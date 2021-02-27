# ***************************************************************************************
# * Program name: brainfuck								*
# * Description: Interpreter for the brainfuck language					*
# ***************************************************************************************
.bss
FILEBUFF: 	.skip 64000	
JUMPTABLE:	.skip 128000
MEMORY:		.skip 8192
PRINTBUFF: 	.skip 256

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
	movq	$filemode, %rsi		# Second argument: filemode
	movq	%r14, %rdi		# First argument: filename
	call	fopen

	# Check for errors with opening file
	cmpq	$0, %rax		# Compare file pointer 'fp' to 0
	je	file_error		# If equal, go to file_error	

	movq	%rax, %r12		# Move the file pointer 'fp' to r12

	# Move the file pointer to the end of the file
	movq	$2, %rdx		# Third argument: position to go to (2 = SEEK_END)
	movq	$0, %rsi		# Second argument: offset
	movq	%r12, %rdi		# First argument: file pointer
	call	fseek

	# Get current position in file
	movq	%r12, %rdi		# First argument: file pointer
	call	ftell

	pushq	%rax			# Push 'filelength' to stack

	# Move file pointer back to the beginning of the file
	movq	$0, %rdx		# Third argument: position to go to (0 = SEEK_SET)
	movq	$0, %rsi		# Second argument: offset
	movq	%r12, %rdi		# First argument: file pointer
	call	fseek

	popq	%r13			# Pop 'filelength' to r13

	# Read from file into MEMORY
	movq	%r12, %rcx		# Fourth argument: file pointer
	movq	%r13, %rdx		# Third argument: amount of reads
	movq	$1, %rsi		# Second argument: bytes per read
	movq	$FILEBUFF, %rdi		# First argument: memory to write to
	call	fread

	movq	%r12, %rdi		# First argument: file pointer
	call	fclose			# Close the file

	movq	$0, FILEBUFF(%r13)	# Null terminate the buffer

	call	brainfuck
	call	end

brainfuck:
	push	%rbp
	movq	%rsp, %rbp

	movq	$0, %r12
	movq 	$MEMORY, %r13		# Current memory address to r13

brainfuck_loop:
	cmpb	$'>', FILEBUFF(%r12)
	je	inc_pointer

	cmpb	$'<', FILEBUFF(%r12)
	je	dec_pointer

	cmpb	$'+', FILEBUFF(%r12)
	je	inc_val

	cmpb	$'-',  FILEBUFF(%r12)
	je	dec_val

	cmpb	$'.',  FILEBUFF(%r12)
	je	print_val

	cmpb	$',',  FILEBUFF(%r12)
	je	input_char

	cmpb	$'[',  FILEBUFF(%r12)
	je	open_bracket

	cmpb	$']',  FILEBUFF(%r12)
	je	closing_bracket

	cmpb	$0, FILEBUFF(%r12)
	je	brainfuck_end

brainfuck_loop_end:
	incq	%r12
	jmp	brainfuck_loop

inc_pointer:
	inc	%r13
	jmp	brainfuck_loop_end

dec_pointer:
	dec 	%r13
	jmp	brainfuck_loop_end

inc_val:
	incb	(%r13)
	jmp	brainfuck_loop_end

dec_val:
	decb	(%r13)
	jmp	brainfuck_loop_end

print_val:
	movq	$0, %rax
	movq	(%r13), %rdi
	call	putchar
	
	jmp	brainfuck_loop_end

input_char:
	movq	$0, %rax
	call	getchar
	movq	%rax, (%r13)
	
	jmp	brainfuck_loop_end

open_bracket:
	cmpb	$0, (%r13)
	je	find_closing_bracket

	pushq	%r12

	jmp	brainfuck_loop_end

find_closing_bracket:
	movq	%r12, %r15
	movq	$0, %rdx
	cmpw 	$0, JUMPTABLE(%rdx, %r15, 2)
	jg		jump_matching

	movq	$0, %r14
	find_closing_bracket_loop:
		inc		%r12

		cmpb	$'[', FILEBUFF(%r12)
		jne	check_open_end
		incq	%r14
		check_open_end:

		cmpb	$']', FILEBUFF(%r12)
		jne	check_closing_end
		cmpq	$0, %r14
		je	find_closing_bracket_loop_end
		decq	%r14
		check_closing_end:
		
		jmp	find_closing_bracket_loop

	find_closing_bracket_loop_end:
		movq	$0, %rdx
		movq	%r12, %rax
		movw	%ax, JUMPTABLE(%rdx, %r15, 2)
		jmp	brainfuck_loop_end

jump_matching:
	mov		$0, %rdx
	movw	JUMPTABLE(%rdx, %r15, 2), %ax
	movq	%rax, %r12
	jmp		brainfuck_loop_end

closing_bracket:
	cmpb	$0, (%r13)
	jne	find_opening_bracket
	
	addq 	$8, %rsp
	
	jmp	brainfuck_loop_end	

find_opening_bracket:
	movq	(%rsp), %r12

	jmp	brainfuck_loop_end

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

	jmp	end

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
