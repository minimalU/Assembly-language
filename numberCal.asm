;* FILE			: numberCal.asm				
;* PROJECT      : A6 				   	
;* PROGRAMMER	: Yujung Park						  		
;* FIRST VERSION: 2022-04-10							 		
;* DESCRIPTION : This program calcualtes

; Include derivative-specific definitions
            INCLUDE 'derivative.inc'
            

; export symbols
            XDEF _Startup, main, mainLoop	; export '_Startup' and 'main' 'mainLoop' as symbols. 
                   							; Either can be referenced in the linker .prm file or from C/C++ later on
            XREF __SEG_END_SSTACK   		; symbol defined by the linker for the end of the stack


; variable, constant and data section
originalSecretNumberPicked: 	EQU $80 ; choose number between 1 and 15 - is at address $80
intermediateCalc:				EQU $81 ; where to store the calculation result of subroutine
finalAnswer:					EQU $84 ; where to store finalAnswer


; code section
MyCode:     SECTION


; FUNCTION    : squareIt				
; DESCRIPTION : 				   	
; PARAMETERS  : 						  		
; RETURNS     : 
squareIt:
	PSHX						; Preserve the X register value upon being called
	PSHA						; Preserve the A register value upon being called
	LDX		5, SP				; Load the X register with originalSecretNumberPicked
	LDA		5, SP				; Load the originalSecretNumberPicked into the accumulator 
	MUL							; Multiplies value in x by value in the accumulator - A<-(X)x(A)
	STA		5, SP				; Store the colculation result into the place on the stack where the originalSecretNumberPicked was
	PULA						; Pop the saved A values off the stack
	PULX						; Pop the saved X values off the stack
	RTS							; Return to the line in main where the routine is called after

; FUNCTION    : addThem				
; DESCRIPTION : 				   	
; PARAMETERS  : 						  		
; RETURNS     : 
addThem:
	PSHA						; Preserve the A register value upon being called
	LDA		4, SP				; Load the intermediateCalc into the accumulator
	ADD		5, SP				; Add intermediateCalc(A) to originalSecretNumberPicked(M)
	STA		4, SP				; Store the colculation result into the place on the stack where the originalSecretNumberPicked was
	PULA						; Pop the saved A values off the stack
	RTS							; Return to the line in main where the routine is called after

; FUNCTION    : devideNumOneByNumTwo				
; DESCRIPTION : 				   	
; PARAMETERS  : 						  		
; RETURNS     : 
divideNumOneByNumTwo:
	PSHH						; Preserve the H register value upon being called
	PSHX						; Preserve the X register value upon being called
	PSHA						; Preserve the A register value upon being called
	LDX		6, SP				; Load the originalSecretNumberPicked into X
	CLRH						; Clear out the H register
	LDA		7, SP				; Load the intermediateCalc into the accumulator
	DIV							; Perform the division - A<-(H:A)/(X); H<-Remainder
	STA		6, SP				; Store the answer into the place on the stack where the originalSecretNumberPicked was
	PULA						; Pop the saved A values off the stack
	PULX						; Pop the saved X values off the stack
	PULH						; Pop the saved H values off the stack
	RTS							; Return to the line in main where the routine is called after



main:
_Startup:
    LDHX   #__SEG_END_SSTACK 	; initialize the stack pointer
    TXS							; SP <- (H:X) -1
	CLI							; enable interrupts


mainLoop:
	;originalSecretNumberPicked <- 8
	;intermediateCalc <- 0
	;finalAnwer <- 0
    LDA 	#08								; Load value of #08 on accumulator
    STA 	originalSecretNumberPicked		; Store accumulator value(#08) in $80 
    LDA		#00								; Load value of #00 on accumulator
    STA		intermediateCalc				; Store accumulator value(#00) in $81
    LDA		#00								; Load value of #00 on accumulator
    STA		finalAnswer						; Store accumulator value(#00) in $84
    
    ; STEP 2 intermediateCalc <- squareIt(originalSecretNumberPicked);
    LDA		originalSecretNumberPicked		; Load value of originalSecretNumberPicked on accumulator
    PSHA									; originalSecretNumberPicked on accumulator is pushed onto the stack
    JSR		squareIt						; Call the routine of squareIt
    PULA									; Pull accumulator from the stack (Stack pointer + $0001)
    STA		intermediateCalc				; Store value of accumulator into intermediateCalc 
    AIS		#1								; Clean up stack
    
    ; STEP 3 intermediateCalc <- addThem(intermediateCalc, originalSecretNumberPicked)
    LDA		intermediateCalc				; Load value of intermediateCalc on accumulator
    PSHA									; intermediateCalc on accumulator is pushed onto the stack
    LDA		originalSecretNumberPicked		; Load value of originalSecretNumberPicked on accumulator
    PSHA									; originalSecretNumberPicked on accumulator is pushed onto the stack
    JSR 	addThem							; Call the routine of addThem
    PULA									; Pull accumulator from the stack (Stack pointer + $0001)
    STA		intermediateCalc				; Store value of accumulator into intermediateCalc
    AIS		#1								; Clean up stack
    
    ; STEP 4 intermediateCalc <- divideNumOneByNumTwo(intermediateCalc, originalSecretNumberPicked)
    LDA		intermediateCalc				; Load value of intermediateCalc on accumulator
    PSHA									; intermediateCalc on accumulator is pushed onto the stack
    LDA		originalSecretNumberPicked		; Load value of originalSecretNumberPicked on accumulator
    PSHA									; originalSecretNumberPicked on accumulator is pushed onto the stack
    JSR		divideNumOneByNumTwo			; Call the routine of divideNumOnebyNumTwo
    PULA									; Pull accumulator from the stack (Stack pointer + $0001)
    STA		intermediateCalc				; Store value of accumulator into intermediateCalc				
    AIS 	#1								; Clean up stack
    
    ; STEP 5 intermediateCalc <- addThem(intermediateCalc, 17)
    LDA		intermediateCalc				; Load value of intermediateCalc on accumulator				
    PSHA									; intermediateCalc on accumulator is pushed onto the stack
    LDA 	#17								; Load value of #17 on accumulator
    PSHA									; #17 on accumulator is pushed onto the stack
    JSR		addThem							; Call the routine of addThem
    PULA									; Pull accumulator from the stack (Stack pointer + $0001)
    STA		intermediateCalc				; Store value of accumulator into intermediateCalc
    AIS 	#1								; Clean up stack
    
    ; STEP 6 intermediateCalc <- addThem(intermediateCalc, -originalSecretNumberPicked)  
    LDA		intermediateCalc				; Load value of intermediateCalc on accumulator
    PSHA									; intermediateCalc on accumulator is pushed onto the stack
    LDA		originalSecretNumberPicked		; Load value of originalSecretNumberPicked on accumulator
    NEGA									; Replace the contents of accumulator with its two's complement
    PSHA									; Value on accumulator is pushed onto the stack
    JSR		addThem							; Call the routine of addThem
    PULA									; Pull accumulator from the stack (Stack pointer + $0001)
    STA		intermediateCalc    			; Store value of accumulator into intermediateCalc
    AIS		#1								; Clean up stack

	; STEP 7 finalAnswer <- divideNumOneByNumTwo(intermediateCalc, 6)
    LDA		intermediateCalc				; Load value of intermediateCalc on accumulator
    PSHA									; intermediateCalc on accumulator is pushed onto the stack
    LDA 	#06								; Load value of #06 on accumulator
    PSHA									; #06 on accumulator is pushed onto the stack
    JSR		divideNumOneByNumTwo			; Call the routine of divideNumOneByNumTwo
    PULA									; Pull accumulator from the stack (Stack pointer + $0001)
    STA		finalAnswer						; Store value of accumulator into finalAnswer
    AIS		#1								; Clean up stack								

    BRA mainLoop							; Branch mainLoop						
