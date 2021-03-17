.global main, time, ballx, bally, xdir, ydir, p1y, p2y

.text
main:
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

	# Reset score
	movb	$'0', vga_memory + 72
	movb	$' ', vga_memory + 74
	movb	$' ', vga_memory + 76
	movb	$'-', vga_memory + 78
	movb	$' ', vga_memory + 80
	movb	$' ', vga_memory + 82
	movb	$'0', vga_memory + 84
	
	call	render

loop:
	call	read_inputs

	movl	delay_time, %ebx
	cmpl	%ebx, round_delay
	jg		loop_end

	movl	$0, round_delay

	movl	xdir, %eax
	addl	%eax, ballx
	movl	ydir, %eax
	addl	%eax, bally

	cmpl	$1, bally
	jle		invert_bally
	cmpl	$24, bally
	jge		invert_bally
	bally_invert_end:

	cmpl	$2, ballx
	jle		check_player1_collision
	cmpl	$156, ballx
	jge		check_player2_collision
	ballx_invert_end:

	cmpl	$140, ballx
	jle		ai_end
	cmpl	$2, xdir
	jne		ai_end

	movl	bally, %eax
	subl	$3, %eax
	cmpl	%eax, p2y
	jg		ai_move_down
	jmp		ai_move_up
	ai_end:		

	cmpl	$9, p2y
	je		ai_end2
	cmpl	$9, p2y
	jg		ai_move_down

	ai_move_up:
	incl	p2y
	jmp		ai_end2
	ai_move_down:
	decl	p2y
	jmp		ai_end2
	ai_end2:

	loop_end:
	call	clear
	call	render
	movl	time, %ebx
	addl	%ebx, delay_time
	movl	$0, time
	jmp		loop

check_player1_collision:
	movl	bally, %eax
	movl	p1y, %ebx

	cmpl	p1y, %eax
	jl		player2_score
	addl	$7, %ebx
	cmpl	%ebx, %eax
	jg		player2_score

	jmp		collsion_check_end

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

player1_score:
	movl 	$vga_memory, %eax
	addl	$72, %eax
	incl	(%eax)
	call	reset
	jmp		collsion_check_end

player2_score:
	movl 	$vga_memory, %eax
	addl	$84, %eax
	incl	(%eax)
	call	reset
	jmp		collsion_check_end

reset:
	movl	$80, ballx
	movl	$12, bally
	movl	$2000, round_delay
	movl	$0, delay_time
	movl	$9, p1y
	ret

invert_ballx:
	negl	xdir
	ret

invert_bally:
	negl	ydir
	jmp		bally_invert_end

read_inputs:
	movl	main_delay, %ebx
	read_loop:
		call 	paddle_inputs
		cmpl	%ebx, time
		jl		read_loop
	ret

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

paddle_inputs:
	pushl	%ebp                        # Prologue
	movl	%esp, %ebp

	pushl	$p1y
	cmpb    $1, curr_key              # If current key is the UP key,
	je      move_paddle_up              # move the paddle up
	cmpb    $2, curr_key              # If current key is the DOWN key,
	je      move_paddle_down            # move the paddle down

	movl	%ebp, %esp					# Epilogue
	popl	%ebp                        
	ret

move_paddle_down:
	popl 	%eax

	cmpl    $18, (%eax)                 # If the position is >= 18,
	jge     move_paddle_done            # Exit paddle input function

	incl    (%eax)

	jmp     move_paddle_done

move_paddle_up:
	popl 	%eax

	cmpl    $1, (%eax)                  # If the position is <= 1,
	jle     move_paddle_done            # Exit paddle input function

	decl    (%eax)

	jmp     move_paddle_done

move_paddle_done:
	movb    $0, curr_key                 # Set the pressed key back to none.

	movl	%ebp, %esp
	popl	%ebp
	ret

.data
	time: 			.long 0
	delay_time:		.long 0
	p1y:			.long 9
	p2y:			.long 9
	ballx:			.long 80
	bally:			.long 9
	xdir:			.long -2
	ydir:			.long 1
	prev_dir: 		.long 0
	round_delay:	.long 2000
	main_delay:		.long 50
