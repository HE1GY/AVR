.include "2313def.inc"

.def temp = r16 
.def EE_Addr_Reg = r17 
.def EE_Data_Reg = r18 


.equ Analog_Addr = 0x34 ; 52
.equ Digital_Addr = 0x45 ; 69

.equ Analog_PIN_1 = PB0
.equ Analog_PIN_2 = PB1
.equ Analog_PORT = PORTB
.equ Analog_DDR = DDRB


.equ Digital_PIN = PD3
.equ Digital_PORT = PORTD
.equ Digital_DDR = DDRD


.equ LED_DDR = DDRB
.equ LED_PORT = PORTB
.equ LED_PIN = PB5



.cseg 
.org 0 

	rjmp RESET ; Вектор скиду
	reti ;Зовнішнє переривання INT0
	rjmp INT1_EXT
	reti;Захват таймера/лічильника 1
	reti;Співпадіння таймера/лічильника 1
	reti;Переповнення таймера/лічильника 1
	reti;Переповнення таймера/лічильника 0
	reti;Прийом з послідовного порта завершений
	reti;Регістр даних послідовного порта пустий
	reti;Передача з послідовного порта завершена
	rjmp ANA_COMP 


.org 0x0B ; Початок основної програми

RESET:
	; Ініціалізація стеку
	ldi temp, low(0xDF)
	out SPL, temp
	 
	rcall Config_Analog

	rcall Config_Digital

	rcall Config_LED

Loop:
	sleep ; Перехід в режим пониженого енергоспоживання
	rjmp Loop ; Після спрацювання давача знову перейти в режим пониженого енергоспоживання
	


INT1_EXT: 
	cbi LED_PORT, LED_PIN ;on

	ldi EE_Addr_Reg, Digital_Addr 
	rcall EEPROM_Read 
	inc EE_Data_Reg ; ++
	rcall EEPROM_Write 
	reti  ;return from interaption

ANA_COMP: 
	cbi LED_PORT, LED_PIN ;on

	ldi EE_Addr_Reg, Analog_Addr 
	rcall EEPROM_Read 
	inc EE_Data_Reg ; ++
	rcall EEPROM_Write 
	reti 

EEPROM_Write: 
	sbic EECR, EEWE ; (Skip if Bit in EECR is Cleared) 
	rjmp EEPROM_Write
	out EEAR, EE_Addr_Reg ; Address Register
	out EEDR, EE_Data_Reg ; Data Register
	sbi EECR, EEMWE ; Встановити мастер-біт дозволу запису
	sbi EECR, EEWE ; Встановити біт дозволу запису (непізніше 4 такти після EEMWE)
	ret 

EEPROM_Read: 
	sbic EECR, EEWE 
	rjmp EEPROM_Read
	out EEAR, EE_Addr_Reg 
	sbi EECR, EERE ; Встановити прапорець дозволу читання
	in EE_Data_Reg, EEDR ; Прочитати дані
	ret 


Config_Analog:
	cbi Analog_DDR, Analog_PIN_1 ;вхід
	cbi Analog_DDR, Analog_PIN_2 
	cbi Analog_PORT, Analog_PIN_1 ;внутрішній резистор off
	cbi Analog_PORT, Analog_PIN_2 

	ldi temp, (0<<ACD) | (1<<ACIE) | (1<<ACIS1) | (1<<ACIS0) ;ACD - включення(за замовчуванням)
	out ACSR, temp 											 ; ACIE-дозвіл переривання,ACIS1:ACIS0-умова переривання(0->1) 
	ret


Config_Digital:
	cbi Digital_DDR, Digital_PIN ;вхід
	cbi Digital_PORT, Digital_PIN ;внутрішній резистор off

	ldi temp, (1<<ISC11) | (0<<ISC10) | (1<<SE) | (0<<SM) ;ISC11, ISC10 (PD3/INT1)-умова переривання  (1->0)
	out MCUCR, temp								; SE - Sleep Enable   SM-sleep mode (1 – Power Down   0 – Idle)
	
	ldi temp, (1<<INT1);дозвіл переривання
	out GIMSK, temp
	sei ;Set Global Interrupt Enable
	ret

Config_LED:
	sbi LED_DDR, LED_PIN   ;вихід
	sbi LED_PORT, LED_PIN  ;off
	ret

