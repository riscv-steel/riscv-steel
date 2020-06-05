init:
	csrc		mstatus, 31
	csrc		misa, 31
	csrc		mie, 31
	csrc		mtvec, 31
	csrc		mscratch, 31
	csrc		mepc, 31
	csrc		mcause, 31
	csrc		mtval, 31
	csrc		mip, 31
	csrc		0x320, 31
	csrc		mcycle, 31
	csrc		mcycleh, 31
	csrc		minstret, 31
	csrc		minstreth, 31
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
