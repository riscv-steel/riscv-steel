init:
	li	x1, 0
	li 	x2, 1
	li	x3, 0xF1F2F3F4
	sw	x3, 512(x0)
	lhu	x4, 512(x0)
	li	x5, 0x0000F3F4
	beq x4, x5, iseq
	sw	x1, 1024(x0)
	j	fim
	
iseq:
	sw	x2, 1024(x0)

fim:
	j fim
