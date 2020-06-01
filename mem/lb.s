init:
	li	x1, 0
	li 	x2, 1
	li	x3, 0x112233F8
	sw	x3, 512(x0)
	lb	x4, 512(x0)
	li	x5, 0xFFFFFFF8
	beq x4, x5, iseq
	sw	x1, 1024(x0)
	j	fim
	
iseq:
	sw	x2, 1024(x0)

fim:
	j fim
