# A simple example that uses bootlib.

.global main

.text
	main:
		# Set the timer frequency to 1000Hz
		addl 	$4, %esp

		# Register the handle for the timer IRQ (IRQ0) and enable it.
		pushl 	$0
		addl 	$8, %esp

		# Set up VGA stuff
		call 	color_text_mode
		call 	hide_cursor
		call 	vsync

		# Clear the screen
		movb 	$' ', %al
		movb	$0x0F, %ah
		#movb 	$0x4E, %ah
		movl 	$25*80, %ecx
		movl 	$vga_memory, %edi
		cld
		rep 	stosw

	loop:
		call	clear
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
		
		jmp	loop

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
