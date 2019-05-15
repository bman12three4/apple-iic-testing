********************************
*       Keyboard Monitor       *
********************************

		org	$8000
start	lda	#C010	; Get input strobe
		sbc	#$180	; Subtract 128 to see
		bpl	print	; if key is held down.
		lda	#32		; If not, print a space
print	adc	#$80	; Add the 128 back
		jsr $FDF0	; Print it to the screen
		lda #10		; Set cursor to 10,10
		sta #24
		sta #25
		jmp start	; loop
		