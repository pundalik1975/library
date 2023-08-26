/*****************************************************
  DERIVED FROM PID6.C
to remove bug that mode =0 for welcome message
and also storing of param1[] parameters in eeprom
  
derived from pid4.c

date: 21-6-09
reason: pid4.c completed with all modes and key routines.
to do: add the adc part and control action part.



change the programming modes as follows:
set1: pressing set key 
set2: pressing up and down keys
configuration mode: shorting PA.3 and turning on instrument
calibration mode: shorting PA.4 before turning on instrument


This program was produced by the
CodeWizardAVR V1.24.6 Standard
Automatic Program Generator
© Copyright 1998-2005 Pavel Haiduc, HP InfoTech s.r.l.
http://www.hpinfotech.com
e-mail:office@hpinfotech.com

Project : PID
Version : 1.01
Date    : 5/4/2009
Author  : PUNDALIK                        
Company : MAMATA                          
Comments: 
A simple two set point PID controller
with configurable second set point.
 


Chip type           : ATmega16
Program type        : Application
Clock frequency     : 11.059200 MHz
Memory model        : Small
External SRAM size  : 0
Data Stack size     : 256
*****************************************************/

#include <mega16.h>

// I2C Bus functions
#asm
   .equ __i2c_port=0x1B ;PORTA
   .equ __sda_bit=6
   .equ __scl_bit=7
#endasm
#include <i2c.h>

// DS1307 Real Time Clock functions
#include <ds1307.h>

// Declare your global variables here

#define DATA_REGISTER_EMPTY (1<<UDRE)
#define RX_COMPLETE (1<<RXC)
#define FRAMING_ERROR (1<<FE)
#define PARITY_ERROR (1<<UPE)
#define DATA_OVERRUN (1<<DOR)
#define slave_address 9


// USART Receiver buffer
#define RX_BUFFER_SIZE 16
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
bit rx_buffer_overflow,modbus_fl;
char modbus_frame[8];
// USART Receiver interrupt service routine
interrupt [USART_RXC] void usart_rx_isr(void)
{
char status,data;
short int i;
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
///////////////////////////////////   
//added to form modbus frame
if (rx_counter ==1)
    {
    if (rx_buffer[0] != slave_address)
        rx_counter = rx_wr_index =0;    //reset frame till first byte matchs slave address
    
    
    }   
else
    {
    // valid slave address.allot frame size according to function code. 
    if (rx_counter >=8)
      {
    //modbus frame complete. transfer data to modbus_frame[]   
        for (i=0;i<8;i++)
        {
        modbus_frame[i] = rx_buffer[i];
        }
        rx_counter = rx_wr_index =0;        //reset counter to start for next frame
        modbus_fl =1;                       // set flag to indicate frame recieved in main routine.
      }
    }   
   
   
//////////////////////////////////
   }
    
}   
   
/*unsigned short crc16(char *data_p, unsigned short length)
{
      unsigned char i;
      unsigned int data;
      unsigned int crc = 0xffff;

      if (length == 0)
            return (~crc);

      do
      {
            for (i=0, data=(unsigned int)0xff & *data_p++;
                 i < 8; 
                 i++, data >>= 1)
            {
                  if ((crc & 0x0001) ^ (data & 0x0001))
                        crc = (crc >> 1) ^ POLY;
                  else  crc >>= 1;
            }
      } while (--length);

      crc = ~crc;
      data = crc;
      crc = (crc << 8) | (data >> 8 & 0xff);

      return (crc);
}

*/
#define transmit_fl PORTD.2

flash int wCRCTable[] = {
0X0000, 0XC0C1, 0XC181, 0X0140, 0XC301, 0X03C0, 0X0280, 0XC241,
0XC601, 0X06C0, 0X0780, 0XC741, 0X0500, 0XC5C1, 0XC481, 0X0440,
0XCC01, 0X0CC0, 0X0D80, 0XCD41, 0X0F00, 0XCFC1, 0XCE81, 0X0E40,
0X0A00, 0XCAC1, 0XCB81, 0X0B40, 0XC901, 0X09C0, 0X0880, 0XC841,
0XD801, 0X18C0, 0X1980, 0XD941, 0X1B00, 0XDBC1, 0XDA81, 0X1A40,
0X1E00, 0XDEC1, 0XDF81, 0X1F40, 0XDD01, 0X1DC0, 0X1C80, 0XDC41,
0X1400, 0XD4C1, 0XD581, 0X1540, 0XD701, 0X17C0, 0X1680, 0XD641,
0XD201, 0X12C0, 0X1380, 0XD341, 0X1100, 0XD1C1, 0XD081, 0X1040,
0XF001, 0X30C0, 0X3180, 0XF141, 0X3300, 0XF3C1, 0XF281, 0X3240,
0X3600, 0XF6C1, 0XF781, 0X3740, 0XF501, 0X35C0, 0X3480, 0XF441,
0X3C00, 0XFCC1, 0XFD81, 0X3D40, 0XFF01, 0X3FC0, 0X3E80, 0XFE41,
0XFA01, 0X3AC0, 0X3B80, 0XFB41, 0X3900, 0XF9C1, 0XF881, 0X3840,
0X2800, 0XE8C1, 0XE981, 0X2940, 0XEB01, 0X2BC0, 0X2A80, 0XEA41,
0XEE01, 0X2EC0, 0X2F80, 0XEF41, 0X2D00, 0XEDC1, 0XEC81, 0X2C40,
0XE401, 0X24C0, 0X2580, 0XE541, 0X2700, 0XE7C1, 0XE681, 0X2640,
0X2200, 0XE2C1, 0XE381, 0X2340, 0XE101, 0X21C0, 0X2080, 0XE041,
0XA001, 0X60C0, 0X6180, 0XA141, 0X6300, 0XA3C1, 0XA281, 0X6240,
0X6600, 0XA6C1, 0XA781, 0X6740, 0XA501, 0X65C0, 0X6480, 0XA441,
0X6C00, 0XACC1, 0XAD81, 0X6D40, 0XAF01, 0X6FC0, 0X6E80, 0XAE41,
0XAA01, 0X6AC0, 0X6B80, 0XAB41, 0X6900, 0XA9C1, 0XA881, 0X6840,
0X7800, 0XB8C1, 0XB981, 0X7940, 0XBB01, 0X7BC0, 0X7A80, 0XBA41,
0XBE01, 0X7EC0, 0X7F80, 0XBF41, 0X7D00, 0XBDC1, 0XBC81, 0X7C40,
0XB401, 0X74C0, 0X7580, 0XB541, 0X7700, 0XB7C1, 0XB681, 0X7640,
0X7200, 0XB2C1, 0XB381, 0X7340, 0XB101, 0X71C0, 0X7080, 0XB041,
0X5000, 0X90C1, 0X9181, 0X5140, 0X9301, 0X53C0, 0X5280, 0X9241,
0X9601, 0X56C0, 0X5780, 0X9741, 0X5500, 0X95C1, 0X9481, 0X5440,
0X9C01, 0X5CC0, 0X5D80, 0X9D41, 0X5F00, 0X9FC1, 0X9E81, 0X5E40,
0X5A00, 0X9AC1, 0X9B81, 0X5B40, 0X9901, 0X59C0, 0X5880, 0X9841,
0X8801, 0X48C0, 0X4980, 0X8941, 0X4B00, 0X8BC1, 0X8A81, 0X4A40,
0X4E00, 0X8EC1, 0X8F81, 0X4F40, 0X8D01, 0X4DC0, 0X4C80, 0X8C41,
0X4400, 0X84C1, 0X8581, 0X4540, 0X8701, 0X47C0, 0X4680, 0X8641,
0X8201, 0X42C0, 0X4380, 0X8341, 0X4100, 0X81C1, 0X8081, 0X4040 };

unsigned int CRC16 (const char *nData, unsigned int wLength)
{


char nTemp;
unsigned int wCRCWord = 0xFFFF;

   while (wLength--)
   {
      nTemp = *nData++ ^ wCRCWord;
      wCRCWord >>= 8;
      wCRCWord ^= wCRCTable[nTemp];
   }
   return wCRCWord;

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
#define TX_BUFFER_SIZE 16
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
if (tx_counter>0)
   {
   --tx_counter;
   UDR=tx_buffer[tx_rd_index++];
#if TX_BUFFER_SIZE != 256
   if (tx_rd_index == TX_BUFFER_SIZE) tx_rd_index=0;
#endif
   }
else
    {
    transmit_fl =0;     // once transmit complete reset module to recieve
    }
}


#ifndef _DEBUG_TERMINAL_IO_
// Write a character to the USART Transmitter buffer
#define _ALTERNATE_PUTCHAR_
#pragma used+
void putchar(char c)
{
while (tx_counter == TX_BUFFER_SIZE);
//#asm("cli")
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
//#asm("sei")
}
#pragma used-
#endif
  




#include <stdio.h>

#define ADC_VREF_TYPE 0x00     // change to 0x00 for external aref



// Declare your global variables here

#define digit1() PORTC |= (1<<0)
#define digit2() PORTD |= (1<<6)
#define digit3() PORTD |= (1<<3)
#define digit4() PORTC |= (1<<6)
#define digit5() PORTC |= (1<<7)
#define digit6() PORTD |= (1<<7)
#define digit7() PORTC |= (1<<1)
#define digit8() PORTC |= (1<<2)
#define digit9() PORTD.5 = 1

void clear_display(void)
{
PORTB =0xff;
PORTC &= 0x38;
PORTD &= 0x17; 

}
                    
#define SET_POINTS 3
#define PARAM1_MAX 3
#define PARAM2_MAX 2
#define PARAM3_MAX 14

#define calib  PINA.4
#define config PINA.3
#define relay1 PORTD.4
#define relay2 PORTD.1
#define relay3 PORTD.0
#define FILTER 20

//                              0     1     2   3    4    5    6    7     8    9   10    11   12   13   14   15   16   17   18   19   20   21   22   23   24   25   26   27   28   29   30   31   32   33  34
//                              0     1     2   3    4    5    6    7     8    9    a    b    c    d    e    f    g    h    j    k    l    m    n    o    p    r    t    u    w    y    z    .    -   
unsigned char segment_table[]= {0x28,0x6f,0x58,0x49,0x0f,0x89,0x88,0x6d,0x08,0x09,0x0c,0x8a,0xb8,0x4a,0x98,0x9c,0xa8,0x0e,0x6a,0x8c,0xba,0xcc,0xce,0xca,0x1c,0xde,0x9a,0x2a,0xe8,0x0b,0x09,0xf7,0xdf,0xff};
unsigned short int item1,display_buffer[8];
int zero_p,span_p,zero_tc,span_tc,adc_sample,speed_cnt,ambient_buffer,ambient_raw,adc_pt,adc_tc,adc_amb; 
unsigned long int adc_sum,mode_reset; 
bit open_sensor,neg_fl,first_time;
short int display_count,scan_count=40,p_error;
int set_value,ambient_val,process_value,process_value1,process_value9,process_value10;    // set_value stored in mode0  -> press set key || release set key
int param1[PARAM1_MAX];                  // memory for storing in mode1 -> press inc & dec key for 2~3 seconds || press set key for 2~3 seconds
int param2[PARAM2_MAX];                 //memory for storing in mode 2 -> press set key for 2~3 seconds || press set key for 2~3 seconds     
int param3[PARAM3_MAX];                  //memory for storing in mode 3 -> press set & inc key for 2~3 seconds
unsigned int adc_data;
unsigned int mode1_cnt,mode0_cnt,delay_counter,range_max,range_min,range_hys,range_off;
unsigned short int item2,item3,item4;
unsigned int ent_count,speed_byte =400;
bit pgm_fl,modify_flag;
unsigned short int mode =8;        
eeprom int e_set_value = 200;
eeprom int e_param1[PARAM1_MAX]={0,20,20};
eeprom int e_param2[PARAM2_MAX]={0,0};
//inp,Pvos,cnt1,p,cyct,hys1,rng1,Lock,cnt2,hys2,rng2,cnt3,hys3,rng3                     
eeprom int e_param3[PARAM3_MAX]={2,0,0,20,20,1,600,0,4,1,600,5,1,600};
eeprom int e_zero_p=1495,e_span_p=13124,e_zero_tc=1305,e_span_tc=17582;
eeprom int e_ambient_raw = 1200,e_ambient_buffer=30;
unsigned int pr_cnt,first_cnt;
unsigned short int pr_cnt1,out_count,error1; 
//                      set1
short int message_set[] = {05,14,26,01};   
short int dummy1[1] = {0};
short int dummy2[1] = {0};
//                             Man,       Set2,          set3
short int message_param1[]= {33,21,10,22,05,14,26,02,05,14,26,03};
//                          set2    ,   at
short int message_param2[]= {05,14,26,02,32,32,10,25};
//                             i  n p   ,  Pvos     ,   cnt1    ,     p     ,    cyct   ,   hys1    ,   rng1    ,Lock       ,  cnt2    ,    hys2   ,   rng2      ,  cnt3    ,    hys3   ,   rng3                     
short int message_param3[]= {33,01,22,24,24,27,23,05,12,22,26,01,33,33,33,24,12,29,12,26,17,29,05,01,25,22,16,01,20,23,12,19,12,22,26,02,17,29,05,02,25,22,16,02,12,22,26,03,17,29,05,03,25,22,16,03};

short int message_param4[]= {33,33,24,26,33,33,26,12,33,10,21,11};  // Pt/Tc/Amb

short int message_inp[]= {33,24,26,01,33,24,26,02,33,33,33,18,33,33,33,19}; //pt1/pt2/j/k

short int message_cnt1[]= {33,33,23,22,33,33,24,25};   //on/off Pr

short int message_cnt2[]= {17,14,10,26,12,23,23,20,10,32,17,01,10,32,20,23,13,32,17,01,13,32,20,23,11,23,26,17}; //heat/cool/a-hi/a-lo/d-hi/d-lo/both


bit set_key=1;
bit inc_key=1;
bit dec_key=1;
int table_p[] = {0000,1136,2223,3310,4352,5372,6372,7352,8314,9275};
char slope_p[] = {44,46,46,48,49,50,51,52,52};
int table_j[] = {0000,527,1078,1633,2185,2739,3311,3915,4518,5122,5726,6330,6934,7538,8142};
char slope_j[] = {19,18,18,18,18,17,16,16,16,16,16,16,16,16,16,16};
int table_k[] = {0000,416,816,1232,1632,2048,2483,2899,3315,3715,4115,4500,4870,5240,5610,5980,6350,6720,7090,7460,7830};
char slope_k[] = {24,25,25,24,24,23,24,24,25,25,26,27,27,27,27,27,27};

unsigned short int led_status;
                                  
#define all_led_off() led_status = 0xff;
#define led1_on() led_status &= 0xfe
#define led2_on() led_status &= 0xfd
#define led3_on() led_status &= 0xfb
#define led4_on() led_status &= 0xf7
#define led5_on() led_status &= 0xef
#define led6_on() led_status &= 0xdf
#define led7_on() led_status &= 0xbf
#define led8_on() led_status &= 0x7f
#define led1_off() led_status |= 0x01
#define led2_off() led_status |= 0x02
#define led3_off() led_status |= 0x04
#define led4_off() led_status |= 0x08
#define led5_off() led_status |= 0x10
#define led6_off() led_status |= 0x20
#define led7_off() led_status |= 0x40
#define led8_off() led_status |= 0x80





void led_check(void)
{    
all_led_off();
if (relay1) led3_off();
else led3_on();
if (relay2) led2_off();
else led2_on();
if (relay3) led1_off();
else led1_on();
if (mode ==9) led6_off();
else led6_on();
}


int linearise_p(float a)
{
int number =0;
int count;
int b=0;
long int temp=0;
float temp1=0;
int true_value = 0;

temp1 = (a /(span_p - zero_p)) * 6372;
b = (int)temp1;

for (count=0;count <= 10; count++)  
    {
    if (b>table_p[count] && b <= table_p[count+1])    
        {
        number = count;
        break;
        }
    }

temp = ((((long)b - table_p[number])/2) * slope_p[number]/50)+ ((long)number * 500);
true_value = (int) temp;
return (true_value);
}


int linearise_tc(float a, int* tabletc, char* slopetc)
{
int number =0;
int count;
long temp;
int true_value = 0,b=0;
float temp1=0; 
temp1 = (a /(span_tc-zero_tc)) * 5000;
b = (int)temp1;
for (count=0;count <= 14; count++)  
    {
    if (b> *(tabletc+count) && b <= *(tabletc+count+1))    
        {
        number = count;
        break;
        }
    }
temp = ((  (((long)b - *(tabletc+number)))  *  *(slopetc+number))/100) + ((long)number * 100);
true_value = (int) temp;
return (true_value);

}


/*
check mode sets the appropriate mode value depending upon keys
mode 9: default mode 
mode 0: setting set1
mode1:  used for setting set2/set3/manual reset
mode 2: not used
mode 3: configuration mode when config =0 ( hardware control)
mode 4: calibration mode when calib =0    ( hardware control)

*/
               
void check_mode(void)
{       
        PORTA.4 =1; 
        PORTA.3 =1;
        if ( calib ==0) 
        {
        mode = 4;
        }
        if (set_key ==0 && inc_key ==0 && dec_key ==0 && config ==1 && pgm_fl ==0 && modify_flag ==1 )
        {
        e_set_value = set_value;
        modify_flag =0;   
        }               
        if (!pgm_fl && config && calib)
        {
        mode =9;
        item1=0;
        item2=0;
        item3=0;
        item4=0;                                                                                              
         }
        if (config ==1 && set_key ==1 && mode == 9 && calib ==1) 
                {
                 mode = 0;
                                 
                }
/*        else if ( config ==0 && set_key ==1 && inc_key ==0 && dec_key ==0)
                {
                mode0_cnt++;
                if (mode0_cnt > 1000)
                        { 
                        if (mode == 9)
                                {
                                mode =2;
                                pgm_fl =1;
                                mode0_cnt =0;
                                }
                        else
                                {
                                pgm_fl=0;
                                mode =9;     
                                mode0_cnt =0; 
                                }
                 
                        }
                }       
  */
        else if (config ==0 && pgm_fl ==0 && calib ==1)
                {
                mode =3;
                pgm_fl =0; 
                }
        else if (config ==1 && inc_key ==1 && dec_key==1 && set_key ==0 && calib ==1 && param3[7] !=0)
                {
                mode1_cnt++;
                if (mode1_cnt > 5000)
                        {
                        if (mode == 9)
                                {
                                mode =1;
                                pgm_fl =1;
                                mode1_cnt =0;
                                }
                        else
                                {
                                pgm_fl=0;
                                mode =9;     
                                mode1_cnt =0; 
                                e_param1[0] = param1[0];    //store value in eeprom
                                }
                        }
                }
        else
                {
                mode1_cnt =0;
                mode0_cnt =0;

                }
 
}

void range_check(void)
{         





if (calib)              // when not in calibration mode
{                                                        
open_sensor =0;
neg_fl =0;
switch (param3[0])
                {
                case 0:        range_max = 4000;        //pt100 0.1
                               range_min = -500;  
                               range_hys = 999; 
                               range_off = -999;
                               if (adc_pt > zero_p) process_value1 = linearise_p(adc_pt - zero_p)+param3[1];
                               else process_value1 = -(linearise_p(zero_p - adc_pt))+ param3[1];
                               if (process_value1 > 4250) open_sensor =1; 
                               if (process_value1 < -510) neg_fl =1;
                               break;
                case 1:        range_max = 400;        //pt100 1
                                range_min = -50;
                                range_hys = 99; 
                                range_off = -99;
                                if (adc_pt > zero_p) process_value1 = linearise_p(adc_pt - zero_p)/10 + param3[1];
                               else process_value1 = -(linearise_p(zero_p - adc_pt))/10 + param3[1];  
                               if (process_value1 > 425) open_sensor =1;
                               if (process_value1 < -51) neg_fl =1; 
                                break;
                case 2:        range_max = 650;        //j-type
                                range_min = 0; 
                                range_hys = 99; 
                                range_off =-99; 
                                if (adc_tc >= zero_tc) process_value1 = linearise_tc(adc_tc - zero_tc,table_j,slope_j) + ambient_val + param3[1];
                                else process_value1 = - linearise_tc(zero_tc-adc_tc,table_j,slope_j) + ambient_val + param3[1];
                                if (process_value1 > 675) open_sensor =1; 
                                if (process_value1 < -10) neg_fl =1;
                                break;
                case 3:        range_max = 1250;        //k-type
                                range_min = 0; 
                                range_hys = 99;
                                range_off = -99;
                                if (adc_tc >= zero_tc) process_value1 = linearise_tc(adc_tc - zero_tc,table_k,slope_k) + ambient_val + param3[1];
                                else process_value1 = - linearise_tc(zero_tc-adc_tc,table_k,slope_k) + ambient_val + param3[1];
                                if (process_value1 > 1275) open_sensor =1; 
                                if (process_value1 < -10) neg_fl =1;
                                break;
                }        

                                process_value10 = process_value9;    
                process_value9 = process_value1;
                if ((process_value9 >= process_value10 - FILTER) && (process_value9 <= process_value10 +FILTER))
                    {                     
                    process_value = (process_value1 + process_value10)/2 ;
                    }
}
else
{
switch (item4)
        {
        case 0: ADMUX = 0x00;
                break;
        case 1: ADMUX = 0x01;
                break;
        case 2: ADMUX = 0x02;
                break;
        }

}
}

void increment_value(int* value,int low_limit,int high_limit)
{
*value = *value+1;
if (*value < low_limit) *value = low_limit;
if (*value >= high_limit) *value = high_limit;
} 

void decrement_value(int* value,int low_limit,int high_limit)
{
*value = *value-1;
if (*value < low_limit) *value = low_limit;
if (*value >= high_limit) *value = high_limit;
} 

//check and increment if set and incrment key are pressed together
void check_increment(void)
{
if (set_key==1 && inc_key==1 && dec_key ==0)
{
mode_reset =0;  
modify_flag =1;
if (mode ==0) increment_value(&set_value,range_min,param3[6]);
//if (mode ==2) increment_value(&param2[0],0,param3[10]);
if (mode ==1) 
        {
        switch (item1)
                {
                case 0:  increment_value(&param1[0],0,range_hys);
                         break;
                case 1:  increment_value(&param1[1],range_min,param3[10]);
                         break;
                case 2:  increment_value(&param1[2],range_min,param3[13]);
                         break;

                }
        }        
//inp,Pvos,cnt1,p,cyct,hys1,rng1,Lock,cnt2,hys2,rng2,cnt3,hys3,rng3                     

if (mode ==3) 
        {
        switch (item3)
                {
                case 0:  increment_value(&param3[0],0,3);      //input pt1/pt2/j/k
                         break;
                case 1: increment_value(&param3[1],range_off,range_hys);   //Pvos
                         break;
                case 2:  increment_value(&param3[2],0,1);      //control1
                         break;
                case 3:  increment_value(&param3[3],0,99);     //P
                         break;
                case 4:  increment_value(&param3[4],1,99);     //cyct
                         break;
                case 5:  increment_value(&param3[5],1,range_hys);      //hys1
                         break;
                case 6:  increment_value(&param3[6],range_min,range_max);      //range1
                         break;
                case 7:  increment_value(&param3[7],0,1);//Lock
                         break;
                case 8:  increment_value(&param3[8],0,6);     //control mode 2 heat/cool/al-hi/al-lo/dev-alhi/dev-allo/dev-both
                         break;
                case 9:  increment_value(&param3[9],1,range_hys);      //hysterisis2
                         break;
                case 10:  increment_value(&param3[10],range_min,range_max); // range2
                         break;                                              
                 case 11:  increment_value(&param3[11],0,6);     //control mode 3 heat/cool/al-hi/al-lo/dev-alhi/dev-allo/dev-both
                         break;
                case 12:  increment_value(&param3[12],1,range_hys);      //hysterisis3
                         break;
                case 13:  increment_value(&param3[13],range_min,range_max); // range3
                         break;
    
                }
        }
 if (mode ==4)
        {
        switch (item4)
                {
                case 0: zero_p = adc_data;
                        e_zero_p = adc_data;
                        break;
                case 1: zero_tc = adc_data; 
                        e_zero_tc = adc_data;
                        break;
                case 2: increment_value(&ambient_buffer,0,60);
                        break;
                }
        
        } 
}
}                                                                 

//check and decrement if set and decrement key are pressed together
void check_decrement(void)
{
if (set_key==1 && inc_key==0 && dec_key ==1)
{
mode_reset =0;
modify_flag =1;
if (mode ==0) decrement_value(&set_value,range_min,param3[6]);
if (mode ==2) decrement_value(&param2[0],0,99);
if (mode ==1) 
        {
switch (item1)
                {
                case 0:  decrement_value(&param1[0],0,range_hys);
                         break;
                case 1:  decrement_value(&param1[1],range_min,param3[10]);
                         break;
                case 2:  decrement_value(&param1[2],range_min,param3[13]);
                         break;

                }
        }  
//inp,Pvos,cnt1,p,cyct,hys1,rng1,Lock,cnt2,hys2,rng2,cnt3,hys3,rng3                     
      
if (mode ==3) 
        {
       switch (item3)
                {
                case 0:  decrement_value(&param3[0],0,3);      //input pt1/pt2/j/k
                         break;
                case 1:  decrement_value(&param3[1],range_off,range_hys);   //Pvos
                         break;
                case 2:  decrement_value(&param3[2],0,1);      //control1
                         break;
                case 3:  decrement_value(&param3[3],1,99);     //P
                         break;
                case 4:  decrement_value(&param3[4],1,99);     //cyct
                         break;
                case 5:  decrement_value(&param3[5],1,range_hys);      //hys1
                         break;
                case 6:  decrement_value(&param3[6],range_min,range_max);      //range1
                         break;
                case 7:  decrement_value(&param3[7],0,1);//Lock
                         break;
                case 8:  decrement_value(&param3[8],0,6);     //control mode 2 heat/cool/al-hi/al-lo/dev-alhi/dev-allo/dev-both
                         break;
                case 9:  decrement_value(&param3[9],1,range_hys);      //hysterisis2
                         break;
                case 10: decrement_value(&param3[10],range_min,range_max); // range2
                         break;                                              
                 case 11: decrement_value(&param3[11],0,6);     //control mode 3 heat/cool/al-hi/al-lo/dev-alhi/dev-allo/dev-both
                         break;
                case 12:  decrement_value(&param3[12],1,range_hys);      //hysterisis3
                         break;
                case 13:  decrement_value(&param3[13],range_min,range_max); // range3
                         break;
    
                }
        } 
if (mode ==4)
        {
        switch (item4)
                {
                case 0: span_p = adc_data;
                        e_span_p = adc_data;
                        break;
                case 1: span_tc = adc_data; 
                        e_span_tc = adc_data;
                        break;
                case 2: decrement_value(&ambient_buffer,0,60);
                        break;
                }
        
        }        
}
}                                                                 
                                                               
// check if only decrement key is pressed to enter new values in eeprom and move to next parameter
void check_enter(void)
{
if (dec_key ==1 && inc_key ==0 && set_key ==0)
{ 
mode_reset =0;
ent_count++;
if (ent_count >=800)
{
ent_count =0;                  

if (mode ==1)
        {     
        if (modify_flag ==1)
        {
        e_param1[item1] = param1[item1];
        modify_flag =0;
        }
        item1++;
        if (item1 >= param3[7]) item1 =0;               //PARAM1_MAX) item1 =0;
        }                      

//inp,Pvos,cnt1,p,cyct,hys1,rng1,Lock,cnt2,hys2,rng2,cnt3,hys3,rng3                     
if (mode ==3)
        {    
        if (modify_flag ==1)
        {
        modify_flag =0;
        e_param3[item3] = param3[item3];      //store modfiied value
        }
// check the input parameter and set range_max accordingly
        if (item3 ==0)
        {
        range_check();
        //code added to automatically reset set1/2/3 and rng1/2/3 to maximum if excess
        if (set_value > range_max) e_set_value = set_value = range_max;
        if (param1[1] > range_max) e_param1[1] = param1[1] = range_max;
        if (param1[2] > range_max) e_param1[2] = param1[2] = range_max;
        if (param3[6] > range_max) e_param3[6] = param3[6] = range_max;
        if (param3[10] > range_max) e_param3[10] = param3[10] = range_max;
        if (param3[13] > range_max) e_param3[13] = param3[13] = range_max;
        }
        
        if (item3 ==2 && param3[2] ==0) item3 +=2;          // if on/off skip p,and cyct values
        if (item3 ==4 && param3[2] ==1) item3 ++;            // if time proportional skip hysterisis   
        
        item3++;
        if(item3 >= 8) item3 =0;    //PARAM3_MAX) item3 =0;

        param3[item3] = e_param3[item3];        //reload next parameter from eeprom
 
        }
 if (mode ==4)
        {
        if (item4 == 2)
        {
        ambient_raw = adc_data; 
        e_ambient_raw = ambient_raw;
        e_ambient_buffer = ambient_buffer;
        // add ambient calculation here for calibration of ambient value
        item4 =0; 
               
        }
        else
        {
        item4++;
        }
        }
}
}
else
{
ent_count =0;
}
}

void eeprom_transfer(void)
{    
int i;
set_value  = e_set_value;
if (set_value > 9999) set_value =0;
if (set_value < -50) set_value = -50;

for (i=0;i< PARAM1_MAX;i++)
{
param1[i] = e_param1[i];
if (param1[i] >9999) param1[i] =0;
}
for (i=0;i< PARAM2_MAX;i++)
{
param2[i] = e_param2[i];
if (param2[i] >9999) param2[i] =0;
}
for (i=0;i< PARAM3_MAX;i++)
{
param3[i] = e_param3[i];
if (param3[i] >9999) param3[i] =0;
}
zero_p = e_zero_p;
span_p = e_span_p;
zero_tc = e_zero_tc;
span_tc = e_span_tc;
ambient_raw = e_ambient_raw;
ambient_buffer = e_ambient_buffer;

} 

// ADC interrupt service routine
interrupt [ADC_INT] void adc_isr(void)
{             
adc_sample++;
if ( adc_sample >=8000)
        {
        adc_sample =0;
        adc_data = adc_sum /800;
        adc_sum =0; 
        //code added to assign adc_data sample to respective location according to input parameter
        if (calib && (param3[0] == 0  || param3[0] ==1))
                {
                //input is pt100
                adc_pt = adc_data;      // store adc data in pt100 buffer 
                ADMUX = 0x00;
                }                                                        
        else if (calib && (param3[0] == 2  || param3[0] == 3))
                {
                //input is thermocouple
                scan_count++;
                if (scan_count >= 45) 
                        {
                        scan_count =0;
                        ADMUX = 0x01;   //select tc input
                        }
                if (scan_count <= 40 && scan_count >=1) adc_tc = adc_data;
                if (scan_count > 40) ADMUX = 0x02;      //switch to ambient sense
                if (scan_count > 42) 
                        {
                        adc_amb = adc_data;
                        ADMUX = 0x02; 
                        }
                        
                }
        
        }
else
        {
        adc_sum += ADCW;
        }           
speed_cnt++;
if (speed_cnt >= 50)
{
speed_cnt =0;
if ((set_key ==1 && inc_key ==1 && dec_key ==0) || (set_key ==1 && inc_key ==0 && dec_key ==1))
        {
        speed_byte--;
        if ( speed_byte <2) speed_byte =2;
        }
else
        {
        speed_byte = 400;
        }
}

pr_cnt++;
if (pr_cnt > 25)
        {                       // executed once every 10mS  @11.0592MhZ

        pr_cnt =0;
        pr_cnt1++;
        if (pr_cnt1 > param3[4])        // cycle time
                {
                pr_cnt1=0;
                // code for proportional action
                if (param3[2]==1)
            {
            out_count++;
            if ((out_count >= error1) || (error1 ==0)) relay1 =1;
            if ((out_count < error1) || (error1 == 255)) relay1=0;
            if (out_count >= 255) 
                {
                out_count =0;
                error1 = p_error;
                }
            }
        else
            {
            out_count =0;
            }
        }
                                       
        }
        
first_cnt++;
if (first_cnt > 34000)
{
first_cnt =0;
first_time =1;                  // executed every 2 seconds
mode_reset++;
if (mode_reset >10)             // added to determine that if no key is pressed for more than 20 secs. come out of mode1
        {
        if (mode ==1)
                {
                pgm_fl=0;
                mode =9;     
                item1 =0;
                }     
        }
}
// Read the AD conversion result
//adc_data=ADCW;  
// Place your code here

}       

void WDT_off(void)
{
/* reset WDT */
#asm("wdr")
/* Write logical one to WDTOE and WDE */
WDTCR |= (1<<4) | (1<<3);
/* Turn off WDT */
WDTCR = 0x00;
}

/*puts value in the display buffer 
//if status =0, put value on upper and lower display
//if status =1, put message pointed by message1 in upper display and value in lower dsplay
//if status =2, put message on both display pointed by message1 and message2 */ 

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
// code added to blank the unused 0s
if (mode ==9)
        {
        if (process_value < 1000 && process_value >=0) display_buffer[0] = 33;
        if (process_value < 100 && process_value >=0) display_buffer[1] = 33;
        if (set_value < 1000 && set_value >=0) display_buffer[4] = 33;
        if (set_value < 100 && set_value >=0) display_buffer[5] = 33;
        }
// code added to display open sensor
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
}

void display_check(void)
{                                               

//inp,Pvos,cnt1,p,cyct,hys1,rng1,Lock,cnt2,hys2,rng2,cnt3,hys3,rng3                     
if (mode == 3) 
        {
        switch (item3)
                {
                case 0 : display_put(item3,param3[item3],2,message_param3,message_inp);
                        break;
                case 2 : display_put(item3,param3[item3],2,message_param3,message_cnt1);
                        break;
                case 8 : display_put(item3,param3[item3],2,message_param3,message_cnt2);
                        break;
                case 11 : display_put(item3,param3[item3],2,message_param3,message_cnt2);
                        break;
                default: display_put(item3,param3[item3],1,message_param3,dummy2);
                        break;
                }
        }

if (mode ==4)
        {
         switch (item4)
                {
                case 0 : display_put(item4,adc_data,1,message_param4,dummy2);
                        break;
                case 1 : display_put(item4,adc_data,1,message_param4,dummy2);
                        break;
                case 2 : display_put(item4,ambient_buffer,1,message_param4,dummy2);
                        break;
                }       
        
        
        }
}

void display_out(short int count2)
{
int asa;
clear_display();
asa = display_buffer[count2];
asa = segment_table[asa];
PORTB = asa;
//decimal point for upper display
if ((count2 == 2 || count2 == 6) && param3[0] ==0 && mode == 9)PORTB.3=0;
if (count2 ==6 && param3[0] ==0)
        {
        if (mode == 1 ) PORTB.3=0;
        if (mode == 3 && (item3 ==1 || item3 ==5 || item3 == 6 || item3 ==9 || item3 == 10 || item3 ==12 || item3 ==13)) PORTB.3 =0;
        if (mode == 0) PORTB.3=0;
        }
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
        case 8: PORTB = led_status; 
                digit9();
        break;
        }

if (mode ==9) display_put(process_value,set_value,0,dummy1,dummy2);
if (mode == 0) display_put(0,set_value,1,message_set,dummy2);
if (mode == 1) display_put(item1,param1[item1],1,message_param1,dummy2);
if (mode == 2) display_put(item2,param2[item2],1,message_param2,dummy2);

}

void key_find(void)
{
PORTC.5 =1;
PORTC.4 =1;
PORTC.3 =1;

set_key = ~PINC.5;
inc_key = ~PINC.4;
dec_key = ~PINC.3;
                 
}

void init()
{
/*/ Declare your local variables here

// Input/Output Ports initialization
// Port A initialization
// Func7=Out Func6=Out Func5=In Func4=In Func3=In Func2=In Func1=In Func0=In 
// State7=1 State6=1 State5=P State4=P State3=P State2=T State1=T State0=T */
PORTA=0xF8;
DDRA=0xC0;

/*/ Port B initialization
// Func7=Out Func6=Out Func5=Out Func4=Out Func3=Out Func2=Out Func1=Out Func0=Out 
// State7=1 State6=1 State5=1 State4=1 State3=1 State2=1 State1=1 State0=1 */
PORTB=0xFF;
DDRB=0xFF;

/*/ Port C initialization
// Func7=Out Func6=Out Func5=In Func4=In Func3=In Func2=Out Func1=Out Func0=Out 
// State7=1 State6=1 State5=T State4=T State3=T State2=1 State1=1 State0=1 */
PORTC=0x38;
DDRC=0xc7;

/*/ Port D initialization
// Func7=Out Func6=Out Func5=Out Func4=Out Func3=Out Func2=In Func1=Out Func0=in 
// State7=1 State6=1 State5=1 State4=1 State3=1 State2=T State1=1 State0=0 */
PORTD=0x13;
DDRD=0xFe;

/*// Timer/Counter 0 initialization
// Clock source: System Clock
// Clock value: Timer 0 Stopped
// Mode: Normal top=FFh
// OC0 output: Disconnected  */
TCCR0=0x00;
TCNT0=0x00;
OCR0=0x00;

/*/ Timer/Counter 1 initialization
// Clock source: System Clock
// Clock value: Timer 1 Stopped
// Mode: Normal top=FFFFh
// OC1A output: Discon.
// OC1B output: Discon.
// Noise Canceler: Off
// Input Capture on Falling Edge
// Timer 1 Overflow Interrupt: Off
// Input Capture Interrupt: Off
// Compare A Match Interrupt: Off
// Compare B Match Interrupt: Off  */
TCCR1A=0x00;
TCCR1B=0x00;
TCNT1H=0x00;
TCNT1L=0x00;
ICR1H=0x00;
ICR1L=0x00;
OCR1AH=0x00;
OCR1AL=0x00;
OCR1BH=0x00;
OCR1BL=0x00;

/*/ Timer/Counter 2 initialization
// Clock source: System Clock
// Clock value: Timer 2 Stopped
// Mode: Normal top=FFh
// OC2 output: Disconnected*/
ASSR=0x00;
TCCR2=0x00;
TCNT2=0x00;
OCR2=0x00;

/*/ External Interrupt(s) initialization
// INT0: Off
// INT1: Off
// INT2: Off*/
MCUCR=0x00;
MCUCSR=0x00;
// USART initialization
// Communication Parameters: 8 Data, 1 Stop, No Parity
// USART Receiver: On
// USART Transmitter: On
// USART Mode: Asynchronous
// USART Baud Rate: 9600
UCSRA=(0<<RXC) | (0<<TXC) | (0<<UDRE) | (0<<FE) | (0<<DOR) | (0<<UPE) | (0<<U2X) | (0<<MPCM);
UCSRB=(1<<RXCIE) | (1<<TXCIE) | (0<<UDRIE) | (1<<RXEN) | (1<<TXEN) | (0<<UCSZ2) | (0<<RXB8) | (0<<TXB8);
UCSRC=(1<<URSEL) | (0<<UMSEL) | (0<<UPM1) | (0<<UPM0) | (0<<USBS) | (1<<UCSZ1) | (1<<UCSZ0) | (0<<UCPOL);
UBRRH=0x00;
UBRRL=0x47;


// Timer(s)/Counter(s) Interrupt(s) initialization
TIMSK=0x00;

/*/ USART initialization
// Communication Parameters: 8 Data, 1 Stop, No Parity
// USART Receiver: On
// USART Transmitter: On
// USART Mode: Asynchronous
// USART Baud rate: 19200
//UCSRA=0x00;
//UCSRB=0xD8;
//UCSRC=0x86;
//UBRRH=0x00;
//UBRRL=0x23; */

/*/ Analog Comparator initialization
// Analog Comparator: Off
// Analog Comparator Input Capture by Timer/Counter 1: Off */
ACSR=0x80;
SFIOR=0x00;

/*/ ADC initialization
// ADC Clock frequency: 172.800 kHz
// ADC Voltage Reference: AREF pin
// ADC Auto Trigger Source: Free Running */
ADMUX=0x00;                             //select ambient value 
PORTA.2 =1;     //pullup for ambient diode
ADCSRA=0xAF;
SFIOR&=0x1F;

/*/ I2C Bus initialization
//i2c_init();

// DS1307 Real Time Clock initialization
// Square wave output on pin SQW/OUT: On
// Square wave frequency: 1Hz*/
//rtc_init(0,1,0);

// Global enable interrupts
#asm("sei")
ADCSRA |=(1<<6);     //set ADSC to start conversion
}

void ambient_cal(void)
{  
if ( ambient_raw >= adc_amb)
{
ambient_val = ambient_buffer + (ambient_raw - adc_amb)/16;
}
else
{
ambient_val = ambient_buffer - (adc_amb - ambient_raw)/16;
}
}

short int output_val(int pv, int sv, int pb)
{
short int err;
int t_err;
if (pv >= sv)
{
err =0;
}
else
{
t_err = sv - pv;
if (t_err > pb) 
    {
    err =255;
    }
else
    {
    err = t_err * 255 / pb ;
    }
}
return err;

} 


void relay1_logic()
{ 
if (!neg_fl && !open_sensor && config && calib)
{                             
if (param3[2] ==0)      //on/off action
        {
        if (process_value >=set_value) relay1 =1;
        if (process_value <= (set_value - param3[5])) relay1 =0;
        }
if (param3[2] ==1)
        {
        if (param3[0] ==0) p_error = output_val(process_value,set_value+param1[0],param3[3]*10);
        else  p_error = output_val(process_value,set_value+param1[0],param3[3]);
        }
}
else
relay1 =1;

}

void relay2_logic(void)
{
switch (param3[8])
        {
        case 0: if (process_value >= param1[1]) relay2 =1;              //heat logic
                if (process_value <= (param1[1]-param3[9])) relay2 =0;
                break;
        case 1: if (process_value <= param1[1]) relay2 =1;              //cool logic
                if (process_value >= (param1[1] +param3[9])) relay2 =0;
                break;
        case 2: if (process_value >= param1[1]) relay2 =0;              //Alarm  high logic
                if (process_value <= (param1[1]-param3[9])) relay2 =1;
                break;
        case 3: if (process_value <= param1[1]) relay2 =0;              //Alarm low logic
                if (process_value >= (param1[1] +param3[9])) relay2 =1;
                break;                                                             
        case 4: if (process_value >= (set_value+param1[1])) relay2 =0;            //deviation Alarm  high logic
                if (process_value <= (set_value+param1[1]-param3[9])) relay2 =1;
                break;
        case 5: if (process_value <= (set_value - param1[1])) relay2 =0;              //deviation Alarm low logic
                if (process_value >= (set_value - param1[1] +param3[9])) relay2 =1;
                break; 
        //deviation alarm -hi and alarm low logic combined                                                                           
        case 6: if ((process_value >= (set_value+param1[1])) || (process_value <= (set_value - param1[1]))) relay2 =0;
                if ((process_value <= (set_value+param1[1]-param3[9]))&&(process_value >= (set_value - param1[1] +param3[9]))) relay2 =1; 
        }

}
void relay3_logic(void)
{
switch (param3[11])
        {
        case 0: if (process_value >= param1[2]) relay3 =1;              //heat logic
                if (process_value <= (param1[2]-param3[12])) relay3 =0;
                break;
        case 1: if (process_value <= param1[2]) relay3 =1;              //cool logic
                if (process_value >= (param1[2] +param3[12])) relay3 =0;
                break;
        case 2: if (process_value >= param1[2]) relay3 =0;              //Alarm  high logic
                if (process_value <= (param1[2]-param3[12])) relay3 =1;
                break;
        case 3: if (process_value <= param1[2]) relay3 =0;              //Alarm low logic
                if (process_value >= (param1[2] +param3[12])) relay3 =1;
                break;                                                             
        case 4: if (process_value >= (set_value+param1[2])) relay3 =0;            //deviation Alarm  high logic
                if (process_value <= (set_value+param1[2]-param3[12])) relay3 =1;
                break;
        case 5: if (process_value <= (set_value - param1[2])) relay3 =0;              //deviation Alarm low logic
                if (process_value >= (set_value - param1[2] +param3[12])) relay3 =1;
                break; 
        //deviation alarm -hi and alarm low logic combined                                                                           
        case 6: if ((process_value >= (set_value+param1[2])) || (process_value <= (set_value - param1[2]))) relay3 =0;
                if ((process_value <= (set_value+param1[2]-param3[12]))&&(process_value >= (set_value - param1[2] +param3[12]))) relay3 =1; 
        }

}

void welcome_message(void)
{
display_buffer[0] = 21 ; 
display_buffer[1] = 1 ;
display_buffer[2] = 12 ;
display_buffer[3] = 25 ;
display_buffer[4] = 4 ;
display_buffer[5] = 3 ;
display_buffer[6] = 0 ;
display_buffer[7] = 8 ;
}



//modbus recieved frame processing.executed only when one frame is recieved. 
// to do: 
//1. verify crc
//2. split frame into data ,function code and address
//3. send appropriate response according to function code.
void process_modbus(void)
{
unsigned int i;
int j;
char response[9] = {slave_address,0x03,0x04,0x00,0x13,0x14,0x15,0x00,0x00};  // test response
i = CRC16(modbus_frame,6);
if (i == ((modbus_frame[7]*256)+modbus_frame[6])&& (modbus_frame[0] == slave_address))
{
switch (modbus_frame[1])
        {
        case 03: // read holding registers  
                response[3]= set_value/256;
                response[4]=set_value%256;
                response[5]= process_value/256;
                response[6]=process_value%256;
                i= CRC16(response,7);
                response[8]=(i/256);
                response[7]=(i%256);
                #asm("cli")
                transmit_fl =1;         // enable transmission
                for (j=0;j<9;j++)
                {
                putchar(response[j]);
                }
                #asm("sei")
                break;                 
        }



}




}







void main(void)
{ 
#asm("cli")
WDT_off(); 
init();
transmit_fl =0;    
eeprom_transfer();
//rtc_set_time (12,30,36);
welcome_message(); 
while (!first_time)
        {
        relay1 =1;
        relay2=1;
        relay3=1;
        ambient_cal();
        range_check();
        display_out(display_count);
        display_count++;
        if(display_count >=9) display_count =0;
        }  
        first_time=0;
display_put(param3[0],param3[6],1,message_inp,dummy2);
while (!first_time)

        {
        relay1 =1;
        relay2=1;
        relay3=1;
        ambient_cal();
        range_check();
        display_out(display_count);
        display_count++;
        if(display_count >=9) display_count =0;
        } 
        mode =9;        // reset mode to default
while (1)
      { 
        key_find();  
        led_check();
//        relay1_logic();
//        relay2_logic();
//        relay3_logic();
        if (modbus_fl) 
        {
        modbus_fl =0;
        process_modbus();
        }
        check_mode();
        ambient_cal();
        range_check();
        delay_counter++;
        if (delay_counter > speed_byte+1)               //speed byte will decrease every second in interrupt speeding the increment/decrement
        {
        delay_counter =0;
        check_increment();
        check_decrement();
        }
        check_enter();
        display_check();
        display_out(display_count);
        display_count++;
        if(display_count >=9) display_count =0;  
       // Place your code here                   
/*       rtc_get_time(&t_hour,&t_min,&t_sec);
        if(set_key) t_hour++;
        if(inc_key) t_min++;
        if(dec_key) t_sec++; 
        i = ((int)t_hour * 100)+ (int)t_min;
       j= (int)t_sec; 
*/        
       };
}

