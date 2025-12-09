;
; lab1.2_3.asm
;
; Created: 9/24/2025 2:35:46 PM
; Author : huysk
;


.ORG 0x00
RJMP main
.ORG 0x50

main:
LDI r16, 0xff
OUT ddra, r16

LDI r16, 0x08
starting_phase:
LDI r17, 0xff
ROL r17; dua MSB cua r17 len carry C
BRCC led_off ; C = 0 thi DS = 0
SBI PORTA, 0
RCALL DELAY_500ms

led_on:

SBI PORTA, 1; dua data o DS vao register
CBI PORTA, 1; tat clock
SBI PORTA, 2; bat latch de dua ra output
CBI PORTA, 2; tat latch

DEC R16
BREQ fading_phase_configure ;xong starting phase
RJMP starting_phase

led_off:
CBI PORTA, 0
RCALL DELAY_500ms

SBI PORTA, 1; dua data o DS vao register
CBI PORTA, 1; tat clock
SBI PORTA, 2; bat latch de dua ra output
CBI PORTA, 2; tat latch

DEC R16
BREQ fading_phase_configure; xong starting phase
RJMP starting_phase

fading_phase_configure:
LDI R16, 0x08
fading_phase:
LDI R18, 0x00
ROL R18; dua MSB cua r18 len carry C
BRCC clear_ds
SBI PORTA, 0

RCALL DELAY_500ms
SBI PORTA, 1; dua data o DS vao register
CBI PORTA, 1; tat clock
SBI PORTA, 2; bat latch de dua ra output
CBI PORTA, 2; tat latch

DEC R16
BREQ done
RJMP fading_phase

clear_ds:
CBI PORTA, 0
RCALL DELAY_500ms

SBI PORTA, 1; dua data o DS vao register
CBI PORTA, 1; tat clock
SBI PORTA, 2; bat latch de dua ra output
CBI PORTA, 2; tat latch

DEC R16
BREQ done
RJMP fading_phase

done:
LDI r16, 0x08
RJMP starting_phase

DELAY_500ms: ;4000000 MCs

LDI R27, 66 ; 1

L1: LDI R28, 200 ; 1

L2: LDI R29, 100 ; 1

L3: 
DEC R29 ; 1
BRNE L3 ; 2 (1 last)
		; Total L3 : L3 = 3 x 99 + 2 = 299

DEC R28 ; 1
BRNE L2 ; 2 (1 last)
		; 1+299+1+2 = 303
		; Total L2 : 303 x 199 + 302 = 60599

DEC R27 ; 1
BRNE L1 ; 2 (1 last)
		; 1 + 60599 + 1 + 2  = 60603
		; Total L1 : 60603 x 65 + 60602 = 3999797
		; Toal DELAY : 3999797 + 1 = 3999798 MCs ~ 500ms
RET

