#Anthony Tang, Cole Swingholm 
	#ajt161230 css160030
	
#Computer Architecture Final Project 

	#dungeon crawler. Get the P to the G using wasd, avoid M monsters. 
	
.data
welcome:	.asciiz	"Welcome to 'Computer Architecture Project' the Game: "
		.align 2
controls:	.asciiz "\nuUse W A S and D to navigate the field. Go for the $ and avoid the 4 ghosts"
		.align 2
	
		#full (blank) field. 
mapArray:  	.byte   '_','_','_','_','_','_','_','_',
			'_','_','_','_','_','_','_','_',
			'_','_','_','_','_','_','_','_',
			'_','_','_','_','_','_','_','_',
			'_','_','_','_','_','_','_','_',
			'_','_','_','_','_','_','_','_',
			'_','_','_','_','_','_','_','_',
			'_','_','_','_','_','_','_','_'
			#64 _ 's
		.space 4

newline:	.asciiz  "\n"
		
spacer: 	.ascii " | "
		.align 2
		
framebreak:	.asciiz "\n ----------------------------------"
#user input goes here
userString:	.space 8
		.align 2

#character bytes and ascii values 	
character:	.byte 'P'
		.align 2
			
goal:		.byte '$'
		.align 2
				
monster: 	.byte 'M'
		.align 2
inky:		.byte   'I'
blinky:		.byte	'B'
pinky:		.byte	'K'
clyde:		.byte	'C'

blank:		.byte '_'
		.align 2

#input keys 
	w:	.byte 'w'
	a:	.byte 'a'
	s:	.byte 's'
	d:	.byte 'd'
	
#win and lose messages 
winNote:	.asciiz	"You win! "
congrats:	.asciiz "Congratulations!"
loseNote:	.asciiz "Game Over: "
areDead:	.asciiz "You have died"

########################################################################
.text 	
main:
intro:	#welcome to game. 
	#how to play
	la	$a0, welcome	#message type 
	la	$a1, controls
	li	$v0, 59
		syscall

mapGen:
	#pick a number between 0 and 24 to place the player 
	li	$v0, 42	#random number
	li	$a1, 64
		syscall
	move 	$s3, $a0 #the random number should be in $a0
	
		#place the goal
	li	$v0, 42	#random number
	li	$a1, 64
		syscall
	move 	$s4, $a0
	
	#make 4 monsters $t7, $t6, $t5, $t4,
	#place the monster
	li	$v0, 42	#random number
	li	$a1, 64
		syscall
	move 	$t7, $a0

	li	$v0, 42	#random number
	li	$a1, 64
		syscall
	move 	$t6, $a0

	li	$v0, 42	#random number
	li	$t5, 64
		syscall
	move	$t5, $a0
	
	li	$v0, 42	#random number
	li	$t5, 64
		syscall
	move	$t4, $a0

checkOverlap:
	#runs through all possible overlap configurations 
	#check to see if the spot is occupied 
		#ensures the player, ghosts, and $ will not spawn on the same spot 
	beq 	$s3, $s4 spotConflict	#player $ same spot
		
	beq	$s4, $t7, spotConflict #goal ghost same spot 
	beq	$s4, $t6, spotConflict	
	beq	$s4, $t5, spotConflict
	beq	$s4, $t4, spotConflict
	
	beq	$s3, $t7, spotConflict #player ghost same spot
	beq	$s3, $t6, spotConflict
	beq	$s3, $t5, spotConflict
	beq	$s3, $t4, spotConflict
	
		
		sub	$t0, $s3, $s4
		abs	$t0, $t0
	beq	$t0, 8, spotConflict	#above or below
			
		sub	$t0, $s4, $s5   #next to each other
		abs	$t0, $t0
	beq	$t0, 1, spotConflict 
	
	
	
##################################################################	
gameloop:
	add	$t0, $zero, $zero	#zero temp register
	
	#check for win conditions------------------------------------------
	#if p == g -> win exit
	#if p = m ->lose exit
	beq	$s3, $s4, win
	beq	$s3, $t7, lose
	beq	$s3, $t6, lose
	beq	$s3, $t5, lose
	beq	$s3, $t4, lose
	#------------------------------------------------------
	#print the map
	li	$v0, 4
	la	$a0, framebreak
		syscall
	
	li	$s0, 0	#$s0 is map array register 
	la	$s7, mapArray	#load address of mapArray into $s7
	
	#add character
	lb	$t0, character
		#'P' in character
	sb 	$t0, mapArray($s3)
	
	#add Goal
	lb	$t0, goal
		#'G' in character
	sb 	$t0, mapArray($s4)
	
	#add Monster 1
	lb	$t0, inky
		#'I' in character
	sb 	$t0, mapArray($t7)
	#add Monster 2
	lb	$t0, blinky
		#'B' in character
	sb 	$t0, mapArray($t6)
	#add Monster 3
	lb	$t0, pinky
		#'P' in character
	sb 	$t0, mapArray($t5)
	#add Monster 4
	lb	$t0, clyde
		#'C' in character
	sb 	$t0, mapArray($t4)
##################################################################	
	mapPrintLoop:
		li	$s1, 0	#counter
		li	$s2, 8 	#linebreak
		
		li	$v0, 4
		la 	$a0, newline	#print linebreak
			syscall
			
		#print spacer 
		li	$v0, 4
		la	$a0, spacer
			syscall

		rowPrintLoop:
			#print character
			lb 	$a0, 0($s7)	 #whatever point in array
			li	$v0, 11		#print character syscall
				syscall
			
			addi	$s7, $s7, 1	#point to next char in array
		
			#print spacer 
			li	$v0, 4
			la	$a0, spacer
				syscall

			addi	$s1, $s1, 1
			addi	$s0, $s0, 1
		
			beq 	$s0, 64, movement
			beq	$s1, $s2, mapPrintLoop	

			j 	rowPrintLoop	#else just keep doing row print loop 
			
##################################################################	

#game play, jumps to gameloop
movement:
	#call monster movement, moves all the monsters in accordance to their algorithms 
	mobTurn:
		jal	monsterMove
	#goes to the monster's turn. Upon completion, returns to here. 
	
	#------------------------------------------------------
	userTurn:
	#get movement 
	li	$v0, 8
	la	$a0, userString
	li	$a1, 8
		syscall		
	lb	$s6, 0($a0)	#s6is movement char
	
	li	$t0, 'w'
	beq	$t0, $s6, up
	
	li	$t0, 's'
	beq	$t0, $s6, down

	li	$t0, 'a'
	beq	$t0, $s6, left
	
	li	$t0, 'd'
	beq	$t0, $s6, right
	
	j	gameloop
	#------------------------------------------------------	
	
monsterMove:
	#moves the 4 monsters. 
	#uses a chase, sometimes chase, mirror, and random algorithm to for movement. 
	#each monster movement leads into the next one's algorithm 
#--------------------------------------------------------------------------------------
	#inky: $t7 #chases character. Simple directional 
	mob1:
		#locate the player character
		#if the difference is greather than 8, on another row. 
		#If not, goes to left right based on positive or negative distance value
		sub 	$t0, $s3, $t7
		bgtz	$t0, IkRightDown
		blez	$t0, IkLeftUp
		#else, go to mob2 
		j	mob2	
		#if mob location is less, it will be above or to the left
		IkLeftUp:
			abs	$t0, $t0
			bgt	$t0, 8, up1
			j	left1
		#if its greater, it wil be below or to the right
		IkRightDown: 
			abs	$t0, $t0
			bgt	$t0, 8, down1
			j	right1	
	up1:	
		li	$t1, '_'		#replace former point with normal spacer
		sb	$t1, mapArray($t7)
		addi	$t7, $t7, -8
		rem	$t7, $t7, 64
		bltz 	$t7, neg1
		j	mob2			#after movement is made, jumps to next mob's algorithm 
		
	left1:	
		li	$t1, '_'		#replace former point with normal spacer
		sb	$t1, mapArray($t7)
		addi	$t7, $t7, -1
		rem	$t7, $t7, 64
		bltz 	$t7, neg1
		j	mob2	
	down1:
		li	$t1, '_'		#replace former point with normal spacer
		sb	$t1, mapArray($t7)
		addi	$t7, $t7, 8
		rem	$t7, $t7, 64
		bltz 	$t7, neg1
		j	mob2	
		
	right1:
		li	$t1, '_'		#replace former point with normal spacer
		sb	$t1, mapArray($t7)
		addi	$t7, $t7, 1
		rem	$t7, $t7, 64
		bltz 	$t7, neg1
		j	mob2	
	neg1:	
		addi	$t7, $t7, 64
		rem	$t7, $t7, 64
		j 	mob2
#--------------------------------------------------------------------------------------
	#blinky: $t6 
	#1/2 times will go after character. 
	#other 1/2 times will be random
	mob2:
		li	$v0, 42	#random number
		li	$a1, 47
			syscall
		move 	$t0, $a0
		rem	$t0, $t0, 2 #checks even or odd. 0 for even. 1 for odd. 
		
		beq	$t0, 1, pursue	#if its odd, will go to pursue. 
		
		li	$v0, 42	#random number
		li	$a1, 4
			syscall
		move 	$t0, $a0
	
		beq	$t0, 0, up2
		beq	$t0, 1, left2
		beq	$t0, 2, down2
		beq	$t0, 3, right2
		#otherwise goes in accordance to the randomized function 
	pursue:
		#modified version of the inky algorithm for tracking. 
		sub 	$t0, $s3, $t6
		bgtz	$t0, BkyRightDown
		blez	$t0, BkyLeftUp
		#else, go to mob3
		j	mob3
		
		#if mob location is less, it will be above or to the left
		BkyLeftUp:
			abs	$t0, $t0
			blt	$t0, 8, left2
			j	up
		#if its less, it will go right. 
		BkyRightDown: 
			abs	$t0, $t0
			blt	$t0, 8, right2
			j	down2	
	up2:	
		li	$t2, '_'		#replace former point with normal spacer
		sb	$t2, mapArray($t6)
		addi	$t6, $t6, -8
		rem	$t6, $t6, 64
		bltz 	$t6, neg2
		j	mob3	
	left2:	
		li	$t2, '_'		#replace former point with normal spacer
		sb	$t2, mapArray($t6)
		addi	$t6, $t6, -2
		rem	$t6, $t6, 64
		bltz 	$t6, neg2
		j	mob3
	down2:
		li	$t2, '_'		#replace former point with normal spacer
		sb	$t2, mapArray($t6)
		addi	$t6, $t6, 8
		rem	$t6, $t6, 64
		bltz 	$t6, neg2
		j	mob3	
		
	right2:
		li	$t2, '_'		#replace former point with normal spacer
		sb	$t2, mapArray($t6)
		addi	$t6, $t6, 2
		rem	$t6, $t6, 64
		bltz 	$t6, neg2
		j	mob3	
	neg2:	
		addi	$t6, $t6, 64
		rem	$t6, $t6, 64
		j 	mob3
#--------------------------------------------------------------------------------------
	#pinky: $t5 #randomized movement 
	mob3:
	li	$v0, 42	#random number
	li	$a1, 4
		syscall
	move 	$t0, $a0
	
	#1/4 chance to go in every direction
	beq	$t0, 0, up3
	beq	$t0, 1, left3
	beq	$t0, 2, down3
	beq	$t0, 3, right3
	up3:	
		li	$t1, '_'		#replace former point with normal spacer
		sb	$t1, mapArray($t5)
		addi	$t5, $t5, -8
		rem	$t5, $t5, 64
		abs	$t5, $t5
		j	mob4 
		
	left3:	
		li	$t1, '_'		#replace former point with normal spacer
		sb	$t1, mapArray($t5)
		addi	$t5, $t5, -1
		rem	$t5, $t5, 64
		abs	$t5, $t5
		j	mob4
	down3:
		li	$t1, '_'		#replace former point with normal spacer
		sb	$t1, mapArray($t5)
		addi	$t5, $t5, 8
		rem	$t5, $t5, 64
		abs	$t5, $t5
		j	mob4
		
	right3:
		li	$t1, '_'		#replace former point with normal spacer
		sb	$t1, mapArray($t5)
		addi	$t5, $t5, 1
		rem	$t5, $t5, 64
		abs	$t5, $t5
		j	mob4	

#--------------------------------------------------------------------------------------
	#Clyde: $t4 #mirrors the players movements 
		#s6 contains the character of the players movement. Change it up a little from that
		
	mob4:
		beq	$s6, 'w', down4	#invert the player controls 
		beq	$s6, 'a', right4
		beq	$s6, 's', up4
		beq	$s6, 'd', left4
		#if for some reason that was not an option, just go right 
		j	right4
		
	up4:	
		li	$t1, '_'		#replace former point with normal spacer
		sb	$t1, mapArray($t4)
		addi	$t4, $t4, -8
		rem	$t4, $t4, 64
		abs	$t4, $t4
		j	mobDone			#monsters are done moving
		
	left4:	
		li	$t1, '_'		#replace former point with normal spacer
		sb	$t1, mapArray($t4)
		addi	$t4, $t4, -1
		rem	$t4, $t4, 64
		abs	$t4, $t4
		j	mobDone
	down4:
		li	$t1, '_'		#replace former point with normal spacer
		sb	$t1, mapArray($t4)
		addi	$t4, $t4, 8
		rem	$t4, $t4, 64
		abs	$t4, $t4
		j	mobDone
		
	right4:
		li	$t1, '_'		#replace former point with normal spacer
		sb	$t1, mapArray($t4)
		addi	$t4, $t4, 1
		rem	$t4, $t4, 64
		abs	$t4, $t4
		j	mobDone	
#--------------------------------------------------------------------------------------	
	mobDone: 
		jr	$ra #head back to monsterMove spot 

exit:
	li	$v0, 4
	la 	$a0, newline	#print linebreak
		syscall
	li	$v0, 10		#exit program
		syscall
	
##################################################################	
	#methods	
spotConflict:
	#if theres an overlap, scramble the goal and the player by adding a random number to both
	#take the modulus to ensure no map overflow
	li	$v0, 42	#random number
	li	$a1, 64 #0-63
		syscall #in $a0
	addi	$s3, $s3, 1
	add	$s4, $s4, $a0
	rem	$s3, $s3, 64
	rem	$s4, $s4, 64
	j	checkOverlap

#up down left right, moves the player either +1, -1 for horizontal, or +8 and -8 for vertical.
#uses modulus to account for rollover over 64, uses the negativeCondition method to deal with leaving
#the field through the top. (see negnegativeCondition)
up: 	
	li	$t1, '_'		#replace former point with normal spacer
	sb	$t1, mapArray($s3)
	addi	$s3, $s3, -8
	rem	$s3, $s3, 64
	bltz 	$s3, negativeCondition
	j	gameloop
		
down:
	li	$t1, '_'		#replace former point with normal spacer
	sb	$t1, mapArray($s3)
	addi	$s3, $s3, 8
	rem	$s3, $s3, 64
	bltz 	$s3, negativeCondition
	j	gameloop

left:
	li	$t1, '_'		#replace former point with normal spacer
	sb	$t1, mapArray($s3)
	addi	$s3, $s3, -1
	rem	$s3, $s3, 64
	bltz 	$s3, negativeCondition
	j	gameloop
	
right:	
	li	$t1, '_'		#replace former point with normal spacer
	sb	$t1, mapArray($s3)
	addi	$s3, $s3, 1
	rem	$s3, $s3, 64
	bltz 	$s3, negativeCondition
	j	gameloop

#adds 64 to bring it to the bottom
negativeCondition:
	#have a rollover. Top to bot. 
	addi	$s3, $s3, 64
	j	gameloop 

win:	#you win
	#dialogue box
	la	$a0, winNote	#message type 
	la	$a1, congrats	#message text
	li	$v0, 59
		syscall
	j exit	#on the win or lose conditions, the game loop is teminated

lose:	#you lose 
	#dialogue box
	la	$a0, loseNote	#message type 
	la	$a1, areDead	#message text
	li	$v0, 59
		syscall
	j exit
