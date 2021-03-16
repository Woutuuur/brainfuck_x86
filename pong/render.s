.global render

.text
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
	