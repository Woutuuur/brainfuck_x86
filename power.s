# ***************************************************************************************
# * Program name: power									*
# * Description: Calculate power using a base and exponent				*
# ***************************************************************************************
.text
# Initialize a null-terminated strings
info:	 	.asciz "Wouter van den Broeke\nLab group 148\nAssignment 3: power\n"
askforbase:	.asciz "Base:     "
askforexp:	.asciz "Exponent: "
inputnum:	.asciz "%ld"
resultstr:	.asciz "Output:   %ld\n"

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
# * Description: Read user input and call 'pow' subroutine				*
# ***************************************************************************************
inout:
	pushq	%rbp			# Pushes the base pointer to the stack
	movq	%rsp, %rbp		# Moves the base pointer on top of the stack	
	
	subq	$24, %rsp		# Need 16 bytes, but sub 8 more to
					# keep stack 16 byte aligned

	# Ask user for base
	movq	$askforbase, %rdi	# First argument: the format str
	movq	$0, %rax		# Clear rax
	call	printf			# Call printf

	# Read user input
	leaq	-8(%rbp), %rsi		# Second argument: address of stack variable
	movq	$inputnum, %rdi		# First argument: the format str
	movq	$0, %rax		# Clear %rax
	call 	scanf			# Call scanf

	# Ask user for exponent
	movq	$askforexp, %rdi	# First argument: the format str
	movq	$0, %rax		# Clear rax
	call	printf			# Call printf

	# Read user input
	leaq	-16(%rbp), %rsi		# Second argument: address of stack variable
	movq	$inputnum, %rdi		# First argument: the format str
	movq	$0, %rax		# Clear %rax
	call 	scanf			# Call scanf

	movq	-16(%rbp), %rsi		# Second argument: 'exponent'
	movq	-8(%rbp), %rdi		# First argument: 'base'	
	call	pow			# Call pow subroutine

	addq	$24, %rsp		# Clean the stack
	popq	%rbp			# Restores base pointer
	ret				# Return from subroutine

# ***************************************************************************************
# * Subroutine: pow									*
# * Description: Raises first argument (base) to the power of the second argument (exp) *
# ***************************************************************************************	
pow:		
	movq	$1, %rcx		# Set 'total' to 1
	cmpq	$0, %rsi		# If 'exp' is 0
	je	powEnd			# Return 1
loop:
	movq	%rdi, %rax		# Copy 'base' to rax for multiplication
	mulq	%rcx			# Multiplies rcx by rax and stores in rax
	movq	%rax, %rcx		# Write back the result stored in rax to 'total'
	decq	%rsi			# Subtract 1 from 'exp'
	cmpq	$0, %rsi		# Compare 'exp' to 0
	jg	loop			# If 'exp' is greater than 0, repeat
powEnd:
	movq	%rcx, %rsi		# Second argument: 'total'
	movq	$resultstr, %rdi	# First argument: the format str
	movq	$0, %rax		# Clear rax
	call	printf			# Call printf
	ret
