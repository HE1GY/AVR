.nolist  ;to disable listing
.include "2313def.inc"
.list 

.def result_h = r16 
.def result_l = r17 
.def temp1 = r18 
.def temp2 = r19 

.def Delay1 = r21
.def Delay2 = r22
.def Delay3 = r23

.equ #CS = PB2
.equ SCLK = PB5
.equ DOUT = PB3
.equ #SHDN = PB4
.equ PORT_ADC = PORTB
.equ DDR_ADC = DDRB
.equ PIN_ADC = PINB

.equ LED = PB0
.equ PORT_LED = PORTB
.equ DDR_LED = DDRB
.equ PIN_LED = PINB

.equ F_T = 9000000 ;Hz
.equ T_ADC =0.08 ;s check period
.equ DIV = 64   

.equ LED_delay=5
.equ PIRsensor_delay=14;


;V_noise=190 mkV
;K_u=1924
;V_offset =2.5V
;V_triger = 190*1924 = 365.560m?V=0.36556V
;V_tr-  =  2.5-0.36556=2.13444
;V_tr+  =  2.5+0.36556=2.86556

;ADC code
.equ VTR_P = 2347 ;  (2.86556 * 4096)/5  ; high
.equ VTR_N = 1748 ;  (2.13444 * 4096)/5  ; low

; comparison mode 
.equ Polling_ticks = (F_T * T_ADC/DIV)-1 ; period of polling

.equ LED_delay_ticks = (F_T*LED_delay - 15)/5 
.equ PIRsensor_delay_ticks = (F_T*PIRsensor_delay - 15)/5 
.equ ADC_delay_ticks = (F_T*0.000011 - 15)/5 ; wait 11 us



.MACRO BIT_READ
	sbi PORT_ADC, SCLK 
	nop 
	cbi PORT_ADC, SCLK 
	nop 
	in temp1, PIN_ADC 
	sbrc temp1, DOUT ;sbrc -skip if bit in reg is clear
	ori @0, @1 
.ENDMACRO



.MACRO WAIT 
	ldi Delay1, low(@0)
	ldi Delay2, high(@0)
	ldi Delay3, byte3(@0)

Waiting:
	subi Delay1, 1 
	sbci Delay2, 0
	sbci Delay3, 0
	brcc Waiting 
	nop  
.ENDMACRO


.listmac ; to list macro in output file

.cseg
.org 0
	rjmp RESET 
.org 0x04
	rjmp TIM_COMP1 

.org 0x0B
RESET: 
	ldi temp1, low(RAMEND)
	out SPL, temp1

	ldi temp1, (1<<#CS) | (0<<SCLK)
	out PORT_ADC, temp1 ;to set DOUT to high-impedance  

	in temp1 , DDR_ADC
	ori temp1, (1<<#CS) | (1<<SCLK) | (1<<#SHDN);#CS, SCLK, #SHDN - outputs; DOUT - input
	out DDR_ADC, temp1

	in temp1 , DDR_LED 
	ori temp1 , (1<<LED)
	out DDR_LED, temp1

	in temp1 , PORT_LED
	ori temp1 , (1<<LED)
	out PORT_LED, temp1 ;turn off

	WAIT PIRsensor_delay_ticks

	ldi temp1, (1<<SE) | (0<<SM)  ;SE=1 Sleep Enable; SM=0 idle
	out MCUCR, temp1

	ldi temp1, high(Polling_ticks) ; OCR1A -reg of comparison
	out OCR1AH, temp1 
	ldi temp1, low(Polling_ticks)
	out OCR1AL, temp1 


	ldi temp1, (1<<OCIE1A) ;OCIE1A -interruption if(OCR1A==TCNT1)
	out TIMSK, temp1

	ldi temp1, (1<<CTC1) | (0<<CS12) | (1<<CS11) | (1<<CS10) ;CTC1=1 -- TCNT1 to 0x0000 if(TCNT1>OCR1A); CS12 CS11 CS10 = 0 1 1 -- DIV64;
	out TCCR1B, temp1
	
	sei ;  set enable interruption

Wait_Loop:
	sleep 
	rjmp Wait_Loop 

	
TIM_COMP1:
	rcall ADC_CONV

	ldi temp1, low(VTR_P)
	ldi temp2, high(VTR_P)
	
	sub temp1, result_l
	sbc temp2, result_h ;sub with carry
	brlo Alarm ;if (result > VTR_P)  brlo -branch if lower
	
	ldi temp1, low(VTR_N)
	ldi temp2, high(VTR_N)
	
	sub temp1, result_l
	sbc temp2, result_h
	brsh Alarm ;if (result <= VTR_N) brsh -branch if same or higher
	
	sbi PORT_LED, LED ; off   
	rjmp End 

Alarm:
	clr temp1 ; temp1 = 0
	out TCCR1B, temp1 ; stop timer

	cbi PORT_LED, LED 
	WAIT LED_delay_ticks
	sbi PORT_LED, LED 

	ldi temp1, (1<<CTC1) | (0<<CS12) | (1<<CS11) | (1<<CS10)
	out TCCR1B, temp1
End:
	reti 


ADC_CONV: 
	sbi PORT_ADC, #SHDN ;turn on
	
	WAIT ADC_delay_ticks
	
	clr result_h
	clr result_l
	
	cbi PORT_ADC, #CS ;start transformation
	nop 

EOC: 
	sbis PIN_ADC, DOUT ; wait DOUT =1
	rjmp EOC 

	;read 4 hight bits
	BIT_READ result_h, 0b00001000 ; D11
	BIT_READ result_h, 0b00000100 ; D10
	BIT_READ result_h, 0b00000010 ; D9
	BIT_READ result_h, 0b00000001 ; D8

	;read 8 low bits
	BIT_READ result_l, 0b10000000 ; D7
	BIT_READ result_l, 0b01000000 ; D6
	BIT_READ result_l, 0b00100000 ; D5
	BIT_READ result_l, 0b00010000 ; D4
	BIT_READ result_l, 0b00001000 ; D3
	BIT_READ result_l, 0b00000100 ; D2
	BIT_READ result_l, 0b00000010 ; D1
	BIT_READ result_l, 0b00000001 ; D0
	
	cbi PORT_ADC, SCLK
	sbi PORT_ADC, #CS ;stop transformation
	
	cbi PORT_ADC, #SHDN ;turn off
	ret 
