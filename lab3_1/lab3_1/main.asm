.org 0x0000
    rjmp reset

; =========================
; 1 ms delay using Timer0 (Normal mode, prescaler /64)
; - Assumes F_CPU = 8 MHz
; - Preload TCNT0 = 256 - 125 = 131 (0x83)
; =========================
Delay1ms:
    ; Stop Timer0 to safely preload
    ldi  r16, 0x00
    out  TCCR0B, r16

    ; Normal mode
    out  TCCR0A, r16          ; WGM0x = 0

    ; Preload for 1 ms
    ldi  r16, 131             ; 0x83
    out  TCNT0, r16

    ; Clear overflow flag (write 1 to clear)
    ldi  r16, (1<<TOV0)
    out  TIFR0, r16

    ; Start Timer0 with prescaler /64  (CS02:0 = 0b011)
    ldi  r16, (1<<CS01) | (1<<CS00)
    out  TCCR0B, r16

wait_ovf:
    in   r17, TIFR0
    sbrs r17, TOV0            ; wait until TOV0 = 1
    rjmp wait_ovf

    ; Stop timer (optional—keeps timing exact each call)
    ldi  r16, 0x00
    out  TCCR0B, r16

    ; Clear flag for next use
    ldi  r16, (1<<TOV0)
    out  TIFR0, r16
    ret

; =========================
; Toggle PA0 every 1 ms -> 500 Hz square (period 2 ms)
; =========================
reset:
    ; I/O init
    ldi  r16, 1<<PA0
    out  DDRA, r16            ; PA0 output

main:
    sbi  PORTA, PA0           ; PA0 = 1
    rcall Delay1ms

    cbi  PORTA, PA0           ; PA0 = 0
    rcall Delay1ms

    rjmp main
