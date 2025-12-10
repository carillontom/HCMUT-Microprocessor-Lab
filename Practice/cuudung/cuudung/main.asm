.include "m324PAdef.inc"

.org 0x00
rjmp main
.org 0x40

main:
	LDI R16, 0x00
	OUT DDRD, R16	;PORTD noi voi dip switch
	LDI R16, 0XFF
	OUT PORTD, R16	;pull up dip switch
	OUT DDRB, R16 ;PORTB noi voi LCD

start:
	RCALL LCD_Init
	RCALL read_dip 
	RCALL check_value
	RCALL delay4500ms
	RJMP start

read_dip:
	IN R16, PIND
	LDI R17, 0XFF
	EOR R16, R17 ;	dao bit
	;r16 is now holding the value of dipswitch

check_value:
	CPI R16, 80 
	BRLO display_A
	CPI R16, 150
	BRLO display_B
	CPI R16, 200
	BRLO display_C
	CPI R16, 255
	BRLO display_D
	BREQ display_D

	display_A:
	LDI  R17, 0X80
	RCALL write_cmd_lcd
	LDI R17, 'A'
	RCALL write_data_lcd
	RET
	display_B:
	LDI  R17, 0X8F
	RCALL write_cmd_lcd
	LDI R17, 'B'
	RCALL write_data_lcd
	RET
	display_C:
	LDI  R17, 0XC0
	RCALL write_cmd_lcd
	LDI R17, 'C'
	RCALL write_data_lcd
	RET
	display_D:
	LDI  R17, 0XCF
	RCALL write_cmd_lcd
	LDI R17, 'D'
	RCALL write_data_lcd
	RET
;--------------------LCD------------------------
LCD_Init:
	LDI R17, 0X03
	RCALL write_cmd_lcd	
	RCALL write_cmd_lcd
	RCALL write_cmd_lcd
	LDI R17, 0X02	;4-bit mode
	RCALL write_cmd_lcd
	LDI R17, 0x28	;Configures LCD interface: 4-bit data length, 2 display lines, and 5×8 font.
	RCALL write_cmd_lcd
	LDI R17, 0X01	;Delete everything on screen
	RCALL write_cmd_lcd
	LDI R17, 0X0C	;Display on, cursor off (must have)
	RCALL write_cmd_lcd
	LDI R17, 0X06	;Auto cursor increment to the right
	RCALL write_cmd_lcd
	CLR R17
	RET

;SUB FUNCTIONS FOR CALLING: write_cmd, write_data, delay2ms

write_cmd_lcd:
	PUSH R16
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
	POP R16
	RET

write_data_lcd:
	PUSH R16
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
	POP R16
	RET


delay2ms:
	 PUSH R23
	 PUSH R24
	 PUSH R25
	 PUSH R26
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
	POP R26
	POP R25
	POP R24
	POP R23
    RET

delay4500ms:
    push r18
    push r19

    ldi r18, 17          ; outer loop = 17

outer_loop:
    ldi r19, 8           ; inner loop = 8

inner_loop:
    ; Load Timer0 initial value (full 256 count)
    ldi r16, 0x00
    out TCNT0, r16

    ; Prescaler = 1024 ? CS02=1, CS00=1
    ldi r16, (1<<CS02) | (1<<CS00)
    out TCCR0B, r16

wait_ovf:
    in r16, TIFR0
    sbrs r16, TOV0       ; wait for overflow
    rjmp wait_ovf

    ; Clear overflow flag
    ldi r16, 1<<TOV0
    out TIFR0, r16

    dec r19
    brne inner_loop

    dec r18
    brne outer_loop

    ; Stop Timer0
    ldi r16, 0x00
    out TCCR0B, r16

    pop r19
    pop r18
    ret