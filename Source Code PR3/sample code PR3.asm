;===============================================================================================
;
;	Author					: Cytron Technologies
;   Project					: DIY Project
;	Project Descrription	: PR3 (LCD Display)
;	Date					: 26 May 2009
;
;===============================================================================================


;=============================================================================================================
;The protocol for the LCD
;===============================================================================================================
;R/S	DB7		DB6		DB5		DB4		DB3		DB2		DB1		DB0		Functions
;0		0		0		0		0		0		0		0		1		Clear LCD
;0		0		0		0		0		0		0		1		X		Return Cursor to home position
;0		0		0		0		0		0		1		ID		S		Set Cursor move direction
;0		0		0		0		0		1		D		C		B		Enable Display/Cursor
;0		0		0		0		1		SC		RL		X		X		Move Cursor/Shift Display
;0		0		0		1		DL		N		F		X		X		Set Interface Length and Display format
;0		1		A		A		A		A		A		A		A		Move Cursor to DDRAM
;1		D		D		D		D		D		D		D		D		Write a character to Display and DDRAM
;
;X = Don't care
;A = Address
;================================================================================================================

;================================================================================================================
;LCD command bit value and function
;****************************************************************************************************************
;Bit name		Bit Function					= 0						= 1
;****************************************************************************************************************
;R/S	  		Command or Character			Command					Character
;ID       		Set cursor move direction		Decrement				increment
;S				Specifies to shift display		No display shift		Display shift
;D				Set display On/Off				Display Off				Display On
;C				Cursor On/Off					Cursor Off				Cursor On
;B				Cursor Blink					Cursor Blink Off		Cursor Blink On
;SC				Set Cursor move or shift D		Move Cursor				Shift Display
;RL				Shift direction					Shift Left				Shift Right
;DL				Sets Interface data length		4-bit Interface			8-bit Interface
;N				Number of display line			1 line					2 line
;F				Character font					5x7 dots				5x10 dots
;================================================================================================================

;================================================================================================================
;													DDRAM ADDRESS in HEX
;================================================================================================================
;
;	Display			    1     2   3	    4	5	 6	  7	   8	9	 10	  11   12	13	14	 15    16	
;					---------------------------------------------------------------------------------------------
;	Line 1			| | 00 | 01 | 02 | 03 | 04 | 05 | 06 | 07 | 08 | 09 | 0A | 0B | 0C | 0D | 0E | 0F | |
;	Line 2	 		| | 40 | 41 | 42 | 43 | 44 | 45 | 46 | 47 | 48 | 49 | 4A | 4B | 4C | 4D | 4E | 4F | |
;					---------------------------------------------------------------------------------------------
;================================================================================================================



			LIST P=16F877A

			ERRORLEVEL	-302
			ERRORLEVEL	-305

			#INCLUDE <P16F877A.INC>

			__CONFIG	0X3F32

;===========================================================================================
; MACRO
;===========================================================================================

BANK0		MACRO					;CHANGE TO BANK 0
			BCF		STATUS,RP0					
			BCF		STATUS,RP1
			ENDM
			
BANK1		MACRO					;CHANGE TO BANK 1
			BSF		STATUS,RP0
			BCF		STATUS,RP1
			ENDM
		
BANK2		MACRO					;CHANGE TO BANK 2
			BCF		STATUS,RP0
			BSF		STATUS,RP1
			ENDM
		
BANK3		MACRO					;CHANGE TO BANK 3
			BSF		STATUS,RP0																											
			BSF		STATUS,RP1
			ENDM

CLOCK_E		MACRO					;'E' RISE UP N FALL DOWN
			BSF		PORTB,5
			CALL	DELAY1
			BCF		PORTB,5
			CALL	DELAY1
			ENDM

;========================================================================================
; VARIABLE DEFINATION
;========================================================================================
;DATA MEMORY ADDRESS =	20h - 7Fh (BANK0)
;						A0h - EFh (BANK1)
;						110h - 16Fh (BANK2)
;						190h - 1EFh	(BANK3)

D1			EQU		0X20	;FOR DELAY
D2			EQU		0X21	;FOR DELAY
D3			EQU		0X22	;FOR DELAY
D4			EQU		0X23	;FOR DELAY
D5			EQU		0X24	;FOR DELAY
D6			EQU		0X25	;FOR DELAY




;=========================================================================================
; RESET VECTOR
;=========================================================================================
			ORG		0X200

RESET		GOTO	INIT


;=========================================================================================
;INTERRUPT VECTOR 
;=========================================================================================
	

			ORG		0X204
	
INT			GOTO	INIT

;=========================================================================================
; INITIALIAZATION OF I/O
;=========================================================================================


			ORG		0X205

INIT		BANK0

			CLRF	PORTA
			CLRF	PORTD
			CLRF	PORTC
			CLRF	PORTD
			CLRF	PORTE	

			BANK1

			MOVLW	0X06
			MOVWF	ADCON1			;PORTA AS DIGITAL I/O
			CLRF	TRISA			;PORTA AS OUTPUT
			CLRF	TRISB			;PORTD AS OUTPUT
			CLRF	TRISC			;PORTC AS OUTPUT
			CLRF	TRISD			;PORTD AS OUTPUT
			CLRF	TRISE			;PORTE AS OUTPUT
				
			BANK0
			CLRF	PORTD


;============================================================================================== 
;MAIN PROGRAM STRAT HERE
;==============================================================================================

;LCD INITIALIZED
			
			CALL	DELAY1
			CALL	DELAY1

			BCF		PORTB,4				; R/S SET TO '0'as a command		
			MOVLW	B'00110000'			
			MOVWF	PORTD				; FUNCTION SET: 8 BIT INTERFACE
			CLOCK_E						; E CLOCK MACRO
			MOVLW	B'00001101'			
			MOVWF	PORTD				; DISPALY & CURSOR: SET TO DISPLAY ON; CURSOR UNDERLINE OFF; CURSOR BLINK ON
			CLOCK_E						; E CLOCK MACRO
			MOVLW	B'00111000'		
			MOVWF	PORTD				; FUNCTION SET: 8 BIT; 2 LINE MODE; 5X7 DOT FORMAT
			CLOCK_E						; E CLOCK MACRO
			MOVLW	B'00000001'			
			MOVWF	PORTD				; CLEAR DISPLAY
			CLOCK_E						; E CLOCK MACRO									
			MOVLW	B'00000110'
			MOVWF	PORTD				; CHARACTER ENTRY MODE: INCREMENT; DISPLAY SHIFT ON
			CLOCK_E						; E CLOCK MACRO


;WRITE YOUR CHARACTER HERE

			BSF		PORTB,4		;R/S SET TO '1' to write character
			MOVLW	B'01001000'		;'H'in ASCII mode
			MOVWF	PORTD			;Display 'H'
			CLOCK_E					
			MOVLW	B'01100101'		;'e' in ASCII mode
			MOVWF	PORTD			;Display 'e'
			CLOCK_E					
			MOVLW	B'01110010'		;'r' in ASCII mode
			MOVWF	PORTD			;Diplay 'r'
			CLOCK_E					
			MOVLW	B'01100101'		;'e' in ASCII mode
			MOVWF	PORTD			;Display 'e'
			CLOCK_E
			MOVLW	B'10100000'		
			MOVWF	PORTD			;SPACE
			CLOCK_E	
			MOVLW	B'01110101'		;'u' in ASCII mode
			MOVWF	PORTD			;Display 'u'
			CLOCK_E
			MOVLW	B'10100000'		
			MOVWF	PORTD			;SPACE
			CLOCK_E
			MOVLW	B'01100111'		;'g' in ASCII mode
			MOVWF	PORTD			;Display 'g'
			CLOCK_E
			MOVLW	B'01101111'		;'o' in ASCII mode
			MOVWF	PORTD			;Display 'o'
			CLOCK_E
			MOVLW	B'00101110'		;'.' in ASCII mode
			MOVWF	PORTD			;Display '.'
			CLOCK_E
			MOVLW	B'00101110'		;'.' in ASCII mode
			MOVWF	PORTD			;Display '.'
			CLOCK_E
				
			CALL	DELAY1
			
			BCF		PORTB,4			; R/S SET TO '0' as a command
			MOVLW	B'11000000'		; B'10000000' is a command to jump to 2nd line
									; B'01000000' or '0x40' is DDRAM address
									; B'100000000'| B'01000000'
			MOVWF	PORTD			; JUMP TO 2ND LINE
			CLOCK_E

			BSF		PORTB,4			;R/S SET TO '1' to write character
			MOVLW	B'01000111'		;'G' in ASCII mode
			MOVWF	PORTD			;Display 'G'
			CLOCK_E
			MOVLW	B'01001111'		;'O' in ASCII mode
			MOVWF	PORTD			;Display 'O'
			CLOCK_E
			MOVLW	B'01001111'		;'0' in ASCII mode
			MOVWF	PORTD			;Display 'O'
			CLOCK_E
			MOVLW	B'01000100'		;'D' in ASCII mode
			MOVWF	PORTD			;Display 'D'
			CLOCK_E
			MOVLW	B'10100000'		
			MOVWF	PORTD			;SPACE
			CLOCK_E
			MOVLW	B'01001100'		;'L' in ASCII mode
			MOVWF	PORTD			;Display 'L'
			CLOCK_E
			MOVLW	B'01010101'		;'U' in ASCII mode
			MOVWF	PORTD			;Display 'U'
			CLOCK_E
			MOVLW	B'01000011'		;'C' in ASCII mode
			MOVWF	PORTD			;Display 'C'
			CLOCK_E
			MOVLW	B'01001011'		;'K' in ASCII mode
			MOVWF	PORTD			;Display 'K'
			CLOCK_E
			MOVLW	B'10100000'		
			MOVWF	PORTD			;SPACE
			CLOCK_E
			MOVLW	B'00111010'		;':' in ASCII mode
			MOVWF	PORTD			;Display ':'
			CLOCK_E
			MOVLW	B'00101001'		;')' in ASCII mode
			MOVWF	PORTD			;Display ')'
			CLOCK_E
			


			NOP						;NO OPERATION
			GOTO	$-1				;LOCAL LOOPING


			
;=======================================================================================		
;DELAY SUBROUTINE 
;=======================================================================================				


DELAY1		MOVLW	D'100'		
			MOVWF	D3
			MOVLW	D'10'
			MOVWF	D2
			MOVLW	D'1'
			MOVWF	D1
			DECFSZ	D1
			GOTO	$-1
			DECFSZ	D2
			GOTO	$-5
			DECFSZ	D3
			GOTO	$-9
			RETURN

DELAY2		MOVLW	D'255'		
			MOVWF	D6
			MOVLW	D'200'
			MOVWF	D5
			MOVLW	D'50'
			MOVWF	D4
			DECFSZ	D4
			GOTO	$-1
			DECFSZ	D5
			GOTO	$-5
			DECFSZ	D6
			GOTO	$-9
			RETURN


			END
		
		
		
		
		
