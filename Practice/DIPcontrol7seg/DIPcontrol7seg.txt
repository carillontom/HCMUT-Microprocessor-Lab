.ORG 0X00
RJMP configure
.ORG 0X24
RJMP TIMER0_OVF_ISR
.ORG 0X40

configure:
	LDI R16, 0X00
	OUT DDRB, R16
	OUT PORTA, R16

	LDI R16, 0XFF
	OUT PORTB, R16
	OUT DDRA, R16
	
	SBI DDRD, 4
	SBI DDRD, 5
	CBI PORTD, 4
	CBI PORTD, 5

	LDI R16, high(RAMEND)
	OUT SPH, R16
	LDI R16, low(RAMEND)
	OUT SPL, R16

Timer_init:
	LDI R16, 0
	OUT TCNT0, R16	
	LDI R16, 0X00	;Timer0 - Normal mode
	OUT TCCR0A, R16
	LDI R16, 0X05	; Start timer Prescaler = 1024
	OUT TCCR0B, R16
	
	SEI				;Cho phep ngat toan cuc
	LDI R17, (1<<TOIE0)	;Cho phep ngat Timer0 overflow
	STS TIMSK0, R17

	CLR R20 ;Timer loop counter
main:
	CPI R20, 107
	BRLO main
	CLR R20
	LDI R16, 0X00	;temporary stop timer
	OUT TCCR0B, R16

	IN R16, PINB
	LDI R17, 0XFF
	EOR R16, R17

	CPI R16, 80
	BRLO case_1
	CPI R16, 150
	BRLO case_2
	CPI R16, 255
	BRLO case_3
	BREQ case_3
	rjmp main

case_1:
	LDI R28, 0
	RCALL seg_data
	LDI R29, 4
	RCALL seg_led
	RJMP Timer_init

case_2:
	LDI R28, 7
	RCALL seg_data
	LDI R29, 0
	RCALL seg_led
	RJMP Timer_init

case_3:
	LDI R28, 7
	RCALL seg_data
	LDI R29, 3
	RCALL seg_led
	RJMP Timer_init

;------------------------------
seg_data:
	CLR R16
	LDI ZH, high(table_7seg_data<<1)
	LDI ZL, low(table_7seg_data<<1)

	ADD R30, R28
	ADC R31, R16 ;Con tro Z dang mang dia chi can tro toi

	LPM R22, Z
	OUT PORTA, R22
	SBI PORTD, 4
	NOP
	NOP
	CBI PORTD, 4
	RET

seg_led:
	CLR R16
	LDI ZH, high(table_7seg_control<<1)
	LDI ZL, low(table_7seg_control<<1)

	ADD R30, R29
	ADC R31, R16 ;Con tro Z dang mang dia chi can tro toi

	LPM R22, Z
	OUT PORTA, R22
	SBI PORTD, 5
	NOP
	NOP
	CBI PORTD, 5
	RET


TIMER0_OVF_ISR:
	LDI R17, 0X00
	OUT TCCR0B, R17		;stop timer

	INC R20

	LDI R17, 0
	OUT TCNT0, R17
	LDI R17, 0X05		;RESTART TIMER
	OUT TCCR0B, R17

	RETI


; Lookup table for 7-segment codes 
table_7seg_data: .DB 0XC0, 0XF9,0XA4,0XB0,0X99,0X92,0X82,0XF8,0X80,0X90,0X88,0X83
   .DB  0XC6,0XA1,0X86,0X8E
; Lookup table for LED control 
table_7seg_control:   
   .DB  0b00001110,0b00001101, 0b00001011, 0b00000111, 0b00000000