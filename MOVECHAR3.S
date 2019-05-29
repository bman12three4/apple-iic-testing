********************************
*       Low-Res testing        *
********************************

HPOS      = $06
OHPOS     = $07
OLDKEY    = $08
DELAYC    = $09
RNDT      = $FA

HEND      = $2C

SETGR     = $FB40
SETWND    = $FB4B
INIT      = $FB2F
HOME      = $FC58
TXTSET    = $C051
MIXCLR    = $C052
MIXSET    = $C053
CLRSCR    = $F832
SETCOL    = $F864
HLINE     = $F819
KBDSTR    = $C010
KEYIN     = $FD1B
RESET     = $E003

          ORG $8000
          JSR SETGR      ; Init lowres
          BIT MIXCLR     ; Full screen
          JSR CLRSCR     ; Clear screen
          LDA #15        ; Color white
          JSR SETCOL
          LDA #10        ; Set position to 10
          STA HPOS
          STA OLDKEY     ; Initialize key
          LDA #0
          STA DELAYC
          JSR KEYIN
          STA RNDT
          JMP KEYCHK
DRAW      LDA #2         ; Get score value
          JSR SETCOL     ; Change to that color
          LDA SCORE      ; Draw that point at 0,0
          STA HEND
          LDY #0
          LDA #47
          JSR HLINE
          LDA #15        ; Main draw routine.
          JSR SETCOL     ; Set color to white
          LDA HPOS       ; Set hpos and hend to
          STA HEND       ; position.
          LDY HPOS       ; Set everything up
          LDA #5         ; Draw a line from x to x
          JSR HLINE      ; Not sure why, but that
          LDA #0         ; works I guess.
          JSR SETCOL     ; Set color to black.
          LDA OHPOS      ; Load the old position
          STA HEND       ; and draw that.
          LDY OHPOS
          LDA #5         ; This whole routine could
          JSR HLINE      ; probably be at the bottom.
          LDX #00        ; Start X at 0
ENEMY     LDA COLOR,X    ; Load the color of the enemy
          JSR SETCOL     ; Change to that color
          LDY XPOS,X     ; Load the x position
          STY HEND       ; Store that as the end of line
          LDA YPOS,X     ; Load y position
          CMP #0         ; Check if the y pos is 0
          BNE ENEMY2     ; Skip this if it is
          LDA COLOR,X    ; See if the color is 0.
          CMP #0         ; If it is, then don't change
          BEQ ENEMY2     ; color to orange.
          LDA #9         ; Change the color to orange
          JSR SETCOL
          LDA YPOS,X     ; Load the y pos again
ENEMY2    JSR HLINE      ; Draw a line (really a point)
          LDA YPOS,X     ; Load the y pos again
          CMP #5         ; Compare it y 5 (player y pos)
          BNE ENEMY1     ; Skip if it's not the same
          CPY HPOS       ; Compare it to player x pos
          BNE ENEMY1     ; Skip if it's not the same
          LDA #0         ; If both are equal, then player
          STA COLOR,X    ; is over enemy. Change color to
          LDA SCORED,X
          BNE ENEMY1
          LDA SCORE      ; black and increase score
          CLC
          ADC #1
          STA SCORE
          STA SCORED,X
          CMP #39
          BCC DONTSTOP
          JSR INIT
          BIT TXTSET
          JSR SETWND
          JSR HOME
          JMP RESET
DONTSTOP  LDA #0
          JSR SETCOL
          LDA YPOS,X
          ADC #1
          JSR HLINE
          JSR RSPOS1
ENEMY1    LDA #0         ; Clear the block underneath
          JSR SETCOL
          LDA YPOS,X
          CLC
          ADC #1
          JSR HLINE
          INX
          CPX #$5        ; See if x is 5, if it is then
          BNE ENEMY      ; end the loop.
          JSR INCY       ; Increase the y vals of enemy
          JMP KEYCHK     ; Go back to the beginning
          RTS            ; Return from subroutine
KEYCHK    LDA KBDSTR     ; Load keyboard strobe input
          CMP OLDKEY     ; Compare it to the last key
          BEQ JDRAW      ; Go back if they're the same
          STA OLDKEY     ; If not, store input as old key
          CMP #$80       ; Compare it to $80 (key is pressed)
          BCS KEY        ; Continue if it is greater
JDRAW     JMP DRAW       ; Go back if not.
KEY       CMP #"D"       ; Compare the input to "A" and "D"
          BEQ RIGHT      ; Jump to appropriate subroutine
          CMP #"A"
          BEQ LEFT
          JMP KEYCHK     ; If nothing, go back again
RIGHT     LDA HPOS       ; Update old position
          STA OHPOS
          ADC #0         ; "Add" to position (not sure why 0)
          STA HPOS       ; Update current position
          JSR DRAW       ; Jump to draw routine
          JMP KEYCHK     ; Go back to keycheck
LEFT      LDA HPOS       ; Left one is pretty much the same
          STA OHPOS      ; except it actually subtracts one.
          SBC #1
          STA HPOS
          JSR DRAW
          JMP KEYCHK
INCY      LDA DELAYC     ; Delay method. Get current delay val
          CLC
          ADC #$1        ; Add one to delay value 
          STA DELAYC     ; Store it back to delay value
          CMP #$40       ; Compare it to $40. Change this
          BCS INCY1      ; to change delay time.
          RTS            ; If delay val is greater than this, then
INCY1     LDX #0         ; actually increase the y values
          STX DELAYC     ; Load x as 0 and reset delay val
          LDA TIME       ; Increase time by 1
          CLC
          ADC #1
          STA TIME
INCY2     LDA YPOS,X     ; Load y position
          BEQ RSPOS      ; If it is 0, then reset the position
          CLC
          SBC #0         ; If not, then subtract 1 (not sure why 0)
SKIP      STA YPOS,X     ; Go here to skip subtraction. Store y pos
SKIP1     INX            ; Increase x value
          CPX #$5        ; If x is 5, then go back to the beginning
          BNE INCY2      ; Otherwise, go back to the loop
          RTS
RSPOS     JSR RSPOS1
          JMP SKIP1
RSPOS1    LDA #40        ; Reset position sets the y pos to 40.
          STA YPOS,X
          JSR RANDOM
          STA XPOS,X
          LDA #12
          STA COLOR,X
          LDA #0
          STA SCORED,X
          RTS            ; right now it just stores 20 to y pos.
RANDOM    JSR RANDOM1
          AND #31
          STA RND
          JSR RANDOM1
          AND #7
          ADC RND
          RTS
RANDOM1   LDA RNDT
          ASL
          BCC NOEOR
          EOR #$1D
NOEOR     STA RNDT
          CPX #2
          BCS NOROL
          ROL
NOROL     RTS


* This is the data section, it stores the x position array, the
* y position array, the color array, the score and the time.

XPOS      DFB 1,4,11,18,29
YPOS      DFB 19,25,14,22,37
COLOR     DFB 12,12,12,12,12
SCORED    DFB 0,0,0,0,0
SCORE     HEX 00
TIME      HEX 00
RND       HEX 00
