init:
	csrwi		mstatus, 0b11111
	csrw		misa, 0b11111
	csrw		mie, 0b11111
	csrw		mtvec, 0b11111
	csrw		mscratch, 0b11111
	csrw		mepc, 0b11111
	csrw		mcause, 0b11111
	csrw		mtval, 0b11111
	csrw		mip, 0b11111
	csrw		0x320, 0b11111
	csrw		mcycle, 0b11111
	csrw		mcycleh, 0b11111
	csrw		minstret, 0b11111
	csrw		minstreth, 0b11111
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
