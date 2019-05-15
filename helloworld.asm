********************************
*         Hello World          *
********************************


		org	$8000
		ldx #$0
loop	lda string,x; Load  the next letter of string
		beq done	; If a loaded $00, then end. (null terminated string)
		jsr	$FDF0	; Print subroutine
		inx
		bne loop	; I don't think this does anything
done	rts
string	asc	"Hello, World! Now I have variable string length!",00
		end