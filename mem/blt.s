init:
	li	x1, -1
	li	x2, 1
	li	x3, 5
	li	x4, 5
	blt x3, x4, err
	blt x1, x2, lt
err:
	sw	x1, 1024(x0)
	j	fim
	
lt:
	sw	x2, 1024(x0)

fim:
	j fim
