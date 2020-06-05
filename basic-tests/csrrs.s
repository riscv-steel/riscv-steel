init:
	li			x31, 0xFFFFFFFF
	csrs		mstatus, x31
	csrs		misa, x31
	csrs		mie, x31
	csrs		mtvec, x31
	csrs		mscratch, x31
	csrs		mepc, x31
	csrs		mcause, x31
	csrs		mtval, x31
	csrs		mip, x31
	csrs		0x320, x31
	csrs		mcycle, x31
	csrs		mcycleh, x31
	csrs		minstret, x31
	csrs		minstreth, x31
	rdcycle		x1
	rdcycleh	x2
	rdtime		x3
	rdtimeh		x4
	rdinstret	x5
	rdinstreth	x6	
	csrr		x7, mstatus
	csrr		x8, misa
	csrr		x9, mie
	csrr		x10, mtvec
	csrr		x11, mscratch
	csrr		x12, mepc
	csrr		x13, mcause
	csrr		x14, mtval
	csrr		x15, mip
	csrr		x16, mcycle
	csrr		x17, mcycleh
	csrr		x18, minstret
	csrr		x19, minstreth
	csrr		x20, 0x320
fim:
	j fim
