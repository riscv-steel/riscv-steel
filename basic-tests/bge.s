init:
	li	x1, -1
	li	x2, 1
	li	x3, 5
	li	x4, 5
	bge x2, x1, err
	bge x3, x4, eq
err:
	sw	x1, 1024(x0)
	j	fim
	
ge:
	sw	x2, 1024(x0)

fim:
	j fim
	
eq:
	bge	x2, x1, ge
	j fim
