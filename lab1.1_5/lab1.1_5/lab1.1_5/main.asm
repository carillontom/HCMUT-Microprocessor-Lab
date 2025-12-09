;
; lab1.1_5.asm
;
; Created: 9/20/2025 5:07:39 PM
; Author : huysk
;


.org 0x00
rjmp main
.org 0x50
main:
CBI DDRA, 0; PA0 in
SBI PORTA, 0; pull-up on PA0

SBI DDRA, 1; PA1 out

RJMP released

released_check:
SBIC PINA, 0; pressed
RJMP released; released
RJMP released_check

released:
CBI PORTA, 1
SBIS PINA, 0; not pressed yet
RJMP led_on; pressed again
RJMP released

led_on:
SBI PORTA, 1; PA1 = 1 led on
RJMP released_check


