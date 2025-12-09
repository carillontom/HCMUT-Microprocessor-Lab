;
; lab1.2_2b2.asm
;
; Created: 9/22/2025 12:01:18 PM
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
LDI R16, 0x00

start:
SBI PORTA, 0
CALL DELAY_100ms
CBI PORTA, 0
CALL DELAY_100ms
RJMP start

DELAY_100ms: ;800000 MCs

LDI R20, 3; 1

L0: LDI R17, 200 ; 1

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
NOP
NOP ; 11

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
		; 1 + 1319 + 1 + 2 + 11 = 1334
		; Total L1 : 1334 x 199 + 1333 = 266799 MCs

DEC R20 ; 1
BRNE L0 ; 2 (1 last)
		; L0 : 1 + 266799 + 1 + 2 = 266803 MCs
		; Total L0 : 266803 x 2 + 266802 = 800408 MCs
RET 

