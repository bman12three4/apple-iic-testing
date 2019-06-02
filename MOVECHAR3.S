********************************
*          Lo-res Game         *
********************************

HPOS      = $06
OHPOS     = $07
OLDKEY    = $08
DELAYC    = $09
DELAYT    = $FB
RNDT      = $FA

HEND      = $2C
RNDH      = $4F

SETGR     = $FB40
INIT      = $FB2F
HOME      = $FC58
MIXCLR    = $C052
CLRSCR    = $F832
SETCOL    = $F864
HLINE     = $F819
KBDSTR    = $C010
KEYIN     = $FD1B
PRINT     = $FDF0

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
          STA DELAYC     ; Set both delays to 0
          STA DELAYT
          JSR KEYIN      ; Use KEYIN to generate
          LDA RNDH       ; a random number. Store this
          STA RNDT       ; as the first seed.
          JMP KEYCHK
DRAW      LDA #2         ; Change color to blue
          JSR SETCOL
          LDA SCORE      ; Set width to current score
          STA HEND
          LDY #0         ; Start at left side
          LDA #47        ; Bottom of screen
          JSR HLINE      ; Draw that line
          LDA #13        ; Change color to yellow
          JSR SETCOL
          LDA TIME       ; Set width to time remaining
          STA HEND
          LDY #0         ; Start at left side
          LDA #46        ; Second line from bottom
          JSR HLINE      ; Draw the line
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
          STA COLOR,X    ; is over enemy.
          LDA SCORED,X   ; See if that enemy is already scored
          BNE ENEMY1     ; on the same tick. Skip this if so.
          LDA SCORE      ; Load the current score and add 1
          CLC
          ADC #1
          STA SCORE      ; Save as current score, position score
          STA SCORED,X   ; must not equal 0, so current score is fine.
          LDA TIME
          CMP #39        ; Compare the time to 39. If time >= 39,
          BCC DONTSTOP   ; then end the game. Otherwise, keep going.
          JMP END
DONTSTOP  LDA #0         ; Set the color to black
          JSR SETCOL
          LDA YPOS,X     ; Load the y-pos below the enemy
          ADC #1         ; and draw the black square there.
          JSR HLINE
          JSR RSPOS1     ; Reset that enemy.
ENEMY1    LDA #0         ; Clear the block underneath
          JSR SETCOL
          LDA YPOS,X
          CLC
          ADC #1
          JSR HLINE
          INX
          CPX #$5        ; See if x is 5, if it is then
          BNE JENEMY     ; end the loop.
          JSR INCY       ; Increase the y vals of enemy
          JMP KEYCHK     ; Go back to the beginning
          RTS            ; Return from subroutine
JENEMY    JMP ENEMY
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
          LDA DELAYT     ; Get time delay value
          CLC
          ADC #1         ; Add 1 to it.
          STA DELAYT     ; Store  it again
          CMP #10        ; Compare it to 10. Decreasing speeds up game
          BCC INCY2      ; If time delay >= 10, increase time val.
          LDA TIME       ; Incrase time val by 1
          CLC
          ADC #1
          STA TIME       ; Store it again
          STX DELAYT     ; Reset time delay val
INCY2     LDA YPOS,X     ; Load y position
          BEQ RSPOS      ; If it is 0, then reset the position
          CLC
          SBC #0         ; If not, then subtract 1 (not sure why 0)
          STA YPOS,X     ; Store new y pos.
SKIP1     INX            ; Increase x value
          CPX #$5        ; If x is 5, then go back to the beginning
          BNE INCY2      ; Otherwise, go back to the loop
          RTS
RSPOS     JSR RSPOS1
          JMP SKIP1
RSPOS1    LDA #40        ; Reset position sets the y pos to 40.
          STA YPOS,X
          JSR RANDOM     ; Load A with a random number 0-39
          STA XPOS,X     ; Set that as x position.
          LDA #12        ; Set the color to 12 (Green)
          STA COLOR,X
          LDA #0         ; Set scored variable to false.
          STA SCORED,X
          RTS            ; return
RANDOM    JSR RANDOM1    ; Load a random number and cap it at 31
          AND #31
          STA RND        ; Store it temporarily
          JSR RANDOM1    ; Load a random number and cap it at 7
          AND #7
          ADC RND        ; Add it to current number and store.
          STA RND        ; This gives number capped at 38
          JSR RANDOM1    ; Load a random number and cap it at 1
          AND #1         ; Add 1 to give a random number 0-39
          ADC RND
          RTS            ; Return with A as the random number
RANDOM1   LDA RNDT       ; This is something I found online.
          ASL            ; Link is at the bottom
          BCC NOEOR
          EOR #$1D
NOEOR     STA RNDT
          CPX #2
          BCS NOROL
          ROL
NOROL     RTS
END       JSR INIT       ; End game stuff
          JSR HOME       ; Go to text mode.
          LDX #0         ; reset X
SCORE1    LDA SCORETX,X  ; Load the score text message
          BEQ SCOREN
          JSR PRINT
          INX
          JMP SCORE1
SCOREN    LDY SCORE      ; Get the score number in ASCII
          JSR TENS       ; Get the 10s digit
          CLC
          ADC #176       ; Add that to 176 to convert
          JSR PRINT      ; to ASCII. Print that digit
          JSR TENS       ; Get 10s digit
          JSR ONES       ; Pass that to ones and get
          CLC            ; ones digit.
          ADC #176       ; Convert that to ASCII
          JSR PRINT      ; Print that digit.
          LDX #0
          JMP END1
SCORE2    LDA TIMETX1,X  ; Load time message 1
          BEQ TIMEN      ; Print that string
          JSR PRINT
          INX
          JMP SCORE2
TIMEN     LDA #157       ; Temporary score, delete
          JSR HUNDT
          JSR PRINT
          LDY TIME
          JSR TENS
          CLC
          ADC #176
          JSR PRINT
          JSR TENS
          JSR ONES
          CLC
          ADC #176
          JSR PRINT
          LDX #0
END1      JMP END1
HUNDS     LDA SCORE
          CMP #100
          BCS HUNDS1
          RTS
HUNDS1    CMP #200
          BCS HUNDS2
          SBC #100
          STA SCORE
          LDA #177
          RTS
HUNDS2    SBC #200
          STA SCORE
          LDA #178
          RTS
HUNDT     LDA TIME       ; Change this to TIME
          CMP #100
          BCS HUNDT1
          RTS
HUNDT1    CMP #200
          BCS HUNDT2
          SBC #100
          STA TIME
          LDA #177
          RTS
HUNDT2    SBC #200
          STA TIME
          LDA #178
          RTS
TENS      LDX #0         ; Get 10's digit. Set x to 0
          TYA            ; Transfer y (score or time) to a
TENS1     SBC #10        ; Subtract 10
          BMI TENS2      ; If it's negative, stop
          INX            ; Increase the x val
          JMP TENS1      ; Do it again.
TENS2     TXA            ; Transfer x (10's digit) to a
          RTS            ; Return with A as 10's digit.
ONES      TAX            ; Transfer a (the 10s digit) to x
          TYA            ; Transfer y (score or time) to a
ONES1     SBC #10        ; Subtract 10 for each 10s digit.
          DEX
          BNE ONES1
          ADC #0
          RTS            ; Return with A as the 1s digit
* This is the random number generator that I used
* http://codebase64.org/doku.php?id=base:small_fast_8-bit_prng

* This is the data section, it stores the x position array, the
* y position array, the color array, the score and the time.

XPOS      DFB 1,4,11,18,29
YPOS      DFB 19,25,14,22,37
COLOR     DFB 12,12,12,12,12
SCORED    DFB 0,0,0,0,0
SCORE     HEX 00
SCOREH    HEX 00
TIME      HEX 00
TIMEH     HEX 00
RND       HEX 00

* String section. All strings are null terminated

SCORETX   ASC "You scored ",00
TIMETX1   ASC " in ",00
TIMETX2   ASC " ticks.",00
