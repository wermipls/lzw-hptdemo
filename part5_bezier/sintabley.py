import math
import numpy

l = []

# og values:
# mag=4, offset=8

samples = 256
magnitude = 80
offset = 96

for i in range(samples):
	rad = (i/samples)*math.pi*2 
	l.append(round((math.sin(rad))*magnitude+offset))

a = numpy.array(l, dtype=numpy.uint8)

f = open("./sintable_y_variant_cuz_i_dont_wanna_scale_in_code_For_Now.bin", "wb+")
f.write(a)
f.close()

print(l)