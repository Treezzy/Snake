//
// Snake.asm
//
// Created: 2016-04-22 13:33:39
// Author : a15ludch
//
.DEF rInputX = r24
.DEF rInputY = r25
.DEF rOutputB = r13
.DEF rOutputC = r14
.DEF rOutputD = r15

.DEF rMemTemp = r16
.DEF rIndexTemp = r17
.DEF rRollTemp = r18
.DEF rShouldUpdate = r19
.DEF rAligned = r20
.DEF rAND = r21
.DEF rORop = r22
.DEF rGenericTemp = r23

.DEF rPosX = r12
.DEF rPosY = r11

.DSEG
	displayMatrix:
		.BYTE 8
.CSEG
 // Interrupt vector table
.ORG 0x0000
	jmp init // Reset vector
	nop
.ORG 0x0020
	jmp updateTimerInterrupt // Timer 0 overflow vector
	nop

.ORG INT_VECTORS_SIZE

init:
	  // Initialisering av bildmatris
	ldi yh, HIGH(displayMatrix)
	ldi yl, LOW(displayMatrix)
		
	ldi rMemTemp, 0b00010000
	st y, rMemTemp

	mov rPosX, rMemTemp

	subi yh, -1
	ldi rMemTemp, 0b00000000
	st y, rMemTemp

	subi yh, -1
	ldi rMemTemp, 0b00000000
	st y, rMemTemp

	subi yh, -1
	ldi rMemTemp, 0b00000000
	st y, rMemTemp

	subi yh, -1
	ldi rMemTemp, 0b00000000
	st y, rMemTemp

	subi yh, -1
	ldi rMemTemp, 0b00000000
	st y, rMemTemp

	subi yh, -1
	ldi rMemTemp, 0b00000000
	st y, rMemTemp

	subi yh, -1
	ldi rMemTemp, 0b00000000
	st y, rMemTemp

	subi yh, 7	// Återställer y
	// Slut på bildmatris

	// Sätt stackpekaren till högsta minnesadressen
    ldi rIndexTemp, HIGH(RAMEND)
    out SPH, rIndexTemp
    ldi rIndexTemp, LOW(RAMEND)
    out SPL, rIndexTemp

	// Initializing update timer
	ldi rMemTemp, 0b00000101
	out TCCR0B, rMemTemp
	ldi rMemTemp, 0b00000001
	sts TIMSK0, rMemTemp
	sei

	// Initializing joystick I/O
	ldi rAND, 0b01111111
	ldi rORop, 0b01100000
	lds rMemTemp, ADMUX

	AND rMemTemp, rAND
	OR rMemTemp, rORop
	sts ADMUX, rMemTemp

	ldi rORop, 0b10000111
	lds rMemTemp, ADCSRA
	
	OR rMemTemp, rORop
	sts ADCSRA, rMemTemp

	// Initializing screen I/O
	ldi rMemTemp, 0b00001111
	out DDRC, rMemTemp  
	ldi rMemTemp, 0b11111100
	out DDRD, rMemTemp  
	ldi rMemTemp, 0b00111111
	out DDRB, rMemTemp 

	ldi rShouldUpdate, 0b00000000
	jmp mainLoop

//##############################################################################################################################################################################################################################
//##############################################################################################################################################################################################################################
//##############################################################################################################################################################################################################################
updateTimerInterrupt:
	ldi rShouldUpdate, 0b00000001
	reti

//##############################################################################################################################################################################################################################
//##############################################################################################################################################################################################################################
//##############################################################################################################################################################################################################################
mainLoop:
	cpi rShouldUpdate, 0b0000001
	brne skipUpdate // Skip update call if shouldUpdate is not true
		call update 
	skipUpdate:
	
	call inputUpdate
	call snakeMove
	call renderStart // Render display matrix
	jmp mainLoop // Repeat main loop

//##############################################################################################################################################################################################################################
//##############################################################################################################################################################################################################################
//##############################################################################################################################################################################################################################
update:

	// Base functionality, don't touch
	ldi rShouldUpdate, 0b00000000
	ret

//##############################################################################################################################################################################################################################
//##############################################################################################################################################################################################################################
//##############################################################################################################################################################################################################################
inputUpdate:
	lds rMemTemp, ADMUX
	ldi rORop, 0b00000101
	ldi rAND, 0b11110101

	OR rMemTemp, rORop
	AND rMemTemp, rAND
	sts ADMUX, rMemTemp

	ldi rORop, 0b01000000

	lds rMemTemp, ADCSRA	
	OR rMemTemp, rORop
	sts ADCSRA, rMemTemp

	inputPoll:
	lds rMemTemp, ADCSRA
	sbrc rMemTemp, 6
	jmp inputPoll

	lds rInputX, ADCH
	//st y, rInputX
	ret

//##############################################################################################################################################################################################################################
//##############################################################################################################################################################################################################################
//##############################################################################################################################################################################################################################
snakeMove:
	cpi rInputX, 1
	brlo moveRight
	cpi rInputX, 254
	brsh moveLeft
	cpi rInputY, 1
	brlo moveUp
	cpi rInputY, 254
	brsh moveDown
	ret

moveRight:
	ldi rGenericTemp, 0b00000001
	cp rPosX, rGenericTemp
	breq return
	lsr rPosX
	jmp updatePos

moveLeft:
	ldi rGenericTemp, 0b10000000
	cp rPosX, rGenericTemp
	breq return
	lsl rPosX
	jmp updatePos

moveUp:
	ldi rGenericTemp, 8
	cp rPosY, rGenericTemp
	brsh return
	ldi rGenericTemp, -1
	sub rPosY, rGenericTemp
	jmp updatePos

moveDown:
	ldi rGenericTemp, 0
	cp rPosY, rGenericTemp
	brlo return
	ldi rGenericTemp, 1
	sub rPosY, rGenericTemp
	jmp updatePos

moveNot:
	ldi rGenericTemp, 0b00010000
	st y, rGenericTemp
	ret

updatePos:
	call resetY
	add yh, rPosY
	st y, rPosX
	sub yh, rPosY
	ret

return:
	ret

resetY:
	ldi rMemTemp, 0b00000000
	st y, rMemTemp

	subi yh, -1
	ldi rMemTemp, 0b00000000
	st y, rMemTemp

	subi yh, -1
	ldi rMemTemp, 0b00000000
	st y, rMemTemp

	subi yh, -1
	ldi rMemTemp, 0b00000000
	st y, rMemTemp

	subi yh, -1
	ldi rMemTemp, 0b00000000
	st y, rMemTemp

	subi yh, -1
	ldi rMemTemp, 0b00000000
	st y, rMemTemp

	subi yh, -1
	ldi rMemTemp, 0b00000000
	st y, rMemTemp

	subi yh, -1
	ldi rMemTemp, 0b00000000
	st y, rMemTemp
	ret

//##############################################################################################################################################################################################################################
//##############################################################################################################################################################################################################################
//##############################################################################################################################################################################################################################
renderStart:
	ldi rIndexTemp, 0
	ldi rRollTemp, 0b00000001
	ldi rAND, 0b11000000
	ldi rGenericTemp, 0

renderLoop:	
	//Load memorymatrix
	ld rMemTemp, y
	// Reverse order of byte
	ldi rAligned, 0

	// Reverse D6 and D7
	bst rMemTemp, 6
	bld rAligned, 7
	bst rMemTemp, 7
	bld rAligned, 6
	
	// Reverse B0 to B5
	bst rMemTemp, 0
	bld rAligned, 5
	bst rMemTemp, 1
	bld rAligned, 4
	bst rMemTemp, 2
	bld rAligned, 3
	bst rMemTemp, 3
	bld rAligned, 2
	bst rMemTemp, 4
	bld rAligned, 1
	bst rMemTemp, 5
	bld rAligned, 0

	// Set columns and rows
	//out PORTC, rRollTemp
	mov rOutputC, rRollTemp
	//out PORTB, rAligned
	mov rOutputB, rAligned
	
	and rAligned, rAND
	//out PORTD, rAligned
	mov rOutputD, rAligned

	cpi rIndexTemp, 4
	brlt skipLatterOperations
		//out PORTC, rGenericTemp
		mov rOutputC, rGenericTemp
		add rAligned, rRollTemp 
		//out PORTD, rAligned
		mov rOutputD, rAligned

skipLatterOperations:
	out PORTB, rOutputB
	out PORTC, rOutputC
	out PORTD, rOutputD	
	subi rIndexTemp, -1
	subi yh, -1
	lsl rRollTemp

	cpi rIndexTemp, 4
	brne skipBitAdjust
		lsr rRollTemp
		lsr rRollTemp

skipBitAdjust:

	cpi rIndexTemp, 8
	brlt renderLoop

	ldi rIndexTemp, 0
	ldi rRollTemp, 0b00000001
	subi yh, 8

    ret

