# ***************************************************************************************
# * Program name: printf								*
# * Description: Simplified printf subroutine						*
# ***************************************************************************************
.text
# Initialize null-terminated strings
teststr:	.asciz "My name is %s. I think I'll get a %u for my exam. What does %r do? And %%? Btw here's negative numbers: %d\n"
piet:		.asciz "Piet"
test:		.asciz "Test!\n"
percent:	.asciz "%"
dash:		.asciz "-"

.global main
# ***************************************************************************************
# * Subroutine: main									*
# * Description: Program entry point							*
# ***************************************************************************************
main:
	movq	$-12493, %rcx		# Fourth argument: 'neg'
	movq	$52345235, %rdx		# Third argument: 'grade'
	movq	$piet, %rsi		# Second argument: 'piet'
	movq	$teststr, %rdi		# First argument: the format str
	call	my_printf
end:
	movq	$0, %rdi		# Load exit code
	call	exit			# Call exit

# ***************************************************************************************
# * Subroutine: my_printf								*
# * Description: Simplified printf subroutine						*
# ***************************************************************************************
my_printf:
	pushq	%rbp			# Pushes the base pointer to the stack
	movq	%rsp, %rbp		# Moves the base pointer on top of the stack		

	# Push all arguments to the stack
	pushq	%r9
	pushq	%r8
	pushq	%rcx
	pushq	%rdx
	pushq	%rsi

	movq	%rdi, %r15		# Copy format str to r15

main_loop:	
	cmpb	$0, (%r15)		# Compare current char to "\0"
	je	printf_end		# If equal, go to printf_end
					
	cmpb	$37, (%r15)		# Else if the char is a '%'
	je	selector		# If equal, go to selector	

	# Print current char
	movq	$1, %rax		# Which syscall: sys_write 
	movq	$1, %rdx		# Third argument: length (1 char = 1 byte)
	movq	%r15, %rsi		# Second argument: what to write
	movq	$1, %rdi		# Where to write: STDOUT (1)	
	syscall
	
	incq	%r15
	jmp	main_loop

selector:
	incq	%r15			# Look at the char after the '%'
	
	cmpb	$115, (%r15)		# Compare char to 's'
	je	string			# If equal, go to string

	cmpb	$117, (%r15)		# Compare char to 'u'
	je	unsigned_int		# If equal, go to unsigned_int

	cmpb	$100, (%r15)		# Compare char to 'd'
	je	signed_int		# If equal, go to signed_int

	# Not a valid specifier (or %%), so we want to print the %	
	movq	$percent, %rdi		# First argument: '%'
	call	print_string		# Print the %
	jmp	main_loop		# Return to the main loop
	
string:
	popq	%rdi			# Load argument from the stack to rdi
	call	print_string		# Call print_string with this argument
	incq	%r15			# Move to next char
	jmp	main_loop		# Return to main loop
	
unsigned_int:	
	popq	%rdi			# Load argument 'num' from the stack to rdi
	call	print_num		# Print the number
	incq	%r15			# Move to next char
	jmp	main_loop		# Return to main loop

signed_int:
	popq	%r12			# Load argument 'num' from the stack to rdi
	cmpq	$0, %r12		# Compare 'num' to 0			
	jl	negative_int		# If negative, go to negative_int

positive_int:
	movq	%r12, %rdi		# Move r12 to rdi
	call	print_num		# Print the number

	incq	%r15			# Move to next char
	jmp	main_loop		# Return to the main loop

negative_int:
	movq	$dash, %rdi		# Move '-' to rdi
	call	print_string		# Print it
	
	neg	%r12			# Negate r12

	jmp	positive_int		# Jump to positive_int

printf_end:
	movq	%rbp, %rsp		# Clean stack
	popq	%rbp			# Restores base pointer
	ret				# Return from subroutine

# ***************************************************************************************
# * Subroutine: print_num								*
# * Description: Print a signed number to the terminal					*
# ***************************************************************************************
print_num:
	pushq	%rbp			# Push base pointer to stack
	movq	%rsp, %rbp		# Move base pointer on top of stack
	
	movq	%rdi, %r12		# Load 'num' to r12
	pushq	$128			# Push 128 to stack (for future reference)

print_num_loop:
	movq	$0, %rdx		# Clear rdx
	movq	%r12, %rax		# Move 'num' to rax register
	movq	$10, %rcx		# Move 10 to rcx
	divq	%rcx			# Divide 'num' by 10

	movq	%rax, %r12		# Move result of 'num' / 10 to r12
	addq	$48, %rdx		# Add 48 to get correct ASCII value for a digit
	
	pushq	%rdx			# Push this value to the stack
	
	cmpq	$0, %r12		# Compare 'num' to 0
	je	print_stack		# If equal, end loop (go to unsigned_int_end)	

	jmp	print_num_loop		# Jump to start of loop		

print_stack:	
	# If rsp is 128, we hit our previously set breakpoint (the end is reached)
	cmpq	$128, (%rsp)		# Compare value at rsp to 128
	je	print_num_end		# Go to print_num_end
	
	# Else, print current digit
	movq	$1, %rax		# Which syscall: sys_write 
	movq	$1, %rdx		# Third argument: length (1 char = 1 byte)	
	movq	%rsp, %rsi		# Second argument: address of current digit on stack
	movq	$1, %rdi		# First argument: where to write: STDOUT (1)	
	syscall
	
	addq	$8, %rsp		# Move to next digit on the stack

	jmp	print_stack		# Go to beginning of loop
	
print_num_end:
	addq	$8, %rsp		# Clean last variable (128) off stack
	popq	%rbp			# Restore base pointer
	ret				# Return from subroutine

# ***************************************************************************************
# * Subroutine: print_string								*
# * Description: Print string to the terminal						*
# ***************************************************************************************
print_string:
	movq	%rdi, %rbx		# Load argument into register rbx	

print_loop:
	cmpb	$0, (%rbx)		# Compare current char to "\0"
	je	print_end		# If equal, go to print_end
	
	# sys_write(1, &c, 1)
	movq	$1, %rax		# Which syscall: sys_write 
	movq	$1, %rdx		# Third argument: length (1 char = 1 byte)
	movq	%rbx, %rsi		# Second argument: what to write
	movq	$1, %rdi		# Where to write: STDOUT (1)	
	syscall

	incq	%rbx			# Consider next char
	jmp	print_loop		# Jump to start of loop

print_end:
	ret				# Return from subroutine
