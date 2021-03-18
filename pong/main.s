.global main, time, ballx, bally, xdir, ydir, p1y, p2y

.text
main:
	# Might have to adjust the timer frequency (1000hz) based on your machine
	pushl	$1000
	call	set_timer_frequency
	addl	$4, %esp

	call	set_handlers

	# Set up VGA stuff
	call 	color_text_mode
	call 	hide_cursor

	# Clear top bar
	movb    $' ', %al 
	movb    $0x70, %ah 
	movl    $80, %ecx
	movl    $vga_memory, %edi
	cld 
	rep     stosw

	# Clear the screen
	call	clear
	# Initial scores
	call	reset_score
	# Initial render
	call	render

# Main game loop
loop:
	call	delay
	call 	read_inputs

	# Don't do any game logic for 'round_delay'ms
	# after a round has started
	movl	delay_time, %ebx
	cmpl	%ebx, round_delay
	jg		loop_end
	movl	$0, round_delay

	# Move the ball
	movl	xdir, %eax
	addl	%eax, ballx
	movl	ydir, %eax
	addl	%eax, bally

	# Bounce the ball on the roof and floor
	cmpl	$1, bally
	jle		invert_bally
	cmpl	$24, bally
	jge		invert_bally
	bally_invert_end:

	# Check if the ball is blocked by a paddle
	cmpl	$2, ballx
	jle		check_player1_collision
	cmpl	$156, ballx
	jge		check_player2_collision
	ballx_invert_end:

	# After the scores are added up,
	# see if a player has won (9 points)
	call	check_win

	# The AI will respond to the ball movement only
	# when the ball has reached x > 140
	cmpl	$140, ballx
	jle		ai_end
	cmpl	$2, xdir
	jne		ai_end

	# AI movement towards the ball
	movl	bally, %eax
	subl	$3, %eax
	cmpl	%eax, p2y
	jg		ai_move_down
	jmp		ai_move_up
	ai_end:		

	# If the AI should not respond to ball movement
	# move the AI back to the center
	cmpl	$9, p2y
	je		ai_end2
	cmpl	$9, p2y
	jg		ai_move_down

	# AI movement
	ai_move_up:
	incl	p2y
	jmp		ai_end2
	ai_move_down:
	decl	p2y
	jmp		ai_end2
	ai_end2:

	loop_end:
	# Clear the vga memory
	call	clear
	# Render the game onto vga memory
	call	render

	# Reset the 'time', but keep 'delay_time' going
	# because 'delay_time' is larger than 'time'
	movl	time, %ebx
	addl	%ebx, delay_time
	movl	$0, time
	jmp		loop

reset_score:
	movb	$'0', vga_memory + 72
	movb	$' ', vga_memory + 74
	movb	$' ', vga_memory + 76
	movb	$'-', vga_memory + 78
	movb	$' ', vga_memory + 80
	movb	$' ', vga_memory + 82
	movb	$'0', vga_memory + 84
	ret

check_win:
	movl 	$vga_memory, %eax
	addl	$72, %eax
	cmpb	$'9', (%eax)
	je 		player1_win
	movl 	$vga_memory, %eax
	addl	$84, %eax
	cmpb	$'9', (%eax)
	je		player2_win

	ret

player1_win:
	call	set_game_over_text
	jmp 	game_over

player2_win:
	call	set_game_over_text
	movl	$vga_memory, %eax
	addl	$1996, %eax
	movb	$'l', (%eax)
	addl	$2, %eax
	movb	$'o', (%eax)
	addl	$2, %eax
	movb	$'s', (%eax)
	addl	$2, %eax
	movb	$'t', (%eax)
	jmp		game_over

# Display game over screen until SPACE is pressed
game_over:
	game_over_loop:
		cmpb	$4, curr_key
		jne 	game_over_loop
		jmp		restart

# Restart the game completely
restart:
	call	clear
	call	reset_score
	call	reset
	movl	$2000, round_delay
	movl	$0, delay_time
	movl	$0, time
	jmp		loop

# Check if the player blocked the ball with his paddle
check_player1_collision:
	movl	bally, %eax
	movl	p1y, %ebx

	cmpl	p1y, %eax
	jl		player2_score
	addl	$7, %ebx
	cmpl	%ebx, %eax
	jg		player2_score

	jmp		collsion_check_end

# Check if the AI blocked the ball with his paddle
check_player2_collision:
	movl	bally, %eax
	movl	p2y, %ebx

	cmpl	p2y, %eax
	jl		player1_score
	addl	$7, %ebx
	cmpl	%ebx, %eax
	jg		player1_score

	jmp		collsion_check_end

collsion_check_end:
	call 	invert_ballx
	jmp		ballx_invert_end

# Increment the player's score
# and reset the board
player1_score:
	movl 	$vga_memory, %eax
	addl	$72, %eax
	incl	(%eax)
	call	reset
	jmp		collsion_check_end

# Increment the AI's score
# and reset the board
player2_score:
	movl 	$vga_memory, %eax
	addl	$84, %eax
	incl	(%eax)
	call	reset
	jmp		collsion_check_end

# Reset the board and prepare for
# the next round
reset:
	movl	$80, ballx
	movl	$12, bally
	movl	$2000, round_delay
	movl	$0, delay_time
	movl	$9, p1y
	ret

# Bounce the ball off the paddles
invert_ballx:
	negl	xdir
	ret

# Bounce the ball off the roof and floor
invert_bally:
	negl	ydir
	jmp		bally_invert_end

# Repeat for a duration 'main_delay' as a delay
# mainly to avoid flickering in the display, which happens
# when the screen is being cleared before the game
# has finished rendering the current VGA memory
delay:
	movl	main_delay, %ebx
	delay_loop:
		cmpl	%ebx, time
		jl		delay_loop
	ret

# Clear the vga memory (except the top bar)
clear:
	pushl   %eax
	pushl   %ecx

	movb    $' ', %al 
	movb    $0x0F, %ah 
	movl    $25*80, %ecx
	movl    $vga_memory, %edi
	addl	$160, %edi
	cld 
	rep     stosw

	popl	%ecx
	popl	%eax
	ret

# Read inputs for the player's paddle (and pause)
read_inputs:
	pushl	%ebp
	movl	%esp, %ebp

	# UP: 	move paddle up
	# DOWN: move paddle down
	# ESC:	pause game
	pushl	$p1y
	cmpb    $1, curr_key              	# If the current key is the UP key,
	je      move_paddle_up            	# move the paddle up
	cmpb    $2, curr_key              	# If the current key is the DOWN key,
	je      move_paddle_down          	# move the paddle down
	cmpb    $3, curr_key				# If the current key is the ESC key,
	je      paused						# pause the game

	jmp		read_input_done                     
	ret

# Pause the game
paused:
	popl	%eax
	movl	$0, curr_key
	call	set_paused_text
	# Repeat until ESC is pressed again
	paused_loop:
		cmpb	$3, curr_key
		jne		paused_loop
	jmp		read_input_done

# Move the paddle down, but make sure it's not out of bounds
move_paddle_down:
	popl 	%eax

	cmpl    $18, (%eax)
	jge     read_input_done 
	incl    (%eax)
	jmp     read_input_done

# Move the paddle up, but make sure it's not out of bounds
move_paddle_up:
	popl 	%eax
	
	cmpl    $1, (%eax)
	jle     read_input_done
	decl    (%eax)
	jmp     read_input_done

read_input_done:
	movb    $0, curr_key

	movl	%ebp, %esp
	popl	%ebp
	ret

# Clear the screen and display the pause text
set_paused_text:
	call	clear
	movl	$vga_memory, %eax
	addl	$1988, %eax
	movb	$'G', (%eax)
	addl	$2, %eax
	movb	$'a', (%eax)
	addl	$2, %eax
	movb	$'m', (%eax)
	addl	$2, %eax
	movb	$'e', (%eax)
	addl	$2, %eax
	movb	$' ', (%eax)
	addl	$2, %eax
	movb	$'p', (%eax)
	addl	$2, %eax
	movb	$'a', (%eax)
	addl	$2, %eax
	movb	$'u', (%eax)
	addl	$2, %eax
	movb	$'s', (%eax)
	addl	$2, %eax
	movb	$'e', (%eax)
	addl	$2, %eax
	movb	$'d', (%eax)
	addl	$130, %eax
	movb	$'P', (%eax)
	addl	$2, %eax
	movb	$'r', (%eax)
	addl	$2, %eax
	movb	$'e', (%eax)
	addl	$2, %eax
	movb	$'s', (%eax)
	addl	$2, %eax
	movb	$'s', (%eax)
	addl	$2, %eax
	movb	$' ', (%eax)
	addl	$2, %eax
	movb	$'E', (%eax)
	addl	$2, %eax
	movb	$'S', (%eax)
	addl	$2, %eax
	movb	$'C', (%eax)
	addl	$2, %eax
	movb	$' ', (%eax)
	addl	$2, %eax
	movb	$'t', (%eax)
	addl	$2, %eax
	movb	$'o', (%eax)
	addl	$2, %eax
	movb	$' ', (%eax)
	addl	$2, %eax
	movb	$'c', (%eax)
	addl	$2, %eax
	movb	$'o', (%eax)
	addl	$2, %eax
	movb	$'n', (%eax)
	addl	$2, %eax
	movb	$'t', (%eax)
	addl	$2, %eax
	movb	$'i', (%eax)
	addl	$2, %eax
	movb	$'n', (%eax)
	addl	$2, %eax
	movb	$'u', (%eax)
	addl	$2, %eax
	movb	$'e', (%eax)
	ret

# Clear the screen and display the game over text
set_game_over_text:
	call	clear
	movl	$vga_memory, %eax
	addl	$1988, %eax
	movb	$'Y', (%eax)
	addl	$2, %eax
	movb	$'o', (%eax)
	addl	$2, %eax
	movb	$'u', (%eax)
	addl	$2, %eax
	movb	$' ', (%eax)
	addl	$2, %eax
	movb	$'w', (%eax)
	addl	$2, %eax
	movb	$'o', (%eax)
	addl	$2, %eax
	movb	$'n', (%eax)
	addl	$2, %eax
	movb	$'!', (%eax)
	addl	$132, %eax
	movb	$'P', (%eax)
	addl	$2, %eax
	movb	$'r', (%eax)
	addl	$2, %eax
	movb	$'e', (%eax)
	addl	$2, %eax
	movb	$'s', (%eax)
	addl	$2, %eax
	movb	$'s', (%eax)
	addl	$2, %eax
	movb	$' ', (%eax)
	addl	$2, %eax
	movb	$'S', (%eax)
	addl	$2, %eax
	movb	$'P', (%eax)
	addl	$2, %eax
	movb	$'A', (%eax)
	addl	$2, %eax
	movb	$'C', (%eax)
	addl	$2, %eax
	movb	$'E', (%eax)
	addl	$2, %eax
	movb	$' ', (%eax)
	addl	$2, %eax
	movb	$'t', (%eax)
	addl	$2, %eax
	movb	$'o', (%eax)
	addl	$2, %eax
	movb	$' ', (%eax)
	addl	$2, %eax
	movb	$'r', (%eax)
	addl	$2, %eax
	movb	$'e', (%eax)
	addl	$2, %eax
	movb	$'s', (%eax)
	addl	$2, %eax
	movb	$'t', (%eax)
	addl	$2, %eax
	movb	$'a', (%eax)
	addl	$2, %eax
	movb	$'r', (%eax)
	addl	$2, %eax
	movb	$'t', (%eax)
	ret

.data
	time: 			.long  0
	delay_time:		.long  0
	p1y:			.long  9
	p2y:			.long  9
	ballx:			.long  80
	bally:			.long  9
	xdir:			.long -2
	ydir:			.long  1
	prev_dir: 		.long  0
	round_delay:	.long  2000
	main_delay:		.long  50
