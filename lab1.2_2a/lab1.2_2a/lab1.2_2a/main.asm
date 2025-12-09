;
; lab1.2_2a.asm
;
; Created: 9/21/2025 3:38:35 PM
; Author : huysk
;


; Replace with your application code

.org 0x00
rjmp main
.org 0x50
main:
LDI R16, 0x01
OUT DDRA, R16; PA0 output

start:
SBI PORTA, 0
CALL DELAY_1ms
CBI PORTA, 0
CALL DELAY_1ms
RJMP start

DELAY_1ms: ;8000 MCs
NOP
NOP ; 2
LDI R17, 6 ; 1

L1: LDI R18, 40 ; 1
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP ; 10

L2: LDI R19, 10 ; 1

L3: 
DEC R19 ; 1
BRNE L3 ; 2 (1 last)
		; Total L3 : L3 = 3 x 9 + 2 = 29

DEC R18 ; 1
BRNE L2 ; 2 (1 last)
		; 1+29+1+2 = 33
		; Total L2 : 33 x 39 + 32 = 1319

DEC R17 ; 1
BRNE L1 ; 2 (1 last)
		; 1 + 1319 + 1 + 2 + 10 = 1333
		; Total L1 : 1333 x 5 + 1332 = 7997
		; Toal DELAY : 7997 + 2 + 1 = 8000
RET

