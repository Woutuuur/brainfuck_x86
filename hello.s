# *******************************************************************************
# * Program name: hello								*
# * Description: Prints information to the terminal				*
# *******************************************************************************
.data
# Initialize a null-terminated string
mystring: .asciz "Wouter van den Broeke\nLab group 148\nAssignment 1: hello\n"

.global main
# *******************************************************************************
# * Subroutine: main								*
# * Description: Print string 'mystring'					*
# *******************************************************************************
main:
	movq	$0, %rax		# Clear %rax
	movq	$mystring, %rdi		# Load address of the string
	call	printf			# Call printf
end:
	mov	$0, %rdi		# Load exit code
	call	exit			# Call exit
