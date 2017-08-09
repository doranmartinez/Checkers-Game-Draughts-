	.data
nl:	.asciiz "\n"
row:	.asciiz "Enter Row (0-5): "
col:	.asciiz "Enter Column (0-5): "
row1:	.asciiz "Enter Row1: "
row2:	.asciiz "Enter Row2: "
col1:	.asciiz "Enter Col1: "
col2:	.asciiz "Enter Col2: "
val:	.asciiz "Enter a value for the location: "
bad:	.asciiz "Invalid Row/Col! "
good:	.asciiz "Valid Row/Col! "
bleh:	.asciiz "Inappropriate Values!"
exit:	.asciiz "Enter 0 to exit:"
colnum:	.asciiz " 012345"	
	.globl main
	.code
main:		# Initializes board to 0
	addi $sp,$sp,-144
	mov $s0,$sp 			# store pointer to board in $s0
	mov $s1,$sp
	li $t3,0				# Used to manipulate user location inputs
	li $t4,0				# Used for manipulation
	li $t5,0				# Used for User Row Val
	li $t6,0				# Used for User Col Val
	li $t7,0				# Used for User input Val

start:
	mov $a0,$sp
	addi $sp,$sp,-20
	sw $a0,0($sp)
	sw $t5,4($sp)
	sw $t6,8($sp)
	sw $t7,12($sp)
	jal board				# Prints board
	lw $a0,0($sp)
	lw $t5,4($sp)
	lw $t6,8($sp)
	lw $t7,12($sp)
	addi $sp,$sp,20
	
	la $a0,row				# Asks user to input Row Val
	syscall $print_string
	syscall $read_int
	beq $v0,-1,next			#exits program when -1
	mov $t5,$v0				# User Row Value->$t5
	la $a0,col				# Asks User to input Col Val
	syscall $print_string
	syscall $read_int
	mov $t6,$v0				# User Col Value->$t6
	
	addi $sp,$sp,-12			# allocates memory on stack
	sw $t5,0($sp)
	sw $t6,4($sp)
	jal lglpos				# calls lglpos()
	lw $t5,0($sp)
	lw $t6,4($sp)
	addi $sp,$sp,12			# deallocates memory on stack
	beq $v0,$0,invalid		# returns 0
	
	la $a0,val				# Asks User for location input value
	syscall $print_string
	syscall $read_int
	mov $t7,$v0				#User Input Value->$t7
	
	mov $a0,$sp				# Calls board to write array
	addi $sp,$sp,-20
	sw $a0,0($sp)
	sw $t5,4($sp)
	sw $t6,8($sp)
	sw $t7,12($sp)
	jal board
	lw $a0,0($sp)
	lw $t5,4($sp)
	lw $t6,8($sp)
	lw $t7,12($sp)
	addi $sp,$sp,20
	j start
	
next:
	addi $sp,$sp,-384		# Allocate stack for tuples array
			#Initialize Arguments
	mov $a0,$s1			# loads *board into a0
	mov $a1,$sp			# Loads *Tuples into $a1
	andi $t7,$t7,2			# grabs color from user value
	
	addi $sp,$sp,-16
	sw $a0,0($sp)			# *board
	sw $a1,4($sp)			# *tuplesList
	sw $t7,8($sp)			# color
	jal getValidMoves
	lw $a0,0($sp)			# *board
	lw $a1,4($sp)			# *tuplesList
	lw $t7,8($sp)			# color
	addi $sp,$sp,16
	
	mov $a0,$v0
	syscall $print_int		# print return value
	la $a0,nl
	syscall $print_string
	
	mov $a0,$s1
	addi $sp,$sp,-20
	sw $a0,0($sp)			# board pointer
	sw $t1,4($sp)			# r1
	sw $t2,8($sp)			# c1
	sw $t3,12($sp)			# r2
	sw $t4,16($sp)			# c2
	jal getValidJumps
	lw $a0,0($sp)			# board pointer
	lw $t1,4($sp)			# r1
	lw $t2,8($sp)			# c1
	lw $t3,12($sp)			# r2
	lw $t4,16($sp)			# c2
	addi $sp,$sp,20
	mov $a0,$v0
	syscall $print_int
esc:
	addi $sp,$sp,144
	syscall $exit
	
getValidMoves:				
			#Load User function calls from stack
	#$a0 contains *board
	# $t7 contains color
	mov $t0,$a1				# Moves *tuplesList
	li $t5,0				# total in array
	li $t6,0
	li $t1,0				#r1=0
	j t1test
t1loop:
	li $t2,0				# c1 =0
	j t2test
t2loop:
	li $t3,-1				# r2=0
	j t3test
t3loop:	
	li $t4,-1				# c2=0
	j t4test
t4loop:
	la $a0,ltpar
	syscall $print_string
	mov $a0,$t1
	syscall $print_int
	la	$a0,comma
	syscall $print_string
	mov $a0,$t2
	syscall $print_int
	la	$a0,comma
	syscall $print_string
	mov $a0,$t3
	syscall $print_int
	la	$a0,comma
	syscall $print_string
	mov $a0,$t4
	syscall $print_int
	la $a0,rtpar
	syscall $print_string
	la $a0,nl
	syscall $print_string
	
	# Checks r,w,R,W appropriate moves
		# Converts r1 from mtx value -> array value
	sub $t1,$t1,5			# r1-5 -> $t1
	abs $t1,$t1				# abs($t1)
	mul $t1,$t1,6			# 6 rows
	add $t1,$t1,$t2			# row + col
	mul $t1,$t1,4			# Makes value a multiple of 4
	add $t1,$t1,$t0			# user location -> $t1
		# Converts c1 from mtx value -> array value
	sub $t3,$t3,5			# r2-5 -> $t3
	abs $t3,$t3			# abs($t3)
	mul $t3,$t3,6			# 6 rows
	add $t3,$t3,$t4			# row + col
	mul $t3,$t3,4			# Makes value a multiple of 4
	add $t2,$t3,$t0			# location where user wants to send -> $t2
	
	beq $t1,$t2,rtrn1		# if user sends to original location return 0
	lw $t5,0($t1)			# value at user’s location -> $t1
	lw $t6,0($t2)			# value where user wants to send piece -> $t2
	
	beq $t1,$t3,rtrn1		# return 0 if r1 = r2
	beq $t5,$0,rtrn1		# return 0 if user place is blank 
	bnez $t6,rtrn1			# return 0 if user sending location!=0
			
	beq $t5,1,mvrd			#Send to specific piece type
	beq $t5,3,mvwh
	beq $t5,5,mvkg
	beq $t5,7,mvkg
	j $ra
	
mvrd:		
	sub $t1,$t1,$t3			# diff of the rows r1-r2 -> $t1
	sub $t3,$t2,$t4			# diff of col -> $t3
	abs $t3,$t3				# col can be neg
	blt $t1,-1,rtrn1		# returns 0 if diff of row < -1 “Backwards in Row”
	bgez $t1,rtrn1			# returns 0 if row >=0
	bgt $t3,1,rtrn1			# returns 0 if diff of col > 1 “lft or rt > 1 col space”
	beq $t3,$0,rtrn1		# returns 0 if diff of col = 0	 “The same col space”
	j rtrn2					# if all passes, return 1
mvwh:
	sub $t1,$t1,$t3			# diff of rows
	sub $t3,$t2,$t4			# diff of col
	abs $t3,$t3				# col can be neg
	bgt $t1,1,rtrn1			# returns 0 if row >1
	blez $t1,rtrn1			# returns 0 if row <=0
	bgt $t3,1,rtrn1			# returns 0 if col >1
	beq $t3,$0,rtrn1 		# returns 0 if col=0
	sub $t1,$t1,$t3			# $t2-$t3 should =0
	beq $t1,$0,rtrn1		#
	j rtrn2					# if all passes, return 1
mvkg:	
	sub $t1,$t1,$t3			# diff of rows
	sub $t3,$t2,$t4			# diff of col
	abs $t1,$t1				# col can be neg
	abs $t3,$t3				# row can be neg
	bgt $t1,1,rtrn1			# row !> 1
	beq $t1,0,rtrn1			# row !=0
	bgt $t1,1,rtrn1			# col !>1
	beq $t1,0,rtrn1			# col !=0
	j rtrn2					#returns 1 if passes above tests	

	mul $t6,$t5,4		# r1*4 Changes into offset
	mul $t6,$t6,4
	add $t6,$t0,$t6
	sw $t1,0($t6)
	
	mul $t6,$t5,4
	mul $t6,$t6,4
	addi $t6,$t6,4			# adds 4 for c1
	add $t6,$t0,$t6
	sw $t2,0($t6)
	
	mul $t6,$t5,4
	mul $t6,$t6,4
	addi $t6,$t6,8			# adds 8 for r2
	add $t6,$t0,$t6
	sw $t3,0($t6)
	
	mul $t6,$t5,4
	mul $t6,$t6,4
	addi $t6,$t6,12			# adds 12 for c2
	add $t6,$t0,$t6
	sw $t4,0($t6)
	
	addi $t5,$t5,1
	beq $t5,24,end
	
usrinp:
	addi $t4,$t4,2			# Increments t4loop
t4test:
	ble $t4,1,t4loop
	addi $t3,$t3,2			# increments t3loop
t3test:
	ble $t3,1,t3loop
	addi $t2,$t2,1			# increments t2loop
t2test:
	blt $t2,6,t2loop		
	addi $t1,$t1,1			# increments t1loop
t1test:
	blt $t1,6,t1loop

end:
	mov $v0,$t5
	jr $ra
	
rtrn2:
	lw $t0,0($sp)			# *board
	lw $t1,4($sp)			#r1
	lw $t2,8($sp)			#c1
	lw $t3,12($sp)			#r2
	lw $t4,16($sp)			#c2
	addi $sp,$sp,20
	li $v0,1				# Acceptable!
	jr $ra
rtrn1:
	lw $t0,0($sp)			# *board
	lw $t1,4($sp)			#r1
	lw $t2,8($sp)			#c1
	lw $t3,12($sp)			#r2
	lw $t4,16($sp)			#c2
	addi $sp,$sp,20
	li $v0,0				# Not Acceptable!
	jr $ra
	
invalid:					# Tells user invalid row/col values
	la $a0,bad		
	syscall $print_string
	la $a0,nl
	syscall $print_string
	jr $ra
invalid2:					# Tells user invalid row/col values
	la $a0,bad		
	syscall $print_string
	la $a0,nl
	syscall $print_string
	jr $ra
	
lglpos:				# Checks if Valid Row/col inputs are on the board
	addi $sp,$sp,-8
	sw $t1,0($sp)
	sw $t2,4($sp)
	lw $t1,8($sp)			# Row input
	lw $t2,12($sp)			# Col input
	bltz $t1,rtrn			# if row <0 return 0
	bgt $t1,5,rtrn			# if row >5 return 0
	bltz $t2,rtrn			# if col <0 return 0
	bgt $t2,5,rtrn			# if col >5 return 0

	andi $t1,1				# obtain least sig bit
	andi $t2,1				# obtain least sig bit
	beq $t1,$t2,rtrn		# check for odd/odd and even/even
	li $v0,1				# Returns 1 if good
	lw $t1,0($sp)
	lw $t2,4($sp)
	addi $sp,$sp,8
	jr $ra					# exit lglpos()
rtrn:		
	lw $t1,0($sp)
	lw $t2,4($sp)
	addi $sp,$sp,8
	li $v0,0				# Returns 0 if bad
	jr $ra					# exit lglpos()

board:				# Loads user's value into Board on Stack
	lw $a0,0($sp)			# *board
	lw $t5,4($sp)			# row
	lw $t6,8($sp)			# col
	lw $t7,12($sp)			# value
	
	mov $s0,$a0
	sub $t3,$t5,5			# Row-5 -> $t3
	abs $t3,$t3				# abs($t3)
	mul $t3,$t3,6			# 6 rows
	add $t3,$t3,$t6			# $t3 contains user location
	mul $t3,$t3,4			# Makes value a multiple of 4
	add $s0,$s0,$t3			# change pointer to user location
	
	beq $t7,2,blah			# User cannot input 2,4,7,>7,<7
	beq $t7,4,blah
	beq $t7,6,blah
	bgt $t7,7,blah
	bltz $t7,blah
	
	
	sw $t7,0($s0)			# Loads User Value into user location on stack
	sub $s0,$s0,$t3			# Pointer is set back to normal
	li $t0,0				# Sets counter for columns
	li $t2,0				# Sets on/off for white/black char to: false
	li $a0,5				# prints 1st row number "5"
	syscall $print_int
	j iloop
blah:
	la $a0,bleh
	syscall $print_string
	la $a0,nl
	syscall $print_string
	li $t7,0
	sw $t7,0($s0)
	sub $s0,$s0,$t3
	li $t0,0
	li $t2,0
	li $a0,5				# prints 1st row number "5"
	syscall $print_int
	j iloop
iloop:				# Routine for Board begin
	li $t1,0				# Sets counter for squares
	j jtest
jloop:				#Routine for White Square / Stack Values
	
	lw $a0,0($s0)
	
	beq $t2,0,else			# Jumps to black sq routine when $t2 is false
	
	bne $a0,0,value			# Jumps if value at location in stack is not 0
	li $a0,32				# Loads white sq char into $a0
	syscall $print_char		# Prints white sq char
	addi $t1,$t1,1			# Increments counter for squares

	addi $s0,$s0,4			# Shifts stack pointer down by 1
	j jtest
value: 
	add $t1,$t1,1			# Increments counter for squares
	addi $s0,$s0,4			# Shifts stack pointer down by 1
	li $t3,1
	beq $t3,$a0,red
	li $t3,3
	beq $t3,$a0,white
	li $t3,5
	beq $t3,$a0,red
	li $t3,7
	beq $t3,$a0,white
	li $a0,0				#this overwrites whatever was prev there
	syscall $print_char
	j jtest
red:
	li $t3,5
	beq $t3,$a0,Rking
	li $a0,114
	syscall $print_char
	j jtest
white:
	li $t3,7
	beq $t3,$a0,Wking
	li $a0,119
	syscall $print_char
	j jtest
Wking:
	li $a0,87
	syscall $print_char
	j jtest
Rking:
	li $a0,82
	syscall $print_char
	j jtest
else:				# Routine for Black Square
	li $a0,219				# Loads black sq char into $a0
	syscall $print_char		# Prints black sq char
	addi $t1,$t1,1			# Increments counter for squares
	addi $s0,$s0,4			# Shifts stack pointer down by 1
jtest:				# Flips Square bit and tests for 6 columns
	
	not $t2,$t2				# ~($t2|0) Flips $t2 bits on/off
	andi $t2,$t2,1			# Saves least sig bit
	blt $t1,6,jloop			# Continues squares for 6 iterations
					# Inner loop end
	la $a0,nl			
	syscall $print_string	# Print a new line
	addi $t0,$t0,1			# Increment counter for columns
	j itest
itest:				# Tests for row
	beq $t0,1,one
	beq $t0,2,two
	beq $t0,3,thr
	beq $t0,4,four
	beq $t0,5,fve
	blt $t0,6,iloop			# Tests for number of rows
	la $a0,colnum
	syscall $print_string
	la $a0,nl
	syscall $print_string
	jr $ra
					# Prints Row Numbers
one:
	li $a0,4
	syscall $print_int		# prints 2nd row from the top of mtx
	j iloop
two:
	li $a0,3
	syscall $print_int		# prints 3rd row from the top of mtx
	j iloop
thr:
	li $a0,2
	syscall $print_int		# prints 4th row from the top of mtx
	j iloop
four:
	li $a0,1
	syscall $print_int		# prints 5th row from the top of mtx
	j iloop
fve:
	li $a0,0
	syscall $print_int		# prints 6th row from the top of mtx
	j iloop