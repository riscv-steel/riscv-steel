init:
	li	x1, 0
	li	x2, 1
	li	x3, 5
	li	x4, 5
	bne x3, x4, eq
	bne x1, x2, neq
eq:
	sw	x1, 1024(x0)
	j	fim
	
neq:
	sw	x2, 1024(x0)

fim:
	j fim
