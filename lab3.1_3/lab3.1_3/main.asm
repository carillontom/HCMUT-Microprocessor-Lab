;
; lab3.1_3.asm
;
; Created: 10/4/2025 1:54:39 PM
; Author : huysk
;


.equ led7seg_ddr = ddra
.equ led7seg_port = porta
.equ ledsel_ddr = ddrd
.equ ledsel_port = portd
.equ le0 = 4
.equ le1 = 5
//select 0 o pc4 va 1 o pc5, sel 1 dung de latch
//r16 dung de tro toi digit position, r17 dung de tro toi so duoc hien thi
.org 0
	rjmp main
.org 40
main:
//Cau hinh A la xuat data, C la xuat latch
	ldi r16, 0xff
	out led7seg_ddr, r16
	ldi r16, (1<<le0)|(1<<le1)
	out ledsel_ddr, r16
	//cau hinh timer 1 ctc mode clock div 1024 o pb3
//timer1
	ldi r16, 0x00
	sts tccr1A, r16
	ldi r16, (1<<WGM12|1<<CS12|1<<CS10)
	sts tccr1B, r16
	ldi r16, high(156/4)
	sts ocr1aH, r16
	ldi r16, low(156/4)
	sts ocr1aL, r16 
loop:
	ldi r16, 0
	ldi r17, 3
	rcall display_7seg
	rcall delay_ms
	ldi r16, 1
	ldi r17, 2
	rcall display_7seg
	rcall delay_ms
	ldi r16, 2
	ldi r17, 1
	rcall display_7seg
	rcall delay_ms
	ldi r16, 3
	ldi r17, 0
	rcall display_7seg
	rcall delay_ms
	rjmp loop
display_7seg:
	//tat het all led tranh bi ghosting
	ldi r18, 0xff
	out led7seg_port, r18
	rcall sel_sig
	rcall data_led_load
	rcall data_sig
	rcall sel_led_load
	rcall sel_sig
	ret
sel_sig:
	sbi ledsel_port, le1
	cbi ledsel_port, le1
	ret
data_sig:
	sbi ledsel_port, le0
	cbi ledsel_port, le0
	ret
delay_ms:
	SBIS TIFR1,OCF1A 
	RJMP delay_ms 
	SBI TIFR1,OCF1A 
	RET
data_led_load:	//tai du lieu cua led
	ldi zh, high(data_led7<<1)
	ldi zl, low(data_led7<<1)
	clr r18
	add r30, r17
	adc r31, r18
	lpm r18, z
	out led7seg_port, r18
	nop
	ret 
sel_led_load:	//tai du lieu cua vi tri led
	ldi zh, high(select_led7<<1)
	ldi zl, low(select_led7<<1)
	clr r18
	add r30, r16
	adc r31, r18
	lpm r18, z
	out led7seg_port, r18
	nop
	ret 
data_led7: .DB 0xC0, 0xF9, 0xA4, 0xB0, 0x99, 0x92, 0x82, 0xF8, 0x80, 0x90, 0x88, 0x83, 0xC6, 0xA1, 0x86, 0x8E, 0, 0
select_led7: .DB 0b00001110, 0b00001101, 0b00001011, 0b00000111

