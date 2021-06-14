import numpy, argparse, math, bitstring
from PIL import Image, ImagePalette
from bitstring import BitArray, BitStream

# argument parsing

parser = argparse.ArgumentParser(description="converts image files to use in speccy software")
parser.add_argument("input")
parser.add_argument("output")
parser.add_argument("-q", default="maxcoverage",
                    help="method to use for tile quantization. options: mediancut, octree, maxcoverage (default)")
parser.add_argument("-d", action='store_true',
                    help="dither")
parser.add_argument("--attrib-v", type=int, default=8)
parser.add_argument("--attrib-h", type=int, default=8)
parser.add_argument("--invert", action='store_true')
def ordering(s):
	d = {
		"columns": "col",
		"rows": "row"
	}
	try:
		pepe = d[s]
		return pepe
	except:
		raise argparse.ArgumentTypeError("must be \"columns\" or \"rows\"")
parser.add_argument("--order", type=ordering)

def crop_box(s):
	try:
		x1, y1, x2, y2 = map(int, s.split(','))
		return (x1, y1, x2, y2)
	except:
		raise argparse.ArgumentTypeError("crop values must be x1,y1,x2,y2")
parser.add_argument("--crop", type=crop_box, default=None)

args = parser.parse_args()

# parser helper function
def getqmethod(string):
	d = {
		"mediancut": Image.MEDIANCUT,
		"octree": Image.FASTOCTREE,
		"maxcoverage": Image.MAXCOVERAGE
	}
	
	return d[string]

def image_convert_pack(img, invert=False):
	imgarr = numpy.array(img)

	img_packed = BitStream()

	for y in imgarr:
		for i in y:
			img_packed.append(BitArray(bool= i >= 1))

	if invert:
		return ~img_packed
	else:
		return img_packed

def extrema_to_attrib(extrema):
	paper = extrema[0]%8
	ink = extrema[1]%8
	bright = 0
	if ink > 8:
		bright = 1
	b = bitstring.pack("0b0, uint:1, uint:3, uint:3", bright, ink, paper)
	return b

# defining palettes for attrib convert

palette_dark = [
	6,8,0,		# black
	13,19,167,	# blue
	189,7,7,	# red
	195,18,175,	# magenta
	7,186,12,	# green
	13,198,180,	# cyan
	188,185,20,	# yellow
	194,196,188	# white
]
palette_dark_img = Image.new("P", (8,1))
palette_dark_img.putpalette(palette_dark)

palette_bright = [
	6,8,0,		# black
	22,28,176,	# blue
	206,24,24,	# red
	220,44,200,	# magenta
	40,220,45,	# green
	54,239,222,	# cyan
	238,235,70,	# yellow
	253,255,247,	# white
]
palette_bright_img = Image.new("P", (8,1))
palette_bright_img.putpalette(palette_bright)
palette_combined = palette_dark+palette_bright
palette_combined_img = Image.new("P", (16,1))
palette_combined_img.putpalette(palette_combined)


# actual processing

img = Image.open(args.input).convert("RGB")

# crop
if args.crop != None:
	img = img.crop(args.crop)
# gracefully handle different image sizes
if img.width > 256 or img.height > 192:
	print("warning: input image dimensions exceed 256x192")
if img.width%8 or img.height%8:
	print("warning: image dimensions are not 8x8 aligned. padding to compensate")
	img_temp = Image.new("RGB", (math.ceil(img.width/8)*8, math.ceil(img.height/8)*8))
	box = (img_temp.width-img.width)//2, (img_temp.height-img.height)//2
	img_temp.paste(img, box)
	img = img_temp

img_data = BitStream()
attrib_data = BitStream()

err = False

for x in range(img.width//8):
	for y in range(img.height//8):
		tile_box = x*8, y*8, x*8+8, y*8+8
		tile = img.crop(tile_box).quantize(colors=16, dither=0, palette=palette_combined_img)

		extrema = tile.getextrema()
		print(extrema)
		if extrema[1] > 8:
			print(f"bright, {x}, {y}")
			#tile.show()
		if extrema[0] < 8 and extrema[1] > 8 and extrema[0] != 0:
			print(f"warning: bright and dark colors mixed up in an attribute {x},{y}!")
			
			tile.show()

		tile = tile.quantize(dither=0) # color reduction
		if tile.getcolors(maxcolors=2) == None:
			print(f"error: too many colors in attribute {x},{y}")
			err = True

		# pixel data
		tile_data = image_convert_pack(tile, args.invert)
		img_data.append(tile_data)
		# attrib data
		attrib = extrema_to_attrib(extrema)
		print(attrib.bin)
		attrib_data.append(attrib)


if err:
	print("conversion failed. exiting...")
	exit()

f = open(args.output+"_data", "wb+")
img_data.tofile(f)
f.close()
f = open(args.output+"_attrib", "wb+")
attrib_data.tofile(f)
f.close()


