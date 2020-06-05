init:
	li			x31, 0xFFFFFFFF
	csrc		mstatus, x31
	csrc		misa, x31
	csrc		mie, x31
	csrc		mtvec, x31
	csrc		mscratch, x31
	csrc		mepc, x31
	csrc		mcause, x31
	csrc		mtval, x31
	csrc		mip, x31
	csrc		0x320, x31
	csrc		mcycle, x31
	csrc		mcycleh, x31
	csrc		minstret, x31
	csrc		minstreth, x31
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
