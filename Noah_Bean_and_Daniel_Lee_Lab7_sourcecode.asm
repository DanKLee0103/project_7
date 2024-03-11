
;***********************************************************
;*
;*	This is the TRANSMIT skeleton file for Lab 7 of ECE 375
;*
;*  	Rock Paper Scissors
;* 	Requirement:
;* 	1. USART1 communication
;* 	2. Timer/counter1 Normal mode to create a 1.5-sec delay
;***********************************************************
;*
;*	 Author: Noah Bean and Daniel Lee
;*	   Date: 03/07/24
;*
;***********************************************************

.include "m32U4def.inc"         ; Include definition file

;***********************************************************
;*  Internal Register Definitions and Constants
;***********************************************************
.def    mpr = r16               ; Multi-Purpose Register

; Use this signal code between two boards for their game ready
.equ    SendReady = 0b11111111

;***********************************************************
;*  Start of Code Segment
;***********************************************************
.cseg                           ; Beginning of code segment

;***********************************************************
;*  Interrupt Vectors
;***********************************************************
.org    $0000                   ; Beginning of IVs
	    rjmp    INIT            	; Reset interrupt


.org    $0056                   ; End of Interrupt Vectors

;***********************************************************
;*  Program Initialization
;***********************************************************
INIT:
	;Stack Pointer (VERY IMPORTANT!!!!)
	;I/O Ports
	;USART1
		;Set baudrate at 2400bps
		;Enable receiver and transmitter
		;Set frame format: 8 data bits, 2 stop bits

	;TIMER/COUNTER1
		;Set Normal mode

	;Other

initUSART1:; Port D set up – pin3 output
ldi mpr, 0b00001000; Configure USART1 TXD1 (Port D, pin 3)
out DDRD, mpr ; Set pin direction to output
; Set Baud rate
ldi mpr, 51
; Set baud rate to 9,600 with f = 8 MHz
sts UBRR1L, mpr; UBRR1H already initialized to $00
; Enable transmitter and interrupt
ldi mpr, (1<<TXEN1|1<<UDRIE1) ; Enable Transmitter and interrupt
sts UCSR1B, mpr; UCSR1B in extended I/O space, use sts
; Set asynchronous mode and frame format
ldi mpr, (1<<UPM11|1<<UPM10|1<<UCSZ11|1<<UCSZ10)
sts UCSR1C, mpr; UCSR1C in extended I/O space, use sts
sei; Enable global interrupt


;***********************************************************
;*  Main Program
;***********************************************************
MAIN:

	;TODO: ???

		rjmp	MAIN

;***********************************************************
;*	Functions and Subroutines
;***********************************************************

;***********************************************************
;*	Stored Program Data
;***********************************************************

;-----------------------------------------------------------
; An example of storing a string. Note the labels before and
; after the .DB directive; these can help to access the data
;-----------------------------------------------------------
STRING_START:
    .DB		"Welcome!"		; Declaring data in ProgMem
STRING_END:

;***********************************************************
;*	Additional Program Includes
;***********************************************************
.include "LCDDriver.asm"		; Include the LCD Driver

/*
Play Rock Paper Scissors between
Two Boards
 Communicate through the USART1 modules
 LCD display to print messages.
 Buttons
◦ PD7 – Start/Ready
◦ PD4 – Change the current gesture and iterate through the three
gestures in order
 Rock → Paper → Scissor → Rock → Paper → ...
 4 LEDs
◦ PB7:4 – Count down indicator
 4 × 1.5-sec delay
 Timer/Counter1 Normal mode
◦ PB3:0 – Leave for LCDDriver
*/

/*
PD2 <=> PD3
PD3 <=> PD2
GND <=> GND
0
PORTD
1
32
4
6
G
5
7
V
TXD1
RXD1
RXD1
Board 1 Board 2
*/

/*
Frame Format
◦ Data Frame : 8-bit data
◦ Stop bit : 2 stop bits
◦ Parity bit : disable
◦ Asynchronous Operation
 Baud Rate
◦ 2400 bits per second
 Control Register
◦ Frame Format
 UCSR1A
 UCSR1B
 UCSR1C
◦ Baud Rate
 UBRR1H
 UBRR1L
 Data Register
◦ UDR1
*/

/*
Transmit
◦ STS UDR1, mpr
 Receive
◦ LDS mpr, UDR1
*/

/*
UCSR1A
Bit 7 – RXCn: USART Receive Complete
Bit 6 – TXCn: USART Transmit Complete
Bit 5 – UDREn: USART Data Register Empty
Bit 4 – FEn: Frame Error
Bit 3 – DORn: Data OverRun
Bit 2 – UPEn: Parity Error
Bit 1 – U2Xn: Double the USART Transmission Speed
Bit 0 – MPCMn: Multi-Processor Communication Mode
*/

/*
UCSR1B
Bit 7 – RXCIEn: RX Complete Interrupt Enable
Bit 6 – TXCIEn: TX Complete Interrupt Enable
Bit 5 – UDRIEn: USART Data Register Empty Interrupt Enable
Bit 4 – RXENn: Receiver Enable
Bit 3 – TXENn: Transmitter Enable
Bit 2 – UCSZn2: Character Size
Bit 1 – RXB8n: Receive Data Bit 8
Bit 0 – TXB8n: Transmit Data Bit 8
*/

/*
UCSR1C
Bit 7:6 – UMSELn1: USART Mode Select
Bit 5:4 – UPMn1:0: Parity Mode
Bit 3 – USBSn: Stop Bit Select
Bit 2:1 – UCSZn1:0: Character Size
Bit 0 – UCPOLn: Clock Polarity
*/

/*
UMSEL1(10) 00 Asynchronous
UPM1(10) 00 Disabled
*/

/*
USBS1  1
UCPOL1 0
*/

;UCSZ2,1,0 = 011

/*
Bit 15:12 – Reserved Bits
Bit 11:0 – UBRRn11:0: USARTn Baud Rate Register
UBRR1H
UBRR1L
*/

/*
mplementation – 60 pts
◦ 10 pts for Correct USART1 configuration
◦ 15 pts for PD7 Functionality
 (5pt) Game Ready/Start
 (10pt) USART1 communication
◦ 15 pts for PD4 Functionality
 (5pt) Select Gestures and iterate correctly
 (10pt) USART1 communication
◦ 10 pts for PB7-4 Functionality
 4 × 1.5-sec delay using T/C1 Normal
◦ 5 pts for the Correct result (Win, Loose, or Draw)
◦ 5 pts for LCD does not show any garbage data
 Challenge – Extra 10 pts
*/

