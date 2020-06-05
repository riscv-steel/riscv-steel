init:
	csrsi		mstatus, 31
	csrsi		misa, 31
	csrsi		mie, 31
	csrsi		mtvec, 31
	csrsi		mscratch, 31
	csrsi		mepc, 31
	csrsi		mcause, 31
	csrsi		mtval, 31
	csrsi		mip, 31
	csrsi		0x320, 31
	csrsi		mcycle, 31
	csrsi		mcycleh, 31
	csrsi		minstret, 31
	csrsi		minstreth, 31
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
