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

.def	opp_hand = r17			;for opponent hand
.def	one_half_cnt = r18		;for delay
.def	temp = r19				;for multi-use
.def	hand = r23				;to see how hand is set
.def	SendData = r24
.def	ReceiveData = r25

.equ	change_hand = 4 ;pb4
.equ	ready_signal = 7 ;pb7

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

.org	$0002;For push button 4 (PIND0->PB4)
		rcall ChooseHand			;interrupt to cycle through rock paper scissors
		reti

.org	$0004;For push button 7 (PIND1->PB7)
		rcall GameStart			;interrupt to start the game 
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
		ldi mpr, 0b11110000
		out DDRB, mpr
		ldi mpr, 0b00000000
		out DDRD, mpr
		ldi mpr, 0b11111111; PB7 and PB4 are what matter, but we can set all (active high) initially
		out PORTD, mpr
	;USART1
		;Set baudrate at 2400bps (double rate) UBRR = clock frequency/(8*baud rate)
		ldi mpr, high(416);
		sts UBRR1H, mpr;
		ldi mpr, low(416); 8000000/(8*2400) = 416 = UBRR
		sts UBRR1L, mpr;
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
		ldi mpr, 0b00000000; no non-invert or invert since normal mode
		sts TCCR1A, mpr
		ldi mpr, 0b00000101; clock selection 1024 prescale, so 101 (we want to get a big delay. if wrong, it can be EDITTED)
		sts TCCR1B, mpr

		;EICRA and EIMSK
		ldi mpr, 0b00001010; using INT0 and INT1 (falling edge)
		sts EICRA, mpr
		ldi mpr, 0b0000000;start out with none available. enable them when needed.
		out EIMSK, mpr

	rcall LCDInit
	rcall LCDBacklightOn

	sei; Enable global interrupt
;***********************************************************
;*  Main Program
;***********************************************************
MAIN:
	; Enable PD7
	ldi mpr, 0b00000010
	out EIMSK, mpr
	;TODO: ???
		;welcome message
		ldi ZL, LOW(STRING_START<<1)
		ldi	ZH, HIGH(STRING_START<<1)
		ldi YL, $00
		ldi YH, $01 ;$0100 first bit of LCD

		LOOP_START:
			lpm temp, Z+
			st Y+, temp
			tst temp
			breq LOOP_START_DONE
			rjmp LOOP_START

LOOP_START_DONE:

		rcall LCDWrite

	;Wait to transmit
	rcall Full_Delay

	;Disable PD7
	ldi mpr, 0b00000000
	out EIMSK, mpr

	;Check if received something
Receive_Check:
	rcall Received
	rcall DisplayStart
	cpi	  ReceivedData, SendData ;just make sure that we got the right signal that we stored earlier inside of UDR1 for transmit
	breq  Receive_Done ;if we did receive that signal, go prepare the game
	rjmp  Receive_Check ; if not, keep looping through until we receive it

Receive_Done:
	;If received, choose hand
	cpi	  ReceivedData, SendData
	breq  ChooseHand
	;If not, display message
	;rcall DisplayStart

	;Sit and wait for ready signal
	

	;Play game, enable PD4 call wait and update LED
		;should make a game called play game or something

	;After 4 LEDS, disable PD4
	rcall Full_Delay
	ldi   mpr, 0b00000000
	out	  EIMSK, mpr
	;Transmit my hand
	ldi SendData, hand		;load hand into data 
	rcall Transmit
	;Receive opponent hand
	rcall Received
	ldi opp_hand, ReceiveData

	;Check if I won or lost
	;Display that with a wait.
	rcall Full_Delay



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
		push	mpr						; save mpr
		in		mpr, SREG				; save program state
		push	mpr

		; Execute the function here
		ldi ZL, LOW(STRING_START<<1)
		ldi	ZH, HIGH(STRING_START<<1)
		ldi YL, $00
		ldi YH, $01 ;$0100 first bit of LCD

		LOOP_READY:
			lpm temp, Z+
			st Y+, temp
			tst temp
			breq LOOP_READY_DONE
			rjmp LOOP_READY

LOOP_READY_DONE:
		rcall LCDWrite
		ldi	  SendData, SendReady
		rcall Transmit		;This sends the signal that you are ready and triggers the interrupt $0032 (I believe)
		; Restore variable by popping them from the stack in reverse order
		pop		mpr
		out		SREG, mpr
		pop		mpr

		ret						; End a function with RET

;-----------------------------------------------------------
; Func: DisplayStart
; Desc: Cut and paste this and fill in the info at the
;		beginning of your functions
;-----------------------------------------------------------
DisplayStart:							; Begin a function with a label

		; Save variable by pushing them to the stack
		push	mpr						; save mpr
		in		mpr, SREG				; save program state
		push	mpr

		; Execute the function here
		ldi ZL, LOW(STRING_PLAY<<1)
		ldi	ZH, HIGH(STRING_PLAY<<1)
		ldi YL, $00
		ldi YH, $01 ;$0100 first bit of LCD

		LOOP_PLAY:
			lpm temp, Z+
			st Y+, temp
			tst temp
			breq LOOP_PLAY_DONE
			rjmp LOOP_PLAY

LOOP_PLAY_DONE:
		rcall LCDWrite

		; Restore variable by popping them from the stack in reverse order
		pop		mpr
		out		SREG, mpr
		pop		mpr

		ret						; End a function with RET

;-----------------------------------------------------------
; Func: ChooseHand
; Desc: Cut and paste this and fill in the info at the
;		beginning of your functions
;-----------------------------------------------------------
ChooseHand:							; Begin a function with a label

		; Save variable by pushing them to the stack
		push	mpr						; save mpr
		in		mpr, SREG				; save program state
		push	mpr

		; Execute the function here
ChangeHand:
		cpi 

		; Restore variable by popping them from the stack in reverse order
		pop		mpr
		out		SREG, mpr
		pop		mpr

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

		;mov	mpr, SendData		;signal that let's other board know it's ready
		sts UDR1, SendData			;store signal data into UDR1 to let program know transmit buffer is full (clears UDRE1)

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

		lds ReceiveData, UDR1		;UDR1 should be $FF if received SendReady signal from other device

		;cpi	mpr, SendData ;just make sure that we got the right signal that we stored earlier inside of UDR1 for transmit
		;breq Receive_Ready ;if we did receive that signal, go prepare the game
		;rjmp Received ; if not, keep looping through until we receive it

Receive_Ready:

		ldi		mpr, 0b00000001		; enable interrupt to rotate hands (INT0)
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
		push	mpr						; save mpr
		in		mpr, SREG				; save program state
		push	mpr

		; Execute the function here


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
		push	mpr						; save mpr
		in		mpr, SREG				; save program state
		push	mpr

		; Execute the function here

		; Restore variable by popping them from the stack in reverse order
		pop		mpr
		out		SREG, mpr
		pop		mpr
		ret						; End a function with RET


;----------------------------------------------------------------
; Sub:	Full_Delay
; Desc:	A full delay for six seconds that turns off each LED light every 1.5 seconds.
;----------------------------------------------------------------
Full_Delay:
		push	mpr						; save mpr
		in		mpr, SREG				; save program state
		push	mpr
		push	one_half_cnt			; Save 1.5_cnt register

		ldi		mpr, $F0		;turns on the first four LED (7-4)
		out		PORTB, mpr
	
		ldi		one_half_cnt, 4		; load 1.5_cnt register so there is 1.5second delay between each LED turn off (1.5*4 = 6)

One_Half_Loop:				
				;65535-(1.5/(1024*0.000000125)) = 53816 = $D238
				ldi		mpr, $D2
				sts		TCNT1H, mpr
				ldi		mpr, $38
				sts		TCNT1L, mpr

	Check_One_Half_Loop:
					lds		mpr, TIFR1
					cpi	mpr, $01			;compare if TOV1 flag high (reach max 65535)
					brne	Check_One_Half_Loop	;if not, Check_1.5LOOP continuosuly

					ldi		mpr, $01		;let the system know that it hit max value or not
					sts		TIFR1, mpr

					in		mpr, PORTB		;put PORTB into mpr
					lsr		mpr				;then logical shift to the right, so everything shifts one and the 1 in the leftmost 1 becomes 0 each 1.5 seconds
					dec		one_half_cnt			; decrement 1.5_cnt
					brne	One_Half_Loop		; Continue 1.5_Loop if 1.5_cnt not == 0

		pop		one_half_cnt		; Restore 1.5_cnt register
		pop		mpr
		out		SREG, mpr
		pop		mpr
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
STRING_LOST_END:

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
