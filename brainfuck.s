# ***************************************************************************************
# * Program name: brainfuck								*
# * Description: Interpreter for the brainfuck language					*
# ***************************************************************************************
.bss
FILEBUFF: 	.skip 163840
MEMORY:		.skip 30000

.text
# Initialize a null-terminated strings
invalidargc: 	.asciz "Please provide a filename\n"
invalidfile:	.asciz "Error reading file\n"
filemode:	.asciz "r"
charformat:	.asciz "%b"
newline:	.asciz "\n"

.global main
# ***************************************************************************************
# * Subroutine: main									*
# * Description: Program entry point							*
# ***************************************************************************************
main:
	# Check if user provided a command-line argument
	cmpq	$2, %rdi		# Compare 'argc' to 2
	jne	invalid_argc		# If not equal, go to invalid_argc		

	movq	8(%rsi), %r14		# Move argv[1] ('filename') to %r14

read_file:
	# Open the file
	movq	$0, %rax
	movq	$filemode, %rsi		# Second argument: filemode
	movq	%r14, %rdi		# First argument: filename
	call	fopen

	# Check for errors with opening file
	cmpq	$0, %rax		# Compare file pointer 'fp' to 0
	je	file_error		# If equal, go to file_error	

	movq	%rax, %r12		# Move the file pointer 'fp' to r12

	# Move the file pointer to the end of the file
	movq	$0, %rax
	movq	$2, %rdx		# Third argument: position to go to (2 = SEEK_END)
	movq	$0, %rsi		# Second argument: offset
	movq	%r12, %rdi		# First argument: file pointer
	call	fseek

	# Get current position in file
	movq	$0, %rax
	movq	%r12, %rdi		# First argument: file pointer
	call	ftell

	pushq	%rax			# Push 'filelength' to stack

	# Move file pointer back to the beginning of the file
	movq	$0, %rax
	movq	$0, %rdx		# Third argument: position to go to (0 = SEEK_SET)
	movq	$0, %rsi		# Second argument: offset
	movq	%r12, %rdi		# First argument: file pointer
	call	fseek

	popq	%r13			# Pop 'filelength' to r13

	# Read from file into MEMORY
	movq	$0, %rax
	movq	%r12, %rcx		# Fourth argument: file pointer
	movq	%r13, %rdx		# Third argument: amount of reads
	movq	$1, %rsi		# Second argument: bytes per read
	movq	$FILEBUFF, %rdi		# First argument: memory to write to
	call	fread

	movq	$0, %rax
	movq	%r12, %rdi		# First argument: file pointer
	call	fclose			# Close the file

	movq	$0, FILEBUFF(%r13)	# Null terminate the buffer

	call	brainfuck
	call	end

brainfuck:
	push	%rbp
	movq	%rsp, %rbp

	movq	$FILEBUFF, %r12		# Current source string address to r12
	movq 	$MEMORY, %r13		# Current memory address to r13

brainfuck_loop:
	cmpb	$'>', (%r12)
	je	inc_pointer

	cmpb	$'<', (%r12)
	je	dec_pointer

	cmpb	$'+', (%r12)
	je	inc_val

	cmpb	$'-', (%r12)
	je	dec_val

	cmpb	$'.', (%r12)
	je	print_val

	cmpb	$',', (%r12)
	je	input_char

	cmpb	$'[', (%r12)
	je	open_bracket

	cmpb	$']', (%r12)
	je	closing_bracket

	cmpb	$0, (%r12)
	je	brainfuck_end

brainfuck_loop_end:
	incq	%r12
	jmp	brainfuck_loop

inc_pointer:
	incq	%r13
	jmp	brainfuck_loop_end

dec_pointer:
	decq 	%r13
	jmp	brainfuck_loop_end

inc_val:
	incb	(%r13)
	jmp	brainfuck_loop_end

dec_val:
	decb	(%r13)
	jmp	brainfuck_loop_end

print_val:
	movq	$0, %rax
	mov	(%r13), %rdi
	call	putchar
	
	jmp	brainfuck_loop_end

input_char:
	movq	$0, %rax
	call	getchar
	mov	%rax, (%r13)
	
	jmp	brainfuck_loop_end

open_bracket:
	cmpb	$0, (%r13)
	je	find_closing_bracket

	jmp	brainfuck_loop_end

find_closing_bracket:
	movq	$0, %r14
	find_closing_bracket_loop:
		incq	%r12

		cmpb	$'[', (%r12)
		jne	check_open_end
		incq	%r14
		check_open_end:

		cmpb	$']', (%r12)
		jne	check_closing_end
		cmpq	$0, %r14
		je	brainfuck_loop_end
		decq	%r14
		check_closing_end:
		
		jmp	find_closing_bracket_loop

closing_bracket:
	cmpb	$0, (%r13)
	jne	find_opening_bracket
	
	jmp	brainfuck_loop_end	

find_opening_bracket:
	movq	$0, %r14
	find_opening_bracket_loop:
		decq	%r12

		cmpb	$']', (%r12)
		jne	check_closing_end2
		incq	%r14
		check_closing_end2:
		
		cmpb	$'[', (%r12)
		jne	check_open_end2
		cmpq	$0, %r14
		je	brainfuck_loop_end
		decq	%r14
		check_open_end2:

		jmp	find_opening_bracket_loop

brainfuck_end:
	movq	$0, %rax
	movq	$newline, %rdi
	call	printf

	movq	%rbp, %rsp
	popq	%rbp
	ret

file_error:
	movq	$0, %rax		# Clear rax
	movq	$invalidfile, %rdi	# First argument: string
	call	printf

	jmp 	end

invalid_argc:
	movq	$0, %rax		# Clear rax
	movq	$invalidargc, %rdi	# First argument: string
	call	printf

	jmp	end

end:
	movq	$0, %rdi		# Load exit code
	call	exit			# Call exit

/* vim: ft=gas :
*/
