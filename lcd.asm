.include "m8535def.inc"

; vastleggen op welke pinnen de controlelijnen van het scherm liggen

.equ LCD_CS1	= 0
.equ LCD_CS2	= 1
.equ LCD_CS3	= 2
.equ LCD_CS4	= 3
.equ	LCD_RS	= 4
.equ	LCD_RW	= 5
.equ	LCD_E	= 6

; alternatieve naam voor werkregisters

.def temp		= r16
.def return	= r17
.def backup	= r18
.def argument	= r19
.def	counter 	= r20
.def	counter2 	= r21

.def pagestart	= r22
.def addrstart = r23
.def csegstart = r24

.def	gamesreg 	= r25

; interruptroutines vastleggen

.org 0x0000
rjmp reset
.org 0x0001
rjmp buttondown
.org 0x0006
rjmp ticktime
.org 0x0013
rjmp tickgame

; vaste karakters in flashgeheugen steken

CHAR_numbers:
.db 124, 162, 146, 138, 124, 0			; 0
.db 136, 132, 254, 128, 128, 0			; 1
.db 132, 194, 162, 146, 140, 0			; 2
.db  66, 130, 138, 150,  98, 0			; 3
.db  48,  40,  36, 254,  32, 0			; 4
.db  78, 138, 138, 138, 114, 0			; 5
.db 120, 148, 146, 146,  96, 0			; 6
.db   6,   2, 226,  18,  14, 0			; 7
.db 108, 146, 146, 146, 108, 0			; 8
.db  12, 146, 146,  82,  60, 0			; 9
CHAR_alfabet:
.db  64, 168, 168, 168, 240, 0			; a
.db   0,   0,   0,   0,   0, 0			; b
.db 112, 136, 136, 136,  64, 0			; c
.db 112, 136, 136, 144, 254, 0			; d
.db 112, 168, 168, 168,  48, 0			; e
.db   0,   0,   0,   0,   0, 0			; f
.db  16, 168, 168, 168, 120, 0			; g
.db   0,   0,   0,   0,   0, 0			; h
.db 136, 250, 128,   0,   0, 0			; i
.db   0,   0,   0,   0,   0, 0			; j
.db 254,  32,  80, 136,   0, 0			; k
.db   0,   0,   0,   0,   0, 0			; l
.db 248,   8,  48,   8, 240, 0			; m
.db 248,  16,   8,   8, 240, 0			; n
.db 112, 136, 136, 136, 112, 0			; o
.db 248,  40,  40,  40,  16, 0			; p
.db   0,   0,   0,   0,   0, 0			; q
.db 248,  16,   8,   8,  16, 0			; r
.db 144, 168, 168, 168,  64, 0			; s
.db   8, 126, 136, 128,  64, 0			; t
.db   0,   0,   0,   0,   0, 0			; u
.db  56,  64, 128,  64,  56, 0			; v
.db   0,   0,   0,   0,   0, 0			; w
.db   0,   0,   0,   0,   0, 0			; x
.db  24, 160, 160, 160, 120, 0			; y
.db   0,   0,   0,   0,   0, 0			; z
CHAR_colon:
.db 108, 108, 0
CHAR_komma:
.db 160,  96, 0
CHAR_excl:
.db   4,   2, 162,  18,  12, 0
CHAR_ani:
.db 254, 130, 130, 254, 130, 130, 254, 0
.db 254, 194, 162, 146, 138, 134, 254, 0
.db 254, 146, 146, 146, 146, 146, 254, 0
.db 254, 134, 138, 146, 162, 194, 254, 0
CHAR_logo:
.db  64,  78,  81,  81,  73,  73,  49,   1, 125,   9,   5, 0
.db   5, 121,   1, 101,  85,  85,  37, 121,   1, 127,   0, 0
.db  17,  41,  69,   1,  57,  85,  85,  85,   9,   1,   0, 0
.db  15,  48,  64,  64,  32,  32,  32,  70,  73,  51,   3, 0
CHAR_by:
.db 127,  68,  69,  69,  57,   1,  77,  81,  81,  81,  61,   1, 0
.db  65, 127,  73,  73,  65, 127,  65,  73,  85,  99,  65,  65, 0

reset:
	; stackpointer initialiseren

	ldi		temp, low(RAMEND)
	out		SPL, temp
	ldi		temp, high(RAMEND)
	out		SPH, temp

	; vastleggen van poortrichtingen

	ldi		temp, 0b11111111			; output
	out		DDRA, temp
	out		DDRC, temp
	ldi		temp, 0b00000000			; en direct op 0 zetten
	out		PORTA, temp
	out		PORTC, temp

	ldi		temp, 0b00000000			; input
	out		DDRD, temp

	; instellen IRQ1

	ldi		temp, 0b00000011			; instellen registers voor IRQ0
	out		MCUCR, temp
	ldi		temp, 0b01000000
	out		GICR, temp

	; tijdgeheugen in SRAM leegmaken

	ldi		ZL, low(time)
	ldi		ZH, high(time)
	ldi		counter, 0b00000100
	gotime:
		ldi		temp, 0b00000000
		st		Z+, temp
		dec		counter
		ldi		temp, 0b00000000
		cpse		counter, temp
		rjmp		gotime

	; scoregeheugen in SRAM leegmaken

	ldi		ZL, low(score)
	ldi		ZH, high(score)
	ldi		counter, 0b00000011
	goscore:
		ldi		temp, 0b00000000
		st		Z+, temp
		dec		counter
		ldi		temp, 0b00000000
		cpse		counter, temp
		rjmp		goscore

	; animatiegeheugen in SRAM leegmaken

	ldi		ZL, low(animation)
	ldi		ZH, high(animation)
	ldi		temp, 0b00000000
	st		Z+, temp
	st		Z+, temp

	; tijdtimer instellen

	ldi 		temp, 0b00000000
	out 		TCCR1A, temp
	ldi		temp, 0b00001011			; laatste 3 bits stellen prescaler in
	out		TCCR1B, temp
	ldi		temp, 0b00000000
	out	 	TCNT1H, temp
	out		TCNT1L, temp
	ldi		temp, 0b00111111
	out		OCR1AH, temp
	ldi		temp, 0b11100000
	out		OCR1AL, temp

	; gametimer instellen

	ldi		temp, 0b00001101			; laatste 3 bits stellen prescaler in
	out		TCCR0, temp
	ldi		temp, 0b00000000
	out		TCNT0, temp
	ldi		temp, 0b01110000
	out		OCR0, temp

	; timerregister

	ldi 		temp, 0b00000000			; we starten de timers nog niet
	out 		TIMSK, temp

	; scherm initialiseren, leegmaken en kader tekenen

	rcall	LCD_init
	rcall	LCD_fullclean
	rcall	LCD_drawborder
	rcall	drawlogo

	; slanggeheugen in SRAM leegmaken

	ldi		ZH, high(snake)
	ldi		ZL, low(snake)
	ldi		counter, 0b11111111
	emptysnakego:
		ldi		temp, 0b00000000
		st		Z+, temp
		dec		counter
		ldi		temp, 0b00000000
		cpse		counter, temp
		rjmp		emptysnakego

	; aanmaken van standaardslang

	ldi		ZH, high(snake)
	ldi		ZL, low(snake)

	ldi		temp, 0b01110000
	st		Z+, temp
	ldi		temp, 0b11011000
	st		Z+, temp
	ldi		temp, 0b01110010
	st		Z+, temp
	ldi		temp, 0b11011000
	st		Z+, temp
	ldi		temp, 0b01110100
	st		Z+, temp
	ldi		temp, 0b11011000
	st		Z+, temp
	ldi		temp, 0b01110110
	st		Z+, temp
	ldi		temp, 0b11011000
	st		Z+, temp

	; game statusregister initialiseren

	ldi		gamesreg, 0b00001000		; we starten het game in pauzestand

	; tijd, animatie en slang voor eerste keer tekenen

	rcall	drawtime
	rcall	drawani
	rcall	snakedraw
	rcall	drawscore
	rcall	pressanykey

	; starten van alle interrupts

	sei

	; leggen van het eerste voedselblokje

	rcall	generatefood

loop:
	rjmp		loop

ticktime:
	rcall	calculatetime				; berekenen van de huidige tijd
	rcall	drawtime					; huidige tijd weergeven
reti

tickgame:
	rcall	drawani					; animatie updaten
	rcall	snaketail					; staart verwijderen van het scherm
	rcall	snakemove					; slang verplaatsen
	rcall	snakedraw					; slang weergeven
reti

buttondown:
	sbrc		gamesreg, 3
	rjmp		buttondownunpauze
	sbrc		gamesreg, 4
	rjmp		buttondownrestart
	rjmp		buttondownplay

	buttondownunpauze:
		ldi 		temp, 0b00010010		; we starten de timers
		out 		TIMSK, temp
		andi		gamesreg, 0b11110111
		rcall	cleanmessage
		rjmp		exitbuttondown

	buttondownrestart:
		rcall	reset				; reset the game
		rjmp		exitbuttondown

	buttondownplay:
		andi		gamesreg, 0b11111001

		in		temp, PIND			; pinnen van poort D uitlezen
		sbrc		temp, 3				; knop 3 -> up
		rjmp		buttondownup
		sbrc		temp, 4				; knop 4 -> links
		rjmp		buttondownleft
		sbrc		temp, 5				; knop 5 -> rechts
		rjmp		buttondownright
		sbrc		temp, 6				; knop 6 -> down
		rjmp		buttondowndown

		buttondownup:
			ldi		temp, 0b00000010
			or		gamesreg, temp
			rjmp		exitbuttondown
		buttondownleft:
			ldi		temp, 0b00000000
			or		gamesreg, temp
			rjmp		exitbuttondown
		buttondownright:
			ldi		temp, 0b00000100
			or		gamesreg, temp
			rjmp		exitbuttondown
		buttondowndown:
			ldi		temp, 0b00000110
			or		gamesreg, temp
			rjmp		exitbuttondown

	exitbuttondown:
reti

generatefood:
	generatefoodcalculate:
		ldi		counter, 0b00000000
		ldi		counter2, 0b00000000

		in		backup, TCNT0
		in		temp, TCNT1L
		mul		backup, temp
		mov		backup, r0
		in		temp, TCNT1L
		eor		temp, backup
		andi		temp, 0b00111111
		lsl		temp
		or		counter, temp

		in		backup, TCNT0
		in		temp, TCNT1L
		mul		backup, temp
		mov		backup, r0
		in		temp, TCNT1L
		eor		temp, backup
		andi		temp, 0b00000110
		swap		temp
		lsl		temp
		or		counter, temp

		in		backup, TCNT0
		in		temp, TCNT1L
		mul		backup, temp
		mov		backup, r0
		in		temp, TCNT1L
		eor		temp, backup
		andi		temp, 0b00001110
		swap		temp
		or		counter2, temp

		in		backup, TCNT0
		in		temp, TCNT1L
		mul		backup, temp
		mov		backup, r0
		in		temp, TCNT1L
		eor		temp, backup
		andi		temp, 0b00000011
		lsl		temp
		lsl		temp
		lsl		temp
		or		counter2, temp

		mov		backup, counter
		andi		backup, 0b11000000
		ldi		temp, 0b00000000
		cp		backup, temp
		breq		gfccseg00
		ldi		temp, 0b01000000
		cp		backup, temp
		breq		gfccseg01
		ldi		temp, 0b10000000
		cp		backup, temp
		breq		gfccseg10
		ldi		temp, 0b11000000
		cp		backup, temp
		breq		gfccseg11

		generatefoodcalculatesub:
			rjmp		generatefoodcalculate

		gfccseg00:
			mov		backup, counter2
			andi		backup, 0b11100000
			swap		backup
			lsr		backup
			ldi		temp, 0b00000010
			cp		backup, temp
			brmi		generatefoodcalculatesub
			mov		backup, counter
			andi		backup, 0b00111111
			ldi		temp, 0b00000110
			cp		backup, temp
			brmi		generatefoodcalculatesub
			rjmp		generatefoodcont

		generatefoodcalculatesub2:
			rjmp		generatefoodcalculatesub

		gfccseg01:
			mov		backup, counter2
			andi		backup, 0b11100000
			swap		backup
			lsr		backup
			ldi		temp, 0b00000010
			cp		backup, temp
			brmi		generatefoodcalculatesub
			mov		backup, counter
			andi		backup, 0b00111111
			ldi		temp, 0b00111000
			cp		backup, temp
			brpl		generatefoodcalculatesub
			rjmp		generatefoodcont

		gfccseg10:
			mov		backup, counter2
			andi		backup, 0b11100000
			swap		backup
			lsr		backup
			ldi		temp, 0b00000011
			cp		backup, temp
			brpl		generatefoodcalculatesub2
			mov		backup, counter
			andi		backup, 0b00111111
			ldi		temp, 0b00000110
			cp		backup, temp
			brmi		generatefoodcalculatesub2
			rjmp		generatefoodcont

		gfccseg11:
			mov		backup, counter2
			andi		backup, 0b11100000
			swap		backup
			lsr		backup
			ldi		temp, 0b00000011
			cp		backup, temp
			brpl		generatefoodcalculatesub2
			mov		backup, counter
			andi		backup, 0b00111111
			ldi		temp, 0b00111000
			cp		backup, temp
			brpl		generatefoodcalculatesub2
			rjmp		generatefoodcont

	generatefoodcont:

	ldi		ZH, high(food)
	ldi		ZL, low(food)

	st		Z+, counter
	st		Z+, counter2

	rcall	snakegetcoord
	mov		counter, return
	mov		counter2, return
	mov		backup, return

	mov		argument, pagestart
	rcall	LCD_setpage
	mov		argument, addrstart
	rcall	LCD_setaddress
	mov		argument, csegstart
	rcall	LCD_setcs

	rcall	LCD_wait
	rcall	LCD_read
	eor		counter, return
	or		counter2, return

	cp		counter, counter2
	brne		generatefoodcalculatesub2

	mov		argument, pagestart
	rcall	LCD_setpage
	mov		argument, addrstart
	rcall	LCD_setaddress
	mov		argument, csegstart
	rcall	LCD_setcs

	mov		argument, backup
	rcall	LCD_wait
	rcall	LCD_write
	mov		argument, backup
	rcall	LCD_wait
	rcall	LCD_write
ret

snakemove:
	rcall	snakehead

	rcall	snakegetcoord
	mov		counter, return
	mov		counter2, return

	mov		argument, pagestart
	rcall	LCD_setpage
	mov		argument, addrstart
	rcall	LCD_setaddress
	mov		argument, csegstart
	rcall	LCD_setcs

	rcall	LCD_wait
	rcall	LCD_read
	eor		counter, return
	or		counter2, return

	andi		gamesreg, 0b11111110

	cp		counter, counter2
	brne		snakehit
	rjmp		snakemovecont

	snakehit:
		rcall	snakehead

		ldi		ZH, high(food)
		ldi		ZL, low(food)

		ld		temp, Z+
		cp		counter, temp
		brne		endgame
		ld		temp, Z+
		cp		counter2, temp
		brne		endgame
		rjmp		snakehitcont

		endgame:
			ldi 		temp, 0b00000000
			out 		TIMSK, temp
			rcall	gameover
			ldi		temp, 0b00010000
			or		gamesreg, temp
			rjmp		exitsnakemove

		snakehitcont:
			rcall	incrementscore
			rcall	drawscore
			rcall	generatefood
			ldi		temp, 0b00000001
			or		gamesreg, temp

	snakemovecont:
		rcall	snakehead

		ldi		YH, high(snakebuffer)
		ldi		YL, low(snakebuffer)

		ldi		ZH, high(snake)
		ldi		ZL, low(snake)
		snakemovego:
			ldd		temp, Z + 0
			std		Y + 0, temp
			ldd		temp, Z + 1
			std		Y + 1, temp

			st		Z+, counter
			st		Z+, counter2
			ldd		counter, Y + 0
			ldd		counter2, Y + 1

			ldi		temp, 0b00000000
			cp		counter, temp
			breq		snakemovecheck
			rjmp		snakemovego
			snakemovecheck:
				cp		counter2, temp
				breq		snakemovecont2
				rjmp		snakemovego
		snakemovecont2:

		sbrc		gamesreg, 0
		rjmp		exitsnakemove

		ldi		temp, 0b00000000
		st		-Z, temp
		st		-Z, temp

	exitsnakemove:
ret

snakehead:
	ldi		ZH, high(snake)
	ldi		ZL, low(snake)
	ld		counter, Z+
	ld		counter2, Z+

	rcall	snakegetcoord

	sbrc		gamesreg, 1
	rjmp		snakeheadupdown
	rjmp		snakeheadleftright
	snakeheadupdown:
		sbrs		gamesreg, 2
		rjmp		moveup
		rjmp		movedownsub1
	snakeheadleftright:
		sbrs		gamesreg, 2
		rjmp		moveleft
		rjmp		moverightsub

	moveleft:							; page en position blijven identiek
		ldi		temp, 0b00000001
		cp		csegstart, temp
		breq		leftleft
		ldi		temp, 0b00000010
		cp		csegstart, temp
		breq		leftright
		ldi		temp, 0b00000011
		cp		csegstart, temp
		breq		leftleft
		ldi		temp, 0b00000100
		cp		csegstart, temp
		breq		leftright

		leftleft:
			ldi		temp, 0b00000000
			cp		addrstart, temp
			breq		leftleftcseg
			ldi		temp, 0b00000010
			sub		addrstart, temp
			rjmp		leftcont
			leftleftcseg:
				ldi		temp, 0b00000001
				add		csegstart, temp
				ldi		temp, 0b00111110
				mov		addrstart, temp
			rjmp		leftcont

		leftright:
			ldi		temp, 0b00000000
			cp		addrstart, temp
			breq		leftrightcseg
			ldi		temp, 0b00000010
			sub		addrstart, temp
			rjmp		leftcont
			leftrightcseg:
				ldi		temp, 0b00000001
				sub		csegstart, temp
				ldi		temp, 0b00111110
				mov		addrstart, temp
			rjmp		leftcont

		leftcont:
		rjmp		snakeheadcont

	moverightsub:
		rjmp		moveright
	movedownsub1:
		rjmp		movedownsub2

	moveup:							; address blijft uniek
		ldi		temp, 0b00000001
		cp		csegstart, temp
		breq		upup
		ldi		temp, 0b00000010
		cp		csegstart, temp
		breq		upup
		ldi		temp, 0b00000011
		cp		csegstart, temp
		breq		updown
		ldi		temp, 0b00000100
		cp		csegstart, temp
		breq		updown

		upup:
			ldi		temp, 0b00000011
			cp		return, temp
			breq		upuppage
			lsr		return
			lsr		return
			rjmp		upupcont
			upuppage:
				ldi		temp, 0b11000000
				mov		return, temp
				ldi		temp, 0b00000001
				sub		pagestart, temp
				ldi		temp, 0b00000000
				cp		pagestart, temp
				breq		upupcseg
				rjmp		upupcont
				upupcseg:
					ldi		temp, 0b00000100
					mov		pagestart, temp
					ldi		temp, 0b00000010
					add		csegstart, temp
			upupcont:
			rjmp		upcont

		updown:
			ldi		temp, 0b00000011
			cp		return, temp
			breq		updownpage
			lsr		return
			lsr		return
			rjmp		updowncont
			updownpage:
				ldi		temp, 0b11000000
				mov		return, temp
				ldi		temp, 0b00000001
				sub		pagestart, temp
				ldi		temp, 0b11111111
				cp		pagestart, temp
				breq		updowncseg
				rjmp		updowncont
				updowncseg:
					ldi		temp, 0b00000111
					mov		pagestart, temp
					ldi		temp, 0b00000010
					sub		csegstart, temp
			updowncont:
			rjmp		upcont

		upcont:
		rjmp		snakeheadcont

	movedownsub2:
		rjmp		movedown

	moveright:						; page en position blijven identiek
		ldi		temp, 0b00000001
		cp		csegstart, temp
		breq		rightleft
		ldi		temp, 0b00000010
		cp		csegstart, temp
		breq		rightright
		ldi		temp, 0b00000011
		cp		csegstart, temp
		breq		rightleft
		ldi		temp, 0b00000100
		cp		csegstart, temp
		breq		rightright

		rightleft:
			ldi		temp, 0b00111110
			cp		addrstart, temp
			breq		rightleftcseg
			ldi		temp, 0b00000010
			add		addrstart, temp
			rjmp		rightcont
			rightleftcseg:
				ldi		temp, 0b00000001
				add		csegstart, temp
				ldi		temp, 0b00000000
				mov		addrstart, temp
			rjmp		rightcont

		rightright:
			ldi		temp, 0b00111110
			cp		addrstart, temp
			breq		rightrightcseg
			ldi		temp, 0b00000010
			add		addrstart, temp
			rjmp		rightcont
			rightrightcseg:
				ldi		temp, 0b00000001
				sub		csegstart, temp
				ldi		temp, 0b00000000
				mov		addrstart, temp
			rjmp		rightcont

		rightcont:
		rjmp		snakeheadcont

	movedown:							; address blijft uniek
		ldi		temp, 0b00000001
		cp		csegstart, temp
		breq		downup
		ldi		temp, 0b00000010
		cp		csegstart, temp
		breq		downup
		ldi		temp, 0b00000011
		cp		csegstart, temp
		breq		downdown
		ldi		temp, 0b00000100
		cp		csegstart, temp
		breq		downdown

		downup:
			ldi		temp, 0b11000000
			cp		return, temp
			breq		downuppage
			lsl		return
			lsl		return
			rjmp		downupcont
			downuppage:
				ldi		temp, 0b00000011
				mov		return, temp
				ldi		temp, 0b00000001
				add		pagestart, temp
				ldi		temp, 0b00001000
				cp		pagestart, temp
				breq		downupcseg
				rjmp		downupcont
				downupcseg:
					ldi		temp, 0b00000000
					mov		pagestart, temp
					ldi		temp, 0b00000010
					sub		csegstart, temp
			downupcont:
			rjmp		downcont

		downdown:
			ldi		temp, 0b11000000
			cp		return, temp
			breq		downdownpage
			lsl		return
			lsl		return
			rjmp		downdowncont
			downdownpage:
				ldi		temp, 0b00000011
				mov		return, temp
				ldi		temp, 0b00000001
				add		pagestart, temp
				ldi		temp, 0b00000101
				cp		pagestart, temp
				breq		downdowncseg
				rjmp		downdowncont
				downdowncseg:
					ldi		temp, 0b00000001
					mov		pagestart, temp
					ldi		temp, 0b00000010
					sub		csegstart, temp
			downdowncont:
			rjmp		downcont

		downcont:
		rjmp		snakeheadcont

	snakeheadcont:

	ldi		counter, 0b00000000
	ldi		counter2, 0b00000000

	ldi		temp, 0b00000001
	sub		csegstart, temp
	andi		csegstart, 0b00000011
	swap		csegstart
	lsl		csegstart
	lsl		csegstart
	or		counter, csegstart

	andi		addrstart, 0b00111111
	or		counter, addrstart

	andi		pagestart, 0b00000111
	swap		pagestart
	lsl		pagestart
	or		counter2, pagestart

	ldi		temp, 0b00000011
	cp		return, temp
	breq		snakehead00
	ldi		temp, 0b00001100
	cp		return, temp
	breq		snakehead01
	ldi		temp, 0b00110000
	cp		return, temp
	breq		snakehead10
	ldi		temp, 0b11000000
	cp		return, temp
	breq		snakehead11

	snakehead00:
		ldi		temp, 0b00000000
		or		counter2, temp
		rjmp		exitsnakehead
	snakehead01:
		ldi		temp, 0b00001000
		or		counter2, temp
		rjmp		exitsnakehead
	snakehead10:
		ldi		temp, 0b00010000
		or		counter2, temp
		rjmp		exitsnakehead
	snakehead11:
		ldi		temp, 0b00011000
		or		counter2, temp
		rjmp		exitsnakehead

	exitsnakehead:
ret

snakegetcoord:
	mov		argument, counter
	andi		argument, 0b11000000
	swap		argument
	lsr		argument
	lsr		argument
	ldi		temp, 0b00000001
	add		argument, temp
	mov		csegstart, argument
	mov		argument, counter
	andi		argument, 0b00111111
	mov		addrstart, argument

	mov		argument, counter2
	andi		argument, 0b11100000
	swap		argument
	lsr		argument
	mov		pagestart, argument
	mov		argument, counter2
	andi		argument, 0b00011000
	lsr		argument
	lsr		argument
	lsr		argument
	mov		backup, counter
	mov		counter, argument
	ldi		argument, 0b00000011
	snakegetcoordgo:
		ldi		temp, 0b00000000
		cp		counter, temp
		breq		snakegetcoordcont
		lsl		argument
		lsl		argument
		dec		counter
		rjmp		snakegetcoordgo
	snakegetcoordcont:
	mov		counter, backup
	mov		return, argument
ret

snaketail:
	ldi		counter, 0b00000000

	ldi		ZH, high(snake)
	ldi		ZL, low(snake)
	snaketailgo:
		ld		backup, Z+
		ldi		temp, 0b00000000
		cp		backup, temp
		breq		snaketailcheck
		rjmp		snaketailcheckcont
		snaketailcheck:
			ld		backup, Z
			cp		backup, temp
			breq		snaketailcont
		snaketailcheckcont:
			ld		backup, Z+
			ldi		temp, 0b00000001
			add		counter, temp
			rjmp		snaketailgo
	snaketailcont:

	mov		backup, counter

	ldi		ZH, high(snake)
	ldi		ZL, low(snake)
	snaketailgo2:
		dec		backup
		ld		counter, Z+
		ld		counter2, Z+
		ldi		temp, 0b00000000
		cp		backup, temp
		breq		snaketailcont2
		rjmp		snaketailgo2
	snaketailcont2:

	rcall	snakegetcoord
	mov		backup, return

	mov		argument, pagestart
	rcall	LCD_setpage
	mov		argument, addrstart
	rcall	LCD_setaddress
	mov		argument, csegstart
	rcall	LCD_setcs

	rcall	LCD_wait
	rcall	LCD_read
	eor		backup, return

	mov		argument, pagestart
	rcall	LCD_setpage
	mov		argument, addrstart
	rcall	LCD_setaddress
	mov		argument, csegstart
	rcall	LCD_setcs

	mov		argument, backup
	rcall	LCD_wait
	rcall	LCD_write
	mov		argument, backup
	rcall	LCD_wait
	rcall	LCD_write
ret

snakedraw:
	ldi		ZH, high(snake)
	ldi		ZL, low(snake)
	snakedrawgo:
		ld		counter, Z+			; we laden eerste deel van segment in
		ld		counter2, Z+			; we laden tweede deel van segment in

		rcall	snakegetcoord			; we laten coordinaten berekenen
		mov		backup, return

		ldi		temp, 0b00000000		; als adres 000000, het codesegment 1, en de page 0, dan hebben we einde bereikt
		cp		addrstart, temp
		breq		snakedrawcheck
		rjmp		snakedrawgocont
		snakedrawcheck:
			ldi		temp, 0b00000001
			cp		csegstart, temp
			breq		snakedrawcheck2
			rjmp		snakedrawgocont
			snakedrawcheck2:
				ldi		temp, 0b00000000
				cp		pagestart, temp
				breq		exitsnakedraw
		snakedrawgocont:

		mov		argument, pagestart
		rcall	LCD_setpage
		mov		argument, addrstart
		rcall	LCD_setaddress
		mov		argument, csegstart
		rcall	LCD_setcs

		rcall	LCD_wait
		rcall	LCD_read
		mov		temp, backup
		or		backup, return

		mov		argument, pagestart
		rcall	LCD_setpage
		mov		argument, addrstart
		rcall	LCD_setaddress
		mov		argument, csegstart
		rcall	LCD_setcs

		mov		argument, backup
		rcall	LCD_wait
		rcall	LCD_write
		mov		argument, backup
		rcall	LCD_wait
		rcall	LCD_write

		rjmp		snakedrawgo
	exitsnakedraw:
ret

cleanmessage:
	ldi		argument, 0b00000101
	rcall	LCD_setpage
	ldi		argument, 0b00000000
	rcall	LCD_setaddress
	rcall	LCD_setcs3

	ldi		counter, 0b01000000
	cleanmessagego:
		ldi		argument, 0b00000000
		rcall	LCD_wait
		rcall	LCD_write
		dec		counter
		ldi		temp, 0b00000000
		cpse		counter, temp
		rjmp		cleanmessagego

	ldi		argument, 0b00000101
	rcall	LCD_setpage
	ldi		argument, 0b00000000
	rcall	LCD_setaddress
	rcall	LCD_setcs4

	ldi		counter, 0b01000000
	cleanmessagego2:
		ldi		argument, 0b00000000
		rcall	LCD_wait
		rcall	LCD_write
		dec		counter
		ldi		temp, 0b00000000
		cpse		counter, temp
		rjmp		cleanmessagego2

	exitcleanmessage:
ret

gameover:
	ldi		pagestart, 0b00000101
	ldi		addrstart, 0b00000000
	ldi		csegstart, 0b00000011

	ldi		ZH, high(2 * CHAR_alfabet)	; g
	ldi		ZL, low(2 * CHAR_alfabet)
	ldi		counter, 0b00000110
	ldi		temp, 0b00000110
	mul		counter, temp
	mov		counter, r0
	add		ZL, counter
	rcall	CHAR_draw

	ldi		temp, 0b00000001
	add		addrstart, temp

	ldi		ZH, high(2 * CHAR_alfabet)	; a
	ldi		ZL, low(2 * CHAR_alfabet)
	ldi		counter, 0b00000000
	ldi		temp, 0b00000110
	mul		counter, temp
	mov		counter, r0
	add		ZL, counter
	rcall	CHAR_draw

	ldi		temp, 0b00000001
	add		addrstart, temp

	ldi		ZH, high(2 * CHAR_alfabet)	; m
	ldi		ZL, low(2 * CHAR_alfabet)
	ldi		counter, 0b00001100
	ldi		temp, 0b00000110
	mul		counter, temp
	mov		counter, r0
	add		ZL, counter
	rcall	CHAR_draw

	ldi		temp, 0b00000001
	add		addrstart, temp

	ldi		ZH, high(2 * CHAR_alfabet)	; e
	ldi		ZL, low(2 * CHAR_alfabet)
	ldi		counter, 0b00000100
	ldi		temp, 0b00000110
	mul		counter, temp
	mov		counter, r0
	add		ZL, counter
	rcall	CHAR_draw

	ldi		temp, 0b00000001
	add		addrstart, temp
	ldi		temp, 0b00000001
	add		addrstart, temp
	ldi		temp, 0b00000001
	add		addrstart, temp

	ldi		ZH, high(2 * CHAR_alfabet)	; o
	ldi		ZL, low(2 * CHAR_alfabet)
	ldi		counter, 0b00001110
	ldi		temp, 0b00000110
	mul		counter, temp
	mov		counter, r0
	add		ZL, counter
	rcall	CHAR_draw

	ldi		temp, 0b00000001
	add		addrstart, temp

	ldi		ZH, high(2 * CHAR_alfabet)	; v
	ldi		ZL, low(2 * CHAR_alfabet)
	ldi		counter, 0b00010101
	ldi		temp, 0b00000110
	mul		counter, temp
	mov		counter, r0
	add		ZL, counter
	rcall	CHAR_draw

	ldi		temp, 0b00000001
	add		addrstart, temp

	ldi		ZH, high(2 * CHAR_alfabet)	; e
	ldi		ZL, low(2 * CHAR_alfabet)
	ldi		counter, 0b00000100
	ldi		temp, 0b00000110
	mul		counter, temp
	mov		counter, r0
	add		ZL, counter
	rcall	CHAR_draw

	ldi		temp, 0b00000001
	add		addrstart, temp

	ldi		ZH, high(2 * CHAR_alfabet)	; r
	ldi		ZL, low(2 * CHAR_alfabet)
	ldi		counter, 0b00010001
	ldi		temp, 0b00000110
	mul		counter, temp
	mov		counter, r0
	add		ZL, counter
	rcall	CHAR_draw

	ldi		temp, 0b00000001
	add		addrstart, temp

	ldi		ZH, high(2 * CHAR_komma)		; ,
	ldi		ZL, low(2 * CHAR_komma)
	rcall	CHAR_draw

	ldi		temp, 0b00000001
	add		addrstart, temp
	ldi		temp, 0b00000001
	add		addrstart, temp
	ldi		temp, 0b00000001
	add		addrstart, temp

	ldi		ZH, high(2 * CHAR_alfabet)	; p
	ldi		ZL, low(2 * CHAR_alfabet)
	ldi		counter, 0b00001111
	ldi		temp, 0b00000110
	mul		counter, temp
	mov		counter, r0
	add		ZL, counter
	rcall	CHAR_draw

	ldi		temp, 0b00000001
	add		addrstart, temp

	ldi		ZH, high(2 * CHAR_alfabet)	; r
	ldi		ZL, low(2 * CHAR_alfabet)
	ldi		counter, 0b00010001
	ldi		temp, 0b00000110
	mul		counter, temp
	mov		counter, r0
	add		ZL, counter
	rcall	CHAR_draw

	ldi		temp, 0b00000001
	add		addrstart, temp

	ldi		ZH, high(2 * CHAR_alfabet)	; e
	ldi		ZL, low(2 * CHAR_alfabet)
	ldi		counter, 0b00000100
	ldi		temp, 0b00000110
	mul		counter, temp
	mov		counter, r0
	add		ZL, counter
	rcall	CHAR_draw

	ldi		temp, 0b00000001
	add		addrstart, temp

	ldi		ZH, high(2 * CHAR_alfabet)	; s
	ldi		ZL, low(2 * CHAR_alfabet)
	ldi		counter, 0b00010010
	ldi		temp, 0b00000110
	mul		counter, temp
	mov		counter, r0
	add		ZL, counter
	rcall	CHAR_draw

	ldi		temp, 0b00000001
	add		addrstart, temp

	ldi		ZH, high(2 * CHAR_alfabet)	; s
	ldi		ZL, low(2 * CHAR_alfabet)
	ldi		counter, 0b00010010
	ldi		temp, 0b00000110
	mul		counter, temp
	mov		counter, r0
	add		ZL, counter
	rcall	CHAR_draw

	ldi		temp, 0b00000001
	add		addrstart, temp
	ldi		temp, 0b00000001
	add		addrstart, temp
	ldi		temp, 0b00000001
	add		addrstart, temp

	ldi		ZH, high(2 * CHAR_alfabet)	; a
	ldi		ZL, low(2 * CHAR_alfabet)
	ldi		counter, 0b00000000
	ldi		temp, 0b00000110
	mul		counter, temp
	mov		counter, r0
	add		ZL, counter
	rcall	CHAR_draw

	ldi		temp, 0b00000001
	add		addrstart, temp

	ldi		ZH, high(2 * CHAR_alfabet)	; n
	ldi		ZL, low(2 * CHAR_alfabet)
	ldi		counter, 0b00001101
	ldi		temp, 0b00000110
	mul		counter, temp
	mov		counter, r0
	add		ZL, counter
	rcall	CHAR_draw

	ldi		temp, 0b00000001
	add		addrstart, temp

	ldi		ZH, high(2 * CHAR_alfabet)	; y
	ldi		ZL, low(2 * CHAR_alfabet)
	ldi		counter, 0b00011000
	ldi		temp, 0b00000110
	mul		counter, temp
	mov		counter, r0
	add		ZL, counter
	rcall	CHAR_draw

	ldi		temp, 0b00000001
	add		addrstart, temp
	ldi		temp, 0b00000001
	add		addrstart, temp
	ldi		temp, 0b00000001
	add		addrstart, temp

	ldi		ZH, high(2 * CHAR_alfabet)	; k
	ldi		ZL, low(2 * CHAR_alfabet)
	ldi		counter, 0b00001010
	ldi		temp, 0b00000110
	mul		counter, temp
	mov		counter, r0
	add		ZL, counter
	rcall	CHAR_draw

	ldi		temp, 0b00000001
	add		addrstart, temp

	ldi		ZH, high(2 * CHAR_alfabet)	; e
	ldi		ZL, low(2 * CHAR_alfabet)
	ldi		counter, 0b00000100
	ldi		temp, 0b00000110
	mul		counter, temp
	mov		counter, r0
	add		ZL, counter
	rcall	CHAR_draw

	ldi		temp, 0b00000001
	add		addrstart, temp

	ldi		ZH, high(2 * CHAR_alfabet)	; y
	ldi		ZL, low(2 * CHAR_alfabet)
	ldi		counter, 0b00011000
	ldi		temp, 0b00000110
	mul		counter, temp
	mov		counter, r0
	add		ZL, counter
	rcall	CHAR_draw
ret

pressanykey:
	ldi		pagestart, 0b00000101
	ldi		addrstart, 0b00000000
	ldi		csegstart, 0b00000011

	ldi		ZH, high(2 * CHAR_alfabet)	; r
	ldi		ZL, low(2 * CHAR_alfabet)
	ldi		counter, 0b00010001
	ldi		temp, 0b00000110
	mul		counter, temp
	mov		counter, r0
	add		ZL, counter
	rcall	CHAR_draw

	ldi		temp, 0b00000001
	add		addrstart, temp

	ldi		ZH, high(2 * CHAR_alfabet)	; e
	ldi		ZL, low(2 * CHAR_alfabet)
	ldi		counter, 0b00000100
	ldi		temp, 0b00000110
	mul		counter, temp
	mov		counter, r0
	add		ZL, counter
	rcall	CHAR_draw

	ldi		temp, 0b00000001
	add		addrstart, temp

	ldi		ZH, high(2 * CHAR_alfabet)	; a
	ldi		ZL, low(2 * CHAR_alfabet)
	ldi		counter, 0b00000000
	ldi		temp, 0b00000110
	mul		counter, temp
	mov		counter, r0
	add		ZL, counter
	rcall	CHAR_draw

	ldi		temp, 0b00000001
	add		addrstart, temp

	ldi		ZH, high(2 * CHAR_alfabet)	; d
	ldi		ZL, low(2 * CHAR_alfabet)
	ldi		counter, 0b00000011
	ldi		temp, 0b00000110
	mul		counter, temp
	mov		counter, r0
	add		ZL, counter
	rcall	CHAR_draw

	ldi		temp, 0b00000001
	add		addrstart, temp

	ldi		ZH, high(2 * CHAR_alfabet)	; y
	ldi		ZL, low(2 * CHAR_alfabet)
	ldi		counter, 0b00011000
	ldi		temp, 0b00000110
	mul		counter, temp
	mov		counter, r0
	add		ZL, counter
	rcall	CHAR_draw

	ldi		temp, 0b00000001
	add		addrstart, temp

	ldi		ZH, high(2 * CHAR_excl)		; ?
	ldi		ZL, low(2 * CHAR_excl)
	rcall	CHAR_draw

	ldi		temp, 0b00000001
	add		addrstart, temp
	ldi		temp, 0b00000001
	add		addrstart, temp
	ldi		temp, 0b00000001
	add		addrstart, temp

	ldi		ZH, high(2 * CHAR_alfabet)	; p
	ldi		ZL, low(2 * CHAR_alfabet)
	ldi		counter, 0b00001111
	ldi		temp, 0b00000110
	mul		counter, temp
	mov		counter, r0
	add		ZL, counter
	rcall	CHAR_draw

	ldi		temp, 0b00000001
	add		addrstart, temp

	ldi		ZH, high(2 * CHAR_alfabet)	; r
	ldi		ZL, low(2 * CHAR_alfabet)
	ldi		counter, 0b00010001
	ldi		temp, 0b00000110
	mul		counter, temp
	mov		counter, r0
	add		ZL, counter
	rcall	CHAR_draw

	ldi		temp, 0b00000001
	add		addrstart, temp

	ldi		ZH, high(2 * CHAR_alfabet)	; e
	ldi		ZL, low(2 * CHAR_alfabet)
	ldi		counter, 0b00000100
	ldi		temp, 0b00000110
	mul		counter, temp
	mov		counter, r0
	add		ZL, counter
	rcall	CHAR_draw

	ldi		temp, 0b00000001
	add		addrstart, temp

	ldi		ZH, high(2 * CHAR_alfabet)	; s
	ldi		ZL, low(2 * CHAR_alfabet)
	ldi		counter, 0b00010010
	ldi		temp, 0b00000110
	mul		counter, temp
	mov		counter, r0
	add		ZL, counter
	rcall	CHAR_draw

	ldi		temp, 0b00000001
	add		addrstart, temp

	ldi		ZH, high(2 * CHAR_alfabet)	; s
	ldi		ZL, low(2 * CHAR_alfabet)
	ldi		counter, 0b00010010
	ldi		temp, 0b00000110
	mul		counter, temp
	mov		counter, r0
	add		ZL, counter
	rcall	CHAR_draw

	ldi		temp, 0b00000001
	add		addrstart, temp
	ldi		temp, 0b00000001
	add		addrstart, temp
	ldi		temp, 0b00000001
	add		addrstart, temp

	ldi		ZH, high(2 * CHAR_alfabet)	; a
	ldi		ZL, low(2 * CHAR_alfabet)
	ldi		counter, 0b00000000
	ldi		temp, 0b00000110
	mul		counter, temp
	mov		counter, r0
	add		ZL, counter
	rcall	CHAR_draw

	ldi		temp, 0b00000001
	add		addrstart, temp

	ldi		ZH, high(2 * CHAR_alfabet)	; n
	ldi		ZL, low(2 * CHAR_alfabet)
	ldi		counter, 0b00001101
	ldi		temp, 0b00000110
	mul		counter, temp
	mov		counter, r0
	add		ZL, counter
	rcall	CHAR_draw

	ldi		temp, 0b00000001
	add		addrstart, temp

	ldi		ZH, high(2 * CHAR_alfabet)	; y
	ldi		ZL, low(2 * CHAR_alfabet)
	ldi		counter, 0b00011000
	ldi		temp, 0b00000110
	mul		counter, temp
	mov		counter, r0
	add		ZL, counter
	rcall	CHAR_draw

	ldi		temp, 0b00000001
	add		addrstart, temp
	ldi		temp, 0b00000001
	add		addrstart, temp
	ldi		temp, 0b00000001
	add		addrstart, temp

	ldi		ZH, high(2 * CHAR_alfabet)	; k
	ldi		ZL, low(2 * CHAR_alfabet)
	ldi		counter, 0b00001010
	ldi		temp, 0b00000110
	mul		counter, temp
	mov		counter, r0
	add		ZL, counter
	rcall	CHAR_draw

	ldi		temp, 0b00000001
	add		addrstart, temp

	ldi		ZH, high(2 * CHAR_alfabet)	; e
	ldi		ZL, low(2 * CHAR_alfabet)
	ldi		counter, 0b00000100
	ldi		temp, 0b00000110
	mul		counter, temp
	mov		counter, r0
	add		ZL, counter
	rcall	CHAR_draw

	ldi		temp, 0b00000001
	add		addrstart, temp

	ldi		ZH, high(2 * CHAR_alfabet)	; y
	ldi		ZL, low(2 * CHAR_alfabet)
	ldi		counter, 0b00011000
	ldi		temp, 0b00000110
	mul		counter, temp
	mov		counter, r0
	add		ZL, counter
	rcall	CHAR_draw
ret

drawlogo:
	ldi		pagestart, 0b00000000
	ldi		addrstart, 0b00000000
	ldi		csegstart, 0b00000001

	ldi		ZH, high(2 * CHAR_logo)		; logo deel 1
	ldi		ZL, low(2 * CHAR_logo)
	ldi		counter, 0b00000000
	ldi		temp, 0b00001100
	mul		counter, temp
	mov		counter, r0
	add		ZL, counter
	rcall	CHAR_draw

	ldi		ZH, high(2 * CHAR_logo)		; logo deel 2
	ldi		ZL, low(2 * CHAR_logo)
	ldi		counter, 0b00000001
	ldi		temp, 0b00001100
	mul		counter, temp
	mov		counter, r0
	add		ZL, counter
	rcall	CHAR_draw

	ldi		ZH, high(2 * CHAR_logo)		; logo deel 3
	ldi		ZL, low(2 * CHAR_logo)
	ldi		counter, 0b00000010
	ldi		temp, 0b00001100
	mul		counter, temp
	mov		counter, r0
	add		ZL, counter
	rcall	CHAR_draw

	ldi		ZH, high(2 * CHAR_logo)		; logo deel 4
	ldi		ZL, low(2 * CHAR_logo)
	ldi		counter, 0b00000011
	ldi		temp, 0b00001100
	mul		counter, temp
	mov		counter, r0
	add		ZL, counter
	rcall	CHAR_draw

	ldi		pagestart, 0b00000000
	ldi		addrstart, 0b00101000
	ldi		csegstart, 0b00000010

	ldi		ZH, high(2 * CHAR_by)		; by deel 1
	ldi		ZL, low(2 * CHAR_by)
	ldi		counter, 0b00000000
	ldi		temp, 0b00001110
	mul		counter, temp
	mov		counter, r0
	add		ZL, counter
	rcall	CHAR_draw

	ldi		ZH, high(2 * CHAR_by)		; by deel 2
	ldi		ZL, low(2 * CHAR_by)
	ldi		counter, 0b00000001
	ldi		temp, 0b00001110
	mul		counter, temp
	mov		counter, r0
	add		ZL, counter
	rcall	CHAR_draw
ret

drawani:
	ldi		pagestart, 0b00000111
	ldi		addrstart, 0b00111001
	ldi		csegstart, 0b00000100

	ldi		ZH, high(2 * CHAR_ani)
	ldi		ZL, low(2 * CHAR_ani)

	ldi		YH, high(animation)
	ldi		YL, low(animation)
	ld		backup, Y
	mov		counter, backup

	ldi		temp, 0b00001000
	mul		counter, temp
	mov		counter, r0
	add		ZL, counter
	rcall	CHAR_draw

	mov		counter, backup
	ldi		temp, 0b00000001
	add		counter, temp
	ldi		temp, 0b00000100
	cp		counter, temp
	breq		acounterreset
	rjmp		drawanicont
	acounterreset:
		ldi		counter, 0b00000000
	drawanicont:

	ldi		YH, high(animation)
	ldi		YL, low(animation)
	st		Y, counter
ret

incrementscore:
	ldi		ZH, high(score)
	ldi		ZL, low(score)

	ldd		counter, Z + 2			; we halen *1 op
	ldi		temp, 0b00000001		; tellen er 1 bij op
	add		counter, temp
	ldi		counter2, 0b00000000
	ldi		temp, 0b00001010		; resetten als *1 = 10
	cp		counter, temp
	breq		incrementscorereset1
	rjmp		incrementscorecont1
	incrementscorereset1:
		ldi		counter, 0b00000000
		ldi		counter2, 0b00000001
	incrementscorecont1:
	std		Z + 2, counter

	ldd		counter, Z + 1				; we halen *10 op
	ldi		temp, 0b00000000
	cpse		counter2, temp
	ldi		temp, 0b00000001
	add		counter, temp				; tellen er 1 bij op als er een overflow was
	ldi		counter2, 0b00000000
	ldi		temp, 0b00001010			; resetten als *10 = 10
	cp		counter, temp
	breq		incrementscorereset2
	rjmp		incrementscorecont2
	incrementscorereset2:
		ldi		counter, 0b00000000
		ldi		counter2, 0b00000001
	incrementscorecont2:
	std		Z + 1, counter

	ldd		counter, Z + 0				; we halen *100 op
	ldi		temp, 0b00000000
	cpse		counter2, temp
	ldi		temp, 0b00000001
	add		counter, temp				; tellen er 1 bij op als er een overflow was
	ldi		counter2, 0b00000000
	ldi		temp, 0b00001010			; resetten als *100 = 10
	cp		counter, temp
	breq		incrementscorereset3
	rjmp		incrementscorecont3
	incrementscorereset3:
		ldi		counter, 0b00000000
		ldi		counter2, 0b00000001
	incrementscorecont3:
	std		Z + 0, counter
ret

calculatetime:
	ldi		ZH, high(time)
	ldi		ZL, low(time)

	ldd		counter, Z + 3				; we halen de seconden*1 op
	ldi		temp, 0b00000001			; tellen er 1 bij op
	add		counter, temp
	ldi		counter2, 0b00000000
	ldi		temp, 0b00001010			; resetten seconden als seconden = 10
	cp		counter, temp
	breq		ticktimereset1
	rjmp		ticktimecont1
	ticktimereset1:
		ldi		counter, 0b00000000
		ldi		counter2, 0b00000001
	ticktimecont1:
	std		Z + 3, counter

	ldd		counter, Z + 2				; we halen de seconden*10 op
	ldi		temp, 0b00000000
	cpse		counter2, temp
	ldi		temp, 0b00000001
	add		counter, temp				; tellen er 1 bij op als er een overflow was
	ldi		counter2, 0b00000000
	ldi		temp, 0b00000110			; resetten als seconden = 60
	cp		counter, temp
	breq		ticktimereset2
	rjmp		ticktimecont2
	ticktimereset2:
		ldi		counter, 0b00000000
		ldi		counter2, 0b00000001
	ticktimecont2:
	std		Z + 2, counter

	ldd		counter, Z + 1				; we halen de minuten*1 op
	ldi		temp, 0b00000000
	cpse		counter2, temp
	ldi		temp, 0b00000001
	add		counter, temp				; tellen er 1 bij op als er een overflow was
	ldi		counter2, 0b00000000
	ldi		temp, 0b00001010			; resetten als minuten = 10
	cp		counter, temp
	breq		ticktimereset3
	rjmp		ticktimecont3
	ticktimereset3:
		ldi		counter, 0b00000000
		ldi		counter2, 0b00000001
	ticktimecont3:
	std		Z + 1, counter

	ldd		counter, Y + 0				; we halen de minuten*10 op
	ldi		temp, 0b00000000
	cpse		counter2, temp
	ldi		temp, 0b00000001
	add		counter, temp				; tellen er 1 bij op als er een overflow was
	ldi		counter2, 0b00000000
	ldi		temp, 0b00001010			; resetten als minuten = 100
	cp		counter, temp
	breq		ticktimereset4
	rjmp		ticktimecont4
	ticktimereset4:
		ldi		counter, 0b00000000
		ldi		counter2, 0b00000001
	ticktimecont4:
	std		Z + 0, counter
ret

drawscore:
	ldi		pagestart, 0b00000110
	ldi		addrstart, 0b00000000
	ldi		csegstart, 0b00000011

	ldi		ZH, high(2 * CHAR_alfabet)	; s
	ldi		ZL, low(2 * CHAR_alfabet)
	ldi		counter, 0b00010010
	ldi		temp, 0b00000110
	mul		counter, temp
	mov		counter, r0
	add		ZL, counter
	rcall	CHAR_draw

	ldi		temp, 0b00000001
	add		addrstart, temp

	ldi		ZH, high(2 * CHAR_alfabet)	; c
	ldi		ZL, low(2 * CHAR_alfabet)
	ldi		counter, 0b00000010
	ldi		temp, 0b00000110
	mul		counter, temp
	mov		counter, r0
	add		ZL, counter
	rcall	CHAR_draw

	ldi		temp, 0b00000001
	add		addrstart, temp

	ldi		ZH, high(2 * CHAR_alfabet)	; o
	ldi		ZL, low(2 * CHAR_alfabet)
	ldi		counter, 0b00001110
	ldi		temp, 0b00000110
	mul		counter, temp
	mov		counter, r0
	add		ZL, counter
	rcall	CHAR_draw

	ldi		temp, 0b00000001
	add		addrstart, temp

	ldi		ZH, high(2 * CHAR_alfabet)	; r
	ldi		ZL, low(2 * CHAR_alfabet)
	ldi		counter, 0b00010001
	ldi		temp, 0b00000110
	mul		counter, temp
	mov		counter, r0
	add		ZL, counter
	rcall	CHAR_draw

	ldi		temp, 0b00000001
	add		addrstart, temp

	ldi		ZH, high(2 * CHAR_alfabet)	; e
	ldi		ZL, low(2 * CHAR_alfabet)
	ldi		counter, 0b00000100
	ldi		temp, 0b00000110
	mul		counter, temp
	mov		counter, r0
	add		ZL, counter
	rcall	CHAR_draw

	ldi		temp, 0b00000001
	add		addrstart, temp
	ldi		temp, 0b00000001
	add		addrstart, temp
	ldi		temp, 0b00000001
	add		addrstart, temp

	ldi		YH, high(score)
	ldi		YL, low(score)

	ldi		ZH, high(2 * CHAR_numbers)
	ldi		ZL, low(2 * CHAR_numbers)
	ldd		counter, Y + 0
	ldi		temp, 0b00000110
	mul		counter, temp
	mov		counter, r0
	add		ZL, counter
	rcall	CHAR_draw

	ldi		temp, 0b00000001
	add		addrstart, temp

	ldi		ZH, high(2 * CHAR_numbers)
	ldi		ZL, low(2 * CHAR_numbers)
	ldd		counter, Y + 1
	ldi		temp, 0b00000110
	mul		counter, temp
	mov		counter, r0
	add		ZL, counter
	rcall	CHAR_draw

	ldi		temp, 0b00000001
	add		addrstart, temp

	ldi		ZH, high(2 * CHAR_numbers)
	ldi		ZL, low(2 * CHAR_numbers)
	ldd		counter, Y + 2
	ldi		temp, 0b00000110
	mul		counter, temp
	mov		counter, r0
	add		ZL, counter
	rcall	CHAR_draw
ret

drawtime:
	ldi		pagestart, 0b00000111
	ldi		addrstart, 0b00000000
	ldi		csegstart, 0b00000011

	ldi		ZH, high(2 * CHAR_alfabet)	; t
	ldi		ZL, low(2 * CHAR_alfabet)
	ldi		counter, 0b00010011
	ldi		temp, 0b00000110
	mul		counter, temp
	mov		counter, r0
	add		ZL, counter
	rcall	CHAR_draw

	ldi		temp, 0b00000001
	add		addrstart, temp

	ldi		ZH, high(2 * CHAR_alfabet)	; i
	ldi		ZL, low(2 * CHAR_alfabet)
	ldi		counter, 0b00001000
	ldi		temp, 0b00000110
	mul		counter, temp
	mov		counter, r0
	add		ZL, counter
	rcall	CHAR_draw

	ldi		temp, 0b00000001
	add		addrstart, temp

	ldi		ZH, high(2 * CHAR_alfabet)	; m
	ldi		ZL, low(2 * CHAR_alfabet)
	ldi		counter, 0b00001100
	ldi		temp, 0b00000110
	mul		counter, temp
	mov		counter, r0
	add		ZL, counter
	rcall	CHAR_draw

	ldi		temp, 0b00000001
	add		addrstart, temp

	ldi		ZH, high(2 * CHAR_alfabet)	; e
	ldi		ZL, low(2 * CHAR_alfabet)
	ldi		counter, 0b00000100
	ldi		temp, 0b00000110
	mul		counter, temp
	mov		counter, r0
	add		ZL, counter
	rcall	CHAR_draw

	ldi		temp, 0b00000001
	add		addrstart, temp
	ldi		temp, 0b00000001
	add		addrstart, temp
	ldi		temp, 0b00000001
	add		addrstart, temp

	ldi		YH, high(time)
	ldi		YL, low(time)

	ldi		ZH, high(2 * CHAR_numbers)
	ldi		ZL, low(2 * CHAR_numbers)
	ldd		counter, Y + 0
	ldi		temp, 0b00000110
	mul		counter, temp
	mov		counter, r0
	add		ZL, counter
	rcall	CHAR_draw

	ldi		temp, 0b00000001
	add		addrstart, temp

	ldi		ZH, high(2 * CHAR_numbers)
	ldi		ZL, low(2 * CHAR_numbers)
	ldd		counter, Y + 1
	ldi		temp, 0b00000110
	mul		counter, temp
	mov		counter, r0
	add		ZL, counter
	rcall	CHAR_draw

	ldi		temp, 0b00000001
	add		addrstart, temp
	ldi		temp, 0b00000001
	add		addrstart, temp
	ldi		temp, 0b00000001
	add		addrstart, temp

	ldi		ZH, high(2 * CHAR_colon)
	ldi		ZL, low(2 * CHAR_colon)
	rcall	CHAR_draw

	ldi		temp, 0b00000001
	add		addrstart, temp
	ldi		temp, 0b00000001
	add		addrstart, temp
	ldi		temp, 0b00000001
	add		addrstart, temp

	ldi		ZH, high(2 * CHAR_numbers)
	ldi		ZL, low(2 * CHAR_numbers)
	ldd		counter, Y + 2
	ldi		temp, 0b00000110
	mul		counter, temp
	mov		counter, r0
	add		ZL, counter
	rcall	CHAR_draw

	ldi		temp, 0b00000001
	add		addrstart, temp

	ldi		ZH, high(2 * CHAR_numbers)
	ldi		ZL, low(2 * CHAR_numbers)
	ldd		counter, Y + 3
	ldi		temp, 0b00000110
	mul		counter, temp
	mov		counter, r0
	add		ZL, counter
	rcall	CHAR_draw
ret

CHAR_draw:
	mov		argument, pagestart
	rcall	LCD_setpage
	mov		argument, addrstart
	rcall	LCD_setaddress
	mov		argument, csegstart
	rcall	LCD_setcs

	drawloop:
		ldi		temp, 0b01000000
		cp		addrstart, temp
		breq		drawoverflow
		rjmp		drawcont
		drawoverflow:
			ldi		temp, 0b00000001
			add		csegstart, temp
			ldi		addrstart, 0b00000000
			mov		argument, addrstart
			rcall	LCD_setaddress
			mov		argument, csegstart
			rcall	LCD_setcs
		drawcont:
		lpm		argument, Z+
		ldi		temp, 0b00000000
		cp		argument, temp
		breq		exitdraw
		rcall	LCD_wait
		rcall	LCD_write
		ldi		temp, 0b00000001
		add		addrstart, temp
		rjmp		drawloop

	exitdraw:
ret

LCD_fullclean:
	ldi		argument, 0b00000000
	rcall	LCD_setpage
	ldi		argument, 0b00000000
	rcall	LCD_setaddress

	ldi		counter, 0b00001000
	cleango1:
		mov		argument, counter
		rcall	LCD_setpage
		ldi		counter2, 0b01000000
		cleango2:
			ldi		argument, 0b00000000
			rcall	LCD_wait
			rcall	LCD_write
			dec		counter2
			ldi		temp, 0b00000000
			cpse		counter2, temp
			rjmp		cleango2
		dec		counter
		ldi		temp, 0b00000000
		cpse		counter, temp
		rjmp		cleango1
ret

LCD_drawborder:
	; +-----
	; | CS1

	ldi		argument, 0b00000001		; alles resetten voor CS1
	rcall	LCD_setpage
	ldi		argument, 0b00000000
	rcall	LCD_setaddress
	rcall	LCD_setcs1

	ldi		argument, 0b11111111		; linkerbovenhoek
	rcall	LCD_wait
	rcall	LCD_write
	ldi		argument, 0b11111111
	rcall	LCD_wait
	rcall	LCD_write

	ldi		counter, 0b001111100		; rest van bovenste lijn is gewoon toplijn
	loop1:
		ldi		argument, 0b00000011
		rcall	LCD_wait
		rcall	LCD_write
		dec		counter
		ldi		temp, 0b00000000
		cpse		counter, temp
		rjmp		loop1

	ldi		counter, 0b00000001
	loop2:
		mov		argument, counter
		rcall	LCD_setpage
		ldi		argument, 0b00000000
		rcall	LCD_setaddress
		rcall	LCD_setcs1
		ldi		argument, 0b11111111	; linkerlijn
		rcall	LCD_wait
		rcall	LCD_write
		ldi		argument, 0b11111111
		rcall	LCD_wait
		rcall	LCD_write
		inc		counter
		ldi		temp, 0b00001000
		cpse		counter, temp
		rjmp		loop2

	; -----+
	;  CS2 |

	ldi		argument, 0b00000001		; alles resetten voor CS2
	rcall	LCD_setpage
	ldi		argument, 0b00000000
	rcall	LCD_setaddress
	rcall	LCD_setcs2

	ldi		counter, 0b01000000			; bovenste lijn is gewoon toplijn
	loop3:
		ldi		argument, 0b00000011
		rcall	LCD_wait
		rcall	LCD_write
		dec		counter
		ldi		temp, 0b00000000
		cpse		counter, temp
		rjmp		loop3

	ldi		argument, 0b00111110
	rcall	LCD_setaddress
	rcall	LCD_setcs2
	ldi		argument, 0b11111111		; rechterbovenhoek
	rcall	LCD_wait
	rcall	LCD_write
	ldi		argument, 0b11111111
	rcall	LCD_wait
	rcall	LCD_write

	ldi		counter, 0b00000001
	loop4:
		mov		argument, counter
		rcall	LCD_setpage
		ldi		argument, 0b00111110
		rcall	LCD_setaddress
		rcall	LCD_setcs2
		ldi		argument, 0b11111111	; rechterlijn
		rcall	LCD_wait
		rcall	LCD_write
		ldi		argument, 0b11111111
		rcall	LCD_wait
		rcall	LCD_write
		inc		counter
		ldi		temp, 0b00001000
		cpse		counter, temp
		rjmp		loop4

	; | CS3
	; +-----

	ldi		argument, 0b00000000		; alles resetten voor CS3
	rcall	LCD_setpage
	ldi		argument, 0b00000000
	rcall	LCD_setaddress
	rcall	LCD_setcs3

	ldi		counter, 0b00000000
	loop5:
		mov		argument, counter
		rcall	LCD_setpage
		ldi		argument, 0b00000000
		rcall	LCD_setaddress
		rcall	LCD_setcs3
		ldi		argument, 0b11111111	; linkerlijn
		rcall	LCD_wait
		rcall	LCD_write
		ldi		argument, 0b11111111
		rcall	LCD_wait
		rcall	LCD_write
		inc		counter
		ldi		temp, 0b00000100
		cpse		counter, temp
		rjmp		loop5

	ldi		argument, 0b00000100
	rcall	LCD_setpage
	ldi		argument, 0b00000000
	rcall	LCD_setaddress
	rcall	LCD_setcs3
	ldi		argument, 0b11111111		; linkeronderhoek
	rcall	LCD_wait
	rcall	LCD_write
	ldi		argument, 0b11111111
	rcall	LCD_wait
	rcall	LCD_write

	ldi		counter, 0b000111110		; rest van onderste lijn is gewoon bottomlijn
	loop6:
		ldi		argument, 0b11000000
		rcall	LCD_wait
		rcall	LCD_write
		dec		counter
		ldi		temp, 0b00000000
		cpse		counter, temp
		rjmp		loop6

	;  CS4 |
	; -----+

	ldi		argument, 0b00000000		; alles resetten voor CS4
	rcall	LCD_setpage
	ldi		argument, 0b00000000
	rcall	LCD_setaddress
	rcall	LCD_setcs4

	ldi		counter, 0b00000000
	loop7:
		mov		argument, counter
		rcall	LCD_setpage
		ldi		argument, 0b00111110
		rcall	LCD_setaddress
		rcall	LCD_setcs4
		ldi		argument, 0b11111111	; linkerlijn
		rcall	LCD_wait
		rcall	LCD_write
		ldi		argument, 0b11111111
		rcall	LCD_wait
		rcall	LCD_write
		inc		counter
		ldi		temp, 0b00000100
		cpse		counter, temp
		rjmp		loop7

	ldi		argument, 0b00000100
	rcall	LCD_setpage
	ldi		argument, 0b00000000
	rcall	LCD_setaddress
	rcall	LCD_setcs4
	ldi		counter, 0b01000000			; rest van bovenste lijn is gewoon toplijn
	loop8:
		ldi		argument, 0b11000000
		rcall	LCD_wait
		rcall	LCD_write
		dec		counter
		ldi		temp, 0b00000010
		cpse		counter, temp
		rjmp		loop8

	ldi		argument, 0b11111111		; rechteronderhoek
	rcall	LCD_wait
	rcall	LCD_write
	ldi		argument, 0b11111111
	rcall	LCD_wait
	rcall	LCD_write

ret

LCD_wait:
	ldi		temp, 0b00000000
	out		DDRA, temp

	sbi		PORTC, LCD_RW
	cbi		PORTC, LCD_RS
	waitloop:
		sbi 		PORTC, LCD_E
     	cbi 		PORTC, LCD_E
		in		temp, PINC
		sbrc		temp, 7
		rjmp		waitloop

	ldi		temp, 0b11111111
	out		DDRA, temp
ret

LCD_init:
	sbi 		PORTC, LCD_CS1
	sbi 		PORTC, LCD_CS2
	sbi 		PORTC, LCD_CS3
	sbi 		PORTC, LCD_CS4
	cbi		PORTC, LCD_RS
	cbi		PORTC, LCD_RW

	rcall	LCD_delay1ms
	ldi		temp, 0b11000000		 	; startlijn = 0
	out 		PORTA, temp
	sbi 		PORTC, LCD_E
     cbi 		PORTC, LCD_E

	rcall	LCD_delay1ms
	ldi 		temp, 0b01000000		 	; adres = 0
	out 		PORTA, temp
	sbi 		PORTC, LCD_E
     cbi 		PORTC, LCD_E

	rcall	LCD_delay1ms
	ldi		temp, 0b10111000		 	; page = 0
	out 		PORTA, temp
	sbi 		PORTC, LCD_E
     cbi 		PORTC, LCD_E

	rcall	LCD_delay1ms
	ldi 		temp, 0b00111111			 ; display aan
	out 		PORTA, temp
	sbi 		PORTC, LCD_E
     cbi 		PORTC, LCD_E

	cbi 		PORTC, LCD_CS1
	cbi 		PORTC, LCD_CS2
	cbi 		PORTC, LCD_CS3
	cbi 		PORTC, LCD_CS4
ret

LCD_delay1ms:
	ldi		counter, 0b00011100
	delay1msgo:
		ldi 		counter2, 0b00000000
		delay1msgo2:
			dec		counter2
			brne		delay1msgo2
		dec		counter
		brne 	delay1msgo
ret

LCD_setcs:
	sbi		PORTC, LCD_CS1
	ldi		temp, 0b00000001
	cpse		temp, argument
	cbi 		PORTC, LCD_CS1

	sbi		PORTC, LCD_CS2
	ldi		temp, 0b00000010
	cpse		temp, argument
	cbi 		PORTC, LCD_CS2

	sbi		PORTC, LCD_CS3
	ldi		temp, 0b00000011
	cpse		temp, argument
	cbi 		PORTC, LCD_CS3

	sbi		PORTC, LCD_CS4
	ldi		temp, 0b00000100
	cpse		temp, argument
	cbi 		PORTC, LCD_CS4
ret

LCD_setcs1:
	sbi 		PORTC, LCD_CS1
	cbi		PORTC, LCD_CS2
	cbi		PORTC, LCD_CS3
	cbi		PORTC, LCD_CS4
ret

LCD_setcs2:
	cbi 		PORTC, LCD_CS1
	sbi		PORTC, LCD_CS2
	cbi		PORTC, LCD_CS3
	cbi		PORTC, LCD_CS4
ret

LCD_setcs3:
	cbi 		PORTC, LCD_CS1
	cbi		PORTC, LCD_CS2
	sbi		PORTC, LCD_CS3
	cbi		PORTC, LCD_CS4
ret

LCD_setcs4:
	cbi 		PORTC, LCD_CS1
	cbi		PORTC, LCD_CS2
	cbi		PORTC, LCD_CS3
	sbi		PORTC, LCD_CS4
ret

LCD_write:
	sbi 		PORTC, LCD_RS
	cbi 		PORTC, LCD_RW
	out 		PORTA, argument
	sbi 		PORTC, LCD_E
	cbi 		PORTC, LCD_E
ret

LCD_read:
	ldi		temp, 0b00000000
	out		DDRA, temp

	sbi		PORTC, LCD_RS
	sbi		PORTC, LCD_RW
	sbi		PORTC, LCD_E
	cbi		PORTC, LCD_E
	cbi		PORTC, LCD_RS
	sbi		PORTC, LCD_RS
	sbi		PORTC, LCD_E
	cbi		PORTC, LCD_E
	in		return, PINA
	cbi		PORTC, LCD_RW

	ldi		temp, 0b11111111
	out		DDRA, temp
ret

LCD_setpage:
	sbi		PORTC, LCD_CS1
	sbi 		PORTC, LCD_CS2
	sbi 		PORTC, LCD_CS3
	sbi 		PORTC, LCD_CS4
	cbi 		PORTC, LCD_RS
	ldi 		temp, 0b10111000
	add		argument, temp
	out 		PORTA, argument
	sbi 		PORTC, LCD_E
	cbi 		PORTC, LCD_E
	sbi 		PORTC, LCD_RS
ret

LCD_setaddress:
	sbi		PORTC, LCD_CS1
	sbi 		PORTC, LCD_CS2
	sbi 		PORTC, LCD_CS3
	sbi 		PORTC, LCD_CS4
	cbi 		PORTC, LCD_RS
	ldi 		temp, 0b01000000
	add		argument, temp
	out 		PORTA, argument
	sbi 		PORTC, LCD_E
	cbi 		PORTC, LCD_E
	sbi 		PORTC, LCD_RS
ret

			.DSEG
time:		.BYTE	4
snake:		.BYTE	256
snakebuffer:	.BYTE	2
food:		.BYTE	2
score:		.BYTE	3
animation:	.BYTE	2
