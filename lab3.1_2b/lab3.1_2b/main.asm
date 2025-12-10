.org 0
	rjmp main
.org 40
main:
//PB3 la output
	ldi r16, 0x08
	out ddrb, r16
//timer 1 CTC
	ldi r17, 0x00
	sts tccr1A, r17
	ldi r17, (1<<WGM12|1<<CS11)
	sts tccr1B, r17	//mode ctc clockdiv8
	ldi r17, high(32-1)
	sts ocr1aH, r17
	ldi r17, low(32-1)
	sts ocr1aL, r17	
start:
	rcall delay_ms
	sbi portb, 3
	rcall delay_ms
	cbi portb, 3
	rjmp start
delay_ms:
	SBIS TIFR1,OCF1A 
	RJMP delay_ms 
	SBI TIFR1,OCF1A 
	RET

