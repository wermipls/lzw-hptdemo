import math
import numpy

l = []

# og values:
# mag=4, offset=8

samples = 256
magnitude = 68
offset = 0

for i in range(samples):
	rad = (i/samples)*math.pi*2 
	sin = math.cos(rad*2)
	#sinmag = 1-abs(math.cos(rad))
	sinmag = math.sin(rad)
	sin = sin*sinmag
	l.append(round((sin)*magnitude+offset))

a = numpy.array(l, dtype=numpy.int8)

f = open("./crazysin2.bin", "wb+")
f.write(a)
f.close()

print(l)