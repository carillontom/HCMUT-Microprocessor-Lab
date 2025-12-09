;	Wiring:
;	7SEG Data 0 - 7 --> PA0 - PA7
;	nLE0 --> PB4
;	nLE1 --> PB5

configure:
	LDI R16, 0xFF
	OUT DDRA, R16
	SBI DDRB, 4
	SBI DDRB, 5

main:
	call segdata_on
	call led_on 
	call DELAY
	call segdata_off
	call led_on
	call DELAY
	RJMP main

segdata_on:
	CLR R16
	LDI R29, 1
	LDI ZH, high(table_7seg_data<<1)
	LDI ZL, low(table_7seg_data<<1)

	ADD R30, R29
	ADC R31, R16 ;Con tro Z dang mang dia chi can tro toi

	LPM R22, Z
	OUT PORTA, R22
	SBI PORTB, 4
	CBI PORTB, 4
	RET

led_on:
	CLR R16
	LDI R29, 0
	LDI ZH, high(table_7seg_control<<1)
	LDI ZL, low(table_7seg_control<<1)

	ADD R30, R29
	ADC R31, R16 ;Con tro Z dang mang dia chi can tro toi

	LPM R22, Z
	OUT PORTA, R22
	SBI PORTB, 5
	CBI PORTB, 5
	RET

DELAY: ; ~320,000 MCs 

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

segdata_off:
	CLR R16
	LDI R29, 16
	LDI ZH, high(table_7seg_data<<1)
	LDI ZL, low(table_7seg_data<<1)

	ADD R30, R29
	ADC R31, R16 ;Con tro Z dang mang dia chi can tro toi

	LPM R22, Z
	OUT PORTA, R22
	SBI PORTB, 4
	CBI PORTB, 4
	RET


; Lookup table for 7-segment codes 
table_7seg_data: .DB 0XC0, 0XF9,0XA4,0XB0,0X99,0X92,0X82,0XF8,0X80,0X90,0X88,0X8 
   .DB  0XC6,0XA1,0X86,0X8E,0XFF
; Lookup table for LED control 
table_7seg_control:   
   .DB  0b00001110,0b00001101, 0b00001011, 0b00000111 	