
/*******************************************************
date: 25-02-2020
reason: to add dp in function code 4 along with PV so that it can be scanned and displayed along with 
decimal point by PC software
delay change from 20mS to 50mS


date: 26-11-2019
derived from mbscan9.c
reason:
*to add preset single register function in modbus.
function code 06


date: 16-11-2019
derived from mbscan8.c
todo:
* add other functions to modbus protocol
    04  ---read input register
    16  ---preset multiple register
    
* limit the no. of registers read to 16 bytes. if more, than return only 16
* add tick timer to timeout error request.. timeout is 1 second and poll timeout is 20ms
* add scan time logic
* add scan/hold logic
*add open sensor status
* add predefined code to channels for open/underrange/skip status in modbus transmission
        underrange ---- 0xbbbb hex
        overrange ------0xcccc hex
        skipped   ------0xdddd hex
        


date 11-11-2019
derived from mbscan7.c
reason: to add modbus




date: 06-11-2019
derived from mbscan6.c
todo:
*add 4~20ma linearisation
*add voltage linearisation
add offset
add skip status to relay and led logic
skip channel 8 if thermocouple selected on any channel and collect ch8 data for ambient calculation
ambient calibration temp value in rhi-8
add ambient compensation to thermocouples



derived from mbscan4.c
to do:
*add led logic
*add decimal point for pt100 0.1
*add relay logic and link to led status
*add common relay logic
*add range limits for thermocouple and pt100
*add skip status
*eeprom store and retrieve dp status.
*add serial speed


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
bit modbus_fl;      // recieved modbus flag
                                  
#define all_led_off() led_status = 0xff;             //red led status
#define rled3_on() led_status &= 0xfe
#define rled2_on() led_status &= 0xfd
#define rled1_on() led_status &= 0xfb
#define rled4_on() led_status &= 0xf7
#define rled5_on() led_status &= 0xef
#define rled6_on() led_status &= 0xdf
#define rled7_on() led_status &= 0xbf
#define rled8_on() led_status &= 0x7f
#define rled3_off() led_status |= 0x01
#define rled2_off() led_status |= 0x02
#define rled1_off() led_status |= 0x04
#define rled4_off() led_status |= 0x08
#define rled5_off() led_status |= 0x10
#define rled6_off() led_status |= 0x20
#define rled7_off() led_status |= 0x40
#define rled8_off() led_status |= 0x80

#define all_led_off1() led_status1 = 0xff;             //red led status
#define gled3_on() led_status1 &= 0xfe
#define gled2_on() led_status1 &= 0xfd
#define gled1_on() led_status1 &= 0xfb
#define gled4_on() led_status1 &= 0xf7
#define gled5_on() led_status1 &= 0xef
#define gled6_on() led_status1 &= 0xdf
#define gled7_on() led_status1 &= 0xbf
#define gled8_on() led_status1 &= 0x7f
#define gled3_off() led_status1 |= 0x01
#define gled2_off() led_status1 |= 0x02
#define gled1_off() led_status1 |= 0x04
#define gled4_off() led_status1 |= 0x08
#define gled5_off() led_status1 |= 0x10
#define gled6_off() led_status1 |= 0x20
#define gled7_off() led_status1 |= 0x40
#define gled8_off() led_status1 |= 0x80

#define mb_dir  PORTD.2



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
int ambient_val;
bit tc_fl;






















// USART Receiver buffer
#define RX_BUFFER_SIZE 20
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
char mbreceived_data[10];

// This flag is set on USART Receiver buffer overflow
bit rx_buffer_overflow;

// USART Receiver interrupt service routine
interrupt [USART_RXC] void usart_rx_isr(void)
{
char status,data,i;
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
if (rx_counter==1)
    {
    if (rx_buffer[0] != (char)(gen[1]))
        rx_counter = rx_wr_index =0;    //reset frame till first byte matchs slave address
    }   
else
    {
    // valid slave address.allot frame size according to function code. 
    if (rx_counter >=8)
      {
    //modbus frame complete. transfer data to mbreceived_data[]   
        for (i=0;i<8;i++)
        {
        mbreceived_data[i] = rx_buffer[i];
        }
        rx_counter = rx_wr_index =0;        //reset counter to start for next frame
        modbus_fl =1;                       // set flag to indicate frame recieved in main routine.
//        mb_dir =1;      //ready for transmit
      }
    }   
   
   
//////////////////////////////////

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

// Standard Input/Output functions
#include <stdio.h>
#include <delay.h>


//                              0     1     2   3    4    5    6    7     8    9   10    11   12   13   14   15   16   17   18   19   20   21   22   23   24   25   26   27   28   29   30   31   32   33  34  35   36
//                              0     1     2   3    4    5    6    7     8    9    a    b    c    d    e    f    g    h    j    k    l    m    n    o    p    r    t    u    w    y    -    8.   9.  BL   0.  -1   5.
unsigned char segment_table[]= {0x84,0xf5,0xc2,0xc1,0xb1,0x89,0x88,0xe5,0x80,0x81,0xa0,0x98,0x8e,0xd0,0x8a,0xaa,0x8c,0xb0,0xd5,0xa8,0x9e,0xe8,0xf8,0xd8,0xa2,0xfa,0x9a,0xdc,0xcc,0x91,0xfb,0x00,0x01,0xff,0x04,0xf1,0x09};
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
short int message_alow[]={10,20,30,01,10,20,30,02,10,20,30,03,10,20,30,04,10,20,30,05,10,20,30,06,10,20,30,07,10,20,30,8};
//ah-1...ah-8
short int message_ahigh[]={10,17,30,01,10,17,30,02,10,17,30,03,10,17,30,04,10,17,30,05,10,17,30,06,10,17,30,07,10,17,30,8};
//in-1....in-8
short int message_in[]={01,22,30,01,01,22,30,02,01,22,30,03,01,22,30,04,01,22,30,05,01,22,30,06,01,22,30,07,01,22,30,8};
//dp-1....dp-8
short int message_dp[]={13,24,30,1,13,24,30,2,13,24,30,3,13,24,30,4,13,24,30,5,13,24,30,6,13,24,30,7,13,24,30,8};

//process error byte: 0: normal,1: underrange,2: overrange,3: skip
short int process_error[8];    


//sub menu messages for skip/unskip,input
//unsk/skip
short int message_skuk[]={27,22,05,19,05,19,01,24};
//pt1,pt2,j,k,r,s,t,volt,4~20
short int message_inp[]={33,24,26,01,33,24,26,02,33,33,33,18,33,33,33,19,33,33,33,25,33,33,33,05,33,33,33,26,27,23,20,26,4,30,2,0};
short int message_baud[]={33,32,6,19,1,32,2,19,03,31,04,19,01,01,36,02};  // 9.6k,19.2k,38.4k,115.2
short int message_cal[]={12,20,30,01,12,20,30,02,12,20,30,03,12,20,30,04,12,20,30,05,12,20,30,06,12,20,30,07,12,20,30,8};
short int message_dp1[]={34,0,0,1,0,34,0,1,0,0,34,1,0,0,0,1}; //0.001,00.01,000.1,0001
short int message_neg[]={30,30,30,30}; //----
short int message_open[]={01,33,33,33}; //1     

bit cal_fl,ser_fl,hold_fl;     //calibration mode flag;


// end of key routine parameters map/////

int table_p[]={-8388,-6176,-4054,-2000,0,1955,3870,5730,7554,9335,11075,12775,14432,16052,17635,19171,20685,22158,24000};
unsigned int table_j[]={0,258,527,801,1078,1356,1633,1909,2185,2461,2739,3022,3310,3607,3913};
unsigned int table_k[]={0,202,410,614,814,1015,1221,1430,1640,1852,2064,2278,2491,2703,2913,3121,3328,3531,3733,3931,4128,4321,4512,4700,4884,5064,5241,5414};
//unsigned int table_k[]={0,184,392,597,797,1000,1206,1415,1626,1839,2052,2266,2480,2693,2903,3112,3319,3524,3726,3925,4121,4316,4507,4696,4880,5061,5238,5412};
//unsigned int table_j[]={0,239,509,784,1062,1339,1619,1895,2172,2449,2729,3012,3301,3600,3906};

//unsigned int table_r[]={0,296,647,1041,1469,1923,2401,2896,3408,3933,4471,5021,5583,6157,6743,7340,7950,8571,9205,9850,10506,11173,11850,12535,13228,13926,14629,15334,16040,16746,17451,18152,18849,19540,20222,20877};
//unsigned int table_s[]={0,299,646,1029,1441,1874,2323,2786,3259,3742,4233,4732,5239,5753,6275,6806,7345,7893,8449,9014,9587,10168,10757,11351,11951,12554,13159,13766,14373,14978,15582,16182,16777,17366,17947,18503};
//unsigned int table_t[]={0,204,428,670,929,1201,1486,1782};
unsigned int table_r[]={0,296,647,1041,1469,1923,2401,2896,3408,3933,4471,5021,5583,6157,6743,7340,7950,8571,9205,9850,10506,11173,11850,12535,13228,13926,14629,15334,16040,16746,17451,18152,18849,19540,20222,20877};
unsigned int table_s[]={0,299,646,1029,1441,1874,2323,2786,3259,3742,4233,4732,5239,5753,6275,6806,7345,7893,8449,9014,9587,10168,10757,11351,11951,12554,13159,13766,14373,14978,15582,16182,16777,17366,17947,18503};
unsigned int table_t[]={0,204,428,670,929,1201,1486,1782};


///////////////////////MODBUS CODES /////////////////////////





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

int mb_data[57];
int mb_inputdata[21];
//function  codes
#define mbreadholdingregisters  3
#define mbreadinputregisters    4
#define mb presetmultipleregisters 16
#define mbreportslaveid  17

//error codes
#define mbillegalfunction 1
#define mbillegaldataaddress 2
#define mbillegaldatavalue 3
#define mbslavedevicefailure 4
#define mbacknowledge 5
#define mbslavedevicebusy 6
#define mbnegativeacknowledge 7
#define mbmemoryparityerror 8



void mbreset()
{

    rx_counter=0;
    rx_rd_index=0;
    rx_rd_index =0;
    tx_counter =0;
    tx_wr_index =0;
    tx_rd_index =0;
}


//map
//40001 - 8    process_Value
//40009-16   al-hi
//40017-24   al-lo
//40018-32    r-hi
//40033-40   r-lo
void mb_datatransfer()
{
short int i,count =0;
for (i =0;i<8;i++)
    {
    mb_data[count] = os[i];
    count++;
    }
for (i =0;i<8;i++)
    {
    mb_data[count] = skip[i];
    count++;
    }       
for (i =0;i<8;i++)
    {
    mb_data[count] = ahigh[i];
    count++;
    }
for (i =0;i<8;i++)
    {
    mb_data[count] = alow[i];
    count++;
    }
for (i =0;i<8;i++)
    {
    mb_data[count] = rhigh[i];
    count++;
    }     
for (i =0;i<8;i++)
    {
    mb_data[count] = rlow[i];
    count++;
    }    
for (i =0;i<8;i++)
    {
    mb_data[count] = dp[i];
    count++;
    }
mb_data[count] = gen[0];        //scan time
//end of holding register transfer
//start of input register(read only) data
count=0;
for (i =0;i<8;i++)
    {
    switch (process_error[i])
    {  
    case 0: mb_inputdata[count] = process_value[i];
            break;
    case 1: mb_inputdata[count] = 20000;       //overrange
            break;
    case 2: mb_inputdata[count] = 22000;      //underrange
            break;
    default:mb_inputdata[count] = process_value[i];
            break;
    }
    if (skip[i] ==1) mb_inputdata[count] =24000;
    count++;
    }
for (i =0;i<8;i++)
    {
    mb_inputdata[count] = input[i];
    count++;
    }
for (i =0;i<8;i++)
    {
    mb_inputdata[count] = dp[i];
    count++;
    }

mb_inputdata[count] = gen[1];       //slave ID
count++;
mb_inputdata[count] = gen[2];       //baud rate
count++;
mb_inputdata[count] = ~led_status;       //bitwise status of alarm high of individual channels
count++;
mb_inputdata[count] = ~led_status1;       //bitwise status of alarm high of individual channels
count++;
}


//used for function code 06. write single register.
//checks the address to be written,if valid,writes to the address and returns 0,else returns 1
short int mblimitcheck(int address,int value)
{
int min[8],max[8],i;
short int ok_st=1;
//update min max values according to input
for (i=0;i<8;i++)
    {
    switch (input[i])
        {
        case 0: min[i] = -1999  ;
                max[i] = 7000  ;
                break;
        case 1: min[i] =-199  ;
                max[i] =700  ;
                break;
        case 2: min[i] =0  ;
                max[i] =700  ;
                break;
        case 3: min[i] =0  ;
                max[i] =1300  ;
                break;
        case 4: 
        case 5: min[i] =0  ;
                max[i] =1700  ;
                break;
        case 6: min[i] =0  ;
                max[i] =350  ;
                break;
        case 7: 
        case 8: min[i] =rlow[i] - (rlow[i]*20/100);
                max[i] =rhigh[i]+ (rhigh[i]*20/100);
                break;
        }
    
    }

//offset range check
if (address <=7)    
    {
    if (value >=-999 && value <= 999)
        {
        ee_os[address] = os[address] = value;
        ok_st =0;
        }
    }
// skip status check
else if (address>=8 && address <=15)
    {
    if (value >=0 && value <= 1)
        {
        ee_skip[address-8] = skip[address-8] = value;
        ok_st =0;
        }
    }  
//alarm high
else if (address>=16 && address <=23)
    {
    if (value >=min[address-16] && value <= max[address-16])
        {
        ee_ahigh[address-16] = ahigh[address-16] = value;
        ok_st =0;
        }
    }
//alarm low
else if (address>=24 && address <=31)
    {
    if (value >=min[address-24] && value <= max[address-24])
        {
        ee_alow[address-24] = alow[address-24] = value;
        ok_st =0;
        }
    }  
//range high
else if (address>=32 && address <=39)
    {
    if (value >=-1999 && value <= 9999)
        {
        ee_rhigh[address-32] = rhigh[address-32] = value;
        ok_st =0;
        }
    } 
//range low
else if (address>=40 && address <=47)
    {
    if (value >=-1999 && value <= 9999)
        {
        ee_rlow[address-40] = rlow[address-40] = value;
        ok_st =0;
        }
    }
//decimal point
else if (address>=48 && address <=55)
    {
    if (value >=0 && value <= 3)
        {
        ee_dp[address-48] = dp[address-48] = value;
        ok_st =0;
        }
    } 
//scan time
else if (address == 56)
    { 
    if (value >=0 && value <= 99)
        {
        ee_gen[0] = gen[0] = value;
        ok_st =0;
        }    
    }
return (ok_st);
}


void check_mbreceived()
{
unsigned int mbaddress;
int mbamount;
unsigned char mbtransmit_data[40];        //transmit buffer max. 32 nytes or 16 registers
short int error_code =0;
unsigned int i,j,k;
//mb_dir =0;  //set 485 to transmit data
//check function code
//printf(" test sending");
switch (mbreceived_data[1])            
            {
            case 0x03: 
 //                mbaddress = (mbreceived_data[2]*256) + mbreceived_data[3];      //start address;
                 mbaddress = mbreceived_data[3];      //start address;
                 if (mbaddress+1 >=58) 
                    {
                    error_code = mbillegaldataaddress;
                    break;
                    }
//                 mbamount = (mbreceived_data[4] *256) +mbreceived_data[5];      //requested amount
                 mbamount = mbreceived_data[5];      //requested amount
                 if ((mbaddress+mbamount) > 58 || mbamount >16)
                    {
                    error_code = mbillegaldatavalue;         //requested data overflow
                    break;
                    } 
                    i = CRC16(rx_buffer,6);
                    
                    if((rx_buffer[6] != i%256) || (rx_buffer[7] != i/256)  )
                    {
                    error_code = mbillegaldatavalue;      //CRC not matching
                    break;
                    }
                  //valid request so form mb frame accordingly 
                  error_code =0;       //
                    mb_dir =1;      //transmit
//                  mbamount =8;                  //test
                  mbtransmit_data[0] = mbreceived_data[0];      //slave id
                  mbtransmit_data[1] = mbreceived_data[1];       //function code
                  mbtransmit_data[2] = (char)mbamount *2;             //SIZE OF DATA IN BYTES
                    j=3;

//                    mb_dir =0;  //set to transmit 
                    delay_ms(2);
                    for (i=0;i<mbamount;i++)               //transfer data
                        {
//                        mbtransmit_data[j] = (char)(mb_data[mbaddress+i]/256);
                         mbtransmit_data[j] = (short int)((mb_data[mbaddress+i]>>8)& 0X00ff);

                        j++;
//                        mbtransmit_data[j] = (char)(mb_data[mbaddress+i]%256);
                         mbtransmit_data[j] = (short int)(mb_data[mbaddress+i]& 0X00ff);

                        j++;
                        } 
                    i= CRC16(mbtransmit_data,(mbamount*2)+3);
                    mbtransmit_data[j] = i%256;
                    mbtransmit_data[j+1]=i/256;
                    #asm("cli")

//                    mb_dir =0;//set to transmit data
                    for (i=0;i<mbtransmit_data[2]+4+1;i++)
                        {
                        putchar(mbtransmit_data[i]);
                        }
            
//                     mbreset();
                    #asm("sei")
                    delay_ms(50);      //wait till all data transmitted need time to transmit max 36 bytes @9600
                    mb_dir =0;   //recieve
                    mbreset();
                    break; 
            case 0x04:     //read input registers (30xxx)
                     //                mbaddress = (mbreceived_data[2]*256) + mbreceived_data[3];      //start address;
                 mbaddress = mbreceived_data[3];      //start address; 30001
                 if (mbaddress+1 >=21) 
                    {
                    error_code = mbillegaldataaddress;
                    break;
                    }
//                 mbamount = (mbreceived_data[4] *256) +mbreceived_data[5];      //requested amount
                 mbamount = mbreceived_data[5];      //requested amount
                 if ((mbaddress+mbamount) > 20 || mbamount >16)
                    {
                    error_code = mbillegaldatavalue;         //requested data overflow
                    break;
                    } 
                    i = CRC16(rx_buffer,6);
                    
                    if((rx_buffer[6] != i%256) || (rx_buffer[7] != i/256)  )
                    {
                    error_code = mbillegaldatavalue;      //CRC not matching
                    break;
                    }   
                    
                  //valid request so form mb frame accordingly 
                  error_code =0;       //
                    mb_dir =1;      //transmit
//                  mbamount =8;                  //test
                  mbtransmit_data[0] = mbreceived_data[0];      //slave id
                  mbtransmit_data[1] = mbreceived_data[1];       //function code
                  mbtransmit_data[2] = (char)mbamount *2;             //SIZE OF DATA IN BYTES
                    j=3;

//                    mb_dir =0;  //set to transmit 
                    delay_ms(2);
                    for (i=0;i<mbamount;i++)               //transfer data
                        {
//                        mbtransmit_data[j] = (char)(mb_inputdata[mbaddress+i]/256);
                         mbtransmit_data[j] = (short int)((mb_inputdata[mbaddress+i]>>8)& 0X00ff);
                        j++;
//                        mbtransmit_data[j] = (char)(mb_inputdata[mbaddress+i]%256);
                         mbtransmit_data[j] = (short int)(mb_inputdata[mbaddress+i]& 0X00ff);
                        j++;
                        } 
                    i= CRC16(mbtransmit_data,(mbamount*2)+3);
                    mbtransmit_data[j] = i%256;
                    mbtransmit_data[j+1]=i/256;
                    #asm("cli")

//                    mb_dir =0;//set to transmit data
                    for (i=0;i<mbtransmit_data[2]+4+1;i++)
                        {
                        putchar(mbtransmit_data[i]);
                        }
            
//                     mbreset();
                    #asm("sei")
                    delay_ms(50);      //wait till all data transmitted need time to transmit max 36 bytes @9600
                    mb_dir =0;   //recieve
                    mbreset();

 
                    
                    break;
            //Preset Single Register  
            case 0x06:
                 mbaddress = mbreceived_data[3];      //start address;
                 if (mbaddress+1 > 58) 
                    {
                    error_code = mbillegaldataaddress;
                    break;
                    }
                 mbamount = (mbreceived_data[4] *256) +mbreceived_data[5];      //requested amount

                 if (mbamount < -1999 || mbamount >9999)
                    {
                    error_code = mbillegaldatavalue;         //requested data overflow
                    break;
                    }
                 else 
                    {
                    k = mblimitcheck(mbaddress,mbamount);
                    if (k == 1) 
                    {
                    error_code = 7;//mbillegaldatavalue;       //write not done. invalid value
                    break;
                    }
                    } 
                    i = CRC16(rx_buffer,6);
                    
                 if((rx_buffer[6] != i%256) || (rx_buffer[7] != i/256)  )
                    {
                    error_code = mbillegaldatavalue;      //CRC not matching
                    break;
                    }
                  //valid request so form mb frame  echo accordingly 
                  error_code =0;       //
                  mb_dir =1;      //transmit
                  mbtransmit_data[0] = mbreceived_data[0];      //slave id
                  mbtransmit_data[1] = mbreceived_data[1];       //function code
                  mbtransmit_data[2] = mbreceived_data[2];      //slave id
                  mbtransmit_data[3] = mbreceived_data[3];       //function code
                  mbtransmit_data[4] = mbreceived_data[4];      //slave id
                  mbtransmit_data[5] = mbreceived_data[5];       //function code
                  mbtransmit_data[6] = mbreceived_data[6];      //slave id
                  mbtransmit_data[7] = mbreceived_data[7];       //function code

                    delay_ms(2);

                    #asm("cli")

//                    mb_dir =0;//set to transmit data
                    for (i=0;i<8;i++)
                        {
                        putchar(mbtransmit_data[i]);
                        }
            
//                     mbreset();
                    #asm("sei")
                    delay_ms(50);      //wait till all data transmitted need time to transmit max 36 bytes @9600
                    mb_dir =0;   //recieve
                    mbreset();
                    break;  
            default: error_code = mbillegalfunction;  
//                    mbreset();
                    break;
                    
            }  
//        error handling;
        if (error_code !=0)
            {
            //todo : error handling code here
                mb_dir =1; 
                mbtransmit_data[0] = mbreceived_data[0];    //slave id
                mbtransmit_data[1] = mbreceived_data[1] | 0x80;     //set highest bit to indicate exception
                mbtransmit_data[2] = error_code;        //error code
                    i= CRC16(mbtransmit_data,3);    // CRC
                    mbtransmit_data[3] = i%256;
                    mbtransmit_data[4]=i/256;
                    #asm("cli")

//                    mb_dir =0;//set to transmit data
                    for (i=0;i<5;i++)
                        {
                        putchar(mbtransmit_data[i]);
                        }
            
//                     mbreset();
                    #asm("sei")
                    delay_ms(50);      //wait till all data transmitted need time to transmit max 36 bytes @9600
                    mb_dir =0;   //recieve
                    mbreset();
                
            
            }
       
 
    
}












////////////////////////////////////////////////////////////










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
//if (buffer4<0) buffer4 = -buffer4;
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
//if (b<0)
//{
//b = -b;
//nfl =1;
//}
//else
//{
//nfl =0;
//}
for (count=0;count <= 17; count++)  
    {
    if (b>table_p[count] && b <= table_p[count+1])    
        {
        number = count;
        break;
        }
    }

temp = ((500*(temp1-(float)table_p[number]))/((float)table_p[number+1] - (float)table_p[number]))+ ((long)(number-4) * 500);
true_value = (int) temp;
//if (nfl) true_value = -true_value;
return (true_value);
}


int linearise_tc(float a,float zero_tc,float span_tc,int iter,unsigned int* tabletc,long int factor)
{
int number =0;
int count;
int b=0;
long int temp=0;
float temp1=0;
int true_value = 0;
bit nfl;

temp1 = ((a - zero_tc)*factor /(span_tc - zero_tc));    //adc value of 300 deg. is 11075 in table_p
//added to add ambient value in table value 
temp1 = temp1 + (*(tabletc+1) * (long)ambient_val /50);



b = (unsigned int)temp1;

if (b<0)
{
b = -b;
nfl =1;
}
else
{
nfl =0;
}
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
if (nfl) true_value = -true_value;

return (true_value);
}

int linearise_volt(float a,float zero_tc, float span_tc,float rangehigh,float rangelow)
{
float b,c,result;

b= (a - zero_tc)*20000/(span_tc-zero_tc);     //scale to 0~20000
c= rangehigh - rangelow;
result = (b * c /20000)+rangelow;
return (result);
}

int linearise_420(float a,float zero_tc, float span_tc,float rangehigh,float rangelow)
{
float b,c,result;
c = ((span_tc - zero_tc)/5) +zero_tc;   //scale offset to offset + 4ma adc
b= (a - c)*20000/(span_tc-c);     //scale to 0~20000
c= rangehigh - rangelow;
result = (b * c /20000)+rangelow;
return (result);
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

        if (low_display <0 && low_display > -1000)
        {                
        low_display = -low_display;
        low_display%=1000;
        display_buffer[4]= 30;
        } 
        else if (low_display <=-1000)
        {
        low_display = -low_display;
        low_display%=1000;
        display_buffer[0]= 35;
     
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
            case 0: ee_gen[item2-1] = gen[item2-1]; //store in eeprom

                    if (item2 >= 3) 
                    {
                    item2 =0;       //general parameters st/mb id ,baud
                    level =1;       // return to level 1        
                    }                     
                    break;            
            case 1: ee_os[item2-1] = os[item2-1]; //store in eeprom

                    if (item2 >= 8) 
                    {
                    item2 =0;       //offset
                    level =1;
                    }                     
                    break;            
            case 2: ee_skip[item2-1] = skip[item2-1]; //store in eeprom
                    if (item2 >= 8) 
                    {
                    item2 =0;       //skip
                    level =1;       // return to level 1

                    }                     
                    break;            
            case 3: ee_rlow[item2-1] = rlow[item2-1]; //store in eeprom
                    if (item2 >= 8) 
                    {
                    item2 =0;       //rlow
                    level =1;       // return to level 1

                    }                     
                    break;            
            case 4: ee_rhigh[item2-1] = rhigh[item2-1]; //store in eeprom
                    if (item2 >= 8) 
                    {
                    item2 =0;       //rhigh
                    level =1;       // return to level 1


                    }                     
                    break;            
            case 5: ee_alow[item2-1] = alow[item2-1]; //store in eeprom
                    if (item2 >= 8) 
                    {
                    item2 =0;       //alow
                    level =1;       // return to level 1
                    }                     
                    break;            
            case 6: ee_ahigh[item2-1] = ahigh[item2-1]; //store in eeprom
                    if (item2 >= 8) 
                    {
                    item2 =0;       //ahigh
                    level =1;       // return to level 1

                    }                     
                    break;            
            case 7: ee_input[item2-1] = input[item2-1]; //store in eeprom  
                    switch (input[item2-1])
                        {
                        case 0:dp[item2-1]=2; 
                             break;
                        case 1: dp[item2-1] =3;
                                break;
                        case 2: dp[item2-1] =3;
                                break;
                        case 3: dp[item2-1] =3;
                                break;
                        case 4: dp[item2-1] =3;
                                break;
                        case 5: dp[item2-1] =3;
                                break;
                        case 6: dp[item2-1] =3;
                                break;
                        }
                    if (item2 >= 8) 
                    {
                    item2 =0;       //input
                    level =1;       // return to level 1

                    }                     
                    break;        
            case 8: ee_dp[item2-1] = dp[item2-1]; //store in eeprom
                    if (item2 >= 8) 
                    {
                    item2 =0;       //input
                    level =1;       // return to level 1

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
int max_value,min_value;        // to determine maximum and minimum values for different inputs
switch (input[item2])
    {
    case 0: min_value = -1000;
            max_value = 6500;
            break;
    case 1: min_value = -100;
            max_value = 650;
            break;
    case 2: min_value = 0;
            max_value = 650;
            break;
    case 3: min_value = 0;
            max_value = 1300;
            break;
    case 4: min_value = 0;
            max_value = 1700;
            break;
    case 5: min_value = 0;
            max_value = 1700;
            break;
    case 6: min_value = -100;
            max_value = 250;
            break;
    case 7: min_value = -1999;
            max_value = 9999;
            break;
    case 8: min_value = -1999;
            max_value = 9999;
            break;
    }
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
            case 0: if (item2==0) increment_value(&gen[0],1,99,0);  //scan time
                    if(item2 ==1) increment_value(&gen[1],1,242,blink_digit);//modbus id
                    if (item2==2) increment_value(&gen[2],0,3,0);   //baud rates 9600/19200/38400/115200
                    break;
            case 1: increment_value(&os[item2],-999,1999,blink_digit);   //offset
                    break;
            case 2: increment_value(&skip[item2],0,1,0);    //skip
                    break;
            case 3: increment_value(&rlow[item2],min_value,max_value,blink_digit);    //rlow
                    break;
            case 4: increment_value(&rhigh[item2],min_value,max_value,blink_digit);   //rhigh
                    break;
            case 5: increment_value(&alow[item2],min_value,ahigh[item2],blink_digit);    //alow
                    break;
            case 6: increment_value(&ahigh[item2],alow[item2],max_value,blink_digit);   //ahigh
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
else if (!menu_fl && !cal_fl && hold_fl)
            {
        display_scan_cnt++;
        if (skip[display_scan_cnt]!=0 && display_scan_cnt <=8)
        goto bypass1;
        if (display_scan_cnt >=8) display_scan_cnt =0;
        display_put(process_value[display_scan_cnt],display_scan_cnt+1,0,dummy,dummy2);
        bypass1:
        }
}

void dec_key(void)
{
int max_value,min_value;        // to determine maximum and minimum values for different inputs
switch (input[item2])
    {
    case 0: min_value = -1000;
            max_value = 6500;
            break;
    case 1: min_value = -100;
            max_value = 650;
            break;
    case 2: min_value = 0;
            max_value = 650;
            break;
    case 3: min_value = 0;
            max_value = 1300;
            break;
    case 4: min_value = 0;
            max_value = 1700;
            break;
    case 5: min_value = 0;
            max_value = 1700;
            break;
    case 6: min_value = -100;
            max_value = 250;
            break;
    case 7: min_value = -1999;
            max_value = 9999;
            break;
    case 8: min_value = -1999;
            max_value = 9999;
            break;
    }
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
            case 0: if (item2==0) decrement_value(&gen[0],1,99,0);  //scan time
                    if(item2 ==1) decrement_value(&gen[1],1,242,blink_digit);//modbus id
                    if (item2==2) decrement_value(&gen[2],0,3,0);   //baud rates 9600/19200/38400/115200
                    break;
            case 1: decrement_value(&os[item2],-999,999,blink_digit);   //offset
                    break;
            case 2: decrement_value(&skip[item2],0,1,0);    //skip
                    break;
            case 3: decrement_value(&rlow[item2],min_value,max_value,blink_digit);    //rlow
                    break;
            case 4: decrement_value(&rhigh[item2],min_value,max_value,blink_digit);   //rhigh
                    break;
            case 5: decrement_value(&alow[item2],min_value,ahigh[item2],blink_digit);    //alow
                    break;
            case 6: decrement_value(&ahigh[item2],alow[item2],max_value,blink_digit);   //ahigh
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
    if (!menu_fl && !cal_fl) hold_fl = ~hold_fl; //toggle hold scan flag
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
if (tsec_cnt >=(2*gen[0])) //scan time in seconds
    {
    tsec_fl =1;
    tsec_cnt =0; 
    ser_fl =1;
    }


}




void led_check(void)
{    
all_led_off();
all_led_off1();
if (process_value[0] <= alow[0])
gled1_on();
if (process_value[0] >= ahigh[0])
rled1_on();
 

if (skip[1] ==0)
    {
    if (process_value[1] <= alow[1])
    gled2_on();
    if (process_value[1] >= ahigh[1])
    rled2_on();
   
    }
if (skip[2] ==0)
    {
    if (process_value[2] <= alow[2])
    gled3_on();
    if (process_value[2] >= ahigh[2])
    rled3_on();

    }
if (skip[3] ==0)
    {
    if (process_value[3] <= alow[3])
    gled4_on();
    if (process_value[3] >= ahigh[3])
    rled4_on();

    }
if (skip[4] ==0)
    {
    if (process_value[4] <= alow[4])
    gled5_on();
    if (process_value[4] >= ahigh[4])
    rled5_on();
    }
if (skip[5] ==0)
    {
    if (process_value[5] <= alow[5])
    gled6_on();
    if (process_value[5] >= ahigh[5])
    rled6_on();
    }
if (skip[6] ==0)
    {
    if (process_value[6] <= alow[6])
    gled7_on();
    if (process_value[6] >= ahigh[6])
    rled7_on();
    }
if (skip[7] ==0)
    {
    if (process_value[7] <= alow[7])
    gled8_on();
    if (process_value[7] >= ahigh[7])
    rled8_on(); 
    }
}

void  relay_logic()
{
if (led_status ==0xff) 
relay1 =1;
else 
relay1 =0;

if (led_status1 ==0xff)
relay2 =1;
else
relay2 =0;
}

void pv_update(void)
{
int adc_value,min_val,max_val;
if (!cal_fl)
{
adc_value=adc3421_read();
if (mux_scan ==7 && tc_fl)  //added to calculate ambient value 
{
if ( adc_value >= cal_zero[7])
{
ambient_val = rhigh[7] + (adc_value - cal_zero[7])/22;
}
else
{
ambient_val = rhigh[7] - (adc_value - cal_zero[7])/22;
}


}
else
{
//process_value[mux_scan] = ((long)adc_value -(long)cal_zero[mux_scan]) * 10000 / ((long)cal_span[mux_scan]- (long)cal_zero[mux_scan]);
switch (input[mux_scan])
    {
    case 0: process_value[mux_scan] = linearise_p(adc_value,cal_zero[mux_scan],cal_span[mux_scan])+os[mux_scan];
            min_val = -1999;
            max_val = 6000;
            break;
    case 1: process_value[mux_scan] = linearise_p(adc_value,cal_zero[mux_scan],cal_span[mux_scan])/10 +os[mux_scan];
            min_val = -199;
            max_val = 600;
            break;
    case 2: process_value[mux_scan] = linearise_tc(adc_value,cal_zero[mux_scan],cal_span[mux_scan],15,table_j,5000)+os[mux_scan];
            min_val =0;
            max_val = 700;
            break;
    case 3: process_value[mux_scan] = linearise_tc(adc_value,cal_zero[mux_scan],cal_span[mux_scan],28,table_k,5000)+os[mux_scan];
            min_val =0;
            max_val = 1300;
            break;                           
    case 4: process_value[mux_scan] = linearise_tc(adc_value,cal_zero[mux_scan],cal_span[mux_scan],36,table_r,50000)+os[mux_scan];
            min_val =0;
            max_val = 1700;
            break;
    case 5: process_value[mux_scan] = linearise_tc(adc_value,cal_zero[mux_scan],cal_span[mux_scan],36,table_s,50000)+os[mux_scan];
            min_val =0;
            max_val = 1700;
            break;
    case 6: process_value[mux_scan] = linearise_tc(adc_value,cal_zero[mux_scan],cal_span[mux_scan],8,table_t,5000)+os[mux_scan];
            min_val =0;
            max_val = 350;
            break;
    case 7: process_value[mux_scan] = linearise_volt(adc_value,cal_zero[mux_scan],cal_span[mux_scan],rhigh[mux_scan],rlow[mux_scan])+os[mux_scan];
            min_val =-1999;
            max_val =9999;
            break;  
    case 8: process_value[mux_scan] = linearise_420(adc_value,cal_zero[mux_scan],cal_span[mux_scan],rhigh[mux_scan],rlow[mux_scan])+os[mux_scan];
             min_val =-1999;
            max_val =9999;
            break;
    }   
    //check for overrange or underrange or skip. proces_error used in other routines and modbus
    //0: normal
    //1: underrange
    //2: overrange
    //3: skip
    //////////////////////////////////////////////////////////////////////////
    if (process_value[mux_scan] < min_val) process_error[mux_scan] = 1;
    else if (process_value[mux_scan] > max_val) process_error[mux_scan]=2;
    else process_error[mux_scan] =0;        //normal
    //////////////////////////////////////////////////////////////////////////
}
mux_scan++;
//////////////////////////////////////////////////////////////////
//internal scanning according to skip status. to be checked later after uncommenting
//////////////////////////////////////////////////////////////////

if (!(tc_fl && (mux_scan ==7)))
{
while (skip[mux_scan] !=0)
{
mux_scan++;
if (mux_scan>=8)
break;
}
}
//////////////////////////////////////////////////////////////////



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

void display_check(void)
{
int adc_value;
if(!menu_fl && !cal_fl)
    {
    skip[0] = ee_skip[0] =0;
    if (tsec_fl )   //hold_fl =0 implies scan else hold (toggled in shf key routine)
        {
        if (!hold_fl) display_scan_cnt++;  //hold display to same channel
        if (skip[display_scan_cnt]!=0 && display_scan_cnt <=8)
        goto bypass;
        tsec_fl =0;
        if (display_scan_cnt >=8) display_scan_cnt =0;
        switch (process_error[display_scan_cnt])
            {
            case 0: display_put(process_value[display_scan_cnt],display_scan_cnt+1,0,dummy,dummy2);
                    break;
           case 1: display_put(0,display_scan_cnt+1,1,message_neg,dummy2);
                    break;
           case 2: display_put(0,display_scan_cnt+1,1,message_open,dummy2);
                    break;
           default: display_put(process_value[display_scan_cnt],display_scan_cnt+1,0,dummy,dummy2);
                    break;

            }     
bypass:
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
for(i=0;i<8;i++)
    {
    cal_zero[i] = ee_cal_zero[i];
    } 
for(i=0;i<8;i++)
    {
    cal_span[i] = ee_cal_span[i];
    } 
for(i=0;i<3;i++)
    {
    gen[i] = ee_gen[i];
    } 
for(i=0;i<8;i++)
    {
    os[i] = ee_os[i];
    } 
for(i=0;i<8;i++)
    {
    skip[i] = ee_skip[i];
    } 
for(i=0;i<8;i++)
    {
    rlow[i] = ee_rlow[i];
    } 
for(i=0;i<8;i++)
    {
    rhigh[i] = ee_rhigh[i];
    } 
for(i=0;i<8;i++)
    {
    alow[i] = ee_alow[i];
    } 
for(i=0;i<8;i++)
    {
    ahigh[i] = ee_ahigh[i];
    } 
for(i=0;i<8;i++)
    {
    input[i] = ee_input[i];
    } 
for(i=0;i<8;i++)
    {
    dp[i] = ee_dp[i];
    } 

}

// added to check if any input is tc. if so, then channel 8 is skipped for all purposes
void tc_check()
{
int i;
tc_fl =0;
for (i=0;i<=7;i++)
    {
    if (input[i]>=2  && input[i] <=6) tc_fl =1;
    } 
if (tc_fl) skip[7] = ee_skip[7] = 1;    //force skip channel 8
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
//change serial speed according to value set
if (gen[2] ==0)    ///9600 baud
{
UBRRH=0x00;
UBRRL=0x8F;
}
else if (gen[2] ==1)   //19200 baud
{
UBRRH=0x00;
UBRRL=0x47;
}
else if (gen[2] ==2)   //38400 baud
{
UBRRH=0x00;
UBRRL=0x23;
}
else if (gen[2] ==3)   //115200 baud
{
UBRRH=0x00;
UBRRL=0x0b;
}
else                    //force to default 9600 baud if not above
{
gen[2]=0;
UBRRH=0x00;
UBRRL=0x8F;
}

cal_fl =0;
if (!key5) cal_fl =1;
mb_dir =0;
while (1)
      {
      // Place your code here
      display_check();
      display_out(display_count);
      display_count++; 
      led_check();   
      relay_logic();
             key_check();
      tc_check();
      if(display_count >=10) 
      {
       display_count =0;
       if (hsec_fl)
        {
        hsec_fl =0;
        pv_update();  
        check_set(); 
        if (modbus_fl)
            {  
            modbus_fl =0;
            mb_datatransfer();
            check_mbreceived(); 
 //           delay_ms(100);
//            mb_dir =0;      //set to receieve
            }  
       if (ser_fl)
        {
        ser_fl =0;
//        mb_dir =0;
//        delay_ms(2);
//        printf("%5u %5u %5u %5u %5u %5u %5u %5u\n",process_value[0],process_value[1],process_value[2],process_value[3],process_value[4],process_value[5],process_value[6],process_value[7]);    
//        mb_dir =1;
        }
      }
//      process_value[0] =1234;
//      process_value[1] = 5678; 
      }
}
}