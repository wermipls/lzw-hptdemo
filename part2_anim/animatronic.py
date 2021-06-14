import numpy, argparse, bitstring, math, threading, subprocess, os
from PIL import Image, ImageFilter, ImageEnhance, GifImagePlugin
from bitstring import BitArray, BitStream

#def compress(infile, outfile):
#	exe = os.path.abspath(os.path.dirname(__file__))+"\\aplib_pack2.exe"
#	subprocess.run(exe+" "+infile+" "+outfile, stdout=None)

def compress(infile, outfile):
	exe = os.path.abspath(os.path.dirname(__file__))+"\\oapack.exe"
	subprocess.run(exe+" "+infile+" "+outfile, stdout=None)

#def compress(infile, outfile):
#	exe = os.path.abspath(os.path.dirname(__file__))+"\\apultra.exe"
#	subprocess.run(exe+" "+infile+" "+outfile, stdout=None)

def image_convert_pack(img):
	imgarr = numpy.array(img)

	img_packed = BitStream()

	for y in imgarr:
		for i in y:
			img_packed.append(BitArray(bool= i >= 1))

	if args.invert:
		return ~img_packed
	else:
		return img_packed

def image_rearrange8x8(img_packed):
	a = BitStream()

	for i in range(20*20):
		img_packed.bytepos = i%20 + math.floor(i/20)*160
		for x in range(8):
			b = img_packed.peek("bytes:1")
			a.append(b)
			if x < 7:
				img_packed.bytepos += 20

	return a

def image_rearrange_columns(img_packed):
	a = BitStream()

	for i in range(20):
		img_packed.bytepos = i%20 + math.floor(i/20)*160
		for x in range(160):
			b = img_packed.peek("bytes:1")
			a.append(b)
			if x < 159:
				img_packed.bytepos += 20

	return a

def write_asm(output, n_frames):
	metadata = open(output+"_metadata.asm", "w+")
	data = open(output+"_data.asm", "w+")

	label = "ANIM_DATA"

	# metadata file first
	print(f"{label}_FRAME_COUNT equ {n_frames}", file=metadata)
	print(f"{label}_POINTERS:", file=metadata)
	print(f"\tDW {label}", file=metadata)
	for i in range(1, n_frames):
		print(f"\tDW {label}.f{i}", file=metadata)

	print(f"{label}_DELAYS:", file=metadata)
	print(f"\tINCBIN \"{args.output}_dur\"", file=metadata)

	# actual data
	print(f"{label}:", file=data)
	print(f"\tINCBIN \"{args.output}0.aplib\"", file=data)
	for i in range(1, n_frames):
		print(f".f{i}:", file=data)
		print(f"\tINCBIN \"{args.output}{i}.aplib\"", file=data)

	data.close()
	metadata.close()




parser = argparse.ArgumentParser(description="converts image files for use with a speccy animation playback engine")

parser.add_argument("input")
parser.add_argument("output", help="plz name only. no absolute paths")
parser.add_argument("--nodiff", action='store_true')
parser.add_argument("--frames", type=int, default=0)
parser.add_argument("--keep-uncompressed", action='store_true')
parser.add_argument("--invert", action='store_true')
parser.add_argument("--columns", action='store_true')

args = parser.parse_args()

img = Image.open(args.input)

if not getattr(img, "is_animated", False):
	print("not animated bruh. use gif plz")
	exit()

img.seek(img.n_frames-1)
img_old = image_convert_pack(img)
img_old = image_rearrange8x8(img_old)

img_old_odd = img_old
img_old_even = img_old

command_difference = BitArray(bin="00000001")
command_keep = BitArray(bin="00000000")

nim_durations = []
compress_threads = []

size_reorder_total = 0

frames = img.n_frames
if args.frames > 0:
	frames = args.frames

for i in range(frames):
	isOdd = i%2
	if isOdd == 1:
		img_old = img_old_odd
	else:
		img_old = img_old_even

	print("\nframe "+str(i), end="... ")

	nim_durations.append(img.info.get("duration")//20)

	
	img.seek(i)
	img_new = image_convert_pack(img)
	img_new = image_rearrange8x8(img_new)

	
	img_old.bytepos = 0
	img_new.bytepos = 0

	encoded_cmds = BitStream()
	encoded_data = BitStream()

	filename = args.output+str(i)

	# useful info
	tiles_changed = 0
	tiles_unchanged = 0
	# compare
	for n in range(20*20):
		bold = img_old.peek("bytes:8")
		bnew = img_new.peek("bytes:8")
		if bold == bnew:
			tiles_unchanged += 1
			encoded_cmds.append(command_keep)
		else:
			tiles_changed += 1
			encoded_cmds.append(command_difference)
			encoded_data.append(bnew)
		img_old.bytepos += 8
		img_new.bytepos += 8

	print(f"tiles changed/unchanged: {tiles_changed}/{tiles_unchanged}, bytes of data: {tiles_changed*8}")
	# new = old
	img_old = img_new
	# save encoded diff
	encoded_reorder = encoded_cmds + encoded_data
	f = open(filename, "wb+")
	encoded_reorder.tofile(f)
	f.close()
	# save nodiff
	if args.nodiff:
		f = open(filename+".nodiff", "wb+")
		img_new.tofile(f)
		f.close()
	# compress (TODO: FIX THIS. this is 100% not the right way to do this)
	compress_threads.append(threading.Thread(target=compress(filename, filename+".aplib")))
	# delete original after compression
	if args.keep_uncompressed == False:
		os.remove(filename)
	# size stats
	size_reorder = os.path.getsize(filename+".aplib")
	if tiles_changed != 0:
		ratio = 100-size_reorder/(tiles_changed*8)*100
	else:
		ratio = None
	print (f"\ncompression ratio: {ratio}%")
	size_reorder_total += size_reorder
	#print(f"\nsize reorder: {size_reorder}")
	if isOdd == 1:
		img_old_odd = img_old
	else:
		img_old_even = img_old

print(f"TOTAL SIZE: {size_reorder_total}")

# write asm
# write_asm("animation", frames)

f = open(args.output+"_dur", "wb+")
f.write(bytes(nim_durations))
f.close()