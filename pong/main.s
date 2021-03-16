# A simple example that uses bootlib.

.global main, time

.text
main:
	pushl	$1000
	call	set_timer_frequency
	addl	$4, %esp

	call	set_handlers

	# Set up VGA stuff
	call 	color_text_mode
	call 	hide_cursor

	call	clear

loop:
	movl	$100, %ebx
	call	delay

	incl	ballx
	incl	ballx

	cmpl	$0, ballx

	call	clear
	call	render

	movl	$0, time
	jmp		loop

invert_ballx:

	ret

invert_bally:

	ret

delay:
	cmpl	%ebx, time
	jl		delay 
	ret

render:	
	# Render the ball
	movl	$160, %eax
	movl	bally, %ebx
	mull	%ebx
	addl	ballx, %eax
	movl	%eax, %ebx		

	movl 	$vga_memory, %eax
	addl	%ebx, %eax
	movb 	$254, (%eax)

	# Render player 1
	movl	$160, %eax
	movl	p1y, %ebx
	mull	%ebx
	movl	%eax, %ebx

	movl 	$vga_memory, %eax
	addl 	%ebx, %eax
	movb 	$219, (%eax)
	addl	$160, %eax
	movb 	$219, (%eax)
	addl	$160, %eax
	movb 	$219, (%eax)
	addl	$160, %eax
	movb 	$219, (%eax)
	addl	$160, %eax
	movb 	$219, (%eax)
	addl	$160, %eax
	movb 	$219, (%eax)
	addl	$160, %eax
	movb 	$219, (%eax)
	addl	$160, %eax

	# Render player 2
	movl	$160, %eax
	movl	p2y, %ebx
	mull	%ebx
	addl	$158, %eax
	movl	%eax, %ebx

	movl 	$vga_memory, %eax
	addl 	%ebx, %eax
	movb 	$219, (%eax)
	addl	$160, %eax
	movb 	$219, (%eax)
	addl	$160, %eax
	movb 	$219, (%eax)
	addl	$160, %eax
	movb 	$219, (%eax)
	addl	$160, %eax
	movb 	$219, (%eax)
	addl	$160, %eax
	movb 	$219, (%eax)
	addl	$160, %eax
	movb 	$219, (%eax)
	addl	$160, %eax

	ret
			
clear:
	pushl   %eax
	pushl   %ecx

	movb    $' ', %al 
	movb    $0x0F, %ah 
	movl    $25*80, %ecx
	movl    $vga_memory, %edi
	cld 
	rep     stosw

	popl	%ecx
	popl	%eax
	ret

.data
	time: 	.long 0
	p1y:	.long 12
	p2y:	.long 12
	ballx:	.long 30
	bally:	.long 15
