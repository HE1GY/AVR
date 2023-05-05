#include <tiny2313.h>
#include <delay.h>


#define SHLEIF_NO_DDR DDRD
#define SHLEIF_NO_PORT PORTD
#define SHLEIF_NO_PIN PIND
#define SHLEIF_NO_1 2
#define SHLEIF_NO_2 3

#define SHLEIF_NC_DDR DDRB
#define SHLEIF_NC_PORT PORTB
#define SHLEIF_NC_PIN PINB 
#define SHLEIF_NC_1 2
#define SHLEIF_NC_2 3

#define LED_DDR DDRB
#define LED_PORT PORTB
#define LED_PIN PINDB
#define LED 5

#define SWITCH_DDR DDRD
#define SWITCH_PORT PORTD
#define SWITCH_PIN PIND
#define SWITCH 0



 
void PinInit();

void main(void)
{
    const unsigned long int k_Hz =8000000;
    const unsigned int k_delay=3900;  //ms  
    const unsigned long int k_blip_delay=((k_Hz/11)/k_Hz)*1000000;   //us 
    bit led_state;
    
    PinInit(); 

    
    LED_PORT.LED=1;
    
No_Work:
      if(SWITCH_PIN.SWITCH==1)
      {
        goto No_Work; 
      }
         

      //Time_to_escape
      delay_ms(k_delay);
      LED_PORT.LED=0;
Check:
      if(SHLEIF_NO_PIN.SHLEIF_NO_1==0 || SHLEIF_NO_PIN.SHLEIF_NO_2==0 || SHLEIF_NC_PIN.SHLEIF_NC_1==1 || SHLEIF_NC_PIN.SHLEIF_NC_2==1)
      {      
        goto Work; 
      }
        
      if(SWITCH_PIN.SWITCH==0)
      {
        goto Check; 
      } 
      
      LED_PORT.LED=1;
      goto No_Work;    
       
Work:
     //Time_to_turn off
      delay_ms(k_delay); 
      
     if(SWITCH_PIN.SWITCH==0)
     {
        goto Alarm; 
     }
       
     LED_PORT.LED=1;   
     goto No_Work; 

Alarm:
    led_state = LED_PORT.LED;
    led_state^=1;
    LED_PORT.LED=led_state;
    delay_us(k_blip_delay);
    goto Alarm;                
}

void PinInit()
{
    unsigned char port_switch =SWITCH_PORT;
    unsigned char ddr_led = LED_DDR;
    
    ddr_led|=(1<<LED);
    LED_DDR= ddr_led; 
    
    port_switch|=(1<<SWITCH);
    SWITCH_PORT=port_switch;
}





