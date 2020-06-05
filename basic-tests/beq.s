init:
	li	x1, 0
	li	x2, 1
	li	x3, 5
	li	x4, 5
	beq x1, x2, neq
	beq x3, x4, iseq
neq:
	sw	x1, 1024(x0)
	j	fim
	
iseq:
	sw	x2, 1024(x0)

fim:
	j fim
