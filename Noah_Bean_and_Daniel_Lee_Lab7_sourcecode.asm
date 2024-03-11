
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

/*
• First pressing PD4 selects the Rock gesture.
• Pressing PD4 changes the current gesture and iterates through the thee
gestures in order. For example, Rock Ñ Paper Ñ Scissor Ñ Rock Ñ ...
• Pressing PD4 immediately displays the choice on the user’s LCD.
*/

/*
• You will need to configure the USART1 module on the boards. Also, al-
though the ATmega32U4’s USART modules can communicate at rates as
high as 2 ˆ 106 bits per second (2 Mbps), you will use the (relatively) slow
baud rate of 2400 bits per second with double data rate.
• Packets, which consist of 8-bit data frame with 2-stop bits and no
parity bit, will be sent back-to-back by the USART modules. One of
packets will be a “send ready” byte, which indicates the sender is ready to
start a game. The others include a choice of their gestures.
• The LCD display needs to be updated immediately whenever the user pro-
vides input.
• Single button press must result in a single action
You must use the Timer/Counter1 module with NORMAL mode
to manage the countdown unit timing. You may design your code to use
polling or you may use interrupts (either approach is fine). You may not
utilize any busy loop for the code delay, although it is allowed to loop if you
are monitoring an interrupt flag.
• Do not include switch debouncing delays of more than 150ms. A busy loop
for debouncing is okay.
• The LCD screen must never display symbols, gibberish, or other undesired
output.
Students often ask about the behavior of the LEDs which are connected to
PB1-PB3. In some cases the LCD library will illuminate one or more of those
LEDs (even if you don’t want them to be enabled). You do not need to worry
about this. The project guidelines do not dictate the behavior of any LEDs
which aren’t mentioned in the project instructions. However, overwriting
values to PB1-PB3 (e.g., during 4 LEDs countdown implementation) can
result in the failure of using the LCD. You will need to avoid overwriting
unused bits (PB0-PB3).
*/


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
.db "Please press PD7"
.db "Ready. Waiting"
.db "for the opponent"
.db "Game start"
.db "Rock"
.db "Paper"
.db "Scissor"
.db "You lost"
.db "You won!"
STRING_END:


/*
When the CPU firsts boots, the LCD screen should show the following content
to the user:
Welcome!
Please press PD7
*/

/*
his content will remain indefinitely until the user presses the button which
is connected to Port D, pin 7. After the button is pressed, the user’s board
should transmit a ready signal to the opponent so that it knows the user is
ready. Additionally, this information will be displayed on the user’s screen:
Ready. Waiting
for the opponent
*/

/*
his content will remain indefinitely until the opponent player presses the PD7
on their board and sends a ready signal to the user’s board.
When the user’s board transmits/receives the ready signal to/from the oppo-
nent, both the user and the opponent’s 4 LEDs are on and start counting down
by turning off one by one at each 1.5-second. Simultaneously, their screens will
also display:
Game start
*/



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

/*
• Write an assembly program (for two separate mega32u4 boards) and have
them interact.
• Learn how to configure and use the Universal Synchronous/Asynchronous
Receiver/Transmitter (USART) module on the ATmega32U4 microcon-
troller.
• Learn how to configure and use the 16-bit Timer/Counter1 module to gen-
erate a 1.5-sec delay.
*/

/*
Specifi-
cally, TX and RX pins in a board need to be wired with RX and TX
pins in the other board, respectively. GND pins in both boards also
need to be connected.
Board 1 Board 2
PD2 Ø PD3
PD3 Ø PD2
PD.gnd Ø PD.gnd
*/

/*
When the CPU firsts boots, the LCD screen should show the following content
to the user:
Welcome!
Please press PD7
*/

