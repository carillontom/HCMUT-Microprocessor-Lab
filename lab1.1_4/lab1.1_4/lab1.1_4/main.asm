;
; lab1.1_4.asm
;
; Created: 9/18/2025 4:16:45 PM
; Author : huysk
;
;nhan co dau

; Replace with your application code
.org 0x00

LDI R16, 0x00
OUT DDRA, R16
OUT PORTB, R16

LDI R16, 0xFF
OUT DDRB, R16
OUT PORTA, R16

MAIN:
IN R16, PINA
COM R16 ;R16 mang gia tri input

LDI R17, 0xF0
LDI R18, 0x0F

AND R17, R16 ;R17 mang 4 bit dau
AND R18, R16 ;R18 mang 4 bit cuoi

LDI R19, 4
LOOP:
TST R19
BREQ DONE
DEC R19
ASR R17 ; xxxx0000 -> ----xxxx
RJMP LOOP

DONE:
MULS R17, R18
MOV R20, R0 ; nhan xong mac dinh luu vao R0
OUT PORTB, R20

RJMP MAIN



