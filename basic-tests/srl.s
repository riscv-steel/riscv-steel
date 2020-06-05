1:	li	x1, 0xFFFFFFF8
	li	x2, 3
	srl x3, x1, x2
	sw	x3, 1024(x0)
