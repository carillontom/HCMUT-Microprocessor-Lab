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
	;set data
	LDI R17, 0b10100100
	OUT PORTA, R17
	SBI PORTB, 4
	RCALL DELAY
	CBI PORTB, 4
	RCALL DELAY

	;set led
	LDI R17, 0b11111110
	OUT PORTA, R17
	SBI PORTB, 5
	RCALL DELAY
	CBI PORTB, 5
	RCALL DELAY

RJMP main

DELAY: ;26500 MCs

LDI R17, 20

L1: LDI R18, 40 ; 1

L2: LDI R19, 10 ; 1

L3: 
DEC R19 ; 1
BRNE L3 ; 2 (1 last)
		; Total L3 : L3 = 3x10 - 1 = 29

DEC R18 ; 1
BRNE L2 ; 2 (1 last)
		; 1+29+1+2 = 33
		; Total L2 : 33 x 39 + 32 = 1319

DEC R17 ; 1
BRNE L1 ; 2 (1 last)
		; 1 + 1319 + 1 + 2 = 1323
		; Total L1 : 1323 x 19 + 1322 = 26459

RET

	