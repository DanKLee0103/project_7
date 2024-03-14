
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
;*	 Author: Daniel Lee and Noah Bean
;*	   Date: 3/13/2024
;*
;***********************************************************

.include "m32U4def.inc"         ; Include definition file

;***********************************************************
;*  Internal Register Definitions and Constants
;***********************************************************
.def    mpr = r16               ; Multi-Purpose Register

.def	display = r17			;for LED display
.def	1.5_count = r18			;for delay
.def	.5_count = r19			;for delay

; Use this signal code between two boards for their game ready
.equ    SendReady = 0b11111111
.equ	LED1 = 7	
.equ	LED2 = 6
.equ	LED3 = 5
.equ	LED4 = 4

;***********************************************************
;*  Start of Code Segment
;***********************************************************
.cseg                           ; Beginning of code segment

;***********************************************************
;*  Interrupt Vectors
;***********************************************************
.org    $0000                   ; Beginning of IVs
	    rjmp    INIT            	; Reset interrupt

.org	$0002;For push button 4 (PIND0->PB4)
		rcall Choose_Hand			;interrupt to cycle through rock paper scissors
		reti

.org	$0004;For push button 7 (PIND1->PB7)
		rcall Game_Start			;interrupt to start the game 
		reti
		;$0006 and $0008 occupied for transmitter and receiver
.org	$0032
		rcall Received			;interrupt that indicates that signal is received
		reti

.org    $0056                   ; End of Interrupt Vectors

;***********************************************************
;*  Program Initialization
;***********************************************************
INIT:	
		;Stack Pointer (VERY IMPORTANT!!!!)
		ldi mpr, low(RAMEND)
		out SPL, mpr			
		ldi mpr, high(RAMEND)	
		out SPH, mpr

		cli

		;I/O Ports
		ldi mpr, 0b00001111
		out DDRB, mpr
		ldi mpr, 0b00000000
		out PORTB, mpr
		ldi mpr, 0b11111111; PB7 and PB4 are what matter, but we can set all (active high) initially
		out DDRD, mpr
	;USART1
		;Set baudrate at 2400bps (double rate) UBRR = clock frequency/(8*baud rate)
		ldi mpr, low(416); 8000000/(8*2400) = 416 = UBRR
		sts UBRR1L, mpr;
		ldi mpr, high(416);
		sts UBRR1H, mpr;
		;Enable receiver and transmitter
		;Set frame format: 8 data bits, 2 stop bits
		ldi mpr, 0b00100010; data register empty = 1; double rate = 1;
		sts UCSR1A, mpr
		ldi mpr, 0b10011000; receiver complete enable = 1; receiver enable, transmitter enable = 1;
		sts UCSR1B, mpr
		ldi mpr, 0b00001110; UCPOL1 = 00, USBS1 = 1, UCSZ = 011 (only last two bits relevant for UCSR1C), UMSEL1 = 00, UPM1 = 00 
		sts UCSR1C, mpr; in extended I/O space, so we use sts


	;TIMER/COUNTER1
		;Set Normal mode (WGM 13:10 = 0000)
		ldi mpr, 0b11110000; compare output mode high for COM1A and COM1B
		sts TCCR1A, mpr
		ldi mpr, 0b00000101; clock selection 1024 prescale, so 101 (we want to get a big delay. if wrong, it can be EDITTED)
		sts TCCR1B, mpr
		sei; Enable global interrupt

	rcall LCDInit
	rcall LCDBacklightOn


;***********************************************************
;*  Main Program
;***********************************************************
MAIN:

	;TODO: ???

	;need some way to know that both players are ready and then call GameStart if both players ready

		rjmp	MAIN

;***********************************************************
;*	Functions and Subroutines
;***********************************************************

;-----------------------------------------------------------
; Func: GameStart
; Desc: Cut and paste this and fill in the info at the
;		beginning of your functions
;-----------------------------------------------------------
GameStart:							; Begin a function with a label

		; Save variable by pushing them to the stack
		
		; Execute the function here

		; Restore variable by popping them from the stack in reverse order

		ret						; End a function with RET

;-----------------------------------------------------------
; Func: ChooseHand
; Desc: Cut and paste this and fill in the info at the
;		beginning of your functions
;-----------------------------------------------------------
ChooseHand:							; Begin a function with a label

		; Save variable by pushing them to the stack

		; Execute the function here

		; Restore variable by popping them from the stack in reverse order

		ret						; End a function with RET

;-----------------------------------------------------------
; Func: Transmit
; Desc: Cut and paste this and fill in the info at the
;		beginning of your functions
;-----------------------------------------------------------
Transmit:							; Begin a function with a label

		push	mpr						; save mpr
		in		mpr, SREG				; save program state
		push	mpr

		lds		mpr, UCSR1A
		sbrs	mpr, UDRE1		; wait until UDRE1 is empty and is set to sts UDR1,mpr
		rjmp	Transmit

		ldi	mpr, SendReady		;signal that let's other board know it's ready
		sts UDR1, mpr			;store signal data into UDR1 to let program know transmit buffer is full (clears UDRE1)

		;eifr or eimsk? might need it

		; Restore variable by popping them from the stack in reverse order
		pop		mpr
		out		SREG, mpr
		pop		mpr

		ret						; End a function with RET

;-----------------------------------------------------------
; Func: Received
; Desc: Cut and paste this and fill in the info at the
;		beginning of your functions
;-----------------------------------------------------------
Received:							; Begin a function with a label

		push	mpr						; save mpr
		in		mpr, SREG				; save program state
		push	mpr

		lds mpr, UDR1		;UDR1 should be $FF if received SendReady signal from other device

		cpi	mpr, SendReady ;just make sure that we got the right signal that we stored earlier inside of UDR1 for transmit
		breq Receive_Ready ;if we did receive that signal, go prepare the game
		rjmp Received ; if not, keep looping through until we receive it

Receive_Ready:

		ldi		mpr, 0b00000010		; enable interrupt to rotate hands
		out		EIMSK, mpr

		; Restore variable by popping them from the stack in reverse order
		pop		mpr
		out		SREG, mpr
		pop		mpr

		ret						; End a function with RET


;-----------------------------------------------------------
; Func: DisplayLines
; Desc: Cut and paste this and fill in the info at the
;		beginning of your functions
;-----------------------------------------------------------
DisplayLines:							; Begin a function with a label

		; Save variable by pushing them to the stack

		; Execute the function here

		; Restore variable by popping them from the stack in reverse order

		ret						; End a function with RET

;-----------------------------------------------------------
; Func: ChangeLEDs
; Desc: Cut and paste this and fill in the info at the
;		beginning of your functions
;-----------------------------------------------------------
ChangeLEDs:							; Begin a function with a label

		push	mpr						; save mpr
		in		mpr, SREG				; save program state
		push	mpr

		clr		mpr
		in		mpr, PORTB				; PORTB to mpr


		; Restore variable by popping them from the stack in reverse order
		pop		mpr
		out		SREG, mpr
		pop		mpr

		ret						; End a function with RET


;-----------------------------------------------------------
; Func: EvaluateScore
; Desc: Checks which board has winning condition
;-----------------------------------------------------------
EvaluateScore:							; Begin a function with a label

		; Save variable by pushing them to the stack

		; Execute the function here

		; Restore variable by popping them from the stack in reverse order

		ret						; End a function with RET


;----------------------------------------------------------------
; Sub:	Full_Delay
; Desc:	A full delay for six seconds that turns off each LED light every 1.5 seconds.
;----------------------------------------------------------------
Full_Delay:
		push	1.5_cnt			; Save 1.5_cnt register
		push	.5_cnt			; Save .5_cnt register

		ldi		mpr, $F0		;turns on the first four LED (7-4)
		out		PORTB, mpr

1.5_Loop:	ldi		1.5_cnt, 4		; load 1.5_cnt register so there is 1.5second delay between each LED turn off (1.5*4 = 6)

	.5_Loop:	ldi		.5_cnt, 3		;load .5_cnt three times (.5*3 = 1.5) It's split to three because of max value problems with delay (max = 65535 but 1.5 second = ... something may not be right here)
				;need to figure these values out
				ldi		mpr, $00
				sts		TCNT1H, mpr
				ldi		mpr, $00
				sts		TCNT1L, mpr

	Check_.5Loop:
					in		mpr, TIFR1
					cpi	mpr, $01			;compare if TOV1 flag high (reach max 65535)
					brne	Check_.5Loop	;if not, Check_.5LOOP continuosuly

					ldi		mpr, 0b00000001			;
					out		TIFR1, mpr

					dec		.5_cnt			; decrement .5_cnt
					brne	.5_Loop			; Continue .5_Loop

					in		mpr, PORTB		;put PORTB into mpr
					lsr		mpr				;then logical shift to the right, so everything shifts one and the 1 in the leftmost 1 becomes 0 each 1.5 seconds
					dec		1.5_cnt			; decrement 1.5_cnt
					brne	1.5_Loop		; Continue 1.5_Loop if 1.5_cnt not == 0

		pop		1.5_cnt		; Restore 1.5_cnt register
		pop		.5_cnt		; Restore .5_cnt register
		ret				; Return from subroutine

;***********************************************************
;*	Stored Program Data
;***********************************************************

;-----------------------------------------------------------
; An example of storing a string. Note the labels before and
; after the .DB directive; these can help to access the data
;-----------------------------------------------------------
STRING_START:
    .DB		"Welcome!        Please press PD7"		; Declaring data in ProgMem (Use Z later to pull it out)
STRING_END:

STRING_READY:
.db "Ready. Waiting  for the opponent";DO NOT EDIT
STRING_READY_WAIT:

STRING_PLAY:
.db "Game start      "
STRING_PLAY_WAIT:

STRING_ROCK:
.db "Rock            "
STRING_ROCK_END:

STRING_PAPER:
.db "Paper           "
STRING_PAPER_END:

STRING_SCISSOR:
.db "Scissor         "
STRING_SCISSOR_END:

STRING_LOST:
.db "You lost        "
STRING_LOST END:

STRING_WON:
.db "You won!        "
STRING_WON_END:

STRING_DRAW:
.db "Draw...         "
STRING_DRAW_END:

;***********************************************************
;*	Additional Program Includes
;***********************************************************
.include "LCDDriver.asm"		; Include the LCD Driver

/*
Play Rock Paper Scissors between
Two Boards
? Communicate through the USART1 modules
? LCD display to print messages.
? Buttons
? PD7 – Start/Ready
? PD4 – Change the current gesture and iterate through the three
gestures in order
? Rock ? Paper ? Scissor ? Rock ? Paper ? ...
? 4 LEDs
? PB7:4 – Count down indicator
? 4 × 1.5-sec delay
? Timer/Counter1 Normal mode
? PB3:0 – Leave for LCDDriver
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
? Data Frame : 8-bit data
? Stop bit : 2 stop bits
? Parity bit : disable
? Asynchronous Operation
? Baud Rate
? 2400 bits per second
? Control Register
? Frame Format
? UCSR1A
? UCSR1B
? UCSR1C
? Baud Rate
? UBRR1H
? UBRR1L
? Data Register
? UDR1
*/

/*
Transmit
? STS UDR1, mpr
? Receive
? LDS mpr, UDR1
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