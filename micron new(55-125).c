/*****************************************************
derived from micron new(4-135).c
reason:
to change the angle to 55 - 125
to change the battery voltage calculation to compensate for the charging current error.
to change low battery to 10.6V and reconnect voltage to 12.2V

derived from alpha agritech(70-120).c
reason: to change the start /end angle from 70-120 to 45-135
 


derived from noname20w.c
reason: 
to change the latitude longitude to 11/78
to change that start /end angle to 70/120


derived from tracker3.c
reason: to change welcome message to sai babuji infra projects pvt. ltd.


date : 17-11-2013
derived from tracker2.c

reason:
1.low battery indication in normal mode. hysterisis to be provided for reconnection on 12.4V
2. cutoff backlight on low battery status (errfl2)
3. if adc_battery > 15V, cut charging , put message ("no battery connected");
4. remove condition that if battery voltage < 5V, disconnect charging.
5. increase current limits to 1.2A/1A
6. overflow for OCR1A correction
7. fast charging depending on battery voltage
8. low battery/battery not connected sensing and algorithm.
9. bug of sleep mode.
10.MPPT changed to full charge PV >=battery + 2.0V





date: 13 nov 2013
derived from tracker1.c
reason: to test in new hardware
changes:
OC1A - pin 19 of mega32 - pwm output
OC1B = pin 18 of mega32 - shutdown for ir2104
mux lines pc7 and pc5 interchanged to suit new hardware solar4-main
rs232 to be re-introduced





derived from solar14.c

reason: to add algorithm for sleep mode between sunset + 30 min and sunrise - 30 min.
derived from solar13.c
reason: to make algorithm change to the mechanical error logic.
checked once every 30 seconds. if angle has changed more than 2 degrees then continue else end panel movement



date: 04-nov 2013
reason: to make following changes as suggested by tata solar
1.enter/exit of calibration mode for start/emd angle setting improved.**
2.LED indication in case of error on charger side to be inhibited.    **
3. timeout for mechanical error to be changed
4. battery low indication in absence of PV to be indicated.           **
5. output to relay to be inhibited in all conditions even in manual mode. **


date: 23-9-13
reason:
done: setting of latitude/longitude and timezone for user
result stored in riset,settm.

todo: put value in regular calculation of target angle.
remove existing table for sunrise/set.

********


date: 16-09-2013

derived from solar4.c
reason:to add latitude/longitude calculations.
only for checking purpose





date: 20 july 2013
reason:
to add logic to come out of the program mode after 29 seconds of inactivity of key pressed
the variable used is program_timeout, function added is clear_default();

date:5-7-13
reason: to add RS232 control to the unit.
if 'R' is received, send record count.
if 'P' is received, send print command.
if 's' is received , reset record count.


date : 29-6-13
derived from solar1.c
reason: 
to add fixed parameters batteryvoltage = 12V and MPPT 17V
and to monitor and control charging parameters

This program was produced by the
CodeWizardAVR V2.04.4a Advanced
Automatic Program Generator
© Copyright 1998-2009 Pavel Haiduc, HP InfoTech s.r.l.
http://www.hpinfotech.com

Project : 
Version : 
Date    : 27.06.2013
Author  : NeVaDa
Company : Warner Brothers Movie World
Comments: 


Chip type               : ATmega16
Program type            : Application
AVR Core Clock frequency: 11,059200 MHz
Memory model            : Small
External RAM size       : 0
Data Stack size         : 256
*****************************************************/

#include <mega32.h>
#include <delay.h>
#include <math.h>
#include <ctype.h>
#include <stdlib.h>
#include <sleep.h>

// I2C Bus functions
#asm
   .equ __i2c_port=0x1B ;PORTA
   .equ __sda_bit=4
   .equ __scl_bit=5
#endasm
#include <i2c.h>

// DS1307 Real Time Clock functions
#include <ds1307.h>

// Alphanumeric LCD Module functions
#asm
   .equ __lcd_port=0x18 ;PORTB
#endasm
#include <lcd.h>

#define key1    PINA.0
#define key2    PINA.1
#define key3    PINA.2
#define key4    PINA.3
#define relay2  PORTC.0
#define relay1  PORTD.7
#define printkey PINA.6
#define led1    PORTD.3
#define led2    PORTC.4
#define led3    PORTD.6
#define led4    PORTC.3
#define led5    PORTC.1
#define led6    PORTC.2
#define mux1    PORTC.5
#define mux2    PORTC.6
#define mux3    PORTC.7
#define backlight   PORTB.3
#define shutdown    PORTD.4


#define battery_voltage 1200   //12V
//#define mppt           1600   //17V
#define equal_voltage   1350   //13.5V
#define boost_voltage   1440   //14.4V
#define boost_current   120    //1.200A
#define trickle_current 100    //1.0A
#define cutoff_voltage  1070   //10.7V
#define reconnect_voltage 1220 // reconnect voltage at 12.2V
#define set_capacity    700    //7AH
#define boost_timeout   36000    //1 hour
#define float_timeout   36000    //1 hour
#define log_interval    5       // 5 second interval

/////////

float pi =3.14159;
float degs;
float rads;
float L,g;
float sundia = 0.53;
float airrefr = 34.0/60.0;
float settm,riset,daytime,sunrise_min,sunset_min;

///////////////////////////////////////////////////

unsigned long int adc_buffer,timeout_cnt,target_angle,printkeycnt,calibusercnt,program_timeout;
unsigned char hour,minute,second,day,month,year,;
bit key1_old,key2_old,key3_old,key4_old,printkey_old,start_fl,end_fl,inf_fl;
//bit rcflag;
bit key1_fl,key2_fl,key3_fl,key4_fl,printkey_fl,err_fl,err_fl1,err_fl2,err_fl3,led_blinkfl,sleep_fl;
bit pgm_fl,blink_fl,adc_fl,read_adcfl,boost_fl,trickle_fl,float_fl;
short int mode,set,item1,bright_cnt,angle_cnt,mode0_seqcnt,end_cnt,ocr_inc,sleep_counter;
int adc_pvolt,adc_chargecurrent,adc_battery,adc_angle;
//short int ir_cnt;
unsigned int mode1_count,blink_count,display_cnt,manual_cnt,adc_count;
unsigned long int boost_time,float_time;
char blink_locx,blink_locy;
char blink_data;
signed int set_latit,set_longitude,angle,low_angle,high_angle,time_interval,target_time,time_elap,set_timezone;
//int ircommand;
//unsigned long irsense;
long int zero_adc,span_adc;
unsigned char char_latitude,char_longitude,char_timezone;
//char record_buffer[16];
eeprom signed int e_set_latit = 1113,e_set_longitude =7865,e_low_angle=550,e_high_angle=1250,e_time_interval=15,e_set_timezone=550;
eeprom long int e_zero_adc =14000,e_span_adc=20000;
eeprom int record_cnt @0x020;
eeprom int record_cnt =0;
//flash int sunrise_time[] ={718,709,607,620,601,556,605,617,625,634,649,708};            //according to month
//flash int sunset_time[]={1818,1836,1848,1857,1909,1921,1923,1908,1841,1814,1757,1759};   //according to month
//flash int sunrise_min[]={438,429,407,380,361,356,365,377,385,394,409,428};
//flash int sunset_min[]={1098,1116,1128,1137,1149,1161,1163,1148,1121,1094,1077,1079};
//flash int daytime[]={659,687,720,757,788,804,798,771,736,700,668,651};
bit calibuser,calibfact,manual_fl=0;
//char flash *message1 = {"set the time"};

void display_update(void);
/* table for the user defined character
   arrow that points to the top right corner */
flash char char0[8]={
0b0001110,
0b0010001,
0b0010001,
0b0001110,
0b0000000,
0b0000000,
0b0000000,
0b0000000};


/* function used to define user characters */
void define_char(char flash *pc,char char_code)
{
char i,a;
a=(char_code<<3) | 0x40;
for (i=0; i<8; i++) lcd_write_byte(a++,*pc++);
}


void control_buck_off(void)
{   
TCCR1A &= 0x3f;         // stop PWM outpu
shutdown = 0;
}

void control_buck_on(void)
{
shutdown =1;
delay_ms(2);
TCCR1A |= 0x80;         // turn PWM on.
}
//////*********

float fnday(long y,long m,long d,float h)
            {
            long int luku = -7 *(y+(m+9)/12)/4 + 275*m/9 + d;
            luku+=(long int) y*367;
            return (float)luku-730531.5 + h/24.0;
            }
            
float fnrange(float x)
            {
            float b = 0.5 * x / pi;
            float a = 2.0 * pi * (b - (long) b);
            if (a<0) a = 2.0 * pi+a;
            return a;
            }
            
            
float f0(float lat, float declin)
            {
            float f0,df0;
            df0 = rads *(0.5*sundia + airrefr);
            if (lat <0.0) df0 = -df0;
            f0 = tan(declin+df0) * tan(lat*rads);
            if (f0>0.99999) f0 = 1.0;
            f0 = asin(f0) + pi/2.0;
            return f0;
            }


float fnsun(float d)
            {
            L = fnrange(280.461* rads + 0.9856474 * rads * d);
            g = fnrange(357.528 * rads + 0.9856003 * rads * d);
            
            return fnrange(L+1.915 * rads * sin(g) + 0.02 * rads * sin(2*g));
            }
  
void rise_set( float day,float m,float y,float h,float latit,float longit,float tzone)
{
float d,lamda;
float obliq,alpha,delta,LL,equation,ha;
degs = 180.0/pi;
rads = pi/180.0;
h=12;
d= fnday (y,m,day,h);
lamda = fnsun(d);
obliq = 23.439 * rads - 0.0000004 * rads *d;
alpha =atan2(cos(obliq) * sin(lamda),cos(lamda));
delta = asin(sin(obliq) * sin(lamda));

LL = L-alpha;
if (L<pi) LL+= 2.0 * pi;
equation = 1440.0 * (1.0 - LL/pi/2.0);
ha = f0(latit,delta);
riset = 12.0 - 12.0 * ha/pi +tzone - longit/15.0 +equation/60.0;
settm = 12.0 + 12.0 * ha/pi +tzone - longit/15.0 + equation/60.0;
if (riset > 24.0) riset =riset -24.0;
if (settm > 24.0) settm =settm -24.0;
sunrise_min = riset * 60;       //rise time in minutes
sunset_min = settm * 60;        //set time in minutes
daytime = sunset_min - sunrise_min ;   //day time in minutes
}

/////*********


//void print_realtime(void);

void clear_to_default()
{
if (mode!=0)
    {
                mode1_count =0;
                mode =0;
                pgm_fl =0;  
                blink_fl =0;
                set =0;
                item1 =0;
                lcd_clear();
                delay_ms(10);
    }       
if (manual_fl)
    {
            manual_fl =0;
            lcd_clear();
            lcd_putsf("manual mode");
            lcd_gotoxy(0,1);
            lcd_putsf("exiting...");
            delay_ms(2000);
 
    }
}

int to_minute(char hr,char min)
{
return (hr*60 + min);
}



void put_message(long int a)
{
char b[5];
if (a <0)
{
lcd_putchar('-');
a = -a;
}
else
{
lcd_putchar(' ');
}
b[0] = a % 10 + 48;
a = a/10;
b[1] = a % 10 + 48;
a = a/10;
b[2] = a % 10 + 48;
a = a/10;
b[3] = a % 10 + 48;
a = a/10;
b[4] = a + 48;
lcd_putchar(b[4]);
lcd_putchar(b[3]);
lcd_putchar(b[2]);
lcd_putchar(b[1]);
lcd_putchar(b[0]);


}

void put_message2(unsigned char a)
{
char b[2];
b[0] = a % 10 + 48;
a = a/10;
b[1] = a + 48;
lcd_putchar(b[1]);
lcd_putchar(b[0]);
}

void put_message3(unsigned int a)
{
char b[3];
b[0] = (a %10) + 48;
a = a/10;
b[1] = (a %10) + 48;
a = a/10;
b[2] = a + 48;
lcd_putchar(b[2]);
lcd_putchar(b[1]);
lcd_putchar(b[0]);
}

void blink_control(void)
{
if (blink_fl)
{
 blink_count++;
 if (blink_count >=200) blink_count =0;
 
 if (blink_count >=150) 
 {
 lcd_gotoxy(blink_locx,blink_locy);
 lcd_putsf("  ");
 }
 else
 {
 lcd_gotoxy(blink_locx,blink_locy);
 put_message2(blink_data);
 }
     
 
 
 }
 }

void display_time(void)
{
      put_message2(hour);  
      lcd_putchar(':');
      put_message2(minute);
      lcd_putchar(':');
      put_message2(second); 
}

void display_latlong(signed int l)
{
unsigned int m;
if (l<0) 
lcd_putchar('-');
else
lcd_putchar('+');
m = abs(l);
put_message3(m/100);
lcd_putchar('.');
put_message2(m%100);
}

/*
void display_time2(int t)
{
    put_message2(t/100);
    lcd_putchar(':');
    put_message2((t%100)*6/10);
}
*/

void display_date(void)
{
      put_message2(day);  
      lcd_putchar('.');
      put_message2(month);
      lcd_putchar('.');
      lcd_putsf("20");
      put_message2(year); 
}

/*
void display_day(int data)
{
char a;
a = data /100;
put_message2(a);
lcd_putsf(":");
a = data%100;
put_message2(a);
}
*/

void display_day2(int data)
{
char a;
a = data /60;
put_message2(a);
lcd_putsf(":");
a = data%60;
put_message2(a);
}

void display_analog(int a)
{
    put_message2(a/100);
    lcd_putchar('.');
    put_message2(a%100);
}

void display_analog1(int a)
{
    put_message2(a/10);
    lcd_putchar('.');
    lcd_putchar((a%10)+48);
}

void display_angle(int a)
{
char x,y;
y = a/10;
x = y%100;
y = y/100; 
lcd_putchar(y+48);       
put_message2(x);
  
lcd_putchar('.');
x = a%10;

lcd_putchar(x+48);
lcd_putchar(0);
}

void check_mode(void)
{
//key1 =1;
if (!key1)
    { 
    bright_cnt =0;
    program_timeout=0;
        mode1_count++;
        if (mode1_count >= 1000)
        {
            if (mode == 0)
            {    
                mode1_count=0;
                mode =1;
                pgm_fl =1;
//                lcd_gotoxy(0,0);
                lcd_clear();
                lcd_putsf("set the time");
                lcd_gotoxy(0,1);
                display_time();
                blink_data = hour;
                blink_locx =0;
                blink_locy =1;
                blink_fl =1;                              
                set =0;
                item1 =0;
            }
            else
            {   
                mode1_count =0;
                mode =0;
                pgm_fl =0;  
                blink_fl =0;
                set =0;
                item1 =0;
                lcd_clear();
                delay_ms(10);
            }
        } 
    }
else
    mode1_count =0; 

//////manual mode key check
if (!key4)
{
manual_cnt++;
if (manual_cnt > 2000)
        {
        manual_cnt =0;
        if (!manual_fl)
            {
            manual_fl =1;
            lcd_clear();
            lcd_putsf("manual mode");
            lcd_gotoxy(0,1);
            lcd_putsf("entering....");
            delay_ms(2000);
            }
        else
            {
            manual_fl =0;
            lcd_clear();
            lcd_putsf("manual mode");
            lcd_gotoxy(0,1);
            lcd_putsf("exiting...");
            delay_ms(2000);
            }

        }

}
else
{
manual_cnt=0;
}


//////////////////////////



}

void check_increment(void)
{
if (key2_fl && pgm_fl)
{
    key2_fl =0; 
        bright_cnt =0;
        program_timeout=0;

    if (mode ==1)
    {
    switch (item1)
    {
        case 0: hour++;
                if (hour > 24) hour =0;
                break;
        case 1: minute++;
                if (minute > 59) minute =0;
                break;
        case 2: second++;
                if (second >59) second =0;
                break;
        case 3: day++;
                if (day > 31) day =1;
                break;
        case 4: month++;
                if (month > 12) month = 1;
                break;
        case 5: year++;
                if (year >99) year = 13;
                break;
        case 6: set_latit+=100;
                if (set_latit > 9000) set_latit =9000;
                char_latitude = blink_data = abs(set_latit)/100;
                break;
        case 7: set_latit+=1;
                if (set_latit > 9000) set_latit =9000;
                char_latitude = blink_data = abs(set_latit)%100;
                break;
        case 8: set_longitude+=100;
                if (set_longitude > 18000) set_longitude = 18000;
                char_longitude = blink_data = (abs(set_longitude)/100)%100;
                break;
        case 9: set_longitude+=1;
                if (set_longitude > 18000) set_longitude = 18000;
                char_longitude = blink_data = abs(set_longitude)%100;
                break; 
        case 10:time_interval+=5;
                if (time_interval > 90) time_interval = 5; 
                break;
        case 11: set_timezone+=100;
                if(set_timezone > 1200) set_timezone = 1200;
                break;        
        case 12: set_timezone+=25;
                if(set_timezone > 1200) set_timezone = 1200;
                break;        
       }
    
    }


}
}

void check_decrement(void)
{
if (key3_fl && pgm_fl)
{
    bright_cnt =0;
    program_timeout=0;
    key3_fl =0;
    if (mode ==1)
    {
    switch (item1)
    {
        case 0: hour--;
                if (hour > 23) hour =23; 
                break;
        case 1: minute--;
                if (minute > 59) minute =59;
                break;
        case 2: second--;
                if (second > 59) second =59;
                break;
        case 3: day--;
                if (day <1) day =31;
                break;
        case 4: month--;
                if (month <1) month = 12;
                break;
        case 5: year--;
                if (year >99) year = 99;
                break;
        case 6: set_latit-=100;
                if (set_latit <-9000) set_latit =-9000;
                char_latitude = blink_data = abs(set_latit)/100;
                break;
        case 7: set_latit-=1;
                if (set_latit <-9000) set_latit =-9000;        
                char_latitude = blink_data = abs(set_latit)%100;
                break;
        case 8: set_longitude-=100;
                if (set_longitude <-18000) set_longitude =-18000;
                char_longitude = blink_data = (abs(set_longitude)/100)%100;
                break;
        case 9: set_longitude-=1;
                if (set_longitude <-18000) set_longitude =-18000;
                char_longitude = blink_data = abs(set_longitude)%100;
                break;
        case 10:time_interval-=5;
                if(time_interval<5) time_interval =90;
                break;
        case 11: set_timezone-=100;
                if(set_timezone < -1200) set_timezone = -1200;
                break;        
        case 12: set_timezone-=25;
                if(set_timezone < -1200) set_timezone = -1200;
                break;        
    }
    
    }


}
}

void check_shift(void)
{
if (key4_fl && pgm_fl)
{
    bright_cnt =0;
    program_timeout=0;
    key4_fl =0;
    if (mode ==1)
    {
    item1++;
    if (set ==0 && item1>2) item1=0;
    if (set ==1 && (item1 <3 || item1 >5)) item1 =3;
    if (set ==2 && (item1 <6 || item1 >7)) item1 =6;
    if (set ==3 && (item1 <8 || item1 >9)) item1 =8;
    if (set ==4) item1 =10;
    if (set ==5 && (item1 <11 || item1 >12)) item1 = 11;
    
   }

}
}

void check_enter(void)
{

if (key1_fl && pgm_fl)
{
    bright_cnt =0;
    program_timeout=0;
    key1_fl =0;
    if (mode ==1)
    {
    switch(set)
    {
    case 0: rtc_set_time(hour,minute,second);
            break;
    case 1: rtc_set_date(day,month,year);
            break;
    case 2: e_set_latit = set_latit;
            break;
    case 3: e_set_longitude = set_longitude;
            break;
    case 4: e_time_interval = time_interval;
            break; 
    case 5: e_set_timezone = set_timezone;   
    }

    set++;
    if (set>5)  set =0;
    
    switch (set)
    {
    case 0:     lcd_clear();
                lcd_putsf("Set Time");
                rtc_get_time(&hour,&minute,&second);
                lcd_gotoxy(0,1);
                display_time();
                blink_data = hour;
                blink_locx =0;
                blink_locy =1;
                blink_fl =1;                              
                set =0;
                item1 =0;
                break;

    case 1:     lcd_clear();
                lcd_putsf("Set Date");
                rtc_get_date(&day,&month,&year);
                lcd_gotoxy(0,1);
                display_date();
                blink_data = day;
                blink_locx =0;
                blink_locy =1;
                blink_fl =1;                              
                set =1;
                item1 = 3;  
                break;
    case 2:     lcd_clear();
                lcd_putsf("Set Latitude");
                set_latit = e_set_latit;
                lcd_gotoxy(0,1);
                display_latlong(set_latit);
                lcd_putsf(" Deg.");
                char_latitude = blink_data = (abs(set_latit)/100)%100 ;
                blink_locx =2;
                blink_locy =1;
                blink_fl =1;                              
                set =2;
                item1 =6;
                break;
    case 3:     lcd_clear();
                lcd_putsf("Set Longitude");
                set_longitude = e_set_longitude;
                lcd_gotoxy(0,1);
                display_latlong(set_longitude);
                lcd_putsf(" Deg.");
                char_longitude = blink_data = (abs(set_longitude)/100)%100 ;
                blink_locx =2;
                blink_locy =1;
                blink_fl =1;                              
                set =3;
                item1 =8;
                break;  
    case 4:     lcd_clear();
                lcd_putsf("Time Interval ");
                e_time_interval = time_interval;
                lcd_gotoxy(0,1);
                put_message2(time_interval);
                lcd_putsf(" minutes");
                blink_data = time_interval;
                blink_locx =0;
                blink_locy =1;
                blink_fl =1;                              
                set =4;
                item1 =10;
                break;
    case 5:     lcd_clear();
                lcd_putsf("Set Timezone");
                set_timezone = e_set_timezone;
                lcd_gotoxy(0,1);
                lcd_putsf("GMT ");        
                display_latlong(set_timezone);
                lcd_putsf("Hrs.");
                char_timezone = blink_data = (abs(set_timezone)/100)%100 ;
                blink_locx =6;
                blink_locy =1;
                blink_fl =1;                              
                set =5;
                item1 =11;
                break;
    }
    
    }

}
}

void get_key(void)
{
if (!key1 && key1_old) key1_fl =1;
if (!key2 && key2_old) key2_fl =1;
if (!key3 && key3_old) key3_fl =1;
if (!key4 && key4_old) key4_fl =1;
if (!printkey && printkey_old) printkey_fl =1;
printkey_old = printkey;
key1_old = key1;
key2_old = key2;
key3_old = key3;
key4_old = key4;
if (!key3 && mode==0 && !manual_fl)
{
printkeycnt++;
if (printkeycnt >=4000)
            {
            printkeycnt=0;
            printkey_fl =1;
            }
}
else
printkeycnt=0;

if (!key2 && !manual_fl)              //calibuser calibration mode enter
            {
            calibusercnt++;
            if(calibusercnt >=2000)
                        {
                        calibusercnt=0;
                        calibuser=1;            //enter calibration mode for user
                        lcd_clear();
                        lcd_putsf("Calibration Mode");
                        lcd_gotoxy(0,1);
                        lcd_putsf("entering");
                        delay_ms(2000);
                        }
            }
else
calibusercnt=0;
}


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





void read_adc(void)
{
if(adc_fl)
        {
        if (adc_count ==0)
        {
        mux1=0;
        mux2=1;
        mux3=1;
        }
        adc_count++;
        if (adc_count == 75)
        {
        adc_battery = adc3421_read()/5; 
        if (adc_chargecurrent <400) adc_battery = adc_battery - (adc_chargecurrent/4); //added to correct error in battery voltage due to charging current.
        mux1 =0;
        mux2 =0;
        mux3 =0;
        } 
        if (adc_count == 150)
        {
        adc_chargecurrent = adc3421_read()/8;
        mux1 =0;
        mux2 =1;
        mux3 =0;
        } 
        if (adc_count == 225)
        {
        adc_pvolt = adc3421_read()/5;
        if (adc_chargecurrent <400) adc_pvolt = adc_pvolt + (adc_chargecurrent/4); //added to correct error in pvolt voltage due to charging current.
        mux1 =1;
        mux2 =0;
        mux3 =1;
        } 
        if (adc_count >= 300)
        {
        adc_angle = adc3421_read();
        mux1 =0;
        mux2 =1;
        mux3 =1;
        adc_fl =0;
        adc_count =0;
        read_adcfl =1;
        } 



        }
}


/*
void get_irkey(void)
{
// ir sensing
if (rcflag)
{
rcflag =0;
ircommand = irsense & 0x0f;
switch(ircommand)
    {
    case 0:     mode =1;
                pgm_fl =1;
//                lcd_gotoxy(0,0);
                lcd_clear();
                lcd_putsf("set the time");
                lcd_gotoxy(0,1);
                display_time();
                blink_data = hour;
                blink_locx =0;
                blink_locy =1;
                blink_fl =1;                              
                set =0;
                item1 =0; 
                break;
    case 1:     calibfact = calibuser =0;
                mode =0;
                pgm_fl =0;  
                blink_fl =0;
                set =0;
                item1 =0;
                lcd_clear();
                delay_ms(10);
                break;
    case 2:     key1_fl =1;
                key2_fl = key3_fl = key4_fl =0;
                break;
    case 3:     key4_fl=1;
                key1_fl = key2_fl = key3_fl =0;
                break;
    case 4:    key2_fl=1;
               key1_fl = key4_fl = key3_fl =0;

                break;
    case 5:    key3_fl=1;    
                    key1_fl = key2_fl = key4_fl =0;

                break;   
    case 6:     calibuser =1;
                calibfact =0;
                lcd_putsf("the panel ");
                lcd_gotoxy(0,1);
                lcd_putsf("calibration mode");
                delay_ms(3000);
                lcd_gotoxy(0,0);
                lcd_putsf("inc > inch up");
                lcd_gotoxy(0,1);
                lcd_putsf("dec > inch down");
                delay_ms(3000);
                lcd_gotoxy(0,0);
                lcd_putsf("set > enter low");
                lcd_gotoxy(0,1);
                lcd_putsf("shf-> enter high");
                delay_ms(3000);    
                break;
    }




}


}
*/

void display_update(void)
{

if (mode ==0 && !manual_fl)
        {
        lcd_clear();
        mode0_seqcnt++;
        if (mode0_seqcnt > 85) mode0_seqcnt=0;
        if (mode0_seqcnt>=0 && mode0_seqcnt<=35)                //display date and time
                { 
                lcd_gotoxy(0,0);
                lcd_putsf("time: ");
                display_time(); 
                lcd_gotoxy(0,1);         
                    if (!err_fl2 && !err_fl3) 
                    {
                    lcd_putsf("angle: ");       
                    display_angle(angle);  
//                    lcd_putsf(" deg.");    
                    }
                    else if (!err_fl3)
                    {
                    lcd_putsf(" LOW BATTERY    ");
                    }
                    else
                    {
                    lcd_putsf("CONNECT BATTERY ");
                    }
                }
        if (mode0_seqcnt>=36 && mode0_seqcnt<=45)            //display sunrise and sunset time
                { 
                lcd_gotoxy(0,0);
                lcd_putsf("sunrise: ");
                display_day2(sunrise_min);          
                lcd_gotoxy(0,1);
                lcd_putsf("sunset: ");       
                display_day2(sunset_min);      
                }
        if (mode0_seqcnt>=46 && mode0_seqcnt<=55)
                {                                            //next target angle and time
                lcd_gotoxy(0,0);
                lcd_putsf("next time/angle:");
                lcd_gotoxy(0,1);
                display_day2(target_time);
                lcd_putchar('/');
                display_angle(target_angle);      
                }
        if (mode0_seqcnt>=56 && mode0_seqcnt<=65)             //pv volt and current
                { 
                lcd_gotoxy(0,0);
                lcd_putsf("charge: ");
                if(boost_fl)
                lcd_putsf("boost    ");
                else if (float_fl)
                lcd_putsf("equal..  ");
                else
                lcd_putsf("trickle  ");
                lcd_gotoxy(0,1);
                 lcd_putsf("date: ");       
                display_date();  
  
                }
        if (mode0_seqcnt>=66 && mode0_seqcnt<=75)             //pv volt and current
                { 
                lcd_gotoxy(0,0);
                lcd_putsf("start: ");
                display_angle(low_angle);
                lcd_gotoxy(0,1);
                lcd_putsf("end  : ");       
                display_angle(high_angle);
                }
        if (mode0_seqcnt>=76 && mode0_seqcnt<=85)             //pv volt and current
                { 
                lcd_gotoxy(0,0);
                lcd_putsf("Bat. Volt: ");
                display_analog1(adc_battery/10);
                lcd_putchar('V');
                lcd_gotoxy(0,1);
                lcd_putsf("Chrge cur: ");       
                display_analog1(adc_chargecurrent/10);
                lcd_putchar('A');
                }
         
         lcd_gotoxy(0,2);
//                lcd_putsf("sunrise: ");
//                display_time2(riset*100);          
//                lcd_gotoxy(0,3);
//                lcd_putsf("sunset: ");       
//                display_time2(settm*100);    



         display_analog(adc_pvolt);
         display_analog(adc_battery);
         if (boost_fl) lcd_putsf("boost");
         if(float_fl) lcd_putsf("equal.");
         if(trickle_fl) lcd_putsf("trickle");       
         lcd_gotoxy(0,3);
         if (shutdown) lcd_putsf(" ON ");
         else lcd_putsf("OFF ");     
         display_analog(adc_chargecurrent);
         lcd_putsf(" ");
         display_analog(OCR1A);
        }
if (mode == 1 && !manual_fl)
        {
        lcd_gotoxy(0,1);
        switch(set)
        {
        case 0: display_time();
                break;
        case 1: display_date();
                break;
        case 2: display_latlong(set_latit);
                lcd_putsf(" Deg.   "); 
                break;
        case 3: display_latlong(set_longitude);
                lcd_putsf(" Deg.  ");
                break;
        case 4: put_message2(time_interval);
                lcd_putsf(" minutes  ");
                break;
        case 5: lcd_putsf("GMT ");
                display_latlong(set_timezone);
                break;        
        } 
           switch (item1)
                {
                case 0: blink_data = hour;
                        blink_locx =0;
                        blink_locy =1;  
                        break;
                case 1: blink_data = minute;
                        blink_locx =3;
                        blink_locy =1;  
                        break;
                case 2: blink_data = second;
                        blink_locx =6;
                        blink_locy =1;  
                        break;
                case 3: blink_data = day;
                        blink_locx =0;
                        blink_locy =1;  
                        break;
                case 4: blink_data = month;
                        blink_locx =3;
                        blink_locy =1;
                        break;
                case 5: blink_data = year;
                        blink_locx =8;
                        blink_locy =1;
                        break;
                case 6: char_latitude = blink_data = (abs(set_latit)/100)%100 ;
                        blink_locx =2;
                        blink_locy =1;
                        break;
                case 7: char_latitude = blink_data = abs(set_latit)%100 ;
                        blink_locx =5;
                        blink_locy =1;
                        break;
                case 8: char_longitude = blink_data = (abs(set_longitude)/100)%100 ;
                        blink_locx =2;
                        blink_locy =1;
                        break;
                case 9: char_longitude = blink_data = abs(set_longitude)%100 ;
                        blink_locx =5;
                        blink_locy =1;
                        break;
                case 10:blink_data = time_interval;
                        blink_locx =0;
                        blink_locy =1;
                        break;
                case 11:char_timezone = blink_data = (abs(set_timezone)/100)%100 ;
                        blink_locx =6;
                        blink_locy =1;
                        break;
                case 12:char_timezone =  blink_data = abs(set_timezone)%100;
                        blink_locx = 9;
                        blink_locy =1;
                        break;
                        
                }       
        }
if (manual_fl)
    {
    lcd_gotoxy(0,0);
                lcd_putsf("* Manual Mode * ");

//    lcd_putsf("manual mode");
    lcd_gotoxy(0,1);
    lcd_putsf("angle: ");       
    display_angle(angle);  
    lcd_putsf(" deg.   ");    
    }


}




/*
void adc3421_init(void)
{                      
i2c_start();
i2c_write(0xd2);
delay_ms(1);
i2c_write(0x9c);   //18 bit mode 1v/v
 i2c_stop();
}

long int adc3421_read(void)
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
//return ((long)rand()+32000);
} 

void write_2464(unsigned int address,char data1,char data2,char data3,char data4,char data5,char data6,char data7,char data8,char data9,char data10,char data11,char data12,char data13,char data14)
{
unsigned int adhi,adlo;
adhi = address/256;
adlo = address%256;
i2c_start();
i2c_write(0xa0);               // write command
i2c_write(adhi);
i2c_write(adlo);
i2c_write(data1);
i2c_write(data2);
i2c_write(data3);
i2c_write(data4);
i2c_write(data5);
i2c_write(data6);
i2c_write(data7);
i2c_write(data8);
i2c_write(data9);
i2c_write(data10);
i2c_write(data11);
i2c_write(data12);
i2c_write(data13);
i2c_write(data14);
delay_ms(1000);

i2c_stop();
delay_ms(1);
}
*/
/*

void read_2464(int addr)
{
i2c_start();
i2c_write(0xa0);               // write command
i2c_write(addr/256);
i2c_write(addr%256);
//i2c_stop();
i2c_start();
i2c_write(0xa1);             //read address
record_buffer[0] = i2c_read(1);
record_buffer[1] = i2c_read(1);
record_buffer[2] = i2c_read(1);
record_buffer[3] = i2c_read(1);
record_buffer[4] = i2c_read(1);
record_buffer[5] = i2c_read(1);
record_buffer[6] = i2c_read(1);
record_buffer[7] = i2c_read(1);
record_buffer[8] = i2c_read(1);
record_buffer[9] = i2c_read(1);
record_buffer[10] = i2c_read(1);
record_buffer[11] = i2c_read(1);
record_buffer[12] = i2c_read(1);
record_buffer[13] = i2c_read(0);
i2c_stop();
}

*/


void cal_angle(void)
{
float sensitivity,angle_rad;

sensitivity = span_adc - zero_adc;
angle_rad = asin(((float)adc_angle - (float)zero_adc) /sensitivity);
//angle_sum = angle_sum + ((angle_rad * 572.957795) + 900) ;
angle=((angle_rad * 572.957795) + 900) ;

angle_cnt++;
/*
if (angle_cnt >=4)
{
angle_cnt =0;
angle = angle_sum/4;
angle_sum =0;
}
*///angle = (double)adc_buffer - (double)zero_adc /sensitivity ;
}

void target_cal(void)
{
long  a;
int y=1;
time_elap = to_minute(hour,minute);      // convert real time to minutes
if (time_elap > sunrise_min)
        {
        for (y=1;y<=150;y++)
        {
        if (time_elap <= (sunrise_min +(time_interval*y)))
                {                                                          
                target_time = sunrise_min +((long)(time_interval)*y);
                break;
                }
        }
        
        if (target_time > sunset_min) target_time = sunset_min;
        if (target_time < sunrise_min) target_time = sunrise_min;
        
        a = target_time - sunrise_min;     
        target_angle = (1800 * a)/ (long)daytime;
        if (target_angle > high_angle) target_angle = high_angle;
        if (target_angle < low_angle) target_angle = low_angle;
// bring the panel to 90 degrees (horizontal position ) 10 minutes after sunset.
        if ((time_elap < sunrise_min) || (time_elap>sunset_min))
            {
            target_time = sunset_min+10;
            target_angle = 900;     // target angle is 90.0 degrees
            }

        if ((time_elap == target_time) && !start_fl && !end_fl)
        {
        start_fl =1;
        }
        
        }
}



void current_control(int cur,int volt_limit,int PV_limit)
{
if (read_adcfl)                 // check if all adc readings over
{
read_adcfl =0;
if (adc_battery < volt_limit && adc_pvolt >= PV_limit)
{
        
if (adc_chargecurrent < cur-1) 
{
        if((adc_battery < volt_limit-50) &&(OCR1A < 500)) ocr_inc =10;
        else
        ocr_inc =1;  
OCR1A+=ocr_inc;   //hysterisis of +/- 0.02A
}
if (adc_chargecurrent > cur+1 && OCR1A != 0x000) 
{
        if((adc_battery > volt_limit+50)&&(OCR1A > 20)) ocr_inc =10;
        else
        ocr_inc =1;  
OCR1A-=ocr_inc;
}
if (OCR1A > 500) OCR1A = 500;
}
else if(adc_pvolt<= adc_battery+200)
{
OCR1A -=10;
if (OCR1A < 200) OCR1A =200;
}
else
{
if ((OCR1A < 0x05) ||((adc_pvolt <=(adc_battery+200)) && trickle_fl && float_fl)) OCR1A -=ocr_inc;
}
}
}


void voltage_control(int vol,int cur_limit,int PV_limit)
{
if (read_adcfl)                 // check if all adc readings over
{
read_adcfl =0;
            

if(adc_chargecurrent < cur_limit && adc_pvolt >= PV_limit)
{
if (adc_battery <= vol-1) 
{
        if((adc_battery < vol-50)&&(OCR1A < 500)) ocr_inc =10;
        else
        ocr_inc =1;  

OCR1A+=ocr_inc;   //hysterisis of +/- 0.02A
}
if (adc_battery > vol+1 && (OCR1A !=0x000)) 
{
        if ((adc_battery > vol+50)&&(OCR1A > 20)) ocr_inc =10;
        else
        ocr_inc =1;  


OCR1A-=ocr_inc;
}
if (OCR1A > 500) OCR1A = 500;
}
else if(adc_pvolt<= adc_battery + 200)
{
OCR1A-=10;
if (OCR1A < 200) OCR1A =200;
}
else
{
if ((OCR1A <= 0x05) || ((adc_pvolt <= (adc_battery+200))) && trickle_fl && float_fl) OCR1A-=1;
}
}
}



void battery_control(void)
{
//int a;
if (boost_fl)
{
//a = to_min(set_boost_timeout);
control_buck_on();
current_control(boost_current,boost_voltage,adc_battery + 100);
if ((adc_battery >= boost_voltage) || (boost_time >= boost_timeout))
{
boost_fl=0;
float_fl =1;
trickle_fl =0;
}
}

if (float_fl)
{
//a= set_float_timeout;
control_buck_on();     
voltage_control(boost_voltage,boost_current,adc_battery+100);
if (((adc_chargecurrent < set_capacity/50) && (adc_battery >=equal_voltage))||(float_time > float_timeout))                  // threshold current < 2% of capacity
{
boost_fl =0;
float_fl =0;
trickle_fl =1;
}
}
if (trickle_fl)
{
control_buck_on();     
voltage_control(equal_voltage,trickle_current,adc_battery+100);
if (adc_battery < cutoff_voltage)
{
boost_fl =1;
trickle_fl =0;
float_fl=0;
}
}
}

/*
void check_lowbat(void)
{
if (adc_battery < cutoff_voltage)
bat_cur =1;         // turn off load output
if (adc_battery > cutoff_voltage+100)
bat_cur =0;
}
*/




// External Interrupt 0 service routine
interrupt [EXT_INT0] void ext_int0_isr(void)
{
int night_time;

// Place your code here
rise_set((long)(day),(long)(month),(long)year+2000,12,(float)(set_latit)/100,(float)(set_longitude)/100,(float)(set_timezone)/100) ;
// Place your code here
if (mode ==0)
{
/*log_cnt++;
if(log_cnt >= log_interval)
{
log_cnt =0;
if(log_fl) print_realtime();
}
*/
rtc_get_time(&hour,&minute,&second);
rtc_get_date(&day,&month,&year);
}
if (boost_fl) boost_time++;
if (float_fl) float_time++;
adc_fl =1;
led2=~relay1;
led1=~relay2;
//led3=~err_fl;
//led4= ~(boost_fl | float_fl) ;
//led5= ~trickle_fl;
//if (adc_battery < cutoff_voltage) led6 =0;
//else led6 =1; 
led_blinkfl = ~ led_blinkfl;

//display_update();
bright_cnt++;
if (bright_cnt > 20) bright_cnt =20;
if (bright_cnt<20 && !err_fl2) backlight =0;         // not valid for low battery
else backlight =1;
program_timeout++;
if (program_timeout >=30) program_timeout =30;
if (program_timeout ==29)
clear_to_default();     //reset to normal mode if no key is pressed for more than 29 seconds.

if (end_fl)
{
end_cnt++;
if (end_cnt >=61)
{
end_fl =0;
end_cnt =0;
}
}
// added code to check if time is between sunset and sunrise. if yes, invoke sleep
// sleep/standby mode.
night_time = to_minute(hour,minute);      // convert real time to minutes
if (((night_time > sunset_min +30)|| (night_time < sunrise_min - 30))&& key1 && key2 && key3 && key4)
        {
        sleep_counter++;
        if (sleep_counter >=30)
        {
        sleep_counter =30;
        relay1=relay2=0;        //turn off relay  
        backlight =1;                    //turn backlight off
        led1=led2=led3=led4=led5=led6 =1; //turn led off   
        control_buck_off() ;
        lcd_gotoxy(0,0);
        lcd_putsf("  NIGHT MODE  ");
        lcd_gotoxy(0,1);
        display_time();
        sleep_fl =1;  
//        sleep_enable();
//        idle();
        }
        }
else
{
sleep_counter =0;
sleep_fl=0;
}
}
/*
#ifndef RXB8
#define RXB8 1
#endif

#ifndef TXB8
#define TXB8 0
#endif

#ifndef UPE
#define UPE 2
#endif

#ifndef DOR
#define DOR 3
#endif

#ifndef FE
#define FE 4
#endif

#ifndef UDRE
#define UDRE 5
#endif

#ifndef RXC
#define RXC 7
#endif

#define FRAMING_ERROR (1<<FE)
#define PARITY_ERROR (1<<UPE)
#define DATA_OVERRUN (1<<DOR)
#define DATA_REGISTER_EMPTY (1<<UDRE)
#define RX_COMPLETE (1<<RXC)

// USART Receiver buffer
#define RX_BUFFER_SIZE 8
char rx_buffer[RX_BUFFER_SIZE];

#if RX_BUFFER_SIZE<256
unsigned char rx_wr_index,rx_rd_index,rx_counter;
#else
unsigned int rx_wr_index,rx_rd_index,rx_counter;
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
   rx_buffer[rx_wr_index]=data;
   if (++rx_wr_index == RX_BUFFER_SIZE) rx_wr_index=0;
   if (++rx_counter == RX_BUFFER_SIZE)
      {
      rx_counter=0;
      rx_buffer_overflow=1;
      };
   };
}

#ifndef _DEBUG_TERMINAL_IO_
// Get a character from the USART Receiver buffer
#define _ALTERNATE_GETCHAR_
#pragma used+
char getchar(void)
{
char data;
while (rx_counter==0);
data=rx_buffer[rx_rd_index];
if (++rx_rd_index == RX_BUFFER_SIZE) rx_rd_index=0;
#asm("cli")
--rx_counter;
#asm("sei")
return data;
}
#pragma used-
#endif

// USART Transmitter buffer
#define TX_BUFFER_SIZE 8
char tx_buffer[TX_BUFFER_SIZE];

#if TX_BUFFER_SIZE<256
unsigned char tx_wr_index,tx_rd_index,tx_counter;
#else
unsigned int tx_wr_index,tx_rd_index,tx_counter;
#endif

// USART Transmitter interrupt service routine
interrupt [USART_TXC] void usart_tx_isr(void)
{
if (tx_counter)
   {
   --tx_counter;
   UDR=tx_buffer[tx_rd_index];
   if (++tx_rd_index == TX_BUFFER_SIZE) tx_rd_index=0;
   };
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
   tx_buffer[tx_wr_index]=c;
   if (++tx_wr_index == TX_BUFFER_SIZE) tx_wr_index=0;
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

// Declare your global variables here

*/

void eeprom_transfer(void)
{
span_adc = e_span_adc;
zero_adc = e_zero_adc;
time_interval = e_time_interval;
low_angle = e_low_angle;
high_angle = e_high_angle;
set_latit = e_set_latit;
set_longitude = e_set_longitude;
set_timezone = e_set_timezone;
}


void init(void)
{// Declare your local variables here

// Input/Output Ports initialization
// Port A initialization
// Func7=In Func6=In Func5=In Func4=In Func3=In Func2=In Func1=In Func0=In 
// State7=T State6=T State5=T State4=T State3=P State2=P State1=P State0=P 
PORTA=0xFF;
DDRA=0x20;

// Port B initialization
// Func7=In Func6=In Func5=In Func4=In Func3=In Func2=In Func1=In Func0=In 
// State7=T State6=T State5=T State4=T State3=T State2=T State1=T State0=T 
PORTB=0x08;  //pb.3 is bcklight
DDRB=0x08;

// Port C initialization
// Func7=Out Func6=Out Func5=Out Func4=Out Func3=Out Func2=Out Func1=Out Func0=Out 
// State7=0 State6=0 State5=0 State4=1 State3=1 State2=1 State1=1 State0=0 
PORTC=0x1E;
DDRC=0xFF;

// Port D initialization
// Func7=Out Func6=Out Func5=Out Func4=Out Func3=Out Func2=In Func1=In Func0=In 
// State7=0 State6=1 State5=0 State4=0 State3=1 State2=T State1=T State0=T 
PORTD=0x4C;
DDRD=0xF8;

// Timer/Counter 0 initialization
// Clock source: System Clock
// Clock value: Timer 0 Stopped
// Mode: Normal top=FFh
// OC0 output: Disconnected
TCCR0=0x00;
TCNT0=0x00;
OCR0=0x00;

// Timer/Counter 1 initialization
// Clock source: System Clock
// Clock value: 11059,200 kHz
// Mode: Fast PWM top=01FFh
// OC1A output: Non-Inv.
// OC1B output: Non-Inv.
// Noise Canceler: Off
// Input Capture on Falling Edge
// Timer1 Overflow Interrupt: Off
// Input Capture Interrupt: Off
// Compare A Match Interrupt: Off
// Compare B Match Interrupt: Off
TCCR1A=0x82;
TCCR1B=0x09;
TCNT1H=0x00;
TCNT1L=0x00;
ICR1H=0x00;
ICR1L=0x00;
OCR1AH=0x00;
OCR1AL=0xFF;
OCR1BH=0x00;
OCR1BL=0xFF;
//control_buck_off();
//control_boost_off();

// Timer/Counter 2 initialization
// Clock source: System Clock
// Clock value: Timer2 Stopped
// Mode: Normal top=FFh
// OC2 output: Disconnected
ASSR=0x00;
TCCR2=0x00;
TCNT2=0x00;
OCR2=0x00;

// External Interrupt(s) initialization
// INT0: On
// INT0 Mode: Falling Edge
// INT1: Off
// INT2: Off
GICR|=0x40;
MCUCR=0x02;
MCUCSR=0x00;
GIFR=0x40;

// Timer(s)/Counter(s) Interrupt(s) initialization
TIMSK=0x00;
/*
// USART initialization
// Communication Parameters: 8 Data, 1 Stop, No Parity
// USART Receiver: On
// USART Transmitter: On
// USART Mode: Asynchronous
// USART Baud Rate: 9600
UCSRA=0x00;
UCSRB=0xD8;
UCSRC=0x86;
UBRRH=0x00;
UBRRL=0x47;
*/
// Analog Comparator initialization
// Analog Comparator: Off
// Analog Comparator Input Capture by Timer/Counter 1: Off
ACSR=0x80;
SFIOR=0x00;

// I2C Bus initialization
i2c_init();
delay_ms(1000);

// DS1307 Real Time Clock initialization
// Square wave output on pin SQW/OUT: Off
// SQW/OUT pin state: 1
rtc_init(0,1,0);

// LCD module initialization
lcd_init(16);
delay_ms(100);
adc3421_init();
boost_fl =1;
float_fl = trickle_fl =0;
define_char(char0,0);
// Global enable interrupts
#asm("sei")
sleep_fl =0;
}

void panel_movement(void)
{
int panel_cutoff;
bit flag_01;
int angle_old;
if(start_fl)
        {
               
        lcd_clear();
if (angle < target_angle)
        {
        timeout_cnt =0;
        inf_fl =1;
        angle_old = angle;
        panel_cutoff =0;
        while(angle < target_angle && inf_fl)
                { 
  // check routine for low voltage . if battery voltage drops below
  // 10.8V, then display low battery indication. if it recovers within 20 seconds
  // then, get back, else break.
                if (adc_battery < cutoff_voltage)
                panel_cutoff++;
                else
                panel_cutoff =0;        //reset                      
                
                if (panel_cutoff > 100 && panel_cutoff < 5000) //15 seconds
                        {
                        lcd_gotoxy(0,1);
                        lcd_putsf("!!LOW BATTERY!!");
                        flag_01 =1;
//                        delay_ms(500);
                        } 
                        else
                        flag_01 =0; // to display low battery only 
                        
                if (panel_cutoff > 5000)
                        {
                        lcd_clear();
                        err_fl =1;
                        lcd_putsf("LOW BATTERY");
                        lcd_gotoxy(0,1);
                        lcd_putsf("!!!ERROR!!!    ");        
                        relay1=relay2 =0;
                        delay_ms(2000);
                        err_fl =0;
                        inf_fl =0;  // break while loop
                         }                                                        

/////////////////////////////////////////////////////////////////////                        
 //               delay_ms(1);
 //               adc_buffer = adc3421_read();
                read_adc();
                cal_angle(); 
                lcd_gotoxy(0,0);           
                lcd_putsf("ang: ");
                display_angle(angle);
                lcd_gotoxy(0,1);
                if (!flag_01)
                {
                lcd_putsf("tar: ");
                display_angle(target_angle);
                }
                relay1=0;
                relay2=1;
                timeout_cnt++;
                if(timeout_cnt >22000)      //once every 30 seconds
                        {
                        timeout_cnt =0;
                        if (!((angle < angle_old - 20) || (angle > angle_old +20)))
                            {
                            lcd_clear();
                            err_fl =1;
                            lcd_putsf("mech. error");
                            relay1=relay2 =0;
                            delay_ms(3000);
                            err_fl =0;
                            inf_fl =0;  // break while loop
                            }
                        else
                            {
                            angle_old = angle;
                            }
                        }
                }
        start_fl =0;
        end_fl =1;        
        relay1=relay2=0;
        }
else if (angle > target_angle +20)     //hysterisis of 2 degrees before action
        {
        timeout_cnt =0;
        inf_fl =1;  
        angle_old = angle; 
        panel_cutoff =0;
        while(angle > target_angle && inf_fl)
                { 
  // check routine for low voltage . if battery voltage drops below
  // 10.8V, then display low battery indication. if it recovers within 20 seconds
  // then, get back, else break.
                if (adc_battery < cutoff_voltage)
                panel_cutoff++;
                else
                panel_cutoff =0;        //reset                      
                
                if (panel_cutoff > 100 && panel_cutoff < 5000) //15 seconds
                        {
                        lcd_gotoxy(0,1);
                        lcd_putsf("!!LOW BATTERY!!"); 
                        flag_01 =1;
//                        delay_ms(500);
                        }
                else
                        flag_01 =0;
                if (panel_cutoff > 5000)
                        {                              
                        panel_cutoff =0;
                        lcd_clear();
                        err_fl =1;
                        lcd_putsf("LOW BATTERY");
                        lcd_gotoxy(0,1);
                        lcd_putsf("!!!ERROR!!!    ");        
                        relay1=relay2 =0;
                        delay_ms(2000);
                        err_fl =0;
                        inf_fl =0;  // break while loop
                         }                                                        

/////////////////////////////////////////////////////////////////////    
//                delay_ms(1);
//                adc_buffer = adc3421_read();
                read_adc();
                cal_angle(); 
                lcd_gotoxy(0,0);           
                lcd_putsf("ang: ");
                display_angle(angle);
                lcd_gotoxy(0,1);
                if (!flag_01)
                {
                lcd_putsf("tar: ");
                display_angle(target_angle);
                }
                relay1=1;
                relay2=0;
                timeout_cnt++;
                if(timeout_cnt >22000)
                        {
                        timeout_cnt =0;
                        if (!((angle < angle_old - 20) || (angle > angle_old +20)))
                            {  
                             lcd_clear();
                            err_fl =1;
                            lcd_putsf("mech. error");
                            relay1=relay2 =0;
                            delay_ms(3000);
                            err_fl =0;
                            inf_fl =0;  // break while loop
                            }
                        else
                            {
                            angle_old = angle;
                            }
                        
                        }
                }
        start_fl =0;
        end_fl =1;        
        relay1=relay2=0;
        } 
else            
        start_fl =0;
        
        end_fl =1;        
        relay1=relay2=0;
//        #asm("cli")
//        write_2464(record_cnt,angle/100,angle%100,target_angle/100,target_angle%100,hour,minute,day,month,adc_pvolt/100,adc_pvolt%100,adc_chargecurrent/100,adc_chargecurrent%100,adc_battery/100,adc_battery%100);
//        #asm("sei")
        record_cnt +=14;
        }
}

/*
void check_print(void)
{
int i,j=0;
if(printkey_fl)
    {
    lcd_clear();
    lcd_putsf("printing");
    lcd_gotoxy(0,1);
    printkey_fl =0;
    if (record_cnt>13)
        {
            #asm("cli") 
        putchar(0x0a);
        putchar(0x0d);
        putsf("angle  target  time     date       PV   chargecur.   batvolt");
//        putchar(0x0a);
//        putchar(0x0d);
        for(i=0;i<=(record_cnt-1);i+=14)
            {
            j++;
            if (j>=15)                                      //lower display printing algo
                        {
                        j=0;
                        lcd_gotoxy(0,1);
                        lcd_putsf("               ");
                        lcd_gotoxy(0,1);        
                        }
            lcd_putchar('.');
            read_2464(i);    
            delay_ms(200);
            putchar((record_buffer[0]/10)+48);
            putchar((record_buffer[0]%10)+48);
            putchar((record_buffer[1]/10)+48);
            putchar('.');
            putchar((record_buffer[1]%10)+48);
            putchar(' ');
            putchar(' ');

            putchar((record_buffer[2]/10)+48);
            putchar((record_buffer[2]%10)+48);
            putchar((record_buffer[3]/10)+48);
            putchar('.');
            putchar((record_buffer[3]%10)+48);
            putchar(' ');
            putchar(' ');

            putchar((record_buffer[4]/10)+48);
            putchar((record_buffer[4]%10)+48);
            putchar(':');
            putchar((record_buffer[5]/10)+48);
            putchar((record_buffer[5]%10)+48);
            putchar(' ');
            putchar(' ');

            putchar((record_buffer[6]/10)+48);
            putchar((record_buffer[6]%10)+48);
            putchar('-');
            putchar((record_buffer[7]/10)+48);
            putchar((record_buffer[7]%10)+48);
            putchar('-');
            putchar('2');
            putchar('0');
            putchar('1');
            putchar('3');
                        
            putchar(' ');
            putchar(' ');

            putchar((record_buffer[8]/10)+48);
            putchar((record_buffer[8]%10)+48);
            putchar('.');
            putchar((record_buffer[9]/10)+48);
            putchar((record_buffer[9]%10)+48);
            putchar('V');
            putchar(' ');

            putchar((record_buffer[10]/10)+48);
            putchar('.');
            putchar((record_buffer[10]%10)+48);
            putchar((record_buffer[11]/10)+48);
            putchar((record_buffer[11]%10)+48);
            putchar('A');
            putchar(' ');

            putchar((record_buffer[12]/10)+48);
            putchar((record_buffer[12]%10)+48);
            putchar('.');
            putchar((record_buffer[13]/10)+48);
            putchar((record_buffer[13]%10)+48);
            putchar('V');
            putchar(' ');
            putsf(" ");//new line character

            }
        #asm("sei")
        lcd_clear();
//        record_cnt =0;          //reset record count to 00;
        }

    } 
}
*/
void error_check()
{
if (adc_pvolt < 1000 || adc_battery <300)
err_fl1 = 1;
else
err_fl1=0;
if (adc_battery < cutoff_voltage)
err_fl2 =1;
if(err_fl2 && adc_battery > reconnect_voltage)//hysterisis for reconnect 
err_fl2 =0;
}

void led_check()
{
led2=~relay1;
led1=~relay2;
if (err_fl || err_fl1)
led3 =0;
else
led3 =1;
        if (!err_fl1)
            {
            if (boost_fl)
            led4 =0;
            else if (float_fl)
            led4 = led_blinkfl;
            else
            led4 =1;
            led5= ~trickle_fl;
          }
        else
            {
            led4 = led5 =1;
            }
       if (adc_battery < cutoff_voltage) led6 =0;       //low battery indication
       else led6 =1; 
  
}


/*
void print_analog(int a,short int decimal)
{
putchar((a/1000)+48);
a =a%1000;
if (decimal == 1) putchar('.');
putchar((a/100)+48);
a = a%100;
if (decimal == 2) putchar('.');
putchar((a/10)+48);
if (decimal ==3) putchar('.');
putchar((a%10)+48);
}
*/
/*
void print_control()
{
char data;
while (rx_counter)                     //receive buffer is not empty
{
data = getchar();
switch (data)
            {
            case 'p':   printkey_fl =1;    
                        delay_ms(100);
                        break;
            case 'r':   putsf("no. of records stored :");
                        print_analog(record_cnt/14,0);
                        putsf(" ");
                        break;
            case 's':   record_cnt =0;
                        putsf("records reset!!!");
                        break;
            case 'v':   putsf("Panel voltage:");
                        print_analog(adc_pvolt,2);
                        putchar('V'); 
                        putsf(" ");
                        break;
            case 'b':   putsf("Battery voltage:");
                        print_analog(adc_battery,2);
                        putchar('V');
                        putsf(" ");
                        break;            
            case 'c':   putsf("charge current:");
                        print_analog(adc_chargecurrent,2);
                        putchar('A');
                        putsf(" ");
                        break; 
            case 'l':   log_fl=1; 
                        putsf("angle  target  time     date       PV   current  batvolt");
                        putsf("logging started...");
                        break;
            case 'm':   log_fl=0;
                        putsf("logging stopped");
                        break;                  
            default:    break;
              }
}
}
*/

/*
void print_realtime()
{
            print_analog(angle,3);
            putchar('d');
            putchar(' ');

            print_analog(target_angle,3);
            putchar('d');
            putchar(' ');

            putchar((hour/10)+48);
            putchar((hour%10)+48);
            putchar(':');
            putchar((minute/10)+48);
            putchar((minute%10)+48);
            putchar(' ');
            putchar(' ');

            putchar((day/10)+48);
            putchar((day%10)+48);
            putchar('-');
            putchar((month/10)+48);
            putchar((month%10)+48);
            putchar('-');
            putchar('2');
            putchar('0');
            putchar('1');
            putchar('3');
                        
            putchar(' ');
            putchar(' ');

            print_analog(adc_pvolt,2);
            putchar('V');
            putchar(' ');

            print_analog(adc_chargecurrent,2);
            putchar('A');
            putchar(' ');

            print_analog(adc_battery,2);
            putchar('V');
            putchar(' ');
            putsf(" ");//new line character
}

 */



void WDT_off(void)
{
/* reset WDT */
#asm("wdr")
/* Write logical one to WDTOE and WDE */
WDTCR |= (1<<4) | (1<<3);
/* Turn off WDT */
WDTCR = 0x00;
}

void main(void)
{
// Declare your local variables here
#asm("cli")
WDT_off();
#asm ("sei")

init();
// Global enable interrupts
#asm("sei")
calibuser = calibfact =0;
//if (!key1 && key2 && key3 && key4) calibuser =1;
if (key1 && key2 && !key3 && !key4) calibfact =1;
lcd_clear();
if (!calibfact)
{
lcd_putsf("* SINGLE AXIS  *");
lcd_gotoxy(0,1);
lcd_putsf("*SOLAR TRACKER *");
delay_ms(2000);
lcd_clear();
//lcd_putsf("Sai Babuji Infra");
//lcd_gotoxy(0,1);
//lcd_putsf("Projects Pvt Ltd");
//delay_ms(2000);
}
if(calibuser)
{
lcd_putsf("the panel ");
lcd_gotoxy(0,1);
lcd_putsf("calibration mode");
delay_ms(3000);
lcd_gotoxy(0,0);
lcd_putsf("inc > inch up");
lcd_gotoxy(0,1);
lcd_putsf("dec > inch down");
delay_ms(3000);
lcd_gotoxy(0,0);
lcd_putsf("set-> enter low");
lcd_gotoxy(0,1);
lcd_putsf("shf-> enter high");
delay_ms(3000);
}
if(calibfact)
{
lcd_putsf("adc: ");
lcd_gotoxy(0,1);
lcd_putsf("angle:");
}


OCR1A = 0x13f;
//rtc_set_time(12,13,26);
delay_ms(10);
eeprom_transfer();
err_fl1= err_fl2 = err_fl3 = 0;
adc_battery = 1300;     //default 13.00 v for low battery hysterisis initial condition.
while (1)
{  
if (sleep_fl ==1)
{
sleep_enable();
idle();
//delay_ms(500);
}
else
{   
sleep_disable(); 
        get_key(); 
//        ir_cnt++;
//        if(ir_cnt>500)
//        {
//        ir_cnt =0;
//        get_irkey();
//        }
//normal run mode with configuration setting and real time display on power on.
    if(!calibuser || !calibfact )    
        {   
//        print_control(); 
 
        error_check();
        led_check();
        led2 = ~relay1;
        led1 = ~relay2;
        check_mode();
        read_adc();            
        delay_ms(1); 
        target_cal();
        check_increment();
        check_decrement();
        check_shift();
        check_enter();
//        check_print();
        blink_control();
        display_cnt++;
        if (display_cnt > 200)
                {
                display_cnt =0;
                display_update();
                cal_angle();
                }
        
        if (mode==0 && !manual_fl && !err_fl2 && !err_fl3) panel_movement();   
        if (manual_fl)
        {
        if (err_fl2)
            {
            delay_ms(1000);
            lcd_gotoxy(0,0);
            lcd_putsf("  LOW BATTERY   ");
            lcd_gotoxy(0,1);
            lcd_putsf("output disabled.");
            delay_ms(2000); 
            relay1 = relay2 = 0;        //turn off relay
            led1 = ~relay1;
            led2 = ~relay2;
            lcd_gotoxy(0,0);
            lcd_putsf(" Manual Mode    ");
            lcd_gotoxy(0,1);
            lcd_putsf("  exiting...... ");
            delay_ms(2000);
            manual_fl =0;
            }
        else
            {
            relay1 = ~key2;
            relay2 = ~key3;
            }
        
        }
//        if (adc_pvolt < adc_battery +200)
//        {
//        control_buck_off();
//        }             
//        else if (adc_battery < battery_voltage - 300)
//        {
//        control_buck_off();
//        }
        if((adc_battery > boost_voltage+100)||(adc_battery < 400)) // no battery connected condition
         {
         err_fl3 =1; 
         control_buck_off();                                          // displayed on display_update();
         }
         else if ((adc_battery >= 400)&&(adc_battery < cutoff_voltage)) // if battery voltage less than low bat, boost is re-initiated
        { 
        err_fl3 =0;
        trickle_fl = float_fl = 0;
        boost_fl =1;
        control_buck_on();
        battery_control();
        }
        else 
        {
        err_fl3 =0;
        control_buck_on();
        battery_control();
        }
        } 
        
         
///////////////////////////////////////////////////////// 


//calibration mode for user to set start and end angles
    if(calibuser)
    {
    lcd_clear();
    delay_ms(1);
    lcd_putsf("Set Start Angle");
    while(key4)
    { 
//    get_irkey();
    get_key();
    delay_ms(1);
        error_check();

//    lcd_gotoxy(0,0);
//    lcd_putsf("Set Start Angle")
    
//    put_message(zero_adc);
//    lcd_putsf("   ");
//    put_message(span_adc);
    lcd_gotoxy(0,1);
    lcd_putsf("angle:");
//    adc_buffer = adc3421_read();
    read_adc();
    relay1 = ~key2;
    relay2 = ~key3;
//    key2_fl = key3_fl =0;
    cal_angle();
    display_angle(angle);
    }
    e_low_angle = low_angle = angle;
    lcd_gotoxy(0,0);
    lcd_putsf("start angle ");
    lcd_gotoxy(0,1);
    lcd_putsf("accepted!");
    delay_ms(1500);
    
    lcd_clear();
    lcd_putsf("Set End Angle");
    while(key1)
    {  
//    get_irkey();
    get_key();
    delay_ms(1);
        error_check();

    lcd_gotoxy(0,1);
    lcd_putsf("angle:");
//    adc_buffer = adc3421_read();
    read_adc();
    relay1 = ~key2;
    relay2 = ~key3;
//    key2_fl = key3_fl =0;
    cal_angle();
    display_angle(angle);
    }
    e_high_angle = high_angle = angle;
    lcd_gotoxy(0,0);
    lcd_putsf("end angle ");
    lcd_gotoxy(0,1);
    lcd_putsf("accepted! ");
    delay_ms(3000);    
    calibuser =0;  
    lcd_clear();
    }    
////////////////////////////////////////////////////////////////////



 // factory setting for inclinometer and pv/current input calibration.

   if(calibfact)
    {
    record_cnt=0;   //reset record count for printing
    lcd_clear();
    mux1 =1;
    mux2 =0;
    mux3 =1;
    delay_ms(250);
    while(key2)
    {    
    adc_buffer = adc3421_read();
    cal_angle();
    lcd_gotoxy(0,0);
    delay_ms(500);    
    lcd_putsf("adc: ");
    put_message(adc_buffer);        
    lcd_gotoxy(0,1);
    lcd_putsf("angle: ");
    display_angle(angle);
    }
    e_zero_adc = zero_adc = adc_buffer;
    lcd_clear();   
    lcd_putsf("zero angle ");
    lcd_gotoxy(0,1);
    lcd_putsf("accepted! ");
    delay_ms(3000);
    lcd_clear();
    delay_ms(250);
    while(key1)
    {
    adc_buffer = adc3421_read();
    cal_angle();
    lcd_gotoxy(0,0); 
    delay_ms(500);
    lcd_putsf("adc: ");
    put_message(adc_buffer);        
    lcd_gotoxy(0,1);
    lcd_putsf("angle: ");
    display_angle(angle);
    }
    e_span_adc = span_adc = adc_buffer;
    lcd_clear(); 
    delay_ms(100);  
    lcd_putsf("span angle ");
    lcd_gotoxy(0,1);
    lcd_putsf("accepted! ");
    delay_ms(1500);
    calibfact =0;  
    lcd_clear();
    }    
///////////////////////////////////////////////


    }
    }; //end of while loop

}


