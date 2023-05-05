#ifndef LAB5
#define LAB5

#include <90s2313.h> 
#include <stdint.h>
#include <delay.h>
#include <stdio.h>


////////////////////////////////////////////////////////////Variant
//PORTD = 0x12
// PD2 = 2 

#asm
 .equ __w1_port = 0x12
 .equ __w1_bit = 2 
 .equ __w1_dir = 0x11       
 .equ __w1_inp = 0x10
#endasm

#include <1wire.h>



///////////////////////////////////////////////////////////Variant
// PB7
#define LED_PORT PORTB
#define LED_DDR DDRB
#define LED 7
enum {LED_OFF = 1, LED_ON = 0};



///////////////////////////////////////////////////////////Variant
// key count = 5
#define MAX_IBUTTON 5

// size of key = 8
#define IBUTTON_ID_SIZE 8


// command code iButton DS1990
#define SEARCH_ROM 0xF0



///////////////////////////////////////////////////////////Variant
// door open = 7 sec
#define T_OPEN_SEC (7) 
#define T_OPEN_MS (T_OPEN_SEC * 1000)



// timer cofigs
///////////////////////////////////////////////////////////Variant
#define T1_PIRIOD 0,45 //450-ms
#define T1_COMP_DIV 64
#define T1_COMP_OCR ((_MCU_CLOCK_FREQUENCY_/(T1_PIRIOD * T1_COMP_DIV)) - 1)




// terminal configs
///////////////////////////////////////////////////////////Variant
// UART = 57600 
#define UART_BR 57600
#define UART_UBRR_VAL ((_MCU_CLOCK_FREQUENCY_/(UART_BR * 16)) - 1)



// terminal messages
flash char str2[] = "iButton found!\n\r";
flash char str3[] = "iButton not found!\n\r";
flash char str4[] = "iButton valid!\n\r";
flash char str5[] = "iButton not valid!\n\r\n\r";


void Pin_Init(void);
void Timer_Init(void);
void UART_Init(void);
void System_Init(void);
void Run(void);
#endif
