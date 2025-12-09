;	Wiring:
;	7SEG Data 0 - 7 --> PA0 - PA7
;	nLE0 --> PB4
;	nLE1 --> PB5
.org 0x00
rjmp configure
.org 0x50

configure:
	LDI R16, 0xFF
	OUT DDRA, R16
	OUT DDRB, R16
	SBI 
	CLR R16

turn_off_leds:
	LDI R25, 0xFF
	OUT PORTA, R25
	SBI PORTB, 4
	SBI PORTB, 5
	NOP
	CBI PORTB, 4
	CBI PORTB, 5	

main:
	ldi  r16, high(RAMEND)
	out  SPH, r16
	ldi  r16, low(RAMEND)
	out  SPL, r16

	LDI R28, 1
	LDI R29, 0
	CALL seg_data
	CALL seg_led
	CALL DELAY

	LDI R28, 2
	LDI R29, 1
	CALL seg_data
	CALL seg_led
	CALL DELAY

	LDI R28, 3
	LDI R29, 2
	CALL seg_data
	CALL seg_led
	CALL DELAY

	LDI R28, 4
	LDI R29, 3
	CALL seg_data
	CALL seg_led
	CALL DELAY

			RJMP main



seg_data:
	CLR R16
	LDI ZH, high(table_7seg_data<<1)
	LDI ZL, low(table_7seg_data<<1)

	ADD R30, R28
	ADC R31, R16 ;Con tro Z dang mang dia chi can tro toi

	LPM R22, Z
	OUT PORTA, R22
	SBI PORTB, 4
	NOP
	NOP
	CBI PORTB, 4
	RET

seg_led:
	CLR R16
	LDI ZH, high(table_7seg_control<<1)
	LDI ZL, low(table_7seg_control<<1)

	ADD R30, R29
	ADC R31, R16 ;Con tro Z dang mang dia chi can tro toi

	LPM R22, Z
	OUT PORTA, R22
	SBI PORTB, 5
	NOP
	NOP
	CBI PORTB, 5
	RET


DELAY: ; ~320,000 MCs ~40ms

    LDI R20, 2   
L0: LDI R17, 121     

L1: LDI R18, 40     
L2: LDI R19, 10     
L3:
    DEC R19
    BRNE L3

    DEC R18
    BRNE L2

    DEC R17
    BRNE L1

    DEC R20
    BRNE L0
    RET


; Lookup table for 7-segment codes 
table_7seg_data: .DB 0XC0, 0XF9,0XA4,0XB0,0X99,0X92,0X82,0XF8,0X80,0X90,0X88,0X83
   .DB  0XC6,0XA1,0X86,0X8E
; Lookup table for LED control 
table_7seg_control:   
   .DB  0b00001110,0b00001101, 0b00001011, 0b00000111 	