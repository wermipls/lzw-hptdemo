import math
import numpy

l = []

# og values:
# mag=4, offset=8

samples = 256
magnitude = 110
offset = 128

for i in range(samples):
	rad = (i/samples)*math.pi*2 
	l.append(round((math.sin(rad))*magnitude+offset))

a = numpy.array(l, dtype=numpy.uint8)

f = open("./SiNTABLE.PROPER.bin", "wb+")
f.write(a)
f.close()

print(l)