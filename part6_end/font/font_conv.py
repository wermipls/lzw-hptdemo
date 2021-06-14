from xml.dom.minidom import parse
import xml.dom.minidom
from PIL import Image

def parse_xml(filename):
	dom = parse(filename)
	col = dom.documentElement
	chars = col.getElementsByTagName("Char")

	chars_parsed = []

	for c in chars:
		width = int(c.getAttribute("width"))

		offset_s = c.getAttribute("offset")
		offset = [int(i) for i in offset_s.split(" ")]

		rect_s = c.getAttribute("rect")
		rect = [int(i) for i in rect_s.split(" ")]

		code = c.getAttribute("code")

		char_parsed = [code, rect[0], width]

		chars_parsed.append(char_parsed)

	return chars_parsed

def generate_img(filename, chars):
	fontimg = Image.open(filename)
	fontimg = Image.alpha_composite(Image.new("RGBA", fontimg.size), fontimg)

	charimgs = []

	for c in chars:
		pos = (c[1], 0, c[1]+c[2], 16)
		charimg = Image.new("RGB", (8, 16))
		charimg.paste(fontimg.crop(pos))
		charimgs.append(charimg)

	img_final = Image.new("RGB", ((len(charimgs)//12+1)*8,192))

	for i in range(len(charimgs)):
		x = i//12
		y = i%12
		img_final.paste(charimgs[i], (x*8, y*16))

	return img_final

chars = parse_xml("entercommand_medium_12.xml")
img = generate_img("entercommand_medium_12.PNG", chars)
img.save("font_medium.png")
f = open("font_medium_charwidths.bin", "wb+")
for i in chars:
	f.write(i[2].to_bytes(1, 'big'))

chars = parse_xml("entercommand_bold_12.xml")
img = generate_img("entercommand_bold_12.PNG", chars)
img.save("font_bold.png")
f = open("font_bold_charwidths.bin", "wb+")
for i in chars:
	f.write(i[2].to_bytes(1, 'big'))

