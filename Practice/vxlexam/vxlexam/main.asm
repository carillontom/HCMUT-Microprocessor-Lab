.org 0x00
rjmp main
.org 0x1E
rjmp  TIMER1_OVF_ISR
.org 0x40

;Write a function using Timer1 interrupt to generate a time interval of 1 second, using that function to write a program to display a second counter on four 7 segment leds
   
main: 
	 LDI R16, 0XFF
	 OUT DDRA, R16	;PA to 7SEG DATA

	SBI DDRB, 4; NLE0
	SBI DDRB, 5 ; NLE1
	
	CLR R20	
	CLR R21
	CLR R22
	CLR R23 

	ldi  r16, high(RAMEND)
	out  SPH, r16
	ldi  r16, low(RAMEND)
	out  SPL, r16
	
Timer1_Init_1s:
    ; 8 MHz / 256 = 31 250 Hz
    ; preload = 65536 - 31250 = -31250 
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
    ldi  r16, (1<<TOIE1)
    sts  TIMSK1, r16        ;  TIMSK, r16

    sei                     ;cho phep ngat toan cuc

start:
	RCALL spltter ;R23 : R20 - ngan - tram - chuc - don vi
	
	MOV R28, R20
	RCALL seg_data
	LDI R29, 0
	RCALL seg_led
	RCALL delay2ms

	MOV R28, R21
	RCALL seg_data
	LDI R29, 1
	RCALL seg_led
	RCALL delay2ms

	MOV R28, R22
	RCALL seg_data
	LDI R29, 2
	RCALL seg_led
	RCALL delay2ms

	MOV R28, R23
	RCALL seg_data
	LDI R29, 3
	RCALL seg_led
	RCALL delay2ms

	RJMP start


spltter:
check_unit_sec:
	CPI R20, 10
	BREQ inc_dozen_sec
	RJMP check_dozen_sec
	inc_dozen_sec:
	INC R21
	CLR R20

check_dozen_sec:
	CPI R21, 10
	BREQ inc_unit_min
	RJMP check_unit_min
	inc_unit_min:
	INC R22
	CLR R21
	CLR R20

check_unit_min:
	CPI R22, 10
	BREQ inc_dozen_min
	RJMP check_dozen_min
	inc_dozen_min:
	INC R23
	CLR R22
	CLR R21
	CLR R20 

check_dozen_min:
	CPI R23, 10
	BRNE done
	BREQ stop_clock

stop_clock:
	LDI R23, 9 
	LDI R22, 9
	LDI R21, 9
	LDI R20, 9

done:
	RET

;------------7 seg

seg_data:
	PUSH R16
	CLR R16
	LDI ZH, high(table_7seg_data<<1)
	LDI ZL, low(table_7seg_data<<1)

	ADD R30, R28
	ADC R31, R16 ;Con tro Z dang mang dia chi can tro toi

	LPM R24, Z
	OUT PORTA, R24
	SBI PORTB, 4
	NOP
	NOP
	CBI PORTB, 4
	POP R16
	RET

seg_led:
	PUSH R16
	CLR R16
	LDI ZH, high(table_7seg_control<<1)
	LDI ZL, low(table_7seg_control<<1)

	ADD R30, R29
	ADC R31, R16 ;Con tro Z dang mang dia chi can tro toi

	LPM R24, Z
	OUT PORTA, R24
	SBI PORTB, 5
	NOP
	NOP
	CBI PORTB, 5
	POP R16
	RET

;---------------

TIMER1_OVF_ISR:
	PUSH R16
	IN R16, SREG
	PUSH R16

    ; reload Timer1 
    ldi  r16, high(-31250)
    sts  TCNT1H, r16
    ldi  r16, low(-31250)
    sts  TCNT1L, r16

	INC R20			;1 sec to counter

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




table_7seg_data: .DB 0XC0, 0XF9,0XA4,0XB0,0X99,0X92,0X82,0XF8,0X80,0X90,0X88,0X83
   .DB  0XC6,0XA1,0X86,0X8E
; Lookup table for LED control 
table_7seg_control:   
   .DB  0b00001110,0b00001101, 0b00001011, 0b00000111 	

