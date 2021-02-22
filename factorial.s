# ***************************************************************************************
# * Program name: factorial								*
# * Description: Recursively calculates factorial					*
# ***************************************************************************************
.text
# Initialize a null-terminated strings
info:	 	.asciz "Wouter van den Broeke\nLab group 148\nAssignment 4: power\n"
askforinput:	.asciz "Input:  "
inputnum:	.asciz "%ld"
resultstr:	.asciz "Output: %ld\n"

.global main
# ***************************************************************************************
# * Subroutine: main									*
# * Description: Program entry point							*
# ***************************************************************************************
main:
	movq	$info, %rdi
	movq	$0, %rax
	call	printf
	call	inout
end:
	movq	$0, %rdi		# Load exit code
	call	exit			# Call exit

# ***************************************************************************************
# * Subroutine: inout									*
# * Description: Read user input and call 'factorial' subroutine			*
# ***************************************************************************************
inout:
	pushq	%rbp			# Pushes the base pointer to the stack
	movq	%rsp, %rbp		# Moves the base pointer on top of the stack	
	
	subq	$8, %rsp		# Reserve stack spcae for variable

	# Ask user for base
	movq	$askforinput, %rdi	# First argument: the format str
	movq	$0, %rax		# Clear rax
	call	printf			# Call printf

	# Read user input
	leaq	-8(%rbp), %rsi		# Second argument: address of stack variable
	movq	$inputnum, %rdi		# First argument: the format str
	movq	$0, %rax		# Clear rax
	call 	scanf			# Call scanf

	movq	-8(%rbp), %rdi		# First argument: 'n'
	movq	$0, %rax		# Clear rax
	call	factorial
	
	# Ask user for base
	movq	%rax, %rsi		# Second argument: 'n!'
	movq	$resultstr, %rdi	# First argument: the format str
	movq	$0, %rax		# Clear rax
	call	printf			# Call printf

	addq	$8, %rsp
	popq	%rbp
	ret				# Return from subroutine

# ***************************************************************************************
# * Subroutine: factorial								*
# * Description: Returns n!								*
# ***************************************************************************************
factorial:
	cmpq	$0, %rdi		# If 'n' is 0
	je	base_case		# return 1
	cmpq	$1, %rdi		# If 'n' is 1, 
	je	base_case		# return 1
	
	pushq	%rbp			# Pushes base pointer to the stack
	movq	%rsp, %rbp		# Moves base pointer on top of stack
	pushq	%rdi			# Push 'n' to the stack
	decq	%rdi			# Decrease 'n' by 1
	call	factorial		# Call f(n-1), which returns to rax
	popq	%rbx			# Pop 'n' off the stack to rbx
	mulq	%rbx			# Multiply f(n-1) (rax) by 'n' (rbx)

	popq	%rbp			# Restores base pointer
	ret				# Return n * f(n-1)

base_case:
	movq	$1, %rax
	ret
