# type in data here
# MAKE SURE TO EXPORT .OBJ IN BLENDER WITH "-Z FORWARD" AND "-Y UP"!
# AS WELL AS RECALCULATE NORMALS

faces_old = [
	(1,2,3),
	(1,4,5),
	(6,3,7),
	(6,8,4),
	(9,10,2),
	(9,5,11),
	(12,7,10),
	(12,11,8),
	(1,5,2),
	(9,2,5),
	(6,7,8),
	(12,8,7),
	(3,6,1),
	(4,1,6),
	(10,9,12),
	(11,12,9),
	(2,10,3),
	(7,3,10),
	(5,4,11),
	(8,11,4),
]

faces = []
count = 0
vertcount = 3

for f in faces_old:
	if vertcount == 4:
		f_new = (f[0]-1, f[1]-1, f[2]-1, f[3]-1)
	else:
		f_new = (f[0]-1, f[1]-1, f[2]-1)
	faces.append(f_new)

print("faces:")
for f in faces:
	print(f)

lines = {}

line_indices = []

print("lines:")
for f in faces:
	face_lines = []
	if vertcount == 4:
		face_lines = [0,0,0,0]
	else:
		face_lines = [0,0,0]
	
	for i in range(vertcount):
		line = (f[i], f[(i+1)%vertcount])
		line_rev = (f[(i+1)%vertcount], f[i])
		if line in lines:
			face_lines[i] = lines[line]
		elif line_rev in lines:
			face_lines[i] = lines[line_rev]
		else:
			print(line)
			lines[line] = count
			face_lines[i] = count
			count += 1
	line_indices.append(face_lines)

print("line indices:")
for i in line_indices:
	print(i)
