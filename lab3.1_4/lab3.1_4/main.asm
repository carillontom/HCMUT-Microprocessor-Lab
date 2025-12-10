.org 0
	rjmp main
.org 40
main:
//PA0 la output
	ldi r16, 0xFF
	out ddra, r16
//timer 0 NOR
	ldi r17, 0x00
	out tccr0A, r17
//timer 0 nor stop
	ldi r17, 0x00
	out tccr0B, r17
start:
	rcall delay_1ms
	sbi porta, 0
	rcall delay_1ms
	cbi porta, 0
	rjmp start
delay_1ms:
	ldi r17, -32
	out tcnt0, r17
	ldi r17, 0x00
	out tccr0A, r17
	ldi r17, (1<<CS01)	//clockdiv8
	out tccr0B, r17
wait:
	SBIS TIFR0,TOV0 ;ch? c? TOV0 = 1 báo Timer0 tràn
	RJMP WAIT ;c? TOV0=0 ti?p t?c ch?
	SBI TIFR0,TOV0 ;TOV0 = 1 => xóa c? TOV0 ho?c OUT TIFR0,R17
	LDI R17,0x00 ;d?ng Timer0
	OUT TCCR0B,R17
	RET
