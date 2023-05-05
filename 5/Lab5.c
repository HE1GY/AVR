#include "Lab5.h"

uint8_t ROM_ID[IBUTTON_ID_SIZE + 1];

///////////////////////////////////////////////////////////Variant
// 5 keys
flash uint8_t IButton_ID[MAX_IBUTTON][IBUTTON_ID_SIZE] =
{
    {0x01, 0x2A, 0xC5, 0xE8, 0x00, 0x00, 0x00, 0xE1},
    {0x01, 0xC5, 0xAC, 0xCF, 0x0F, 0x00, 0x00, 0xA7},
    {0x01, 0x90, 0x2C, 0x3D, 0x00, 0x00, 0x00, 0x80},
    {0x01, 0x67, 0xCD, 0x45, 0x00, 0x00, 0x00, 0xD4},
    {0x01, 0x2B, 0xF0, 0x12, 0x00, 0x00, 0x00, 0xEA}, // valid
};

interrupt [TIM1_COMP] void T1_Compare_ISR (void)
{
     uint8_t devices, i, j, id_valid;
    devices = w1_search(SEARCH_ROM, &ROM_ID[0]);
     if (devices == 0) 
     {
         putsf(str3);
     }
     else 
     {
         putsf(str2);
     
         printf("ID IButton: "); 
         for (i = 0; i < IBUTTON_ID_SIZE; i++) {
            printf("0x%02X ", ROM_ID[IBUTTON_ID_SIZE - i - 1]);
         };
         
         putchar('\r');
         
         for (i = 0; i < MAX_IBUTTON; i++) {
            id_valid = 1;
            for (j = 0; j < IBUTTON_ID_SIZE; j++) {
                if (IButton_ID[i][j] != ROM_ID[j]) {
                id_valid = 0;
                break;
                }
             };
         
            if (id_valid == 1) {
             putsf(str4);
         
             LED_PORT.LED = LED_ON;
             delay_ms(T_OPEN_MS);
             LED_PORT.LED = LED_OFF;
             break;
             }
         }
         
         if (id_valid == 0) {
         putsf(str5);
         }
     }
};

void main( void )
{
     System_Init();
     Run();
}

void Pin_Init( void )
{
     LED_PORT.LED = LED_OFF;
     LED_DDR.LED = 1;
}

void Timer_Init( void )
{
     OCR1 = T1_COMP_OCR;
     TIMSK = (1 << OCIE1A);
     TCCR1B = (1 << CS10) | (1 << CS11) | (1 << CTC1);
}

void UART_Init( void )
{
     UBRR = UART_UBRR_VAL;
     UCR = (1 << TXEN) | (1 << RXEN);
}
void System_Init( void )
{
     Pin_Init();
     Timer_Init();
     UART_Init();
     #asm( "sei" );
}
void Run( void )
{
     while(1) 
     {   
     }
}
