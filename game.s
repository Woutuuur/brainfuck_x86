# ***************************************************************************************
# * Program name: Pong									*
# * Description: Pong game implementation in assembly					*
# ***************************************************************************************
.bss
DISPLAY_BUFFER: .skip 2501	# 50x50 + 1

.text
# Initialize a null-terminated strings
bar:		.asciz "[XXXXXXXXXXXXXXXX]"
clearscreen:	.asciz "\033c"
stringformat:	.asciz "%s"
raw:		.asciz "/bin/stty -icanon min 0"
cooked:		.asciz	"/bin/stty cooked"

.data
WIDTH:		.quad 100
HEIGHT: 	.quad 50
X_END:		.quad 83
PLAYER1_X:	.quad 50
PLAYER2_X:	.quad 50
BALL_X:		.quad 10
BALL_Y:		.quad 15
XDIR:		.quad 1
YDIR:		.quad -1

.global main
# ***************************************************************************************
# * Subroutine: main									*
# * Description: Print information and call inout subroutine				*
# ***************************************************************************************
main:
	call	pong			# Call inout
	call	end
end:
	movq	$0, %rdi		# Load exit code
	call	exit			# Call exit

pong:
	movq	$raw, %rdi
	call	system

pong_loop:	
	movq	$0, %rax
	movq	$clearscreen, %rdi
	call	printf

	movq	$0, %r13

	call	read_input

	mov	$0, %r12
	append_border_top:
		movb	$'-', DISPLAY_BUFFER(%r13)
		inc	%r12
		incq	%r13
		cmpq	WIDTH, %r12
		jne	append_border_top

	movb	$'\n', DISPLAY_BUFFER(%r13)
	incq	%r13

	mov	$0, %r12
	cmpq	$0, PLAYER1_X
	je	indent_1_end
	indent_1:
		movb 	$' ', DISPLAY_BUFFER(%r13)
		inc	%r12	
		incq 	%r13
		cmpq	PLAYER1_X, %r12
		jne	indent_1
	indent_1_end:

	movb 	$0, DISPLAY_BUFFER(%r13)
	incq	%r13

	movq	$0, %rax
	movq	$bar, %rsi
	movq	$DISPLAY_BUFFER, %rdi
	call	strcat

	addq	$17, %r13

	mov	$0, %r12
	append_screen:
		movb	$'\n', DISPLAY_BUFFER(%r13)
		inc	%r12
		incq	%r13
		
		cmpq	BALL_Y, %r12
		jne	print_ball_end
		movq	$0, %r15
		print_ball:
			cmpq	BALL_X, %r15
			je	print_ball_2
			movb	$' ', DISPLAY_BUFFER(%r13)
			incq	%r13
			incq	%r15
			jmp	print_ball
		print_ball_2:
			movb 	$'X', DISPLAY_BUFFER(%r13)
			incq	%r13
		print_ball_end:

		cmp	HEIGHT, %r12
		jne	append_screen	

	mov	$0, %r12
	cmpq	$0, PLAYER2_X
	je	indent_2_end
	indent_2:
		movb 	$' ', DISPLAY_BUFFER(%r13)
		inc	%r12	
		incq 	%r13
		cmpq	PLAYER2_X, %r12
		jne	indent_2
	indent_2_end:

	movb 	$0, DISPLAY_BUFFER(%r13)
	incq	%r13

	movq	$0, %rax
	movq	$bar, %rsi
	movq	$DISPLAY_BUFFER, %rdi
	call	strcat

	addq	$17, %r13

	movb	$'\n', DISPLAY_BUFFER(%r13)
	incq	%r13
	
	mov	$0, %r12
	append_border_bot:
		movb	$'-', DISPLAY_BUFFER(%r13)
		inc	%r12
		incq	%r13
		cmp	WIDTH, %r12
		jne	append_border_bot
	
	movb	$'\n', DISPLAY_BUFFER(%r13)
	incq	%r13
	movb	$0, DISPLAY_BUFFER(%r13)

	movq	$0, %rax
	movq	$DISPLAY_BUFFER, %rsi
	movq	$stringformat, %rdi
	call	printf

	movq	$300000000, %r12
	ugly_delay:
		decq	%r12
		cmpq	$0, %r12
		jg	ugly_delay

	movq	XDIR, %rax
	addq	%rax, BALL_X

	movq	YDIR, %rax
	addq	%rax, BALL_Y
	
	movq	BALL_X, %rax
	subq	$7, %rax
	
	set_limit1:
	cmpq	$0, %rax
	jg	set_limit2
	movq	$0, %rax
	set_limit2:
	movq	WIDTH, %rdx
	subq	$17, %rdx
	cmpq	%rdx, %rax
	jl	set_limit_end
	movq	%rdx, %rax
	set_limit_end:
	
	movq	%rax, PLAYER2_X
	movq	%rax, PLAYER1_X
	
	cmpq	$0, BALL_X
	jne	x_inv_end
	negq	XDIR
	x_inv_end:

	movq	WIDTH, %rax	
	cmpq	%rax, BALL_X
	jne	x_inv_end2
	negq	XDIR
	x_inv_end2:
		
	cmpq	$1, BALL_Y
	jne	y_inv_end
	negq	YDIR
	y_inv_end:

	movq	HEIGHT, %rax	
	subq	$1, %rax
	cmpq	%rax, BALL_Y
	jne	y_inv_end2
	negq	YDIR
	y_inv_end2:

	jmp	pong_loop

read_input:
	push	%rbp
	movq	%rsp, %rbp

	subq	$8, %rsp

	movq	$0, %rax
	movq	$1, %rdx
	leaq	-8(%rbp), %rsi 
	movq	$0, %rdi
	call	read

	cmpq	$0, %rax
	je	read_input_end

	popq	%rax

	cmpb	$'a', %al
	je	player1_left
	cmpb	$'d', %al
	je	player1_right
#	cmpb	$'j', %al
#	je	player2_left
#	cmpb	$'l', %al
#	je	player2_right
	cmpb	$'q', %al
	je	end

	jmp	read_input_end	

	movq	X_END, %rax

	player1_left:
		cmpq	$0, PLAYER1_X
		je	read_input_end
		decq	PLAYER1_X
		jmp	read_input_end
	player1_right:
		cmpq	%rax, PLAYER1_X
		je	read_input_end
		incq	PLAYER1_X
		jmp	read_input_end

read_input_end:
	movq	%rbp, %rsp
	popq	%rbp
	ret	

pong_end:
	movq	$cooked, %rdi
	call	system
	ret	
