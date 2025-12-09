.equ lcd_ddr = ddrb
.equ lcd_port = portb
.equ lcd_pin = pinb
.equ rs = 0
.equ rw = 1
.equ en = 2

.org 0
	rjmp main
.org 40
main:
//cau hinh port a va c la output
	ldi r16, 0xff
	out lcd_ddr, r16
loop:
	rcall lcd_init
	rcall line_1_display
	rcall delay_2ms
	rcall line_2_display
endloop:
	rjmp endloop
lcd_init:
	rcall delay_2ms
	ldi r17, 0x03
	rcall write_cmd
	rcall delay_2ms
	rcall write_cmd
	rcall delay_2ms
	rcall write_cmd
	rcall delay_2ms
	ldi r17, 0x02
	rcall write_cmd	//xong reset cap nguon
	rcall delay_2ms
	ldi r17, 0x28
	rcall write_cmd
	ldi r17, 0x01
	rcall write_cmd
	ldi r17, 0x0C
	rcall write_cmd
	ldi r17, 0x06
	rcall write_cmd
	nop
	ret
write_cmd:
	mov r16, r17
	andi r16, 0xf0	//gi? các bit ??u r?i xu?t 4 bit cao ra tr??c
	out lcd_port, r16
	cbi lcd_port, rs
	cbi lcd_port, rw
	sbi lcd_port, en
	nop
	cbi lcd_port, en
	rcall delay_2ms
	mov r16, r17
	swap r16	//??o 4 bit cao và 4 bit th?p ?? t?i l?nh 4 bit th?p
	andi r16, 0xf0
	out lcd_port, r16
	cbi lcd_port, rs
	cbi lcd_port, rw
	sbi lcd_port, en
	nop
	cbi lcd_port, en
	rcall delay_2ms
	ret

write_data:
	mov r16, r17
	andi r16, 0xf0	//gi? các bit ??u r?i xu?t 4 bit cao ra tr??c
	out lcd_port, r16
	sbi lcd_port, rs
	cbi lcd_port, rw
	sbi lcd_port, en
	nop
	cbi lcd_port, en
	rcall delay_2ms
	mov r16, r17
	swap r16	//??o 4 bit cao và 4 bit th?p ?? t?i l?nh 4 bit th?p
	andi r16, 0xf0
	out lcd_port, r16
	sbi lcd_port, rs
	cbi lcd_port, rw
	sbi lcd_port, en
	nop
	cbi lcd_port, en
	rcall delay_2ms
	ret

delay_2ms:
	LDI R18, 20
	DL1:	
		LDI R19, 200
		DL2:
			NOP
			DEC R19
			BRNE DL2
		DEC R18
		BRNE DL1
	RET

line_1_display:
	ldi r17, 0x80
	rcall write_cmd
	ldi zh, high(line1<<1)
	ldi zl, low(line1<<1)
line_1_loop:
	lpm r17, z+
	cpi r17, 0
	breq ext_line1
	rcall write_data
	rjmp line_1_loop

ext_line1:
	ret

line_2_display:
	ldi r17, 0xC0
	rcall write_cmd
	ldi zh, high(line2<<1)
	ldi zl, low(line2<<1)
line_2_loop:
	lpm r17, z+
	cpi r17, 0
	breq ext_line2
	rcall write_data
	rjmp line_2_loop
ext_line2:
	ret
.org 0x200
line1: .db "MCU-AVR LAB", 0
line2: .db "GROUP: 02", 0
