import string

src = open("./scrollertext.txt", "rb")
dest = open("./scrollertext_encoded.txt", "wb+")

d = {
	" ":	"@",
	"!":	"[",
	",":	"\\",
	"?":	"{",
	".":	"|",
    "^":    "]",
    "_":    "^",
    "'":    "_"
}

# termination
dest.write('\0'.encode())

while i := src.read(1):
	if i.decode() in d:
		dest.write(d[i.decode()].encode())
		print("dupa")
	else:
		dest.write(i)

# empty space + termination
for i in range(31):
    dest.write('@'.encode())
dest.write('\1'.encode())


src.close()
dest.close()