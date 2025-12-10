;
; lab5.2_1.asm
;
; Created: 11/20/2025 3:17:16 PM
; Author : huysk
;
;Write a program to generate a 1 kHz clock signal on pin PA0 using Timer0 interrupt. Use Timer0 in both Normal mode and CTC mode. Verify the waveform using an oscilloscope.
;Connect a push button to PA1 and a single LED to PA2. Write a program that both generates a 1 kHz signal on PA0 and continuously checks the button state. 
;If the button is pressed, turn on the LED; otherwise, turn it off. While controlling the LED, the pulse signal must still be output.

.ORG 0X00
RJMP configure
.ORG 0X20
RJMP TIMER0_COMPA_ISR
.ORG 0X40
configure:
	SBI DDRA, 0
	CBI DDRA, 1
	SBI PORTA, 1
	SBI DDRA, 2
	CBI PORTA, 2

	LDI R16, high(RAMEND)
	OUT SPH, R16
	LDI R16, low(RAMEND)
	OUT SPL, R16

Timer_init:
	LDI R16, 0X02	;Timer0 - CTC mode
	OUT TCCR0A, R16
	LDI R16, 63
	OUT OCR0A, R16	;Set Top = 63
	LDI R16, 0X03	;Prescaler = 64
	OUT TCCR0B, R16
	

	SEI				;Cho phep ngat toan cuc
	LDI R17, (1<<OCIE0A)	;Cho phep ngat Timer0 compa
	STS TIMSK0, R17

start: 
	press_check:
	SBIC PINA, 1
	rjmp press_check
	release_check:
	SBI PORTA, 2
	SBIS PINA, 1
	rjmp release_check
	CBI PORTA, 2
	rjmp press_check

TIMER0_COMPA_ISR:
	IN R16, PORTA
	LDI R17, 0b0000_0001
	EOR R16, R17
	OUT PORTA, R16		;if 1 -> 0, if 0 -> 1

	RETI