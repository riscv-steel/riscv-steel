init:
	li	x1, 0
	li	x2, 1
	lui	x3, 0xABCDE
	li	x4, 0xABCDE000
	beq x1, x2, neq
	beq x3, x4, iseq
neq:
	sw	x1, 1024(x0)
	j	fim
	
iseq:
	sw	x2, 1024(x0)

fim:
	j fim
