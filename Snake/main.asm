//
// Snake.asm
//
// Created: 2016-04-22 13:33:39
// Author : shitsngiggles
//
.DEF rMemTemp = r16
.DEF rIndexTemp = r17
.DEF rGenericTemp = r18
.DEF rReverse = r20
.DEF rIndexTempR = r21
.DEF rAND = r22

.DSEG
	displayMatrix:
		.BYTE 8
.CSEG
 // Interrupt vector table
.ORG 0x0000
      jmp init // Reset vector
.ORG INT_VECTORS_SIZE

init:
	  // Initialize displaymatrix
	  ldi yh, HIGH(displayMatrix)
	  ldi yl, LOW(displayMatrix)

	  ldi rMemTemp, 0b00101010
	  st y, rMemTemp

	  subi yh, -1
	  ldi rMemTemp, 0b00101010
	  st y, rMemTemp

	  subi yh, -1
	  ldi rMemTemp, 0b00101010
	  st y, rMemTemp

	  subi yh, -1
	  ldi rMemTemp, 0b00101010
	  st y, rMemTemp

	  subi yh, -1
	  ldi rMemTemp, 0b00101010
	  st y, rMemTemp

	  subi yh, -1
	  ldi rMemTemp, 0b00101010
	  st y, rMemTemp

	  subi yh, -1
	  ldi rMemTemp, 0b00101010
	  st y, rMemTemp

	  subi yh, -1
	  ldi rMemTemp, 0b00101010
	  st y, rMemTemp

	  ldi yh, HIGH(displayMatrix)	// Reset y
	  ldi yl, LOW(displayMatrix)
	  // End of displaymatrix

	  // Set stackpointer to highest memory adress
      ldi rIndexTemp, HIGH(RAMEND)
      out SPH, rIndexTemp
      ldi rIndexTemp, LOW(RAMEND)
      out SPL, rIndexTemp

	  // Setting of screen-I/O
	  ldi rMemTemp, 0b00001111
	  out DDRC, rMemTemp  
	  ldi rMemTemp, 0b11111100
	  out DDRD, rMemTemp  
	  ldi rMemTemp, 0b00111111
	  out DDRB, rMemTemp 
	  

// Replace with your application code
start:
	ldi r19, 0
	ldi rIndexTemp, 0
	ldi rGenericTemp, 0b00000001
	ldi rAND, 0b11000000

renderLoop:	
	//Load memorymatrix
	ld rMemTemp, y
	ldi rIndexTempR, 0
	// Reverse order of byte
	reverse:
		subi rIndexTempR, -1
		lsl rMemTemp				// shift one bit into the carry flag
		ror rReverse				// rotate carry flag into result
		cpi rIndexTempR, 9
		brlt reverse
	ldi r23, 0
	add r23, rReverse
	lsl r23
	lsl r23

	// Set columns and rows
	out PORTC, rGenericTemp
	out PORTB, r23
	
	and r23, rAND
	out PORTD, r23

	cpi rIndexTemp, 4
	brlt skipLatterOperations
		out PORTC, r19
		add r23, rGenericTemp 
		out PORTD, r23

skipLatterOperations:	
	subi rIndexTemp, -1
	subi yh, -1
	lsl rGenericTemp

	cpi rIndexTemp, 4
	brne skipBitAdjust
		lsr rGenericTemp
		lsr rGenericTemp

skipBitAdjust:

	cpi rIndexTemp, 8
	brlt renderLoop

	ldi rIndexTemp, 0
	ldi rGenericTemp, 0b00000001
	subi yh, 7

    jmp renderLoop