init:
	nop
	nop
	nop
	nop
	li	x1, 1
	sw	x1, 1024(x0)
	ebreak
	li	x1, 0
	sw	x1, 1024(x0)
fim:
	j fim
