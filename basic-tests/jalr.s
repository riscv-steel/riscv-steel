init:
	li	x2, 0
	li	x3, 1
	nop
	li	x4, 0x34	
	jalr x5, x4, 4
	nop
	nop
	nop
	li	x4, 0x4c
	jr	x4
	sw	x2, 1024(x0)
	nop
	nop
	nop
j1:
	sw	x3, 1024(x0)
	nop
	nop
	nop
	jr	x5
fim:
	j fim
