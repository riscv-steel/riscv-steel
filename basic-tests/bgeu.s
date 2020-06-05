init:
	li	x1, -1
	li	x2, 1
	li	x3, 5
	li	x4, 5
	bgeu x2, x1, err
	bgeu x3, x4, eq
err:
	sw	x1, 1024(x0)
	j	fim
	
geu:
	sw	x2, 1024(x0)

fim:
	j fim
	
eq:
	bgeu	x1, x2, geu
	j fim
