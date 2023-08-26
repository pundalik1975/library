/*******************************************************
This program was created by the
CodeWizardAVR V3.12 Advanced
Automatic Program Generator
© Copyright 1998-2014 Pavel Haiduc, HP InfoTech s.r.l.
http://www.hpinfotech.com

Project : mbscan
Version : 1.0
Date    : 10/1/2019
Author  : pundalik
Company : bhoomi controls
Comments: 
this is compatible with mbscan1/2/3/4 
hardware


Chip type               : ATmega32A
Program type            : Application
AVR Core Clock frequency: 11.059200 MHz
Memory model            : Small
External RAM size       : 0
Data Stack size         : 512
*******************************************************/

#include <mega32a.h>

// I2C Bus functions
#include <i2c.h>

// Declare your global variables here

#define DATA_REGISTER_EMPTY (1<<UDRE)
#define RX_COMPLETE (1<<RXC)
#define FRAMING_ERROR (1<<FE)
#define PARITY_ERROR (1<<UPE)
#define DATA_OVERRUN (1<<DOR)



#define digit1() PORTC.0 = 1
#define digit2() PORTC.7 = 1
#define digit3() PORTC.6 = 1
#define digit4() PORTC.5 = 1
#define digit5() PORTC.1 = 1
#define digit6() PORTC.2 = 1
#define digit7() PORTC.3 = 1
#define digit8() PORTC.4 = 1
#define digit9() PORTB.6 = 1        //led red common
#define digit10() PORTB.7 = 1       //led green common

#define mb_dir  PORTD.2

#define relay1 PORTD.6
#define relay2 PORTD.7

#define set_key PINB.2
#define inc_key PINB.3
#define dec_key PINB.4
#define shf_key PINB.5

#define mux9 PORTD.3
#define mux10 PORTD.4
#define mux11 PORTD.5

void clear_display(void)
{
PORTA =0xff;    //segment off
PORTC = 0x00;  //digit drive off
PORTB.6 = 0;   //led common off
PORTB.7 =0;
 

}

unsigned short int led_status,led_status1;
unsigned short int display_buffer[10];
short int dummy[1] = {0};
short int dummy2[1] = {0};
int process_value[8];
short int display_count;
                                  
#define all_led_off() led_status = 0xff;             //red led status
#define rled1_on() led_status &= 0xfe
#define rled2_on() led_status &= 0xfd
#define rled3_on() led_status &= 0xfb
#define rled4_on() led_status &= 0xf7
#define rled5_on() led_status &= 0xef
#define rled6_on() led_status &= 0xdf
#define rled7_on() led_status &= 0xbf
#define rled8_on() led_status &= 0x7f
#define rled1_off() led_status |= 0x01
#define rled2_off() led_status |= 0x02
#define rled3_off() led_status |= 0x04
#define rled4_off() led_status |= 0x08
#define rled5_off() led_status |= 0x10
#define rled6_off() led_status |= 0x20
#define rled7_off() led_status |= 0x40
#define rled8_off() led_status |= 0x80

#define all_led_off1() led_status1 = 0xff;             //red led status
#define gled1_on() led_status1 &= 0xfe
#define gled2_on() led_status1 &= 0xfd
#define gled3_on() led_status1 &= 0xfb
#define gled4_on() led_status1 &= 0xf7
#define gled5_on() led_status1 &= 0xef
#define gled6_on() led_status1 &= 0xdf
#define gled7_on() led_status1 &= 0xbf
#define gled8_on() led_status1 &= 0x7f
#define gled1_off() led_status1 |= 0x01
#define gled2_off() led_status1 |= 0x02
#define gled3_off() led_status1 |= 0x04
#define gled4_off() led_status1 |= 0x08
#define gled5_off() led_status1 |= 0x10
#define gled6_off() led_status1 |= 0x20
#define gled7_off() led_status1 |= 0x40
#define gled8_off() led_status1 |= 0x80

// USART Receiver buffer
#define RX_BUFFER_SIZE 48
char rx_buffer[RX_BUFFER_SIZE];

#if RX_BUFFER_SIZE <= 256
unsigned char rx_wr_index=0,rx_rd_index=0;
#else
unsigned int rx_wr_index=0,rx_rd_index=0;
#endif

#if RX_BUFFER_SIZE < 256
unsigned char rx_counter=0;
#else
unsigned int rx_counter=0;
#endif

// This flag is set on USART Receiver buffer overflow
bit rx_buffer_overflow;

// USART Receiver interrupt service routine
interrupt [USART_RXC] void usart_rx_isr(void)
{
char status,data;
status=UCSRA;
data=UDR;
if ((status & (FRAMING_ERROR | PARITY_ERROR | DATA_OVERRUN))==0)
   {
   rx_buffer[rx_wr_index++]=data;
#if RX_BUFFER_SIZE == 256
   // special case for receiver buffer size=256
   if (++rx_counter == 0) rx_buffer_overflow=1;
#else
   if (rx_wr_index == RX_BUFFER_SIZE) rx_wr_index=0;
   if (++rx_counter == RX_BUFFER_SIZE)
      {
      rx_counter=0;
      rx_buffer_overflow=1;
      }
#endif
   }
}

#ifndef _DEBUG_TERMINAL_IO_
// Get a character from the USART Receiver buffer
#define _ALTERNATE_GETCHAR_
#pragma used+
char getchar(void)
{
char data;
while (rx_counter==0);
data=rx_buffer[rx_rd_index++];
#if RX_BUFFER_SIZE != 256
if (rx_rd_index == RX_BUFFER_SIZE) rx_rd_index=0;
#endif
#asm("cli")
--rx_counter;
#asm("sei")
return data;
}
#pragma used-
#endif

// USART Transmitter buffer
#define TX_BUFFER_SIZE 48
char tx_buffer[TX_BUFFER_SIZE];

#if TX_BUFFER_SIZE <= 256
unsigned char tx_wr_index=0,tx_rd_index=0;
#else
unsigned int tx_wr_index=0,tx_rd_index=0;
#endif

#if TX_BUFFER_SIZE < 256
unsigned char tx_counter=0;
#else
unsigned int tx_counter=0;
#endif

// USART Transmitter interrupt service routine
interrupt [USART_TXC] void usart_tx_isr(void)
{
if (tx_counter)
   {
   --tx_counter;
   UDR=tx_buffer[tx_rd_index++];
#if TX_BUFFER_SIZE != 256
   if (tx_rd_index == TX_BUFFER_SIZE) tx_rd_index=0;
#endif
   }
}

#ifndef _DEBUG_TERMINAL_IO_
// Write a character to the USART Transmitter buffer
#define _ALTERNATE_PUTCHAR_
#pragma used+
void putchar(char c)
{
while (tx_counter == TX_BUFFER_SIZE);
#asm("cli")
if (tx_counter || ((UCSRA & DATA_REGISTER_EMPTY)==0))
   {
   tx_buffer[tx_wr_index++]=c;
#if TX_BUFFER_SIZE != 256
   if (tx_wr_index == TX_BUFFER_SIZE) tx_wr_index=0;
#endif
   ++tx_counter;
   }
else
   UDR=c;
#asm("sei")
}
#pragma used-
#endif

// Standard Input/Output functions
#include <stdio.h>
#include <delay.h>


//                              0     1     2   3    4    5    6    7     8    9   10    11   12   13   14   15   16   17   18   19   20   21   22   23   24   25   26   27   28   29   30   31   32   33  34
//                              0     1     2   3    4    5    6    7     8    9    a    b    c    d    e    f    g    h    j    k    l    m    n    o    p    r    t    u    w    y    -    8.   9.  BL   0.
unsigned char segment_table[]= {0x84,0xf5,0xc2,0xc1,0xb1,0x89,0x88,0xe5,0x80,0x81,0xa0,0x98,0x8e,0xd0,0x8a,0xaa,0x8c,0xb0,0xd5,0xa8,0x9e,0xe8,0xf8,0xd8,0xa2,0xfa,0x9a,0xdc,0xcc,0x91,0xfb,0x00,0x01,0xff,0x44};
bit blink_flag,blinking,qsecfl;
short int blink_digit;
short int mux_scan;


 void adc3421_init(void)
{                      
i2c_start();
i2c_write(0xd2);
delay_ms(1);
//i2c_write(0x9f);   //18 bit mode 8v/v
i2c_write(0x9b);        //16 bit 8v/v         
i2c_stop();
}

/*
long int adc3421_read18(void)
{
 unsigned int buffer1;
 unsigned int buffer2,buffer3;
 long int buffer4;
 i2c_start();
 buffer1 = i2c_write(0xd3);
 buffer1 = i2c_read(1);
 buffer2 = i2c_read(1);
 buffer3 = i2c_read(0);
 i2c_stop();
 buffer1 = buffer1 & 0x01;
 buffer4 = (long) (buffer1) * 65536 ;
 buffer4 = buffer4 + ((long)(buffer2) * 256);
 buffer4 = buffer4 + (long)(buffer3);
 return(buffer4);
} 
*/

int adc3421_read(void)
{
 unsigned int buffer1;
 unsigned int buffer2;
signed int buffer4;
 i2c_start();
 buffer1 = i2c_write(0xd3);
 buffer1 = i2c_read(1);
 buffer2 = i2c_read(0);
 i2c_stop();
 //buffer1 = buffer1 & 0x7f;      //ignore sign bit
 //buffer4 = (long)(buffer1) * 256);
 //buffer4 = buffer4 + (long)(buffer2);
 buffer4 = (buffer1 *256) + buffer2;
if (buffer4<0) buffer4 = -buffer4;
 return(buffer4);
} 


// Timer1 overflow interrupt service routine
interrupt [TIM1_OVF] void timer1_ovf_isr(void)
{
// Reinitialize Timer1 value
TCNT1H=0xABA0 >> 8;
TCNT1L=0xABA0 & 0xff;
// Place your code here
qsecfl = ~qsecfl;
process_value[mux_scan]=adc3421_read();
mux_scan++;
if (mux_scan >=8) mux_scan =0;
switch(mux_scan)
    {
    case 0: mux9 =0;
            mux10 =0;
            mux11 =0;
            break;
    case 1: mux9 =1;
            mux10 =0;
            mux11 =0;
            break;
    case 2: mux9 =0;
            mux10 =1;
            mux11 =0;
            break;
    case 3: mux9 =1;
            mux10 =1;
            mux11 =0;
            break;
    case 4: mux9 =0;
            mux10 =0;
            mux11 =1;
            break;    
    case 5: mux9 =1;
            mux10 =0;
            mux11 =1;
            break;        
    case 6: mux9 =0;
            mux10 =1;
            mux11 =1;
            break;    
    case 7: mux9 =1;
            mux10 =1;
            mux11 =1;
            break;
    default:mux_scan =0;
            mux9 =0;
            mux10 =0;
            mux11 =0;
            break;       
    }
}




void led_check(void)
{    
//all_led_off();
//all_led_off1();
if (qsecfl)
    {
    led_status =0xaa;
    led_status1 = 0xff;

    }
else
    {
    led_status = 0xff;
    led_status1= 0x55;
    }

}


void display_put(int up_display, int low_display,int status,short int* message1,short int* message2)
{
if (status ==0) 
        {
        if (up_display <0)
        {                
        up_display = -up_display;
        up_display%=1000;
        display_buffer[0]= 32;
        }
        else
        {                                              
        display_buffer[0]=up_display/1000;
        up_display%=1000;
        }
        display_buffer[1]=up_display/100;
        up_display%=100;
        display_buffer[2]=up_display/10;
        up_display%=10;
        display_buffer[3]=up_display;

        if (low_display <0)
        {                
        low_display = -low_display;
        low_display%=1000;
        display_buffer[4]= 32;
        }
        else
        {                                              
        display_buffer[4]=low_display/1000;
        low_display%=1000;
        }
        display_buffer[5]=low_display/100;
        low_display%=100;
        display_buffer[6]=low_display/10;
        low_display%=10;
        display_buffer[7]=low_display;
        }
else if (status ==1)
        {   
        message1 = message1 + (up_display *4);
        display_buffer[0]=*message1;
        message1++;
        display_buffer[1]=*message1;
        message1++;
        display_buffer[2]=*message1;
        message1++;
        display_buffer[3]=*message1;
        if (low_display <0)
        {                
        low_display = -low_display;
        low_display%=1000;
        display_buffer[4]= 32;
        }
        else
        {                                              
        display_buffer[4]=low_display/1000;
        low_display%=1000;
        }        display_buffer[5]=low_display/100;
        low_display%=100;
        display_buffer[6]=low_display/10;
        low_display%=10;
        display_buffer[7]=low_display;
        }
else if (status ==2)
        {
        message1 = message1 + (up_display *4);
        display_buffer[0]=*message1;
        message1++;
        display_buffer[1]=*message1;
        message1++;
        display_buffer[2]=*message1;
        message1++;
        display_buffer[3]=*message1;
        message2 = message2 + (low_display * 4);
        display_buffer[4]=*message2;
        message2++;
        display_buffer[5]=*message2;
        message2++;
        display_buffer[6]=*message2;
        message2++;
        display_buffer[7]=*message2;
        }
/*
if (mode ==9 && open_sensor)
        {
        display_buffer[0] = 1;
        display_buffer[1] = 33;
        display_buffer[2] = 33;
        display_buffer[3] = 33;
        }
if (mode ==9 && neg_fl)
        {
        display_buffer[0] = 32;
        display_buffer[1] = 32;
        display_buffer[2] = 32;
        display_buffer[3] = 32;
        }  
*/
}

void display_check(void)
{
display_put(process_value[0],process_value[1],0,dummy,dummy2);
}


void display_out(short int count2)
{
int asa;
clear_display();
asa = display_buffer[count2];
asa = segment_table[asa];
if (count2 == (7-blink_digit))
{
if (blink_flag && blinking)
PORTA =0xff;
else
PORTA = asa;
}
else
PORTA = asa;//decimal point for upper display

switch(count2)
        {
        case 0:  digit1();
        break;
        case 1:  digit2();
        break;
        case 2:  digit3();
        break;
        case 3:  digit4();
        break;
        case 4:  digit5();
        break;
        case 5:  digit6();
        break;
        case 6:  digit7();
        break;
        case 7:  digit8();
        break;
        case 8: PORTA = led_status; 
                digit9();
                break; 
        case 9: PORTA = led_status1;
                digit10();
        break;
        }

display_put(process_value[0],process_value[1],0,dummy,dummy2);                       //**


}





void init(void)
{
// Input/Output Ports initialization
// Port A initialization
// Function: Bit7=Out Bit6=Out Bit5=Out Bit4=Out Bit3=Out Bit2=Out Bit1=Out Bit0=Out 
DDRA=(1<<DDA7) | (1<<DDA6) | (1<<DDA5) | (1<<DDA4) | (1<<DDA3) | (1<<DDA2) | (1<<DDA1) | (1<<DDA0);
// State: Bit7=1 Bit6=1 Bit5=1 Bit4=1 Bit3=1 Bit2=1 Bit1=1 Bit0=1 
PORTA=(1<<PORTA7) | (1<<PORTA6) | (1<<PORTA5) | (1<<PORTA4) | (1<<PORTA3) | (1<<PORTA2) | (1<<PORTA1) | (1<<PORTA0);

// Port B initialization
// Function: Bit7=Out Bit6=Out Bit5=In Bit4=In Bit3=In Bit2=In Bit1=Out Bit0=Out 
DDRB=(1<<DDB7) | (1<<DDB6) | (0<<DDB5) | (0<<DDB4) | (0<<DDB3) | (0<<DDB2) | (1<<DDB1) | (1<<DDB0);
// State: Bit7=1 Bit6=1 Bit5=P Bit4=P Bit3=P Bit2=P Bit1=1 Bit0=1 
PORTB=(1<<PORTB7) | (1<<PORTB6) | (1<<PORTB5) | (1<<PORTB4) | (1<<PORTB3) | (1<<PORTB2) | (1<<PORTB1) | (1<<PORTB0);

// Port C initialization
// Function: Bit7=Out Bit6=Out Bit5=Out Bit4=Out Bit3=Out Bit2=Out Bit1=Out Bit0=Out 
DDRC=(1<<DDC7) | (1<<DDC6) | (1<<DDC5) | (1<<DDC4) | (1<<DDC3) | (1<<DDC2) | (1<<DDC1) | (1<<DDC0);
// State: Bit7=1 Bit6=1 Bit5=1 Bit4=1 Bit3=1 Bit2=1 Bit1=1 Bit0=1 
PORTC=(1<<PORTC7) | (1<<PORTC6) | (1<<PORTC5) | (1<<PORTC4) | (1<<PORTC3) | (1<<PORTC2) | (1<<PORTC1) | (1<<PORTC0);

// Port D initialization
// Function: Bit7=Out Bit6=Out Bit5=Out Bit4=Out Bit3=Out Bit2=Out Bit1=Out Bit0=Out 
DDRD=(1<<DDD7) | (1<<DDD6) | (1<<DDD5) | (1<<DDD4) | (1<<DDD3) | (1<<DDD2) | (1<<DDD1) | (1<<DDD0);
// State: Bit7=1 Bit6=1 Bit5=1 Bit4=1 Bit3=1 Bit2=1 Bit1=1 Bit0=1 
PORTD=(1<<PORTD7) | (1<<PORTD6) | (1<<PORTD5) | (1<<PORTD4) | (1<<PORTD3) | (1<<PORTD2) | (1<<PORTD1) | (1<<PORTD0);

// Timer/Counter 0 initialization
// Clock source: System Clock
// Clock value: Timer 0 Stopped
// Mode: Normal top=0xFF
// OC0 output: Disconnected
TCCR0=(0<<WGM00) | (0<<COM01) | (0<<COM00) | (0<<WGM01) | (0<<CS02) | (0<<CS01) | (0<<CS00);
TCNT0=0x00;
OCR0=0x00;

// Timer/Counter 1 initialization
// Clock source: System Clock
// Clock value: 172.800 kHz
// Mode: Normal top=0xFFFF
// OC1A output: Disconnected
// OC1B output: Disconnected
// Noise Canceler: Off
// Input Capture on Falling Edge
// Timer Period: 0.5 s
// Timer1 Overflow Interrupt: On
// Input Capture Interrupt: Off
// Compare A Match Interrupt: Off
// Compare B Match Interrupt: Off
TCCR1A=(0<<COM1A1) | (0<<COM1A0) | (0<<COM1B1) | (0<<COM1B0) | (0<<WGM11) | (0<<WGM10);
TCCR1B=(0<<ICNC1) | (0<<ICES1) | (0<<WGM13) | (0<<WGM12) | (1<<CS12) | (0<<CS11) | (0<<CS10);
TCNT1H=0xAB;
TCNT1L=0xA0;
ICR1H=0x00;
ICR1L=0x00;
OCR1AH=0x00;
OCR1AL=0x00;
OCR1BH=0x00;
OCR1BL=0x00;

// Timer/Counter 2 initialization
// Clock source: System Clock
// Clock value: Timer2 Stopped
// Mode: Normal top=0xFF
// OC2 output: Disconnected
ASSR=0<<AS2;
TCCR2=(0<<PWM2) | (0<<COM21) | (0<<COM20) | (0<<CTC2) | (0<<CS22) | (0<<CS21) | (0<<CS20);
TCNT2=0x00;
OCR2=0x00;

// Timer(s)/Counter(s) Interrupt(s) initialization
TIMSK=(0<<OCIE2) | (0<<TOIE2) | (0<<TICIE1) | (0<<OCIE1A) | (0<<OCIE1B) | (1<<TOIE1) | (0<<OCIE0) | (0<<TOIE0);

// External Interrupt(s) initialization
// INT0: Off
// INT1: Off
// INT2: Off
MCUCR=(0<<ISC11) | (0<<ISC10) | (0<<ISC01) | (0<<ISC00);
MCUCSR=(0<<ISC2);

// USART initialization
// Communication Parameters: 8 Data, 1 Stop, No Parity
// USART Receiver: On
// USART Transmitter: On
// USART Mode: Asynchronous
// USART Baud Rate: 9600 (Double Speed Mode)
UCSRA=(0<<RXC) | (0<<TXC) | (0<<UDRE) | (0<<FE) | (0<<DOR) | (0<<UPE) | (1<<U2X) | (0<<MPCM);
UCSRB=(1<<RXCIE) | (1<<TXCIE) | (0<<UDRIE) | (1<<RXEN) | (1<<TXEN) | (0<<UCSZ2) | (0<<RXB8) | (0<<TXB8);
UCSRC=(1<<URSEL) | (0<<UMSEL) | (0<<UPM1) | (0<<UPM0) | (0<<USBS) | (1<<UCSZ1) | (1<<UCSZ0) | (0<<UCPOL);
UBRRH=0x00;
UBRRL=0x8F;

// Analog Comparator initialization
// Analog Comparator: Off
// The Analog Comparator's positive input is
// connected to the AIN0 pin
// The Analog Comparator's negative input is
// connected to the AIN1 pin
ACSR=(1<<ACD) | (0<<ACBG) | (0<<ACO) | (0<<ACI) | (0<<ACIE) | (0<<ACIC) | (0<<ACIS1) | (0<<ACIS0);
SFIOR=(0<<ACME);

// ADC initialization
// ADC disabled
ADCSRA=(0<<ADEN) | (0<<ADSC) | (0<<ADATE) | (0<<ADIF) | (0<<ADIE) | (0<<ADPS2) | (0<<ADPS1) | (0<<ADPS0);

// SPI initialization
// SPI disabled
SPCR=(0<<SPIE) | (0<<SPE) | (0<<DORD) | (0<<MSTR) | (0<<CPOL) | (0<<CPHA) | (0<<SPR1) | (0<<SPR0);

// TWI initialization
// TWI disabled
TWCR=(0<<TWEA) | (0<<TWSTA) | (0<<TWSTO) | (0<<TWEN) | (0<<TWIE);

// Bit-Banged I2C Bus initialization
// I2C Port: PORTB
// I2C SDA bit: 1
// I2C SCL bit: 0
// Bit Rate: 100 kHz
// Note: I2C settings are specified in the
// Project|Configure|C Compiler|Libraries|I2C menu.
i2c_init();
delay_ms(250);
adc3421_init();
delay_ms(250);

// Global enable interrupts
#asm("sei")
}

void main(void)
{
// Declare your local variables here


init();

while (1)
      {
      // Place your code here
      display_check();
      display_out(display_count);
      display_count++; 
      led_check();
      if(display_count >=10) display_count =0;
//      process_value[0] =1234;
//      process_value[1] = 5678; 
      }
}
