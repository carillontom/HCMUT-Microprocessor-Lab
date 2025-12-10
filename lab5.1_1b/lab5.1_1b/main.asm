;
; lab5.1_1b.asm
;
; Created: 10-Nov-25 9:29:44 PM
; Author : Vinh
;

.include "m324padef.inc"  
	.org 0x00
	rjmp  reset
	.org 0x50

reset:
    ldi r16, high(RAMEND)
    out SPH, r16
    ldi r16, low(RAMEND)
    out SPL, r16

configuration:
	cbi ddra, 0 ;adc0  as input
	cbi porta, 0

	call USART_Init
	call ADC_Init

	start: 
	call read_adc_16bit		;read ADC and store H-L byte to r17-r16
	call Send_char
	call Timer_delay1s
	rjmp start 

;--------sending chars-----------
Send_char:
	push r16
	push r16
	push r17

	ldi r16, 0x55
	call USART_SendChar 

	mov r16, r17
	call USART_SendChar 

	pop r17 
	pop r16
	call USART_SendChar 

	ldi r16, 0xFF
	call USART_SendChar 
	pop r16
	ret


;-----------------init ADC---------------------
;init the ADC with reference voltage to AVCC,  select ADC channel 0 
;set ADC clock to 125Khz with 8Mhz CPU clock
ADC_Init: 
	ldi r16, (1<<REFS0)  ; set reference voltage to AVCC, ADC channel 0   
	sts ADMUX, r16  ; store the value in ADMUX register 
	ldi  r16, (1<<ADEN) | (1<<ADPS2) | (1<<ADPS1) | (1<<ADPS0) ; prescaler = 128
	sts  ADCSRA, r16 ; write to ADCSRA register 
	nop 
	ret         
  
;start a single conversion  
;read ADC and store H-L byte to r17-r16                
read_adc_16bit: 
	push r18 
	lds r18, ADCSRA 
	ori r18, (1<<ADSC) 
	sts ADCSRA, r18 

 read_adc_16bit_wait: 
	 lds  r18,ADCSRA 
	 andi r18, (1<<ADSC) 
	 cpi  r18, (1<<ADSC) 
	 breq read_adc_16bit_wait	;if ADSC of ADCSRA = 1 means the system still busy -> wait
	 lds   r16, ADCL             ; read ADCL first 
	 lds   r17, ADCH             ; read ADCH second 
 
	  pop r18 
	  ret 


;-----------------init UART 0---------------------
;CPU clock is 8Mhz 
USART_Init: 
	ldi r16, 103
	sts UBRR0L, r16 
    ldi r16, (1 << U2X0) 
    sts UCSR0A, r16 
    ; Set frame format: 8 data bits, no parity, 1 stop bit 
    ldi r16, (1 << UCSZ01) | (1 << UCSZ00) 
    sts UCSR0C, r16 
    ; Enable transmitter and receiver 
    ldi r16, (1 << RXEN0) | (1 << TXEN0) 
    sts UCSR0B, r16 
	clr r16
    ret 

;send out 1 byte in r16 
USART_SendChar: 
 push r17 
    ; Wait for the transmitter to be ready 
    USART_SendChar_Wait: 
  lds r17, UCSR0A 
        sbrs r17, UDRE0 ;check USART Data Register Empty bit 
        rjmp USART_SendChar_Wait 
       sts UDR0, r16  ;send out 
 pop r17 
    ret 

;----------------Delay 1s by timer---------------------
Timer_delay32ms:
	push r17
//timer 0 NOR
    ldi r17, 0x00
    out TCCR0A, r17
//timer 0 nor stop
    ldi r17, 0x00
    out TCCR0B, r17
    ldi r17, 0          ; preload = 0 ? count full 0..255
    out TCNT0, r17
    ldi r17, 0x00
    out TCCR0A, r17
    ldi r17, (1<<CS02) | (1<<CS00)   ; prescaler = 1024 (max)
    out TCCR0B, r17
wait:
    SBIS TIFR0, TOV0
    RJMP wait
    SBI TIFR0, TOV0
    LDI R17, 0x00
    OUT TCCR0B, R17
	pop r17
    RET

Timer_delay1s:
    push r18              ; preserve caller’s r18
    ldi  r18, 31          ; 31 × 32.768 ms ? 1.016 s
Delay_1s_loop:
    rcall Timer_delay32ms ; call your 32 ms timer
    dec  r18
    brne Delay_1s_loop
    pop  r18              ; restore
    ret