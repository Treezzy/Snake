//
// Snake.asm
//
// Created: 2016-04-22 13:33:39
// Author : a15ludch
//
.DEF rMemTemp = r16
.DEF rIndexTemp = r17
.DEF rGenericTemp = r18

.DSEG
	displayMatrix:
		.BYTE 8
.CSEG
 // Interrupt vector table
.ORG 0x0000
      jmp init // Reset vector
.ORG INT_VECTORS_SIZE

init:
	  // Initialisering av bildmatris
	  ldi yh, HIGH(displayMatrix)
	  ldi yl, LOW(displayMatrix)

	  ldi rMemTemp, 0b11000001
	  st y, rMemTemp

	  subi yh, -1
	  ldi rMemTemp, 0b11000001
	  st y, rMemTemp

	  subi yh, -1
	  ldi rMemTemp, 0b11000001
	  st y, rMemTemp

	  subi yh, -1
	  ldi rMemTemp, 0b11000001
	  st y, rMemTemp

	  subi yh, -1
	  ldi rMemTemp, 0b11000010
	  st y, rMemTemp

	  subi yh, -1
	  ldi rMemTemp, 0b11000010
	  st y, rMemTemp

	  subi yh, -1
	  ldi rMemTemp, 0b11000010
	  st y, rMemTemp

	  subi yh, -1
	  ldi rMemTemp, 0b11000010
	  st y, rMemTemp

	  ldi yh, HIGH(displayMatrix)	// Återställer y
	  ldi yl, LOW(displayMatrix)
	  // Slut på bildmatris

	  // Sätt stackpekaren till högsta minnesadressen
      ldi rIndexTemp, HIGH(RAMEND)
      out SPH, rIndexTemp
      ldi rIndexTemp, LOW(RAMEND)
      out SPL, rIndexTemp

	  // Inställning av skärm-I/O
	  ldi rMemTemp, 0b00001111
	  out DDRC, rMemTemp  
	  ldi rMemTemp, 0b11111100
	  out DDRD, rMemTemp  
	  ldi rMemTemp, 0b00111111
	  out DDRB, rMemTemp 
	  
	  ldi rMemTemp, 0b00111111
	  out PORTB, rMemTemp

// Replace with your application code
start:
	ldi r19, 0
	ldi rIndexTemp, 0
	ldi rGenericTemp, 0b00000001

renderLoop:	
	//Ladda in minnesmatris
	ld rMemTemp, y

	//Ställ in kolonner och rader
	out PORTC, rGenericTemp 
	out PORTD, r19
	out PORTB, rMemTemp

	cpi rIndexTemp, 4
	brlt skipLatterOperations
		out PORTC, r19 
		out PORTD, rGenericTemp
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