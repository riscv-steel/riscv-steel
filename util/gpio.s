# this is a very, very simple program that blinks a LED connected to GPIO port #1
# the light turns on/off every second when the the clock speed is 50MHz
# this program only work if the parameter MCOUNTINHIBIT_CY_RESET in globals.vh is set to zero (default value)

init:
	li 	x1, 1
	li	x2, 0xFFFFFF40	# GPIO 1 configuration register address
	li	x3, 0xFFFFFF00	# GPIO 1 output register address
	sw	x1, 0(x2)		# configures GPIO 1 as output
	li	x4, 10			# x4 holds the number of clock cycles the LED stands on/off
begin:	
	sw	x1, 0(x3)		# sets GPIO 1 output to 1
	csrw	mcycle, x0	# clears mcycle CSR
loop1:
	csrr	x5, mcycle
	ble	x5, x4, loop1
	sw	x0, 0(x3)		# sets GPIO 1 output to 0
	csrw	mcycle, x0	# clears mcycle CSR
loop0:
	csrr	x5, mcycle
	ble	x5, x4, loop0	
	j begin
