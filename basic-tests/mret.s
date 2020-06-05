init:
	li	x3, 0x24
	csrw mepc, x3
	mret	
	j err
	nop
	nop
	nop
	nop
	nop
	li	x2, 1
	sw	x2, 1024(x0)
	j fim
err:
	li	x1, 0
	sw	x1, 1024(x0)
fim:
	j fim
