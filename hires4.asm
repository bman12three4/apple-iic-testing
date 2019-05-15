********************************
*     High Resolution Test     *
********************************

HGR		=	$F3E2	; Applesoft clear to hires1
BKGND	=	$F3F4	; Applesoft hires background
MIXCLR	=	$C052	; Fullscreen soft switch

ROWL 	=	$06 	; Row pointer
ROWH	=	$07

		org	$8000
		jsr	HGR		; Hires page 1
		jsr BKGND	; Clear
		bit	MIXCLR	; Full screen
		lda	#$00  	; Load $2000 into row pointer
		sta	ROWL
		lda #$20
		sta ROWH
		lda #$7F	; White line for 7px
		ldy	#$00
DRAW	sta (ROWL),y; Draw that segment
		iny			; Increment y
		cpy	#$01	; Compare it to 1 (from when this used to be a loop)
		bne DRAW
		ldy #$00
		lda #$80
		sta ROWL	; Load $2080 into row pointer (9th line)
		lda #$7f	; White line for 7px
DRAW2	sta (ROWL),y; Draw that segment
		iny			; Increment y
		cpy #$01	; Compare it to 1
		bne DRAW2	
		ldy #$00
		lda #$24
		sta ROWH
		lda #$00
		sta ROWL
DRAW3	lda #$41	; Outside dots
		sta	(ROWL),y
		lda	ROWH
		clc
		adc	#$04
		sta ROWH
		cmp	#$40
		bne DRAW3
LOL		jmp	LOL