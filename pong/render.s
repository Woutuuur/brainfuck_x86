.global render

.text
render:	
	# ---- Render the ball ----
	# Calculate memory offset for the ball
	movl	$160, %eax
	movl	bally, %ebx
	mull	%ebx
	addl	ballx, %eax
	movl	%eax, %ebx
	# Add ■ in the vga memory (renders the ball)
	movl 	$vga_memory, %eax
	addl	%ebx, %eax
	movb 	$254, (%eax)

	# ---- Render the player's paddle ----
	# Calculate memory offset for the paddle
	movl	$160, %eax
	movl	p1y, %ebx
	mull	%ebx
	movl	%eax, %ebx
	# Add multiple █'s vertically (renders the paddle)
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

	# ---- Render the AI's paddle ----
	# Calculate memory offset for the paddle
	movl	$160, %eax
	movl	p2y, %ebx
	mull	%ebx
	addl	$158, %eax
	movl	%eax, %ebx
	# Add multiple █'s vertically (renders the paddle)
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
