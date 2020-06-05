init:
	li			x31, 0xFFFFFFFF
	csrw		mstatus, x31
	csrw		misa, x31
	csrw		mie, x31
	csrw		mtvec, x31
	csrw		mscratch, x31
	csrw		mepc, x31
	csrw		mcause, x31
	csrw		mtval, x31
	csrw		mip, x31
	csrw		0x320, x31
	csrw		mcycle, x31
	csrw		mcycleh, x31
	csrw		minstret, x31
	csrw		minstreth, x31
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
