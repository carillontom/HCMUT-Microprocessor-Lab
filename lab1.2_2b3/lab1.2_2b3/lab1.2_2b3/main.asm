;
; lab1.2_2b3.asm
;
; Created: 9/22/2025 12:40:51 PM
; Author : huysk
;

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
CALL DELAY_1s
CBI PORTA, 0
CALL DELAY_1s
RJMP start

DELAY_1s: ;8000000 MCs

LDI R17, 132 ; 1

L1: LDI R18, 200 ; 1

L2: LDI R19, 100 ; 1

L3: 
DEC R19 ; 1
BRNE L3 ; 2 (1 last)
		; Total L3 : L3 = 3 x 99 + 2 = 299

DEC R18 ; 1
BRNE L2 ; 2 (1 last)
		; 1+299+1+2 = 303
		; Total L2 : 303 x 199 + 302 = 60599

DEC R17 ; 1
BRNE L1 ; 2 (1 last)
		; 1 + 60599 + 1 + 2  = 60603
		; Total L1 : 60603 x 131 + 60602 = 7999595
		; Toal DELAY : 7999595 + 1 = 7999596 MCs ~ 1s
RET


