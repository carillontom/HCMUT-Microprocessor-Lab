.ORG 0X00
RJMP begin
.ORG 0X40

begin:
	CBI DDRA, 0 
	CBI DDRA, 1
	CBI DDRA, 2
	SBI PORTA, 0
	SBI PORTA, 1
	SBI PORTA, 2

	LDI R16, 0XFF
	OUT DDRB, R16
	LDI R16, 0X00
	OUT PORTB, R16

	SBI DDRC, 0 
	SBI DDRC, 1
	CBI PORTC, 0 
	CBI PORTC, 1

	LDI R16, high(RAMEND)
	OUT SPH, R16
	LDI R16, low(RAMEND)
	OUT SPL, R16



press_check:
	CLR R16		;use as check loop counter
	
	SBIS PINA, 0
	RJMP sw0_check
	SBIS PINA, 1
	RJMP sw1_check
	SBIS PINA, 2
	RJMP sw2_check
	RJMP press_check

;------------------
sw0_check:
	CALL delay500ms
	SBIC PINA, 0 
	RJMP press_check	;released early
	INC R16
	CPI R16, 8
	BREQ sw0_valid
	RJMP sw0_check

sw1_check:
	CALL delay500ms
	SBIC PINA, 1
	RJMP press_check	;released early
	INC R16
	CPI R16, 8
	BREQ sw1_valid
	RJMP sw1_check
	
sw2_check:
	CALL delay500ms
	SBIC PINA, 2 
	RJMP press_check	;released early
	INC R16
	CPI R16, 8
	BREQ sw2_valid
	RJMP sw2_check

;-----------------

sw0_valid:
	SBIS PINA, 0 
	RJMP sw0_valid ;not released afterward
	CLR R16
	LDI R28, 16
	CALL seg_data
	LDI R29, 4
	CALL seg_led
	RJMP press_check

sw1_valid:
	SBIS PINA, 1
	RJMP sw1_valid ;not released afterward
	CLR R16
	LDI R28, 4
	CALL seg_data
	LDI R29, 0
	CALL seg_led
	RJMP press_check

sw2_valid:
	SBIS PINA, 2
	RJMP sw2_valid ;not released afterward
	CLR R16
	LDI R28, 4
	CALL seg_data
	LDI R29, 3
	CALL seg_led
	RJMP press_check

delay500ms:
	PUSH R16
	PUSH R17
	PUSH R18

	LDI R16, 250
	LOOP_1:
	LDI R17, 200
	LOOP_2:
	LDI R18, 16
	LOOP_3:
	NOP
	NOP
	DEC R18
	BRNE LOOP_3
	DEC R17
	BRNE LOOP_2
	DEC R16
	BRNE LOOP_1

	POP R18
	POP R17
	POP R16
	RET

seg_data:;R28 = so can xuat
	PUSH R16
	CLR R16
	LDI ZH, high(table_7seg_data<<1)
	LDI ZL, low(table_7seg_data<<1)

	ADD R30, R28
	ADC R31, R16 ;Con tro Z dang mang dia chi can tro toi

	LPM R22, Z
	OUT PORTB, R22
	SBI PORTC, 0
	NOP
	NOP
	CBI PORTC, 0
	POP R16
	RET

seg_led:;R29 = so thu tu cua led can xuat
	PUSH R16
	CLR R16
	LDI ZH, high(table_7seg_control<<1)
	LDI ZL, low(table_7seg_control<<1)

	ADD R30, R29
	ADC R31, R16 ;Con tro Z dang mang dia chi can tro toi

	LPM R22, Z
	OUT PORTB, R22
	SBI PORTC, 1
	NOP
	NOP
	CBI PORTC, 1
	POP R16
	RET

; Lookup table for 7-segment codes 
table_7seg_data: .DB 0XC0, 0XF9,0XA4,0XB0,0X99,0X92,0X82,0XF8,0X80,0X90,0X88,0X83
   .DB  0XC6,0XA1,0X86,0X8E,0XFF
; Lookup table for LED control 
table_7seg_control:   
   .DB  0b00001110, 0b00001101, 0b00001011, 0b00000111, 0b00001111 	