
.data
mapArray:  	.byte '_','_','_','_','_','_','_','_','_','_','_','_','_','_','_','_','_','_','_','_','_','_','_','_','_' #25 _ 's
newline:	.asciiz  "\n"
		
spacer: 	.ascii " | "
		.align 2
		
framebreak:	.asciiz "\n ---------------------------"

userString:	.space 8
		.align 2

#character bytes and ascii values 	
character:	.byte 'P'
		.align 2	
goal:		.byte 'G'
		.align 2
		
monster: 	.byte 'M'
		.align 2
		
blank:		.byte '_'
		.align 2

#input keys 
	w:	.byte 'w'
	a:	.byte 'a'
	s:	.byte 's'
	d:	.byte 'd'
	
.text
main:

mapGen:
	#pick a number between 0 and 24 to place the player 
	li	$v0, 42	#random number
	li	$a1, 24
		syscall
	move 	$s3, $a0 #the random number should be in $a0
	
	#place the monster
	li	$v0, 42	#random number
	li	$a1, 24
		syscall
	move 	$s4, $a0
	
	#place the goal
	li	$v0, 42	#random number
	li	$a1, 24
		syscall
	move 	$s5, $a0

checkOverlap:
	#runs through all possible overlap configurations 
	#check to see if the spot is occupied 
	beq 	$s3, $s4, spotConflict
		#or if the spot if within one above / below spaces 
		sub	$t0, $s3, $s4
		abs	$t0, $t0
	beq	$t0, 5, spotConflict	
		sub	$t0, $s4, $s5
		abs	$t0, $t0
	beq	$s4, $s5, spotConflict 
		sub	$t0, $s3, $s5
		abs	$t0, $t0
	beq	$s3, $s5, spotConflict 
	
##################################################################	
#TODO:add provision for play being too close to goal


##################################################################	
gameloop:

#check for win conditions
	#if p == g -> win exit
	#if p = m ->lose exit
	
	beq	$s3, $s5, lose
	beq	$s3, $s4, win
	
	li	$v0, 4
	la	$a0, framebreak
		syscall
	
	li	$s0, 0	#$s0 is map array register 
	la	$s7, mapArray	#load address of mapArray into $s7
	
	#add character
	lb	$t0, character
		#'p' in character
	sb 	$t0, mapArray($s3)
	
	#add Monster
	lb	$t0, monster
		#'M' in character
	sb 	$t0, mapArray($s4)
	
	#add Goal
	lb	$t0, goal
		#'M' in character
	sb 	$t0, mapArray($s5)
	
	mapPrintLoop:
		li	$s1, 0	#counter
		li	$s2, 5 	#linebreak
		
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
		
		beq 	$s0, 25, movement
		beq	$s1, $s2, mapPrintLoop	

		j 	rowPrintLoop	#else just keep doing row print loop 
##################################################################	

#game play, jumps to gameloop
movement:
	li	$v0, 8
	la	$a0, userString
	li	$a1, 8
		syscall		
	lb	$s6, 0($a0)	#s6 is movement char
	
	li	$t0, 'w'
	beq	$t0, $s6, up
	
	li	$t0, 's'
	beq	$t0, $s6, down
	
	li	$t0, 'a'
	beq	$t0, $s6, left
	
	li	$t0, 'd'
	beq	$t0, $s6, right
	
#put monster movment here	 
	#else go back to game loop and reprint map

exit:
	li	$v0, 4
	la 	$a0, newline	#print linebreak
		syscall
		
	li	$v0, 10
	syscall
	
	
##################################################################	
	#methods	
spotConflict:
	#adds, takes remainder. Goes back to top. 
	addi	$s3, $s4, 1
	rem	$t0, $s4, 25
	j	checkOverlap

up: 	
	li	$t1, '_'		#replace former point with normal spacer
	sb	$t1, mapArray($s3)
	addi	$s3, $s3, -5
	rem	$s3, $s3, 25
	j	gameloop	
down:
	li	$t1, '_'		#replace former point with normal spacer
	sb	$t1, mapArray($s3)
	addi	$s3, $s3, 5
	rem	$s3, $s3, 25
	j	gameloop

left:
	li	$t1, '_'		#replace former point with normal spacer
	sb	$t1, mapArray($s3)
	addi	$s3, $s3, -1
	rem	$s3, $s3, 25
	j	gameloop
right:	
	li	$t1, '_'		#replace former point with normal spacer
	sb	$t1, mapArray($s3)
	addi	$s3, $s3, 1
	rem	$s3, $s3, 25
	j	gameloop
	
win:	#you win
	#implement dialogue box
	j exit

lose:	#you lose 
	#implement dialogue box
	j exit
