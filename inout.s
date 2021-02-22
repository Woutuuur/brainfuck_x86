# ***************************************************************************************
# * Program name: inout									*
# * Description: Simple subroutine and user input					*
# ***************************************************************************************
.text
# Initialize a null-terminated strings
info:	 	.asciz "Wouter van den Broeke\nLab group 148\nAssignment 2: inout\n"
formatstr:	.asciz "%ld"
inputstr:	.asciz "Input:  "
resultstr:	.asciz "Output: %ld\n"


.global main
# ***************************************************************************************
# * Subroutine: main									*
# * Description: Print information and call inout subroutine				*
# ***************************************************************************************
main:
	movq	$info, %rdi		# Load address of the string	
	movq	$0, %rax		# No vector registers in use for printf
	call	printf			# Call printf
	call	inout			# Call inout
end:
	movq	$1, %rdi		# Load exit code
	call	exit			# Call exit

# ***************************************************************************************
# * Subroutine: inout									*
# * Description: Increment input by one and print result to the terminal		*
# ***************************************************************************************
inout:
	pushq	%rbp			# Pushes the base pointer to the stack
	movq	%rsp, %rbp		# Moves the base pointer on top of the stack	

	movq	$inputstr, %rdi		# First argument: the format str
	movq	$0, %rax		# Clear rax
	call	printf			# Call printf

	subq	$8, %rsp		# Reserve stack space for variable	
	leaq	-8(%rbp), %rsi		# Second argument: address of stack variable
	movq	$formatstr, %rdi	# First argument: the format str
	movq	$0, %rax		# Clear %rax
	call 	scanf			# Call scanf

	movq	-8(%rbp), %rbx		# Load the number into a register	
	inc	%rbx			# Increase the number by 1
	
	movq	%rbx, %rsi		# Second argument: the (incremented) number
	movq	$resultstr, %rdi	# First argument: the format str
	movq	$0, %rax		# Clear rax
	call	printf			# Call printf

	addq	$8, %rsp		# Clean the stack
	popq	%rbp			# Restores base pointer
	ret				# Return from subroutine
