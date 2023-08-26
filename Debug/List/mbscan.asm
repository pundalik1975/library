
;CodeVisionAVR C Compiler V3.12 Advanced
;(C) Copyright 1998-2014 Pavel Haiduc, HP InfoTech s.r.l.
;http://www.hpinfotech.com

;Build configuration    : Debug
;Chip type              : ATmega32A
;Program type           : Application
;Clock frequency        : 11.059200 MHz
;Memory model           : Small
;Optimize for           : Speed
;(s)printf features     : int, width
;(s)scanf features      : int, width
;External RAM size      : 0
;Data Stack size        : 256 byte(s)
;Heap size              : 0 byte(s)
;Promote 'char' to 'int': Yes
;'char' is unsigned     : Yes
;8 bit enums            : Yes
;Global 'const' stored in FLASH: Yes
;Enhanced function parameter passing: Yes
;Enhanced core instructions: On
;Automatic register allocation for global variables: On
;Smart register allocation: On

	#define _MODEL_SMALL_

	#pragma AVRPART ADMIN PART_NAME ATmega32A
	#pragma AVRPART MEMORY PROG_FLASH 32768
	#pragma AVRPART MEMORY EEPROM 1024
	#pragma AVRPART MEMORY INT_SRAM SIZE 2048
	#pragma AVRPART MEMORY INT_SRAM START_ADDR 0x60

	#define CALL_SUPPORTED 1

	.LISTMAC
	.EQU UDRE=0x5
	.EQU RXC=0x7
	.EQU USR=0xB
	.EQU UDR=0xC
	.EQU SPSR=0xE
	.EQU SPDR=0xF
	.EQU EERE=0x0
	.EQU EEWE=0x1
	.EQU EEMWE=0x2
	.EQU EECR=0x1C
	.EQU EEDR=0x1D
	.EQU EEARL=0x1E
	.EQU EEARH=0x1F
	.EQU WDTCR=0x21
	.EQU MCUCR=0x35
	.EQU SPL=0x3D
	.EQU SPH=0x3E
	.EQU SREG=0x3F

	.DEF R0X0=R0
	.DEF R0X1=R1
	.DEF R0X2=R2
	.DEF R0X3=R3
	.DEF R0X4=R4
	.DEF R0X5=R5
	.DEF R0X6=R6
	.DEF R0X7=R7
	.DEF R0X8=R8
	.DEF R0X9=R9
	.DEF R0XA=R10
	.DEF R0XB=R11
	.DEF R0XC=R12
	.DEF R0XD=R13
	.DEF R0XE=R14
	.DEF R0XF=R15
	.DEF R0X10=R16
	.DEF R0X11=R17
	.DEF R0X12=R18
	.DEF R0X13=R19
	.DEF R0X14=R20
	.DEF R0X15=R21
	.DEF R0X16=R22
	.DEF R0X17=R23
	.DEF R0X18=R24
	.DEF R0X19=R25
	.DEF R0X1A=R26
	.DEF R0X1B=R27
	.DEF R0X1C=R28
	.DEF R0X1D=R29
	.DEF R0X1E=R30
	.DEF R0X1F=R31

	.EQU __SRAM_START=0x0060
	.EQU __SRAM_END=0x085F
	.EQU __DSTACK_SIZE=0x0100
	.EQU __HEAP_SIZE=0x0000
	.EQU __CLEAR_SRAM_SIZE=__SRAM_END-__SRAM_START+1

	.MACRO __CPD1N
	CPI  R30,LOW(@0)
	LDI  R26,HIGH(@0)
	CPC  R31,R26
	LDI  R26,BYTE3(@0)
	CPC  R22,R26
	LDI  R26,BYTE4(@0)
	CPC  R23,R26
	.ENDM

	.MACRO __CPD2N
	CPI  R26,LOW(@0)
	LDI  R30,HIGH(@0)
	CPC  R27,R30
	LDI  R30,BYTE3(@0)
	CPC  R24,R30
	LDI  R30,BYTE4(@0)
	CPC  R25,R30
	.ENDM

	.MACRO __CPWRR
	CP   R@0,R@2
	CPC  R@1,R@3
	.ENDM

	.MACRO __CPWRN
	CPI  R@0,LOW(@2)
	LDI  R30,HIGH(@2)
	CPC  R@1,R30
	.ENDM

	.MACRO __ADDB1MN
	SUBI R30,LOW(-@0-(@1))
	.ENDM

	.MACRO __ADDB2MN
	SUBI R26,LOW(-@0-(@1))
	.ENDM

	.MACRO __ADDW1MN
	SUBI R30,LOW(-@0-(@1))
	SBCI R31,HIGH(-@0-(@1))
	.ENDM

	.MACRO __ADDW2MN
	SUBI R26,LOW(-@0-(@1))
	SBCI R27,HIGH(-@0-(@1))
	.ENDM

	.MACRO __ADDW1FN
	SUBI R30,LOW(-2*@0-(@1))
	SBCI R31,HIGH(-2*@0-(@1))
	.ENDM

	.MACRO __ADDD1FN
	SUBI R30,LOW(-2*@0-(@1))
	SBCI R31,HIGH(-2*@0-(@1))
	SBCI R22,BYTE3(-2*@0-(@1))
	.ENDM

	.MACRO __ADDD1N
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	SBCI R22,BYTE3(-@0)
	SBCI R23,BYTE4(-@0)
	.ENDM

	.MACRO __ADDD2N
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	SBCI R24,BYTE3(-@0)
	SBCI R25,BYTE4(-@0)
	.ENDM

	.MACRO __SUBD1N
	SUBI R30,LOW(@0)
	SBCI R31,HIGH(@0)
	SBCI R22,BYTE3(@0)
	SBCI R23,BYTE4(@0)
	.ENDM

	.MACRO __SUBD2N
	SUBI R26,LOW(@0)
	SBCI R27,HIGH(@0)
	SBCI R24,BYTE3(@0)
	SBCI R25,BYTE4(@0)
	.ENDM

	.MACRO __ANDBMNN
	LDS  R30,@0+(@1)
	ANDI R30,LOW(@2)
	STS  @0+(@1),R30
	.ENDM

	.MACRO __ANDWMNN
	LDS  R30,@0+(@1)
	ANDI R30,LOW(@2)
	STS  @0+(@1),R30
	LDS  R30,@0+(@1)+1
	ANDI R30,HIGH(@2)
	STS  @0+(@1)+1,R30
	.ENDM

	.MACRO __ANDD1N
	ANDI R30,LOW(@0)
	ANDI R31,HIGH(@0)
	ANDI R22,BYTE3(@0)
	ANDI R23,BYTE4(@0)
	.ENDM

	.MACRO __ANDD2N
	ANDI R26,LOW(@0)
	ANDI R27,HIGH(@0)
	ANDI R24,BYTE3(@0)
	ANDI R25,BYTE4(@0)
	.ENDM

	.MACRO __ORBMNN
	LDS  R30,@0+(@1)
	ORI  R30,LOW(@2)
	STS  @0+(@1),R30
	.ENDM

	.MACRO __ORWMNN
	LDS  R30,@0+(@1)
	ORI  R30,LOW(@2)
	STS  @0+(@1),R30
	LDS  R30,@0+(@1)+1
	ORI  R30,HIGH(@2)
	STS  @0+(@1)+1,R30
	.ENDM

	.MACRO __ORD1N
	ORI  R30,LOW(@0)
	ORI  R31,HIGH(@0)
	ORI  R22,BYTE3(@0)
	ORI  R23,BYTE4(@0)
	.ENDM

	.MACRO __ORD2N
	ORI  R26,LOW(@0)
	ORI  R27,HIGH(@0)
	ORI  R24,BYTE3(@0)
	ORI  R25,BYTE4(@0)
	.ENDM

	.MACRO __DELAY_USB
	LDI  R24,LOW(@0)
__DELAY_USB_LOOP:
	DEC  R24
	BRNE __DELAY_USB_LOOP
	.ENDM

	.MACRO __DELAY_USW
	LDI  R24,LOW(@0)
	LDI  R25,HIGH(@0)
__DELAY_USW_LOOP:
	SBIW R24,1
	BRNE __DELAY_USW_LOOP
	.ENDM

	.MACRO __GETD1S
	LDD  R30,Y+@0
	LDD  R31,Y+@0+1
	LDD  R22,Y+@0+2
	LDD  R23,Y+@0+3
	.ENDM

	.MACRO __GETD2S
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	LDD  R24,Y+@0+2
	LDD  R25,Y+@0+3
	.ENDM

	.MACRO __PUTD1S
	STD  Y+@0,R30
	STD  Y+@0+1,R31
	STD  Y+@0+2,R22
	STD  Y+@0+3,R23
	.ENDM

	.MACRO __PUTD2S
	STD  Y+@0,R26
	STD  Y+@0+1,R27
	STD  Y+@0+2,R24
	STD  Y+@0+3,R25
	.ENDM

	.MACRO __PUTDZ2
	STD  Z+@0,R26
	STD  Z+@0+1,R27
	STD  Z+@0+2,R24
	STD  Z+@0+3,R25
	.ENDM

	.MACRO __CLRD1S
	STD  Y+@0,R30
	STD  Y+@0+1,R30
	STD  Y+@0+2,R30
	STD  Y+@0+3,R30
	.ENDM

	.MACRO __POINTB1MN
	LDI  R30,LOW(@0+(@1))
	.ENDM

	.MACRO __POINTW1MN
	LDI  R30,LOW(@0+(@1))
	LDI  R31,HIGH(@0+(@1))
	.ENDM

	.MACRO __POINTD1M
	LDI  R30,LOW(@0)
	LDI  R31,HIGH(@0)
	LDI  R22,BYTE3(@0)
	LDI  R23,BYTE4(@0)
	.ENDM

	.MACRO __POINTW1FN
	LDI  R30,LOW(2*@0+(@1))
	LDI  R31,HIGH(2*@0+(@1))
	.ENDM

	.MACRO __POINTD1FN
	LDI  R30,LOW(2*@0+(@1))
	LDI  R31,HIGH(2*@0+(@1))
	LDI  R22,BYTE3(2*@0+(@1))
	LDI  R23,BYTE4(2*@0+(@1))
	.ENDM

	.MACRO __POINTB2MN
	LDI  R26,LOW(@0+(@1))
	.ENDM

	.MACRO __POINTW2MN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	.ENDM

	.MACRO __POINTW2FN
	LDI  R26,LOW(2*@0+(@1))
	LDI  R27,HIGH(2*@0+(@1))
	.ENDM

	.MACRO __POINTD2FN
	LDI  R26,LOW(2*@0+(@1))
	LDI  R27,HIGH(2*@0+(@1))
	LDI  R24,BYTE3(2*@0+(@1))
	LDI  R25,BYTE4(2*@0+(@1))
	.ENDM

	.MACRO __POINTBRM
	LDI  R@0,LOW(@1)
	.ENDM

	.MACRO __POINTWRM
	LDI  R@0,LOW(@2)
	LDI  R@1,HIGH(@2)
	.ENDM

	.MACRO __POINTBRMN
	LDI  R@0,LOW(@1+(@2))
	.ENDM

	.MACRO __POINTWRMN
	LDI  R@0,LOW(@2+(@3))
	LDI  R@1,HIGH(@2+(@3))
	.ENDM

	.MACRO __POINTWRFN
	LDI  R@0,LOW(@2*2+(@3))
	LDI  R@1,HIGH(@2*2+(@3))
	.ENDM

	.MACRO __GETD1N
	LDI  R30,LOW(@0)
	LDI  R31,HIGH(@0)
	LDI  R22,BYTE3(@0)
	LDI  R23,BYTE4(@0)
	.ENDM

	.MACRO __GETD2N
	LDI  R26,LOW(@0)
	LDI  R27,HIGH(@0)
	LDI  R24,BYTE3(@0)
	LDI  R25,BYTE4(@0)
	.ENDM

	.MACRO __GETB1MN
	LDS  R30,@0+(@1)
	.ENDM

	.MACRO __GETB1HMN
	LDS  R31,@0+(@1)
	.ENDM

	.MACRO __GETW1MN
	LDS  R30,@0+(@1)
	LDS  R31,@0+(@1)+1
	.ENDM

	.MACRO __GETD1MN
	LDS  R30,@0+(@1)
	LDS  R31,@0+(@1)+1
	LDS  R22,@0+(@1)+2
	LDS  R23,@0+(@1)+3
	.ENDM

	.MACRO __GETBRMN
	LDS  R@0,@1+(@2)
	.ENDM

	.MACRO __GETWRMN
	LDS  R@0,@2+(@3)
	LDS  R@1,@2+(@3)+1
	.ENDM

	.MACRO __GETWRZ
	LDD  R@0,Z+@2
	LDD  R@1,Z+@2+1
	.ENDM

	.MACRO __GETD2Z
	LDD  R26,Z+@0
	LDD  R27,Z+@0+1
	LDD  R24,Z+@0+2
	LDD  R25,Z+@0+3
	.ENDM

	.MACRO __GETB2MN
	LDS  R26,@0+(@1)
	.ENDM

	.MACRO __GETW2MN
	LDS  R26,@0+(@1)
	LDS  R27,@0+(@1)+1
	.ENDM

	.MACRO __GETD2MN
	LDS  R26,@0+(@1)
	LDS  R27,@0+(@1)+1
	LDS  R24,@0+(@1)+2
	LDS  R25,@0+(@1)+3
	.ENDM

	.MACRO __PUTB1MN
	STS  @0+(@1),R30
	.ENDM

	.MACRO __PUTW1MN
	STS  @0+(@1),R30
	STS  @0+(@1)+1,R31
	.ENDM

	.MACRO __PUTD1MN
	STS  @0+(@1),R30
	STS  @0+(@1)+1,R31
	STS  @0+(@1)+2,R22
	STS  @0+(@1)+3,R23
	.ENDM

	.MACRO __PUTB1EN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMWRB
	.ENDM

	.MACRO __PUTW1EN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMWRW
	.ENDM

	.MACRO __PUTD1EN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMWRD
	.ENDM

	.MACRO __PUTBR0MN
	STS  @0+(@1),R0
	.ENDM

	.MACRO __PUTBMRN
	STS  @0+(@1),R@2
	.ENDM

	.MACRO __PUTWMRN
	STS  @0+(@1),R@2
	STS  @0+(@1)+1,R@3
	.ENDM

	.MACRO __PUTBZR
	STD  Z+@1,R@0
	.ENDM

	.MACRO __PUTWZR
	STD  Z+@2,R@0
	STD  Z+@2+1,R@1
	.ENDM

	.MACRO __GETW1R
	MOV  R30,R@0
	MOV  R31,R@1
	.ENDM

	.MACRO __GETW2R
	MOV  R26,R@0
	MOV  R27,R@1
	.ENDM

	.MACRO __GETWRN
	LDI  R@0,LOW(@2)
	LDI  R@1,HIGH(@2)
	.ENDM

	.MACRO __PUTW1R
	MOV  R@0,R30
	MOV  R@1,R31
	.ENDM

	.MACRO __PUTW2R
	MOV  R@0,R26
	MOV  R@1,R27
	.ENDM

	.MACRO __ADDWRN
	SUBI R@0,LOW(-@2)
	SBCI R@1,HIGH(-@2)
	.ENDM

	.MACRO __ADDWRR
	ADD  R@0,R@2
	ADC  R@1,R@3
	.ENDM

	.MACRO __SUBWRN
	SUBI R@0,LOW(@2)
	SBCI R@1,HIGH(@2)
	.ENDM

	.MACRO __SUBWRR
	SUB  R@0,R@2
	SBC  R@1,R@3
	.ENDM

	.MACRO __ANDWRN
	ANDI R@0,LOW(@2)
	ANDI R@1,HIGH(@2)
	.ENDM

	.MACRO __ANDWRR
	AND  R@0,R@2
	AND  R@1,R@3
	.ENDM

	.MACRO __ORWRN
	ORI  R@0,LOW(@2)
	ORI  R@1,HIGH(@2)
	.ENDM

	.MACRO __ORWRR
	OR   R@0,R@2
	OR   R@1,R@3
	.ENDM

	.MACRO __EORWRR
	EOR  R@0,R@2
	EOR  R@1,R@3
	.ENDM

	.MACRO __GETWRS
	LDD  R@0,Y+@2
	LDD  R@1,Y+@2+1
	.ENDM

	.MACRO __PUTBSR
	STD  Y+@1,R@0
	.ENDM

	.MACRO __PUTWSR
	STD  Y+@2,R@0
	STD  Y+@2+1,R@1
	.ENDM

	.MACRO __MOVEWRR
	MOV  R@0,R@2
	MOV  R@1,R@3
	.ENDM

	.MACRO __INWR
	IN   R@0,@2
	IN   R@1,@2+1
	.ENDM

	.MACRO __OUTWR
	OUT  @2+1,R@1
	OUT  @2,R@0
	.ENDM

	.MACRO __CALL1MN
	LDS  R30,@0+(@1)
	LDS  R31,@0+(@1)+1
	ICALL
	.ENDM

	.MACRO __CALL1FN
	LDI  R30,LOW(2*@0+(@1))
	LDI  R31,HIGH(2*@0+(@1))
	CALL __GETW1PF
	ICALL
	.ENDM

	.MACRO __CALL2EN
	PUSH R26
	PUSH R27
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMRDW
	POP  R27
	POP  R26
	ICALL
	.ENDM

	.MACRO __CALL2EX
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	CALL __EEPROMRDD
	ICALL
	.ENDM

	.MACRO __GETW1STACK
	IN   R30,SPL
	IN   R31,SPH
	ADIW R30,@0+1
	LD   R0,Z+
	LD   R31,Z
	MOV  R30,R0
	.ENDM

	.MACRO __GETD1STACK
	IN   R30,SPL
	IN   R31,SPH
	ADIW R30,@0+1
	LD   R0,Z+
	LD   R1,Z+
	LD   R22,Z
	MOVW R30,R0
	.ENDM

	.MACRO __NBST
	BST  R@0,@1
	IN   R30,SREG
	LDI  R31,0x40
	EOR  R30,R31
	OUT  SREG,R30
	.ENDM


	.MACRO __PUTB1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RNS
	MOVW R26,R@0
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RNS
	MOVW R26,R@0
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RNS
	MOVW R26,R@0
	ADIW R26,@1
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	CALL __PUTDP1
	.ENDM


	.MACRO __GETB1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R30,Z
	.ENDM

	.MACRO __GETB1HSX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R31,Z
	.ENDM

	.MACRO __GETW1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R0,Z+
	LD   R31,Z
	MOV  R30,R0
	.ENDM

	.MACRO __GETD1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R0,Z+
	LD   R1,Z+
	LD   R22,Z+
	LD   R23,Z
	MOVW R30,R0
	.ENDM

	.MACRO __GETB2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R26,X
	.ENDM

	.MACRO __GETW2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	.ENDM

	.MACRO __GETD2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R1,X+
	LD   R24,X+
	LD   R25,X
	MOVW R26,R0
	.ENDM

	.MACRO __GETBRSX
	MOVW R30,R28
	SUBI R30,LOW(-@1)
	SBCI R31,HIGH(-@1)
	LD   R@0,Z
	.ENDM

	.MACRO __GETWRSX
	MOVW R30,R28
	SUBI R30,LOW(-@2)
	SBCI R31,HIGH(-@2)
	LD   R@0,Z+
	LD   R@1,Z
	.ENDM

	.MACRO __GETBRSX2
	MOVW R26,R28
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	LD   R@0,X
	.ENDM

	.MACRO __GETWRSX2
	MOVW R26,R28
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	LD   R@0,X+
	LD   R@1,X
	.ENDM

	.MACRO __LSLW8SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R31,Z
	CLR  R30
	.ENDM

	.MACRO __PUTB1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	.ENDM

	.MACRO __CLRW1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X,R30
	.ENDM

	.MACRO __CLRD1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X+,R30
	ST   X+,R30
	ST   X,R30
	.ENDM

	.MACRO __PUTB2SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z,R26
	.ENDM

	.MACRO __PUTW2SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z+,R26
	ST   Z,R27
	.ENDM

	.MACRO __PUTD2SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z+,R26
	ST   Z+,R27
	ST   Z+,R24
	ST   Z,R25
	.ENDM

	.MACRO __PUTBSRX
	MOVW R30,R28
	SUBI R30,LOW(-@1)
	SBCI R31,HIGH(-@1)
	ST   Z,R@0
	.ENDM

	.MACRO __PUTWSRX
	MOVW R30,R28
	SUBI R30,LOW(-@2)
	SBCI R31,HIGH(-@2)
	ST   Z+,R@0
	ST   Z,R@1
	.ENDM

	.MACRO __PUTB1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	.ENDM

	.MACRO __MULBRR
	MULS R@0,R@1
	MOVW R30,R0
	.ENDM

	.MACRO __MULBRRU
	MUL  R@0,R@1
	MOVW R30,R0
	.ENDM

	.MACRO __MULBRR0
	MULS R@0,R@1
	.ENDM

	.MACRO __MULBRRU0
	MUL  R@0,R@1
	.ENDM

	.MACRO __MULBNWRU
	LDI  R26,@2
	MUL  R26,R@0
	MOVW R30,R0
	MUL  R26,R@1
	ADD  R31,R0
	.ENDM

;NAME DEFINITIONS FOR GLOBAL VARIABLES ALLOCATED TO REGISTERS
	.DEF _led_status=R4
	.DEF _led_status_msb=R5
	.DEF _led_status1=R6
	.DEF _led_status1_msb=R7
	.DEF _display_count=R8
	.DEF _display_count_msb=R9
	.DEF _display_scan_cnt=R10
	.DEF _display_scan_cnt_msb=R11
	.DEF _ambient_val=R12
	.DEF _ambient_val_msb=R13

	.CSEG
	.ORG 0x00

;START OF CODE MARKER
__START_OF_CODE:

;INTERRUPT VECTORS
	JMP  __RESET
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  _timer1_ovf_isr
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  _usart_rx_isr
	JMP  0x00
	JMP  _usart_tx_isr
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00

_wCRCTable:
	.DB  0x0,0x0,0xC1,0xC0,0x81,0xC1,0x40,0x1
	.DB  0x1,0xC3,0xC0,0x3,0x80,0x2,0x41,0xC2
	.DB  0x1,0xC6,0xC0,0x6,0x80,0x7,0x41,0xC7
	.DB  0x0,0x5,0xC1,0xC5,0x81,0xC4,0x40,0x4
	.DB  0x1,0xCC,0xC0,0xC,0x80,0xD,0x41,0xCD
	.DB  0x0,0xF,0xC1,0xCF,0x81,0xCE,0x40,0xE
	.DB  0x0,0xA,0xC1,0xCA,0x81,0xCB,0x40,0xB
	.DB  0x1,0xC9,0xC0,0x9,0x80,0x8,0x41,0xC8
	.DB  0x1,0xD8,0xC0,0x18,0x80,0x19,0x41,0xD9
	.DB  0x0,0x1B,0xC1,0xDB,0x81,0xDA,0x40,0x1A
	.DB  0x0,0x1E,0xC1,0xDE,0x81,0xDF,0x40,0x1F
	.DB  0x1,0xDD,0xC0,0x1D,0x80,0x1C,0x41,0xDC
	.DB  0x0,0x14,0xC1,0xD4,0x81,0xD5,0x40,0x15
	.DB  0x1,0xD7,0xC0,0x17,0x80,0x16,0x41,0xD6
	.DB  0x1,0xD2,0xC0,0x12,0x80,0x13,0x41,0xD3
	.DB  0x0,0x11,0xC1,0xD1,0x81,0xD0,0x40,0x10
	.DB  0x1,0xF0,0xC0,0x30,0x80,0x31,0x41,0xF1
	.DB  0x0,0x33,0xC1,0xF3,0x81,0xF2,0x40,0x32
	.DB  0x0,0x36,0xC1,0xF6,0x81,0xF7,0x40,0x37
	.DB  0x1,0xF5,0xC0,0x35,0x80,0x34,0x41,0xF4
	.DB  0x0,0x3C,0xC1,0xFC,0x81,0xFD,0x40,0x3D
	.DB  0x1,0xFF,0xC0,0x3F,0x80,0x3E,0x41,0xFE
	.DB  0x1,0xFA,0xC0,0x3A,0x80,0x3B,0x41,0xFB
	.DB  0x0,0x39,0xC1,0xF9,0x81,0xF8,0x40,0x38
	.DB  0x0,0x28,0xC1,0xE8,0x81,0xE9,0x40,0x29
	.DB  0x1,0xEB,0xC0,0x2B,0x80,0x2A,0x41,0xEA
	.DB  0x1,0xEE,0xC0,0x2E,0x80,0x2F,0x41,0xEF
	.DB  0x0,0x2D,0xC1,0xED,0x81,0xEC,0x40,0x2C
	.DB  0x1,0xE4,0xC0,0x24,0x80,0x25,0x41,0xE5
	.DB  0x0,0x27,0xC1,0xE7,0x81,0xE6,0x40,0x26
	.DB  0x0,0x22,0xC1,0xE2,0x81,0xE3,0x40,0x23
	.DB  0x1,0xE1,0xC0,0x21,0x80,0x20,0x41,0xE0
	.DB  0x1,0xA0,0xC0,0x60,0x80,0x61,0x41,0xA1
	.DB  0x0,0x63,0xC1,0xA3,0x81,0xA2,0x40,0x62
	.DB  0x0,0x66,0xC1,0xA6,0x81,0xA7,0x40,0x67
	.DB  0x1,0xA5,0xC0,0x65,0x80,0x64,0x41,0xA4
	.DB  0x0,0x6C,0xC1,0xAC,0x81,0xAD,0x40,0x6D
	.DB  0x1,0xAF,0xC0,0x6F,0x80,0x6E,0x41,0xAE
	.DB  0x1,0xAA,0xC0,0x6A,0x80,0x6B,0x41,0xAB
	.DB  0x0,0x69,0xC1,0xA9,0x81,0xA8,0x40,0x68
	.DB  0x0,0x78,0xC1,0xB8,0x81,0xB9,0x40,0x79
	.DB  0x1,0xBB,0xC0,0x7B,0x80,0x7A,0x41,0xBA
	.DB  0x1,0xBE,0xC0,0x7E,0x80,0x7F,0x41,0xBF
	.DB  0x0,0x7D,0xC1,0xBD,0x81,0xBC,0x40,0x7C
	.DB  0x1,0xB4,0xC0,0x74,0x80,0x75,0x41,0xB5
	.DB  0x0,0x77,0xC1,0xB7,0x81,0xB6,0x40,0x76
	.DB  0x0,0x72,0xC1,0xB2,0x81,0xB3,0x40,0x73
	.DB  0x1,0xB1,0xC0,0x71,0x80,0x70,0x41,0xB0
	.DB  0x0,0x50,0xC1,0x90,0x81,0x91,0x40,0x51
	.DB  0x1,0x93,0xC0,0x53,0x80,0x52,0x41,0x92
	.DB  0x1,0x96,0xC0,0x56,0x80,0x57,0x41,0x97
	.DB  0x0,0x55,0xC1,0x95,0x81,0x94,0x40,0x54
	.DB  0x1,0x9C,0xC0,0x5C,0x80,0x5D,0x41,0x9D
	.DB  0x0,0x5F,0xC1,0x9F,0x81,0x9E,0x40,0x5E
	.DB  0x0,0x5A,0xC1,0x9A,0x81,0x9B,0x40,0x5B
	.DB  0x1,0x99,0xC0,0x59,0x80,0x58,0x41,0x98
	.DB  0x1,0x88,0xC0,0x48,0x80,0x49,0x41,0x89
	.DB  0x0,0x4B,0xC1,0x8B,0x81,0x8A,0x40,0x4A
	.DB  0x0,0x4E,0xC1,0x8E,0x81,0x8F,0x40,0x4F
	.DB  0x1,0x8D,0xC0,0x4D,0x80,0x4C,0x41,0x8C
	.DB  0x0,0x44,0xC1,0x84,0x81,0x85,0x40,0x45
	.DB  0x1,0x87,0xC0,0x47,0x80,0x46,0x41,0x86
	.DB  0x1,0x82,0xC0,0x42,0x80,0x43,0x41,0x83
	.DB  0x0,0x41,0xC1,0x81,0x81,0x80,0x40,0x40
_tbl10_G100:
	.DB  0x10,0x27,0xE8,0x3,0x64,0x0,0xA,0x0
	.DB  0x1,0x0
_tbl16_G100:
	.DB  0x0,0x10,0x0,0x1,0x10,0x0,0x1,0x0

;REGISTER BIT VARIABLES INITIALIZATION
__REG_BIT_VARS:
	.DW  0x0000

_0x1F:
	.DB  0x84,0xF5,0xC2,0xC1,0xB1,0x89,0x88,0xE5
	.DB  0x80,0x81,0xA0,0x98,0x8E,0xD0,0x8A,0xAA
	.DB  0x8C,0xB0,0xD5,0xA8,0x9E,0xE8,0xF8,0xD8
	.DB  0xA2,0xFA,0x9A,0xDC,0xCC,0x91,0xFB,0x0
	.DB  0x1,0xFF,0x4,0xF1,0x9
_0x20:
	.DB  0x15,0x0,0xE,0x0,0x16,0x0,0x1B
_0x21:
	.DB  0x21,0x0,0x10,0x0,0xE,0x0,0x16,0x0
	.DB  0x21,0x0,0x21,0x0,0x17,0x0,0x5,0x0
	.DB  0x5,0x0,0x13,0x0,0x1,0x0,0x18,0x0
	.DB  0x19,0x0,0x1E,0x0,0x14,0x0,0x17,0x0
	.DB  0x19,0x0,0x1E,0x0,0x11,0x0,0x1,0x0
	.DB  0xA,0x0,0x1E,0x0,0x14,0x0,0x17,0x0
	.DB  0xA,0x0,0x1E,0x0,0x11,0x0,0x1,0x0
	.DB  0x21,0x0,0x1,0x0,0x16,0x0,0x18,0x0
	.DB  0x21,0x0,0x21,0x0,0xD,0x0,0x18
_0x22:
	.DB  0x21,0x0,0x21,0x0,0x5,0x0,0x1A,0x0
	.DB  0x21,0x0,0x21,0x0,0x1,0x0,0xD,0x0
	.DB  0xB,0x0,0xA,0x0,0x1B,0x0,0xD
_0x23:
	.DB  0x17,0x0,0x5,0x0,0x1E,0x0,0x1,0x0
	.DB  0x17,0x0,0x5,0x0,0x1E,0x0,0x2,0x0
	.DB  0x17,0x0,0x5,0x0,0x1E,0x0,0x3,0x0
	.DB  0x17,0x0,0x5,0x0,0x1E,0x0,0x4,0x0
	.DB  0x17,0x0,0x5,0x0,0x1E,0x0,0x5,0x0
	.DB  0x17,0x0,0x5,0x0,0x1E,0x0,0x6,0x0
	.DB  0x17,0x0,0x5,0x0,0x1E,0x0,0x7,0x0
	.DB  0x17,0x0,0x5,0x0,0x1E,0x0,0x8
_0x24:
	.DB  0x5,0x0,0x13,0x0,0x1E,0x0,0x1,0x0
	.DB  0x5,0x0,0x13,0x0,0x1E,0x0,0x2,0x0
	.DB  0x5,0x0,0x13,0x0,0x1E,0x0,0x3,0x0
	.DB  0x5,0x0,0x13,0x0,0x1E,0x0,0x4,0x0
	.DB  0x5,0x0,0x13,0x0,0x1E,0x0,0x5,0x0
	.DB  0x5,0x0,0x13,0x0,0x1E,0x0,0x6,0x0
	.DB  0x5,0x0,0x13,0x0,0x1E,0x0,0x7,0x0
	.DB  0x5,0x0,0x13,0x0,0x1E,0x0,0x8
_0x25:
	.DB  0x19,0x0,0x14,0x0,0x1E,0x0,0x1,0x0
	.DB  0x19,0x0,0x14,0x0,0x1E,0x0,0x2,0x0
	.DB  0x19,0x0,0x14,0x0,0x1E,0x0,0x3,0x0
	.DB  0x19,0x0,0x14,0x0,0x1E,0x0,0x4,0x0
	.DB  0x19,0x0,0x14,0x0,0x1E,0x0,0x5,0x0
	.DB  0x19,0x0,0x14,0x0,0x1E,0x0,0x6,0x0
	.DB  0x19,0x0,0x14,0x0,0x1E,0x0,0x7,0x0
	.DB  0x19,0x0,0x14,0x0,0x1E,0x0,0x8
_0x26:
	.DB  0x19,0x0,0x11,0x0,0x1E,0x0,0x1,0x0
	.DB  0x19,0x0,0x11,0x0,0x1E,0x0,0x2,0x0
	.DB  0x19,0x0,0x11,0x0,0x1E,0x0,0x3,0x0
	.DB  0x19,0x0,0x11,0x0,0x1E,0x0,0x4,0x0
	.DB  0x19,0x0,0x11,0x0,0x1E,0x0,0x5,0x0
	.DB  0x19,0x0,0x11,0x0,0x1E,0x0,0x6,0x0
	.DB  0x19,0x0,0x11,0x0,0x1E,0x0,0x7,0x0
	.DB  0x19,0x0,0x11,0x0,0x1E,0x0,0x8
_0x27:
	.DB  0xA,0x0,0x14,0x0,0x1E,0x0,0x1,0x0
	.DB  0xA,0x0,0x14,0x0,0x1E,0x0,0x2,0x0
	.DB  0xA,0x0,0x14,0x0,0x1E,0x0,0x3,0x0
	.DB  0xA,0x0,0x14,0x0,0x1E,0x0,0x4,0x0
	.DB  0xA,0x0,0x14,0x0,0x1E,0x0,0x5,0x0
	.DB  0xA,0x0,0x14,0x0,0x1E,0x0,0x6,0x0
	.DB  0xA,0x0,0x14,0x0,0x1E,0x0,0x7,0x0
	.DB  0xA,0x0,0x14,0x0,0x1E,0x0,0x8
_0x28:
	.DB  0xA,0x0,0x11,0x0,0x1E,0x0,0x1,0x0
	.DB  0xA,0x0,0x11,0x0,0x1E,0x0,0x2,0x0
	.DB  0xA,0x0,0x11,0x0,0x1E,0x0,0x3,0x0
	.DB  0xA,0x0,0x11,0x0,0x1E,0x0,0x4,0x0
	.DB  0xA,0x0,0x11,0x0,0x1E,0x0,0x5,0x0
	.DB  0xA,0x0,0x11,0x0,0x1E,0x0,0x6,0x0
	.DB  0xA,0x0,0x11,0x0,0x1E,0x0,0x7,0x0
	.DB  0xA,0x0,0x11,0x0,0x1E,0x0,0x8
_0x29:
	.DB  0x1,0x0,0x16,0x0,0x1E,0x0,0x1,0x0
	.DB  0x1,0x0,0x16,0x0,0x1E,0x0,0x2,0x0
	.DB  0x1,0x0,0x16,0x0,0x1E,0x0,0x3,0x0
	.DB  0x1,0x0,0x16,0x0,0x1E,0x0,0x4,0x0
	.DB  0x1,0x0,0x16,0x0,0x1E,0x0,0x5,0x0
	.DB  0x1,0x0,0x16,0x0,0x1E,0x0,0x6,0x0
	.DB  0x1,0x0,0x16,0x0,0x1E,0x0,0x7,0x0
	.DB  0x1,0x0,0x16,0x0,0x1E,0x0,0x8
_0x2A:
	.DB  0xD,0x0,0x18,0x0,0x1E,0x0,0x1,0x0
	.DB  0xD,0x0,0x18,0x0,0x1E,0x0,0x2,0x0
	.DB  0xD,0x0,0x18,0x0,0x1E,0x0,0x3,0x0
	.DB  0xD,0x0,0x18,0x0,0x1E,0x0,0x4,0x0
	.DB  0xD,0x0,0x18,0x0,0x1E,0x0,0x5,0x0
	.DB  0xD,0x0,0x18,0x0,0x1E,0x0,0x6,0x0
	.DB  0xD,0x0,0x18,0x0,0x1E,0x0,0x7,0x0
	.DB  0xD,0x0,0x18,0x0,0x1E,0x0,0x8
_0x2B:
	.DB  0x1B,0x0,0x16,0x0,0x5,0x0,0x13,0x0
	.DB  0x5,0x0,0x13,0x0,0x1,0x0,0x18
_0x2C:
	.DB  0x21,0x0,0x18,0x0,0x1A,0x0,0x1,0x0
	.DB  0x21,0x0,0x18,0x0,0x1A,0x0,0x2,0x0
	.DB  0x21,0x0,0x21,0x0,0x21,0x0,0x12,0x0
	.DB  0x21,0x0,0x21,0x0,0x21,0x0,0x13,0x0
	.DB  0x21,0x0,0x21,0x0,0x21,0x0,0x19,0x0
	.DB  0x21,0x0,0x21,0x0,0x21,0x0,0x5,0x0
	.DB  0x21,0x0,0x21,0x0,0x21,0x0,0x1A,0x0
	.DB  0x1B,0x0,0x17,0x0,0x14,0x0,0x1A,0x0
	.DB  0x4,0x0,0x1E,0x0,0x2
_0x2D:
	.DB  0x21,0x0,0x20,0x0,0x6,0x0,0x13,0x0
	.DB  0x1,0x0,0x20,0x0,0x2,0x0,0x13,0x0
	.DB  0x3,0x0,0x1F,0x0,0x4,0x0,0x13,0x0
	.DB  0x1,0x0,0x1,0x0,0x24,0x0,0x2
_0x2E:
	.DB  0xC,0x0,0x14,0x0,0x1E,0x0,0x1,0x0
	.DB  0xC,0x0,0x14,0x0,0x1E,0x0,0x2,0x0
	.DB  0xC,0x0,0x14,0x0,0x1E,0x0,0x3,0x0
	.DB  0xC,0x0,0x14,0x0,0x1E,0x0,0x4,0x0
	.DB  0xC,0x0,0x14,0x0,0x1E,0x0,0x5,0x0
	.DB  0xC,0x0,0x14,0x0,0x1E,0x0,0x6,0x0
	.DB  0xC,0x0,0x14,0x0,0x1E,0x0,0x7,0x0
	.DB  0xC,0x0,0x14,0x0,0x1E,0x0,0x8
_0x2F:
	.DB  0x22,0x0,0x0,0x0,0x0,0x0,0x1,0x0
	.DB  0x0,0x0,0x22,0x0,0x0,0x0,0x1,0x0
	.DB  0x0,0x0,0x0,0x0,0x22,0x0,0x1,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x1
_0x30:
	.DB  0x1E,0x0,0x1E,0x0,0x1E,0x0,0x1E
_0x31:
	.DB  0x1,0x0,0x21,0x0,0x21,0x0,0x21
_0x32:
	.DB  0x3C,0xDF,0xE0,0xE7,0x2A,0xF0,0x30,0xF8
	.DB  0x0,0x0,0xA3,0x7,0x1E,0xF,0x62,0x16
	.DB  0x82,0x1D,0x77,0x24,0x43,0x2B,0xE7,0x31
	.DB  0x60,0x38,0xB4,0x3E,0xE3,0x44,0xE3,0x4A
	.DB  0xCD,0x50,0x8E,0x56,0xC0,0x5D
_0x33:
	.DB  0x0,0x0,0x2,0x1,0xF,0x2,0x21,0x3
	.DB  0x36,0x4,0x4C,0x5,0x61,0x6,0x75,0x7
	.DB  0x89,0x8,0x9D,0x9,0xB3,0xA,0xCE,0xB
	.DB  0xEE,0xC,0x17,0xE,0x49,0xF
_0x34:
	.DB  0x0,0x0,0xCA,0x0,0x9A,0x1,0x66,0x2
	.DB  0x2E,0x3,0xF7,0x3,0xC5,0x4,0x96,0x5
	.DB  0x68,0x6,0x3C,0x7,0x10,0x8,0xE6,0x8
	.DB  0xBB,0x9,0x8F,0xA,0x61,0xB,0x31,0xC
	.DB  0x0,0xD,0xCB,0xD,0x95,0xE,0x5B,0xF
	.DB  0x20,0x10,0xE1,0x10,0xA0,0x11,0x5C,0x12
	.DB  0x14,0x13,0xC8,0x13,0x79,0x14,0x26,0x15
_0x35:
	.DB  0x0,0x0,0x28,0x1,0x87,0x2,0x11,0x4
	.DB  0xBD,0x5,0x83,0x7,0x61,0x9,0x50,0xB
	.DB  0x50,0xD,0x5D,0xF,0x77,0x11,0x9D,0x13
	.DB  0xCF,0x15,0xD,0x18,0x57,0x1A,0xAC,0x1C
	.DB  0xE,0x1F,0x7B,0x21,0xF5,0x23,0x7A,0x26
	.DB  0xA,0x29,0xA5,0x2B,0x4A,0x2E,0xF7,0x30
	.DB  0xAC,0x33,0x66,0x36,0x25,0x39,0xE6,0x3B
	.DB  0xA8,0x3E,0x6A,0x41,0x2B,0x44,0xE8,0x46
	.DB  0xA1,0x49,0x54,0x4C,0xFE,0x4E,0x8D,0x51
_0x36:
	.DB  0x0,0x0,0x2B,0x1,0x86,0x2,0x5,0x4
	.DB  0xA1,0x5,0x52,0x7,0x13,0x9,0xE2,0xA
	.DB  0xBB,0xC,0x9E,0xE,0x89,0x10,0x7C,0x12
	.DB  0x77,0x14,0x79,0x16,0x83,0x18,0x96,0x1A
	.DB  0xB1,0x1C,0xD5,0x1E,0x1,0x21,0x36,0x23
	.DB  0x73,0x25,0xB8,0x27,0x5,0x2A,0x57,0x2C
	.DB  0xAF,0x2E,0xA,0x31,0x67,0x33,0xC6,0x35
	.DB  0x25,0x38,0x82,0x3A,0xDE,0x3C,0x36,0x3F
	.DB  0x89,0x41,0xD6,0x43,0x1B,0x46,0x47,0x48
_0x37:
	.DB  0xD0,0xFD,0x30,0xFE,0xAE,0xFE,0x4A,0xFF
	.DB  0x0,0x0,0xCC,0x0,0xAC,0x1,0x9E,0x2
	.DB  0xA1,0x3,0xB1,0x4,0xCE,0x5,0xF6,0x6
_0xED:
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0
_0xF4:
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0
_0xFB:
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0

__GLOBAL_INI_TBL:
	.DW  0x02
	.DW  0x02
	.DW  __REG_BIT_VARS*2

	.DW  0x25
	.DW  _segment_table
	.DW  _0x1F*2

	.DW  0x07
	.DW  _ms_menu
	.DW  _0x20*2

	.DW  0x47
	.DW  _message_menu
	.DW  _0x21*2

	.DW  0x17
	.DW  _message_gen
	.DW  _0x22*2

	.DW  0x3F
	.DW  _message_os
	.DW  _0x23*2

	.DW  0x3F
	.DW  _message_skip
	.DW  _0x24*2

	.DW  0x3F
	.DW  _message_rlow
	.DW  _0x25*2

	.DW  0x3F
	.DW  _message_rhigh
	.DW  _0x26*2

	.DW  0x3F
	.DW  _message_alow
	.DW  _0x27*2

	.DW  0x3F
	.DW  _message_ahigh
	.DW  _0x28*2

	.DW  0x3F
	.DW  _message_in
	.DW  _0x29*2

	.DW  0x3F
	.DW  _message_dp
	.DW  _0x2A*2

	.DW  0x0F
	.DW  _message_skuk
	.DW  _0x2B*2

	.DW  0x45
	.DW  _message_inp
	.DW  _0x2C*2

	.DW  0x1F
	.DW  _message_baud
	.DW  _0x2D*2

	.DW  0x3F
	.DW  _message_cal
	.DW  _0x2E*2

	.DW  0x1F
	.DW  _message_dp1
	.DW  _0x2F*2

	.DW  0x07
	.DW  _message_neg
	.DW  _0x30*2

	.DW  0x07
	.DW  _message_open
	.DW  _0x31*2

	.DW  0x26
	.DW  _table_p
	.DW  _0x32*2

	.DW  0x1E
	.DW  _table_j
	.DW  _0x33*2

	.DW  0x38
	.DW  _table_k
	.DW  _0x34*2

	.DW  0x48
	.DW  _table_r
	.DW  _0x35*2

	.DW  0x48
	.DW  _table_s
	.DW  _0x36*2

	.DW  0x18
	.DW  _table_t
	.DW  _0x37*2

_0xFFFFFFFF:
	.DW  0

#define __GLOBAL_INI_TBL_PRESENT 1

__RESET:
	CLI
	CLR  R30
	OUT  EECR,R30

;INTERRUPT VECTORS ARE PLACED
;AT THE START OF FLASH
	LDI  R31,1
	OUT  MCUCR,R31
	OUT  MCUCR,R30

;CLEAR R2-R14
	LDI  R24,(14-2)+1
	LDI  R26,2
	CLR  R27
__CLEAR_REG:
	ST   X+,R30
	DEC  R24
	BRNE __CLEAR_REG

;CLEAR SRAM
	LDI  R24,LOW(__CLEAR_SRAM_SIZE)
	LDI  R25,HIGH(__CLEAR_SRAM_SIZE)
	LDI  R26,__SRAM_START
__CLEAR_SRAM:
	ST   X+,R30
	SBIW R24,1
	BRNE __CLEAR_SRAM

;GLOBAL VARIABLES INITIALIZATION
	LDI  R30,LOW(__GLOBAL_INI_TBL*2)
	LDI  R31,HIGH(__GLOBAL_INI_TBL*2)
__GLOBAL_INI_NEXT:
	LPM  R24,Z+
	LPM  R25,Z+
	SBIW R24,0
	BREQ __GLOBAL_INI_END
	LPM  R26,Z+
	LPM  R27,Z+
	LPM  R0,Z+
	LPM  R1,Z+
	MOVW R22,R30
	MOVW R30,R0
__GLOBAL_INI_LOOP:
	LPM  R0,Z+
	ST   X+,R0
	SBIW R24,1
	BRNE __GLOBAL_INI_LOOP
	MOVW R30,R22
	RJMP __GLOBAL_INI_NEXT
__GLOBAL_INI_END:

;HARDWARE STACK POINTER INITIALIZATION
	LDI  R30,LOW(__SRAM_END-__HEAP_SIZE)
	OUT  SPL,R30
	LDI  R30,HIGH(__SRAM_END-__HEAP_SIZE)
	OUT  SPH,R30

;DATA STACK POINTER INITIALIZATION
	LDI  R28,LOW(__SRAM_START+__DSTACK_SIZE)
	LDI  R29,HIGH(__SRAM_START+__DSTACK_SIZE)

	JMP  _main

	.ESEG
	.ORG 0

	.DSEG
	.ORG 0x160

	.CSEG
;
;/*******************************************************
;derived from mbscan15.c
;reason: the relay for al-hi and al-lo are to be interchanged
;as per the connection sticker.
;to be corrected in main universal unit as well
;
;derived from mbscan14.c
;reason:
;done: converted to T type -ve range
;todo:
;fix r-lo,r-hi and other parmeters to fixed values
;remove them in programming.
;
;r-lo : all -200
;r-hi : all +300
;dp: all 3
;inp: all T type
;
;
;
;
;date: 25-02-2020
;derived from mbscan10.c
;
;reason: to add dp in function code 4 along with PV so that it can be scanned and displayed along with
;decimal point by PC software
;delay change from 20mS to 50mS
;
;
;date: 26-11-2019
;derived from mbscan9.c
;reason:
;*to add preset single register function in modbus.
;function code 06
;
;
;date: 16-11-2019
;derived from mbscan8.c
;todo:
;* add other functions to modbus protocol
;    04  ---read input register
;    16  ---preset multiple register
;
;* limit the no. of registers read to 16 bytes. if more, than return only 16
;* add tick timer to timeout error request.. timeout is 1 second and poll timeout is 20ms
;* add scan time logic
;* add scan/hold logic
;*add open sensor status
;* add predefined code to channels for open/underrange/skip status in modbus transmission
;        underrange ---- 0xbbbb hex
;        overrange ------0xcccc hex
;        skipped   ------0xdddd hex
;
;
;
;date 11-11-2019
;derived from mbscan7.c
;reason: to add modbus
;
;
;
;
;date: 06-11-2019
;derived from mbscan6.c
;todo:
;*add 4~20ma linearisation
;*add voltage linearisation
;add offset
;add skip status to relay and led logic
;skip channel 8 if thermocouple selected on any channel and collect ch8 data for ambient calculation
;ambient calibration temp value in rhi-8
;add ambient compensation to thermocouples
;
;
;
;derived from mbscan4.c
;to do:
;*add led logic
;*add decimal point for pt100 0.1
;*add relay logic and link to led status
;*add common relay logic
;*add range limits for thermocouple and pt100
;*add skip status
;*eeprom store and retrieve dp status.
;*add serial speed
;
;
;derived from mbscan3.c
;date: 01-11-2019
;reason:
;to add voltage and 4~20mA tables
;to correct blinking issue
;to add decimal point
;
;date 04-10-2019
;reason: to add menu routines
;main menu: Scan time st,offset OSx8, skip/unskip x 8,alarm low x 8,alarm high x8,input x 8, modbus id,baudrate
;
;
;derived from mbscan1.c
;date: 2-10-2019
;achieved:
;*display and led scan
;*adc 3421 operating with mux scanning
;
;
;todo
;* scan display with chno. on bottom and pv on top. fixed scan time of 2 seconds
;
;
;
;
;
;
;
;
;
;This program was created by the
;CodeWizardAVR V3.12 Advanced
;Automatic Program Generator
;© Copyright 1998-2014 Pavel Haiduc, HP InfoTech s.r.l.
;http://www.hpinfotech.com
;
;Project : mbscan
;Version : 1.0
;Date    : 10/1/2019
;Author  : pundalik
;Company : bhoomi controls
;Comments:
;this is compatible with mbscan1/2/3/4
;hardware
;
;
;Chip type               : ATmega32A
;Program type            : Application
;AVR Core Clock frequency: 11.059200 MHz
;Memory model            : Small
;External RAM size       : 0
;Data Stack size         : 512
;*******************************************************/
;
;#include <mega32a.h>
	#ifndef __SLEEP_DEFINED__
	#define __SLEEP_DEFINED__
	.EQU __se_bit=0x80
	.EQU __sm_mask=0x70
	.EQU __sm_powerdown=0x20
	.EQU __sm_powersave=0x30
	.EQU __sm_standby=0x60
	.EQU __sm_ext_standby=0x70
	.EQU __sm_adc_noise_red=0x10
	.SET power_ctrl_reg=mcucr
	#endif
;
;// I2C Bus functions
;#include <i2c.h>
;
;// Declare your global variables here
;
;#define DATA_REGISTER_EMPTY (1<<UDRE)
;#define RX_COMPLETE (1<<RXC)
;#define FRAMING_ERROR (1<<FE)
;#define PARITY_ERROR (1<<UPE)
;#define DATA_OVERRUN (1<<DOR)
;
;
;
;#define digit1() PORTC.0 = 1
;#define digit2() PORTC.7 = 1
;#define digit3() PORTC.6 = 1
;#define digit4() PORTC.5 = 1
;#define digit5() PORTC.1 = 1
;#define digit6() PORTC.2 = 1
;#define digit7() PORTC.3 = 1
;#define digit8() PORTC.4 = 1
;#define digit9() PORTB.6 = 1        //led red common
;#define digit10() PORTB.7 = 1       //led green common
;
;
;#define relay1 PORTD.7
;#define relay2 PORTD.6
;
;#define key1 PINB.2
;#define key2 PINB.3
;#define key3 PINB.4
;#define key4 PINB.5
;#define key5 PINB.2
;
;#define mux9 PORTD.3
;#define mux10 PORTD.4
;#define mux11 PORTD.5
;
;void clear_display(void)
; 0000 00B8 {

	.CSEG
_clear_display:
; .FSTART _clear_display
; 0000 00B9 PORTA =0xff;    //segment off
	LDI  R30,LOW(255)
	OUT  0x1B,R30
; 0000 00BA PORTC = 0x00;  //digit drive off
	LDI  R30,LOW(0)
	OUT  0x15,R30
; 0000 00BB PORTB.6 = 0;   //led common off
	CBI  0x18,6
; 0000 00BC PORTB.7 =0;
	CBI  0x18,7
; 0000 00BD 
; 0000 00BE 
; 0000 00BF }
	RET
; .FEND
;
;unsigned short int led_status,led_status1;
;unsigned short int display_buffer[10];
;short int dummy[1] = {0};
;short int dummy2[1] = {0};
;int process_value[8];
;short int display_count;
;short int display_scan_cnt;
;bit modbus_fl;      // recieved modbus flag
;
;#define all_led_off() led_status = 0xff;             //red led status
;#define rled3_on() led_status &= 0xfe
;#define rled2_on() led_status &= 0xfd
;#define rled1_on() led_status &= 0xfb
;#define rled4_on() led_status &= 0xf7
;#define rled5_on() led_status &= 0xef
;#define rled6_on() led_status &= 0xdf
;#define rled7_on() led_status &= 0xbf
;#define rled8_on() led_status &= 0x7f
;#define rled3_off() led_status |= 0x01
;#define rled2_off() led_status |= 0x02
;#define rled1_off() led_status |= 0x04
;#define rled4_off() led_status |= 0x08
;#define rled5_off() led_status |= 0x10
;#define rled6_off() led_status |= 0x20
;#define rled7_off() led_status |= 0x40
;#define rled8_off() led_status |= 0x80
;
;#define all_led_off1() led_status1 = 0xff;             //red led status
;#define gled3_on() led_status1 &= 0xfe
;#define gled2_on() led_status1 &= 0xfd
;#define gled1_on() led_status1 &= 0xfb
;#define gled4_on() led_status1 &= 0xf7
;#define gled5_on() led_status1 &= 0xef
;#define gled6_on() led_status1 &= 0xdf
;#define gled7_on() led_status1 &= 0xbf
;#define gled8_on() led_status1 &= 0x7f
;#define gled3_off() led_status1 |= 0x01
;#define gled2_off() led_status1 |= 0x02
;#define gled1_off() led_status1 |= 0x04
;#define gled4_off() led_status1 |= 0x08
;#define gled5_off() led_status1 |= 0x10
;#define gled6_off() led_status1 |= 0x20
;#define gled7_off() led_status1 |= 0x40
;#define gled8_off() led_status1 |= 0x80
;
;#define mb_dir  PORTD.2
;
;
;
;//memory map
;int gen[8];
;eeprom int ee_gen[8]={1,1,0,0,0,0,0,0};
;int os[8];
;eeprom int ee_os[8]={0,0,0,0,0,0,0,0};
;int skip[8];
;eeprom int ee_skip[8]={0,0,0,0,0,0,0,0};
;int rlow[8];
;eeprom int ee_rlow[8]={0,0,0,0,0,0,0,0};
;int rhigh[8];
;eeprom int ee_rhigh[8]={100,100,100,100,100,100,100,100};
;int alow[8];
;eeprom int ee_alow[8]={0,0,0,0,0,0,0,0};
;int ahigh[8];
;eeprom int ee_ahigh[8]={100,100,100,100,100,100,100,100};
;int input[8];
;eeprom int ee_input[8]={0,0,0,0,0,0,0,0};
;int dp[8];
;eeprom int ee_dp[8]={0,0,0,0,0,0,0,0};
;
;int cal_zero[8];
;eeprom int ee_cal_zero[8]={10300,10300,10300,10300,10300,10300,10300,10300};
;int cal_span[8];
;eeprom int ee_cal_span[8]={21300,21300,21300,21300,21300,21300,21300,21300};
;int ambient_val;
;bit tc_fl;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;// USART Receiver buffer
;#define RX_BUFFER_SIZE 20
;char rx_buffer[RX_BUFFER_SIZE];
;
;#if RX_BUFFER_SIZE <= 256
;unsigned char rx_wr_index=0,rx_rd_index=0;
;#else
;unsigned int rx_wr_index=0,rx_rd_index=0;
;#endif
;
;#if RX_BUFFER_SIZE < 256
;unsigned char rx_counter=0;
;#else
;unsigned int rx_counter=0;
;#endif
;char mbreceived_data[10];
;
;// This flag is set on USART Receiver buffer overflow
;bit rx_buffer_overflow;
;
;// USART Receiver interrupt service routine
;interrupt [USART_RXC] void usart_rx_isr(void)
; 0000 0138 {
_usart_rx_isr:
; .FSTART _usart_rx_isr
	ST   -Y,R26
	ST   -Y,R27
	ST   -Y,R30
	ST   -Y,R31
	IN   R30,SREG
	ST   -Y,R30
; 0000 0139 char status,data,i;
; 0000 013A status=UCSRA;
	CALL __SAVELOCR4
;	status -> R17
;	data -> R16
;	i -> R19
	IN   R17,11
; 0000 013B data=UDR;
	IN   R16,12
; 0000 013C if ((status & (FRAMING_ERROR | PARITY_ERROR | DATA_OVERRUN))==0)
	MOV  R30,R17
	ANDI R30,LOW(0x1C)
	BREQ PC+2
	RJMP _0x7
; 0000 013D    {
; 0000 013E    rx_buffer[rx_wr_index++]=data;
	LDS  R30,_rx_wr_index
	SUBI R30,-LOW(1)
	STS  _rx_wr_index,R30
	SUBI R30,LOW(1)
	LDI  R31,0
	SUBI R30,LOW(-_rx_buffer)
	SBCI R31,HIGH(-_rx_buffer)
	ST   Z,R16
; 0000 013F #if RX_BUFFER_SIZE == 256
; 0000 0140    // special case for receiver buffer size=256
; 0000 0141    if (++rx_counter == 0) rx_buffer_overflow=1;
; 0000 0142 #else
; 0000 0143    if (rx_wr_index == RX_BUFFER_SIZE) rx_wr_index=0;
	LDS  R26,_rx_wr_index
	CPI  R26,LOW(0x14)
	BRNE _0x8
	LDI  R30,LOW(0)
	STS  _rx_wr_index,R30
; 0000 0144    if (++rx_counter == RX_BUFFER_SIZE)
_0x8:
	LDS  R26,_rx_counter
	SUBI R26,-LOW(1)
	STS  _rx_counter,R26
	CPI  R26,LOW(0x14)
	BRNE _0x9
; 0000 0145       {
; 0000 0146       rx_counter=0;
	LDI  R30,LOW(0)
	STS  _rx_counter,R30
; 0000 0147       rx_buffer_overflow=1;
	SET
	BLD  R2,2
; 0000 0148       }
; 0000 0149 #endif
; 0000 014A ///////////////////////////////////
; 0000 014B //added to form modbus frame
; 0000 014C if (rx_counter==1)
_0x9:
	LDS  R26,_rx_counter
	CPI  R26,LOW(0x1)
	BRNE _0xA
; 0000 014D     {
; 0000 014E     if (rx_buffer[0] != (char)(gen[1]))
	__GETB1MN _gen,2
	LDS  R26,_rx_buffer
	CP   R30,R26
	BREQ _0xB
; 0000 014F         rx_counter = rx_wr_index =0;    //reset frame till first byte matchs slave address
	LDI  R30,LOW(0)
	STS  _rx_wr_index,R30
	STS  _rx_counter,R30
; 0000 0150     }
_0xB:
; 0000 0151 else
	RJMP _0xC
_0xA:
; 0000 0152     {
; 0000 0153     // valid slave address.allot frame size according to function code.
; 0000 0154     if (rx_counter >=8)
	LDS  R26,_rx_counter
	CPI  R26,LOW(0x8)
	BRLO _0xD
; 0000 0155       {
; 0000 0156     //modbus frame complete. transfer data to mbreceived_data[]
; 0000 0157         for (i=0;i<8;i++)
	LDI  R19,LOW(0)
_0xF:
	CPI  R19,8
	BRSH _0x10
; 0000 0158         {
; 0000 0159         mbreceived_data[i] = rx_buffer[i];
	MOV  R26,R19
	LDI  R27,0
	SUBI R26,LOW(-_mbreceived_data)
	SBCI R27,HIGH(-_mbreceived_data)
	MOV  R30,R19
	LDI  R31,0
	SUBI R30,LOW(-_rx_buffer)
	SBCI R31,HIGH(-_rx_buffer)
	LD   R30,Z
	ST   X,R30
; 0000 015A         }
	SUBI R19,-1
	RJMP _0xF
_0x10:
; 0000 015B         rx_counter = rx_wr_index =0;        //reset counter to start for next frame
	LDI  R30,LOW(0)
	STS  _rx_wr_index,R30
	STS  _rx_counter,R30
; 0000 015C         modbus_fl =1;                       // set flag to indicate frame recieved in main routine.
	SET
	BLD  R2,0
; 0000 015D //        mb_dir =1;      //ready for transmit
; 0000 015E       }
; 0000 015F     }
_0xD:
_0xC:
; 0000 0160 
; 0000 0161 
; 0000 0162 //////////////////////////////////
; 0000 0163 
; 0000 0164    }
; 0000 0165 }
_0x7:
	CALL __LOADLOCR4
	ADIW R28,4
	LD   R30,Y+
	OUT  SREG,R30
	LD   R31,Y+
	LD   R30,Y+
	LD   R27,Y+
	LD   R26,Y+
	RETI
; .FEND
;
;#ifndef _DEBUG_TERMINAL_IO_
;// Get a character from the USART Receiver buffer
;#define _ALTERNATE_GETCHAR_
;#pragma used+
;char getchar(void)
; 0000 016C {
; 0000 016D char data;
; 0000 016E while (rx_counter==0);
;	data -> R17
; 0000 016F data=rx_buffer[rx_rd_index++];
; 0000 0170 #if RX_BUFFER_SIZE != 256
; 0000 0171 if (rx_rd_index == RX_BUFFER_SIZE) rx_rd_index=0;
; 0000 0172 #endif
; 0000 0173 #asm("cli")
; 0000 0174 --rx_counter;
; 0000 0175 #asm("sei")
; 0000 0176 return data;
; 0000 0177 }
;#pragma used-
;#endif
;
;// USART Transmitter buffer
;#define TX_BUFFER_SIZE 48
;char tx_buffer[TX_BUFFER_SIZE];
;
;#if TX_BUFFER_SIZE <= 256
;unsigned char tx_wr_index=0,tx_rd_index=0;
;#else
;unsigned int tx_wr_index=0,tx_rd_index=0;
;#endif
;
;#if TX_BUFFER_SIZE < 256
;unsigned char tx_counter=0;
;#else
;unsigned int tx_counter=0;
;#endif
;
;// USART Transmitter interrupt service routine
;interrupt [USART_TXC] void usart_tx_isr(void)
; 0000 018D {
_usart_tx_isr:
; .FSTART _usart_tx_isr
	ST   -Y,R26
	ST   -Y,R30
	ST   -Y,R31
	IN   R30,SREG
	ST   -Y,R30
; 0000 018E if (tx_counter)
	LDS  R30,_tx_counter
	CPI  R30,0
	BREQ _0x15
; 0000 018F    {
; 0000 0190    --tx_counter;
	SUBI R30,LOW(1)
	STS  _tx_counter,R30
; 0000 0191    UDR=tx_buffer[tx_rd_index++];
	LDS  R30,_tx_rd_index
	SUBI R30,-LOW(1)
	STS  _tx_rd_index,R30
	SUBI R30,LOW(1)
	LDI  R31,0
	SUBI R30,LOW(-_tx_buffer)
	SBCI R31,HIGH(-_tx_buffer)
	LD   R30,Z
	OUT  0xC,R30
; 0000 0192 #if TX_BUFFER_SIZE != 256
; 0000 0193    if (tx_rd_index == TX_BUFFER_SIZE) tx_rd_index=0;
	LDS  R26,_tx_rd_index
	CPI  R26,LOW(0x30)
	BRNE _0x16
	LDI  R30,LOW(0)
	STS  _tx_rd_index,R30
; 0000 0194 #endif
; 0000 0195    }
_0x16:
; 0000 0196 }
_0x15:
	LD   R30,Y+
	OUT  SREG,R30
	LD   R31,Y+
	LD   R30,Y+
	LD   R26,Y+
	RETI
; .FEND
;
;#ifndef _DEBUG_TERMINAL_IO_
;// Write a character to the USART Transmitter buffer
;#define _ALTERNATE_PUTCHAR_
;#pragma used+
;void putchar(char c)
; 0000 019D {
_putchar:
; .FSTART _putchar
; 0000 019E while (tx_counter == TX_BUFFER_SIZE);
	ST   -Y,R26
;	c -> Y+0
_0x17:
	LDS  R26,_tx_counter
	CPI  R26,LOW(0x30)
	BREQ _0x17
; 0000 019F //#asm("cli")
; 0000 01A0 if (tx_counter || ((UCSRA & DATA_REGISTER_EMPTY)==0))
	LDS  R30,_tx_counter
	CPI  R30,0
	BRNE _0x1B
	SBIC 0xB,5
	RJMP _0x1A
_0x1B:
; 0000 01A1    {
; 0000 01A2    tx_buffer[tx_wr_index++]=c;
	LDS  R30,_tx_wr_index
	SUBI R30,-LOW(1)
	STS  _tx_wr_index,R30
	SUBI R30,LOW(1)
	LDI  R31,0
	SUBI R30,LOW(-_tx_buffer)
	SBCI R31,HIGH(-_tx_buffer)
	LD   R26,Y
	STD  Z+0,R26
; 0000 01A3 #if TX_BUFFER_SIZE != 256
; 0000 01A4    if (tx_wr_index == TX_BUFFER_SIZE) tx_wr_index=0;
	LDS  R26,_tx_wr_index
	CPI  R26,LOW(0x30)
	BRNE _0x1D
	LDI  R30,LOW(0)
	STS  _tx_wr_index,R30
; 0000 01A5 #endif
; 0000 01A6    ++tx_counter;
_0x1D:
	LDS  R30,_tx_counter
	SUBI R30,-LOW(1)
	STS  _tx_counter,R30
; 0000 01A7    }
; 0000 01A8 else
	RJMP _0x1E
_0x1A:
; 0000 01A9    UDR=c;
	LD   R30,Y
	OUT  0xC,R30
; 0000 01AA  //#asm("sei")
; 0000 01AB }
_0x1E:
	ADIW R28,1
	RET
; .FEND
;#pragma used-
;#endif
;
;// Standard Input/Output functions
;#include <stdio.h>
;#include <delay.h>
;
;
;//                              0     1     2   3    4    5    6    7     8    9   10    11   12   13   14   15   16   1 ...
;//                              0     1     2   3    4    5    6    7     8    9    a    b    c    d    e    f    g    h ...
;unsigned char segment_table[]= {0x84,0xf5,0xc2,0xc1,0xb1,0x89,0x88,0xe5,0x80,0x81,0xa0,0x98,0x8e,0xd0,0x8a,0xaa,0x8c,0xb ...

	.DSEG
;bit blink_flag,blinking,qsecfl,tsec_fl,hsec_fl;
;short int blink_digit;
;short int mux_scan,tsec_cnt;
;
;//key routine map
;
;short int key_count;
;bit key1_old,key2_old,key3_old,key4_old;
;bit menu_fl;
;short int menu_count,item1,item2;
;short int level;    //level  = 0,1,2 sub level
;short int item1,item2;  // item 1 has common parameters st/id/baudrate
;//menu text
;short int ms_menu[]={21,14,22,27};
;//menu message
;//gen,os,skip,r-lo,r-hi,a-lo,a-hi,inp
;short int message_menu[] = {33,16,14,22,33,33,23,05,05,19,01,24,25,30,20,23,25,30,17,01,10,30,20,23,10,30,17,01,33,01,22 ...
;//st,id,baud
;short int message_gen[]={33,33,5,26,33,33,1,13,11,10,27,13};
;//os-1,os-2.....os-8
;short int message_os[]={23,5,30,1,23,5,30,2,23,5,30,3,23,5,30,4,23,5,30,5,23,5,30,6,23,5,30,7,23,5,30,8};
;//sk-1,sk-2.....sk-8
;short int message_skip[]={05,19,30,01,05,19,30,02,05,19,30,03,05,19,30,04,05,19,30,05,05,19,30,06,05,19,30,07,05,19,30,8 ...
;//rl-1,rl-2....rl-8
;short int message_rlow[]={25,20,30,01,25,20,30,02,25,20,30,03,25,20,30,04,25,20,30,05,25,20,30,06,25,20,30,07,25,20,30,8 ...
;//rh-1...rh-8
;short int message_rhigh[]={25,17,30,01,25,17,30,02,25,17,30,03,25,17,30,04,25,17,30,05,25,17,30,06,25,17,30,07,25,17,30, ...
;//al-1.....al-8
;short int message_alow[]={10,20,30,01,10,20,30,02,10,20,30,03,10,20,30,04,10,20,30,05,10,20,30,06,10,20,30,07,10,20,30,8 ...
;//ah-1...ah-8
;short int message_ahigh[]={10,17,30,01,10,17,30,02,10,17,30,03,10,17,30,04,10,17,30,05,10,17,30,06,10,17,30,07,10,17,30, ...
;//in-1....in-8
;short int message_in[]={01,22,30,01,01,22,30,02,01,22,30,03,01,22,30,04,01,22,30,05,01,22,30,06,01,22,30,07,01,22,30,8};
;//dp-1....dp-8
;short int message_dp[]={13,24,30,1,13,24,30,2,13,24,30,3,13,24,30,4,13,24,30,5,13,24,30,6,13,24,30,7,13,24,30,8};
;
;//process error byte: 0: normal,1: underrange,2: overrange,3: skip
;short int process_error[8];
;
;
;//sub menu messages for skip/unskip,input
;//unsk/skip
;short int message_skuk[]={27,22,05,19,05,19,01,24};
;//pt1,pt2,j,k,r,s,t,volt,4~20
;short int message_inp[]={33,24,26,01,33,24,26,02,33,33,33,18,33,33,33,19,33,33,33,25,33,33,33,05,33,33,33,26,27,23,20,26 ...
;short int message_baud[]={33,32,6,19,1,32,2,19,03,31,04,19,01,01,36,02};  // 9.6k,19.2k,38.4k,115.2
;short int message_cal[]={12,20,30,01,12,20,30,02,12,20,30,03,12,20,30,04,12,20,30,05,12,20,30,06,12,20,30,07,12,20,30,8} ...
;short int message_dp1[]={34,0,0,1,0,34,0,1,0,0,34,1,0,0,0,1}; //0.001,00.01,000.1,0001
;short int message_neg[]={30,30,30,30}; //----
;short int message_open[]={01,33,33,33}; //1
;
;bit cal_fl,ser_fl,hold_fl;     //calibration mode flag;
;
;
;// end of key routine parameters map/////
;
;int table_p[]={-8388,-6176,-4054,-2000,0,1955,3870,5730,7554,9335,11075,12775,14432,16052,17635,19171,20685,22158,24000} ...
;unsigned int table_j[]={0,258,527,801,1078,1356,1633,1909,2185,2461,2739,3022,3310,3607,3913};
;unsigned int table_k[]={0,202,410,614,814,1015,1221,1430,1640,1852,2064,2278,2491,2703,2913,3121,3328,3531,3733,3931,412 ...
;//unsigned int table_k[]={0,184,392,597,797,1000,1206,1415,1626,1839,2052,2266,2480,2693,2903,3112,3319,3524,3726,3925,4 ...
;//unsigned int table_j[]={0,239,509,784,1062,1339,1619,1895,2172,2449,2729,3012,3301,3600,3906};
;
;//unsigned int table_r[]={0,296,647,1041,1469,1923,2401,2896,3408,3933,4471,5021,5583,6157,6743,7340,7950,8571,9205,9850 ...
;//unsigned int table_s[]={0,299,646,1029,1441,1874,2323,2786,3259,3742,4233,4732,5239,5753,6275,6806,7345,7893,8449,9014 ...
;//unsigned int table_t[]={0,204,428,670,929,1201,1486,1782};
;unsigned int table_r[]={0,296,647,1041,1469,1923,2401,2896,3408,3933,4471,5021,5583,6157,6743,7340,7950,8571,9205,9850,1 ...
;unsigned int table_s[]={0,299,646,1029,1441,1874,2323,2786,3259,3742,4233,4732,5239,5753,6275,6806,7345,7893,8449,9014,9 ...
;int table_t[]={-560,-464,-338,-182,0,204,428,670,929,1201,1486,1782};
;
;
;///////////////////////MODBUS CODES /////////////////////////
;
;
;
;
;
;flash int wCRCTable[] = {
;0X0000, 0XC0C1, 0XC181, 0X0140, 0XC301, 0X03C0, 0X0280, 0XC241,
;0XC601, 0X06C0, 0X0780, 0XC741, 0X0500, 0XC5C1, 0XC481, 0X0440,
;0XCC01, 0X0CC0, 0X0D80, 0XCD41, 0X0F00, 0XCFC1, 0XCE81, 0X0E40,
;0X0A00, 0XCAC1, 0XCB81, 0X0B40, 0XC901, 0X09C0, 0X0880, 0XC841,
;0XD801, 0X18C0, 0X1980, 0XD941, 0X1B00, 0XDBC1, 0XDA81, 0X1A40,
;0X1E00, 0XDEC1, 0XDF81, 0X1F40, 0XDD01, 0X1DC0, 0X1C80, 0XDC41,
;0X1400, 0XD4C1, 0XD581, 0X1540, 0XD701, 0X17C0, 0X1680, 0XD641,
;0XD201, 0X12C0, 0X1380, 0XD341, 0X1100, 0XD1C1, 0XD081, 0X1040,
;0XF001, 0X30C0, 0X3180, 0XF141, 0X3300, 0XF3C1, 0XF281, 0X3240,
;0X3600, 0XF6C1, 0XF781, 0X3740, 0XF501, 0X35C0, 0X3480, 0XF441,
;0X3C00, 0XFCC1, 0XFD81, 0X3D40, 0XFF01, 0X3FC0, 0X3E80, 0XFE41,
;0XFA01, 0X3AC0, 0X3B80, 0XFB41, 0X3900, 0XF9C1, 0XF881, 0X3840,
;0X2800, 0XE8C1, 0XE981, 0X2940, 0XEB01, 0X2BC0, 0X2A80, 0XEA41,
;0XEE01, 0X2EC0, 0X2F80, 0XEF41, 0X2D00, 0XEDC1, 0XEC81, 0X2C40,
;0XE401, 0X24C0, 0X2580, 0XE541, 0X2700, 0XE7C1, 0XE681, 0X2640,
;0X2200, 0XE2C1, 0XE381, 0X2340, 0XE101, 0X21C0, 0X2080, 0XE041,
;0XA001, 0X60C0, 0X6180, 0XA141, 0X6300, 0XA3C1, 0XA281, 0X6240,
;0X6600, 0XA6C1, 0XA781, 0X6740, 0XA501, 0X65C0, 0X6480, 0XA441,
;0X6C00, 0XACC1, 0XAD81, 0X6D40, 0XAF01, 0X6FC0, 0X6E80, 0XAE41,
;0XAA01, 0X6AC0, 0X6B80, 0XAB41, 0X6900, 0XA9C1, 0XA881, 0X6840,
;0X7800, 0XB8C1, 0XB981, 0X7940, 0XBB01, 0X7BC0, 0X7A80, 0XBA41,
;0XBE01, 0X7EC0, 0X7F80, 0XBF41, 0X7D00, 0XBDC1, 0XBC81, 0X7C40,
;0XB401, 0X74C0, 0X7580, 0XB541, 0X7700, 0XB7C1, 0XB681, 0X7640,
;0X7200, 0XB2C1, 0XB381, 0X7340, 0XB101, 0X71C0, 0X7080, 0XB041,
;0X5000, 0X90C1, 0X9181, 0X5140, 0X9301, 0X53C0, 0X5280, 0X9241,
;0X9601, 0X56C0, 0X5780, 0X9741, 0X5500, 0X95C1, 0X9481, 0X5440,
;0X9C01, 0X5CC0, 0X5D80, 0X9D41, 0X5F00, 0X9FC1, 0X9E81, 0X5E40,
;0X5A00, 0X9AC1, 0X9B81, 0X5B40, 0X9901, 0X59C0, 0X5880, 0X9841,
;0X8801, 0X48C0, 0X4980, 0X8941, 0X4B00, 0X8BC1, 0X8A81, 0X4A40,
;0X4E00, 0X8EC1, 0X8F81, 0X4F40, 0X8D01, 0X4DC0, 0X4C80, 0X8C41,
;0X4400, 0X84C1, 0X8581, 0X4540, 0X8701, 0X47C0, 0X4680, 0X8641,
;0X8201, 0X42C0, 0X4380, 0X8341, 0X4100, 0X81C1, 0X8081, 0X4040 };
;
;unsigned int CRC16 (const char *nData, unsigned int wLength)
; 0000 0226 {

	.CSEG
_CRC16:
; .FSTART _CRC16
; 0000 0227 
; 0000 0228 
; 0000 0229 char nTemp;
; 0000 022A unsigned int wCRCWord = 0xFFFF;
; 0000 022B 
; 0000 022C    while (wLength--)
	ST   -Y,R27
	ST   -Y,R26
	CALL __SAVELOCR4
;	*nData -> Y+6
;	wLength -> Y+4
;	nTemp -> R17
;	wCRCWord -> R18,R19
	__GETWRN 18,19,-1
_0x38:
	LDD  R30,Y+4
	LDD  R31,Y+4+1
	SBIW R30,1
	STD  Y+4,R30
	STD  Y+4+1,R31
	ADIW R30,1
	BREQ _0x3A
; 0000 022D    {
; 0000 022E       nTemp = *nData++ ^ wCRCWord;
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	LD   R30,X+
	STD  Y+6,R26
	STD  Y+6+1,R27
	EOR  R30,R18
	MOV  R17,R30
; 0000 022F       wCRCWord >>= 8;
	MOV  R18,R19
	CLR  R19
; 0000 0230       wCRCWord ^= wCRCTable[nTemp];
	LDI  R26,LOW(_wCRCTable*2)
	LDI  R27,HIGH(_wCRCTable*2)
	LDI  R31,0
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	CALL __GETW1PF
	__EORWRR 18,19,30,31
; 0000 0231    }
	RJMP _0x38
_0x3A:
; 0000 0232    return wCRCWord;
	MOVW R30,R18
	CALL __LOADLOCR4
	ADIW R28,8
	RET
; 0000 0233 
; 0000 0234 }
; .FEND
;
;int mb_data[57];
;int mb_inputdata[21];
;//function  codes
;#define mbreadholdingregisters  3
;#define mbreadinputregisters    4
;#define mb presetmultipleregisters 16
;#define mbreportslaveid  17
;
;//error codes
;#define mbillegalfunction 1
;#define mbillegaldataaddress 2
;#define mbillegaldatavalue 3
;#define mbslavedevicefailure 4
;#define mbacknowledge 5
;#define mbslavedevicebusy 6
;#define mbnegativeacknowledge 7
;#define mbmemoryparityerror 8
;
;
;
;void mbreset()
; 0000 024B {
_mbreset:
; .FSTART _mbreset
; 0000 024C 
; 0000 024D     rx_counter=0;
	LDI  R30,LOW(0)
	STS  _rx_counter,R30
; 0000 024E     rx_rd_index=0;
	STS  _rx_rd_index,R30
; 0000 024F     rx_rd_index =0;
	STS  _rx_rd_index,R30
; 0000 0250     tx_counter =0;
	STS  _tx_counter,R30
; 0000 0251     tx_wr_index =0;
	STS  _tx_wr_index,R30
; 0000 0252     tx_rd_index =0;
	STS  _tx_rd_index,R30
; 0000 0253 }
	RET
; .FEND
;
;
;//map
;//40001 - 8    process_Value
;//40009-16   al-hi
;//40017-24   al-lo
;//40018-32    r-hi
;//40033-40   r-lo
;void mb_datatransfer()
; 0000 025D {
_mb_datatransfer:
; .FSTART _mb_datatransfer
; 0000 025E short int i,count =0;
; 0000 025F for (i =0;i<8;i++)
	CALL __SAVELOCR4
;	i -> R16,R17
;	count -> R18,R19
	__GETWRN 18,19,0
	__GETWRN 16,17,0
_0x3C:
	__CPWRN 16,17,8
	BRGE _0x3D
; 0000 0260     {
; 0000 0261     mb_data[count] = os[i];
	MOVW R30,R18
	LDI  R26,LOW(_mb_data)
	LDI  R27,HIGH(_mb_data)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	MOVW R0,R30
	MOVW R30,R16
	LDI  R26,LOW(_os)
	LDI  R27,HIGH(_os)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	MOVW R26,R0
	ST   X+,R30
	ST   X,R31
; 0000 0262     count++;
	__ADDWRN 18,19,1
; 0000 0263     }
	__ADDWRN 16,17,1
	RJMP _0x3C
_0x3D:
; 0000 0264 for (i =0;i<8;i++)
	__GETWRN 16,17,0
_0x3F:
	__CPWRN 16,17,8
	BRGE _0x40
; 0000 0265     {
; 0000 0266     mb_data[count] = skip[i];
	MOVW R30,R18
	LDI  R26,LOW(_mb_data)
	LDI  R27,HIGH(_mb_data)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	MOVW R0,R30
	MOVW R30,R16
	LDI  R26,LOW(_skip)
	LDI  R27,HIGH(_skip)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	MOVW R26,R0
	ST   X+,R30
	ST   X,R31
; 0000 0267     count++;
	__ADDWRN 18,19,1
; 0000 0268     }
	__ADDWRN 16,17,1
	RJMP _0x3F
_0x40:
; 0000 0269 for (i =0;i<8;i++)
	__GETWRN 16,17,0
_0x42:
	__CPWRN 16,17,8
	BRGE _0x43
; 0000 026A     {
; 0000 026B     mb_data[count] = ahigh[i];
	MOVW R30,R18
	LDI  R26,LOW(_mb_data)
	LDI  R27,HIGH(_mb_data)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	MOVW R0,R30
	MOVW R30,R16
	LDI  R26,LOW(_ahigh)
	LDI  R27,HIGH(_ahigh)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	MOVW R26,R0
	ST   X+,R30
	ST   X,R31
; 0000 026C     count++;
	__ADDWRN 18,19,1
; 0000 026D     }
	__ADDWRN 16,17,1
	RJMP _0x42
_0x43:
; 0000 026E for (i =0;i<8;i++)
	__GETWRN 16,17,0
_0x45:
	__CPWRN 16,17,8
	BRGE _0x46
; 0000 026F     {
; 0000 0270     mb_data[count] = alow[i];
	MOVW R30,R18
	LDI  R26,LOW(_mb_data)
	LDI  R27,HIGH(_mb_data)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	MOVW R0,R30
	MOVW R30,R16
	LDI  R26,LOW(_alow)
	LDI  R27,HIGH(_alow)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	MOVW R26,R0
	ST   X+,R30
	ST   X,R31
; 0000 0271     count++;
	__ADDWRN 18,19,1
; 0000 0272     }
	__ADDWRN 16,17,1
	RJMP _0x45
_0x46:
; 0000 0273 for (i =0;i<8;i++)
	__GETWRN 16,17,0
_0x48:
	__CPWRN 16,17,8
	BRGE _0x49
; 0000 0274     {
; 0000 0275     mb_data[count] = rhigh[i];
	MOVW R30,R18
	LDI  R26,LOW(_mb_data)
	LDI  R27,HIGH(_mb_data)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	MOVW R0,R30
	MOVW R30,R16
	LDI  R26,LOW(_rhigh)
	LDI  R27,HIGH(_rhigh)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	MOVW R26,R0
	ST   X+,R30
	ST   X,R31
; 0000 0276     count++;
	__ADDWRN 18,19,1
; 0000 0277     }
	__ADDWRN 16,17,1
	RJMP _0x48
_0x49:
; 0000 0278 for (i =0;i<8;i++)
	__GETWRN 16,17,0
_0x4B:
	__CPWRN 16,17,8
	BRGE _0x4C
; 0000 0279     {
; 0000 027A     mb_data[count] = rlow[i];
	MOVW R30,R18
	LDI  R26,LOW(_mb_data)
	LDI  R27,HIGH(_mb_data)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	MOVW R0,R30
	MOVW R30,R16
	LDI  R26,LOW(_rlow)
	LDI  R27,HIGH(_rlow)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	MOVW R26,R0
	ST   X+,R30
	ST   X,R31
; 0000 027B     count++;
	__ADDWRN 18,19,1
; 0000 027C     }
	__ADDWRN 16,17,1
	RJMP _0x4B
_0x4C:
; 0000 027D for (i =0;i<8;i++)
	__GETWRN 16,17,0
_0x4E:
	__CPWRN 16,17,8
	BRGE _0x4F
; 0000 027E     {
; 0000 027F     mb_data[count] = dp[i];
	MOVW R30,R18
	LDI  R26,LOW(_mb_data)
	LDI  R27,HIGH(_mb_data)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	MOVW R0,R30
	MOVW R30,R16
	LDI  R26,LOW(_dp)
	LDI  R27,HIGH(_dp)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	MOVW R26,R0
	ST   X+,R30
	ST   X,R31
; 0000 0280     count++;
	__ADDWRN 18,19,1
; 0000 0281     }
	__ADDWRN 16,17,1
	RJMP _0x4E
_0x4F:
; 0000 0282 mb_data[count] = gen[0];        //scan time
	MOVW R30,R18
	LDI  R26,LOW(_mb_data)
	LDI  R27,HIGH(_mb_data)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	LDS  R26,_gen
	LDS  R27,_gen+1
	STD  Z+0,R26
	STD  Z+1,R27
; 0000 0283 //end of holding register transfer
; 0000 0284 //start of input register(read only) data
; 0000 0285 count=0;
	__GETWRN 18,19,0
; 0000 0286 for (i =0;i<8;i++)
	__GETWRN 16,17,0
_0x51:
	__CPWRN 16,17,8
	BRLT PC+2
	RJMP _0x52
; 0000 0287     {
; 0000 0288     switch (process_error[i])
	MOVW R30,R16
	LDI  R26,LOW(_process_error)
	LDI  R27,HIGH(_process_error)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
; 0000 0289     {
; 0000 028A     case 0: mb_inputdata[count] = process_value[i];
	SBIW R30,0
	BREQ _0x333
; 0000 028B             break;
; 0000 028C     case 1: mb_inputdata[count] = 20000;       //overrange
	CPI  R30,LOW(0x1)
	LDI  R26,HIGH(0x1)
	CPC  R31,R26
	BRNE _0x57
	MOVW R30,R18
	LDI  R26,LOW(_mb_inputdata)
	LDI  R27,HIGH(_mb_inputdata)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	LDI  R30,LOW(20000)
	LDI  R31,HIGH(20000)
	RJMP _0x334
; 0000 028D             break;
; 0000 028E     case 2: mb_inputdata[count] = 22000;      //underrange
_0x57:
	CPI  R30,LOW(0x2)
	LDI  R26,HIGH(0x2)
	CPC  R31,R26
	BRNE _0x59
	MOVW R30,R18
	LDI  R26,LOW(_mb_inputdata)
	LDI  R27,HIGH(_mb_inputdata)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	LDI  R30,LOW(22000)
	LDI  R31,HIGH(22000)
	RJMP _0x334
; 0000 028F             break;
; 0000 0290     default:mb_inputdata[count] = process_value[i];
_0x59:
_0x333:
	MOVW R30,R18
	LDI  R26,LOW(_mb_inputdata)
	LDI  R27,HIGH(_mb_inputdata)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	MOVW R0,R30
	MOVW R30,R16
	LDI  R26,LOW(_process_value)
	LDI  R27,HIGH(_process_value)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	MOVW R26,R0
_0x334:
	ST   X+,R30
	ST   X,R31
; 0000 0291             break;
; 0000 0292     }
; 0000 0293     if (skip[i] ==1) mb_inputdata[count] =24000;
	MOVW R30,R16
	LDI  R26,LOW(_skip)
	LDI  R27,HIGH(_skip)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	CPI  R30,LOW(0x1)
	LDI  R26,HIGH(0x1)
	CPC  R31,R26
	BRNE _0x5A
	MOVW R30,R18
	LDI  R26,LOW(_mb_inputdata)
	LDI  R27,HIGH(_mb_inputdata)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	LDI  R30,LOW(24000)
	LDI  R31,HIGH(24000)
	ST   X+,R30
	ST   X,R31
; 0000 0294     count++;
_0x5A:
	__ADDWRN 18,19,1
; 0000 0295     }
	__ADDWRN 16,17,1
	RJMP _0x51
_0x52:
; 0000 0296 ///added to store factor to be divided from process value according to dp
; 0000 0297 for (i =0;i<8;i++)
	__GETWRN 16,17,0
_0x5C:
	__CPWRN 16,17,8
	BRLT PC+2
	RJMP _0x5D
; 0000 0298     {
; 0000 0299     switch (dp[i])
	MOVW R30,R16
	LDI  R26,LOW(_dp)
	LDI  R27,HIGH(_dp)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
; 0000 029A     {
; 0000 029B     case 0: mb_inputdata[count] = 1000;
	SBIW R30,0
	BRNE _0x61
	MOVW R30,R18
	LDI  R26,LOW(_mb_inputdata)
	LDI  R27,HIGH(_mb_inputdata)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	LDI  R30,LOW(1000)
	LDI  R31,HIGH(1000)
	RJMP _0x335
; 0000 029C             break;
; 0000 029D     case 1: mb_inputdata[count] = 100;
_0x61:
	CPI  R30,LOW(0x1)
	LDI  R26,HIGH(0x1)
	CPC  R31,R26
	BRNE _0x62
	MOVW R30,R18
	LDI  R26,LOW(_mb_inputdata)
	LDI  R27,HIGH(_mb_inputdata)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	LDI  R30,LOW(100)
	LDI  R31,HIGH(100)
	RJMP _0x335
; 0000 029E             break;
; 0000 029F     case 2: mb_inputdata[count] = 10;
_0x62:
	CPI  R30,LOW(0x2)
	LDI  R26,HIGH(0x2)
	CPC  R31,R26
	BRNE _0x64
	MOVW R30,R18
	LDI  R26,LOW(_mb_inputdata)
	LDI  R27,HIGH(_mb_inputdata)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	LDI  R30,LOW(10)
	LDI  R31,HIGH(10)
	RJMP _0x335
; 0000 02A0             break;
; 0000 02A1     default:mb_inputdata[count] = 1;
_0x64:
	MOVW R30,R18
	LDI  R26,LOW(_mb_inputdata)
	LDI  R27,HIGH(_mb_inputdata)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	LDI  R30,LOW(1)
	LDI  R31,HIGH(1)
_0x335:
	ST   X+,R30
	ST   X,R31
; 0000 02A2             break;
; 0000 02A3     }
; 0000 02A4     count++;
	__ADDWRN 18,19,1
; 0000 02A5     }
	__ADDWRN 16,17,1
	RJMP _0x5C
_0x5D:
; 0000 02A6 ///////////////////////////
; 0000 02A7 
; 0000 02A8 mb_inputdata[count] = gen[1];       //slave ID
	MOVW R30,R18
	LDI  R26,LOW(_mb_inputdata)
	LDI  R27,HIGH(_mb_inputdata)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	__GETW1MN _gen,2
	ST   X+,R30
	ST   X,R31
; 0000 02A9 count++;
	__ADDWRN 18,19,1
; 0000 02AA mb_inputdata[count] = gen[2];       //baud rate
	MOVW R30,R18
	LDI  R26,LOW(_mb_inputdata)
	LDI  R27,HIGH(_mb_inputdata)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	__GETW1MN _gen,4
	ST   X+,R30
	ST   X,R31
; 0000 02AB count++;
	__ADDWRN 18,19,1
; 0000 02AC mb_inputdata[count] = ~led_status;       //bitwise status of alarm high of individual channels
	MOVW R30,R18
	LDI  R26,LOW(_mb_inputdata)
	LDI  R27,HIGH(_mb_inputdata)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	MOVW R30,R4
	COM  R30
	COM  R31
	ST   X+,R30
	ST   X,R31
; 0000 02AD count++;
	__ADDWRN 18,19,1
; 0000 02AE mb_inputdata[count] = ~led_status1;       //bitwise status of alarm high of individual channels
	MOVW R30,R18
	LDI  R26,LOW(_mb_inputdata)
	LDI  R27,HIGH(_mb_inputdata)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	MOVW R30,R6
	COM  R30
	COM  R31
	ST   X+,R30
	ST   X,R31
; 0000 02AF count++;
	__ADDWRN 18,19,1
; 0000 02B0 }
	CALL __LOADLOCR4
	ADIW R28,4
	RET
; .FEND
;
;
;//used for function code 06. write single register.
;//checks the address to be written,if valid,writes to the address and returns 0,else returns 1
;short int mblimitcheck(int address,int value)
; 0000 02B6 {
_mblimitcheck:
; .FSTART _mblimitcheck
; 0000 02B7 int min[8],max[8],i;
; 0000 02B8 short int ok_st=1;
; 0000 02B9 //update min max values according to input
; 0000 02BA for (i=0;i<8;i++)
	ST   -Y,R27
	ST   -Y,R26
	SBIW R28,32
	CALL __SAVELOCR4
;	address -> Y+38
;	value -> Y+36
;	min -> Y+20
;	max -> Y+4
;	i -> R16,R17
;	ok_st -> R18,R19
	__GETWRN 18,19,1
	__GETWRN 16,17,0
_0x66:
	__CPWRN 16,17,8
	BRLT PC+2
	RJMP _0x67
; 0000 02BB     {
; 0000 02BC     switch (input[i])
	MOVW R30,R16
	LDI  R26,LOW(_input)
	LDI  R27,HIGH(_input)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
; 0000 02BD         {
; 0000 02BE         case 0: min[i] = -1999  ;
	SBIW R30,0
	BRNE _0x6B
	MOVW R30,R16
	MOVW R26,R28
	ADIW R26,20
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	LDI  R30,LOW(63537)
	LDI  R31,HIGH(63537)
	ST   X+,R30
	ST   X,R31
; 0000 02BF                 max[i] = 7000  ;
	MOVW R30,R16
	MOVW R26,R28
	ADIW R26,4
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	LDI  R30,LOW(7000)
	LDI  R31,HIGH(7000)
	RJMP _0x336
; 0000 02C0                 break;
; 0000 02C1         case 1: min[i] =-199  ;
_0x6B:
	CPI  R30,LOW(0x1)
	LDI  R26,HIGH(0x1)
	CPC  R31,R26
	BRNE _0x6C
	MOVW R30,R16
	MOVW R26,R28
	ADIW R26,20
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	LDI  R30,LOW(65337)
	LDI  R31,HIGH(65337)
	ST   X+,R30
	ST   X,R31
; 0000 02C2                 max[i] =700  ;
	MOVW R30,R16
	MOVW R26,R28
	ADIW R26,4
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	LDI  R30,LOW(700)
	LDI  R31,HIGH(700)
	RJMP _0x336
; 0000 02C3                 break;
; 0000 02C4         case 2: min[i] =0  ;
_0x6C:
	CPI  R30,LOW(0x2)
	LDI  R26,HIGH(0x2)
	CPC  R31,R26
	BRNE _0x6D
	MOVW R30,R16
	MOVW R26,R28
	ADIW R26,20
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	ST   X+,R30
	ST   X,R31
; 0000 02C5                 max[i] =700  ;
	MOVW R30,R16
	MOVW R26,R28
	ADIW R26,4
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	LDI  R30,LOW(700)
	LDI  R31,HIGH(700)
	RJMP _0x336
; 0000 02C6                 break;
; 0000 02C7         case 3: min[i] =0  ;
_0x6D:
	CPI  R30,LOW(0x3)
	LDI  R26,HIGH(0x3)
	CPC  R31,R26
	BRNE _0x6E
	MOVW R30,R16
	MOVW R26,R28
	ADIW R26,20
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	ST   X+,R30
	ST   X,R31
; 0000 02C8                 max[i] =1300  ;
	MOVW R30,R16
	MOVW R26,R28
	ADIW R26,4
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	LDI  R30,LOW(1300)
	LDI  R31,HIGH(1300)
	RJMP _0x336
; 0000 02C9                 break;
; 0000 02CA         case 4:
_0x6E:
	CPI  R30,LOW(0x4)
	LDI  R26,HIGH(0x4)
	CPC  R31,R26
	BREQ _0x70
; 0000 02CB         case 5: min[i] =0  ;
	CPI  R30,LOW(0x5)
	LDI  R26,HIGH(0x5)
	CPC  R31,R26
	BRNE _0x71
_0x70:
	MOVW R30,R16
	MOVW R26,R28
	ADIW R26,20
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	ST   X+,R30
	ST   X,R31
; 0000 02CC                 max[i] =1700  ;
	MOVW R30,R16
	MOVW R26,R28
	ADIW R26,4
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	LDI  R30,LOW(1700)
	LDI  R31,HIGH(1700)
	RJMP _0x336
; 0000 02CD                 break;
; 0000 02CE         case 6: min[i] =-200  ;
_0x71:
	CPI  R30,LOW(0x6)
	LDI  R26,HIGH(0x6)
	CPC  R31,R26
	BRNE _0x72
	MOVW R30,R16
	MOVW R26,R28
	ADIW R26,20
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	LDI  R30,LOW(65336)
	LDI  R31,HIGH(65336)
	ST   X+,R30
	ST   X,R31
; 0000 02CF                 max[i] =300  ;
	MOVW R30,R16
	MOVW R26,R28
	ADIW R26,4
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	LDI  R30,LOW(300)
	LDI  R31,HIGH(300)
	RJMP _0x336
; 0000 02D0                 break;
; 0000 02D1         case 7:
_0x72:
	CPI  R30,LOW(0x7)
	LDI  R26,HIGH(0x7)
	CPC  R31,R26
	BREQ _0x74
; 0000 02D2         case 8: min[i] =rlow[i] - (rlow[i]*20/100);
	CPI  R30,LOW(0x8)
	LDI  R26,HIGH(0x8)
	CPC  R31,R26
	BREQ PC+2
	RJMP _0x6A
_0x74:
	MOVW R30,R16
	MOVW R26,R28
	ADIW R26,20
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	PUSH R31
	PUSH R30
	MOVW R30,R16
	LDI  R26,LOW(_rlow)
	LDI  R27,HIGH(_rlow)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	LD   R22,X+
	LD   R23,X
	MOVW R30,R16
	LDI  R26,LOW(_rlow)
	LDI  R27,HIGH(_rlow)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	LDI  R26,LOW(20)
	LDI  R27,HIGH(20)
	CALL __MULW12
	MOVW R26,R30
	LDI  R30,LOW(100)
	LDI  R31,HIGH(100)
	CALL __DIVW21
	MOVW R26,R30
	MOVW R30,R22
	SUB  R30,R26
	SBC  R31,R27
	POP  R26
	POP  R27
	ST   X+,R30
	ST   X,R31
; 0000 02D3                 max[i] =rhigh[i]+ (rhigh[i]*20/100);
	MOVW R30,R16
	MOVW R26,R28
	ADIW R26,4
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	PUSH R31
	PUSH R30
	MOVW R30,R16
	LDI  R26,LOW(_rhigh)
	LDI  R27,HIGH(_rhigh)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	LD   R22,X+
	LD   R23,X
	MOVW R30,R16
	LDI  R26,LOW(_rhigh)
	LDI  R27,HIGH(_rhigh)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	LDI  R26,LOW(20)
	LDI  R27,HIGH(20)
	CALL __MULW12
	MOVW R26,R30
	LDI  R30,LOW(100)
	LDI  R31,HIGH(100)
	CALL __DIVW21
	ADD  R30,R22
	ADC  R31,R23
	POP  R26
	POP  R27
_0x336:
	ST   X+,R30
	ST   X,R31
; 0000 02D4                 break;
; 0000 02D5         }
_0x6A:
; 0000 02D6 
; 0000 02D7     }
	__ADDWRN 16,17,1
	RJMP _0x66
_0x67:
; 0000 02D8 
; 0000 02D9 //offset range check
; 0000 02DA if (address <=7)
	LDD  R26,Y+38
	LDD  R27,Y+38+1
	SBIW R26,8
	BRGE _0x76
; 0000 02DB     {
; 0000 02DC     if (value >=-999 && value <= 999)
	LDD  R26,Y+36
	LDD  R27,Y+36+1
	CPI  R26,LOW(0xFC19)
	LDI  R30,HIGH(0xFC19)
	CPC  R27,R30
	BRLT _0x78
	CPI  R26,LOW(0x3E8)
	LDI  R30,HIGH(0x3E8)
	CPC  R27,R30
	BRLT _0x79
_0x78:
	RJMP _0x77
_0x79:
; 0000 02DD         {
; 0000 02DE         ee_os[address] = os[address] = value;
	LDD  R30,Y+38
	LDD  R31,Y+38+1
	LDI  R26,LOW(_ee_os)
	LDI  R27,HIGH(_ee_os)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	MOVW R0,R30
	LDD  R30,Y+38
	LDD  R31,Y+38+1
	LDI  R26,LOW(_os)
	LDI  R27,HIGH(_os)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	LDD  R30,Y+36
	LDD  R31,Y+36+1
	ST   X+,R30
	ST   X,R31
	MOVW R26,R0
	CALL __EEPROMWRW
; 0000 02DF         ok_st =0;
	__GETWRN 18,19,0
; 0000 02E0         }
; 0000 02E1     }
_0x77:
; 0000 02E2 // skip status check
; 0000 02E3 else if (address>=8 && address <=15)
	RJMP _0x7A
_0x76:
	LDD  R26,Y+38
	LDD  R27,Y+38+1
	SBIW R26,8
	BRLT _0x7C
	LDD  R26,Y+38
	LDD  R27,Y+38+1
	SBIW R26,16
	BRLT _0x7D
_0x7C:
	RJMP _0x7B
_0x7D:
; 0000 02E4     {
; 0000 02E5     if (value >=0 && value <= 1)
	LDD  R26,Y+37
	TST  R26
	BRMI _0x7F
	LDD  R26,Y+36
	LDD  R27,Y+36+1
	SBIW R26,2
	BRLT _0x80
_0x7F:
	RJMP _0x7E
_0x80:
; 0000 02E6         {
; 0000 02E7         ee_skip[address-8] = skip[address-8] = value;
	LDD  R30,Y+38
	LDD  R31,Y+38+1
	SBIW R30,8
	MOVW R22,R30
	LDI  R26,LOW(_ee_skip)
	LDI  R27,HIGH(_ee_skip)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	MOVW R0,R30
	MOVW R30,R22
	LDI  R26,LOW(_skip)
	LDI  R27,HIGH(_skip)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	LDD  R30,Y+36
	LDD  R31,Y+36+1
	ST   X+,R30
	ST   X,R31
	MOVW R26,R0
	CALL __EEPROMWRW
; 0000 02E8         ok_st =0;
	__GETWRN 18,19,0
; 0000 02E9         }
; 0000 02EA     }
_0x7E:
; 0000 02EB //alarm high
; 0000 02EC else if (address>=16 && address <=23)
	RJMP _0x81
_0x7B:
	LDD  R26,Y+38
	LDD  R27,Y+38+1
	SBIW R26,16
	BRLT _0x83
	LDD  R26,Y+38
	LDD  R27,Y+38+1
	SBIW R26,24
	BRLT _0x84
_0x83:
	RJMP _0x82
_0x84:
; 0000 02ED     {
; 0000 02EE     if (value >=min[address-16] && value <= max[address-16])
	LDD  R30,Y+38
	LDD  R31,Y+38+1
	SBIW R30,16
	MOVW R0,R30
	MOVW R26,R28
	ADIW R26,20
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	LDD  R26,Y+36
	LDD  R27,Y+36+1
	CP   R26,R30
	CPC  R27,R31
	BRLT _0x86
	MOVW R30,R0
	MOVW R26,R28
	ADIW R26,4
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	LDD  R26,Y+36
	LDD  R27,Y+36+1
	CP   R30,R26
	CPC  R31,R27
	BRGE _0x87
_0x86:
	RJMP _0x85
_0x87:
; 0000 02EF         {
; 0000 02F0         ee_ahigh[address-16] = ahigh[address-16] = value;
	LDD  R30,Y+38
	LDD  R31,Y+38+1
	SBIW R30,16
	MOVW R22,R30
	LDI  R26,LOW(_ee_ahigh)
	LDI  R27,HIGH(_ee_ahigh)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	MOVW R0,R30
	MOVW R30,R22
	LDI  R26,LOW(_ahigh)
	LDI  R27,HIGH(_ahigh)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	LDD  R30,Y+36
	LDD  R31,Y+36+1
	ST   X+,R30
	ST   X,R31
	MOVW R26,R0
	CALL __EEPROMWRW
; 0000 02F1         ok_st =0;
	__GETWRN 18,19,0
; 0000 02F2         }
; 0000 02F3     }
_0x85:
; 0000 02F4 //alarm low
; 0000 02F5 else if (address>=24 && address <=31)
	RJMP _0x88
_0x82:
	LDD  R26,Y+38
	LDD  R27,Y+38+1
	SBIW R26,24
	BRLT _0x8A
	LDD  R26,Y+38
	LDD  R27,Y+38+1
	SBIW R26,32
	BRLT _0x8B
_0x8A:
	RJMP _0x89
_0x8B:
; 0000 02F6     {
; 0000 02F7     if (value >=min[address-24] && value <= max[address-24])
	LDD  R30,Y+38
	LDD  R31,Y+38+1
	SBIW R30,24
	MOVW R0,R30
	MOVW R26,R28
	ADIW R26,20
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	LDD  R26,Y+36
	LDD  R27,Y+36+1
	CP   R26,R30
	CPC  R27,R31
	BRLT _0x8D
	MOVW R30,R0
	MOVW R26,R28
	ADIW R26,4
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	LDD  R26,Y+36
	LDD  R27,Y+36+1
	CP   R30,R26
	CPC  R31,R27
	BRGE _0x8E
_0x8D:
	RJMP _0x8C
_0x8E:
; 0000 02F8         {
; 0000 02F9         ee_alow[address-24] = alow[address-24] = value;
	LDD  R30,Y+38
	LDD  R31,Y+38+1
	SBIW R30,24
	MOVW R22,R30
	LDI  R26,LOW(_ee_alow)
	LDI  R27,HIGH(_ee_alow)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	MOVW R0,R30
	MOVW R30,R22
	LDI  R26,LOW(_alow)
	LDI  R27,HIGH(_alow)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	LDD  R30,Y+36
	LDD  R31,Y+36+1
	ST   X+,R30
	ST   X,R31
	MOVW R26,R0
	CALL __EEPROMWRW
; 0000 02FA         ok_st =0;
	__GETWRN 18,19,0
; 0000 02FB         }
; 0000 02FC     }
_0x8C:
; 0000 02FD //range high
; 0000 02FE else if (address>=32 && address <=39)
	RJMP _0x8F
_0x89:
	LDD  R26,Y+38
	LDD  R27,Y+38+1
	SBIW R26,32
	BRLT _0x91
	LDD  R26,Y+38
	LDD  R27,Y+38+1
	SBIW R26,40
	BRLT _0x92
_0x91:
	RJMP _0x90
_0x92:
; 0000 02FF     {
; 0000 0300     if (value >=-1999 && value <= 9999)
	LDD  R26,Y+36
	LDD  R27,Y+36+1
	CPI  R26,LOW(0xF831)
	LDI  R30,HIGH(0xF831)
	CPC  R27,R30
	BRLT _0x94
	CPI  R26,LOW(0x2710)
	LDI  R30,HIGH(0x2710)
	CPC  R27,R30
	BRLT _0x95
_0x94:
	RJMP _0x93
_0x95:
; 0000 0301         {
; 0000 0302         ee_rhigh[address-32] = rhigh[address-32] = value;
	LDD  R30,Y+38
	LDD  R31,Y+38+1
	SBIW R30,32
	MOVW R22,R30
	LDI  R26,LOW(_ee_rhigh)
	LDI  R27,HIGH(_ee_rhigh)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	MOVW R0,R30
	MOVW R30,R22
	LDI  R26,LOW(_rhigh)
	LDI  R27,HIGH(_rhigh)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	LDD  R30,Y+36
	LDD  R31,Y+36+1
	ST   X+,R30
	ST   X,R31
	MOVW R26,R0
	CALL __EEPROMWRW
; 0000 0303         ok_st =0;
	__GETWRN 18,19,0
; 0000 0304         }
; 0000 0305     }
_0x93:
; 0000 0306 //range low
; 0000 0307 else if (address>=40 && address <=47)
	RJMP _0x96
_0x90:
	LDD  R26,Y+38
	LDD  R27,Y+38+1
	SBIW R26,40
	BRLT _0x98
	LDD  R26,Y+38
	LDD  R27,Y+38+1
	SBIW R26,48
	BRLT _0x99
_0x98:
	RJMP _0x97
_0x99:
; 0000 0308     {
; 0000 0309     if (value >=-1999 && value <= 9999)
	LDD  R26,Y+36
	LDD  R27,Y+36+1
	CPI  R26,LOW(0xF831)
	LDI  R30,HIGH(0xF831)
	CPC  R27,R30
	BRLT _0x9B
	CPI  R26,LOW(0x2710)
	LDI  R30,HIGH(0x2710)
	CPC  R27,R30
	BRLT _0x9C
_0x9B:
	RJMP _0x9A
_0x9C:
; 0000 030A         {
; 0000 030B         ee_rlow[address-40] = rlow[address-40] = value;
	LDD  R30,Y+38
	LDD  R31,Y+38+1
	SBIW R30,40
	MOVW R22,R30
	LDI  R26,LOW(_ee_rlow)
	LDI  R27,HIGH(_ee_rlow)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	MOVW R0,R30
	MOVW R30,R22
	LDI  R26,LOW(_rlow)
	LDI  R27,HIGH(_rlow)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	LDD  R30,Y+36
	LDD  R31,Y+36+1
	ST   X+,R30
	ST   X,R31
	MOVW R26,R0
	CALL __EEPROMWRW
; 0000 030C         ok_st =0;
	__GETWRN 18,19,0
; 0000 030D         }
; 0000 030E     }
_0x9A:
; 0000 030F //decimal point
; 0000 0310 else if (address>=48 && address <=55)
	RJMP _0x9D
_0x97:
	LDD  R26,Y+38
	LDD  R27,Y+38+1
	SBIW R26,48
	BRLT _0x9F
	LDD  R26,Y+38
	LDD  R27,Y+38+1
	SBIW R26,56
	BRLT _0xA0
_0x9F:
	RJMP _0x9E
_0xA0:
; 0000 0311     {
; 0000 0312     if (value >=0 && value <= 3)
	LDD  R26,Y+37
	TST  R26
	BRMI _0xA2
	LDD  R26,Y+36
	LDD  R27,Y+36+1
	SBIW R26,4
	BRLT _0xA3
_0xA2:
	RJMP _0xA1
_0xA3:
; 0000 0313         {
; 0000 0314         ee_dp[address-48] = dp[address-48] = value;
	LDD  R30,Y+38
	LDD  R31,Y+38+1
	SBIW R30,48
	MOVW R22,R30
	LDI  R26,LOW(_ee_dp)
	LDI  R27,HIGH(_ee_dp)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	MOVW R0,R30
	MOVW R30,R22
	LDI  R26,LOW(_dp)
	LDI  R27,HIGH(_dp)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	LDD  R30,Y+36
	LDD  R31,Y+36+1
	ST   X+,R30
	ST   X,R31
	MOVW R26,R0
	CALL __EEPROMWRW
; 0000 0315         ok_st =0;
	__GETWRN 18,19,0
; 0000 0316         }
; 0000 0317     }
_0xA1:
; 0000 0318 //scan time
; 0000 0319 else if (address == 56)
	RJMP _0xA4
_0x9E:
	LDD  R26,Y+38
	LDD  R27,Y+38+1
	SBIW R26,56
	BRNE _0xA5
; 0000 031A     {
; 0000 031B     if (value >=0 && value <= 99)
	LDD  R26,Y+37
	TST  R26
	BRMI _0xA7
	LDD  R26,Y+36
	LDD  R27,Y+36+1
	CPI  R26,LOW(0x64)
	LDI  R30,HIGH(0x64)
	CPC  R27,R30
	BRLT _0xA8
_0xA7:
	RJMP _0xA6
_0xA8:
; 0000 031C         {
; 0000 031D         ee_gen[0] = gen[0] = value;
	LDD  R30,Y+36
	LDD  R31,Y+36+1
	STS  _gen,R30
	STS  _gen+1,R31
	LDI  R26,LOW(_ee_gen)
	LDI  R27,HIGH(_ee_gen)
	CALL __EEPROMWRW
; 0000 031E         ok_st =0;
	__GETWRN 18,19,0
; 0000 031F         }
; 0000 0320     }
_0xA6:
; 0000 0321 return (ok_st);
_0xA5:
_0xA4:
_0x9D:
_0x96:
_0x8F:
_0x88:
_0x81:
_0x7A:
	MOVW R30,R18
	CALL __LOADLOCR4
	ADIW R28,40
	RET
; 0000 0322 }
; .FEND
;
;
;void check_mbreceived()
; 0000 0326 {
_check_mbreceived:
; .FSTART _check_mbreceived
; 0000 0327 unsigned int mbaddress;
; 0000 0328 int mbamount;
; 0000 0329 unsigned char mbtransmit_data[40];        //transmit buffer max. 32 nytes or 16 registers
; 0000 032A short int error_code =0;
; 0000 032B unsigned int i,j,k;
; 0000 032C //mb_dir =0;  //set 485 to transmit data
; 0000 032D //check function code
; 0000 032E //printf(" test sending");
; 0000 032F switch (mbreceived_data[1])
	SBIW R28,46
	CALL __SAVELOCR6
;	mbaddress -> R16,R17
;	mbamount -> R18,R19
;	mbtransmit_data -> Y+12
;	error_code -> R20,R21
;	i -> Y+10
;	j -> Y+8
;	k -> Y+6
	__GETWRN 20,21,0
	__GETB1MN _mbreceived_data,1
	LDI  R31,0
; 0000 0330             {
; 0000 0331             case 0x03:
	CPI  R30,LOW(0x3)
	LDI  R26,HIGH(0x3)
	CPC  R31,R26
	BREQ PC+2
	RJMP _0xAC
; 0000 0332  //                mbaddress = (mbreceived_data[2]*256) + mbreceived_data[3];      //start address;
; 0000 0333                  mbaddress = mbreceived_data[3];      //start address;
	__GETBRMN 16,_mbreceived_data,3
	CLR  R17
; 0000 0334                  if (mbaddress+1 >=58)
	MOVW R26,R16
	ADIW R26,1
	SBIW R26,58
	BRLO _0xAD
; 0000 0335                     {
; 0000 0336                     error_code = mbillegaldataaddress;
	__GETWRN 20,21,2
; 0000 0337                     break;
	RJMP _0xAB
; 0000 0338                     }
; 0000 0339 //                 mbamount = (mbreceived_data[4] *256) +mbreceived_data[5];      //requested amount
; 0000 033A                  mbamount = mbreceived_data[5];      //requested amount
_0xAD:
	__GETBRMN 18,_mbreceived_data,5
	CLR  R19
; 0000 033B                  if ((mbaddress+mbamount) > 58 || mbamount >16)
	MOVW R26,R18
	ADD  R26,R16
	ADC  R27,R17
	SBIW R26,59
	BRSH _0xAF
	__CPWRN 18,19,17
	BRLT _0xAE
_0xAF:
; 0000 033C                     {
; 0000 033D                     error_code = mbillegaldatavalue;         //requested data overflow
	__GETWRN 20,21,3
; 0000 033E                     break;
	RJMP _0xAB
; 0000 033F                     }
; 0000 0340                     i = CRC16(rx_buffer,6);
_0xAE:
	LDI  R30,LOW(_rx_buffer)
	LDI  R31,HIGH(_rx_buffer)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(6)
	LDI  R27,0
	RCALL _CRC16
	STD  Y+10,R30
	STD  Y+10+1,R31
; 0000 0341 
; 0000 0342                     if((rx_buffer[6] != i%256) || (rx_buffer[7] != i/256)  )
	__GETB2MN _rx_buffer,6
	ANDI R31,HIGH(0xFF)
	LDI  R27,0
	CP   R30,R26
	CPC  R31,R27
	BRNE _0xB2
	__GETB2MN _rx_buffer,7
	LDD  R30,Y+11
	ANDI R31,HIGH(0x0)
	LDI  R27,0
	CP   R30,R26
	CPC  R31,R27
	BREQ _0xB1
_0xB2:
; 0000 0343                     {
; 0000 0344                     error_code = mbillegaldatavalue;      //CRC not matching
	__GETWRN 20,21,3
; 0000 0345                     break;
	RJMP _0xAB
; 0000 0346                     }
; 0000 0347                   //valid request so form mb frame accordingly
; 0000 0348                   error_code =0;       //
_0xB1:
	__GETWRN 20,21,0
; 0000 0349                     mb_dir =1;      //transmit
	SBI  0x12,2
; 0000 034A //                  mbamount =8;                  //test
; 0000 034B                   mbtransmit_data[0] = mbreceived_data[0];      //slave id
	LDS  R30,_mbreceived_data
	STD  Y+12,R30
; 0000 034C                   mbtransmit_data[1] = mbreceived_data[1];       //function code
	__GETB1MN _mbreceived_data,1
	STD  Y+13,R30
; 0000 034D                   mbtransmit_data[2] = (char)mbamount *2;             //SIZE OF DATA IN BYTES
	MOV  R30,R18
	LSL  R30
	STD  Y+14,R30
; 0000 034E                     j=3;
	LDI  R30,LOW(3)
	LDI  R31,HIGH(3)
	STD  Y+8,R30
	STD  Y+8+1,R31
; 0000 034F 
; 0000 0350 //                    mb_dir =0;  //set to transmit
; 0000 0351                     delay_ms(2);
	LDI  R26,LOW(2)
	LDI  R27,0
	CALL _delay_ms
; 0000 0352                     for (i=0;i<mbamount;i++)               //transfer data
	LDI  R30,LOW(0)
	STD  Y+10,R30
	STD  Y+10+1,R30
_0xB7:
	LDD  R26,Y+10
	LDD  R27,Y+10+1
	CP   R26,R18
	CPC  R27,R19
	BRSH _0xB8
; 0000 0353                         {
; 0000 0354 //                        mbtransmit_data[j] = (char)(mb_data[mbaddress+i]/256);
; 0000 0355                          mbtransmit_data[j] = (short int)((mb_data[mbaddress+i]>>8)& 0X00ff);
	LDD  R30,Y+8
	LDD  R31,Y+8+1
	MOVW R26,R28
	ADIW R26,12
	ADD  R30,R26
	ADC  R31,R27
	MOVW R0,R30
	LDD  R30,Y+10
	LDD  R31,Y+10+1
	ADD  R30,R16
	ADC  R31,R17
	LDI  R26,LOW(_mb_data)
	LDI  R27,HIGH(_mb_data)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	CALL __ASRW8
	MOVW R26,R0
	ST   X,R30
; 0000 0356 
; 0000 0357                         j++;
	LDD  R30,Y+8
	LDD  R31,Y+8+1
	ADIW R30,1
	STD  Y+8,R30
	STD  Y+8+1,R31
; 0000 0358 //                        mbtransmit_data[j] = (char)(mb_data[mbaddress+i]%256);
; 0000 0359                          mbtransmit_data[j] = (short int)(mb_data[mbaddress+i]& 0X00ff);
	MOVW R26,R28
	ADIW R26,12
	ADD  R30,R26
	ADC  R31,R27
	MOVW R0,R30
	LDD  R30,Y+10
	LDD  R31,Y+10+1
	ADD  R30,R16
	ADC  R31,R17
	LDI  R26,LOW(_mb_data)
	LDI  R27,HIGH(_mb_data)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	LD   R30,X
	MOVW R26,R0
	ST   X,R30
; 0000 035A 
; 0000 035B                         j++;
	LDD  R30,Y+8
	LDD  R31,Y+8+1
	ADIW R30,1
	STD  Y+8,R30
	STD  Y+8+1,R31
; 0000 035C                         }
	LDD  R30,Y+10
	LDD  R31,Y+10+1
	ADIW R30,1
	STD  Y+10,R30
	STD  Y+10+1,R31
	RJMP _0xB7
_0xB8:
; 0000 035D                     i= CRC16(mbtransmit_data,(mbamount*2)+3);
	MOVW R30,R28
	ADIW R30,12
	ST   -Y,R31
	ST   -Y,R30
	MOVW R30,R18
	LSL  R30
	ROL  R31
	ADIW R30,3
	MOVW R26,R30
	RCALL _CRC16
	STD  Y+10,R30
	STD  Y+10+1,R31
; 0000 035E                     mbtransmit_data[j] = i%256;
	LDD  R30,Y+8
	LDD  R31,Y+8+1
	MOVW R26,R28
	ADIW R26,12
	ADD  R26,R30
	ADC  R27,R31
	LDD  R30,Y+10
	ST   X,R30
; 0000 035F                     mbtransmit_data[j+1]=i/256;
	LDD  R30,Y+8
	LDD  R31,Y+8+1
	ADIW R30,1
	MOVW R26,R28
	ADIW R26,12
	ADD  R26,R30
	ADC  R27,R31
	LDD  R30,Y+11
	ST   X,R30
; 0000 0360                     #asm("cli")
	cli
; 0000 0361 
; 0000 0362 //                    mb_dir =0;//set to transmit data
; 0000 0363                     for (i=0;i<mbtransmit_data[2]+4+1;i++)
	LDI  R30,LOW(0)
	STD  Y+10,R30
	STD  Y+10+1,R30
_0xBA:
	LDD  R30,Y+14
	LDI  R31,0
	ADIW R30,5
	LDD  R26,Y+10
	LDD  R27,Y+10+1
	CP   R26,R30
	CPC  R27,R31
	BRSH _0xBB
; 0000 0364                         {
; 0000 0365                         putchar(mbtransmit_data[i]);
	LDD  R30,Y+10
	LDD  R31,Y+10+1
	MOVW R26,R28
	ADIW R26,12
	ADD  R26,R30
	ADC  R27,R31
	LD   R26,X
	RCALL _putchar
; 0000 0366                         }
	LDD  R30,Y+10
	LDD  R31,Y+10+1
	ADIW R30,1
	STD  Y+10,R30
	STD  Y+10+1,R31
	RJMP _0xBA
_0xBB:
; 0000 0367 
; 0000 0368 //                     mbreset();
; 0000 0369                     #asm("sei")
	sei
; 0000 036A                     delay_ms(50);      //wait till all data transmitted need time to transmit max 36 bytes @9600
	LDI  R26,LOW(50)
	LDI  R27,0
	CALL _delay_ms
; 0000 036B                     mb_dir =0;   //recieve
	CBI  0x12,2
; 0000 036C                     mbreset();
	RCALL _mbreset
; 0000 036D                     break;
	RJMP _0xAB
; 0000 036E             case 0x04:     //read input registers (30xxx)
_0xAC:
	CPI  R30,LOW(0x4)
	LDI  R26,HIGH(0x4)
	CPC  R31,R26
	BREQ PC+2
	RJMP _0xBE
; 0000 036F                      //                mbaddress = (mbreceived_data[2]*256) + mbreceived_data[3];      //start address;
; 0000 0370                  mbaddress = mbreceived_data[3];      //start address; 30001
	__GETBRMN 16,_mbreceived_data,3
	CLR  R17
; 0000 0371                  if (mbaddress+1 >=21)
	MOVW R26,R16
	ADIW R26,1
	SBIW R26,21
	BRLO _0xBF
; 0000 0372                     {
; 0000 0373                     error_code = mbillegaldataaddress;
	__GETWRN 20,21,2
; 0000 0374                     break;
	RJMP _0xAB
; 0000 0375                     }
; 0000 0376 //                 mbamount = (mbreceived_data[4] *256) +mbreceived_data[5];      //requested amount
; 0000 0377                  mbamount = mbreceived_data[5];      //requested amount
_0xBF:
	__GETBRMN 18,_mbreceived_data,5
	CLR  R19
; 0000 0378                  if ((mbaddress+mbamount) > 20 || mbamount >16)
	MOVW R26,R18
	ADD  R26,R16
	ADC  R27,R17
	SBIW R26,21
	BRSH _0xC1
	__CPWRN 18,19,17
	BRLT _0xC0
_0xC1:
; 0000 0379                     {
; 0000 037A                     error_code = mbillegaldatavalue;         //requested data overflow
	__GETWRN 20,21,3
; 0000 037B                     break;
	RJMP _0xAB
; 0000 037C                     }
; 0000 037D                     i = CRC16(rx_buffer,6);
_0xC0:
	LDI  R30,LOW(_rx_buffer)
	LDI  R31,HIGH(_rx_buffer)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(6)
	LDI  R27,0
	RCALL _CRC16
	STD  Y+10,R30
	STD  Y+10+1,R31
; 0000 037E 
; 0000 037F                     if((rx_buffer[6] != i%256) || (rx_buffer[7] != i/256)  )
	__GETB2MN _rx_buffer,6
	ANDI R31,HIGH(0xFF)
	LDI  R27,0
	CP   R30,R26
	CPC  R31,R27
	BRNE _0xC4
	__GETB2MN _rx_buffer,7
	LDD  R30,Y+11
	ANDI R31,HIGH(0x0)
	LDI  R27,0
	CP   R30,R26
	CPC  R31,R27
	BREQ _0xC3
_0xC4:
; 0000 0380                     {
; 0000 0381                     error_code = mbillegaldatavalue;      //CRC not matching
	__GETWRN 20,21,3
; 0000 0382                     break;
	RJMP _0xAB
; 0000 0383                     }
; 0000 0384 
; 0000 0385                   //valid request so form mb frame accordingly
; 0000 0386                   error_code =0;       //
_0xC3:
	__GETWRN 20,21,0
; 0000 0387                     mb_dir =1;      //transmit
	SBI  0x12,2
; 0000 0388 //                  mbamount =8;                  //test
; 0000 0389                   mbtransmit_data[0] = mbreceived_data[0];      //slave id
	LDS  R30,_mbreceived_data
	STD  Y+12,R30
; 0000 038A                   mbtransmit_data[1] = mbreceived_data[1];       //function code
	__GETB1MN _mbreceived_data,1
	STD  Y+13,R30
; 0000 038B                   mbtransmit_data[2] = (char)mbamount *2;             //SIZE OF DATA IN BYTES
	MOV  R30,R18
	LSL  R30
	STD  Y+14,R30
; 0000 038C                     j=3;
	LDI  R30,LOW(3)
	LDI  R31,HIGH(3)
	STD  Y+8,R30
	STD  Y+8+1,R31
; 0000 038D 
; 0000 038E //                    mb_dir =0;  //set to transmit
; 0000 038F                     delay_ms(2);
	LDI  R26,LOW(2)
	LDI  R27,0
	CALL _delay_ms
; 0000 0390                     for (i=0;i<mbamount;i++)               //transfer data
	LDI  R30,LOW(0)
	STD  Y+10,R30
	STD  Y+10+1,R30
_0xC9:
	LDD  R26,Y+10
	LDD  R27,Y+10+1
	CP   R26,R18
	CPC  R27,R19
	BRSH _0xCA
; 0000 0391                         {
; 0000 0392 //                        mbtransmit_data[j] = (char)(mb_inputdata[mbaddress+i]/256);
; 0000 0393                          mbtransmit_data[j] = (short int)((mb_inputdata[mbaddress+i]>>8)& 0X00ff);
	LDD  R30,Y+8
	LDD  R31,Y+8+1
	MOVW R26,R28
	ADIW R26,12
	ADD  R30,R26
	ADC  R31,R27
	MOVW R0,R30
	LDD  R30,Y+10
	LDD  R31,Y+10+1
	ADD  R30,R16
	ADC  R31,R17
	LDI  R26,LOW(_mb_inputdata)
	LDI  R27,HIGH(_mb_inputdata)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	CALL __ASRW8
	MOVW R26,R0
	ST   X,R30
; 0000 0394                         j++;
	LDD  R30,Y+8
	LDD  R31,Y+8+1
	ADIW R30,1
	STD  Y+8,R30
	STD  Y+8+1,R31
; 0000 0395 //                        mbtransmit_data[j] = (char)(mb_inputdata[mbaddress+i]%256);
; 0000 0396                          mbtransmit_data[j] = (short int)(mb_inputdata[mbaddress+i]& 0X00ff);
	MOVW R26,R28
	ADIW R26,12
	ADD  R30,R26
	ADC  R31,R27
	MOVW R0,R30
	LDD  R30,Y+10
	LDD  R31,Y+10+1
	ADD  R30,R16
	ADC  R31,R17
	LDI  R26,LOW(_mb_inputdata)
	LDI  R27,HIGH(_mb_inputdata)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	LD   R30,X
	MOVW R26,R0
	ST   X,R30
; 0000 0397                         j++;
	LDD  R30,Y+8
	LDD  R31,Y+8+1
	ADIW R30,1
	STD  Y+8,R30
	STD  Y+8+1,R31
; 0000 0398                         }
	LDD  R30,Y+10
	LDD  R31,Y+10+1
	ADIW R30,1
	STD  Y+10,R30
	STD  Y+10+1,R31
	RJMP _0xC9
_0xCA:
; 0000 0399                     i= CRC16(mbtransmit_data,(mbamount*2)+3);
	MOVW R30,R28
	ADIW R30,12
	ST   -Y,R31
	ST   -Y,R30
	MOVW R30,R18
	LSL  R30
	ROL  R31
	ADIW R30,3
	MOVW R26,R30
	RCALL _CRC16
	STD  Y+10,R30
	STD  Y+10+1,R31
; 0000 039A                     mbtransmit_data[j] = i%256;
	LDD  R30,Y+8
	LDD  R31,Y+8+1
	MOVW R26,R28
	ADIW R26,12
	ADD  R26,R30
	ADC  R27,R31
	LDD  R30,Y+10
	ST   X,R30
; 0000 039B                     mbtransmit_data[j+1]=i/256;
	LDD  R30,Y+8
	LDD  R31,Y+8+1
	ADIW R30,1
	MOVW R26,R28
	ADIW R26,12
	ADD  R26,R30
	ADC  R27,R31
	LDD  R30,Y+11
	ST   X,R30
; 0000 039C                     #asm("cli")
	cli
; 0000 039D 
; 0000 039E //                    mb_dir =0;//set to transmit data
; 0000 039F                     for (i=0;i<mbtransmit_data[2]+4+1;i++)
	LDI  R30,LOW(0)
	STD  Y+10,R30
	STD  Y+10+1,R30
_0xCC:
	LDD  R30,Y+14
	LDI  R31,0
	ADIW R30,5
	LDD  R26,Y+10
	LDD  R27,Y+10+1
	CP   R26,R30
	CPC  R27,R31
	BRSH _0xCD
; 0000 03A0                         {
; 0000 03A1                         putchar(mbtransmit_data[i]);
	LDD  R30,Y+10
	LDD  R31,Y+10+1
	MOVW R26,R28
	ADIW R26,12
	ADD  R26,R30
	ADC  R27,R31
	LD   R26,X
	RCALL _putchar
; 0000 03A2                         }
	LDD  R30,Y+10
	LDD  R31,Y+10+1
	ADIW R30,1
	STD  Y+10,R30
	STD  Y+10+1,R31
	RJMP _0xCC
_0xCD:
; 0000 03A3 
; 0000 03A4 //                     mbreset();
; 0000 03A5                     #asm("sei")
	sei
; 0000 03A6                     delay_ms(50);      //wait till all data transmitted need time to transmit max 36 bytes @9600
	LDI  R26,LOW(50)
	LDI  R27,0
	CALL _delay_ms
; 0000 03A7                     mb_dir =0;   //recieve
	CBI  0x12,2
; 0000 03A8                     mbreset();
	RCALL _mbreset
; 0000 03A9 
; 0000 03AA 
; 0000 03AB 
; 0000 03AC                     break;
	RJMP _0xAB
; 0000 03AD             //Preset Single Register
; 0000 03AE             case 0x06:
_0xBE:
	CPI  R30,LOW(0x6)
	LDI  R26,HIGH(0x6)
	CPC  R31,R26
	BREQ PC+2
	RJMP _0xE1
; 0000 03AF                  mbaddress = mbreceived_data[3];      //start address;
	__GETBRMN 16,_mbreceived_data,3
	CLR  R17
; 0000 03B0                  if (mbaddress+1 > 58)
	MOVW R26,R16
	ADIW R26,1
	SBIW R26,59
	BRLO _0xD1
; 0000 03B1                     {
; 0000 03B2                     error_code = mbillegaldataaddress;
	__GETWRN 20,21,2
; 0000 03B3                     break;
	RJMP _0xAB
; 0000 03B4                     }
; 0000 03B5                  mbamount = (mbreceived_data[4] *256) +mbreceived_data[5];      //requested amount
_0xD1:
	__GETB2MN _mbreceived_data,4
	LDI  R27,0
	LDI  R30,LOW(256)
	LDI  R31,HIGH(256)
	CALL __MULW12
	MOVW R26,R30
	__GETB1MN _mbreceived_data,5
	LDI  R31,0
	ADD  R30,R26
	ADC  R31,R27
	MOVW R18,R30
; 0000 03B6 
; 0000 03B7                  if (mbamount < -1999 || mbamount >9999)
	__CPWRN 18,19,-1999
	BRLT _0xD3
	__CPWRN 18,19,10000
	BRLT _0xD2
_0xD3:
; 0000 03B8                     {
; 0000 03B9                     error_code = mbillegaldatavalue;         //requested data overflow
	__GETWRN 20,21,3
; 0000 03BA                     break;
	RJMP _0xAB
; 0000 03BB                     }
; 0000 03BC                  else
_0xD2:
; 0000 03BD                     {
; 0000 03BE                     k = mblimitcheck(mbaddress,mbamount);
	ST   -Y,R17
	ST   -Y,R16
	MOVW R26,R18
	RCALL _mblimitcheck
	STD  Y+6,R30
	STD  Y+6+1,R31
; 0000 03BF                     if (k == 1)
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	SBIW R26,1
	BRNE _0xD6
; 0000 03C0                     {
; 0000 03C1                     error_code = 7;//mbillegaldatavalue;       //write not done. invalid value
	__GETWRN 20,21,7
; 0000 03C2                     break;
	RJMP _0xAB
; 0000 03C3                     }
; 0000 03C4                     }
_0xD6:
; 0000 03C5                     i = CRC16(rx_buffer,6);
	LDI  R30,LOW(_rx_buffer)
	LDI  R31,HIGH(_rx_buffer)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(6)
	LDI  R27,0
	CALL _CRC16
	STD  Y+10,R30
	STD  Y+10+1,R31
; 0000 03C6 
; 0000 03C7                  if((rx_buffer[6] != i%256) || (rx_buffer[7] != i/256)  )
	__GETB2MN _rx_buffer,6
	ANDI R31,HIGH(0xFF)
	LDI  R27,0
	CP   R30,R26
	CPC  R31,R27
	BRNE _0xD8
	__GETB2MN _rx_buffer,7
	LDD  R30,Y+11
	ANDI R31,HIGH(0x0)
	LDI  R27,0
	CP   R30,R26
	CPC  R31,R27
	BREQ _0xD7
_0xD8:
; 0000 03C8                     {
; 0000 03C9                     error_code = mbillegaldatavalue;      //CRC not matching
	__GETWRN 20,21,3
; 0000 03CA                     break;
	RJMP _0xAB
; 0000 03CB                     }
; 0000 03CC                   //valid request so form mb frame  echo accordingly
; 0000 03CD                   error_code =0;       //
_0xD7:
	__GETWRN 20,21,0
; 0000 03CE                   mb_dir =1;      //transmit
	SBI  0x12,2
; 0000 03CF                   mbtransmit_data[0] = mbreceived_data[0];      //slave id
	LDS  R30,_mbreceived_data
	STD  Y+12,R30
; 0000 03D0                   mbtransmit_data[1] = mbreceived_data[1];       //function code
	__GETB1MN _mbreceived_data,1
	STD  Y+13,R30
; 0000 03D1                   mbtransmit_data[2] = mbreceived_data[2];      //slave id
	__GETB1MN _mbreceived_data,2
	STD  Y+14,R30
; 0000 03D2                   mbtransmit_data[3] = mbreceived_data[3];       //function code
	__GETB1MN _mbreceived_data,3
	STD  Y+15,R30
; 0000 03D3                   mbtransmit_data[4] = mbreceived_data[4];      //slave id
	__GETB1MN _mbreceived_data,4
	STD  Y+16,R30
; 0000 03D4                   mbtransmit_data[5] = mbreceived_data[5];       //function code
	__GETB1MN _mbreceived_data,5
	STD  Y+17,R30
; 0000 03D5                   mbtransmit_data[6] = mbreceived_data[6];      //slave id
	__GETB1MN _mbreceived_data,6
	STD  Y+18,R30
; 0000 03D6                   mbtransmit_data[7] = mbreceived_data[7];       //function code
	__GETB1MN _mbreceived_data,7
	STD  Y+19,R30
; 0000 03D7 
; 0000 03D8                     delay_ms(2);
	LDI  R26,LOW(2)
	LDI  R27,0
	CALL _delay_ms
; 0000 03D9 
; 0000 03DA                     #asm("cli")
	cli
; 0000 03DB 
; 0000 03DC //                    mb_dir =0;//set to transmit data
; 0000 03DD                     for (i=0;i<8;i++)
	LDI  R30,LOW(0)
	STD  Y+10,R30
	STD  Y+10+1,R30
_0xDD:
	LDD  R26,Y+10
	LDD  R27,Y+10+1
	SBIW R26,8
	BRSH _0xDE
; 0000 03DE                         {
; 0000 03DF                         putchar(mbtransmit_data[i]);
	LDD  R30,Y+10
	LDD  R31,Y+10+1
	MOVW R26,R28
	ADIW R26,12
	ADD  R26,R30
	ADC  R27,R31
	LD   R26,X
	CALL _putchar
; 0000 03E0                         }
	LDD  R30,Y+10
	LDD  R31,Y+10+1
	ADIW R30,1
	STD  Y+10,R30
	STD  Y+10+1,R31
	RJMP _0xDD
_0xDE:
; 0000 03E1 
; 0000 03E2 //                     mbreset();
; 0000 03E3                     #asm("sei")
	sei
; 0000 03E4                     delay_ms(50);      //wait till all data transmitted need time to transmit max 36 bytes @9600
	LDI  R26,LOW(50)
	LDI  R27,0
	CALL _delay_ms
; 0000 03E5                     mb_dir =0;   //recieve
	CBI  0x12,2
; 0000 03E6                     mbreset();
	CALL _mbreset
; 0000 03E7                     break;
	RJMP _0xAB
; 0000 03E8             default: error_code = mbillegalfunction;
_0xE1:
	__GETWRN 20,21,1
; 0000 03E9 //                    mbreset();
; 0000 03EA                     break;
; 0000 03EB 
; 0000 03EC             }
_0xAB:
; 0000 03ED //        error handling;
; 0000 03EE         if (error_code !=0)
	MOV  R0,R20
	OR   R0,R21
	BREQ _0xE2
; 0000 03EF             {
; 0000 03F0             //todo : error handling code here
; 0000 03F1                 mb_dir =1;
	SBI  0x12,2
; 0000 03F2                 mbtransmit_data[0] = mbreceived_data[0];    //slave id
	LDS  R30,_mbreceived_data
	STD  Y+12,R30
; 0000 03F3                 mbtransmit_data[1] = mbreceived_data[1] | 0x80;     //set highest bit to indicate exception
	__GETB1MN _mbreceived_data,1
	ORI  R30,0x80
	STD  Y+13,R30
; 0000 03F4                 mbtransmit_data[2] = error_code;        //error code
	MOVW R30,R28
	ADIW R30,14
	ST   Z,R20
; 0000 03F5                     i= CRC16(mbtransmit_data,3);    // CRC
	MOVW R30,R28
	ADIW R30,12
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(3)
	LDI  R27,0
	CALL _CRC16
	STD  Y+10,R30
	STD  Y+10+1,R31
; 0000 03F6                     mbtransmit_data[3] = i%256;
	LDD  R30,Y+10
	STD  Y+15,R30
; 0000 03F7                     mbtransmit_data[4]=i/256;
	LDD  R30,Y+11
	STD  Y+16,R30
; 0000 03F8                     #asm("cli")
	cli
; 0000 03F9 
; 0000 03FA //                    mb_dir =0;//set to transmit data
; 0000 03FB                     for (i=0;i<5;i++)
	LDI  R30,LOW(0)
	STD  Y+10,R30
	STD  Y+10+1,R30
_0xE6:
	LDD  R26,Y+10
	LDD  R27,Y+10+1
	SBIW R26,5
	BRSH _0xE7
; 0000 03FC                         {
; 0000 03FD                         putchar(mbtransmit_data[i]);
	LDD  R30,Y+10
	LDD  R31,Y+10+1
	MOVW R26,R28
	ADIW R26,12
	ADD  R26,R30
	ADC  R27,R31
	LD   R26,X
	CALL _putchar
; 0000 03FE                         }
	LDD  R30,Y+10
	LDD  R31,Y+10+1
	ADIW R30,1
	STD  Y+10,R30
	STD  Y+10+1,R31
	RJMP _0xE6
_0xE7:
; 0000 03FF 
; 0000 0400 //                     mbreset();
; 0000 0401                     #asm("sei")
	sei
; 0000 0402                     delay_ms(50);      //wait till all data transmitted need time to transmit max 36 bytes @9600
	LDI  R26,LOW(50)
	LDI  R27,0
	CALL _delay_ms
; 0000 0403                     mb_dir =0;   //recieve
	CBI  0x12,2
; 0000 0404                     mbreset();
	CALL _mbreset
; 0000 0405 
; 0000 0406 
; 0000 0407             }
; 0000 0408 
; 0000 0409 
; 0000 040A 
; 0000 040B }
_0xE2:
	CALL __LOADLOCR6
	ADIW R28,52
	RET
; .FEND
;
;
;
;
;
;
;
;
;
;
;
;
;////////////////////////////////////////////////////////////
;
;
;
;
;
;
;void set_fixed_values(void)
; 0000 0420 {
_set_fixed_values:
; .FSTART _set_fixed_values
; 0000 0421 int i;
; 0000 0422 for (i=0;i<=7;i++)
	ST   -Y,R17
	ST   -Y,R16
;	i -> R16,R17
	__GETWRN 16,17,0
_0xEB:
	__CPWRN 16,17,8
	BRGE _0xEC
; 0000 0423     {
; 0000 0424     rlow[i] = -200;
	MOVW R30,R16
	LDI  R26,LOW(_rlow)
	LDI  R27,HIGH(_rlow)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	LDI  R30,LOW(65336)
	LDI  R31,HIGH(65336)
	ST   X+,R30
	ST   X,R31
; 0000 0425     rhigh[i] =300;
	MOVW R30,R16
	LDI  R26,LOW(_rhigh)
	LDI  R27,HIGH(_rhigh)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	LDI  R30,LOW(300)
	LDI  R31,HIGH(300)
	ST   X+,R30
	ST   X,R31
; 0000 0426     dp[i] =3;
	MOVW R30,R16
	LDI  R26,LOW(_dp)
	LDI  R27,HIGH(_dp)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	LDI  R30,LOW(3)
	LDI  R31,HIGH(3)
	ST   X+,R30
	ST   X,R31
; 0000 0427     input[i] = 6;
	MOVW R30,R16
	LDI  R26,LOW(_input)
	LDI  R27,HIGH(_input)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	LDI  R30,LOW(6)
	LDI  R31,HIGH(6)
	ST   X+,R30
	ST   X,R31
; 0000 0428     }
	__ADDWRN 16,17,1
	RJMP _0xEB
_0xEC:
; 0000 0429 
; 0000 042A 
; 0000 042B }
	LD   R16,Y+
	LD   R17,Y+
	RET
; .FEND
;
;
;
; void adc3421_init(void)
; 0000 0430 {
_adc3421_init:
; .FSTART _adc3421_init
; 0000 0431 i2c_start();
	CALL _i2c_start
; 0000 0432 i2c_write(0xd2);
	LDI  R26,LOW(210)
	CALL _i2c_write
; 0000 0433 delay_ms(1);
	LDI  R26,LOW(1)
	LDI  R27,0
	CALL _delay_ms
; 0000 0434 //i2c_write(0x9f);   //18 bit mode 8v/v
; 0000 0435 i2c_write(0x98);        //16 bit 1v/v
	LDI  R26,LOW(152)
	CALL _i2c_write
; 0000 0436 i2c_stop();
	CALL _i2c_stop
; 0000 0437 }
	RET
; .FEND
;
;/*
;long int adc3421_read18(void)
;{
; unsigned int buffer1;
; unsigned int buffer2,buffer3;
; long int buffer4;
; i2c_start();
; buffer1 = i2c_write(0xd3);
; buffer1 = i2c_read(1);
; buffer2 = i2c_read(1);
; buffer3 = i2c_read(0);
; i2c_stop();
; buffer1 = buffer1 & 0x01;
; buffer4 = (long) (buffer1) * 65536 ;
; buffer4 = buffer4 + ((long)(buffer2) * 256);
; buffer4 = buffer4 + (long)(buffer3);
; return(buffer4);
;}
;*/
;
;int adc3421_read(void)
; 0000 044E {
_adc3421_read:
; .FSTART _adc3421_read
; 0000 044F  unsigned int buffer1;
; 0000 0450  unsigned int buffer2;
; 0000 0451 signed int buffer4;
; 0000 0452  i2c_start();
	CALL __SAVELOCR6
;	buffer1 -> R16,R17
;	buffer2 -> R18,R19
;	buffer4 -> R20,R21
	CALL _i2c_start
; 0000 0453  buffer1 = i2c_write(0xd3);
	LDI  R26,LOW(211)
	CALL _i2c_write
	MOV  R16,R30
	CLR  R17
; 0000 0454  buffer1 = i2c_read(1);
	LDI  R26,LOW(1)
	CALL _i2c_read
	MOV  R16,R30
	CLR  R17
; 0000 0455  buffer2 = i2c_read(0);
	LDI  R26,LOW(0)
	CALL _i2c_read
	MOV  R18,R30
	CLR  R19
; 0000 0456  i2c_stop();
	CALL _i2c_stop
; 0000 0457  //buffer1 = buffer1 & 0x7f;      //ignore sign bit
; 0000 0458  //buffer4 = (long)(buffer1) * 256);
; 0000 0459  //buffer4 = buffer4 + (long)(buffer2);
; 0000 045A  buffer4 = (buffer1 *256) + buffer2;
	MOV  R31,R16
	LDI  R30,LOW(0)
	ADD  R30,R18
	ADC  R31,R19
	MOVW R20,R30
; 0000 045B //if (buffer4<0) buffer4 = -buffer4;
; 0000 045C  return(buffer4);
	CALL __LOADLOCR6
	ADIW R28,6
	RET
; 0000 045D }
; .FEND
;
;
;int linearise_p(float a,float zero_tc,float span_tc)
; 0000 0461 {
_linearise_p:
; .FSTART _linearise_p
; 0000 0462 int number =0;
; 0000 0463 int count;
; 0000 0464 int b=0;
; 0000 0465 long int temp=0;
; 0000 0466 float temp1=0;
; 0000 0467 int true_value = 0;
; 0000 0468 
; 0000 0469 
; 0000 046A 
; 0000 046B temp1 = ((a - zero_tc) /(span_tc - zero_tc)) * 11075;    //adc value of 300 deg. is 11075 in table_p
	CALL __PUTPARD2
	SBIW R28,10
	LDI  R24,10
	LDI  R26,LOW(0)
	LDI  R27,HIGH(0)
	LDI  R30,LOW(_0xED*2)
	LDI  R31,HIGH(_0xED*2)
	CALL __INITLOCB
	CALL __SAVELOCR6
;	a -> Y+24
;	zero_tc -> Y+20
;	span_tc -> Y+16
;	number -> R16,R17
;	count -> R18,R19
;	b -> R20,R21
;	temp -> Y+12
;	temp1 -> Y+8
;	true_value -> Y+6
	__GETWRN 16,17,0
	__GETWRN 20,21,0
	__GETD2S 20
	__GETD1S 24
	CALL __SUBF12
	PUSH R23
	PUSH R22
	PUSH R31
	PUSH R30
	__GETD2S 20
	__GETD1S 16
	CALL __SUBF12
	POP  R26
	POP  R27
	POP  R24
	POP  R25
	CALL __DIVF21
	__GETD2N 0x462D0C00
	CALL __MULF12
	__PUTD1S 8
; 0000 046C b = (int)temp1;
	CALL __CFD1
	MOVW R20,R30
; 0000 046D //if (b<0)
; 0000 046E //{
; 0000 046F //b = -b;
; 0000 0470 //nfl =1;
; 0000 0471 //}
; 0000 0472 //else
; 0000 0473 //{
; 0000 0474 //nfl =0;
; 0000 0475 //}
; 0000 0476 for (count=0;count <= 17; count++)
	__GETWRN 18,19,0
_0xEF:
	__CPWRN 18,19,18
	BRGE _0xF0
; 0000 0477     {
; 0000 0478     if (b>table_p[count] && b <= table_p[count+1])
	MOVW R30,R18
	LDI  R26,LOW(_table_p)
	LDI  R27,HIGH(_table_p)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	CP   R30,R20
	CPC  R31,R21
	BRGE _0xF2
	MOVW R26,R18
	LSL  R26
	ROL  R27
	__ADDW2MN _table_p,2
	CALL __GETW1P
	CP   R30,R20
	CPC  R31,R21
	BRGE _0xF3
_0xF2:
	RJMP _0xF1
_0xF3:
; 0000 0479         {
; 0000 047A         number = count;
	MOVW R16,R18
; 0000 047B         break;
	RJMP _0xF0
; 0000 047C         }
; 0000 047D     }
_0xF1:
	__ADDWRN 18,19,1
	RJMP _0xEF
_0xF0:
; 0000 047E 
; 0000 047F temp = ((500*(temp1-(float)table_p[number]))/((float)table_p[number+1] - (float)table_p[number]))+ ((long)(number-4) * 5 ...
	MOVW R30,R16
	LDI  R26,LOW(_table_p)
	LDI  R27,HIGH(_table_p)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	CALL __CWD1
	CALL __CDF1
	__GETD2S 8
	CALL __SWAPD12
	CALL __SUBF12
	__GETD2N 0x43FA0000
	CALL __MULF12
	PUSH R23
	PUSH R22
	PUSH R31
	PUSH R30
	MOVW R26,R16
	LSL  R26
	ROL  R27
	__ADDW2MN _table_p,2
	CALL __GETW1P
	CALL __CWD1
	CALL __CDF1
	PUSH R23
	PUSH R22
	PUSH R31
	PUSH R30
	MOVW R30,R16
	LDI  R26,LOW(_table_p)
	LDI  R27,HIGH(_table_p)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	CALL __CWD1
	CALL __CDF1
	POP  R26
	POP  R27
	POP  R24
	POP  R25
	CALL __SWAPD12
	CALL __SUBF12
	POP  R26
	POP  R27
	POP  R24
	POP  R25
	CALL __DIVF21
	PUSH R23
	PUSH R22
	PUSH R31
	PUSH R30
	MOVW R30,R16
	SBIW R30,4
	CALL __CWD1
	__GETD2N 0x1F4
	RJMP _0x2060004
; 0000 0480 true_value = (int) temp;
; 0000 0481 //if (nfl) true_value = -true_value;
; 0000 0482 return (true_value);
; 0000 0483 }
; .FEND
;int linearise_t(float a,float zero_tc,float span_tc)
; 0000 0485 {
_linearise_t:
; .FSTART _linearise_t
; 0000 0486 int number =0;
; 0000 0487 int count;
; 0000 0488 int b=0;
; 0000 0489 long int temp=0;
; 0000 048A float temp1=0;
; 0000 048B int true_value = 0;
; 0000 048C 
; 0000 048D 
; 0000 048E 
; 0000 048F temp1 = ((a - zero_tc)*5000 /(span_tc - zero_tc));    //adc value of 300 deg. is 11075 in table_p
	CALL __PUTPARD2
	SBIW R28,10
	LDI  R24,10
	LDI  R26,LOW(0)
	LDI  R27,HIGH(0)
	LDI  R30,LOW(_0xF4*2)
	LDI  R31,HIGH(_0xF4*2)
	CALL __INITLOCB
	CALL __SAVELOCR6
;	a -> Y+24
;	zero_tc -> Y+20
;	span_tc -> Y+16
;	number -> R16,R17
;	count -> R18,R19
;	b -> R20,R21
;	temp -> Y+12
;	temp1 -> Y+8
;	true_value -> Y+6
	__GETWRN 16,17,0
	__GETWRN 20,21,0
	__GETD2S 20
	__GETD1S 24
	CALL __SUBF12
	__GETD2N 0x459C4000
	CALL __MULF12
	PUSH R23
	PUSH R22
	PUSH R31
	PUSH R30
	__GETD2S 20
	__GETD1S 16
	CALL __SUBF12
	POP  R26
	POP  R27
	POP  R24
	POP  R25
	CALL __DIVF21
	__PUTD1S 8
; 0000 0490 //added to add ambient value in table value
; 0000 0491 temp1 = temp1 + (table_t[5] * (long)ambient_val /50);
	__GETW2MN _table_t,10
	MOVW R30,R12
	CALL __CWD1
	CALL __CWD2
	CALL __MULD12
	MOVW R26,R30
	MOVW R24,R22
	__GETD1N 0x32
	CALL __DIVD21
	__GETD2S 8
	CALL __CDF1
	CALL __ADDF12
	__PUTD1S 8
; 0000 0492 b = (int)temp1;
	CALL __CFD1
	MOVW R20,R30
; 0000 0493 //if (b<0)
; 0000 0494 //{
; 0000 0495 //b = -b;
; 0000 0496 //nfl =1;
; 0000 0497 //}
; 0000 0498 //else
; 0000 0499 //{
; 0000 049A //nfl =0;
; 0000 049B //}
; 0000 049C for (count=0;count <= 12; count++)
	__GETWRN 18,19,0
_0xF6:
	__CPWRN 18,19,13
	BRGE _0xF7
; 0000 049D     {
; 0000 049E     if (b>table_t[count] && b <= table_t[count+1])
	MOVW R30,R18
	LDI  R26,LOW(_table_t)
	LDI  R27,HIGH(_table_t)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	CP   R30,R20
	CPC  R31,R21
	BRGE _0xF9
	MOVW R26,R18
	LSL  R26
	ROL  R27
	__ADDW2MN _table_t,2
	CALL __GETW1P
	CP   R30,R20
	CPC  R31,R21
	BRGE _0xFA
_0xF9:
	RJMP _0xF8
_0xFA:
; 0000 049F         {
; 0000 04A0         number = count;
	MOVW R16,R18
; 0000 04A1         break;
	RJMP _0xF7
; 0000 04A2         }
; 0000 04A3     }
_0xF8:
	__ADDWRN 18,19,1
	RJMP _0xF6
_0xF7:
; 0000 04A4 
; 0000 04A5 temp = ((50*(temp1-(float)table_t[number]))/((float)table_t[number+1] - (float)table_t[number]))+ ((long)(number-4) * 50 ...
	MOVW R30,R16
	LDI  R26,LOW(_table_t)
	LDI  R27,HIGH(_table_t)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	CALL __CWD1
	CALL __CDF1
	__GETD2S 8
	CALL __SWAPD12
	CALL __SUBF12
	__GETD2N 0x42480000
	CALL __MULF12
	PUSH R23
	PUSH R22
	PUSH R31
	PUSH R30
	MOVW R26,R16
	LSL  R26
	ROL  R27
	__ADDW2MN _table_t,2
	CALL __GETW1P
	CALL __CWD1
	CALL __CDF1
	PUSH R23
	PUSH R22
	PUSH R31
	PUSH R30
	MOVW R30,R16
	LDI  R26,LOW(_table_t)
	LDI  R27,HIGH(_table_t)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	CALL __CWD1
	CALL __CDF1
	POP  R26
	POP  R27
	POP  R24
	POP  R25
	CALL __SWAPD12
	CALL __SUBF12
	POP  R26
	POP  R27
	POP  R24
	POP  R25
	CALL __DIVF21
	PUSH R23
	PUSH R22
	PUSH R31
	PUSH R30
	MOVW R30,R16
	SBIW R30,4
	CALL __CWD1
	__GETD2N 0x32
_0x2060004:
	CALL __MULD12
	POP  R26
	POP  R27
	POP  R24
	POP  R25
	CALL __CDF1
	CALL __ADDF12
	MOVW R26,R28
	ADIW R26,12
	CALL __CFD1
	CALL __PUTDP1
; 0000 04A6 true_value = (int) temp;
	LDD  R30,Y+12
	LDD  R31,Y+12+1
	STD  Y+6,R30
	STD  Y+6+1,R31
; 0000 04A7 //if (nfl) true_value = -true_value;
; 0000 04A8 return (true_value);
	CALL __LOADLOCR6
	ADIW R28,28
	RET
; 0000 04A9 }
; .FEND
;
;
;int linearise_tc(float a,float zero_tc,float span_tc,int iter,unsigned int* tabletc,long int factor)
; 0000 04AD {
_linearise_tc:
; .FSTART _linearise_tc
	PUSH R15
; 0000 04AE int number =0;
; 0000 04AF int count;
; 0000 04B0 int b=0;
; 0000 04B1 long int temp=0;
; 0000 04B2 float temp1=0;
; 0000 04B3 int true_value = 0;
; 0000 04B4 bit nfl;
; 0000 04B5 
; 0000 04B6 temp1 = ((a - zero_tc)*factor /(span_tc - zero_tc));    //adc value of 300 deg. is 11075 in table_p
	CALL __PUTPARD2
	SBIW R28,10
	LDI  R24,10
	LDI  R26,LOW(0)
	LDI  R27,HIGH(0)
	LDI  R30,LOW(_0xFB*2)
	LDI  R31,HIGH(_0xFB*2)
	CALL __INITLOCB
	CALL __SAVELOCR6
;	a -> Y+32
;	zero_tc -> Y+28
;	span_tc -> Y+24
;	iter -> Y+22
;	*tabletc -> Y+20
;	factor -> Y+16
;	number -> R16,R17
;	count -> R18,R19
;	b -> R20,R21
;	temp -> Y+12
;	temp1 -> Y+8
;	true_value -> Y+6
;	nfl -> R15.0
	__GETWRN 16,17,0
	__GETWRN 20,21,0
	__GETD2S 28
	__GETD1S 32
	CALL __SUBF12
	MOVW R26,R30
	MOVW R24,R22
	__GETD1S 16
	CALL __CDF1
	CALL __MULF12
	PUSH R23
	PUSH R22
	PUSH R31
	PUSH R30
	__GETD2S 28
	__GETD1S 24
	CALL __SUBF12
	POP  R26
	POP  R27
	POP  R24
	POP  R25
	CALL __DIVF21
	__PUTD1S 8
; 0000 04B7 //added to add ambient value in table value
; 0000 04B8 temp1 = temp1 + (*(tabletc+1) * (long)ambient_val /50);
	LDD  R30,Y+20
	LDD  R31,Y+20+1
	LDD  R26,Z+2
	LDD  R27,Z+3
	MOVW R30,R12
	CALL __CWD1
	CLR  R24
	CLR  R25
	CALL __MULD12
	MOVW R26,R30
	MOVW R24,R22
	__GETD1N 0x32
	CALL __DIVD21
	__GETD2S 8
	CALL __CDF1
	CALL __ADDF12
	__PUTD1S 8
; 0000 04B9 
; 0000 04BA 
; 0000 04BB 
; 0000 04BC b = (unsigned int)temp1;
	CALL __CFD1U
	MOVW R20,R30
; 0000 04BD 
; 0000 04BE if (b<0)
	TST  R21
	BRPL _0xFC
; 0000 04BF {
; 0000 04C0 b = -b;
	CALL __ANEGW1
	MOVW R20,R30
; 0000 04C1 nfl =1;
	SET
	RJMP _0x337
; 0000 04C2 }
; 0000 04C3 else
_0xFC:
; 0000 04C4 {
; 0000 04C5 nfl =0;
	CLT
_0x337:
	BLD  R15,0
; 0000 04C6 }
; 0000 04C7 for (count=0;count <= iter; count++)
	__GETWRN 18,19,0
_0xFF:
	LDD  R30,Y+22
	LDD  R31,Y+22+1
	CP   R30,R18
	CPC  R31,R19
	BRLT _0x100
; 0000 04C8     {
; 0000 04C9     if (b> *(tabletc+count) && b <= *(tabletc+count+1))
	MOVW R30,R18
	LDD  R26,Y+20
	LDD  R27,Y+20+1
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	CP   R30,R20
	CPC  R31,R21
	BRSH _0x102
	MOVW R30,R18
	LDD  R26,Y+20
	LDD  R27,Y+20+1
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	ADIW R26,2
	CALL __GETW1P
	CP   R30,R20
	CPC  R31,R21
	BRSH _0x103
_0x102:
	RJMP _0x101
_0x103:
; 0000 04CA         {
; 0000 04CB         number = count;
	MOVW R16,R18
; 0000 04CC         break;
	RJMP _0x100
; 0000 04CD         }
; 0000 04CE     }
_0x101:
	__ADDWRN 18,19,1
	RJMP _0xFF
_0x100:
; 0000 04CF 
; 0000 04D0 temp = (50 * (temp1 - *(tabletc+number))/( *(tabletc+number+1) - *(tabletc+number))) + ((long)number*50) ;
	MOVW R30,R16
	LDD  R26,Y+20
	LDD  R27,Y+20+1
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	__GETD2S 8
	CLR  R22
	CLR  R23
	CALL __CDF1
	CALL __SWAPD12
	CALL __SUBF12
	__GETD2N 0x42480000
	CALL __MULF12
	PUSH R23
	PUSH R22
	PUSH R31
	PUSH R30
	MOVW R30,R16
	LDD  R26,Y+20
	LDD  R27,Y+20+1
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	ADIW R26,2
	LD   R0,X+
	LD   R1,X
	MOVW R30,R16
	LDD  R26,Y+20
	LDD  R27,Y+20+1
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	MOVW R26,R30
	MOVW R30,R0
	SUB  R30,R26
	SBC  R31,R27
	POP  R26
	POP  R27
	POP  R24
	POP  R25
	CLR  R22
	CLR  R23
	CALL __CDF1
	CALL __DIVF21
	PUSH R23
	PUSH R22
	PUSH R31
	PUSH R30
	MOVW R26,R16
	CALL __CWD2
	__GETD1N 0x32
	CALL __MULD12
	POP  R26
	POP  R27
	POP  R24
	POP  R25
	CALL __CDF1
	CALL __ADDF12
	MOVW R26,R28
	ADIW R26,12
	CALL __CFD1
	CALL __PUTDP1
; 0000 04D1 
; 0000 04D2 
; 0000 04D3 //temp = ((500*(temp1-(float)table_p[number]))/((float)table_p[number+1] - (float)table_p[number]))+ ((long)(number-4) * ...
; 0000 04D4 true_value = (int) temp;
	LDD  R30,Y+12
	LDD  R31,Y+12+1
	STD  Y+6,R30
	STD  Y+6+1,R31
; 0000 04D5 if (nfl) true_value = -true_value;
	SBRS R15,0
	RJMP _0x104
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	CALL __ANEGW1
	STD  Y+6,R30
	STD  Y+6+1,R31
; 0000 04D6 
; 0000 04D7 return (true_value);
_0x104:
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	CALL __LOADLOCR6
	ADIW R28,36
	POP  R15
	RET
; 0000 04D8 }
; .FEND
;
;int linearise_volt(float a,float zero_tc, float span_tc,float rangehigh,float rangelow)
; 0000 04DB {
_linearise_volt:
; .FSTART _linearise_volt
; 0000 04DC float b,c,result;
; 0000 04DD 
; 0000 04DE b= (a - zero_tc)*20000/(span_tc-zero_tc);     //scale to 0~20000
	CALL __PUTPARD2
	SBIW R28,12
;	a -> Y+28
;	zero_tc -> Y+24
;	span_tc -> Y+20
;	rangehigh -> Y+16
;	rangelow -> Y+12
;	b -> Y+8
;	c -> Y+4
;	result -> Y+0
	__GETD2S 24
	__GETD1S 28
	CALL __SUBF12
	__GETD2N 0x469C4000
	CALL __MULF12
	PUSH R23
	PUSH R22
	PUSH R31
	PUSH R30
	__GETD2S 24
	RJMP _0x2060003
; 0000 04DF c= rangehigh - rangelow;
; 0000 04E0 result = (b * c /20000)+rangelow;
; 0000 04E1 return (result);
; 0000 04E2 }
; .FEND
;
;int linearise_420(float a,float zero_tc, float span_tc,float rangehigh,float rangelow)
; 0000 04E5 {
_linearise_420:
; .FSTART _linearise_420
; 0000 04E6 float b,c,result;
; 0000 04E7 c = ((span_tc - zero_tc)/5) +zero_tc;   //scale offset to offset + 4ma adc
	CALL __PUTPARD2
	SBIW R28,12
;	a -> Y+28
;	zero_tc -> Y+24
;	span_tc -> Y+20
;	rangehigh -> Y+16
;	rangelow -> Y+12
;	b -> Y+8
;	c -> Y+4
;	result -> Y+0
	__GETD2S 24
	__GETD1S 20
	CALL __SUBF12
	MOVW R26,R30
	MOVW R24,R22
	__GETD1N 0x40A00000
	CALL __DIVF21
	__GETD2S 24
	CALL __ADDF12
	__PUTD1S 4
; 0000 04E8 b= (a - c)*20000/(span_tc-c);     //scale to 0~20000
	__GETD2S 4
	__GETD1S 28
	CALL __SUBF12
	__GETD2N 0x469C4000
	CALL __MULF12
	PUSH R23
	PUSH R22
	PUSH R31
	PUSH R30
	__GETD2S 4
_0x2060003:
	__GETD1S 20
	CALL __SUBF12
	POP  R26
	POP  R27
	POP  R24
	POP  R25
	CALL __DIVF21
	__PUTD1S 8
; 0000 04E9 c= rangehigh - rangelow;
	__GETD2S 12
	__GETD1S 16
	CALL __SUBF12
	__PUTD1S 4
; 0000 04EA result = (b * c /20000)+rangelow;
	__GETD2S 8
	CALL __MULF12
	MOVW R26,R30
	MOVW R24,R22
	__GETD1N 0x469C4000
	CALL __DIVF21
	__GETD2S 12
	CALL __ADDF12
	CALL __PUTD1S0
; 0000 04EB return (result);
	LD   R30,Y
	LDD  R31,Y+1
	CALL __CFD1
	ADIW R28,32
	RET
; 0000 04EC }
; .FEND
;
;
;void increment_value(int* value,int low_limit,int high_limit,short int power)
; 0000 04F0 {
_increment_value:
; .FSTART _increment_value
; 0000 04F1 int a;
; 0000 04F2 int b=1;
; 0000 04F3 for (a=0;a<power;a++) b = b*10;
	ST   -Y,R27
	ST   -Y,R26
	CALL __SAVELOCR4
;	*value -> Y+10
;	low_limit -> Y+8
;	high_limit -> Y+6
;	power -> Y+4
;	a -> R16,R17
;	b -> R18,R19
	__GETWRN 18,19,1
	__GETWRN 16,17,0
_0x106:
	LDD  R30,Y+4
	LDD  R31,Y+4+1
	CP   R16,R30
	CPC  R17,R31
	BRGE _0x107
	MOVW R30,R18
	LDI  R26,LOW(10)
	LDI  R27,HIGH(10)
	CALL __MULW12
	MOVW R18,R30
	__ADDWRN 16,17,1
	RJMP _0x106
_0x107:
; 0000 04F4 *value = *value + b;
	LDD  R26,Y+10
	LDD  R27,Y+10+1
	CALL __GETW1P
	ADD  R30,R18
	ADC  R31,R19
	ST   X+,R30
	ST   X,R31
; 0000 04F5 if (*value < low_limit) *value = low_limit;
	LDD  R26,Y+10
	LDD  R27,Y+10+1
	CALL __GETW1P
	MOVW R26,R30
	LDD  R30,Y+8
	LDD  R31,Y+8+1
	CP   R26,R30
	CPC  R27,R31
	BRGE _0x108
	LDD  R26,Y+10
	LDD  R27,Y+10+1
	ST   X+,R30
	ST   X,R31
; 0000 04F6 if (*value >= high_limit) *value = high_limit;
_0x108:
	LDD  R26,Y+10
	LDD  R27,Y+10+1
	CALL __GETW1P
	MOVW R26,R30
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	CP   R26,R30
	CPC  R27,R31
	BRLT _0x109
	LDD  R26,Y+10
	LDD  R27,Y+10+1
	ST   X+,R30
	ST   X,R31
; 0000 04F7 }
_0x109:
	RJMP _0x2060002
; .FEND
;
;void decrement_value(int* value,int low_limit,int high_limit,short int power)
; 0000 04FA {
_decrement_value:
; .FSTART _decrement_value
; 0000 04FB int a;
; 0000 04FC int b=1;
; 0000 04FD for (a=0;a<power;a++) b = b*10;
	ST   -Y,R27
	ST   -Y,R26
	CALL __SAVELOCR4
;	*value -> Y+10
;	low_limit -> Y+8
;	high_limit -> Y+6
;	power -> Y+4
;	a -> R16,R17
;	b -> R18,R19
	__GETWRN 18,19,1
	__GETWRN 16,17,0
_0x10B:
	LDD  R30,Y+4
	LDD  R31,Y+4+1
	CP   R16,R30
	CPC  R17,R31
	BRGE _0x10C
	MOVW R30,R18
	LDI  R26,LOW(10)
	LDI  R27,HIGH(10)
	CALL __MULW12
	MOVW R18,R30
	__ADDWRN 16,17,1
	RJMP _0x10B
_0x10C:
; 0000 04FE *value = *value- b;
	LDD  R26,Y+10
	LDD  R27,Y+10+1
	CALL __GETW1P
	SUB  R30,R18
	SBC  R31,R19
	ST   X+,R30
	ST   X,R31
; 0000 04FF if (*value < low_limit) *value = low_limit;
	LDD  R26,Y+10
	LDD  R27,Y+10+1
	CALL __GETW1P
	MOVW R26,R30
	LDD  R30,Y+8
	LDD  R31,Y+8+1
	CP   R26,R30
	CPC  R27,R31
	BRGE _0x10D
	LDD  R26,Y+10
	LDD  R27,Y+10+1
	ST   X+,R30
	ST   X,R31
; 0000 0500 if (*value >= high_limit) *value = high_limit;
_0x10D:
	LDD  R26,Y+10
	LDD  R27,Y+10+1
	CALL __GETW1P
	MOVW R26,R30
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	CP   R26,R30
	CPC  R27,R31
	BRLT _0x10E
	LDD  R26,Y+10
	LDD  R27,Y+10+1
	ST   X+,R30
	ST   X,R31
; 0000 0501 }
_0x10E:
_0x2060002:
	CALL __LOADLOCR4
	ADIW R28,12
	RET
; .FEND
;
;
;void escape_menu(void)
; 0000 0505 {
_escape_menu:
; .FSTART _escape_menu
; 0000 0506 menu_fl =0;
	CLT
	BLD  R3,4
; 0000 0507 level=0;
	LDI  R30,LOW(0)
	STS  _level,R30
	STS  _level+1,R30
; 0000 0508 item1=item2=0;
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	STS  _item2,R30
	STS  _item2+1,R31
	STS  _item1,R30
	STS  _item1+1,R31
; 0000 0509 blinking=0;
	BLD  R2,4
; 0000 050A blink_digit=0;
	STS  _blink_digit,R30
	STS  _blink_digit+1,R30
; 0000 050B blink_flag =0;
	BLD  R2,3
; 0000 050C 
; 0000 050D }
	RET
; .FEND
;
;
;void display_put(int up_display, int low_display,int status,short int* message1,short int* message2)
; 0000 0511 {
_display_put:
; .FSTART _display_put
; 0000 0512 if (status ==0)
	ST   -Y,R27
	ST   -Y,R26
;	up_display -> Y+8
;	low_display -> Y+6
;	status -> Y+4
;	*message1 -> Y+2
;	*message2 -> Y+0
	LDD  R30,Y+4
	LDD  R31,Y+4+1
	SBIW R30,0
	BREQ PC+2
	RJMP _0x10F
; 0000 0513         {
; 0000 0514         if (up_display <0 && up_display > -1000)
	LDD  R26,Y+9
	TST  R26
	BRPL _0x111
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	LDI  R30,LOW(64536)
	LDI  R31,HIGH(64536)
	CP   R30,R26
	CPC  R31,R27
	BRLT _0x112
_0x111:
	RJMP _0x110
_0x112:
; 0000 0515         {
; 0000 0516         up_display = -up_display;
	LDD  R30,Y+8
	LDD  R31,Y+8+1
	CALL __ANEGW1
	STD  Y+8,R30
	STD  Y+8+1,R31
; 0000 0517         up_display%=1000;
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	LDI  R30,LOW(1000)
	LDI  R31,HIGH(1000)
	CALL __MODW21
	STD  Y+8,R30
	STD  Y+8+1,R31
; 0000 0518         display_buffer[0]= 30;
	LDI  R30,LOW(30)
	LDI  R31,HIGH(30)
	STS  _display_buffer,R30
	STS  _display_buffer+1,R31
; 0000 0519         }
; 0000 051A         else if (up_display <=-1000)
	RJMP _0x113
_0x110:
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	LDI  R30,LOW(64536)
	LDI  R31,HIGH(64536)
	CP   R30,R26
	CPC  R31,R27
	BRLT _0x114
; 0000 051B         {
; 0000 051C         up_display = -up_display;
	LDD  R30,Y+8
	LDD  R31,Y+8+1
	CALL __ANEGW1
	STD  Y+8,R30
	STD  Y+8+1,R31
; 0000 051D         up_display%=1000;
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	LDI  R30,LOW(1000)
	LDI  R31,HIGH(1000)
	CALL __MODW21
	STD  Y+8,R30
	STD  Y+8+1,R31
; 0000 051E         display_buffer[0]= 35;
	LDI  R30,LOW(35)
	LDI  R31,HIGH(35)
	STS  _display_buffer,R30
	STS  _display_buffer+1,R31
; 0000 051F 
; 0000 0520         }
; 0000 0521         else
	RJMP _0x115
_0x114:
; 0000 0522         {
; 0000 0523         display_buffer[0]=up_display/1000;
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	LDI  R30,LOW(1000)
	LDI  R31,HIGH(1000)
	CALL __DIVW21
	STS  _display_buffer,R30
	STS  _display_buffer+1,R31
; 0000 0524         up_display%=1000;
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	LDI  R30,LOW(1000)
	LDI  R31,HIGH(1000)
	CALL __MODW21
	STD  Y+8,R30
	STD  Y+8+1,R31
; 0000 0525         }
_0x115:
_0x113:
; 0000 0526         display_buffer[1]=up_display/100;
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	LDI  R30,LOW(100)
	LDI  R31,HIGH(100)
	CALL __DIVW21
	__PUTW1MN _display_buffer,2
; 0000 0527         up_display%=100;
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	LDI  R30,LOW(100)
	LDI  R31,HIGH(100)
	CALL __MODW21
	STD  Y+8,R30
	STD  Y+8+1,R31
; 0000 0528         display_buffer[2]=up_display/10;
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	LDI  R30,LOW(10)
	LDI  R31,HIGH(10)
	CALL __DIVW21
	__PUTW1MN _display_buffer,4
; 0000 0529         up_display%=10;
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	LDI  R30,LOW(10)
	LDI  R31,HIGH(10)
	CALL __MODW21
	STD  Y+8,R30
	STD  Y+8+1,R31
; 0000 052A         display_buffer[3]=up_display;
	__PUTW1MN _display_buffer,6
; 0000 052B 
; 0000 052C         if (low_display <0 && low_display > -1000)
	LDD  R26,Y+7
	TST  R26
	BRPL _0x117
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	LDI  R30,LOW(64536)
	LDI  R31,HIGH(64536)
	CP   R30,R26
	CPC  R31,R27
	BRLT _0x118
_0x117:
	RJMP _0x116
_0x118:
; 0000 052D         {
; 0000 052E         low_display = -low_display;
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	CALL __ANEGW1
	STD  Y+6,R30
	STD  Y+6+1,R31
; 0000 052F         low_display%=1000;
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	LDI  R30,LOW(1000)
	LDI  R31,HIGH(1000)
	CALL __MODW21
	STD  Y+6,R30
	STD  Y+6+1,R31
; 0000 0530         display_buffer[4]= 30;
	__POINTW1MN _display_buffer,8
	LDI  R26,LOW(30)
	LDI  R27,HIGH(30)
	STD  Z+0,R26
	STD  Z+1,R27
; 0000 0531         }
; 0000 0532         else if (low_display <=-1000)
	RJMP _0x119
_0x116:
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	LDI  R30,LOW(64536)
	LDI  R31,HIGH(64536)
	CP   R30,R26
	CPC  R31,R27
	BRLT _0x11A
; 0000 0533         {
; 0000 0534         low_display = -low_display;
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	CALL __ANEGW1
	STD  Y+6,R30
	STD  Y+6+1,R31
; 0000 0535         low_display%=1000;
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	LDI  R30,LOW(1000)
	LDI  R31,HIGH(1000)
	CALL __MODW21
	STD  Y+6,R30
	STD  Y+6+1,R31
; 0000 0536         display_buffer[0]= 35;
	LDI  R30,LOW(35)
	LDI  R31,HIGH(35)
	STS  _display_buffer,R30
	STS  _display_buffer+1,R31
; 0000 0537 
; 0000 0538         }
; 0000 0539         else
	RJMP _0x11B
_0x11A:
; 0000 053A         {
; 0000 053B         display_buffer[4]=low_display/1000;
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	LDI  R30,LOW(1000)
	LDI  R31,HIGH(1000)
	CALL __DIVW21
	__PUTW1MN _display_buffer,8
; 0000 053C         low_display%=1000;
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	LDI  R30,LOW(1000)
	LDI  R31,HIGH(1000)
	CALL __MODW21
	STD  Y+6,R30
	STD  Y+6+1,R31
; 0000 053D         }
_0x11B:
_0x119:
; 0000 053E         display_buffer[5]=low_display/100;
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	LDI  R30,LOW(100)
	LDI  R31,HIGH(100)
	CALL __DIVW21
	__PUTW1MN _display_buffer,10
; 0000 053F         low_display%=100;
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	LDI  R30,LOW(100)
	LDI  R31,HIGH(100)
	CALL __MODW21
	STD  Y+6,R30
	STD  Y+6+1,R31
; 0000 0540         display_buffer[6]=low_display/10;
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	LDI  R30,LOW(10)
	LDI  R31,HIGH(10)
	CALL __DIVW21
	__PUTW1MN _display_buffer,12
; 0000 0541         low_display%=10;
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	LDI  R30,LOW(10)
	LDI  R31,HIGH(10)
	CALL __MODW21
	STD  Y+6,R30
	STD  Y+6+1,R31
; 0000 0542         display_buffer[7]=low_display;
	RJMP _0x338
; 0000 0543         }
; 0000 0544 else if (status ==1)
_0x10F:
	LDD  R26,Y+4
	LDD  R27,Y+4+1
	SBIW R26,1
	BREQ PC+2
	RJMP _0x11D
; 0000 0545         {
; 0000 0546         message1 = message1 + (up_display *4);
	LDD  R30,Y+8
	LDD  R31,Y+8+1
	CALL __LSLW2
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	STD  Y+2,R30
	STD  Y+2+1,R31
; 0000 0547         display_buffer[0]=*message1;
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	CALL __GETW1P
	STS  _display_buffer,R30
	STS  _display_buffer+1,R31
; 0000 0548         message1++;
	LDD  R30,Y+2
	LDD  R31,Y+2+1
	ADIW R30,2
	STD  Y+2,R30
	STD  Y+2+1,R31
; 0000 0549         display_buffer[1]=*message1;
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	CALL __GETW1P
	__PUTW1MN _display_buffer,2
; 0000 054A         message1++;
	LDD  R30,Y+2
	LDD  R31,Y+2+1
	ADIW R30,2
	STD  Y+2,R30
	STD  Y+2+1,R31
; 0000 054B         display_buffer[2]=*message1;
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	CALL __GETW1P
	__PUTW1MN _display_buffer,4
; 0000 054C         message1++;
	LDD  R30,Y+2
	LDD  R31,Y+2+1
	ADIW R30,2
	STD  Y+2,R30
	STD  Y+2+1,R31
; 0000 054D         display_buffer[3]=*message1;
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	CALL __GETW1P
	__PUTW1MN _display_buffer,6
; 0000 054E         if (low_display <0)
	LDD  R26,Y+7
	TST  R26
	BRPL _0x11E
; 0000 054F         {
; 0000 0550         low_display = -low_display;
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	CALL __ANEGW1
	STD  Y+6,R30
	STD  Y+6+1,R31
; 0000 0551         low_display%=1000;
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	LDI  R30,LOW(1000)
	LDI  R31,HIGH(1000)
	CALL __MODW21
	STD  Y+6,R30
	STD  Y+6+1,R31
; 0000 0552         display_buffer[4]= 30;
	__POINTW1MN _display_buffer,8
	LDI  R26,LOW(30)
	LDI  R27,HIGH(30)
	STD  Z+0,R26
	STD  Z+1,R27
; 0000 0553         }
; 0000 0554         else
	RJMP _0x11F
_0x11E:
; 0000 0555         {
; 0000 0556         display_buffer[4]=low_display/1000;
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	LDI  R30,LOW(1000)
	LDI  R31,HIGH(1000)
	CALL __DIVW21
	__PUTW1MN _display_buffer,8
; 0000 0557         low_display%=1000;
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	LDI  R30,LOW(1000)
	LDI  R31,HIGH(1000)
	CALL __MODW21
	STD  Y+6,R30
	STD  Y+6+1,R31
; 0000 0558         }        display_buffer[5]=low_display/100;
_0x11F:
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	LDI  R30,LOW(100)
	LDI  R31,HIGH(100)
	CALL __DIVW21
	__PUTW1MN _display_buffer,10
; 0000 0559         low_display%=100;
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	LDI  R30,LOW(100)
	LDI  R31,HIGH(100)
	CALL __MODW21
	STD  Y+6,R30
	STD  Y+6+1,R31
; 0000 055A         display_buffer[6]=low_display/10;
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	LDI  R30,LOW(10)
	LDI  R31,HIGH(10)
	CALL __DIVW21
	__PUTW1MN _display_buffer,12
; 0000 055B         low_display%=10;
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	LDI  R30,LOW(10)
	LDI  R31,HIGH(10)
	CALL __MODW21
	STD  Y+6,R30
	STD  Y+6+1,R31
; 0000 055C         display_buffer[7]=low_display;
	RJMP _0x338
; 0000 055D         }
; 0000 055E else if (status ==2)
_0x11D:
	LDD  R26,Y+4
	LDD  R27,Y+4+1
	SBIW R26,2
	BREQ PC+2
	RJMP _0x121
; 0000 055F         {
; 0000 0560         message1 = message1 + (up_display *4);
	LDD  R30,Y+8
	LDD  R31,Y+8+1
	CALL __LSLW2
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	STD  Y+2,R30
	STD  Y+2+1,R31
; 0000 0561         display_buffer[0]=*message1;
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	CALL __GETW1P
	STS  _display_buffer,R30
	STS  _display_buffer+1,R31
; 0000 0562         message1++;
	LDD  R30,Y+2
	LDD  R31,Y+2+1
	ADIW R30,2
	STD  Y+2,R30
	STD  Y+2+1,R31
; 0000 0563         display_buffer[1]=*message1;
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	CALL __GETW1P
	__PUTW1MN _display_buffer,2
; 0000 0564         message1++;
	LDD  R30,Y+2
	LDD  R31,Y+2+1
	ADIW R30,2
	STD  Y+2,R30
	STD  Y+2+1,R31
; 0000 0565         display_buffer[2]=*message1;
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	CALL __GETW1P
	__PUTW1MN _display_buffer,4
; 0000 0566         message1++;
	LDD  R30,Y+2
	LDD  R31,Y+2+1
	ADIW R30,2
	STD  Y+2,R30
	STD  Y+2+1,R31
; 0000 0567         display_buffer[3]=*message1;
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	CALL __GETW1P
	__PUTW1MN _display_buffer,6
; 0000 0568         message2 = message2 + (low_display * 4);
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	CALL __LSLW2
	LD   R26,Y
	LDD  R27,Y+1
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	ST   Y,R30
	STD  Y+1,R31
; 0000 0569         display_buffer[4]=*message2;
	LD   R26,Y
	LDD  R27,Y+1
	CALL __GETW1P
	__PUTW1MN _display_buffer,8
; 0000 056A         message2++;
	LD   R30,Y
	LDD  R31,Y+1
	ADIW R30,2
	ST   Y,R30
	STD  Y+1,R31
; 0000 056B         display_buffer[5]=*message2;
	LD   R26,Y
	LDD  R27,Y+1
	CALL __GETW1P
	__PUTW1MN _display_buffer,10
; 0000 056C         message2++;
	LD   R30,Y
	LDD  R31,Y+1
	ADIW R30,2
	ST   Y,R30
	STD  Y+1,R31
; 0000 056D         display_buffer[6]=*message2;
	LD   R26,Y
	LDD  R27,Y+1
	CALL __GETW1P
	__PUTW1MN _display_buffer,12
; 0000 056E         message2++;
	LD   R30,Y
	LDD  R31,Y+1
	ADIW R30,2
	ST   Y,R30
	STD  Y+1,R31
; 0000 056F         display_buffer[7]=*message2;
	LD   R26,Y
	LDD  R27,Y+1
	CALL __GETW1P
_0x338:
	__PUTW1MN _display_buffer,14
; 0000 0570         }
; 0000 0571 /*
; 0000 0572 if (mode ==9 && open_sensor)
; 0000 0573         {
; 0000 0574         display_buffer[0] = 1;
; 0000 0575         display_buffer[1] = 33;
; 0000 0576         display_buffer[2] = 33;
; 0000 0577         display_buffer[3] = 33;
; 0000 0578         }
; 0000 0579 if (mode ==9 && neg_fl)
; 0000 057A         {
; 0000 057B         display_buffer[0] = 32;
; 0000 057C         display_buffer[1] = 32;
; 0000 057D         display_buffer[2] = 32;
; 0000 057E         display_buffer[3] = 32;
; 0000 057F         }
; 0000 0580 */
; 0000 0581 }
_0x121:
	ADIW R28,10
	RET
; .FEND
;
;void check_set(void)
; 0000 0584 {
_check_set:
; .FSTART _check_set
; 0000 0585 if (!key5)
	SBIC 0x16,2
	RJMP _0x122
; 0000 0586     {
; 0000 0587     menu_count++;
	LDI  R26,LOW(_menu_count)
	LDI  R27,HIGH(_menu_count)
	LD   R30,X+
	LD   R31,X+
	ADIW R30,1
	ST   -X,R31
	ST   -X,R30
; 0000 0588     if (menu_count >=4)
	LDS  R26,_menu_count
	LDS  R27,_menu_count+1
	SBIW R26,4
	BRLT _0x123
; 0000 0589         {
; 0000 058A         menu_count =0;
	LDI  R30,LOW(0)
	STS  _menu_count,R30
	STS  _menu_count+1,R30
; 0000 058B         if(!menu_fl)
	SBRC R3,4
	RJMP _0x124
; 0000 058C             {
; 0000 058D             menu_fl =1;
	SET
	BLD  R3,4
; 0000 058E             level =1;
	LDI  R30,LOW(1)
	LDI  R31,HIGH(1)
	STS  _level,R30
	STS  _level+1,R31
; 0000 058F             item1=item2=0;
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	STS  _item2,R30
	STS  _item2+1,R31
	STS  _item1,R30
	STS  _item1+1,R31
; 0000 0590             blink_digit =0;
	STS  _blink_digit,R30
	STS  _blink_digit+1,R30
; 0000 0591             blink_flag=1;
	BLD  R2,3
; 0000 0592             }
; 0000 0593         else if (menu_fl)
	RJMP _0x125
_0x124:
	SBRC R3,4
; 0000 0594             {
; 0000 0595             escape_menu();
	RCALL _escape_menu
; 0000 0596             }
; 0000 0597         }
_0x125:
; 0000 0598     }
_0x123:
; 0000 0599 else
	RJMP _0x127
_0x122:
; 0000 059A     menu_count =0;
	LDI  R30,LOW(0)
	STS  _menu_count,R30
	STS  _menu_count+1,R30
; 0000 059B }
_0x127:
	RET
; .FEND
;
;
;void ent_key(void)
; 0000 059F {
_ent_key:
; .FSTART _ent_key
; 0000 05A0 if (menu_fl && !cal_fl)
	SBRS R3,4
	RJMP _0x129
	SBRS R3,5
	RJMP _0x12A
_0x129:
	RJMP _0x128
_0x12A:
; 0000 05A1     {
; 0000 05A2     blink_digit =0;
	LDI  R30,LOW(0)
	STS  _blink_digit,R30
	STS  _blink_digit+1,R30
; 0000 05A3 
; 0000 05A4     if (level ==1)
	LDS  R26,_level
	LDS  R27,_level+1
	SBIW R26,1
	BRNE _0x12B
; 0000 05A5         {
; 0000 05A6         level =2;
	LDI  R30,LOW(2)
	LDI  R31,HIGH(2)
	STS  _level,R30
	STS  _level+1,R31
; 0000 05A7         item2 =0;
	LDI  R30,LOW(0)
	STS  _item2,R30
	STS  _item2+1,R30
; 0000 05A8         }
; 0000 05A9     else if (level==2)
	RJMP _0x12C
_0x12B:
	LDS  R26,_level
	LDS  R27,_level+1
	SBIW R26,2
	BREQ PC+2
	RJMP _0x12D
; 0000 05AA         {
; 0000 05AB         item2++;
	LDI  R26,LOW(_item2)
	LDI  R27,HIGH(_item2)
	LD   R30,X+
	LD   R31,X+
	ADIW R30,1
	ST   -X,R31
	ST   -X,R30
; 0000 05AC         switch (item1)
	LDS  R30,_item1
	LDS  R31,_item1+1
; 0000 05AD             {
; 0000 05AE             case 0: ee_gen[item2-1] = gen[item2-1]; //store in eeprom
	SBIW R30,0
	BRNE _0x131
	LDS  R30,_item2
	LDS  R31,_item2+1
	SBIW R30,1
	MOVW R22,R30
	LDI  R26,LOW(_ee_gen)
	LDI  R27,HIGH(_ee_gen)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	MOVW R0,R30
	MOVW R30,R22
	LDI  R26,LOW(_gen)
	LDI  R27,HIGH(_gen)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	MOVW R26,R0
	CALL __EEPROMWRW
; 0000 05AF 
; 0000 05B0                     if (item2 >= 1)
	LDS  R26,_item2
	LDS  R27,_item2+1
	SBIW R26,1
	BRLT _0x132
; 0000 05B1                     {
; 0000 05B2                     item2 =0;       //general parameters st/mb id ,baud
	LDI  R30,LOW(0)
	STS  _item2,R30
	STS  _item2+1,R30
; 0000 05B3                     level =1;       // return to level 1
	LDI  R30,LOW(1)
	LDI  R31,HIGH(1)
	STS  _level,R30
	STS  _level+1,R31
; 0000 05B4                     }
; 0000 05B5                     break;
_0x132:
	RJMP _0x130
; 0000 05B6             case 1: ee_os[item2-1] = os[item2-1]; //store in eeprom
_0x131:
	CPI  R30,LOW(0x1)
	LDI  R26,HIGH(0x1)
	CPC  R31,R26
	BRNE _0x133
	LDS  R30,_item2
	LDS  R31,_item2+1
	SBIW R30,1
	MOVW R22,R30
	LDI  R26,LOW(_ee_os)
	LDI  R27,HIGH(_ee_os)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	MOVW R0,R30
	MOVW R30,R22
	LDI  R26,LOW(_os)
	LDI  R27,HIGH(_os)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	MOVW R26,R0
	CALL __EEPROMWRW
; 0000 05B7 
; 0000 05B8                     if (item2 >= 7)
	LDS  R26,_item2
	LDS  R27,_item2+1
	SBIW R26,7
	BRLT _0x134
; 0000 05B9                     {
; 0000 05BA                     item2 =0;       //offset
	LDI  R30,LOW(0)
	STS  _item2,R30
	STS  _item2+1,R30
; 0000 05BB                     level =1;
	LDI  R30,LOW(1)
	LDI  R31,HIGH(1)
	STS  _level,R30
	STS  _level+1,R31
; 0000 05BC                     }
; 0000 05BD                     break;
_0x134:
	RJMP _0x130
; 0000 05BE             case 2: ee_skip[item2-1] = skip[item2-1]; //store in eeprom
_0x133:
	CPI  R30,LOW(0x2)
	LDI  R26,HIGH(0x2)
	CPC  R31,R26
	BRNE _0x135
	LDS  R30,_item2
	LDS  R31,_item2+1
	SBIW R30,1
	MOVW R22,R30
	LDI  R26,LOW(_ee_skip)
	LDI  R27,HIGH(_ee_skip)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	MOVW R0,R30
	MOVW R30,R22
	LDI  R26,LOW(_skip)
	LDI  R27,HIGH(_skip)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	MOVW R26,R0
	CALL __EEPROMWRW
; 0000 05BF                     if (item2 >= 7)
	LDS  R26,_item2
	LDS  R27,_item2+1
	SBIW R26,7
	BRLT _0x136
; 0000 05C0                     {
; 0000 05C1                     item2 =0;       //skip
	LDI  R30,LOW(0)
	STS  _item2,R30
	STS  _item2+1,R30
; 0000 05C2                     level =1;       // return to level 1
	LDI  R30,LOW(1)
	LDI  R31,HIGH(1)
	STS  _level,R30
	STS  _level+1,R31
; 0000 05C3 
; 0000 05C4                     }
; 0000 05C5                     break;
_0x136:
	RJMP _0x130
; 0000 05C6             case 3: ee_rlow[item2-1] = rlow[item2-1]; //store in eeprom
_0x135:
	CPI  R30,LOW(0x3)
	LDI  R26,HIGH(0x3)
	CPC  R31,R26
	BRNE _0x137
	LDS  R30,_item2
	LDS  R31,_item2+1
	SBIW R30,1
	MOVW R22,R30
	LDI  R26,LOW(_ee_rlow)
	LDI  R27,HIGH(_ee_rlow)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	MOVW R0,R30
	MOVW R30,R22
	LDI  R26,LOW(_rlow)
	LDI  R27,HIGH(_rlow)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	MOVW R26,R0
	CALL __EEPROMWRW
; 0000 05C7                     if (item2 >= 7)
	LDS  R26,_item2
	LDS  R27,_item2+1
	SBIW R26,7
	BRLT _0x138
; 0000 05C8                     {
; 0000 05C9                     item2 =0;       //rlow
	LDI  R30,LOW(0)
	STS  _item2,R30
	STS  _item2+1,R30
; 0000 05CA                     level =1;       // return to level 1
	LDI  R30,LOW(1)
	LDI  R31,HIGH(1)
	STS  _level,R30
	STS  _level+1,R31
; 0000 05CB 
; 0000 05CC                     }
; 0000 05CD                     break;
_0x138:
	RJMP _0x130
; 0000 05CE             case 4: ee_rhigh[item2-1] = rhigh[item2-1]; //store in eeprom
_0x137:
	CPI  R30,LOW(0x4)
	LDI  R26,HIGH(0x4)
	CPC  R31,R26
	BRNE _0x139
	LDS  R30,_item2
	LDS  R31,_item2+1
	SBIW R30,1
	MOVW R22,R30
	LDI  R26,LOW(_ee_rhigh)
	LDI  R27,HIGH(_ee_rhigh)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	MOVW R0,R30
	MOVW R30,R22
	LDI  R26,LOW(_rhigh)
	LDI  R27,HIGH(_rhigh)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	MOVW R26,R0
	CALL __EEPROMWRW
; 0000 05CF                     if (item2 >= 7)
	LDS  R26,_item2
	LDS  R27,_item2+1
	SBIW R26,7
	BRLT _0x13A
; 0000 05D0                     {
; 0000 05D1                     item2 =0;       //rhigh
	LDI  R30,LOW(0)
	STS  _item2,R30
	STS  _item2+1,R30
; 0000 05D2                     level =1;       // return to level 1
	LDI  R30,LOW(1)
	LDI  R31,HIGH(1)
	STS  _level,R30
	STS  _level+1,R31
; 0000 05D3 
; 0000 05D4 
; 0000 05D5                     }
; 0000 05D6                     break;
_0x13A:
	RJMP _0x130
; 0000 05D7             case 5: ee_alow[item2-1] = alow[item2-1]; //store in eeprom
_0x139:
	CPI  R30,LOW(0x5)
	LDI  R26,HIGH(0x5)
	CPC  R31,R26
	BRNE _0x13B
	LDS  R30,_item2
	LDS  R31,_item2+1
	SBIW R30,1
	MOVW R22,R30
	LDI  R26,LOW(_ee_alow)
	LDI  R27,HIGH(_ee_alow)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	MOVW R0,R30
	MOVW R30,R22
	LDI  R26,LOW(_alow)
	LDI  R27,HIGH(_alow)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	MOVW R26,R0
	CALL __EEPROMWRW
; 0000 05D8                     if (item2 >= 7)
	LDS  R26,_item2
	LDS  R27,_item2+1
	SBIW R26,7
	BRLT _0x13C
; 0000 05D9                     {
; 0000 05DA                     item2 =0;       //alow
	LDI  R30,LOW(0)
	STS  _item2,R30
	STS  _item2+1,R30
; 0000 05DB                     level =1;       // return to level 1
	LDI  R30,LOW(1)
	LDI  R31,HIGH(1)
	STS  _level,R30
	STS  _level+1,R31
; 0000 05DC                     }
; 0000 05DD                     break;
_0x13C:
	RJMP _0x130
; 0000 05DE             case 6: ee_ahigh[item2-1] = ahigh[item2-1]; //store in eeprom
_0x13B:
	CPI  R30,LOW(0x6)
	LDI  R26,HIGH(0x6)
	CPC  R31,R26
	BRNE _0x13D
	LDS  R30,_item2
	LDS  R31,_item2+1
	SBIW R30,1
	MOVW R22,R30
	LDI  R26,LOW(_ee_ahigh)
	LDI  R27,HIGH(_ee_ahigh)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	MOVW R0,R30
	MOVW R30,R22
	LDI  R26,LOW(_ahigh)
	LDI  R27,HIGH(_ahigh)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	MOVW R26,R0
	CALL __EEPROMWRW
; 0000 05DF                     if (item2 >= 7)
	LDS  R26,_item2
	LDS  R27,_item2+1
	SBIW R26,7
	BRLT _0x13E
; 0000 05E0                     {
; 0000 05E1                     item2 =0;       //ahigh
	LDI  R30,LOW(0)
	STS  _item2,R30
	STS  _item2+1,R30
; 0000 05E2                     level =1;       // return to level 1
	LDI  R30,LOW(1)
	LDI  R31,HIGH(1)
	STS  _level,R30
	STS  _level+1,R31
; 0000 05E3 
; 0000 05E4                     }
; 0000 05E5                     break;
_0x13E:
	RJMP _0x130
; 0000 05E6             case 7: ee_input[item2-1] = input[item2-1]; //store in eeprom
_0x13D:
	CPI  R30,LOW(0x7)
	LDI  R26,HIGH(0x7)
	CPC  R31,R26
	BREQ PC+2
	RJMP _0x13F
	LDS  R30,_item2
	LDS  R31,_item2+1
	SBIW R30,1
	MOVW R22,R30
	LDI  R26,LOW(_ee_input)
	LDI  R27,HIGH(_ee_input)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	MOVW R0,R30
	MOVW R30,R22
	LDI  R26,LOW(_input)
	LDI  R27,HIGH(_input)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	MOVW R26,R0
	CALL __EEPROMWRW
; 0000 05E7                     switch (input[item2-1])
	LDS  R30,_item2
	LDS  R31,_item2+1
	SBIW R30,1
	LDI  R26,LOW(_input)
	LDI  R27,HIGH(_input)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
; 0000 05E8                         {
; 0000 05E9                         case 0:dp[item2-1]=2;
	SBIW R30,0
	BRNE _0x143
	LDS  R30,_item2
	LDS  R31,_item2+1
	SBIW R30,1
	LDI  R26,LOW(_dp)
	LDI  R27,HIGH(_dp)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	LDI  R30,LOW(2)
	LDI  R31,HIGH(2)
	RJMP _0x339
; 0000 05EA                              break;
; 0000 05EB                         case 1: dp[item2-1] =3;
_0x143:
	CPI  R30,LOW(0x1)
	LDI  R26,HIGH(0x1)
	CPC  R31,R26
	BREQ _0x33A
; 0000 05EC                                 break;
; 0000 05ED                         case 2: dp[item2-1] =3;
	CPI  R30,LOW(0x2)
	LDI  R26,HIGH(0x2)
	CPC  R31,R26
	BREQ _0x33A
; 0000 05EE                                 break;
; 0000 05EF                         case 3: dp[item2-1] =3;
	CPI  R30,LOW(0x3)
	LDI  R26,HIGH(0x3)
	CPC  R31,R26
	BREQ _0x33A
; 0000 05F0                                 break;
; 0000 05F1                         case 4: dp[item2-1] =3;
	CPI  R30,LOW(0x4)
	LDI  R26,HIGH(0x4)
	CPC  R31,R26
	BREQ _0x33A
; 0000 05F2                                 break;
; 0000 05F3                         case 5: dp[item2-1] =3;
	CPI  R30,LOW(0x5)
	LDI  R26,HIGH(0x5)
	CPC  R31,R26
	BREQ _0x33A
; 0000 05F4                                 break;
; 0000 05F5                         case 6: dp[item2-1] =3;
	CPI  R30,LOW(0x6)
	LDI  R26,HIGH(0x6)
	CPC  R31,R26
	BRNE _0x142
_0x33A:
	LDS  R30,_item2
	LDS  R31,_item2+1
	SBIW R30,1
	LDI  R26,LOW(_dp)
	LDI  R27,HIGH(_dp)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	LDI  R30,LOW(3)
	LDI  R31,HIGH(3)
_0x339:
	ST   X+,R30
	ST   X,R31
; 0000 05F6                                 break;
; 0000 05F7                         }
_0x142:
; 0000 05F8                     if (item2 >= 7)
	LDS  R26,_item2
	LDS  R27,_item2+1
	SBIW R26,7
	BRLT _0x14A
; 0000 05F9                     {
; 0000 05FA                     item2 =0;       //input
	LDI  R30,LOW(0)
	STS  _item2,R30
	STS  _item2+1,R30
; 0000 05FB                     level =1;       // return to level 1
	LDI  R30,LOW(1)
	LDI  R31,HIGH(1)
	STS  _level,R30
	STS  _level+1,R31
; 0000 05FC 
; 0000 05FD                     }
; 0000 05FE                     break;
_0x14A:
	RJMP _0x130
; 0000 05FF             case 8: ee_dp[item2-1] = dp[item2-1]; //store in eeprom
_0x13F:
	CPI  R30,LOW(0x8)
	LDI  R26,HIGH(0x8)
	CPC  R31,R26
	BRNE _0x130
	LDS  R30,_item2
	LDS  R31,_item2+1
	SBIW R30,1
	MOVW R22,R30
	LDI  R26,LOW(_ee_dp)
	LDI  R27,HIGH(_ee_dp)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	MOVW R0,R30
	MOVW R30,R22
	LDI  R26,LOW(_dp)
	LDI  R27,HIGH(_dp)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	MOVW R26,R0
	CALL __EEPROMWRW
; 0000 0600                     if (item2 >= 7)
	LDS  R26,_item2
	LDS  R27,_item2+1
	SBIW R26,7
	BRLT _0x14C
; 0000 0601                     {
; 0000 0602                     item2 =0;       //input
	LDI  R30,LOW(0)
	STS  _item2,R30
	STS  _item2+1,R30
; 0000 0603                     level =1;       // return to level 1
	LDI  R30,LOW(1)
	LDI  R31,HIGH(1)
	STS  _level,R30
	STS  _level+1,R31
; 0000 0604 
; 0000 0605                     }
; 0000 0606                     break;
_0x14C:
; 0000 0607 
; 0000 0608 
; 0000 0609             }
_0x130:
; 0000 060A         }
; 0000 060B 
; 0000 060C     else
	RJMP _0x14D
_0x12D:
; 0000 060D         {
; 0000 060E         escape_menu();
	RCALL _escape_menu
; 0000 060F         }
_0x14D:
_0x12C:
; 0000 0610     }
; 0000 0611     else if (cal_fl)
	RJMP _0x14E
_0x128:
	SBRS R3,5
	RJMP _0x14F
; 0000 0612         {
; 0000 0613         mux_scan++;
	LDI  R26,LOW(_mux_scan)
	LDI  R27,HIGH(_mux_scan)
	LD   R30,X+
	LD   R31,X+
	ADIW R30,1
	ST   -X,R31
	ST   -X,R30
; 0000 0614         if (mux_scan>=8) mux_scan=0;
	LDS  R26,_mux_scan
	LDS  R27,_mux_scan+1
	SBIW R26,8
	BRLT _0x150
	LDI  R30,LOW(0)
	STS  _mux_scan,R30
	STS  _mux_scan+1,R30
; 0000 0615         switch(mux_scan)
_0x150:
	LDS  R30,_mux_scan
	LDS  R31,_mux_scan+1
; 0000 0616                 {
; 0000 0617                 case 0: mux9 =0;
	SBIW R30,0
	BREQ _0x33B
; 0000 0618                         mux10 =0;
; 0000 0619                         mux11 =0;
; 0000 061A                        break;
; 0000 061B                 case 1: mux9 =1;
	CPI  R30,LOW(0x1)
	LDI  R26,HIGH(0x1)
	CPC  R31,R26
	BRNE _0x15B
	SBI  0x12,3
; 0000 061C                       mux10 =0;
	RJMP _0x33C
; 0000 061D                         mux11 =0;
; 0000 061E                         break;
; 0000 061F                 case 2: mux9 =0;
_0x15B:
	CPI  R30,LOW(0x2)
	LDI  R26,HIGH(0x2)
	CPC  R31,R26
	BRNE _0x162
	CBI  0x12,3
; 0000 0620                         mux10 =1;
	SBI  0x12,4
; 0000 0621                         mux11 =0;
	RJMP _0x33D
; 0000 0622                       break;
; 0000 0623                 case 3: mux9 =1;
_0x162:
	CPI  R30,LOW(0x3)
	LDI  R26,HIGH(0x3)
	CPC  R31,R26
	BRNE _0x169
	SBI  0x12,3
; 0000 0624                         mux10 =1;
	SBI  0x12,4
; 0000 0625                         mux11 =0;
	RJMP _0x33D
; 0000 0626                         break;
; 0000 0627                 case 4: mux9 =0;
_0x169:
	CPI  R30,LOW(0x4)
	LDI  R26,HIGH(0x4)
	CPC  R31,R26
	BRNE _0x170
	CBI  0x12,3
; 0000 0628                         mux10 =0;
	CBI  0x12,4
; 0000 0629                         mux11 =1;
	SBI  0x12,5
; 0000 062A                         break;
	RJMP _0x153
; 0000 062B                 case 5: mux9 =1;
_0x170:
	CPI  R30,LOW(0x5)
	LDI  R26,HIGH(0x5)
	CPC  R31,R26
	BRNE _0x177
	SBI  0x12,3
; 0000 062C                         mux10 =0;
	CBI  0x12,4
; 0000 062D                         mux11 =1;
	SBI  0x12,5
; 0000 062E                         break;
	RJMP _0x153
; 0000 062F                 case 6: mux9 =0;
_0x177:
	CPI  R30,LOW(0x6)
	LDI  R26,HIGH(0x6)
	CPC  R31,R26
	BRNE _0x17E
	CBI  0x12,3
; 0000 0630                         mux10 =1;
	SBI  0x12,4
; 0000 0631                         mux11 =1;
	SBI  0x12,5
; 0000 0632                         break;
	RJMP _0x153
; 0000 0633                 case 7: mux9 =1;
_0x17E:
	CPI  R30,LOW(0x7)
	LDI  R26,HIGH(0x7)
	CPC  R31,R26
	BRNE _0x18C
	SBI  0x12,3
; 0000 0634                         mux10 =1;
	SBI  0x12,4
; 0000 0635                         mux11 =1;
	SBI  0x12,5
; 0000 0636                         break;
	RJMP _0x153
; 0000 0637                 default:mux_scan =0;
_0x18C:
	LDI  R30,LOW(0)
	STS  _mux_scan,R30
	STS  _mux_scan+1,R30
; 0000 0638                         mux9 =0;
_0x33B:
	CBI  0x12,3
; 0000 0639                         mux10 =0;
_0x33C:
	CBI  0x12,4
; 0000 063A                         mux11 =0;
_0x33D:
	CBI  0x12,5
; 0000 063B                         break;
; 0000 063C                 }
_0x153:
; 0000 063D         }
; 0000 063E }
_0x14F:
_0x14E:
	RET
; .FEND
;
;void inc_key(void)
; 0000 0641 {
_inc_key:
; .FSTART _inc_key
; 0000 0642 
; 0000 0643 if (menu_fl && !cal_fl)
	SBRS R3,4
	RJMP _0x194
	SBRS R3,5
	RJMP _0x195
_0x194:
	RJMP _0x193
_0x195:
; 0000 0644     {
; 0000 0645     if (level ==1)
	LDS  R26,_level
	LDS  R27,_level+1
	SBIW R26,1
	BRNE _0x196
; 0000 0646         {
; 0000 0647         item2 =0;
	LDI  R30,LOW(0)
	STS  _item2,R30
	STS  _item2+1,R30
; 0000 0648         item1 ++;
	LDI  R26,LOW(_item1)
	LDI  R27,HIGH(_item1)
	LD   R30,X+
	LD   R31,X+
	ADIW R30,1
	ST   -X,R31
	ST   -X,R30
; 0000 0649         if (item1 ==3) item1 =5;
	LDS  R26,_item1
	LDS  R27,_item1+1
	SBIW R26,3
	BRNE _0x197
	LDI  R30,LOW(5)
	LDI  R31,HIGH(5)
	STS  _item1,R30
	STS  _item1+1,R31
; 0000 064A         if (item1>=7) item1 =0;
_0x197:
	LDS  R26,_item1
	LDS  R27,_item1+1
	SBIW R26,7
	BRLT _0x198
	LDI  R30,LOW(0)
	STS  _item1,R30
	STS  _item1+1,R30
; 0000 064B         }
_0x198:
; 0000 064C     else if (level ==2)
	RJMP _0x199
_0x196:
	LDS  R26,_level
	LDS  R27,_level+1
	SBIW R26,2
	BREQ PC+2
	RJMP _0x19A
; 0000 064D         {
; 0000 064E         switch (item1)
	LDS  R30,_item1
	LDS  R31,_item1+1
; 0000 064F             {
; 0000 0650             case 0: if (item2==0) increment_value(&gen[0],1,99,0);  //scan time
	SBIW R30,0
	BREQ PC+2
	RJMP _0x19E
	LDS  R30,_item2
	LDS  R31,_item2+1
	SBIW R30,0
	BRNE _0x19F
	LDI  R30,LOW(_gen)
	LDI  R31,HIGH(_gen)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(1)
	LDI  R31,HIGH(1)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(99)
	LDI  R31,HIGH(99)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(0)
	LDI  R27,0
	RCALL _increment_value
; 0000 0651                     if(item2 ==1) increment_value(&gen[1],1,242,blink_digit);//modbus id
_0x19F:
	LDS  R26,_item2
	LDS  R27,_item2+1
	SBIW R26,1
	BRNE _0x1A0
	__POINTW1MN _gen,2
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(1)
	LDI  R31,HIGH(1)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(242)
	LDI  R31,HIGH(242)
	ST   -Y,R31
	ST   -Y,R30
	LDS  R26,_blink_digit
	LDS  R27,_blink_digit+1
	RCALL _increment_value
; 0000 0652                     if (item2==2) increment_value(&gen[2],0,3,0);   //baud rates 9600/19200/38400/115200
_0x1A0:
	LDS  R26,_item2
	LDS  R27,_item2+1
	SBIW R26,2
	BRNE _0x1A1
	__POINTW1MN _gen,4
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(3)
	LDI  R31,HIGH(3)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(0)
	LDI  R27,0
	RCALL _increment_value
; 0000 0653                     break;
_0x1A1:
	RJMP _0x19D
; 0000 0654             case 1: increment_value(&os[item2],-999,1999,blink_digit);   //offset
_0x19E:
	CPI  R30,LOW(0x1)
	LDI  R26,HIGH(0x1)
	CPC  R31,R26
	BRNE _0x1A2
	LDS  R30,_item2
	LDS  R31,_item2+1
	LDI  R26,LOW(_os)
	LDI  R27,HIGH(_os)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(64537)
	LDI  R31,HIGH(64537)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(1999)
	LDI  R31,HIGH(1999)
	ST   -Y,R31
	ST   -Y,R30
	LDS  R26,_blink_digit
	LDS  R27,_blink_digit+1
	RCALL _increment_value
; 0000 0655                     break;
	RJMP _0x19D
; 0000 0656             case 2: increment_value(&skip[item2],0,1,0);    //skip
_0x1A2:
	CPI  R30,LOW(0x2)
	LDI  R26,HIGH(0x2)
	CPC  R31,R26
	BRNE _0x1A3
	LDS  R30,_item2
	LDS  R31,_item2+1
	LDI  R26,LOW(_skip)
	LDI  R27,HIGH(_skip)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(1)
	LDI  R31,HIGH(1)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(0)
	LDI  R27,0
	RCALL _increment_value
; 0000 0657                     break;
	RJMP _0x19D
; 0000 0658             case 3: increment_value(&rlow[item2],-200,300,blink_digit);    //rlow
_0x1A3:
	CPI  R30,LOW(0x3)
	LDI  R26,HIGH(0x3)
	CPC  R31,R26
	BRNE _0x1A4
	LDS  R30,_item2
	LDS  R31,_item2+1
	LDI  R26,LOW(_rlow)
	LDI  R27,HIGH(_rlow)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(65336)
	LDI  R31,HIGH(65336)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(300)
	LDI  R31,HIGH(300)
	ST   -Y,R31
	ST   -Y,R30
	LDS  R26,_blink_digit
	LDS  R27,_blink_digit+1
	RCALL _increment_value
; 0000 0659                     break;
	RJMP _0x19D
; 0000 065A             case 4: increment_value(&rhigh[item2],-200,300,blink_digit);   //rhigh
_0x1A4:
	CPI  R30,LOW(0x4)
	LDI  R26,HIGH(0x4)
	CPC  R31,R26
	BRNE _0x1A5
	LDS  R30,_item2
	LDS  R31,_item2+1
	LDI  R26,LOW(_rhigh)
	LDI  R27,HIGH(_rhigh)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(65336)
	LDI  R31,HIGH(65336)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(300)
	LDI  R31,HIGH(300)
	ST   -Y,R31
	ST   -Y,R30
	LDS  R26,_blink_digit
	LDS  R27,_blink_digit+1
	RCALL _increment_value
; 0000 065B                     break;
	RJMP _0x19D
; 0000 065C             case 5: increment_value(&alow[item2],-200,300,blink_digit);    //alow
_0x1A5:
	CPI  R30,LOW(0x5)
	LDI  R26,HIGH(0x5)
	CPC  R31,R26
	BRNE _0x1A6
	LDS  R30,_item2
	LDS  R31,_item2+1
	LDI  R26,LOW(_alow)
	LDI  R27,HIGH(_alow)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(65336)
	LDI  R31,HIGH(65336)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(300)
	LDI  R31,HIGH(300)
	ST   -Y,R31
	ST   -Y,R30
	LDS  R26,_blink_digit
	LDS  R27,_blink_digit+1
	RCALL _increment_value
; 0000 065D                     break;
	RJMP _0x19D
; 0000 065E             case 6: increment_value(&ahigh[item2],-200,300,blink_digit);   //ahigh
_0x1A6:
	CPI  R30,LOW(0x6)
	LDI  R26,HIGH(0x6)
	CPC  R31,R26
	BRNE _0x1A7
	LDS  R30,_item2
	LDS  R31,_item2+1
	LDI  R26,LOW(_ahigh)
	LDI  R27,HIGH(_ahigh)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(65336)
	LDI  R31,HIGH(65336)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(300)
	LDI  R31,HIGH(300)
	ST   -Y,R31
	ST   -Y,R30
	LDS  R26,_blink_digit
	LDS  R27,_blink_digit+1
	RCALL _increment_value
; 0000 065F                     break;
	RJMP _0x19D
; 0000 0660             case 7: increment_value(&input[item2],0,8,0);     //input selection
_0x1A7:
	CPI  R30,LOW(0x7)
	LDI  R26,HIGH(0x7)
	CPC  R31,R26
	BRNE _0x1A8
	LDS  R30,_item2
	LDS  R31,_item2+1
	LDI  R26,LOW(_input)
	LDI  R27,HIGH(_input)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(8)
	LDI  R31,HIGH(8)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(0)
	LDI  R27,0
	RCALL _increment_value
; 0000 0661                      break;
	RJMP _0x19D
; 0000 0662             case 8: if (input[item2]<7)
_0x1A8:
	CPI  R30,LOW(0x8)
	LDI  R26,HIGH(0x8)
	CPC  R31,R26
	BRNE _0x1AC
	LDS  R30,_item2
	LDS  R31,_item2+1
	LDI  R26,LOW(_input)
	LDI  R27,HIGH(_input)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	SBIW R30,7
	BRGE _0x1AA
; 0000 0663                         increment_value(&dp[item2],3,3,0);       //decimal point selection for temperature
	LDS  R30,_item2
	LDS  R31,_item2+1
	LDI  R26,LOW(_dp)
	LDI  R27,HIGH(_dp)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(3)
	LDI  R31,HIGH(3)
	RJMP _0x33E
; 0000 0664                     else
_0x1AA:
; 0000 0665                         increment_value(&dp[item2],0,3,0);       //decimal point selection for voltage and current
	LDS  R30,_item2
	LDS  R31,_item2+1
	LDI  R26,LOW(_dp)
	LDI  R27,HIGH(_dp)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
_0x33E:
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(3)
	LDI  R31,HIGH(3)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(0)
	LDI  R27,0
	RCALL _increment_value
; 0000 0666                     break;
	RJMP _0x19D
; 0000 0667             default:escape_menu();
_0x1AC:
	RCALL _escape_menu
; 0000 0668                     break;
; 0000 0669             }
_0x19D:
; 0000 066A         }
; 0000 066B 
; 0000 066C 
; 0000 066D 
; 0000 066E     }
_0x19A:
_0x199:
; 0000 066F else if (cal_fl)         //zero setting for all 8 channels
	RJMP _0x1AD
_0x193:
	SBRS R3,5
	RJMP _0x1AE
; 0000 0670     {
; 0000 0671     cal_zero[mux_scan]=adc3421_read();
	LDS  R30,_mux_scan
	LDS  R31,_mux_scan+1
	LDI  R26,LOW(_cal_zero)
	LDI  R27,HIGH(_cal_zero)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	PUSH R31
	PUSH R30
	CALL _adc3421_read
	POP  R26
	POP  R27
	ST   X+,R30
	ST   X,R31
; 0000 0672     ee_cal_zero[mux_scan]= cal_zero[mux_scan];
	LDS  R30,_mux_scan
	LDS  R31,_mux_scan+1
	LDI  R26,LOW(_ee_cal_zero)
	LDI  R27,HIGH(_ee_cal_zero)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	MOVW R0,R30
	LDS  R30,_mux_scan
	LDS  R31,_mux_scan+1
	LDI  R26,LOW(_cal_zero)
	LDI  R27,HIGH(_cal_zero)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	MOVW R26,R0
	CALL __EEPROMWRW
; 0000 0673     }
; 0000 0674 else if (!menu_fl && !cal_fl && hold_fl)
	RJMP _0x1AF
_0x1AE:
	SBRC R3,4
	RJMP _0x1B1
	SBRC R3,5
	RJMP _0x1B1
	SBRC R3,7
	RJMP _0x1B2
_0x1B1:
	RJMP _0x1B0
_0x1B2:
; 0000 0675             {
; 0000 0676         display_scan_cnt++;
	MOVW R30,R10
	ADIW R30,1
	MOVW R10,R30
; 0000 0677         if (skip[display_scan_cnt]!=0 && display_scan_cnt <=8)
	LDI  R26,LOW(_skip)
	LDI  R27,HIGH(_skip)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	SBIW R30,0
	BREQ _0x1B4
	LDI  R30,LOW(8)
	LDI  R31,HIGH(8)
	CP   R30,R10
	CPC  R31,R11
	BRGE _0x1B5
_0x1B4:
	RJMP _0x1B3
_0x1B5:
; 0000 0678         goto bypass1;
	RJMP _0x1B6
; 0000 0679         if (display_scan_cnt >=8) display_scan_cnt =0;
_0x1B3:
	LDI  R30,LOW(8)
	LDI  R31,HIGH(8)
	CP   R10,R30
	CPC  R11,R31
	BRLT _0x1B7
	CLR  R10
	CLR  R11
; 0000 067A         display_put(process_value[display_scan_cnt],display_scan_cnt+1,0,dummy,dummy2);
_0x1B7:
	MOVW R30,R10
	LDI  R26,LOW(_process_value)
	LDI  R27,HIGH(_process_value)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	ST   -Y,R31
	ST   -Y,R30
	MOVW R30,R10
	ADIW R30,1
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(_dummy)
	LDI  R31,HIGH(_dummy)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(_dummy2)
	LDI  R27,HIGH(_dummy2)
	RCALL _display_put
; 0000 067B         bypass1:
_0x1B6:
; 0000 067C         }
; 0000 067D }
_0x1B0:
_0x1AF:
_0x1AD:
	RET
; .FEND
;
;void dec_key(void)
; 0000 0680 {
_dec_key:
; .FSTART _dec_key
; 0000 0681 
; 0000 0682 if (menu_fl &&!cal_fl)
	SBRS R3,4
	RJMP _0x1B9
	SBRS R3,5
	RJMP _0x1BA
_0x1B9:
	RJMP _0x1B8
_0x1BA:
; 0000 0683     {
; 0000 0684     if (level ==1)
	LDS  R26,_level
	LDS  R27,_level+1
	SBIW R26,1
	BRNE _0x1BB
; 0000 0685         {
; 0000 0686         item1 --;
	LDI  R26,LOW(_item1)
	LDI  R27,HIGH(_item1)
	LD   R30,X+
	LD   R31,X+
	SBIW R30,1
	ST   -X,R31
	ST   -X,R30
; 0000 0687         if (item1==4) item1=2;      //skip r-lo/r-hi
	LDS  R26,_item1
	LDS  R27,_item1+1
	SBIW R26,4
	BRNE _0x1BC
	LDI  R30,LOW(2)
	LDI  R31,HIGH(2)
	STS  _item1,R30
	STS  _item1+1,R31
; 0000 0688         if (item1<0) item1 =6;
_0x1BC:
	LDS  R26,_item1+1
	TST  R26
	BRPL _0x1BD
	LDI  R30,LOW(6)
	LDI  R31,HIGH(6)
	STS  _item1,R30
	STS  _item1+1,R31
; 0000 0689         }
_0x1BD:
; 0000 068A     else if (level ==2)
	RJMP _0x1BE
_0x1BB:
	LDS  R26,_level
	LDS  R27,_level+1
	SBIW R26,2
	BREQ PC+2
	RJMP _0x1BF
; 0000 068B         {
; 0000 068C         switch (item1)
	LDS  R30,_item1
	LDS  R31,_item1+1
; 0000 068D             {
; 0000 068E             case 0: if (item2==0) decrement_value(&gen[0],1,99,0);  //scan time
	SBIW R30,0
	BREQ PC+2
	RJMP _0x1C3
	LDS  R30,_item2
	LDS  R31,_item2+1
	SBIW R30,0
	BRNE _0x1C4
	LDI  R30,LOW(_gen)
	LDI  R31,HIGH(_gen)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(1)
	LDI  R31,HIGH(1)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(99)
	LDI  R31,HIGH(99)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(0)
	LDI  R27,0
	RCALL _decrement_value
; 0000 068F                     if(item2 ==1) decrement_value(&gen[1],1,242,blink_digit);//modbus id
_0x1C4:
	LDS  R26,_item2
	LDS  R27,_item2+1
	SBIW R26,1
	BRNE _0x1C5
	__POINTW1MN _gen,2
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(1)
	LDI  R31,HIGH(1)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(242)
	LDI  R31,HIGH(242)
	ST   -Y,R31
	ST   -Y,R30
	LDS  R26,_blink_digit
	LDS  R27,_blink_digit+1
	RCALL _decrement_value
; 0000 0690                     if (item2==2) decrement_value(&gen[2],0,3,0);   //baud rates 9600/19200/38400/115200
_0x1C5:
	LDS  R26,_item2
	LDS  R27,_item2+1
	SBIW R26,2
	BRNE _0x1C6
	__POINTW1MN _gen,4
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(3)
	LDI  R31,HIGH(3)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(0)
	LDI  R27,0
	RCALL _decrement_value
; 0000 0691                     break;
_0x1C6:
	RJMP _0x1C2
; 0000 0692             case 1: decrement_value(&os[item2],-999,999,blink_digit);   //offset
_0x1C3:
	CPI  R30,LOW(0x1)
	LDI  R26,HIGH(0x1)
	CPC  R31,R26
	BRNE _0x1C7
	LDS  R30,_item2
	LDS  R31,_item2+1
	LDI  R26,LOW(_os)
	LDI  R27,HIGH(_os)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(64537)
	LDI  R31,HIGH(64537)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(999)
	LDI  R31,HIGH(999)
	ST   -Y,R31
	ST   -Y,R30
	LDS  R26,_blink_digit
	LDS  R27,_blink_digit+1
	RCALL _decrement_value
; 0000 0693                     break;
	RJMP _0x1C2
; 0000 0694             case 2: decrement_value(&skip[item2],0,1,0);    //skip
_0x1C7:
	CPI  R30,LOW(0x2)
	LDI  R26,HIGH(0x2)
	CPC  R31,R26
	BRNE _0x1C8
	LDS  R30,_item2
	LDS  R31,_item2+1
	LDI  R26,LOW(_skip)
	LDI  R27,HIGH(_skip)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(1)
	LDI  R31,HIGH(1)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(0)
	LDI  R27,0
	RCALL _decrement_value
; 0000 0695                     break;
	RJMP _0x1C2
; 0000 0696             case 3: decrement_value(&rlow[item2],-200,300,blink_digit);    //rlow
_0x1C8:
	CPI  R30,LOW(0x3)
	LDI  R26,HIGH(0x3)
	CPC  R31,R26
	BRNE _0x1C9
	LDS  R30,_item2
	LDS  R31,_item2+1
	LDI  R26,LOW(_rlow)
	LDI  R27,HIGH(_rlow)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(65336)
	LDI  R31,HIGH(65336)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(300)
	LDI  R31,HIGH(300)
	ST   -Y,R31
	ST   -Y,R30
	LDS  R26,_blink_digit
	LDS  R27,_blink_digit+1
	RCALL _decrement_value
; 0000 0697                     break;
	RJMP _0x1C2
; 0000 0698             case 4: decrement_value(&rhigh[item2],-200,300,blink_digit);   //rhigh
_0x1C9:
	CPI  R30,LOW(0x4)
	LDI  R26,HIGH(0x4)
	CPC  R31,R26
	BRNE _0x1CA
	LDS  R30,_item2
	LDS  R31,_item2+1
	LDI  R26,LOW(_rhigh)
	LDI  R27,HIGH(_rhigh)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(65336)
	LDI  R31,HIGH(65336)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(300)
	LDI  R31,HIGH(300)
	ST   -Y,R31
	ST   -Y,R30
	LDS  R26,_blink_digit
	LDS  R27,_blink_digit+1
	RCALL _decrement_value
; 0000 0699                     break;
	RJMP _0x1C2
; 0000 069A             case 5: decrement_value(&alow[item2],-200,300,blink_digit);    //alow
_0x1CA:
	CPI  R30,LOW(0x5)
	LDI  R26,HIGH(0x5)
	CPC  R31,R26
	BRNE _0x1CB
	LDS  R30,_item2
	LDS  R31,_item2+1
	LDI  R26,LOW(_alow)
	LDI  R27,HIGH(_alow)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(65336)
	LDI  R31,HIGH(65336)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(300)
	LDI  R31,HIGH(300)
	ST   -Y,R31
	ST   -Y,R30
	LDS  R26,_blink_digit
	LDS  R27,_blink_digit+1
	CALL _decrement_value
; 0000 069B                     break;
	RJMP _0x1C2
; 0000 069C             case 6: decrement_value(&ahigh[item2],-200,300,blink_digit);   //ahigh
_0x1CB:
	CPI  R30,LOW(0x6)
	LDI  R26,HIGH(0x6)
	CPC  R31,R26
	BRNE _0x1CC
	LDS  R30,_item2
	LDS  R31,_item2+1
	LDI  R26,LOW(_ahigh)
	LDI  R27,HIGH(_ahigh)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(65336)
	LDI  R31,HIGH(65336)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(300)
	LDI  R31,HIGH(300)
	ST   -Y,R31
	ST   -Y,R30
	LDS  R26,_blink_digit
	LDS  R27,_blink_digit+1
	CALL _decrement_value
; 0000 069D                     break;
	RJMP _0x1C2
; 0000 069E             case 7: decrement_value(&input[item2],0,8,0);     //input selection
_0x1CC:
	CPI  R30,LOW(0x7)
	LDI  R26,HIGH(0x7)
	CPC  R31,R26
	BRNE _0x1CD
	LDS  R30,_item2
	LDS  R31,_item2+1
	LDI  R26,LOW(_input)
	LDI  R27,HIGH(_input)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(8)
	LDI  R31,HIGH(8)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(0)
	LDI  R27,0
	CALL _decrement_value
; 0000 069F                     break;
	RJMP _0x1C2
; 0000 06A0             case 8: if (input[item2]<7)
_0x1CD:
	CPI  R30,LOW(0x8)
	LDI  R26,HIGH(0x8)
	CPC  R31,R26
	BRNE _0x1D1
	LDS  R30,_item2
	LDS  R31,_item2+1
	LDI  R26,LOW(_input)
	LDI  R27,HIGH(_input)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	SBIW R30,7
	BRGE _0x1CF
; 0000 06A1                         decrement_value(&dp[item2],3,3,0);       //decimal point selection for temperature
	LDS  R30,_item2
	LDS  R31,_item2+1
	LDI  R26,LOW(_dp)
	LDI  R27,HIGH(_dp)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(3)
	LDI  R31,HIGH(3)
	RJMP _0x33F
; 0000 06A2                     else
_0x1CF:
; 0000 06A3                         decrement_value(&dp[item2],0,3,0);       //decimal point selection for voltage and current
	LDS  R30,_item2
	LDS  R31,_item2+1
	LDI  R26,LOW(_dp)
	LDI  R27,HIGH(_dp)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
_0x33F:
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(3)
	LDI  R31,HIGH(3)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(0)
	LDI  R27,0
	CALL _decrement_value
; 0000 06A4                     break;
	RJMP _0x1C2
; 0000 06A5 
; 0000 06A6             default:escape_menu();
_0x1D1:
	CALL _escape_menu
; 0000 06A7                     break;
; 0000 06A8             }
_0x1C2:
; 0000 06A9         }
; 0000 06AA 
; 0000 06AB 
; 0000 06AC 
; 0000 06AD     }
_0x1BF:
_0x1BE:
; 0000 06AE else if (cal_fl)
	RJMP _0x1D2
_0x1B8:
	SBRS R3,5
	RJMP _0x1D3
; 0000 06AF     {
; 0000 06B0     cal_span[mux_scan]=adc3421_read();
	LDS  R30,_mux_scan
	LDS  R31,_mux_scan+1
	LDI  R26,LOW(_cal_span)
	LDI  R27,HIGH(_cal_span)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	PUSH R31
	PUSH R30
	CALL _adc3421_read
	POP  R26
	POP  R27
	ST   X+,R30
	ST   X,R31
; 0000 06B1     ee_cal_span[mux_scan] = cal_span[mux_scan];
	LDS  R30,_mux_scan
	LDS  R31,_mux_scan+1
	LDI  R26,LOW(_ee_cal_span)
	LDI  R27,HIGH(_ee_cal_span)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	MOVW R0,R30
	LDS  R30,_mux_scan
	LDS  R31,_mux_scan+1
	LDI  R26,LOW(_cal_span)
	LDI  R27,HIGH(_cal_span)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	MOVW R26,R0
	CALL __EEPROMWRW
; 0000 06B2     }
; 0000 06B3 }
_0x1D3:
_0x1D2:
	RET
; .FEND
;
;void shf_key(void)
; 0000 06B6 {
_shf_key:
; .FSTART _shf_key
; 0000 06B7     if (!menu_fl && !cal_fl) hold_fl = ~hold_fl; //toggle hold scan flag
	SBRC R3,4
	RJMP _0x1D5
	SBRS R3,5
	RJMP _0x1D6
_0x1D5:
	RJMP _0x1D4
_0x1D6:
	LDI  R30,LOW(128)
	EOR  R3,R30
; 0000 06B8     if (blink_flag)
_0x1D4:
	SBRS R2,3
	RJMP _0x1D7
; 0000 06B9     blink_digit++;
	LDI  R26,LOW(_blink_digit)
	LDI  R27,HIGH(_blink_digit)
	LD   R30,X+
	LD   R31,X+
	ADIW R30,1
	ST   -X,R31
	ST   -X,R30
; 0000 06BA     if (blink_digit > 3)
_0x1D7:
	LDS  R26,_blink_digit
	LDS  R27,_blink_digit+1
	SBIW R26,4
	BRLT _0x1D8
; 0000 06BB     blink_digit=0;
	LDI  R30,LOW(0)
	STS  _blink_digit,R30
	STS  _blink_digit+1,R30
; 0000 06BC }
_0x1D8:
	RET
; .FEND
;
;// Timer1 overflow interrupt service routine
;interrupt [TIM1_OVF] void timer1_ovf_isr(void)
; 0000 06C0 {
_timer1_ovf_isr:
; .FSTART _timer1_ovf_isr
	ST   -Y,R26
	ST   -Y,R27
	ST   -Y,R30
	ST   -Y,R31
	IN   R30,SREG
	ST   -Y,R30
; 0000 06C1 // Reinitialize Timer1 value
; 0000 06C2 TCNT1H=0xABA0 >> 8;
	LDI  R30,LOW(171)
	OUT  0x2D,R30
; 0000 06C3 TCNT1L=0xABA0 & 0xff;
	LDI  R30,LOW(160)
	OUT  0x2C,R30
; 0000 06C4 // Place your code here
; 0000 06C5 qsecfl = ~qsecfl;
	LDI  R30,LOW(32)
	EOR  R2,R30
; 0000 06C6 hsec_fl =1;
	SET
	BLD  R2,7
; 0000 06C7 blinking = ~blinking;
	LDI  R30,LOW(16)
	EOR  R2,R30
; 0000 06C8 tsec_cnt++;
	LDI  R26,LOW(_tsec_cnt)
	LDI  R27,HIGH(_tsec_cnt)
	LD   R30,X+
	LD   R31,X+
	ADIW R30,1
	ST   -X,R31
	ST   -X,R30
; 0000 06C9 if (tsec_cnt >=(2*gen[0])) //scan time in seconds
	LDS  R30,_gen
	LDS  R31,_gen+1
	LSL  R30
	ROL  R31
	LDS  R26,_tsec_cnt
	LDS  R27,_tsec_cnt+1
	CP   R26,R30
	CPC  R27,R31
	BRLT _0x1D9
; 0000 06CA     {
; 0000 06CB     tsec_fl =1;
	BLD  R2,6
; 0000 06CC     tsec_cnt =0;
	LDI  R30,LOW(0)
	STS  _tsec_cnt,R30
	STS  _tsec_cnt+1,R30
; 0000 06CD     ser_fl =1;
	BLD  R3,6
; 0000 06CE     }
; 0000 06CF 
; 0000 06D0 
; 0000 06D1 }
_0x1D9:
	LD   R30,Y+
	OUT  SREG,R30
	LD   R31,Y+
	LD   R30,Y+
	LD   R27,Y+
	LD   R26,Y+
	RETI
; .FEND
;
;
;
;
;void led_check(void)
; 0000 06D7 {
_led_check:
; .FSTART _led_check
; 0000 06D8 all_led_off();
	LDI  R30,LOW(255)
	LDI  R31,HIGH(255)
	MOVW R4,R30
; 0000 06D9 all_led_off1();
	MOVW R6,R30
; 0000 06DA if (process_value[0] <= alow[0])
	LDS  R30,_alow
	LDS  R31,_alow+1
	LDS  R26,_process_value
	LDS  R27,_process_value+1
	CP   R30,R26
	CPC  R31,R27
	BRLT _0x1DA
; 0000 06DB gled1_on();
	LDI  R30,LOW(251)
	AND  R6,R30
	CLR  R7
; 0000 06DC if (process_value[0] >= ahigh[0])
_0x1DA:
	LDS  R30,_ahigh
	LDS  R31,_ahigh+1
	LDS  R26,_process_value
	LDS  R27,_process_value+1
	CP   R26,R30
	CPC  R27,R31
	BRLT _0x1DB
; 0000 06DD rled1_on();
	LDI  R30,LOW(251)
	AND  R4,R30
	CLR  R5
; 0000 06DE 
; 0000 06DF 
; 0000 06E0 if (skip[1] ==0)
_0x1DB:
	__GETW1MN _skip,2
	SBIW R30,0
	BRNE _0x1DC
; 0000 06E1     {
; 0000 06E2     if (process_value[1] <= alow[1])
	__GETW2MN _process_value,2
	__GETW1MN _alow,2
	CP   R30,R26
	CPC  R31,R27
	BRLT _0x1DD
; 0000 06E3     gled2_on();
	LDI  R30,LOW(253)
	AND  R6,R30
	CLR  R7
; 0000 06E4     if (process_value[1] >= ahigh[1])
_0x1DD:
	__GETW2MN _process_value,2
	__GETW1MN _ahigh,2
	CP   R26,R30
	CPC  R27,R31
	BRLT _0x1DE
; 0000 06E5     rled2_on();
	LDI  R30,LOW(253)
	AND  R4,R30
	CLR  R5
; 0000 06E6 
; 0000 06E7     }
_0x1DE:
; 0000 06E8 if (skip[2] ==0)
_0x1DC:
	__GETW1MN _skip,4
	SBIW R30,0
	BRNE _0x1DF
; 0000 06E9     {
; 0000 06EA     if (process_value[2] <= alow[2])
	__GETW2MN _process_value,4
	__GETW1MN _alow,4
	CP   R30,R26
	CPC  R31,R27
	BRLT _0x1E0
; 0000 06EB     gled3_on();
	LDI  R30,LOW(254)
	AND  R6,R30
	CLR  R7
; 0000 06EC     if (process_value[2] >= ahigh[2])
_0x1E0:
	__GETW2MN _process_value,4
	__GETW1MN _ahigh,4
	CP   R26,R30
	CPC  R27,R31
	BRLT _0x1E1
; 0000 06ED     rled3_on();
	LDI  R30,LOW(254)
	AND  R4,R30
	CLR  R5
; 0000 06EE 
; 0000 06EF     }
_0x1E1:
; 0000 06F0 if (skip[3] ==0)
_0x1DF:
	__GETW1MN _skip,6
	SBIW R30,0
	BRNE _0x1E2
; 0000 06F1     {
; 0000 06F2     if (process_value[3] <= alow[3])
	__GETW2MN _process_value,6
	__GETW1MN _alow,6
	CP   R30,R26
	CPC  R31,R27
	BRLT _0x1E3
; 0000 06F3     gled4_on();
	LDI  R30,LOW(247)
	AND  R6,R30
	CLR  R7
; 0000 06F4     if (process_value[3] >= ahigh[3])
_0x1E3:
	__GETW2MN _process_value,6
	__GETW1MN _ahigh,6
	CP   R26,R30
	CPC  R27,R31
	BRLT _0x1E4
; 0000 06F5     rled4_on();
	LDI  R30,LOW(247)
	AND  R4,R30
	CLR  R5
; 0000 06F6 
; 0000 06F7     }
_0x1E4:
; 0000 06F8 if (skip[4] ==0)
_0x1E2:
	__GETW1MN _skip,8
	SBIW R30,0
	BRNE _0x1E5
; 0000 06F9     {
; 0000 06FA     if (process_value[4] <= alow[4])
	__GETW2MN _process_value,8
	__GETW1MN _alow,8
	CP   R30,R26
	CPC  R31,R27
	BRLT _0x1E6
; 0000 06FB     gled5_on();
	LDI  R30,LOW(239)
	AND  R6,R30
	CLR  R7
; 0000 06FC     if (process_value[4] >= ahigh[4])
_0x1E6:
	__GETW2MN _process_value,8
	__GETW1MN _ahigh,8
	CP   R26,R30
	CPC  R27,R31
	BRLT _0x1E7
; 0000 06FD     rled5_on();
	LDI  R30,LOW(239)
	AND  R4,R30
	CLR  R5
; 0000 06FE     }
_0x1E7:
; 0000 06FF if (skip[5] ==0)
_0x1E5:
	__GETW1MN _skip,10
	SBIW R30,0
	BRNE _0x1E8
; 0000 0700     {
; 0000 0701     if (process_value[5] <= alow[5])
	__GETW2MN _process_value,10
	__GETW1MN _alow,10
	CP   R30,R26
	CPC  R31,R27
	BRLT _0x1E9
; 0000 0702     gled6_on();
	LDI  R30,LOW(223)
	AND  R6,R30
	CLR  R7
; 0000 0703     if (process_value[5] >= ahigh[5])
_0x1E9:
	__GETW2MN _process_value,10
	__GETW1MN _ahigh,10
	CP   R26,R30
	CPC  R27,R31
	BRLT _0x1EA
; 0000 0704     rled6_on();
	LDI  R30,LOW(223)
	AND  R4,R30
	CLR  R5
; 0000 0705     }
_0x1EA:
; 0000 0706 if (skip[6] ==0)
_0x1E8:
	__GETW1MN _skip,12
	SBIW R30,0
	BRNE _0x1EB
; 0000 0707     {
; 0000 0708     if (process_value[6] <= alow[6])
	__GETW2MN _process_value,12
	__GETW1MN _alow,12
	CP   R30,R26
	CPC  R31,R27
	BRLT _0x1EC
; 0000 0709     gled7_on();
	LDI  R30,LOW(191)
	AND  R6,R30
	CLR  R7
; 0000 070A     if (process_value[6] >= ahigh[6])
_0x1EC:
	__GETW2MN _process_value,12
	__GETW1MN _ahigh,12
	CP   R26,R30
	CPC  R27,R31
	BRLT _0x1ED
; 0000 070B     rled7_on();
	LDI  R30,LOW(191)
	AND  R4,R30
	CLR  R5
; 0000 070C     }
_0x1ED:
; 0000 070D //if (skip[7] ==0)
; 0000 070E //    {
; 0000 070F //    if (process_value[7] <= alow[7])
; 0000 0710 //    gled8_on();
; 0000 0711 //    if (process_value[7] >= ahigh[7])
; 0000 0712 //    rled8_on();
; 0000 0713 //    }
; 0000 0714 }
_0x1EB:
	RET
; .FEND
;
;void  relay_logic()
; 0000 0717 {
_relay_logic:
; .FSTART _relay_logic
; 0000 0718 if (led_status ==0xff)
	LDI  R30,LOW(255)
	LDI  R31,HIGH(255)
	CP   R30,R4
	CPC  R31,R5
	BRNE _0x1EE
; 0000 0719 relay1 =1;
	SBI  0x12,7
; 0000 071A else
	RJMP _0x1F1
_0x1EE:
; 0000 071B relay1 =0;
	CBI  0x12,7
; 0000 071C 
; 0000 071D if (led_status1 ==0xff)
_0x1F1:
	LDI  R30,LOW(255)
	LDI  R31,HIGH(255)
	CP   R30,R6
	CPC  R31,R7
	BRNE _0x1F4
; 0000 071E relay2 =1;
	SBI  0x12,6
; 0000 071F else
	RJMP _0x1F7
_0x1F4:
; 0000 0720 relay2 =0;
	CBI  0x12,6
; 0000 0721 }
_0x1F7:
	RET
; .FEND
;
;void pv_update(void)
; 0000 0724 {
_pv_update:
; .FSTART _pv_update
; 0000 0725 int adc_value,min_val,max_val;
; 0000 0726 if (!cal_fl)
	CALL __SAVELOCR6
;	adc_value -> R16,R17
;	min_val -> R18,R19
;	max_val -> R20,R21
	SBRC R3,5
	RJMP _0x1FA
; 0000 0727 {
; 0000 0728 adc_value=adc3421_read();
	CALL _adc3421_read
	MOVW R16,R30
; 0000 0729 if (mux_scan ==7 && tc_fl)  //added to calculate ambient value
	LDS  R26,_mux_scan
	LDS  R27,_mux_scan+1
	SBIW R26,7
	BRNE _0x1FC
	SBRC R2,1
	RJMP _0x1FD
_0x1FC:
	RJMP _0x1FB
_0x1FD:
; 0000 072A {
; 0000 072B if ( adc_value >= cal_zero[7])
	__GETW1MN _cal_zero,14
	CP   R16,R30
	CPC  R17,R31
	BRLT _0x1FE
; 0000 072C {
; 0000 072D ambient_val = 30 + (adc_value - cal_zero[7])/22;
	__GETW2MN _cal_zero,14
	MOVW R30,R16
	SUB  R30,R26
	SBC  R31,R27
	MOVW R26,R30
	LDI  R30,LOW(22)
	LDI  R31,HIGH(22)
	CALL __DIVW21
	ADIW R30,30
	MOVW R12,R30
; 0000 072E }
; 0000 072F else
	RJMP _0x1FF
_0x1FE:
; 0000 0730 {
; 0000 0731 ambient_val = 30 - (adc_value - cal_zero[7])/22;
	__GETW2MN _cal_zero,14
	MOVW R30,R16
	SUB  R30,R26
	SBC  R31,R27
	MOVW R26,R30
	LDI  R30,LOW(22)
	LDI  R31,HIGH(22)
	CALL __DIVW21
	LDI  R26,LOW(30)
	LDI  R27,HIGH(30)
	SUB  R26,R30
	SBC  R27,R31
	MOVW R12,R26
; 0000 0732 }
_0x1FF:
; 0000 0733 
; 0000 0734 
; 0000 0735 }
; 0000 0736 else
	RJMP _0x200
_0x1FB:
; 0000 0737 {
; 0000 0738 //process_value[mux_scan] = ((long)adc_value -(long)cal_zero[mux_scan]) * 10000 / ((long)cal_span[mux_scan]- (long)cal_z ...
; 0000 0739 switch (input[mux_scan])
	LDS  R30,_mux_scan
	LDS  R31,_mux_scan+1
	LDI  R26,LOW(_input)
	LDI  R27,HIGH(_input)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
; 0000 073A     {
; 0000 073B     case 0: process_value[mux_scan] = linearise_p(adc_value,cal_zero[mux_scan],cal_span[mux_scan])+os[mux_scan];
	SBIW R30,0
	BREQ PC+2
	RJMP _0x204
	LDS  R30,_mux_scan
	LDS  R31,_mux_scan+1
	LDI  R26,LOW(_process_value)
	LDI  R27,HIGH(_process_value)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	PUSH R31
	PUSH R30
	MOVW R30,R16
	CALL __CWD1
	CALL __CDF1
	CALL __PUTPARD1
	LDS  R30,_mux_scan
	LDS  R31,_mux_scan+1
	LDI  R26,LOW(_cal_zero)
	LDI  R27,HIGH(_cal_zero)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	CALL __CWD1
	CALL __CDF1
	CALL __PUTPARD1
	LDS  R30,_mux_scan
	LDS  R31,_mux_scan+1
	LDI  R26,LOW(_cal_span)
	LDI  R27,HIGH(_cal_span)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	CALL __CWD1
	CALL __CDF1
	MOVW R26,R30
	MOVW R24,R22
	CALL _linearise_p
	MOVW R0,R30
	LDS  R30,_mux_scan
	LDS  R31,_mux_scan+1
	LDI  R26,LOW(_os)
	LDI  R27,HIGH(_os)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	ADD  R30,R0
	ADC  R31,R1
	POP  R26
	POP  R27
	ST   X+,R30
	ST   X,R31
; 0000 073C             min_val = -1999;
	__GETWRN 18,19,-1999
; 0000 073D             max_val = 6000;
	__GETWRN 20,21,6000
; 0000 073E             break;
	RJMP _0x203
; 0000 073F     case 1: process_value[mux_scan] = linearise_p(adc_value,cal_zero[mux_scan],cal_span[mux_scan])/10 +os[mux_scan];
_0x204:
	CPI  R30,LOW(0x1)
	LDI  R26,HIGH(0x1)
	CPC  R31,R26
	BREQ PC+2
	RJMP _0x205
	LDS  R30,_mux_scan
	LDS  R31,_mux_scan+1
	LDI  R26,LOW(_process_value)
	LDI  R27,HIGH(_process_value)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	PUSH R31
	PUSH R30
	MOVW R30,R16
	CALL __CWD1
	CALL __CDF1
	CALL __PUTPARD1
	LDS  R30,_mux_scan
	LDS  R31,_mux_scan+1
	LDI  R26,LOW(_cal_zero)
	LDI  R27,HIGH(_cal_zero)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	CALL __CWD1
	CALL __CDF1
	CALL __PUTPARD1
	LDS  R30,_mux_scan
	LDS  R31,_mux_scan+1
	LDI  R26,LOW(_cal_span)
	LDI  R27,HIGH(_cal_span)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	CALL __CWD1
	CALL __CDF1
	MOVW R26,R30
	MOVW R24,R22
	CALL _linearise_p
	MOVW R26,R30
	LDI  R30,LOW(10)
	LDI  R31,HIGH(10)
	CALL __DIVW21
	MOVW R0,R30
	LDS  R30,_mux_scan
	LDS  R31,_mux_scan+1
	LDI  R26,LOW(_os)
	LDI  R27,HIGH(_os)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	ADD  R30,R0
	ADC  R31,R1
	POP  R26
	POP  R27
	ST   X+,R30
	ST   X,R31
; 0000 0740             min_val = -199;
	__GETWRN 18,19,-199
; 0000 0741             max_val = 600;
	__GETWRN 20,21,600
; 0000 0742             break;
	RJMP _0x203
; 0000 0743     case 2: process_value[mux_scan] = linearise_tc(adc_value,cal_zero[mux_scan],cal_span[mux_scan],15,table_j,5000)+os[m ...
_0x205:
	CPI  R30,LOW(0x2)
	LDI  R26,HIGH(0x2)
	CPC  R31,R26
	BREQ PC+2
	RJMP _0x206
	LDS  R30,_mux_scan
	LDS  R31,_mux_scan+1
	LDI  R26,LOW(_process_value)
	LDI  R27,HIGH(_process_value)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	PUSH R31
	PUSH R30
	MOVW R30,R16
	CALL __CWD1
	CALL __CDF1
	CALL __PUTPARD1
	LDS  R30,_mux_scan
	LDS  R31,_mux_scan+1
	LDI  R26,LOW(_cal_zero)
	LDI  R27,HIGH(_cal_zero)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	CALL __CWD1
	CALL __CDF1
	CALL __PUTPARD1
	LDS  R30,_mux_scan
	LDS  R31,_mux_scan+1
	LDI  R26,LOW(_cal_span)
	LDI  R27,HIGH(_cal_span)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	CALL __CWD1
	CALL __CDF1
	CALL __PUTPARD1
	LDI  R30,LOW(15)
	LDI  R31,HIGH(15)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(_table_j)
	LDI  R31,HIGH(_table_j)
	ST   -Y,R31
	ST   -Y,R30
	__GETD2N 0x1388
	CALL _linearise_tc
	MOVW R0,R30
	LDS  R30,_mux_scan
	LDS  R31,_mux_scan+1
	LDI  R26,LOW(_os)
	LDI  R27,HIGH(_os)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	ADD  R30,R0
	ADC  R31,R1
	POP  R26
	POP  R27
	ST   X+,R30
	ST   X,R31
; 0000 0744             min_val =0;
	__GETWRN 18,19,0
; 0000 0745             max_val = 700;
	__GETWRN 20,21,700
; 0000 0746             break;
	RJMP _0x203
; 0000 0747     case 3: process_value[mux_scan] = linearise_tc(adc_value,cal_zero[mux_scan],cal_span[mux_scan],28,table_k,5000)+os[m ...
_0x206:
	CPI  R30,LOW(0x3)
	LDI  R26,HIGH(0x3)
	CPC  R31,R26
	BREQ PC+2
	RJMP _0x207
	LDS  R30,_mux_scan
	LDS  R31,_mux_scan+1
	LDI  R26,LOW(_process_value)
	LDI  R27,HIGH(_process_value)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	PUSH R31
	PUSH R30
	MOVW R30,R16
	CALL __CWD1
	CALL __CDF1
	CALL __PUTPARD1
	LDS  R30,_mux_scan
	LDS  R31,_mux_scan+1
	LDI  R26,LOW(_cal_zero)
	LDI  R27,HIGH(_cal_zero)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	CALL __CWD1
	CALL __CDF1
	CALL __PUTPARD1
	LDS  R30,_mux_scan
	LDS  R31,_mux_scan+1
	LDI  R26,LOW(_cal_span)
	LDI  R27,HIGH(_cal_span)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	CALL __CWD1
	CALL __CDF1
	CALL __PUTPARD1
	LDI  R30,LOW(28)
	LDI  R31,HIGH(28)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(_table_k)
	LDI  R31,HIGH(_table_k)
	ST   -Y,R31
	ST   -Y,R30
	__GETD2N 0x1388
	CALL _linearise_tc
	MOVW R0,R30
	LDS  R30,_mux_scan
	LDS  R31,_mux_scan+1
	LDI  R26,LOW(_os)
	LDI  R27,HIGH(_os)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	ADD  R30,R0
	ADC  R31,R1
	POP  R26
	POP  R27
	ST   X+,R30
	ST   X,R31
; 0000 0748             min_val =0;
	__GETWRN 18,19,0
; 0000 0749             max_val = 1300;
	__GETWRN 20,21,1300
; 0000 074A             break;
	RJMP _0x203
; 0000 074B     case 4: process_value[mux_scan] = linearise_tc(adc_value,cal_zero[mux_scan],cal_span[mux_scan],36,table_r,50000)+os[ ...
_0x207:
	CPI  R30,LOW(0x4)
	LDI  R26,HIGH(0x4)
	CPC  R31,R26
	BREQ PC+2
	RJMP _0x208
	LDS  R30,_mux_scan
	LDS  R31,_mux_scan+1
	LDI  R26,LOW(_process_value)
	LDI  R27,HIGH(_process_value)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	PUSH R31
	PUSH R30
	MOVW R30,R16
	CALL __CWD1
	CALL __CDF1
	CALL __PUTPARD1
	LDS  R30,_mux_scan
	LDS  R31,_mux_scan+1
	LDI  R26,LOW(_cal_zero)
	LDI  R27,HIGH(_cal_zero)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	CALL __CWD1
	CALL __CDF1
	CALL __PUTPARD1
	LDS  R30,_mux_scan
	LDS  R31,_mux_scan+1
	LDI  R26,LOW(_cal_span)
	LDI  R27,HIGH(_cal_span)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	CALL __CWD1
	CALL __CDF1
	CALL __PUTPARD1
	LDI  R30,LOW(36)
	LDI  R31,HIGH(36)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(_table_r)
	LDI  R31,HIGH(_table_r)
	ST   -Y,R31
	ST   -Y,R30
	__GETD2N 0xC350
	CALL _linearise_tc
	MOVW R0,R30
	LDS  R30,_mux_scan
	LDS  R31,_mux_scan+1
	LDI  R26,LOW(_os)
	LDI  R27,HIGH(_os)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	ADD  R30,R0
	ADC  R31,R1
	POP  R26
	POP  R27
	ST   X+,R30
	ST   X,R31
; 0000 074C             min_val =0;
	__GETWRN 18,19,0
; 0000 074D             max_val = 1700;
	__GETWRN 20,21,1700
; 0000 074E             break;
	RJMP _0x203
; 0000 074F     case 5: process_value[mux_scan] = linearise_tc(adc_value,cal_zero[mux_scan],cal_span[mux_scan],36,table_s,50000)+os[ ...
_0x208:
	CPI  R30,LOW(0x5)
	LDI  R26,HIGH(0x5)
	CPC  R31,R26
	BREQ PC+2
	RJMP _0x209
	LDS  R30,_mux_scan
	LDS  R31,_mux_scan+1
	LDI  R26,LOW(_process_value)
	LDI  R27,HIGH(_process_value)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	PUSH R31
	PUSH R30
	MOVW R30,R16
	CALL __CWD1
	CALL __CDF1
	CALL __PUTPARD1
	LDS  R30,_mux_scan
	LDS  R31,_mux_scan+1
	LDI  R26,LOW(_cal_zero)
	LDI  R27,HIGH(_cal_zero)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	CALL __CWD1
	CALL __CDF1
	CALL __PUTPARD1
	LDS  R30,_mux_scan
	LDS  R31,_mux_scan+1
	LDI  R26,LOW(_cal_span)
	LDI  R27,HIGH(_cal_span)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	CALL __CWD1
	CALL __CDF1
	CALL __PUTPARD1
	LDI  R30,LOW(36)
	LDI  R31,HIGH(36)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(_table_s)
	LDI  R31,HIGH(_table_s)
	ST   -Y,R31
	ST   -Y,R30
	__GETD2N 0xC350
	CALL _linearise_tc
	MOVW R0,R30
	LDS  R30,_mux_scan
	LDS  R31,_mux_scan+1
	LDI  R26,LOW(_os)
	LDI  R27,HIGH(_os)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	ADD  R30,R0
	ADC  R31,R1
	POP  R26
	POP  R27
	ST   X+,R30
	ST   X,R31
; 0000 0750             min_val =0;
	__GETWRN 18,19,0
; 0000 0751             max_val = 1700;
	__GETWRN 20,21,1700
; 0000 0752             break;
	RJMP _0x203
; 0000 0753     case 6: process_value[mux_scan] = linearise_t(adc_value,cal_zero[mux_scan],cal_span[mux_scan])+os[mux_scan];
_0x209:
	CPI  R30,LOW(0x6)
	LDI  R26,HIGH(0x6)
	CPC  R31,R26
	BREQ PC+2
	RJMP _0x20A
	LDS  R30,_mux_scan
	LDS  R31,_mux_scan+1
	LDI  R26,LOW(_process_value)
	LDI  R27,HIGH(_process_value)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	PUSH R31
	PUSH R30
	MOVW R30,R16
	CALL __CWD1
	CALL __CDF1
	CALL __PUTPARD1
	LDS  R30,_mux_scan
	LDS  R31,_mux_scan+1
	LDI  R26,LOW(_cal_zero)
	LDI  R27,HIGH(_cal_zero)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	CALL __CWD1
	CALL __CDF1
	CALL __PUTPARD1
	LDS  R30,_mux_scan
	LDS  R31,_mux_scan+1
	LDI  R26,LOW(_cal_span)
	LDI  R27,HIGH(_cal_span)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	CALL __CWD1
	CALL __CDF1
	MOVW R26,R30
	MOVW R24,R22
	CALL _linearise_t
	MOVW R0,R30
	LDS  R30,_mux_scan
	LDS  R31,_mux_scan+1
	LDI  R26,LOW(_os)
	LDI  R27,HIGH(_os)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	ADD  R30,R0
	ADC  R31,R1
	POP  R26
	POP  R27
	ST   X+,R30
	ST   X,R31
; 0000 0754             min_val =-200;
	__GETWRN 18,19,-200
; 0000 0755             max_val = 350;
	__GETWRN 20,21,350
; 0000 0756             break;
	RJMP _0x203
; 0000 0757     case 7: process_value[mux_scan] = linearise_volt(adc_value,cal_zero[mux_scan],cal_span[mux_scan],rhigh[mux_scan],rlo ...
_0x20A:
	CPI  R30,LOW(0x7)
	LDI  R26,HIGH(0x7)
	CPC  R31,R26
	BREQ PC+2
	RJMP _0x20B
	LDS  R30,_mux_scan
	LDS  R31,_mux_scan+1
	LDI  R26,LOW(_process_value)
	LDI  R27,HIGH(_process_value)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	PUSH R31
	PUSH R30
	MOVW R30,R16
	CALL __CWD1
	CALL __CDF1
	CALL __PUTPARD1
	LDS  R30,_mux_scan
	LDS  R31,_mux_scan+1
	LDI  R26,LOW(_cal_zero)
	LDI  R27,HIGH(_cal_zero)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	CALL __CWD1
	CALL __CDF1
	CALL __PUTPARD1
	LDS  R30,_mux_scan
	LDS  R31,_mux_scan+1
	LDI  R26,LOW(_cal_span)
	LDI  R27,HIGH(_cal_span)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	CALL __CWD1
	CALL __CDF1
	CALL __PUTPARD1
	LDS  R30,_mux_scan
	LDS  R31,_mux_scan+1
	LDI  R26,LOW(_rhigh)
	LDI  R27,HIGH(_rhigh)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	CALL __CWD1
	CALL __CDF1
	CALL __PUTPARD1
	LDS  R30,_mux_scan
	LDS  R31,_mux_scan+1
	LDI  R26,LOW(_rlow)
	LDI  R27,HIGH(_rlow)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	CALL __CWD1
	CALL __CDF1
	MOVW R26,R30
	MOVW R24,R22
	CALL _linearise_volt
	MOVW R0,R30
	LDS  R30,_mux_scan
	LDS  R31,_mux_scan+1
	LDI  R26,LOW(_os)
	LDI  R27,HIGH(_os)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	ADD  R30,R0
	ADC  R31,R1
	POP  R26
	POP  R27
	RJMP _0x340
; 0000 0758             min_val =-1999;
; 0000 0759             max_val =9999;
; 0000 075A             break;
; 0000 075B     case 8: process_value[mux_scan] = linearise_420(adc_value,cal_zero[mux_scan],cal_span[mux_scan],rhigh[mux_scan],rlow ...
_0x20B:
	CPI  R30,LOW(0x8)
	LDI  R26,HIGH(0x8)
	CPC  R31,R26
	BREQ PC+2
	RJMP _0x203
	LDS  R30,_mux_scan
	LDS  R31,_mux_scan+1
	LDI  R26,LOW(_process_value)
	LDI  R27,HIGH(_process_value)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	PUSH R31
	PUSH R30
	MOVW R30,R16
	CALL __CWD1
	CALL __CDF1
	CALL __PUTPARD1
	LDS  R30,_mux_scan
	LDS  R31,_mux_scan+1
	LDI  R26,LOW(_cal_zero)
	LDI  R27,HIGH(_cal_zero)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	CALL __CWD1
	CALL __CDF1
	CALL __PUTPARD1
	LDS  R30,_mux_scan
	LDS  R31,_mux_scan+1
	LDI  R26,LOW(_cal_span)
	LDI  R27,HIGH(_cal_span)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	CALL __CWD1
	CALL __CDF1
	CALL __PUTPARD1
	LDS  R30,_mux_scan
	LDS  R31,_mux_scan+1
	LDI  R26,LOW(_rhigh)
	LDI  R27,HIGH(_rhigh)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	CALL __CWD1
	CALL __CDF1
	CALL __PUTPARD1
	LDS  R30,_mux_scan
	LDS  R31,_mux_scan+1
	LDI  R26,LOW(_rlow)
	LDI  R27,HIGH(_rlow)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	CALL __CWD1
	CALL __CDF1
	MOVW R26,R30
	MOVW R24,R22
	CALL _linearise_420
	MOVW R0,R30
	LDS  R30,_mux_scan
	LDS  R31,_mux_scan+1
	LDI  R26,LOW(_os)
	LDI  R27,HIGH(_os)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	ADD  R30,R0
	ADC  R31,R1
	POP  R26
	POP  R27
_0x340:
	ST   X+,R30
	ST   X,R31
; 0000 075C              min_val =-1999;
	__GETWRN 18,19,-1999
; 0000 075D             max_val =9999;
	__GETWRN 20,21,9999
; 0000 075E             break;
; 0000 075F     }
_0x203:
; 0000 0760     //check for overrange or underrange or skip. proces_error used in other routines and modbus
; 0000 0761     //0: normal
; 0000 0762     //1: underrange
; 0000 0763     //2: overrange
; 0000 0764     //3: skip
; 0000 0765     //////////////////////////////////////////////////////////////////////////
; 0000 0766     if (process_value[mux_scan] < min_val) process_error[mux_scan] = 1;
	LDS  R30,_mux_scan
	LDS  R31,_mux_scan+1
	LDI  R26,LOW(_process_value)
	LDI  R27,HIGH(_process_value)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	CP   R30,R18
	CPC  R31,R19
	BRGE _0x20D
	LDS  R30,_mux_scan
	LDS  R31,_mux_scan+1
	LDI  R26,LOW(_process_error)
	LDI  R27,HIGH(_process_error)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	LDI  R30,LOW(1)
	LDI  R31,HIGH(1)
	RJMP _0x341
; 0000 0767     else if (process_value[mux_scan] > max_val) process_error[mux_scan]=2;
_0x20D:
	LDS  R30,_mux_scan
	LDS  R31,_mux_scan+1
	LDI  R26,LOW(_process_value)
	LDI  R27,HIGH(_process_value)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	CP   R20,R30
	CPC  R21,R31
	BRGE _0x20F
	LDS  R30,_mux_scan
	LDS  R31,_mux_scan+1
	LDI  R26,LOW(_process_error)
	LDI  R27,HIGH(_process_error)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	LDI  R30,LOW(2)
	LDI  R31,HIGH(2)
	RJMP _0x341
; 0000 0768     else process_error[mux_scan] =0;        //normal
_0x20F:
	LDS  R30,_mux_scan
	LDS  R31,_mux_scan+1
	LDI  R26,LOW(_process_error)
	LDI  R27,HIGH(_process_error)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
_0x341:
	ST   X+,R30
	ST   X,R31
; 0000 0769     //////////////////////////////////////////////////////////////////////////
; 0000 076A }
_0x200:
; 0000 076B mux_scan++;
	LDI  R26,LOW(_mux_scan)
	LDI  R27,HIGH(_mux_scan)
	LD   R30,X+
	LD   R31,X+
	ADIW R30,1
	ST   -X,R31
	ST   -X,R30
; 0000 076C //////////////////////////////////////////////////////////////////
; 0000 076D //internal scanning according to skip status. to be checked later after uncommenting
; 0000 076E //////////////////////////////////////////////////////////////////
; 0000 076F 
; 0000 0770 if (!(tc_fl && (mux_scan ==7)))
	SBRS R2,1
	RJMP _0x212
	LDS  R26,_mux_scan
	LDS  R27,_mux_scan+1
	SBIW R26,7
	BREQ _0x211
_0x212:
; 0000 0771 {
; 0000 0772 while (skip[mux_scan] !=0)
_0x214:
	LDS  R30,_mux_scan
	LDS  R31,_mux_scan+1
	LDI  R26,LOW(_skip)
	LDI  R27,HIGH(_skip)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	SBIW R30,0
	BREQ _0x216
; 0000 0773 {
; 0000 0774 mux_scan++;
	LDI  R26,LOW(_mux_scan)
	LDI  R27,HIGH(_mux_scan)
	LD   R30,X+
	LD   R31,X+
	ADIW R30,1
	ST   -X,R31
	ST   -X,R30
; 0000 0775 if (mux_scan>=8)
	LDS  R26,_mux_scan
	LDS  R27,_mux_scan+1
	SBIW R26,8
	BRLT _0x214
; 0000 0776 break;
; 0000 0777 }
_0x216:
; 0000 0778 }
; 0000 0779 //////////////////////////////////////////////////////////////////
; 0000 077A 
; 0000 077B 
; 0000 077C 
; 0000 077D if (mux_scan >=8) mux_scan =0;
_0x211:
	LDS  R26,_mux_scan
	LDS  R27,_mux_scan+1
	SBIW R26,8
	BRLT _0x218
	LDI  R30,LOW(0)
	STS  _mux_scan,R30
	STS  _mux_scan+1,R30
; 0000 077E switch(mux_scan)
_0x218:
	LDS  R30,_mux_scan
	LDS  R31,_mux_scan+1
; 0000 077F     {
; 0000 0780     case 0: mux9 =0;
	SBIW R30,0
	BREQ _0x342
; 0000 0781             mux10 =0;
; 0000 0782             mux11 =0;
; 0000 0783             break;
; 0000 0784     case 1: mux9 =1;
	CPI  R30,LOW(0x1)
	LDI  R26,HIGH(0x1)
	CPC  R31,R26
	BRNE _0x223
	SBI  0x12,3
; 0000 0785             mux10 =0;
	RJMP _0x343
; 0000 0786             mux11 =0;
; 0000 0787             break;
; 0000 0788     case 2: mux9 =0;
_0x223:
	CPI  R30,LOW(0x2)
	LDI  R26,HIGH(0x2)
	CPC  R31,R26
	BRNE _0x22A
	CBI  0x12,3
; 0000 0789             mux10 =1;
	SBI  0x12,4
; 0000 078A             mux11 =0;
	RJMP _0x344
; 0000 078B             break;
; 0000 078C     case 3: mux9 =1;
_0x22A:
	CPI  R30,LOW(0x3)
	LDI  R26,HIGH(0x3)
	CPC  R31,R26
	BRNE _0x231
	SBI  0x12,3
; 0000 078D             mux10 =1;
	SBI  0x12,4
; 0000 078E             mux11 =0;
	RJMP _0x344
; 0000 078F             break;
; 0000 0790     case 4: mux9 =0;
_0x231:
	CPI  R30,LOW(0x4)
	LDI  R26,HIGH(0x4)
	CPC  R31,R26
	BRNE _0x238
	CBI  0x12,3
; 0000 0791             mux10 =0;
	CBI  0x12,4
; 0000 0792             mux11 =1;
	SBI  0x12,5
; 0000 0793             break;
	RJMP _0x21B
; 0000 0794     case 5: mux9 =1;
_0x238:
	CPI  R30,LOW(0x5)
	LDI  R26,HIGH(0x5)
	CPC  R31,R26
	BRNE _0x23F
	SBI  0x12,3
; 0000 0795             mux10 =0;
	CBI  0x12,4
; 0000 0796             mux11 =1;
	SBI  0x12,5
; 0000 0797             break;
	RJMP _0x21B
; 0000 0798     case 6: mux9 =0;
_0x23F:
	CPI  R30,LOW(0x6)
	LDI  R26,HIGH(0x6)
	CPC  R31,R26
	BRNE _0x246
	CBI  0x12,3
; 0000 0799             mux10 =1;
	SBI  0x12,4
; 0000 079A             mux11 =1;
	SBI  0x12,5
; 0000 079B             break;
	RJMP _0x21B
; 0000 079C     case 7: mux9 =1;
_0x246:
	CPI  R30,LOW(0x7)
	LDI  R26,HIGH(0x7)
	CPC  R31,R26
	BRNE _0x254
	SBI  0x12,3
; 0000 079D             mux10 =1;
	SBI  0x12,4
; 0000 079E             mux11 =1;
	SBI  0x12,5
; 0000 079F             break;
	RJMP _0x21B
; 0000 07A0     default:mux_scan =0;
_0x254:
	LDI  R30,LOW(0)
	STS  _mux_scan,R30
	STS  _mux_scan+1,R30
; 0000 07A1             mux9 =0;
_0x342:
	CBI  0x12,3
; 0000 07A2             mux10 =0;
_0x343:
	CBI  0x12,4
; 0000 07A3             mux11 =0;
_0x344:
	CBI  0x12,5
; 0000 07A4             break;
; 0000 07A5     }
_0x21B:
; 0000 07A6 }
; 0000 07A7 }
_0x1FA:
	CALL __LOADLOCR6
	ADIW R28,6
	RET
; .FEND
;
;void display_check(void)
; 0000 07AA {
_display_check:
; .FSTART _display_check
; 0000 07AB int adc_value;
; 0000 07AC if(!menu_fl && !cal_fl)
	ST   -Y,R17
	ST   -Y,R16
;	adc_value -> R16,R17
	SBRC R3,4
	RJMP _0x25C
	SBRS R3,5
	RJMP _0x25D
_0x25C:
	RJMP _0x25B
_0x25D:
; 0000 07AD     {
; 0000 07AE     skip[0] = ee_skip[0] =0;
	LDI  R26,LOW(_ee_skip)
	LDI  R27,HIGH(_ee_skip)
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	CALL __EEPROMWRW
	STS  _skip,R30
	STS  _skip+1,R31
; 0000 07AF     if (tsec_fl )   //hold_fl =0 implies scan else hold (toggled in shf key routine)
	SBRS R2,6
	RJMP _0x25E
; 0000 07B0         {
; 0000 07B1         if (!hold_fl) display_scan_cnt++;  //hold display to same channel
	SBRC R3,7
	RJMP _0x25F
	MOVW R30,R10
	ADIW R30,1
	MOVW R10,R30
; 0000 07B2         if (skip[display_scan_cnt]!=0 && display_scan_cnt <=7)
_0x25F:
	MOVW R30,R10
	LDI  R26,LOW(_skip)
	LDI  R27,HIGH(_skip)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	SBIW R30,0
	BREQ _0x261
	LDI  R30,LOW(7)
	LDI  R31,HIGH(7)
	CP   R30,R10
	CPC  R31,R11
	BRGE _0x262
_0x261:
	RJMP _0x260
_0x262:
; 0000 07B3         goto bypass;
	RJMP _0x263
; 0000 07B4         tsec_fl =0;
_0x260:
	CLT
	BLD  R2,6
; 0000 07B5         if (display_scan_cnt >=7) display_scan_cnt =0;
	LDI  R30,LOW(7)
	LDI  R31,HIGH(7)
	CP   R10,R30
	CPC  R11,R31
	BRLT _0x264
	CLR  R10
	CLR  R11
; 0000 07B6         switch (process_error[display_scan_cnt])
_0x264:
	MOVW R30,R10
	LDI  R26,LOW(_process_error)
	LDI  R27,HIGH(_process_error)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
; 0000 07B7             {
; 0000 07B8             case 0: display_put(process_value[display_scan_cnt],display_scan_cnt+1,0,dummy,dummy2);
	SBIW R30,0
	BREQ _0x345
; 0000 07B9                     break;
; 0000 07BA            case 1: display_put(0,display_scan_cnt+1,1,message_neg,dummy2);
	CPI  R30,LOW(0x1)
	LDI  R26,HIGH(0x1)
	CPC  R31,R26
	BRNE _0x269
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	ST   -Y,R31
	ST   -Y,R30
	MOVW R30,R10
	ADIW R30,1
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(1)
	LDI  R31,HIGH(1)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(_message_neg)
	LDI  R31,HIGH(_message_neg)
	RJMP _0x346
; 0000 07BB                     break;
; 0000 07BC            case 2: display_put(0,display_scan_cnt+1,1,message_open,dummy2);
_0x269:
	CPI  R30,LOW(0x2)
	LDI  R26,HIGH(0x2)
	CPC  R31,R26
	BRNE _0x26B
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	ST   -Y,R31
	ST   -Y,R30
	MOVW R30,R10
	ADIW R30,1
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(1)
	LDI  R31,HIGH(1)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(_message_open)
	LDI  R31,HIGH(_message_open)
	RJMP _0x346
; 0000 07BD                     break;
; 0000 07BE            default: display_put(process_value[display_scan_cnt],display_scan_cnt+1,0,dummy,dummy2);
_0x26B:
_0x345:
	MOVW R30,R10
	LDI  R26,LOW(_process_value)
	LDI  R27,HIGH(_process_value)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	ST   -Y,R31
	ST   -Y,R30
	MOVW R30,R10
	ADIW R30,1
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(_dummy)
	LDI  R31,HIGH(_dummy)
_0x346:
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(_dummy2)
	LDI  R27,HIGH(_dummy2)
	CALL _display_put
; 0000 07BF                     break;
; 0000 07C0 
; 0000 07C1             }
; 0000 07C2 bypass:
_0x263:
; 0000 07C3         }
; 0000 07C4     }
_0x25E:
; 0000 07C5 
; 0000 07C6 else if (menu_fl && !cal_fl)
	RJMP _0x26C
_0x25B:
	SBRS R3,4
	RJMP _0x26E
	SBRS R3,5
	RJMP _0x26F
_0x26E:
	RJMP _0x26D
_0x26F:
; 0000 07C7     {
; 0000 07C8     if (level ==1)
	LDS  R26,_level
	LDS  R27,_level+1
	SBIW R26,1
	BRNE _0x270
; 0000 07C9         {
; 0000 07CA         display_put(0,item1,2,ms_menu,message_menu);
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	ST   -Y,R31
	ST   -Y,R30
	LDS  R30,_item1
	LDS  R31,_item1+1
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(2)
	LDI  R31,HIGH(2)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(_ms_menu)
	LDI  R31,HIGH(_ms_menu)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(_message_menu)
	LDI  R27,HIGH(_message_menu)
	RJMP _0x347
; 0000 07CB         }
; 0000 07CC     else if (level ==2)
_0x270:
	LDS  R26,_level
	LDS  R27,_level+1
	SBIW R26,2
	BREQ PC+2
	RJMP _0x272
; 0000 07CD         {
; 0000 07CE         switch (item1)
	LDS  R30,_item1
	LDS  R31,_item1+1
; 0000 07CF             {
; 0000 07D0             case 0: if (item2==0) display_put(0,gen[0],1,message_gen,dummy); //st
	SBIW R30,0
	BREQ PC+2
	RJMP _0x276
	LDS  R30,_item2
	LDS  R31,_item2+1
	SBIW R30,0
	BRNE _0x277
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	ST   -Y,R31
	ST   -Y,R30
	LDS  R30,_gen
	LDS  R31,_gen+1
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(1)
	LDI  R31,HIGH(1)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(_message_gen)
	LDI  R31,HIGH(_message_gen)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(_dummy)
	LDI  R27,HIGH(_dummy)
	CALL _display_put
; 0000 07D1                     if (item2==1) display_put(1,gen[1],1,message_gen,dummy);
_0x277:
	LDS  R26,_item2
	LDS  R27,_item2+1
	SBIW R26,1
	BRNE _0x278
	LDI  R30,LOW(1)
	LDI  R31,HIGH(1)
	ST   -Y,R31
	ST   -Y,R30
	__GETW1MN _gen,2
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(1)
	LDI  R31,HIGH(1)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(_message_gen)
	LDI  R31,HIGH(_message_gen)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(_dummy)
	LDI  R27,HIGH(_dummy)
	CALL _display_put
; 0000 07D2                     if (item2==2) display_put(2,gen[2],2,message_gen,message_baud);
_0x278:
	LDS  R26,_item2
	LDS  R27,_item2+1
	SBIW R26,2
	BRNE _0x279
	LDI  R30,LOW(2)
	LDI  R31,HIGH(2)
	ST   -Y,R31
	ST   -Y,R30
	__GETW1MN _gen,4
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(2)
	LDI  R31,HIGH(2)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(_message_gen)
	LDI  R31,HIGH(_message_gen)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(_message_baud)
	LDI  R27,HIGH(_message_baud)
	CALL _display_put
; 0000 07D3                     break;
_0x279:
	RJMP _0x275
; 0000 07D4             case 1: display_put(item2,os[item2],1,message_os,dummy);
_0x276:
	CPI  R30,LOW(0x1)
	LDI  R26,HIGH(0x1)
	CPC  R31,R26
	BRNE _0x27A
	LDS  R30,_item2
	LDS  R31,_item2+1
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(_os)
	LDI  R27,HIGH(_os)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(1)
	LDI  R31,HIGH(1)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(_message_os)
	LDI  R31,HIGH(_message_os)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(_dummy)
	LDI  R27,HIGH(_dummy)
	RJMP _0x347
; 0000 07D5                     break;
; 0000 07D6             case 2: display_put(item2,skip[item2],2,message_skip,message_skuk);
_0x27A:
	CPI  R30,LOW(0x2)
	LDI  R26,HIGH(0x2)
	CPC  R31,R26
	BRNE _0x27B
	LDS  R30,_item2
	LDS  R31,_item2+1
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(_skip)
	LDI  R27,HIGH(_skip)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(2)
	LDI  R31,HIGH(2)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(_message_skip)
	LDI  R31,HIGH(_message_skip)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(_message_skuk)
	LDI  R27,HIGH(_message_skuk)
	RJMP _0x347
; 0000 07D7                     break;
; 0000 07D8             case 3: display_put(item2,rlow[item2],1,message_rlow,dummy);
_0x27B:
	CPI  R30,LOW(0x3)
	LDI  R26,HIGH(0x3)
	CPC  R31,R26
	BRNE _0x27C
	LDS  R30,_item2
	LDS  R31,_item2+1
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(_rlow)
	LDI  R27,HIGH(_rlow)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(1)
	LDI  R31,HIGH(1)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(_message_rlow)
	LDI  R31,HIGH(_message_rlow)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(_dummy)
	LDI  R27,HIGH(_dummy)
	RJMP _0x347
; 0000 07D9                     break;
; 0000 07DA             case 4: display_put(item2,rhigh[item2],1,message_rhigh,dummy);
_0x27C:
	CPI  R30,LOW(0x4)
	LDI  R26,HIGH(0x4)
	CPC  R31,R26
	BRNE _0x27D
	LDS  R30,_item2
	LDS  R31,_item2+1
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(_rhigh)
	LDI  R27,HIGH(_rhigh)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(1)
	LDI  R31,HIGH(1)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(_message_rhigh)
	LDI  R31,HIGH(_message_rhigh)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(_dummy)
	LDI  R27,HIGH(_dummy)
	RJMP _0x347
; 0000 07DB                     break;
; 0000 07DC             case 5: display_put(item2,alow[item2],1,message_alow,dummy);
_0x27D:
	CPI  R30,LOW(0x5)
	LDI  R26,HIGH(0x5)
	CPC  R31,R26
	BRNE _0x27E
	LDS  R30,_item2
	LDS  R31,_item2+1
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(_alow)
	LDI  R27,HIGH(_alow)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(1)
	LDI  R31,HIGH(1)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(_message_alow)
	LDI  R31,HIGH(_message_alow)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(_dummy)
	LDI  R27,HIGH(_dummy)
	RJMP _0x347
; 0000 07DD                     break;
; 0000 07DE             case 6: display_put(item2,ahigh[item2],1,message_ahigh,dummy);
_0x27E:
	CPI  R30,LOW(0x6)
	LDI  R26,HIGH(0x6)
	CPC  R31,R26
	BRNE _0x27F
	LDS  R30,_item2
	LDS  R31,_item2+1
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(_ahigh)
	LDI  R27,HIGH(_ahigh)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(1)
	LDI  R31,HIGH(1)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(_message_ahigh)
	LDI  R31,HIGH(_message_ahigh)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(_dummy)
	LDI  R27,HIGH(_dummy)
	RJMP _0x347
; 0000 07DF                     break;
; 0000 07E0             case 7: display_put(item2,input[item2],2,message_in,message_inp);
_0x27F:
	CPI  R30,LOW(0x7)
	LDI  R26,HIGH(0x7)
	CPC  R31,R26
	BRNE _0x280
	LDS  R30,_item2
	LDS  R31,_item2+1
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(_input)
	LDI  R27,HIGH(_input)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(2)
	LDI  R31,HIGH(2)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(_message_in)
	LDI  R31,HIGH(_message_in)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(_message_inp)
	LDI  R27,HIGH(_message_inp)
	RJMP _0x347
; 0000 07E1                     break;
; 0000 07E2             case 8: display_put(item2,dp[item2],2,message_dp,message_dp1);
_0x280:
	CPI  R30,LOW(0x8)
	LDI  R26,HIGH(0x8)
	CPC  R31,R26
	BRNE _0x275
	LDS  R30,_item2
	LDS  R31,_item2+1
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(_dp)
	LDI  R27,HIGH(_dp)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(2)
	LDI  R31,HIGH(2)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(_message_dp)
	LDI  R31,HIGH(_message_dp)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(_message_dp1)
	LDI  R27,HIGH(_message_dp1)
_0x347:
	CALL _display_put
; 0000 07E3 
; 0000 07E4             }
_0x275:
; 0000 07E5 
; 0000 07E6         }
; 0000 07E7 
; 0000 07E8 
; 0000 07E9 
; 0000 07EA 
; 0000 07EB     }
_0x272:
; 0000 07EC else if (cal_fl)
	RJMP _0x282
_0x26D:
	SBRS R3,5
	RJMP _0x283
; 0000 07ED     {
; 0000 07EE     adc_value = adc3421_read();
	CALL _adc3421_read
	MOVW R16,R30
; 0000 07EF     display_put(mux_scan,adc_value,1,message_cal,dummy);
	LDS  R30,_mux_scan
	LDS  R31,_mux_scan+1
	ST   -Y,R31
	ST   -Y,R30
	ST   -Y,R17
	ST   -Y,R16
	LDI  R30,LOW(1)
	LDI  R31,HIGH(1)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(_message_cal)
	LDI  R31,HIGH(_message_cal)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(_dummy)
	LDI  R27,HIGH(_dummy)
	CALL _display_put
; 0000 07F0     }
; 0000 07F1 }
_0x283:
_0x282:
_0x26C:
	RJMP _0x2060001
; .FEND
;
;void display_out(short int count2)
; 0000 07F4 {
_display_out:
; .FSTART _display_out
; 0000 07F5 int asa;
; 0000 07F6 clear_display();
	ST   -Y,R27
	ST   -Y,R26
	ST   -Y,R17
	ST   -Y,R16
;	count2 -> Y+2
;	asa -> R16,R17
	CALL _clear_display
; 0000 07F7 asa = display_buffer[count2];
	LDD  R30,Y+2
	LDD  R31,Y+2+1
	LDI  R26,LOW(_display_buffer)
	LDI  R27,HIGH(_display_buffer)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	LD   R16,X+
	LD   R17,X
; 0000 07F8 asa = segment_table[asa];
	LDI  R26,LOW(_segment_table)
	LDI  R27,HIGH(_segment_table)
	ADD  R26,R16
	ADC  R27,R17
	LD   R16,X
	CLR  R17
; 0000 07F9 if (count2 == (7-blink_digit))
	LDS  R26,_blink_digit
	LDS  R27,_blink_digit+1
	LDI  R30,LOW(7)
	LDI  R31,HIGH(7)
	SUB  R30,R26
	SBC  R31,R27
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	CP   R30,R26
	CPC  R31,R27
	BRNE _0x284
; 0000 07FA {
; 0000 07FB if (blink_flag && blinking)
	SBRS R2,3
	RJMP _0x286
	SBRC R2,4
	RJMP _0x287
_0x286:
	RJMP _0x285
_0x287:
; 0000 07FC PORTA =0xff;
	LDI  R30,LOW(255)
	OUT  0x1B,R30
; 0000 07FD else
	RJMP _0x288
_0x285:
; 0000 07FE PORTA = asa;
	OUT  0x1B,R16
; 0000 07FF }
_0x288:
; 0000 0800 else
	RJMP _0x289
_0x284:
; 0000 0801 PORTA = asa;//decimal point for upper display
	OUT  0x1B,R16
; 0000 0802 // logic to display decimal point
; 0000 0803 switch (count2)
_0x289:
	LDD  R30,Y+2
	LDD  R31,Y+2+1
; 0000 0804     {
; 0000 0805     case 0: if (!menu_fl && !cal_fl )
	SBIW R30,0
	BRNE _0x28D
	SBRC R3,4
	RJMP _0x28F
	SBRS R3,5
	RJMP _0x290
_0x28F:
	RJMP _0x28E
_0x290:
; 0000 0806                 {
; 0000 0807                 if (dp[display_scan_cnt] ==0) PORTA.7 =0;
	MOVW R30,R10
	LDI  R26,LOW(_dp)
	LDI  R27,HIGH(_dp)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	SBIW R30,0
	BRNE _0x291
	CBI  0x1B,7
; 0000 0808                 }
_0x291:
; 0000 0809             break;
_0x28E:
	RJMP _0x28C
; 0000 080A     case 1: if (!menu_fl && !cal_fl )
_0x28D:
	CPI  R30,LOW(0x1)
	LDI  R26,HIGH(0x1)
	CPC  R31,R26
	BRNE _0x294
	SBRC R3,4
	RJMP _0x296
	SBRS R3,5
	RJMP _0x297
_0x296:
	RJMP _0x295
_0x297:
; 0000 080B                 {
; 0000 080C                 if (dp[display_scan_cnt] ==1) PORTA.7 =0;
	MOVW R30,R10
	LDI  R26,LOW(_dp)
	LDI  R27,HIGH(_dp)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	CPI  R30,LOW(0x1)
	LDI  R26,HIGH(0x1)
	CPC  R31,R26
	BRNE _0x298
	CBI  0x1B,7
; 0000 080D                 }
_0x298:
; 0000 080E             break;
_0x295:
	RJMP _0x28C
; 0000 080F     case 2: if (!menu_fl && !cal_fl )
_0x294:
	CPI  R30,LOW(0x2)
	LDI  R26,HIGH(0x2)
	CPC  R31,R26
	BRNE _0x29B
	SBRC R3,4
	RJMP _0x29D
	SBRS R3,5
	RJMP _0x29E
_0x29D:
	RJMP _0x29C
_0x29E:
; 0000 0810                 {
; 0000 0811                 if (dp[display_scan_cnt] ==2) PORTA.7 =0;
	MOVW R30,R10
	LDI  R26,LOW(_dp)
	LDI  R27,HIGH(_dp)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	CPI  R30,LOW(0x2)
	LDI  R26,HIGH(0x2)
	CPC  R31,R26
	BRNE _0x29F
	CBI  0x1B,7
; 0000 0812                 }
_0x29F:
; 0000 0813             break;
_0x29C:
	RJMP _0x28C
; 0000 0814     case 4: if (menu_fl && !cal_fl && (level ==2))
_0x29B:
	CPI  R30,LOW(0x4)
	LDI  R26,HIGH(0x4)
	CPC  R31,R26
	BRNE _0x2A2
	SBRS R3,4
	RJMP _0x2A4
	SBRC R3,5
	RJMP _0x2A4
	LDS  R26,_level
	LDS  R27,_level+1
	SBIW R26,2
	BREQ _0x2A5
_0x2A4:
	RJMP _0x2A3
_0x2A5:
; 0000 0815                 {
; 0000 0816                 if ((dp[item2] ==0) && ((item1==1)||(item1==3)||(item1==4)||(item1 ==5)||(item1==6))) PORTA.7=0;
	LDS  R30,_item2
	LDS  R31,_item2+1
	LDI  R26,LOW(_dp)
	LDI  R27,HIGH(_dp)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	SBIW R30,0
	BRNE _0x2A7
	LDS  R26,_item1
	LDS  R27,_item1+1
	SBIW R26,1
	BREQ _0x2A8
	LDS  R26,_item1
	LDS  R27,_item1+1
	SBIW R26,3
	BREQ _0x2A8
	LDS  R26,_item1
	LDS  R27,_item1+1
	SBIW R26,4
	BREQ _0x2A8
	LDS  R26,_item1
	LDS  R27,_item1+1
	SBIW R26,5
	BREQ _0x2A8
	LDS  R26,_item1
	LDS  R27,_item1+1
	SBIW R26,6
	BRNE _0x2A7
_0x2A8:
	RJMP _0x2AA
_0x2A7:
	RJMP _0x2A6
_0x2AA:
	CBI  0x1B,7
; 0000 0817                 }
_0x2A6:
; 0000 0818             break;
_0x2A3:
	RJMP _0x28C
; 0000 0819     case 5: if (menu_fl && !cal_fl && (level ==2))
_0x2A2:
	CPI  R30,LOW(0x5)
	LDI  R26,HIGH(0x5)
	CPC  R31,R26
	BRNE _0x2AD
	SBRS R3,4
	RJMP _0x2AF
	SBRC R3,5
	RJMP _0x2AF
	LDS  R26,_level
	LDS  R27,_level+1
	SBIW R26,2
	BREQ _0x2B0
_0x2AF:
	RJMP _0x2AE
_0x2B0:
; 0000 081A                 {
; 0000 081B                 if ((dp[item2] ==1)&& ((item1==1)||(item1==3)||(item1==4)||(item1 ==5)||(item1==6))) PORTA.7=0;
	LDS  R30,_item2
	LDS  R31,_item2+1
	LDI  R26,LOW(_dp)
	LDI  R27,HIGH(_dp)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	SBIW R30,1
	BRNE _0x2B2
	LDS  R26,_item1
	LDS  R27,_item1+1
	SBIW R26,1
	BREQ _0x2B3
	LDS  R26,_item1
	LDS  R27,_item1+1
	SBIW R26,3
	BREQ _0x2B3
	LDS  R26,_item1
	LDS  R27,_item1+1
	SBIW R26,4
	BREQ _0x2B3
	LDS  R26,_item1
	LDS  R27,_item1+1
	SBIW R26,5
	BREQ _0x2B3
	LDS  R26,_item1
	LDS  R27,_item1+1
	SBIW R26,6
	BRNE _0x2B2
_0x2B3:
	RJMP _0x2B5
_0x2B2:
	RJMP _0x2B1
_0x2B5:
	CBI  0x1B,7
; 0000 081C                 }
_0x2B1:
; 0000 081D             break;
_0x2AE:
	RJMP _0x28C
; 0000 081E     case 6: if (menu_fl && !cal_fl && (level ==2))
_0x2AD:
	CPI  R30,LOW(0x6)
	LDI  R26,HIGH(0x6)
	CPC  R31,R26
	BRNE _0x2B8
	SBRS R3,4
	RJMP _0x2BA
	SBRC R3,5
	RJMP _0x2BA
	LDS  R26,_level
	LDS  R27,_level+1
	SBIW R26,2
	BREQ _0x2BB
_0x2BA:
	RJMP _0x2B9
_0x2BB:
; 0000 081F                 {
; 0000 0820                 if ((dp[item2] ==2)&& ((item1==1)||(item1==3)||(item1==4)||(item1 ==5)||(item1==6))) PORTA.7=0;
	LDS  R30,_item2
	LDS  R31,_item2+1
	LDI  R26,LOW(_dp)
	LDI  R27,HIGH(_dp)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	SBIW R30,2
	BRNE _0x2BD
	LDS  R26,_item1
	LDS  R27,_item1+1
	SBIW R26,1
	BREQ _0x2BE
	LDS  R26,_item1
	LDS  R27,_item1+1
	SBIW R26,3
	BREQ _0x2BE
	LDS  R26,_item1
	LDS  R27,_item1+1
	SBIW R26,4
	BREQ _0x2BE
	LDS  R26,_item1
	LDS  R27,_item1+1
	SBIW R26,5
	BREQ _0x2BE
	LDS  R26,_item1
	LDS  R27,_item1+1
	SBIW R26,6
	BRNE _0x2BD
_0x2BE:
	RJMP _0x2C0
_0x2BD:
	RJMP _0x2BC
_0x2C0:
	CBI  0x1B,7
; 0000 0821                 }
_0x2BC:
; 0000 0822             break;
_0x2B9:
	RJMP _0x28C
; 0000 0823     case 7: if (!menu_fl && !cal_fl && hold_fl)
_0x2B8:
	CPI  R30,LOW(0x7)
	LDI  R26,HIGH(0x7)
	CPC  R31,R26
	BRNE _0x28C
	SBRC R3,4
	RJMP _0x2C5
	SBRC R3,5
	RJMP _0x2C5
	SBRC R3,7
	RJMP _0x2C6
_0x2C5:
	RJMP _0x2C4
_0x2C6:
; 0000 0824             {
; 0000 0825             PORTA.7 =0;
	CBI  0x1B,7
; 0000 0826             }
; 0000 0827             break;
_0x2C4:
; 0000 0828 
; 0000 0829 
; 0000 082A     }
_0x28C:
; 0000 082B 
; 0000 082C 
; 0000 082D 
; 0000 082E 
; 0000 082F 
; 0000 0830 ////end of decimal point logic
; 0000 0831 
; 0000 0832 switch(count2)
	LDD  R30,Y+2
	LDD  R31,Y+2+1
; 0000 0833         {
; 0000 0834         case 0:  digit1();
	SBIW R30,0
	BRNE _0x2CC
	SBI  0x15,0
; 0000 0835         break;
	RJMP _0x2CB
; 0000 0836         case 1:  digit2();
_0x2CC:
	CPI  R30,LOW(0x1)
	LDI  R26,HIGH(0x1)
	CPC  R31,R26
	BRNE _0x2CF
	SBI  0x15,7
; 0000 0837         break;
	RJMP _0x2CB
; 0000 0838         case 2:  digit3();
_0x2CF:
	CPI  R30,LOW(0x2)
	LDI  R26,HIGH(0x2)
	CPC  R31,R26
	BRNE _0x2D2
	SBI  0x15,6
; 0000 0839         break;
	RJMP _0x2CB
; 0000 083A         case 3:  digit4();
_0x2D2:
	CPI  R30,LOW(0x3)
	LDI  R26,HIGH(0x3)
	CPC  R31,R26
	BRNE _0x2D5
	SBI  0x15,5
; 0000 083B         break;
	RJMP _0x2CB
; 0000 083C         case 4:  digit5();
_0x2D5:
	CPI  R30,LOW(0x4)
	LDI  R26,HIGH(0x4)
	CPC  R31,R26
	BRNE _0x2D8
	SBI  0x15,1
; 0000 083D         break;
	RJMP _0x2CB
; 0000 083E         case 5:  digit6();
_0x2D8:
	CPI  R30,LOW(0x5)
	LDI  R26,HIGH(0x5)
	CPC  R31,R26
	BRNE _0x2DB
	SBI  0x15,2
; 0000 083F         break;
	RJMP _0x2CB
; 0000 0840         case 6:  digit7();
_0x2DB:
	CPI  R30,LOW(0x6)
	LDI  R26,HIGH(0x6)
	CPC  R31,R26
	BRNE _0x2DE
	SBI  0x15,3
; 0000 0841         break;
	RJMP _0x2CB
; 0000 0842         case 7:  digit8();
_0x2DE:
	CPI  R30,LOW(0x7)
	LDI  R26,HIGH(0x7)
	CPC  R31,R26
	BRNE _0x2E1
	SBI  0x15,4
; 0000 0843         break;
	RJMP _0x2CB
; 0000 0844         case 8: PORTA = led_status;
_0x2E1:
	CPI  R30,LOW(0x8)
	LDI  R26,HIGH(0x8)
	CPC  R31,R26
	BRNE _0x2E4
	OUT  0x1B,R4
; 0000 0845                 digit9();
	SBI  0x18,6
; 0000 0846                 break;
	RJMP _0x2CB
; 0000 0847         case 9: PORTA = led_status1;
_0x2E4:
	CPI  R30,LOW(0x9)
	LDI  R26,HIGH(0x9)
	CPC  R31,R26
	BRNE _0x2CB
	OUT  0x1B,R6
; 0000 0848                 digit10();
	SBI  0x18,7
; 0000 0849         break;
; 0000 084A         }
_0x2CB:
; 0000 084B 
; 0000 084C //display_put(process_value[0],process_value[1],0,dummy,dummy2);                       //**
; 0000 084D 
; 0000 084E 
; 0000 084F }
	LDD  R17,Y+1
	LDD  R16,Y+0
	ADIW R28,4
	RET
; .FEND
;
;
;
;
;void key_check()
; 0000 0855 {
_key_check:
; .FSTART _key_check
; 0000 0856      key1 = key2 = key3 = key4 = 1;
	SBI  0x16,5
	SBI  0x16,4
	SBI  0x16,3
	SBI  0x16,2
; 0000 0857       key_count++;
	LDI  R26,LOW(_key_count)
	LDI  R27,HIGH(_key_count)
	LD   R30,X+
	LD   R31,X+
	ADIW R30,1
	ST   -X,R31
	ST   -X,R30
; 0000 0858  if (key_count >=100)
	LDS  R26,_key_count
	LDS  R27,_key_count+1
	CPI  R26,LOW(0x64)
	LDI  R30,HIGH(0x64)
	CPC  R27,R30
	BRLT _0x2F2
; 0000 0859     {
; 0000 085A       key_count=0;
	LDI  R30,LOW(0)
	STS  _key_count,R30
	STS  _key_count+1,R30
; 0000 085B       if (!key1 && key1_old)ent_key();
	SBIC 0x16,2
	RJMP _0x2F4
	SBRC R3,0
	RJMP _0x2F5
_0x2F4:
	RJMP _0x2F3
_0x2F5:
	CALL _ent_key
; 0000 085C       if (!key2 && key2_old)inc_key();
_0x2F3:
	SBIC 0x16,3
	RJMP _0x2F7
	SBRC R3,1
	RJMP _0x2F8
_0x2F7:
	RJMP _0x2F6
_0x2F8:
	CALL _inc_key
; 0000 085D       if (!key3 && key3_old)dec_key();
_0x2F6:
	SBIC 0x16,4
	RJMP _0x2FA
	SBRC R3,2
	RJMP _0x2FB
_0x2FA:
	RJMP _0x2F9
_0x2FB:
	CALL _dec_key
; 0000 085E       if (!key4 && key4_old)shf_key();
_0x2F9:
	SBIC 0x16,5
	RJMP _0x2FD
	SBRC R3,3
	RJMP _0x2FE
_0x2FD:
	RJMP _0x2FC
_0x2FE:
	CALL _shf_key
; 0000 085F       key1_old = key1;
_0x2FC:
	CLT
	SBIC 0x16,2
	SET
	BLD  R3,0
; 0000 0860       key2_old = key2;
	CLT
	SBIC 0x16,3
	SET
	BLD  R3,1
; 0000 0861       key3_old = key3;
	CLT
	SBIC 0x16,4
	SET
	BLD  R3,2
; 0000 0862       key4_old = key4;
	CLT
	SBIC 0x16,5
	SET
	BLD  R3,3
; 0000 0863      }
; 0000 0864 }
_0x2F2:
	RET
; .FEND
;
;void eeprom_transfer(void)
; 0000 0867 {
_eeprom_transfer:
; .FSTART _eeprom_transfer
; 0000 0868 short int i;
; 0000 0869 for(i=0;i<8;i++)
	ST   -Y,R17
	ST   -Y,R16
;	i -> R16,R17
	__GETWRN 16,17,0
_0x300:
	__CPWRN 16,17,8
	BRGE _0x301
; 0000 086A     {
; 0000 086B     cal_zero[i] = ee_cal_zero[i];
	MOVW R30,R16
	LDI  R26,LOW(_cal_zero)
	LDI  R27,HIGH(_cal_zero)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	MOVW R0,R30
	MOVW R30,R16
	LDI  R26,LOW(_ee_cal_zero)
	LDI  R27,HIGH(_ee_cal_zero)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __EEPROMRDW
	MOVW R26,R0
	ST   X+,R30
	ST   X,R31
; 0000 086C     }
	__ADDWRN 16,17,1
	RJMP _0x300
_0x301:
; 0000 086D for(i=0;i<8;i++)
	__GETWRN 16,17,0
_0x303:
	__CPWRN 16,17,8
	BRGE _0x304
; 0000 086E     {
; 0000 086F     cal_span[i] = ee_cal_span[i];
	MOVW R30,R16
	LDI  R26,LOW(_cal_span)
	LDI  R27,HIGH(_cal_span)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	MOVW R0,R30
	MOVW R30,R16
	LDI  R26,LOW(_ee_cal_span)
	LDI  R27,HIGH(_ee_cal_span)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __EEPROMRDW
	MOVW R26,R0
	ST   X+,R30
	ST   X,R31
; 0000 0870     }
	__ADDWRN 16,17,1
	RJMP _0x303
_0x304:
; 0000 0871 for(i=0;i<3;i++)
	__GETWRN 16,17,0
_0x306:
	__CPWRN 16,17,3
	BRGE _0x307
; 0000 0872     {
; 0000 0873     gen[i] = ee_gen[i];
	MOVW R30,R16
	LDI  R26,LOW(_gen)
	LDI  R27,HIGH(_gen)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	MOVW R0,R30
	MOVW R30,R16
	LDI  R26,LOW(_ee_gen)
	LDI  R27,HIGH(_ee_gen)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __EEPROMRDW
	MOVW R26,R0
	ST   X+,R30
	ST   X,R31
; 0000 0874     }
	__ADDWRN 16,17,1
	RJMP _0x306
_0x307:
; 0000 0875 for(i=0;i<8;i++)
	__GETWRN 16,17,0
_0x309:
	__CPWRN 16,17,8
	BRGE _0x30A
; 0000 0876     {
; 0000 0877     os[i] = ee_os[i];
	MOVW R30,R16
	LDI  R26,LOW(_os)
	LDI  R27,HIGH(_os)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	MOVW R0,R30
	MOVW R30,R16
	LDI  R26,LOW(_ee_os)
	LDI  R27,HIGH(_ee_os)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __EEPROMRDW
	MOVW R26,R0
	ST   X+,R30
	ST   X,R31
; 0000 0878     }
	__ADDWRN 16,17,1
	RJMP _0x309
_0x30A:
; 0000 0879 for(i=0;i<8;i++)
	__GETWRN 16,17,0
_0x30C:
	__CPWRN 16,17,8
	BRGE _0x30D
; 0000 087A     {
; 0000 087B     skip[i] = ee_skip[i];
	MOVW R30,R16
	LDI  R26,LOW(_skip)
	LDI  R27,HIGH(_skip)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	MOVW R0,R30
	MOVW R30,R16
	LDI  R26,LOW(_ee_skip)
	LDI  R27,HIGH(_ee_skip)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __EEPROMRDW
	MOVW R26,R0
	ST   X+,R30
	ST   X,R31
; 0000 087C     }
	__ADDWRN 16,17,1
	RJMP _0x30C
_0x30D:
; 0000 087D for(i=0;i<8;i++)
	__GETWRN 16,17,0
_0x30F:
	__CPWRN 16,17,8
	BRGE _0x310
; 0000 087E     {
; 0000 087F     rlow[i] = ee_rlow[i];
	MOVW R30,R16
	LDI  R26,LOW(_rlow)
	LDI  R27,HIGH(_rlow)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	MOVW R0,R30
	MOVW R30,R16
	LDI  R26,LOW(_ee_rlow)
	LDI  R27,HIGH(_ee_rlow)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __EEPROMRDW
	MOVW R26,R0
	ST   X+,R30
	ST   X,R31
; 0000 0880     }
	__ADDWRN 16,17,1
	RJMP _0x30F
_0x310:
; 0000 0881 for(i=0;i<8;i++)
	__GETWRN 16,17,0
_0x312:
	__CPWRN 16,17,8
	BRGE _0x313
; 0000 0882     {
; 0000 0883     rhigh[i] = ee_rhigh[i];
	MOVW R30,R16
	LDI  R26,LOW(_rhigh)
	LDI  R27,HIGH(_rhigh)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	MOVW R0,R30
	MOVW R30,R16
	LDI  R26,LOW(_ee_rhigh)
	LDI  R27,HIGH(_ee_rhigh)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __EEPROMRDW
	MOVW R26,R0
	ST   X+,R30
	ST   X,R31
; 0000 0884     }
	__ADDWRN 16,17,1
	RJMP _0x312
_0x313:
; 0000 0885 for(i=0;i<8;i++)
	__GETWRN 16,17,0
_0x315:
	__CPWRN 16,17,8
	BRGE _0x316
; 0000 0886     {
; 0000 0887     alow[i] = ee_alow[i];
	MOVW R30,R16
	LDI  R26,LOW(_alow)
	LDI  R27,HIGH(_alow)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	MOVW R0,R30
	MOVW R30,R16
	LDI  R26,LOW(_ee_alow)
	LDI  R27,HIGH(_ee_alow)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __EEPROMRDW
	MOVW R26,R0
	ST   X+,R30
	ST   X,R31
; 0000 0888     }
	__ADDWRN 16,17,1
	RJMP _0x315
_0x316:
; 0000 0889 for(i=0;i<8;i++)
	__GETWRN 16,17,0
_0x318:
	__CPWRN 16,17,8
	BRGE _0x319
; 0000 088A     {
; 0000 088B     ahigh[i] = ee_ahigh[i];
	MOVW R30,R16
	LDI  R26,LOW(_ahigh)
	LDI  R27,HIGH(_ahigh)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	MOVW R0,R30
	MOVW R30,R16
	LDI  R26,LOW(_ee_ahigh)
	LDI  R27,HIGH(_ee_ahigh)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __EEPROMRDW
	MOVW R26,R0
	ST   X+,R30
	ST   X,R31
; 0000 088C     }
	__ADDWRN 16,17,1
	RJMP _0x318
_0x319:
; 0000 088D for(i=0;i<8;i++)
	__GETWRN 16,17,0
_0x31B:
	__CPWRN 16,17,8
	BRGE _0x31C
; 0000 088E     {
; 0000 088F     input[i] = ee_input[i];
	MOVW R30,R16
	LDI  R26,LOW(_input)
	LDI  R27,HIGH(_input)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	MOVW R0,R30
	MOVW R30,R16
	LDI  R26,LOW(_ee_input)
	LDI  R27,HIGH(_ee_input)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __EEPROMRDW
	MOVW R26,R0
	ST   X+,R30
	ST   X,R31
; 0000 0890     }
	__ADDWRN 16,17,1
	RJMP _0x31B
_0x31C:
; 0000 0891 for(i=0;i<8;i++)
	__GETWRN 16,17,0
_0x31E:
	__CPWRN 16,17,8
	BRGE _0x31F
; 0000 0892     {
; 0000 0893     dp[i] = ee_dp[i];
	MOVW R30,R16
	LDI  R26,LOW(_dp)
	LDI  R27,HIGH(_dp)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	MOVW R0,R30
	MOVW R30,R16
	LDI  R26,LOW(_ee_dp)
	LDI  R27,HIGH(_ee_dp)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __EEPROMRDW
	MOVW R26,R0
	ST   X+,R30
	ST   X,R31
; 0000 0894     }
	__ADDWRN 16,17,1
	RJMP _0x31E
_0x31F:
; 0000 0895 
; 0000 0896 }
_0x2060001:
	LD   R16,Y+
	LD   R17,Y+
	RET
; .FEND
;
;// added to check if any input is tc. if so, then channel 8 is skipped for all purposes
;void tc_check()
; 0000 089A {
_tc_check:
; .FSTART _tc_check
; 0000 089B //int i;
; 0000 089C //tc_fl =0;
; 0000 089D //for (i=0;i<=7;i++)
; 0000 089E //    {
; 0000 089F //    if (input[i]>=2  && input[i] <=6) tc_fl =1;
; 0000 08A0 //    }
; 0000 08A1 //if (tc_fl) skip[7] = ee_skip[7] = 1;    //force skip channel 8
; 0000 08A2 tc_fl =1;
	SET
	BLD  R2,1
; 0000 08A3 }
	RET
; .FEND
;
;void init(void)
; 0000 08A6 {
_init:
; .FSTART _init
; 0000 08A7 // Input/Output Ports initialization
; 0000 08A8 // Port A initialization
; 0000 08A9 // Function: Bit7=Out Bit6=Out Bit5=Out Bit4=Out Bit3=Out Bit2=Out Bit1=Out Bit0=Out
; 0000 08AA DDRA=(1<<DDA7) | (1<<DDA6) | (1<<DDA5) | (1<<DDA4) | (1<<DDA3) | (1<<DDA2) | (1<<DDA1) | (1<<DDA0);
	LDI  R30,LOW(255)
	OUT  0x1A,R30
; 0000 08AB // State: Bit7=1 Bit6=1 Bit5=1 Bit4=1 Bit3=1 Bit2=1 Bit1=1 Bit0=1
; 0000 08AC PORTA=(1<<PORTA7) | (1<<PORTA6) | (1<<PORTA5) | (1<<PORTA4) | (1<<PORTA3) | (1<<PORTA2) | (1<<PORTA1) | (1<<PORTA0);
	OUT  0x1B,R30
; 0000 08AD 
; 0000 08AE // Port B initialization
; 0000 08AF // Function: Bit7=Out Bit6=Out Bit5=In Bit4=In Bit3=In Bit2=In Bit1=Out Bit0=Out
; 0000 08B0 DDRB=(1<<DDB7) | (1<<DDB6) | (0<<DDB5) | (0<<DDB4) | (0<<DDB3) | (0<<DDB2) | (1<<DDB1) | (1<<DDB0);
	LDI  R30,LOW(195)
	OUT  0x17,R30
; 0000 08B1 // State: Bit7=1 Bit6=1 Bit5=P Bit4=P Bit3=P Bit2=P Bit1=1 Bit0=1
; 0000 08B2 PORTB=(1<<PORTB7) | (1<<PORTB6) | (1<<PORTB5) | (1<<PORTB4) | (1<<PORTB3) | (1<<PORTB2) | (1<<PORTB1) | (1<<PORTB0);
	LDI  R30,LOW(255)
	OUT  0x18,R30
; 0000 08B3 
; 0000 08B4 // Port C initialization
; 0000 08B5 // Function: Bit7=Out Bit6=Out Bit5=Out Bit4=Out Bit3=Out Bit2=Out Bit1=Out Bit0=Out
; 0000 08B6 DDRC=(1<<DDC7) | (1<<DDC6) | (1<<DDC5) | (1<<DDC4) | (1<<DDC3) | (1<<DDC2) | (1<<DDC1) | (1<<DDC0);
	OUT  0x14,R30
; 0000 08B7 // State: Bit7=1 Bit6=1 Bit5=1 Bit4=1 Bit3=1 Bit2=1 Bit1=1 Bit0=1
; 0000 08B8 PORTC=(1<<PORTC7) | (1<<PORTC6) | (1<<PORTC5) | (1<<PORTC4) | (1<<PORTC3) | (1<<PORTC2) | (1<<PORTC1) | (1<<PORTC0);
	OUT  0x15,R30
; 0000 08B9 
; 0000 08BA // Port D initialization
; 0000 08BB // Function: Bit7=Out Bit6=Out Bit5=Out Bit4=Out Bit3=Out Bit2=Out Bit1=Out Bit0=Out
; 0000 08BC DDRD=(1<<DDD7) | (1<<DDD6) | (1<<DDD5) | (1<<DDD4) | (1<<DDD3) | (1<<DDD2) | (1<<DDD1) | (1<<DDD0);
	OUT  0x11,R30
; 0000 08BD // State: Bit7=1 Bit6=1 Bit5=1 Bit4=1 Bit3=1 Bit2=1 Bit1=1 Bit0=1
; 0000 08BE PORTD=(1<<PORTD7) | (1<<PORTD6) | (1<<PORTD5) | (1<<PORTD4) | (1<<PORTD3) | (1<<PORTD2) | (1<<PORTD1) | (1<<PORTD0);
	OUT  0x12,R30
; 0000 08BF 
; 0000 08C0 // Timer/Counter 0 initialization
; 0000 08C1 // Clock source: System Clock
; 0000 08C2 // Clock value: Timer 0 Stopped
; 0000 08C3 // Mode: Normal top=0xFF
; 0000 08C4 // OC0 output: Disconnected
; 0000 08C5 TCCR0=(0<<WGM00) | (0<<COM01) | (0<<COM00) | (0<<WGM01) | (0<<CS02) | (0<<CS01) | (0<<CS00);
	LDI  R30,LOW(0)
	OUT  0x33,R30
; 0000 08C6 TCNT0=0x00;
	OUT  0x32,R30
; 0000 08C7 OCR0=0x00;
	OUT  0x3C,R30
; 0000 08C8 
; 0000 08C9 // Timer/Counter 1 initialization
; 0000 08CA // Clock source: System Clock
; 0000 08CB // Clock value: 172.800 kHz
; 0000 08CC // Mode: Normal top=0xFFFF
; 0000 08CD // OC1A output: Disconnected
; 0000 08CE // OC1B output: Disconnected
; 0000 08CF // Noise Canceler: Off
; 0000 08D0 // Input Capture on Falling Edge
; 0000 08D1 // Timer Period: 0.5 s
; 0000 08D2 // Timer1 Overflow Interrupt: On
; 0000 08D3 // Input Capture Interrupt: Off
; 0000 08D4 // Compare A Match Interrupt: Off
; 0000 08D5 // Compare B Match Interrupt: Off
; 0000 08D6 TCCR1A=(0<<COM1A1) | (0<<COM1A0) | (0<<COM1B1) | (0<<COM1B0) | (0<<WGM11) | (0<<WGM10);
	OUT  0x2F,R30
; 0000 08D7 TCCR1B=(0<<ICNC1) | (0<<ICES1) | (0<<WGM13) | (0<<WGM12) | (1<<CS12) | (0<<CS11) | (0<<CS10);
	LDI  R30,LOW(4)
	OUT  0x2E,R30
; 0000 08D8 TCNT1H=0xAB;
	LDI  R30,LOW(171)
	OUT  0x2D,R30
; 0000 08D9 TCNT1L=0xA0;
	LDI  R30,LOW(160)
	OUT  0x2C,R30
; 0000 08DA ICR1H=0x00;
	LDI  R30,LOW(0)
	OUT  0x27,R30
; 0000 08DB ICR1L=0x00;
	OUT  0x26,R30
; 0000 08DC OCR1AH=0x00;
	OUT  0x2B,R30
; 0000 08DD OCR1AL=0x00;
	OUT  0x2A,R30
; 0000 08DE OCR1BH=0x00;
	OUT  0x29,R30
; 0000 08DF OCR1BL=0x00;
	OUT  0x28,R30
; 0000 08E0 
; 0000 08E1 // Timer/Counter 2 initialization
; 0000 08E2 // Clock source: System Clock
; 0000 08E3 // Clock value: Timer2 Stopped
; 0000 08E4 // Mode: Normal top=0xFF
; 0000 08E5 // OC2 output: Disconnected
; 0000 08E6 ASSR=0<<AS2;
	OUT  0x22,R30
; 0000 08E7 TCCR2=(0<<PWM2) | (0<<COM21) | (0<<COM20) | (0<<CTC2) | (0<<CS22) | (0<<CS21) | (0<<CS20);
	OUT  0x25,R30
; 0000 08E8 TCNT2=0x00;
	OUT  0x24,R30
; 0000 08E9 OCR2=0x00;
	OUT  0x23,R30
; 0000 08EA 
; 0000 08EB // Timer(s)/Counter(s) Interrupt(s) initialization
; 0000 08EC TIMSK=(0<<OCIE2) | (0<<TOIE2) | (0<<TICIE1) | (0<<OCIE1A) | (0<<OCIE1B) | (1<<TOIE1) | (0<<OCIE0) | (0<<TOIE0);
	LDI  R30,LOW(4)
	OUT  0x39,R30
; 0000 08ED 
; 0000 08EE // External Interrupt(s) initialization
; 0000 08EF // INT0: Off
; 0000 08F0 // INT1: Off
; 0000 08F1 // INT2: Off
; 0000 08F2 MCUCR=(0<<ISC11) | (0<<ISC10) | (0<<ISC01) | (0<<ISC00);
	LDI  R30,LOW(0)
	OUT  0x35,R30
; 0000 08F3 MCUCSR=(0<<ISC2);
	OUT  0x34,R30
; 0000 08F4 
; 0000 08F5 // USART initialization
; 0000 08F6 // Communication Parameters: 8 Data, 1 Stop, No Parity
; 0000 08F7 // USART Receiver: On
; 0000 08F8 // USART Transmitter: On
; 0000 08F9 // USART Mode: Asynchronous
; 0000 08FA // USART Baud Rate: 9600 (Double Speed Mode)
; 0000 08FB UCSRA=(0<<RXC) | (0<<TXC) | (0<<UDRE) | (0<<FE) | (0<<DOR) | (0<<UPE) | (1<<U2X) | (0<<MPCM);
	LDI  R30,LOW(2)
	OUT  0xB,R30
; 0000 08FC UCSRB=(1<<RXCIE) | (1<<TXCIE) | (0<<UDRIE) | (1<<RXEN) | (1<<TXEN) | (0<<UCSZ2) | (0<<RXB8) | (0<<TXB8);
	LDI  R30,LOW(216)
	OUT  0xA,R30
; 0000 08FD UCSRC=(1<<URSEL) | (0<<UMSEL) | (0<<UPM1) | (0<<UPM0) | (0<<USBS) | (1<<UCSZ1) | (1<<UCSZ0) | (0<<UCPOL);
	LDI  R30,LOW(134)
	OUT  0x20,R30
; 0000 08FE UBRRH=0x00;
	LDI  R30,LOW(0)
	OUT  0x20,R30
; 0000 08FF UBRRL=0x8F;
	LDI  R30,LOW(143)
	OUT  0x9,R30
; 0000 0900 
; 0000 0901 // Analog Comparator initialization
; 0000 0902 // Analog Comparator: Off
; 0000 0903 // The Analog Comparator's positive input is
; 0000 0904 // connected to the AIN0 pin
; 0000 0905 // The Analog Comparator's negative input is
; 0000 0906 // connected to the AIN1 pin
; 0000 0907 ACSR=(1<<ACD) | (0<<ACBG) | (0<<ACO) | (0<<ACI) | (0<<ACIE) | (0<<ACIC) | (0<<ACIS1) | (0<<ACIS0);
	LDI  R30,LOW(128)
	OUT  0x8,R30
; 0000 0908 SFIOR=(0<<ACME);
	LDI  R30,LOW(0)
	OUT  0x30,R30
; 0000 0909 
; 0000 090A // ADC initialization
; 0000 090B // ADC disabled
; 0000 090C ADCSRA=(0<<ADEN) | (0<<ADSC) | (0<<ADATE) | (0<<ADIF) | (0<<ADIE) | (0<<ADPS2) | (0<<ADPS1) | (0<<ADPS0);
	OUT  0x6,R30
; 0000 090D 
; 0000 090E // SPI initialization
; 0000 090F // SPI disabled
; 0000 0910 SPCR=(0<<SPIE) | (0<<SPE) | (0<<DORD) | (0<<MSTR) | (0<<CPOL) | (0<<CPHA) | (0<<SPR1) | (0<<SPR0);
	OUT  0xD,R30
; 0000 0911 
; 0000 0912 // TWI initialization
; 0000 0913 // TWI disabled
; 0000 0914 TWCR=(0<<TWEA) | (0<<TWSTA) | (0<<TWSTO) | (0<<TWEN) | (0<<TWIE);
	OUT  0x36,R30
; 0000 0915 
; 0000 0916 // Bit-Banged I2C Bus initialization
; 0000 0917 // I2C Port: PORTB
; 0000 0918 // I2C SDA bit: 1
; 0000 0919 // I2C SCL bit: 0
; 0000 091A // Bit Rate: 100 kHz
; 0000 091B // Note: I2C settings are specified in the
; 0000 091C // Project|Configure|C Compiler|Libraries|I2C menu.
; 0000 091D i2c_init();
	CALL _i2c_init
; 0000 091E delay_ms(250);
	LDI  R26,LOW(250)
	LDI  R27,0
	CALL _delay_ms
; 0000 091F adc3421_init();
	CALL _adc3421_init
; 0000 0920 delay_ms(250);
	LDI  R26,LOW(250)
	LDI  R27,0
	CALL _delay_ms
; 0000 0921 
; 0000 0922 // Global enable interrupts
; 0000 0923 #asm("sei")
	sei
; 0000 0924 }
	RET
; .FEND
;
;void main(void)
; 0000 0927 {
_main:
; .FSTART _main
; 0000 0928 // Declare your local variables here
; 0000 0929 
; 0000 092A 
; 0000 092B init();
	RCALL _init
; 0000 092C eeprom_transfer();
	RCALL _eeprom_transfer
; 0000 092D //change serial speed according to value set
; 0000 092E if (gen[2] ==0)    ///9600 baud
	__GETW1MN _gen,4
	SBIW R30,0
	BREQ _0x348
; 0000 092F {
; 0000 0930 UBRRH=0x00;
; 0000 0931 UBRRL=0x8F;
; 0000 0932 }
; 0000 0933 else if (gen[2] ==1)   //19200 baud
	__GETW1MN _gen,4
	CPI  R30,LOW(0x1)
	LDI  R26,HIGH(0x1)
	CPC  R31,R26
	BRNE _0x322
; 0000 0934 {
; 0000 0935 UBRRH=0x00;
	LDI  R30,LOW(0)
	OUT  0x20,R30
; 0000 0936 UBRRL=0x47;
	LDI  R30,LOW(71)
	RJMP _0x349
; 0000 0937 }
; 0000 0938 else if (gen[2] ==2)   //38400 baud
_0x322:
	__GETW1MN _gen,4
	CPI  R30,LOW(0x2)
	LDI  R26,HIGH(0x2)
	CPC  R31,R26
	BRNE _0x324
; 0000 0939 {
; 0000 093A UBRRH=0x00;
	LDI  R30,LOW(0)
	OUT  0x20,R30
; 0000 093B UBRRL=0x23;
	LDI  R30,LOW(35)
	RJMP _0x349
; 0000 093C }
; 0000 093D else if (gen[2] ==3)   //115200 baud
_0x324:
	__GETW1MN _gen,4
	CPI  R30,LOW(0x3)
	LDI  R26,HIGH(0x3)
	CPC  R31,R26
	BRNE _0x326
; 0000 093E {
; 0000 093F UBRRH=0x00;
	LDI  R30,LOW(0)
	OUT  0x20,R30
; 0000 0940 UBRRL=0x0b;
	LDI  R30,LOW(11)
	RJMP _0x349
; 0000 0941 }
; 0000 0942 else                    //force to default 9600 baud if not above
_0x326:
; 0000 0943 {
; 0000 0944 gen[2]=0;
	__POINTW1MN _gen,4
	LDI  R26,LOW(0)
	LDI  R27,HIGH(0)
	STD  Z+0,R26
	STD  Z+1,R27
; 0000 0945 UBRRH=0x00;
_0x348:
	LDI  R30,LOW(0)
	OUT  0x20,R30
; 0000 0946 UBRRL=0x8F;
	LDI  R30,LOW(143)
_0x349:
	OUT  0x9,R30
; 0000 0947 }
; 0000 0948 
; 0000 0949 cal_fl =0;
	CLT
	BLD  R3,5
; 0000 094A if (!key5) cal_fl =1;
	SBIC 0x16,2
	RJMP _0x328
	SET
	BLD  R3,5
; 0000 094B mb_dir =0;
_0x328:
	CBI  0x12,2
; 0000 094C while (1)
_0x32B:
; 0000 094D       {
; 0000 094E       // Place your code here
; 0000 094F       set_fixed_values();
	CALL _set_fixed_values
; 0000 0950 
; 0000 0951       display_check();
	RCALL _display_check
; 0000 0952       display_out(display_count);
	MOVW R26,R8
	RCALL _display_out
; 0000 0953       display_count++;
	MOVW R30,R8
	ADIW R30,1
	MOVW R8,R30
; 0000 0954       led_check();
	CALL _led_check
; 0000 0955       relay_logic();
	CALL _relay_logic
; 0000 0956              key_check();
	RCALL _key_check
; 0000 0957       tc_check();
	RCALL _tc_check
; 0000 0958       if(display_count >=10)
	LDI  R30,LOW(10)
	LDI  R31,HIGH(10)
	CP   R8,R30
	CPC  R9,R31
	BRLT _0x32E
; 0000 0959       {
; 0000 095A        display_count =0;
	CLR  R8
	CLR  R9
; 0000 095B        if (hsec_fl)
	SBRS R2,7
	RJMP _0x32F
; 0000 095C         {
; 0000 095D         hsec_fl =0;
	CLT
	BLD  R2,7
; 0000 095E         pv_update();
	CALL _pv_update
; 0000 095F         check_set();
	CALL _check_set
; 0000 0960         if (modbus_fl)
	SBRS R2,0
	RJMP _0x330
; 0000 0961             {
; 0000 0962             modbus_fl =0;
	CLT
	BLD  R2,0
; 0000 0963             mb_datatransfer();
	CALL _mb_datatransfer
; 0000 0964             check_mbreceived();
	CALL _check_mbreceived
; 0000 0965  //           delay_ms(100);
; 0000 0966 //            mb_dir =0;      //set to receieve
; 0000 0967             }
; 0000 0968        if (ser_fl)
_0x330:
	SBRS R3,6
	RJMP _0x331
; 0000 0969         {
; 0000 096A         ser_fl =0;
	CLT
	BLD  R3,6
; 0000 096B //        mb_dir =0;
; 0000 096C //        delay_ms(2);
; 0000 096D //        printf("%5u %5u %5u %5u %5u %5u %5u %5u\n",process_value[0],process_value[1],process_value[2],process_value[3] ...
; 0000 096E //        mb_dir =1;
; 0000 096F         }
; 0000 0970       }
_0x331:
; 0000 0971 //      process_value[0] =1234;
; 0000 0972 //      process_value[1] = 5678;
; 0000 0973       }
_0x32F:
; 0000 0974 }
_0x32E:
	RJMP _0x32B
; 0000 0975 }
_0x332:
	RJMP _0x332
; .FEND
	#ifndef __SLEEP_DEFINED__
	#define __SLEEP_DEFINED__
	.EQU __se_bit=0x80
	.EQU __sm_mask=0x70
	.EQU __sm_powerdown=0x20
	.EQU __sm_powersave=0x30
	.EQU __sm_standby=0x60
	.EQU __sm_ext_standby=0x70
	.EQU __sm_adc_noise_red=0x10
	.SET power_ctrl_reg=mcucr
	#endif

	.CSEG

	.CSEG

	.CSEG

	.DSEG
_display_buffer:
	.BYTE 0x14
_dummy:
	.BYTE 0x2
_dummy2:
	.BYTE 0x2
_process_value:
	.BYTE 0x10
_gen:
	.BYTE 0x10

	.ESEG
_ee_gen:
	.DB  0x1,0x0,0x1,0x0
	.DB  0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0

	.DSEG
_os:
	.BYTE 0x10

	.ESEG
_ee_os:
	.DB  0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0

	.DSEG
_skip:
	.BYTE 0x10

	.ESEG
_ee_skip:
	.DB  0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0

	.DSEG
_rlow:
	.BYTE 0x10

	.ESEG
_ee_rlow:
	.DB  0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0

	.DSEG
_rhigh:
	.BYTE 0x10

	.ESEG
_ee_rhigh:
	.DB  0x64,0x0,0x64,0x0
	.DB  0x64,0x0,0x64,0x0
	.DB  0x64,0x0,0x64,0x0
	.DB  0x64,0x0,0x64,0x0

	.DSEG
_alow:
	.BYTE 0x10

	.ESEG
_ee_alow:
	.DB  0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0

	.DSEG
_ahigh:
	.BYTE 0x10

	.ESEG
_ee_ahigh:
	.DB  0x64,0x0,0x64,0x0
	.DB  0x64,0x0,0x64,0x0
	.DB  0x64,0x0,0x64,0x0
	.DB  0x64,0x0,0x64,0x0

	.DSEG
_input:
	.BYTE 0x10

	.ESEG
_ee_input:
	.DB  0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0

	.DSEG
_dp:
	.BYTE 0x10

	.ESEG
_ee_dp:
	.DB  0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0

	.DSEG
_cal_zero:
	.BYTE 0x10

	.ESEG
_ee_cal_zero:
	.DB  0x3C,0x28,0x3C,0x28
	.DB  0x3C,0x28,0x3C,0x28
	.DB  0x3C,0x28,0x3C,0x28
	.DB  0x3C,0x28,0x3C,0x28

	.DSEG
_cal_span:
	.BYTE 0x10

	.ESEG
_ee_cal_span:
	.DB  0x34,0x53,0x34,0x53
	.DB  0x34,0x53,0x34,0x53
	.DB  0x34,0x53,0x34,0x53
	.DB  0x34,0x53,0x34,0x53

	.DSEG
_rx_buffer:
	.BYTE 0x14
_rx_wr_index:
	.BYTE 0x1
_rx_rd_index:
	.BYTE 0x1
_rx_counter:
	.BYTE 0x1
_mbreceived_data:
	.BYTE 0xA
_tx_buffer:
	.BYTE 0x30
_tx_wr_index:
	.BYTE 0x1
_tx_rd_index:
	.BYTE 0x1
_tx_counter:
	.BYTE 0x1
_segment_table:
	.BYTE 0x25
_blink_digit:
	.BYTE 0x2
_mux_scan:
	.BYTE 0x2
_tsec_cnt:
	.BYTE 0x2
_key_count:
	.BYTE 0x2
_menu_count:
	.BYTE 0x2
_item1:
	.BYTE 0x2
_item2:
	.BYTE 0x2
_level:
	.BYTE 0x2
_ms_menu:
	.BYTE 0x8
_message_menu:
	.BYTE 0x48
_message_gen:
	.BYTE 0x18
_message_os:
	.BYTE 0x40
_message_skip:
	.BYTE 0x40
_message_rlow:
	.BYTE 0x40
_message_rhigh:
	.BYTE 0x40
_message_alow:
	.BYTE 0x40
_message_ahigh:
	.BYTE 0x40
_message_in:
	.BYTE 0x40
_message_dp:
	.BYTE 0x40
_process_error:
	.BYTE 0x10
_message_skuk:
	.BYTE 0x10
_message_inp:
	.BYTE 0x48
_message_baud:
	.BYTE 0x20
_message_cal:
	.BYTE 0x40
_message_dp1:
	.BYTE 0x20
_message_neg:
	.BYTE 0x8
_message_open:
	.BYTE 0x8
_table_p:
	.BYTE 0x26
_table_j:
	.BYTE 0x1E
_table_k:
	.BYTE 0x38
_table_r:
	.BYTE 0x48
_table_s:
	.BYTE 0x48
_table_t:
	.BYTE 0x18
_mb_data:
	.BYTE 0x72
_mb_inputdata:
	.BYTE 0x2A

	.CSEG

	.CSEG
	.equ __sda_bit=1
	.equ __scl_bit=0
	.equ __i2c_port=0x18 ;PORTB
	.equ __i2c_dir=__i2c_port-1
	.equ __i2c_pin=__i2c_port-2

_i2c_init:
	cbi  __i2c_port,__scl_bit
	cbi  __i2c_port,__sda_bit
	sbi  __i2c_dir,__scl_bit
	cbi  __i2c_dir,__sda_bit
	rjmp __i2c_delay2
_i2c_start:
	cbi  __i2c_dir,__sda_bit
	cbi  __i2c_dir,__scl_bit
	clr  r30
	nop
	sbis __i2c_pin,__sda_bit
	ret
	sbis __i2c_pin,__scl_bit
	ret
	rcall __i2c_delay1
	sbi  __i2c_dir,__sda_bit
	rcall __i2c_delay1
	sbi  __i2c_dir,__scl_bit
	ldi  r30,1
__i2c_delay1:
	ldi  r22,18
	rjmp __i2c_delay2l
_i2c_stop:
	sbi  __i2c_dir,__sda_bit
	sbi  __i2c_dir,__scl_bit
	rcall __i2c_delay2
	cbi  __i2c_dir,__scl_bit
	rcall __i2c_delay1
	cbi  __i2c_dir,__sda_bit
__i2c_delay2:
	ldi  r22,37
__i2c_delay2l:
	dec  r22
	brne __i2c_delay2l
	ret
_i2c_read:
	ldi  r23,8
__i2c_read0:
	cbi  __i2c_dir,__scl_bit
	rcall __i2c_delay1
__i2c_read3:
	sbis __i2c_pin,__scl_bit
	rjmp __i2c_read3
	rcall __i2c_delay1
	clc
	sbic __i2c_pin,__sda_bit
	sec
	sbi  __i2c_dir,__scl_bit
	rcall __i2c_delay2
	rol  r30
	dec  r23
	brne __i2c_read0
	mov  r23,r26
	tst  r23
	brne __i2c_read1
	cbi  __i2c_dir,__sda_bit
	rjmp __i2c_read2
__i2c_read1:
	sbi  __i2c_dir,__sda_bit
__i2c_read2:
	rcall __i2c_delay1
	cbi  __i2c_dir,__scl_bit
	rcall __i2c_delay2
	sbi  __i2c_dir,__scl_bit
	rcall __i2c_delay1
	cbi  __i2c_dir,__sda_bit
	rjmp __i2c_delay1

_i2c_write:
	ldi  r23,8
__i2c_write0:
	lsl  r26
	brcc __i2c_write1
	cbi  __i2c_dir,__sda_bit
	rjmp __i2c_write2
__i2c_write1:
	sbi  __i2c_dir,__sda_bit
__i2c_write2:
	rcall __i2c_delay2
	cbi  __i2c_dir,__scl_bit
	rcall __i2c_delay1
__i2c_write3:
	sbis __i2c_pin,__scl_bit
	rjmp __i2c_write3
	rcall __i2c_delay1
	sbi  __i2c_dir,__scl_bit
	dec  r23
	brne __i2c_write0
	cbi  __i2c_dir,__sda_bit
	rcall __i2c_delay1
	cbi  __i2c_dir,__scl_bit
	rcall __i2c_delay2
	ldi  r30,1
	sbic __i2c_pin,__sda_bit
	clr  r30
	sbi  __i2c_dir,__scl_bit
	rjmp __i2c_delay1

_delay_ms:
	adiw r26,0
	breq __delay_ms1
__delay_ms0:
	__DELAY_USW 0xACD
	wdr
	sbiw r26,1
	brne __delay_ms0
__delay_ms1:
	ret

__ROUND_REPACK:
	TST  R21
	BRPL __REPACK
	CPI  R21,0x80
	BRNE __ROUND_REPACK0
	SBRS R30,0
	RJMP __REPACK
__ROUND_REPACK0:
	ADIW R30,1
	ADC  R22,R25
	ADC  R23,R25
	BRVS __REPACK1

__REPACK:
	LDI  R21,0x80
	EOR  R21,R23
	BRNE __REPACK0
	PUSH R21
	RJMP __ZERORES
__REPACK0:
	CPI  R21,0xFF
	BREQ __REPACK1
	LSL  R22
	LSL  R0
	ROR  R21
	ROR  R22
	MOV  R23,R21
	RET
__REPACK1:
	PUSH R21
	TST  R0
	BRMI __REPACK2
	RJMP __MAXRES
__REPACK2:
	RJMP __MINRES

__UNPACK:
	LDI  R21,0x80
	MOV  R1,R25
	AND  R1,R21
	LSL  R24
	ROL  R25
	EOR  R25,R21
	LSL  R21
	ROR  R24

__UNPACK1:
	LDI  R21,0x80
	MOV  R0,R23
	AND  R0,R21
	LSL  R22
	ROL  R23
	EOR  R23,R21
	LSL  R21
	ROR  R22
	RET

__CFD1U:
	SET
	RJMP __CFD1U0
__CFD1:
	CLT
__CFD1U0:
	PUSH R21
	RCALL __UNPACK1
	CPI  R23,0x80
	BRLO __CFD10
	CPI  R23,0xFF
	BRCC __CFD10
	RJMP __ZERORES
__CFD10:
	LDI  R21,22
	SUB  R21,R23
	BRPL __CFD11
	NEG  R21
	CPI  R21,8
	BRTC __CFD19
	CPI  R21,9
__CFD19:
	BRLO __CFD17
	SER  R30
	SER  R31
	SER  R22
	LDI  R23,0x7F
	BLD  R23,7
	RJMP __CFD15
__CFD17:
	CLR  R23
	TST  R21
	BREQ __CFD15
__CFD18:
	LSL  R30
	ROL  R31
	ROL  R22
	ROL  R23
	DEC  R21
	BRNE __CFD18
	RJMP __CFD15
__CFD11:
	CLR  R23
__CFD12:
	CPI  R21,8
	BRLO __CFD13
	MOV  R30,R31
	MOV  R31,R22
	MOV  R22,R23
	SUBI R21,8
	RJMP __CFD12
__CFD13:
	TST  R21
	BREQ __CFD15
__CFD14:
	LSR  R23
	ROR  R22
	ROR  R31
	ROR  R30
	DEC  R21
	BRNE __CFD14
__CFD15:
	TST  R0
	BRPL __CFD16
	RCALL __ANEGD1
__CFD16:
	POP  R21
	RET

__CDF1U:
	SET
	RJMP __CDF1U0
__CDF1:
	CLT
__CDF1U0:
	SBIW R30,0
	SBCI R22,0
	SBCI R23,0
	BREQ __CDF10
	CLR  R0
	BRTS __CDF11
	TST  R23
	BRPL __CDF11
	COM  R0
	RCALL __ANEGD1
__CDF11:
	MOV  R1,R23
	LDI  R23,30
	TST  R1
__CDF12:
	BRMI __CDF13
	DEC  R23
	LSL  R30
	ROL  R31
	ROL  R22
	ROL  R1
	RJMP __CDF12
__CDF13:
	MOV  R30,R31
	MOV  R31,R22
	MOV  R22,R1
	PUSH R21
	RCALL __REPACK
	POP  R21
__CDF10:
	RET

__SWAPACC:
	PUSH R20
	MOVW R20,R30
	MOVW R30,R26
	MOVW R26,R20
	MOVW R20,R22
	MOVW R22,R24
	MOVW R24,R20
	MOV  R20,R0
	MOV  R0,R1
	MOV  R1,R20
	POP  R20
	RET

__UADD12:
	ADD  R30,R26
	ADC  R31,R27
	ADC  R22,R24
	RET

__NEGMAN1:
	COM  R30
	COM  R31
	COM  R22
	SUBI R30,-1
	SBCI R31,-1
	SBCI R22,-1
	RET

__SUBF12:
	PUSH R21
	RCALL __UNPACK
	CPI  R25,0x80
	BREQ __ADDF129
	LDI  R21,0x80
	EOR  R1,R21

	RJMP __ADDF120

__ADDF12:
	PUSH R21
	RCALL __UNPACK
	CPI  R25,0x80
	BREQ __ADDF129

__ADDF120:
	CPI  R23,0x80
	BREQ __ADDF128
__ADDF121:
	MOV  R21,R23
	SUB  R21,R25
	BRVS __ADDF1211
	BRPL __ADDF122
	RCALL __SWAPACC
	RJMP __ADDF121
__ADDF122:
	CPI  R21,24
	BRLO __ADDF123
	CLR  R26
	CLR  R27
	CLR  R24
__ADDF123:
	CPI  R21,8
	BRLO __ADDF124
	MOV  R26,R27
	MOV  R27,R24
	CLR  R24
	SUBI R21,8
	RJMP __ADDF123
__ADDF124:
	TST  R21
	BREQ __ADDF126
__ADDF125:
	LSR  R24
	ROR  R27
	ROR  R26
	DEC  R21
	BRNE __ADDF125
__ADDF126:
	MOV  R21,R0
	EOR  R21,R1
	BRMI __ADDF127
	RCALL __UADD12
	BRCC __ADDF129
	ROR  R22
	ROR  R31
	ROR  R30
	INC  R23
	BRVC __ADDF129
	RJMP __MAXRES
__ADDF128:
	RCALL __SWAPACC
__ADDF129:
	RCALL __REPACK
	POP  R21
	RET
__ADDF1211:
	BRCC __ADDF128
	RJMP __ADDF129
__ADDF127:
	SUB  R30,R26
	SBC  R31,R27
	SBC  R22,R24
	BREQ __ZERORES
	BRCC __ADDF1210
	COM  R0
	RCALL __NEGMAN1
__ADDF1210:
	TST  R22
	BRMI __ADDF129
	LSL  R30
	ROL  R31
	ROL  R22
	DEC  R23
	BRVC __ADDF1210

__ZERORES:
	CLR  R30
	CLR  R31
	CLR  R22
	CLR  R23
	POP  R21
	RET

__MINRES:
	SER  R30
	SER  R31
	LDI  R22,0x7F
	SER  R23
	POP  R21
	RET

__MAXRES:
	SER  R30
	SER  R31
	LDI  R22,0x7F
	LDI  R23,0x7F
	POP  R21
	RET

__MULF12:
	PUSH R21
	RCALL __UNPACK
	CPI  R23,0x80
	BREQ __ZERORES
	CPI  R25,0x80
	BREQ __ZERORES
	EOR  R0,R1
	SEC
	ADC  R23,R25
	BRVC __MULF124
	BRLT __ZERORES
__MULF125:
	TST  R0
	BRMI __MINRES
	RJMP __MAXRES
__MULF124:
	PUSH R0
	PUSH R17
	PUSH R18
	PUSH R19
	PUSH R20
	CLR  R17
	CLR  R18
	CLR  R25
	MUL  R22,R24
	MOVW R20,R0
	MUL  R24,R31
	MOV  R19,R0
	ADD  R20,R1
	ADC  R21,R25
	MUL  R22,R27
	ADD  R19,R0
	ADC  R20,R1
	ADC  R21,R25
	MUL  R24,R30
	RCALL __MULF126
	MUL  R27,R31
	RCALL __MULF126
	MUL  R22,R26
	RCALL __MULF126
	MUL  R27,R30
	RCALL __MULF127
	MUL  R26,R31
	RCALL __MULF127
	MUL  R26,R30
	ADD  R17,R1
	ADC  R18,R25
	ADC  R19,R25
	ADC  R20,R25
	ADC  R21,R25
	MOV  R30,R19
	MOV  R31,R20
	MOV  R22,R21
	MOV  R21,R18
	POP  R20
	POP  R19
	POP  R18
	POP  R17
	POP  R0
	TST  R22
	BRMI __MULF122
	LSL  R21
	ROL  R30
	ROL  R31
	ROL  R22
	RJMP __MULF123
__MULF122:
	INC  R23
	BRVS __MULF125
__MULF123:
	RCALL __ROUND_REPACK
	POP  R21
	RET

__MULF127:
	ADD  R17,R0
	ADC  R18,R1
	ADC  R19,R25
	RJMP __MULF128
__MULF126:
	ADD  R18,R0
	ADC  R19,R1
__MULF128:
	ADC  R20,R25
	ADC  R21,R25
	RET

__DIVF21:
	PUSH R21
	RCALL __UNPACK
	CPI  R23,0x80
	BRNE __DIVF210
	TST  R1
__DIVF211:
	BRPL __DIVF219
	RJMP __MINRES
__DIVF219:
	RJMP __MAXRES
__DIVF210:
	CPI  R25,0x80
	BRNE __DIVF218
__DIVF217:
	RJMP __ZERORES
__DIVF218:
	EOR  R0,R1
	SEC
	SBC  R25,R23
	BRVC __DIVF216
	BRLT __DIVF217
	TST  R0
	RJMP __DIVF211
__DIVF216:
	MOV  R23,R25
	PUSH R17
	PUSH R18
	PUSH R19
	PUSH R20
	CLR  R1
	CLR  R17
	CLR  R18
	CLR  R19
	CLR  R20
	CLR  R21
	LDI  R25,32
__DIVF212:
	CP   R26,R30
	CPC  R27,R31
	CPC  R24,R22
	CPC  R20,R17
	BRLO __DIVF213
	SUB  R26,R30
	SBC  R27,R31
	SBC  R24,R22
	SBC  R20,R17
	SEC
	RJMP __DIVF214
__DIVF213:
	CLC
__DIVF214:
	ROL  R21
	ROL  R18
	ROL  R19
	ROL  R1
	ROL  R26
	ROL  R27
	ROL  R24
	ROL  R20
	DEC  R25
	BRNE __DIVF212
	MOVW R30,R18
	MOV  R22,R1
	POP  R20
	POP  R19
	POP  R18
	POP  R17
	TST  R22
	BRMI __DIVF215
	LSL  R21
	ROL  R30
	ROL  R31
	ROL  R22
	DEC  R23
	BRVS __DIVF217
__DIVF215:
	RCALL __ROUND_REPACK
	POP  R21
	RET

__ANEGW1:
	NEG  R31
	NEG  R30
	SBCI R31,0
	RET

__ANEGD1:
	COM  R31
	COM  R22
	COM  R23
	NEG  R30
	SBCI R31,-1
	SBCI R22,-1
	SBCI R23,-1
	RET

__LSLW2:
	LSL  R30
	ROL  R31
	LSL  R30
	ROL  R31
	RET

__ASRW8:
	MOV  R30,R31
	CLR  R31
	SBRC R30,7
	SER  R31
	RET

__CWD1:
	MOV  R22,R31
	ADD  R22,R22
	SBC  R22,R22
	MOV  R23,R22
	RET

__CWD2:
	MOV  R24,R27
	ADD  R24,R24
	SBC  R24,R24
	MOV  R25,R24
	RET

__MULW12U:
	MUL  R31,R26
	MOV  R31,R0
	MUL  R30,R27
	ADD  R31,R0
	MUL  R30,R26
	MOV  R30,R0
	ADD  R31,R1
	RET

__MULD12U:
	MUL  R23,R26
	MOV  R23,R0
	MUL  R22,R27
	ADD  R23,R0
	MUL  R31,R24
	ADD  R23,R0
	MUL  R30,R25
	ADD  R23,R0
	MUL  R22,R26
	MOV  R22,R0
	ADD  R23,R1
	MUL  R31,R27
	ADD  R22,R0
	ADC  R23,R1
	MUL  R30,R24
	ADD  R22,R0
	ADC  R23,R1
	CLR  R24
	MUL  R31,R26
	MOV  R31,R0
	ADD  R22,R1
	ADC  R23,R24
	MUL  R30,R27
	ADD  R31,R0
	ADC  R22,R1
	ADC  R23,R24
	MUL  R30,R26
	MOV  R30,R0
	ADD  R31,R1
	ADC  R22,R24
	ADC  R23,R24
	RET

__MULW12:
	RCALL __CHKSIGNW
	RCALL __MULW12U
	BRTC __MULW121
	RCALL __ANEGW1
__MULW121:
	RET

__MULD12:
	RCALL __CHKSIGND
	RCALL __MULD12U
	BRTC __MULD121
	RCALL __ANEGD1
__MULD121:
	RET

__DIVW21U:
	CLR  R0
	CLR  R1
	LDI  R25,16
__DIVW21U1:
	LSL  R26
	ROL  R27
	ROL  R0
	ROL  R1
	SUB  R0,R30
	SBC  R1,R31
	BRCC __DIVW21U2
	ADD  R0,R30
	ADC  R1,R31
	RJMP __DIVW21U3
__DIVW21U2:
	SBR  R26,1
__DIVW21U3:
	DEC  R25
	BRNE __DIVW21U1
	MOVW R30,R26
	MOVW R26,R0
	RET

__DIVW21:
	RCALL __CHKSIGNW
	RCALL __DIVW21U
	BRTC __DIVW211
	RCALL __ANEGW1
__DIVW211:
	RET

__DIVD21U:
	PUSH R19
	PUSH R20
	PUSH R21
	CLR  R0
	CLR  R1
	CLR  R20
	CLR  R21
	LDI  R19,32
__DIVD21U1:
	LSL  R26
	ROL  R27
	ROL  R24
	ROL  R25
	ROL  R0
	ROL  R1
	ROL  R20
	ROL  R21
	SUB  R0,R30
	SBC  R1,R31
	SBC  R20,R22
	SBC  R21,R23
	BRCC __DIVD21U2
	ADD  R0,R30
	ADC  R1,R31
	ADC  R20,R22
	ADC  R21,R23
	RJMP __DIVD21U3
__DIVD21U2:
	SBR  R26,1
__DIVD21U3:
	DEC  R19
	BRNE __DIVD21U1
	MOVW R30,R26
	MOVW R22,R24
	MOVW R26,R0
	MOVW R24,R20
	POP  R21
	POP  R20
	POP  R19
	RET

__DIVD21:
	RCALL __CHKSIGND
	RCALL __DIVD21U
	BRTC __DIVD211
	RCALL __ANEGD1
__DIVD211:
	RET

__MODW21:
	CLT
	SBRS R27,7
	RJMP __MODW211
	COM  R26
	COM  R27
	ADIW R26,1
	SET
__MODW211:
	SBRC R31,7
	RCALL __ANEGW1
	RCALL __DIVW21U
	MOVW R30,R26
	BRTC __MODW212
	RCALL __ANEGW1
__MODW212:
	RET

__CHKSIGNW:
	CLT
	SBRS R31,7
	RJMP __CHKSW1
	RCALL __ANEGW1
	SET
__CHKSW1:
	SBRS R27,7
	RJMP __CHKSW2
	COM  R26
	COM  R27
	ADIW R26,1
	BLD  R0,0
	INC  R0
	BST  R0,0
__CHKSW2:
	RET

__CHKSIGND:
	CLT
	SBRS R23,7
	RJMP __CHKSD1
	RCALL __ANEGD1
	SET
__CHKSD1:
	SBRS R25,7
	RJMP __CHKSD2
	CLR  R0
	COM  R26
	COM  R27
	COM  R24
	COM  R25
	ADIW R26,1
	ADC  R24,R0
	ADC  R25,R0
	BLD  R0,0
	INC  R0
	BST  R0,0
__CHKSD2:
	RET

__GETW1P:
	LD   R30,X+
	LD   R31,X
	SBIW R26,1
	RET

__PUTDP1:
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	RET

__GETW1PF:
	LPM  R0,Z+
	LPM  R31,Z
	MOV  R30,R0
	RET

__PUTD1S0:
	ST   Y,R30
	STD  Y+1,R31
	STD  Y+2,R22
	STD  Y+3,R23
	RET

__PUTPARD1:
	ST   -Y,R23
	ST   -Y,R22
	ST   -Y,R31
	ST   -Y,R30
	RET

__PUTPARD2:
	ST   -Y,R25
	ST   -Y,R24
	ST   -Y,R27
	ST   -Y,R26
	RET

__SWAPD12:
	MOV  R1,R24
	MOV  R24,R22
	MOV  R22,R1
	MOV  R1,R25
	MOV  R25,R23
	MOV  R23,R1

__SWAPW12:
	MOV  R1,R27
	MOV  R27,R31
	MOV  R31,R1

__SWAPB12:
	MOV  R1,R26
	MOV  R26,R30
	MOV  R30,R1
	RET

__EEPROMRDW:
	ADIW R26,1
	RCALL __EEPROMRDB
	MOV  R31,R30
	SBIW R26,1

__EEPROMRDB:
	SBIC EECR,EEWE
	RJMP __EEPROMRDB
	PUSH R31
	IN   R31,SREG
	CLI
	OUT  EEARL,R26
	OUT  EEARH,R27
	SBI  EECR,EERE
	IN   R30,EEDR
	OUT  SREG,R31
	POP  R31
	RET

__EEPROMWRW:
	RCALL __EEPROMWRB
	ADIW R26,1
	PUSH R30
	MOV  R30,R31
	RCALL __EEPROMWRB
	POP  R30
	SBIW R26,1
	RET

__EEPROMWRB:
	SBIS EECR,EEWE
	RJMP __EEPROMWRB1
	WDR
	RJMP __EEPROMWRB
__EEPROMWRB1:
	IN   R25,SREG
	CLI
	OUT  EEARL,R26
	OUT  EEARH,R27
	SBI  EECR,EERE
	IN   R24,EEDR
	CP   R30,R24
	BREQ __EEPROMWRB0
	OUT  EEDR,R30
	SBI  EECR,EEMWE
	SBI  EECR,EEWE
__EEPROMWRB0:
	OUT  SREG,R25
	RET

__SAVELOCR6:
	ST   -Y,R21
__SAVELOCR5:
	ST   -Y,R20
__SAVELOCR4:
	ST   -Y,R19
__SAVELOCR3:
	ST   -Y,R18
__SAVELOCR2:
	ST   -Y,R17
	ST   -Y,R16
	RET

__LOADLOCR6:
	LDD  R21,Y+5
__LOADLOCR5:
	LDD  R20,Y+4
__LOADLOCR4:
	LDD  R19,Y+3
__LOADLOCR3:
	LDD  R18,Y+2
__LOADLOCR2:
	LDD  R17,Y+1
	LD   R16,Y
	RET

__INITLOCB:
__INITLOCW:
	ADD  R26,R28
	ADC  R27,R29
__INITLOC0:
	LPM  R0,Z+
	ST   X+,R0
	DEC  R24
	BRNE __INITLOC0
	RET

;END OF CODE MARKER
__END_OF_CODE:
