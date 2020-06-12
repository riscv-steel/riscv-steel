init:
	nop
	nop
	nop
	nop
	nop
	li 	x1, 1
	li	x2, 0x80000000
	sw	x1, 0(x2)
fim:
	j fim
