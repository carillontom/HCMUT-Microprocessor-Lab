;
; lab1.2_1.asm
;
; Created: 9/21/2025 3:22:42 PM
; Author : huysk
;

.include "m324PAdef.inc"
.org	00
	ldi r16,0x01
	out	DDRA, r16
start:
       sbi	PORTA,PINA0
       cbi	PORTA, PINA0
       rjmp start
