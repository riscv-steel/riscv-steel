init:
	li	x2, 0
	li	x3, 1
	nop
	nop	
	jal j1
	nop
	nop
	nop
	nop
	j fim
	sw	x2, 1024(x0)
	nop
	nop
	nop
j1:
	sw	x3, 1024(x0)
	nop
	nop
	nop
	ret
fim:
	j fim
