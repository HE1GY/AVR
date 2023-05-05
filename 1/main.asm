.include <tn2313def.inc> 


.def temp = r16

.def Delay1 = r17
.def Delay2 = r18
.def Delay3 = r19

.equ SHLEIF_NO_1 = PD2
.equ SHLEIF_NO_2 = PD3 
.equ SHLEIF_NC_1 = PB2
.equ SHLEIF_NC_2 = PB3
.equ LED = PB5
.equ SWITCH = PD0 


.equ FCLK = 8000000               ;8MHz
.equ N_Alarm = (FCLK*3.9 - 15)/5  ;3.9c
.equ N_Blick = (FCLK/11 - 15)/5   ;11Hz


.cseg  ;сегмент коду
.org 0 ;початкова адреса

		ldi temp, 0xDF  ;ініціалізація стеку
		out SPL, temp   

		rcall Pin_Init 

		sbi PORTB, LED 

No_Work: 
		in temp, PIND			
		andi temp, (1<<SWITCH)  ;(1 -pressed ; 0 -not)
		brne No_Work ;          

Time_to_escape:
		ldi Delay1, low(N_Alarm)    ;low byte
		ldi Delay2, high(N_Alarm)   ;high byte
		ldi Delay3, byte3(N_Alarm)  ;4th byte 
		rcall Delay 

		cbi PORTB, LED ; Включити світлодіод сигналізації 

Check:		
		in temp, PINB          
		andi temp, (1<<SHLEIF_NC_1) 
		brne Work 

		in temp, PINB          
		andi temp, (1<<SHLEIF_NC_2) 
		brne Work

		in temp, PIND
		andi temp, (1<< SHLEIF_NO_1) 
		breq Work 

		in temp, PIND
		andi temp, (1<< SHLEIF_NO_2) 
		breq Work 
		
		in temp, PIND 
		andi temp, (1<<SWITCH) 
		breq Check 

		sbi PORTB, LED 
		rjmp No_Work 


Work:
		ldi Delay1, low(N_Alarm)  ;час для вимкнення 
		ldi Delay2, high(N_Alarm)
		ldi Delay3, byte3(N_Alarm)
		rcall Delay
		
		in temp, PIND 
		andi temp, (1<<SWITCH) 
		breq Alarm 
		
		sbi PORTB, LED 
		rjmp No_Work 
		

Alarm:
		in temp, PORTB 
		ldi Delay1, (1<<LED)
		eor temp, Delay1 ; Інвертувати стан світлодіоду ;eor=xor
		out PORTB, temp 

		ldi Delay1, low(N_Blick) 
		ldi Delay2, high(N_Blick)
		ldi Delay3, byte3(N_Blick)
		rcall Delay

		rjmp Alarm 



Delay:
		subi Delay1, 1   ;віднімання з преносом
		sbci Delay2, 0
		sbci Delay3, 0
		brcc Delay       ;branch if carry flag is clear
		nop              ;no operation take one clock cycle ??
		ret
		
		
		
Pin_Init:

		cbi PORTD , SHLEIF_NO_1
		cbi PORTD , SHLEIF_NO_2
		cbi PORTB , SHLEIF_NC_1
		cbi PORTB , SHLEIF_NC_2
		cbi PORTB , LED
		sbi PORTD , SWITCH
		
		;тип піна (0-read; 1 -write)
		cbi DDRD , SHLEIF_NO_1
		cbi DDRD , SHLEIF_NO_2
		cbi DDRB , SHLEIF_NC_1
		cbi DDRB , SHLEIF_NC_2
		sbi DDRB , LED
		cbi DDRD , SWITCH
		
		ret 
