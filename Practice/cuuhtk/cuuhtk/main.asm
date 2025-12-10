.org 0x00
rjmp main
.org 0x1E
rjmp  TIMER1_OVF_ISR
.org 0x40

   
main: 
	 LDI R16, 0XFF
	 OUT DDRB, R16	;PB to LCD

	 RCALL LCD_Init

	CLR R20
	CLR R21 ;R21:R20 second
	CLR R22
	CLR R23 ;R23 - R22 minutes

	
Timer1_Init_1s:
    ; preload Timer1 so that overflow happens after 1s
    ; 8 MHz / 256 = 31 250 ticks per second
    ; preload = 65536 - 31250 = -31250 = 0x85EE
    ldi  r16, high(-31250)
    STS  TCNT1H, r16
    ldi  r16, low(-31250)
    sts  TCNT1L, r16

    ; Timer1 normal mode
    ldi  r16, 0x00
    sts  TCCR1A, r16

    ; internal clock, prescaler = 256  (CS12 = 1, CS11 = 0, CS10 = 0)
    ldi  r16, (1<<CS12)
    sts  TCCR1B, r16

    ; enable Timer1 overflow interrupt
    ; use TIMSK1 for ATmega324P, TIMSK for ATmega32
    ldi  r16, (1<<TOIE1)
    sts  TIMSK1, r16        ; or: out TIMSK, r16

    sei                     ; global interrupt enable

start:
check_unit_sec:
	CPI R20, 10
	BREQ inc_dozen_sec
	RJMP check_dozen_sec
	inc_dozen_sec:
	INC R21
	CLR R20

check_dozen_sec:
	CPI R21, 6
	BREQ inc_unit_min
	RJMP check_unit_min
	inc_unit_min:
	INC R22
	CLR R21

check_unit_min:
	CPI R22, 10
	BREQ inc_dozen_min
	RJMP check_dozen_min
	inc_dozen_min:
	INC R23
	CLR R22

check_dozen_min:
	CPI R23, 6
	BREQ stop_clock

stop_clock:
	NOP

LCD_Display:
	LDI R17, 0X80; bring pointer to first position of row 1
	RCALL write_cmd_lcd
	RCALL delay2ms

	LDI ZH, high(L1 << 1); set pointer to the first position address of the first string
	LDI ZL, low(L1 << 1)
L1_write:	
	LPM R17, Z+; LPM value at Z to R17 and +Z
	CPI R17, 0; check if null terminator met
	BREQ exit_L1
	RCALL write_data_lcd
	RJMP L1_write
exit_L1:
	NOP
	LDI R17, 0xC0;set pointer of lcd to the second roww
	RCALL write_cmd_lcd

;Line 2
	MOV R17, R23
	SUBI R17, -'0'
	RCALL write_data_lcd
	MOV R17, R22
	SUBI R17, -'0'
	RCALL write_data_lcd

	LDI R17, 58				; ":"
	RCALL write_data_lcd

	MOV R17, R21
	SUBI R17, -'0'
	RCALL write_data_lcd
	MOV R17, R20
	SUBI R17, -'0'
	RCALL write_data_lcd

	RJMP start

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
	LDI R17, 0X06	;Display on, cursor off (must have)
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

;-----------------------------------------
; Timer1 overflow ISR – occurs every 1 s
;-----------------------------------------
TIMER1_OVF_ISR:
	PUSH R16
	IN R16, SREG
	PUSH R16

    ; reload Timer1 for next 1 second
    ldi  r16, high(-31250)
    sts  TCNT1H, r16
    ldi  r16, low(-31250)
    sts  TCNT1L, r16

	INC R20
	POP R16
	OUT SREG, R16
	POP R16
    reti

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

L1: .db "2351045", 0 
