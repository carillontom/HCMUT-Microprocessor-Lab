;PB0 = RS
;PB1 = RW
;PB2 = E
;PB4–PB7 = D4–D7
;PA0 = BUTTON INPUT
;PORTD = BAR LED

	.ORG 0X00
	RJMP configuration
	.ORG 0X50

;INITIATING
configuration:
	LDI R16, 0XFF
	OUT DDRB, R16		;PB as output
	OUT DDRD, R16		;PD as output 

	CBI DDRA, 0		;PA0 as input 
	SBI PORTA, 0	;enables pull-up at PA0

	CLR R16
	CLR R18		;R18 = number of pressed button
	CLR R19		;R19 = hundreds number
	CLR R20		;R20 = tens number
	CLR R21		;R21 = unit number
	LDI R27, 48
lcd_start:
	LDI R17, 0X03
	RCALL write_cmd_lcd
	LDI R17, 0X03
	RCALL write_cmd_lcd
	LDI R17, 0X03
	RCALL write_cmd_lcd
	LDI R17, 0X02	;4-bit mode
	RCALL write_cmd_lcd
	LDI R17, 0x28	;Configures LCD interface: 4-bit data length, 2 display lines, and 5×8 font.
	RCALL write_cmd_lcd
	LDI R17, 0X01	;Delete everything on screen
	RCALL write_cmd_lcd
	LDI R17, 0X0C	;Display on, cursor off (must have)
	RCALL write_cmd_lcd


;BUTTON READING
read_press:
	SBIS PINA, 0	;if PA0 = 1 (not pressed) continue the loop
	RJMP read_release	;otherwise if PA0 = 0 (pressed) jump to next loop
	RJMP read_press

read_release:
	RCALL delay_debounce
	SBIC PINA, 0 ;if PA0 = 0 (not released) continue the loop
	RJMP count	;if PA0 = 1 (released) jump to next loop
	RJMP read_release 

count:
	CPI R18, 255	;check if it exceed 255 (maximum unsigned 8-bit value)
	BREQ stop_count
	INC R18
	RCALL display_barled ;display on barleds
	RCALL split_digits	;split the number to hundreds, tens, unit
	RCALL display_lcd ;display on lcd screen
	RCALL delay_debounce
	RJMP read_press

stop_count:
	NOP
	RJMP stop_count

;DISPLAYING
display_barled:
	OUT PORTD, R18 
	RET

split_digits:
	CLR R19		;R19 = hundreds number
	CLR R20		;R20 = tens number
	CLR R21		;R21 = unit number

	;HUNDREDS
	MOV R22, R18	;R22 = temp register
	check_hund:
	CPI R22, 100
	BRLO check_ten
	SUBI R22, 100
	INC R19		;increase hundred number
	RJMP check_hund
	;TENS
	check_ten:
	CPI R22, 10
	BRLO check_unit
	SUBI R22, 10
	INC R20		;increase ten number
	RJMP check_ten
	;UNITS
	check_unit:
	CPI R22, 1
	BRLO check_done
	SUBI R22, 1	
	INC R21		;increase unit number
	RJMP check_unit

	check_done:
	RET

display_lcd:
	LDI R17, 0x80 
	RCALL write_cmd_lcd
	ADD R19, R27
	MOV R17, R19
	RCALL write_data_lcd
	ADD R20, R27
	MOV R17, R20
	RCALL write_data_lcd
	ADD R21, R27
	MOV R17, R21
	RCALL write_data_lcd
	RET

;SUB FUNCTIONS FOR CALLING: write_cmd, write_data, delay2ms

write_cmd_lcd:
	MOV R16, R17	;R17 having the command's byte to be transfered
	ANDI R16, 0b11110000 ;keep the high nibble, sort out the lower nibble
	OUT PORTB, R16	;output to PB4-PB7
	CBI PORTB, 0	;RS = 0 cmd
	CBI PORTB, 1	;RW = 0
	SBI PORTB, 2	;EN = 1
	NOP
	CBI PORTB, 2	;EN = 0
	RCALL delay2ms	;delay for sleepy joe lcd to read
	MOV R16, R17	;move command's byte from R17 to R16 again
	SWAP R16	;swap LOW 4 bits with HIGH 4 bits
	ANDI R16, 0b11110000 ;keep the LOW nibble, sort out the HIGH nibble
	OUT PORTB, R16	;output to PB4-PB7
	CBI PORTB, 0	;RS = 0 cmd
	CBI PORTB, 1	;RW = 0
	SBI PORTB, 2	;EN = 1
	NOP
	CBI PORTB, 2	;EN = 0
	RCALL delay2ms	;delay for sleepy joe lcd to read
	RET

write_data_lcd:
	MOV R16, R17	;R17 having the data's byte to be transfered
	ANDI R16, 0b11110000 ;keep the high nibble, sort out the lower nibble
	OUT PORTB, R16	;output to PB4-PB7
	SBI PORTB, 0	;RS = 1 data
	CBI PORTB, 1	;RW = 0
	SBI PORTB, 2	;EN = 1
	NOP
	CBI PORTB, 2	;EN = 0
	RCALL delay2ms	;delay for sleepy joe lcd to read
	MOV R16, R17	;move data's byte from R17 to R16 again
	SWAP R16	;swap LOW 4 bits with HIGH 4 bits
	ANDI R16, 0b11110000 ;keep the LOW nibble, sort out the HIGH nibble
	OUT PORTB, R16	;output to PB4-PB7
	SBI PORTB, 0	;RS = 1
	CBI PORTB, 1	;RW = 0
	SBI PORTB, 2	;EN = 1
	NOP
	CBI PORTB, 2	;EN = 0
	RCALL delay2ms	;delay for sleepy joe lcd to read
	RET

delay2ms:
	 LDI R26, 1
LP0: LDI R25, 12
LP1: LDI R23, 40
LP2: LDI R24, 10
LP3:
    DEC R24
    BRNE LP3

    DEC R23
    BRNE LP2

    DEC R25
    BRNE LP1

    DEC R26
    BRNE LP0
    RET

delay_debounce:
    LDI R26, 1
L0: LDI R23, 242
L1: LDI R24, 40
L2: LDI R25, 10
L3:
    DEC R25
    BRNE L3

    DEC R24
    BRNE L2

    DEC R23
    BRNE L1

    DEC R26
    BRNE L0
    RET
