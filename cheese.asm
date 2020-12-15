;ECE 109 001 Fall 2019
;Sam Huneycutt (shhuneyc)
;created 22 October 2019
;submitted 7 November 2019
;Program 3: Mouse Racer Game
;The user must navigate a mouse through a maze, collecting crumbs and cheese in the process
;Collect as many crumbs as possible in the shortest time before collecting the cheese!
;
;	The user can move the mouse with the WASD keys
;
;	The current position of the mouse is defined by its top-left pixel
;
;the Pennsim screen is 128 pixels wide and 124 lines tall
;


	.ORIG x3000
	
;
;set up clock
	LD R6, INT			;load clock tick interval
	STI R6, TMI			;store interval to Timer Interval Register

;
;Draw all map elements (borders, barriers, crumbs and cheese) and the mouse
MAP	;clear the screen
	;set up DRAW subroutine to paint screen black
	LD R0, SCREEN			;load first address in video memory (top-left of screen)
	LD R1, DOWN1			;set width to 128
	LD R2, LINES			;set height to 124
	LD R3, COLBK			;set color to black
	JSR DRAW
	;set up DRAW subroutine for lines
	;line positions are defined by the uppermost or leftmost pixel
	LD R1, NUM1			;set width to 1
	LD R3, COLB			;set color to blue
	JSR DRAW
	LD R0, DOTF			;load position of line (top-right of screen)
	JSR DRAW
	LD R0, LINE1			;load position of line 1
	LD R2, LINE12H			;set height to 100
	JSR DRAW
	LD R0, LINE2			;load position of line 2
	JSR DRAW			
	LD R0, SCREEN			;load position of line (top-left of screen)
	LD R1, DOWN1			;set width to 128
	LD R2, NUM1			;set height to 1
	JSR DRAW
	LD R0, LINEF			;load position of line (bottom-left of screen)
	JSR DRAW					
	LD R0, LINE3			;load position of line 3
	LD R1, LINE36W			;set width to 53
	JSR DRAW
	LD R0, LINE4			;load position of line 4
	JSR DRAW
	LD R0, LINE5			;load position of line 5
	JSR DRAW
	LD R0, LINE6			;load position of line 6
	JSR DRAW
	;set up DRAW subroutine for cheese (12x12 yellow)
	LD R0, POSCHS			;load position of cheese
	LD R1, NUM12			;set width to 12
	LD R2, NUM12			;set height to 12
	LD R3, COLY			;set color to yellow
	JSR DRAW
	;set up draw subroutine for mouse (10x12 gray)
	LD R0, POS			;load position of mouse
	LD R1, NUM10			;set width to 12
	LD R3, COLGY			;set color to gray
	JSR DRAW
	;set up CRMDRW subroutine (draw all crumbs)
	LD R3, COLR			;set color to red
	LEA R4, CRMB1			;load address containing position of crumb 1
	LD R5, NUMCRM			;load number of crumbs to draw (23)
	JSR CRMDRW
	BRnzp INPUT1
SCREEN	.FILL	xC000			;video memory starting address
PIXELS	.FILL	x3DFF			;number of video memory locations
LINES 	.FILL	#124			;number of lines on screen
DOTF	.FILL	xC07F			;last dot in first line

;line positions and data
LINEF	.FILL	xFD80			;final line on screen
LINE1	.FILL	xCC19
LINE2	.FILL	xC032
LINE12H	.FILL	#100			;height of line 1 2
LINE3	.FILL	xCC4B
LINE36W	.FILL	#53			;width of line 3 4 5 6
LINE4	.FILL	xD8B2	
LINE5	.FILL	xE54B
LINE6	.FILL	xF1B2

;crumb positions, defined by top center pixel
CRMB1	.FILL	xC58C
CRMB2	.FILL	xC5A4
CRMB3	.FILL	xC5C0
CRMB4	.FILL	xC5D8
CRMB5	.FILL	xD18C
CRMB6	.FILL	xD1A4
CRMB7	.FILL	xD1C0
CRMB8	.FILL	xD1D8
CRMB9	.FILL	xD1F0
CRMB10	.FILL	xDF8C
CRMB11	.FILL	xDFA4
CRMB12	.FILL	xDFC0
CRMB13	.FILL	xDFD8
CRMB14	.FILL	xDFF0
CRMB15	.FILL	xEB8C
CRMB16	.FILL	xEBA4
CRMB17	.FILL	xEBC0
CRMB18	.FILL	xEBD8
CRMB19	.FILL	xEBF0
CRMB20	.FILL	xF7A4
CRMB21	.FILL	xF7C0
CRMB22	.FILL	xF7D8
CRMB23	.FILL	xF7F0
NUMCRM	.FILL	#23			;number of crumbs to draw

;useful values
NUM1	.FILL	#1
NUM2	.FILL	#2
NUM3	.FILL	#3
NUM5	.FILL	#5
NUM10	.FILL	#10
NUM12	.FILL	#12
NUM127	.FILL	#127

;
;Get inputs from the user
;Control clock tick
;Branch to the correct code given an input
;
;This code is only for the first input
INPUT1	GETC				;wait for character
	JSR TIME			;start clock
	JSR GOIN1			;begin character check
;This code is for all subsequent inputs
;We will use KBSR/KBDR instead of GETC so that we can tick the clock while waiting for char
INPUT	JSR TIME			;check clock
	LDI R6, KBSR			;check keyboard status
	BRn GOIN			;begin character check if ready
	BRzp INPUT			;else go back to INPUT (to allow time to continue to elapse)
GOIN	LDI R0, KBDR			;load character value from KBDR
GOIN1	LD R1, NEGW			;compare char to w
	ADD R1, R1, R0			;
	BRz UP				;go to UP subroutine if comparison true
	LD R1, NEGS			;compare char to s
	ADD R1, R1, R0			;
	BRz DOWN			;go to DOWN subroutine if comparison true
	LD R1, NEGA			;compare char to a
	ADD R1, R1, R0			;
	BRz LEFT			;go to LEFT subroutine if comparison true
	LD R1, NEGD			;compare char to d
	ADD R1, R1, R0			;
	BRz RIGHT			;go to RIGHT subroutine if comparison true
	LD R1, NEGQ			;compare char to q
	ADD R1, R1, R0			;
	BRz BREAK			;go to BREAK subroutine if comparison true		
	BRnp INPUT			;if no comparison true, run INPUT subroutine again
BREAK	HALT				;halt execution
KBSR	.FILL	xFE00			;OS keyboard staus register address
KBDR	.FILL	xFE02			;OS keyboard data register address
NEGW	.FILL	#-119			;w ASCII comparison value
NEGS	.FILL	#-115			;s ASCII comparison value
NEGA	.FILL	#-97			;a ASCII comparison value
NEGD	.FILL	#-100			;d ASCII comparison value
NEGQ	.FILL	#-113			;q ASCII comparison value

;
;TIME subroutine
;checks if clock has ticked
;increments tick counter
;inputs:
;outputs:
TIME	LDI, R6, TMR		;load timer register
	BRn OFF			;if negative (MSB=1) go to OFF
	RET
OFF	LD R6, TICKS		;load current tick counter
	ADD R6, R6, #1		;increment tick counter
	ST R6, TICKS		;store new tick counter
	RET
TICKS	.FILL	0		;tick counter
TMR	.FILL	xFE08		;OS timer register address
TMI 	.FILL 	xFE0A		;OS time interval register address
INT	.FILL	#500		;desired tick interval

;
;code for 4 movemnt directions
;all movements check for obstacles before completing
UP	LD R0, POS			;load mouse position from memory
	LD R6, UP2			;load value -256 from memory
	ADD R0, R6, R0			;decrement position by 256
	;set up EDGTST subroutine
	;check for obstacle 1 or 2 lines above
	LD R1, NUM10			;set width to 10
	LD R2, NUM2			;set height to 2
	JSR EDGTST
	LD R0, POS			;load mouse position from memory
	LD R6, UP2			;load value -256 from memory
	ADD R0, R6, R0			;decrement mouse position by 256 (2 lines)
	ST R0, POS			;store new position to memory
	;set up DRAW subroutine
	LD R1, NUM10			;set width to 10
	LD R2, NUM2			;set height to 2
	LD R3, COLGY			;set color to gray
	JSR DRAW
	LD R6, DOWN12			;load value 1536 (relative position 12 lines down)
	ADD R0, R6, R0			;incremement position by 1536 (12 lines)
	;set up DRAW subroutine
	LD R3, COLBK			;set color to black
	JSR DRAW
	BRnzp INPUT

DOWN	LD R0, POS			;load mouse position from memory
	LD R6, DOWN12			;load value 1536 (relative position 12 lines down)
	ADD R0, R6, R0			;increment position by 1536 (12 lines)
	;set up EDGTST subroutine
	;check for obstacle 1 or 2 lines below
	LD R1, NUM10			;set width to 10
	LD R2, NUM2			;set height to 2
	JSR EDGTST
	;set up DRAW subroutine
	LD R0, POS			;load mouse position from memory
	LD R1, NUM10			;set width to 10
	LD R2, NUM2			;set height to 2
	LD R3, COLBK			;set color to black
	JSR DRAW
	LD R6, DOWN2			;load value 256 from memory
	ADD R0, R6, R0			;increment mouse position by 256 (2 lines)
	ST R0, POS			;store new position to memory
	;set up DRAW subroutine
	LD R2, NUM12			;set height to 12
	LD R3, COLGY			;set color to gray
	JSR DRAW
	BRnzp INPUT

LEFT	LD R0, POS			;load mouse position from memory
	;set up EDGTST subroutine
	;check for obstacle 1 or 2 lines left
	ADD R0, R0, #-2			;decrememnt position by 2
	LD R1, NUM2			;set width to 2
	LD R2, NUM12			;set height to 12
	JSR EDGTST
	LD R0, POS			;load mouse position from memory
	ADD R0, R0, #-2			;decrement mouse position by 2
	ST R0, POS			;store new position to memory
	;set up DRAW subroutine
	LD R1, NUM2			;set width to 2
	LD R2, NUM12			;set height to 12
	LD R3, COLGY			;set color to gray
	JSR DRAW
	;set up DRAW subroutine
	ADD R0, R0, #10			;increment position by 10
	LD R3, COLBK			;set color to black
	JSR DRAW
	BRnzp INPUT

RIGHT	LD R0, POS			;load mouse position from memory
	;set up EDGTST subroutine
	ADD R0, R0, #10			;increment position by 10
	LD R1, NUM2			;set width to 2
	LD R2, NUM12			;set height to 12
	JSR EDGTST
	;set up DRAW subroutine
	LD R0, POS			;load mouse position from memory
	LD R1, NUM2			;set width to 2
	LD R2, NUM12			;set height to 12
	LD R3, COLBK			;set color to black
	JSR DRAW
	ADD R0, R0, 2
	ST R0, POS			;store new position to memory
	;set up DRAW subroutine
	LD R1, NUM10			;set width to 10
	LD R3, COLGY			;set color to gray
	JSR DRAW
	BRnzp INPUT

;color codes
COLR	.FILL	x7C00			;red
COLB	.FILL	x001F			;blue
COLY	.FILL	x7FED			;yellow
COLGY	.FILL	x4210			;gray
COLBK	.FILL	x0000			;black
NEGBLU	.FILL	xFFE1			;2's complement of blue color code
NEGRED	.FILL	x8400			;2's complement of red color code
NEGYLW	.FILL	x8013			;2's complement of yellow color code

;position offsets
UP2	.FILL	#-256			;relative position 2 lines above
DOWN1	.FILL	#128			;relative position 1 line below
DOWN2	.FILL	#256			;relative position 2 lines below
DOWN12	.FILL	#1536			;relative position 12 lines below

;position variables
POS	.FILL	xEE04			;mouse position (initial position 0xEE04 coordinates (x,y)=(4,92))
POSCHS	.FILL	xC26F			;cheese position (initial position 0xC25F coordinates (x,y)=(111,4))

;
;DRAW subroutine
;draws a rectangle on the screen
;inputs: R0 R1 R2 R3
;outputs:
;R0: position (top-left corner)
;R1: width
;R2: height
;R3: color
;inputs are preserved after execution
DRAW	ST R0, DVAR0			;store input position
	ST R1, DVAR1			;store input width
	ST R2, DVAR2			;store input height
	ADD R4, R0, 0			;set R4 to position
LOOPD	STR, R3, R4, 0			;store color into position
	ADD R4, R4, 1			;increment position by 1
	ADD R1, R1, #-1			;decrement width (counter) by 1
	BRp LOOPD			
	LD R6, DOWN1			;load 128 (relative position 1 line down)
	ADD R0, R6, R0			;add 128 to the input position
	ADD R4, R0, 0			;set R4 to new position
	LD R1, DVAR1			;reload width to R1
	ADD R2, R2, #-1			;decrement line counter (height)
	BRp LOOPD
	LD R0, DVAR0			;restore input position
	LD R1, DVAR1			;restore input width
	LD R2, DVAR2			;restore input height
	RET				;return to initial subroutine execution point (JSR DRAW)
DVAR0	.BLKW	1
DVAR1	.BLKW	1
DVAR2	.BLKW	1

;
;CRMDRW subroutine
;draws crumbs on the screen at positions defined in memory
;inputs: R3 R4 R5
;outputs:
;R3: crumb color
;R4: address containing position of first crumb
;R5: number of crumbs to be drawn
CRMDRW	ST R7, CVAR7			;store R7 (contains PC from last subroutine execution (JSR CRMDRW))
	ST R4, CVAR4			;store address containing position of first crumb
LOOPC	LDR R0, R4, 0			;load position of crumb from address in R4
	;set up DRAW subroutine
	LD R1, NUM1			;set width to 1
	LD R2, NUM3			;set height to 3
	JSR DRAW			
	LD R6, NUM127			;load 127 (relative position 1 line down and 1 pixel left)
	ADD R0, R0, R6			;add 127 to position
	;set up DRAW subroutine
	LD R1, NUM3			;set width to 3
	LD R2, NUM1			;set height to 1
	JSR DRAW
	LD R4, CVAR4			;load address from memory
	ADD R4, R4, 1			;increment address
	ST R4, CVAR4			;store address to memory
	ADD R5, R5, #-1			;decrement crumb counter
	BRp LOOPC
	LD R7, CVAR7			;restore previous value of R7 
	RET				;return to intial subroutine execution point (JSR CRMDRW)
CVAR4	.BLKW	1
CVAR7	.BLKW	1

;
;EDGTST subroutine
;checks for colored pixels in a region
;inputs: R0 R1 R2
;outputs: R4 R5
;R0: position (top-left corner of region)
;R1: width
;R2: height
;R4: position of colored pixel
;R5: color of pixel
EDGTST	ST R1, EVAR1			;store input width
	ADD R4, R0, 0			;set R4 to position
LOOPR	LDR, R5, R4, 0			;load color from position
	ADD R5, R5, 0			;compare color to x0000 (black)
	BRnp FAULT			;run FAULT routine if comparison true
	ADD R4, R4, 1			;increment position by 1
	ADD R1, R1, #-1			;decrement width (counter) by 1
	BRp LOOPR		
	LD R6, DOWN1			;load 128 (relative position 1 line down)
	ADD R0, R6, R0			;add 128 to input position
	ADD R4, R0, 0			;set R4 to new position
	LD R1, EVAR1			;reload width to R1
	ADD R2, R2, #-1			;decrement line counter (height)
	BRp LOOPR
	RET				;return to initial subroutine execution point (JSR EDGTST)
EVAR1	.BLKW	1

;
;FAULT subroutine
;controls execution after colored pixel identified
;inputs: R4 R5
;outputs: 
;R4: position of colored pixel
;R5: color of pixel
FAULT	;if pixel is blue, mouse is trying to run into a wall
	;mouse cannot cross wall, get a new INPUT
	LD R0, NEGBLU			;load color blue comparison value
	ADD R1, R5, R0			;compare to input color
	BRz INPUT			;go to INPUT if comparison true
	;if pixel is yellow, mouse is moving into the cheese
	;mouse has collected cheese, go to CHEESE
	LD R0 NEGYLW			;load color yellow comparison value
	ADD R1, R5, R0			;compare to input color
	BRz CHEESE			;go to CHEESE if comparison true
	;if pixel is red, mouse has reached a crumb
	LD R0, NEGRED			;load color red comparison value
	ADD R1, R5, R0			;compare to input color
	BRnp ENDF			;if comparison false, go to ENDF
	;if the comparison was not false, mouse has reached a crumb
	ST R7, FVAR7			;store R7 (contains PC from last subroutine execution (JSR EDGTST))
	JSR CRUMB			;run CRUMB subroutine (delete crumb and increment counter)
	LD R7, FVAR7			;restore previous value of R7
ENDF	RET				;return to initial subroutine execution point (JSR EDGTST)
	;allows mouse to move into the space previously occupied by the crumb
FVAR7	.BLKW	1
	
;
;CRUMB subroutine
;deletes crumb detected by mouse
;increments crumb counter
;inputs: R4
;outputs:
;R4: position of identified pixel (can be any pixel of the crumb)
CRUMB	LD R6, UP2			;load -256 (relative position 2 lines up)
	ADD R4, R4, R6			;subtract 256 from input position
	ADD R0, R4, #-2			;subtract 2 from input position, store in R0
	;set up DESTROY subroutine	
	LD R1, NUM5			;set width to 5
	LD R2, NUM5			;set height to 5
	LD R3, COLBK			;set color to black
	LD R4, NEGRED			;set comparison color to red
	ST R7, BVAR7			;store R7 (contains PC from last subroutine execution (JSR CRUMB))
	JSR DESTROY
	LD R6, CMBCNT			;load current crumb counter
	ADD R6, R6, #1			;increment crumb counter
	ST R6, CMBCNT			;store new crumb counter
	LD R7, BVAR7			;restore previous value of R7
	RET				;return to initial subroutine execution point (JSR EDGTST)
BVAR7	.BLKW	1
CMBCNT	.FILL	0

;
;DESTROY subroutine
;changes all pixels in a region from one color to a different color
;inputs: R0 R1 R2 R3 R4
;outputs:
;R0: position (top-left corner of region)
;R1: width
;R2: height
;R3: final color (color to set pixels to)
;R4: comparison color (must be 2's complement of color code)
DESTROY	ST R1, SVAR1			;store input width
	ADD R5, R0, 0			;set R5 to position
LOOPS	LDR R6, R5, 0			;load color from position
	ADD R6, R6, R4			;compare to input comparison color
	BRnp SKIP			;if comparison false, SKIP
	STR R3, R5, 0			;else, store final color to position
SKIP	ADD R5, R5, 1			;increment position
	ADD R1, R1, #-1			;decrement width (counter)
	BRp LOOPS
	LD R6, DOWN1			;load 128 (relative position 1 line down)
	ADD R0, R0, R6			;add 128 to input position
	ADD R5, R0, 0			;set R5 to new position
	LD R1, SVAR1			;restore input width
	ADD R2, R2, #-1			;decrement line counter (height)
	BRp LOOPS
	RET				;return to initial subroutine execution point (JSR DESTROY)
SVAR1	.BLKW	1

;
;The mouse has reached the cheese
;Delete the cheese from the screen
;output the end of game message
;output the number of crumbs collected
;;output the elapsed time
CHEESE	JSR TIME			;check time
	;set up DRAW subroutine
	LD R0, POSCHS			;load position of cheese
	LD R1, NUM12			;set width to 12
	LD R2, NUM12			;set height to 12
	LD R3, COLBK			;set color to black
	JSR DRAW
	LEA R0, COMPL1			;load address of first string
	PUTS				;print string
	LD R0, CMBCNT			;load crumb counter
	JSR DIGIT			;convert crumb counter to digits
	JSR PRINT			;print digits
	LEA R0, COMPL2			;load address of second string
	PUTS				;print string
	LD R0, TICKS			;load clock tick counter
	JSR FORMAT			;format clock ticks (create minute second and dec count)
	LD R0, MINUTES			;load minute count
	JSR DIGIT			;convert minutes to digits
	JSR PRINT			;print digits
	LEA R0, COMPL3			;load address of string ":"
	PUTS				;print string
	LD R0, SECONDS			;load second count
	JSR DIGIT			;convert seconds to digits
	JSR PRINT			;print digits
	LEA R0, COMPL4			;load address of string "."
	PUTS				;print string
	LD R4, DEC			;load 1st decimal digit
	AND R5, R5, 0			;set second place to zero
	JSR PRINT			;print decimal
	HALT				;end execution
COMPL1	.STRINGZ	"\nGreat Job!\nYou collected "
COMPL2	.STRINGZ	" crumbs in "
COMPL3	.STRINGZ	":"
COMPL4	.STRINGZ	"."
ASCII	.FILL	x30
NEG100	.FILL	#-100

;
;FORMAT subroutine
;converts ticks to minutes, seconds, and half-seconds
;inputs: R0
;outputs: 
;R0: tick counter (1 tick = 500ms)
FORMAT	LD R5, NEG120			;load value -120 (1 minute in ticks)
	AND R6, R6, 0			;clear R6 (counter)
	;count the number of minutes
LOOPF1	ADD R6, R6, 1			;increment minute counter
	ADD R0, R0, R5			;subtract 120 from tick counter
	BRzp LOOPF1			;continue until negative
	;we've counted one too many
	;decrement minute counter and add 120 back to tick counter
	ADD R6, R6, #-1			;decrement minute counter
	ST R6, MINUTES			;store counter to MINUTES
	LD R6, NUM120			;load 120
	ADD R0, R0, R6			;add 120 back to tick counter
	AND R6, R6, 0			;clear counter
	;count the number of seconds
LOOPF2	ADD R6, R6, 1			;increment second counter
	ADD R0, R0, #-2			;subtract 2 from tick counter (1 second in ticks)
	BRzp LOOPF2			;continue until negative
	;we've counted one too many
	;decrement second counter and add 2 back to tick counter
	ADD R6, R6, #-1			;decrement second counter
	ST R6, SECONDS			;store counter to SECONDS
	ADD R0, R0, 2			;add 2 back to tick counter
	;if tick counter 1, we have 0.5 seconds left
	;if tick counter 0, we have 0.0 seconds left
	ADD R0, R0, #-1			;subtract 1 from tick counter
	BRz HALF			;if result 0, go to HALF (we have half a second left)
	AND R1, R1, 0			;else set R1 to 0
	ST R1, DEC			;store 0 to DEC
	RET
	;if there was one tick left, we need to set the decimal digit to 5
HALF	LD R1, VAL5			;load 5
	ST R1, DEC			;store 5 to DEC
	RET
MINUTES	.BLKW	1			;minute counter
SECONDS	.BLKW	1			;second counter
DEC	.BLKW	1			;decimal place
NUM120	.FILL	#120			
NEG120	.FILL	#-120
NEG2	.FILL	#-2
VAL5	.FILL	#5

;
;DIGIT subroutine
;converts quantity (n<100) into 10s and 1s digit
;inputs: R0
;outputs: R4 R5
;R0: input quantity
;R4: 10s digit
;R5: 1s digit
DIGIT	AND R4, R4, #0		;clear R2 (counter)
LOOPT	ADD R4, R4, 1		;increment counter (count how many 10s are in the number)
	ADD R0, R0, #-10	;subtract 10 from product
	BRzp LOOPT		;continue until result is negative
	;we have actually incremented the counter 1 too high and subtracted 1 too many 10s from the product
	ADD R4, R4, #-1		;decrement counter (# of 10s)
	ADD R5, R0, #10		;add the extra 10 back (to get remainder)
	RET			;return to initial subroutine execution point (JSR DIGIT)

;
;PRINT subroutine
;prints two numbers
;inputs: R4 R5
;outputs:
;R4: 1st number to print
;R5: 2nd number to print
PRINT	ST R7, PVAR7		;store R7 (contains PC from last subroutine execution (JSR PRINT))
	LD R6, ASCII		;load ASCII offset
	ADD R0, R4, R6		;add ASCII offset to first number
	OUT			;print character
	ADD R0, R5, R6		;add ASCII offset to second number
	OUT			;print character
	LD R7, PVAR7		;restore previous value of R7
	RET			;return to initial subroutine execution point (JSR PRINT)
PVAR7	.BLKW	1

.END