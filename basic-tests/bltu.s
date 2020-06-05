init:
	li	x1, -1
	li	x2, 1
	li	x3, 5
	li	x4, 5
	bltu x3, x4, err
	bltu x2, x1, ltu
err:
	sw	x1, 1024(x0)
	j	fim
	
ltu:
	sw	x2, 1024(x0)

fim:
	j fim
