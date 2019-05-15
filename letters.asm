********************************
*        Screen Testing        *
********************************
	org	$8000	; Start at $8000
print	equ	$FDF0	; Print subroutine
	lda	#"A"	; "A"
	jsr	print	; Print the character
end	rts		; End the program
