
/*******************************************************
derived from mbscan3.c
date: 01-11-2019
reason: 
to add voltage and 4~20mA tables
to correct blinking issue
to add decimal point

date 04-10-2019
reason: to add menu routines
main menu: Scan time st,offset OSx8, skip/unskip x 8,alarm low x 8,alarm high x8,input x 8, modbus id,baudrate


derived from mbscan1.c
date: 2-10-2019
achieved:
*display and led scan 
*adc 3421 operating with mux scanning


todo
* scan display with chno. on bottom and pv on top. fixed scan time of 2 seconds









This program was created by the
CodeWizardAVR V3.12 Advanced
Automatic Program Generator
� Copyright 1998-2014 Pavel Haiduc, HP InfoTech s.r.l.
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

#define key1 PINB.2
#define key2 PINB.3
#define key3 PINB.4
#define key4 PINB.5
#define key5 PINB.2

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
short int display_scan_cnt;
                                  
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


//                              0     1     2   3    4    5    6    7     8    9   10    11   12   13   14   15   16   17   18   19   20   21   22   23   24   25   26   27   28   29   30   31   32   33  34  35
//                              0     1     2   3    4    5    6    7     8    9    a    b    c    d    e    f    g    h    j    k    l    m    n    o    p    r    t    u    w    y    -    8.   9.  BL   0.  -1
unsigned char segment_table[]= {0x84,0xf5,0xc2,0xc1,0xb1,0x89,0x88,0xe5,0x80,0x81,0xa0,0x98,0x8e,0xd0,0x8a,0xaa,0x8c,0xb0,0xd5,0xa8,0x9e,0xe8,0xf8,0xd8,0xa2,0xfa,0x9a,0xdc,0xcc,0x91,0xfb,0x00,0x01,0xff,0x04,0xf1};
bit blink_flag,blinking,qsecfl,tsec_fl,hsec_fl;
short int blink_digit;
short int mux_scan,tsec_cnt;

//key routine map          

short int key_count;
bit key1_old,key2_old,key3_old,key4_old;
bit menu_fl;
short int menu_count,item1,item2;
short int level;    //level  = 0,1,2 sub level 
short int item1,item2;  // item 1 has common parameters st/id/baudrate
//menu text
short int ms_menu[]={21,14,22,27};
//menu message
//gen,os,skip,r-lo,r-hi,a-lo,a-hi,inp
short int message_menu[] = {33,16,14,22,33,33,23,05,05,19,01,24,25,30,20,23,25,30,17,01,10,30,20,23,10,30,17,01,33,01,22,24,33,33,13,24};
//st,id,baud
short int message_gen[]={33,33,5,26,33,33,1,13,11,10,27,13};
//os-1,os-2.....os-8
short int message_os[]={23,5,30,1,23,5,30,2,23,5,30,3,23,5,30,4,23,5,30,5,23,5,30,6,23,5,30,7,23,5,30,8};
//sk-1,sk-2.....sk-8
short int message_skip[]={05,19,30,01,05,19,30,02,05,19,30,03,05,19,30,04,05,19,30,05,05,19,30,06,05,19,30,07,05,19,30,8};
//rl-1,rl-2....rl-8
short int message_rlow[]={25,20,30,01,25,20,30,02,25,20,30,03,25,20,30,04,25,20,30,05,25,20,30,06,25,20,30,07,25,20,30,8};
//rh-1...rh-8
short int message_rhigh[]={25,17,30,01,25,17,30,02,25,17,30,03,25,17,30,04,25,17,30,05,25,17,30,06,25,17,30,07,25,17,30,8};
//al-1.....al-8
short int message_alow[]={10,20,30,01,10,20,30,02,10,20,30,03,10,20,30,04,10,20,30,05,10,20,30,06,10,20,30,07,25,20,30,8};
//ah-1...ah-8
short int message_ahigh[]={10,17,30,01,10,17,30,02,10,17,30,03,10,17,30,04,10,17,30,05,10,17,30,06,10,17,30,07,10,17,30,8};
//in-1....in-8
short int message_in[]={01,22,30,01,01,22,30,02,01,22,30,03,01,22,30,04,01,22,30,05,01,22,30,06,01,22,30,07,01,22,30,8};
//dp-1....dp-8
short int message_dp[]={13,24,30,1,13,24,30,2,13,24,30,3,13,24,30,4,13,24,30,5,13,24,30,6,13,24,30,7,13,24,30,8};



//sub menu messages for skip/unskip,input
//unsk/skip
short int message_skuk[]={27,22,05,19,05,19,01,24};
//pt1,pt2,j,k,r,s,t,volt,4~20
short int message_inp[]={33,24,26,01,33,24,26,02,33,33,33,18,33,33,33,19,33,33,33,25,33,33,33,05,33,33,33,26,27,23,20,26,4,30,2,0};
short int message_baud[]={33,32,6,19,1,32,2,19};  // 9.6k and 19.2k
short int message_cal[]={12,20,30,01,12,20,30,02,12,20,30,03,12,20,30,04,12,20,30,05,12,20,30,06,12,20,30,07,12,20,30,8};
short int message_dp1[]={34,0,0,1,0,34,0,1,0,0,34,1,0,0,0,1}; //0.001,00.01,000.1,0001

bit cal_fl;     //calibration mode flag;



// end of key routine parameters map/////

int table_p[]={-8388,-6176,-4054,-2000,0,1955,3870,5730,7554,9335,11075,12775,14432,16052,17635,19171,20685,22158};
int table_j[]={0,2585,5269,8010,10779,13555,16327,19090,21848,24610,27393,30216,33102,36071,39132};
int table_k[]={0,2023,4096,6138,8138,10153,12209,14293,16397,18516,20644,22776,24905,27025,29129,31213,33275,35313,37326,39314,41276,43211,45119,46995,48838,50644,52410,54138};
int table_r[]={0,296,647,1041,1469,1923,2401,2896,3408,3933,4471,5021,5583,6157,6743,7340,7950,8571,9205,9850,10506,11173,11850,12535,13228,13926,14629,15334,16040,16746,17451,18152,18849,19540,20222,20877};
int table_s[]={0,299,646,1029,1441,1874,2323,2786,3259,3742,4233,4732,5239,5753,6275,6806,7345,7893,8449,9014,9587,10168,10757,11351,11951,12554,13159,13766,14373,14978,15582,16182,16777,17366,17947,18503};
int table_t[]={0,2036,4279,6704,9288,12013,14862,17819};

//memory map
int gen[8];
eeprom int ee_gen[8]={1,1,0,0,0,0,0,0};
int os[8];
eeprom int ee_os[8]={0,0,0,0,0,0,0,0};
int skip[8];
eeprom int ee_skip[8]={0,0,0,0,0,0,0,0};
int rlow[8];
eeprom int ee_rlow[8]={0,0,0,0,0,0,0,0};
int rhigh[8];
eeprom int ee_rhigh[8]={100,100,100,100,100,100,100,100};
int alow[8];
eeprom int ee_alow[8]={0,0,0,0,0,0,0,0};
int ahigh[8];
eeprom int ee_ahigh[8]={100,100,100,100,100,100,100,100};
int input[8];
eeprom int ee_input[8]={0,0,0,0,0,0,0,0};
int dp[8];
eeprom int ee_dp[8]={0,0,0,0,0,0,0,0};

int cal_zero[8];
eeprom int ee_cal_zero[8]={10300,10300,10300,10300,10300,10300,10300,10300};
int cal_span[8];
eeprom int ee_cal_span[8]={21300,21300,21300,21300,21300,21300,21300,21300};



 void adc3421_init(void)
{                      
i2c_start();
i2c_write(0xd2);
delay_ms(1);
//i2c_write(0x9f);   //18 bit mode 8v/v
i2c_write(0x98);        //16 bit 1v/v         
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


int linearise_p(float a,float zero_tc,float span_tc)
{
int number =0;
int count;
int b=0;
long int temp=0;
float temp1=0;
int true_value = 0;

temp1 = ((a - zero_tc) /(span_tc - zero_tc)) * 11075;    //adc value of 300 deg. is 11075 in table_p
b = (int)temp1;

for (count=0;count <= 18; count++)  
    {
    if (b>table_p[count] && b <= table_p[count+1])    
        {
        number = count;
        break;
        }
    }

temp = ((500*(temp1-(float)table_p[number]))/((float)table_p[number+1] - (float)table_p[number]))+ ((long)(number-4) * 500);
true_value = (int) temp;
return (true_value);
}


int linearise_tc(float a,float zero_tc,float span_tc,int iter,int* tabletc)
{
int number =0;
int count;
int b=0;
long int temp=0;
float temp1=0;
int true_value = 0;

temp1 = ((a - zero_tc)*50000 /(span_tc - zero_tc));    //adc value of 300 deg. is 11075 in table_p
b = (int)temp1;

for (count=0;count <= iter; count++)  
    {
    if (b> *(tabletc+count) && b <= *(tabletc+count+1))    
        {
        number = count;
        break;
        }
    }

temp = (50 * (temp1 - *(tabletc+number))/( *(tabletc+number+1) - *(tabletc+number))) + ((long)number*50) ;


//temp = ((500*(temp1-(float)table_p[number]))/((float)table_p[number+1] - (float)table_p[number]))+ ((long)(number-4) * 500);
true_value = (int) temp;
return (true_value);
}




void increment_value(int* value,int low_limit,int high_limit,short int power)
{
int a;
int b=1;
for (a=0;a<power;a++) b = b*10;
*value = *value + b;
if (*value < low_limit) *value = low_limit;
if (*value >= high_limit) *value = high_limit;
} 

void decrement_value(int* value,int low_limit,int high_limit,short int power)
{
int a;
int b=1;
for (a=0;a<power;a++) b = b*10;
*value = *value- b;
if (*value < low_limit) *value = low_limit;
if (*value >= high_limit) *value = high_limit;
} 


void escape_menu(void)
{
menu_fl =0;
level=0;
item1=item2=0;
blinking=0;
blink_digit=0;
blink_flag =0;

}


void check_set(void)
{
if (!key5)
    {
    menu_count++;
    if (menu_count >=4)
        {
        menu_count =0;
        if(!menu_fl)
            {
            menu_fl =1;
            level =1;
            item1=item2=0;
            blink_digit =0;
            blink_flag=1;
            }
        else if (menu_fl)
            {
            escape_menu();
            }
        }
    }
else
    menu_count =0;
}


void ent_key(void)
{
short int i;
if (menu_fl && !cal_fl)
    {
    blink_digit =0;
    
    if (level ==1)
        {
        level =2;
        item2 =0;
        }
    else if (level==2)
        {           
        item2++;
        switch (item1)
            {
            case 0: if (item2 >= 3) 
                    {
                    item2 =0;       //general parameters st/mb id ,baud
                    level =1;       // return to level 1        
                    for(i=0;i<=3;i++)
                        {
                        ee_gen[i] = gen[i]; //store in eeprom
                        } 
                    }                     
                    break;            
            case 1: if (item2 >= 8) 
                    {
                    item2 =0;       //offset
                    level =1;       // return to level 1
                    for(i=0;i<=8;i++)
                        {
                        ee_os[i] = os[i]; //store in eeprom
                        } 
                    
                    }                     
                    break;            
            case 2: if (item2 >= 8) 
                    {
                    item2 =0;       //skip
                    level =1;       // return to level 1
                    for(i=0;i<=8;i++)
                        {
                        ee_skip[i] = skip[i]; //store in eeprom
                        } 

                    }                     
                    break;            
            case 3: if (item2 >= 8) 
                    {
                    item2 =0;       //rlow
                    level =1;       // return to level 1
                    for(i=0;i<=8;i++)
                        {
                        ee_rlow[i] = rlow[i]; //store in eeprom
                        } 

                    }                     
                    break;            
            case 4: if (item2 >= 8) 
                    {
                    item2 =0;       //rhigh
                    level =1;       // return to level 1
                    for(i=0;i<=8;i++)
                        {
                        ee_rhigh[i] = rhigh[i]; //store in eeprom
                        } 

                    }                     
                    break;            
            case 5: if (item2 >= 8) 
                    {
                    item2 =0;       //alow
                    level =1;       // return to level 1
                    for(i=0;i<=8;i++)
                        {
                        ee_alow[i] = alow[i]; //store in eeprom
                        } 

                    }                     
                    break;            
            case 6: if (item2 >= 8) 
                    {
                    item2 =0;       //ahigh
                    level =1;       // return to level 1
                    for(i=0;i<=8;i++)
                        {
                        ee_ahigh[i] = ahigh[i]; //store in eeprom
                        } 

                    }                     
                    break;            
            case 7: if (item2 >= 8) 
                    {
                    item2 =0;       //input
                    level =1;       // return to level 1
                    for(i=0;i<=8;i++)
                        {
                        ee_input[i] = input[i]; //store in eeprom
                        } 

                    }                     
                    break;        
            case 8: if (item2 >= 8) 
                    {
                    item2 =0;       //input
                    level =1;       // return to level 1
                    for(i=0;i<=8;i++)
                        {
                        ee_dp[i] = dp[i]; //store in eeprom
                        } 

                    }                     
                    break;         
      
            
            }
        }

    else 
        {
        escape_menu();
        }
    }
    else if (cal_fl)
        {
        mux_scan++;
        if (mux_scan>=8) mux_scan=0;
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
}

void inc_key(void)
{
if (menu_fl && !cal_fl)
    {
    if (level ==1)
        {
        item1 ++;
        if (item1>=9) item1 =0;
        }
    else if (level ==2)
        {
        switch (item1)
            {
            case 0: if (item2==0) increment_value(&gen[0],0,99,0);  //scan time
                    if(item2 ==1) increment_value(&gen[1],1,242,blink_digit);//modbus id
                    if (item2==2) increment_value(&gen[2],0,1,0);   //baud rates 9600/19200
                    break;
            case 1: increment_value(&os[item2],-999,999,blink_digit);   //offset
                    break;
            case 2: increment_value(&skip[item2],0,1,0);    //skip
                    break;
            case 3: increment_value(&rlow[item2],-999,1999,blink_digit);    //rlow
                    break;
            case 4: increment_value(&rhigh[item2],-999,1999,blink_digit);   //rhigh
                    break;
            case 5: increment_value(&alow[item2],-999,1999,blink_digit);    //alow
                    break;
            case 6: increment_value(&ahigh[item2],-999,1999,blink_digit);   //ahigh
                    break;
            case 7: increment_value(&input[item2],0,8,0);     //input selection
                    break;   
            case 8: if (input[item2]<7)
                        increment_value(&dp[item2],3,3,0);       //decimal point selection for temperature
                    else
                        increment_value(&dp[item2],0,3,0);       //decimal point selection for voltage and current
                    break;
            default:escape_menu();
                    break;            
            }        
        }
    
    
    
    }
else if (cal_fl)         //zero setting for all 8 channels
    {
    cal_zero[mux_scan]=adc3421_read();
    ee_cal_zero[mux_scan]= cal_zero[mux_scan];
    }
}

void dec_key(void)
{
if (menu_fl &&!cal_fl)
    {
    if (level ==1)
        {
        item1 --;
        if (item1<0) item1 =8;
        }
    else if (level ==2)
        {
        switch (item1)
            {
            case 0: if (item2==0) decrement_value(&gen[0],0,99,0);  //scan time
                    if(item2 ==1) decrement_value(&gen[1],1,242,blink_digit);//modbus id
                    if (item2==2) decrement_value(&gen[2],0,1,0);   //baud rates 9600/19200
                    break;
            case 1: decrement_value(&os[item2],-999,999,blink_digit);   //offset
                    break;
            case 2: decrement_value(&skip[item2],0,1,0);    //skip
                    break;
            case 3: decrement_value(&rlow[item2],-999,1999,blink_digit);    //rlow
                    break;
            case 4: decrement_value(&rhigh[item2],-999,1999,blink_digit);   //rhigh
                    break;
            case 5: decrement_value(&alow[item2],-999,1999,blink_digit);    //alow
                    break;
            case 6: decrement_value(&ahigh[item2],-999,1999,blink_digit);   //ahigh
                    break;
            case 7: decrement_value(&input[item2],0,8,0);     //input selection
                    break;
            case 8: if (input[item2]<7)
                        decrement_value(&dp[item2],3,3,0);       //decimal point selection for temperature
                    else
                        decrement_value(&dp[item2],0,3,0);       //decimal point selection for voltage and current
                    break;

            default:escape_menu();
                    break;            
            }        
        }
    
    
    
    }
else if (cal_fl)
    {
    cal_span[mux_scan]=adc3421_read();
    ee_cal_span[mux_scan] = cal_span[mux_scan];
    }
}

void shf_key(void)
{
    if (blink_flag)
    blink_digit++;
    if (blink_digit > 3)
    blink_digit=0;
}

// Timer1 overflow interrupt service routine
interrupt [TIM1_OVF] void timer1_ovf_isr(void)
{
// Reinitialize Timer1 value
TCNT1H=0xABA0 >> 8;
TCNT1L=0xABA0 & 0xff;
// Place your code here
qsecfl = ~qsecfl;
hsec_fl =1;
blinking = ~blinking;
tsec_cnt++;
if (tsec_cnt >=4)
    {
    tsec_fl =1;
    tsec_cnt =0;
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


void pv_update(void)
{
int adc_value;
if (!cal_fl)
{
adc_value=adc3421_read();
//process_value[mux_scan] = ((long)adc_value -(long)cal_zero[mux_scan]) * 10000 / ((long)cal_span[mux_scan]- (long)cal_zero[mux_scan]);
switch (input[mux_scan])
    {
    case 0: process_value[mux_scan] = linearise_p(adc_value,cal_zero[mux_scan],cal_span[mux_scan]);
            break;
    case 1: process_value[mux_scan] = linearise_p(adc_value,cal_zero[mux_scan],cal_span[mux_scan])/10;
            break;
    case 2: process_value[mux_scan] = linearise_tc(adc_value,cal_zero[mux_scan],cal_span[mux_scan],15,table_j);
            break;
    case 3: process_value[mux_scan] = linearise_tc(adc_value,cal_zero[mux_scan],cal_span[mux_scan],28,table_k);
            break;
    case 4: process_value[mux_scan] = linearise_tc(adc_value,cal_zero[mux_scan],cal_span[mux_scan],36,table_r);
            break;
    case 5: process_value[mux_scan] = linearise_tc(adc_value,cal_zero[mux_scan],cal_span[mux_scan],36,table_s);
            break;
    case 6: process_value[mux_scan] = linearise_tc(adc_value,cal_zero[mux_scan],cal_span[mux_scan],8,table_t);
            break;
    }





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
}

void display_put(int up_display, int low_display,int status,short int* message1,short int* message2)
{
if (status ==0) 
        {
        if (up_display <0 && up_display > -1000)
        {                
        up_display = -up_display;
        up_display%=1000;
        display_buffer[0]= 30;
        }
        else if (up_display <=-1000)
        {
        up_display = -up_display;
        up_display%=1000;
        display_buffer[0]= 35;
        
        
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
        display_buffer[4]= 30;
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
        display_buffer[4]= 30;
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
int adc_value;
if(!menu_fl && !cal_fl)
    {
    if (tsec_fl)
        {
        tsec_fl =0;
        display_scan_cnt++;
        if (display_scan_cnt >=5) display_scan_cnt =0;
        display_put(process_value[display_scan_cnt],display_scan_cnt+1,0,dummy,dummy2);
        }
    }

else if (menu_fl && !cal_fl)
    {
    if (level ==1)
        {
        display_put(0,item1,2,ms_menu,message_menu);
        }
    else if (level ==2)
        {
        switch (item1)
            {
            case 0: if (item2==0) display_put(0,gen[0],1,message_gen,dummy); //st
                    if (item2==1) display_put(1,gen[1],1,message_gen,dummy);
                    if (item2==2) display_put(2,gen[2],2,message_gen,message_baud);
                    break;
            case 1: display_put(item2,os[item2],1,message_os,dummy);
                    break;
            case 2: display_put(item2,skip[item2],2,message_skip,message_skuk);
                    break;
            case 3: display_put(item2,rlow[item2],1,message_rlow,dummy);
                    break;
            case 4: display_put(item2,rhigh[item2],1,message_rhigh,dummy);
                    break;
            case 5: display_put(item2,alow[item2],1,message_alow,dummy);
                    break;
            case 6: display_put(item2,ahigh[item2],1,message_ahigh,dummy);
                    break;
            case 7: display_put(item2,input[item2],2,message_in,message_inp);
                    break;
            case 8: display_put(item2,dp[item2],2,message_dp,message_dp1); 
            
            }
        
        }    
    
    
    
    
    }
else if (cal_fl)
    { 
    adc_value = adc3421_read();
    display_put(mux_scan,adc_value,1,message_cal,dummy);
    }
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
// logic to display decimal point
switch (count2)
    {
    case 0: if (!menu_fl && !cal_fl )
                {
                if (dp[display_scan_cnt] ==0) PORTA.7 =0;                
                }
            break;
    case 1: if (!menu_fl && !cal_fl )
                {
                if (dp[display_scan_cnt] ==1) PORTA.7 =0;                
                }
            break;          
    case 2: if (!menu_fl && !cal_fl )
                {
                if (dp[display_scan_cnt] ==2) PORTA.7 =0;                
                }
            break;          
    case 4: if (menu_fl && !cal_fl && (level ==2))
                {
                if ((dp[item2] ==0) && ((item1==1)||(item1==3)||(item1==4)||(item1 ==5)||(item1==6))) PORTA.7=0;
                }
            break;                    
    case 5: if (menu_fl && !cal_fl && (level ==2))
                {
                if ((dp[item2] ==1)&& ((item1==1)||(item1==3)||(item1==4)||(item1 ==5)||(item1==6))) PORTA.7=0;
                }
            break;                   
    case 6: if (menu_fl && !cal_fl && (level ==2))
                {
                if ((dp[item2] ==2)&& ((item1==1)||(item1==3)||(item1==4)||(item1 ==5)||(item1==6))) PORTA.7=0;
                }
            break;                  
                
                
    }





////end of decimal point logic

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

//display_put(process_value[0],process_value[1],0,dummy,dummy2);                       //**


}



void key_check()
{
     key1 = key2 = key3 = key4 = 1;
      key_count++;
 if (key_count >=100)
    { 
      key_count=0;     
      if (!key1 && key1_old)ent_key();
      if (!key2 && key2_old)inc_key();
      if (!key3 && key3_old)dec_key();
      if (!key4 && key4_old)shf_key();
      key1_old = key1;
      key2_old = key2;
      key3_old = key3;
      key4_old = key4;
     } 
}

void eeprom_transfer(void)
{
short int i;
for(i=0;i<=8;i++)
    {
    cal_zero[i] = ee_cal_zero[i];
    } 
for(i=0;i<=8;i++)
    {
    cal_span[i] = ee_cal_span[i];
    } 
for(i=0;i<=3;i++)
    {
    gen[i] = ee_gen[i];
    } 
for(i=0;i<=8;i++)
    {
    os[i] = ee_os[i];
    } 
for(i=0;i<=8;i++)
    {
    skip[i] = ee_skip[i];
    } 
for(i=0;i<=8;i++)
    {
    rlow[i] = ee_rlow[i];
    } 
for(i=0;i<=8;i++)
    {
    rhigh[i] = ee_rhigh[i];
    } 
for(i=0;i<=8;i++)
    {
    alow[i] = ee_alow[i];
    } 
for(i=0;i<=8;i++)
    {
    ahigh[i] = ee_ahigh[i];
    } 
for(i=0;i<=8;i++)
    {
    input[i] = ee_input[i];
    } 

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
eeprom_transfer();

cal_fl =0;
if (!key5) cal_fl =1;

while (1)
      {
      // Place your code here
      display_check();
      display_out(display_count);
      display_count++; 
 //     led_check();   
             key_check();

      if(display_count >=10) 
      {
       display_count =0;
       if (hsec_fl)
        {
        hsec_fl =0;
        pv_update();  
        check_set();  
        }
      }
//      process_value[0] =1234;
//      process_value[1] = 5678; 
      }
}
