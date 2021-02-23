# ***************************************************************************************
# * Program name: diff									*
# * Description: Simplified diff subroutine						*
# ***************************************************************************************
.bss
BUFF1:		.skip 128
BUFF2:		.skip 128
DIFFS:		.skip 4096		# Reserve 4096 bytes for the 2nd file's diffs


.text
# Initialize null-terminated strings
teststr:	.asciz "My name is %s. I think I'll get a %u for my exam. What does %r do? And %%? Btw here's negative numbers: %d\n"
newline:	.asciz "\n"
invalidfile:	.asciz "Error reading file '%s'\n"
invalidargc:	.asciz "Invalid amount of argumnets\n"
filemode:	.asciz "r"
diffformat1:	.asciz "< %s"
diffformat2:	.asciz "> "
seperator:	.asciz "---\n"
printstr:	.asciz "%s"

.global main
# ***************************************************************************************
# * Subroutine: main									*
# * Description: Program entry point							*
# ***************************************************************************************
main:
	cmp	$3, %rdi
	jne	invalid_argc

	movq	$129, %rbx

	movq	8(%rsi), %r12		# Move argv[1] ('filename1') to r12
	movq	16(%rsi), %r13		# Move argv[2] ('filename2') to r13

	movq	$filemode, %rsi		# Second argument: filemode
	movq	%r12, %rdi		# First argument: filename
	call	fopen

	movq	%r12, %rdi		# Move 'filename1' to rdi (in case there is an error)
	cmpq	$0, %rax		# Compare file pointer to 0
	je	file_error		# If equal, go to file_error

	movq	%rax, %r12		# Move 'fp1' to r12

	movq	$filemode, %rsi		# Second argument: filemode
	movq	%r13, %rdi		# First argument: filename
	call	fopen

	movq	%r13, %rdi		# Move 'filename2' to rdi (in case there is an error)
	cmpq	$0, %rax		# Compare file pointer to 0
	je	file_error		# If equal, go to file_error
	
	movq	%rax, %r13		# Move 'fp2' to r13

main_loop:
	while_empty:
		# Read a single line from file 1
		movq	$0, %rax		# Clear rax
		movq	%r12, %rdx		# Third argument: File pointer
		movq	$127, %rsi		# Second argument: Max amount of bits to read
		movq	$BUFF1, %rdi		# First argument: buffer to write to 
		call 	fgets
		
		movq	%rax, %r14		# Move 'result1' to r14
	
		movq	$0, %rax		# Clear rax
		movq	$BUFF1, %rdi		# First argument: char buffer
		call	strlen	
		
		cmpq	$0, %rax		# Compare len(BUFF1) to 0
		je	while_empty		# If equal, jump to top of loop

	
	while_empty2:
		# Read a single line from file 2
		movq	$0, %rax		# Clear rax
		movq	%r13, %rdx		# Third argument: File pointer
		movq	$127, %rsi		# Second argument: Max amount of bits to read
		movq	$BUFF2, %rdi		# First argument: buffer to write to 
		call 	fgets

		movq	%rax, %r15		# Move 'result2' to r15

		movq	$0, %rax		# Clear rax
		movq	$BUFF2, %rdi		# First argument: char buffer
		call	strlen

		cmpq	$0, %rax		# Compare len(BUFF1) to 0
		je	while_empty2		# If equal, jump to top of loop
	
	jmp	read_results

read_results:	
	cmpq	$0, %r14		# Compare 'result1' to NULL
	je	file1_null		# If equal, go to file1_null

	cmpq	$0, %r15		# Compare 'result2' to NULL
	je	file2_null		# If equal, go to file2_null

	# Compare BUFF1 to BUFF2
	movq	$0, %rax		# Clear rax
	movq	$BUFF1, %rsi		# Second argument: char buffer 1
	movq	$BUFF2, %rdi		# First argument: char buffer 2
	call	strcmp

	cmpq	$0, %rax
	jne	difference		# If not equal (strings are different)

	jmp 	main_loop

file1_null:
	# If 'result2' is also NULL, we reached the end off both files and should break loop
	cmpq	$0, %r15		# Compare 'result2' to NULL
	je	print_diffs		# If equal, go to print_diff	

	# Else, we should concatenate BUFF2 onto DIFFS
	# 1. Add '< ' to DIFFS
	movq	$0, %rax		# Clear rax
	movq	$diffformat2, %rsi	# Second argument: char buffer to read from
	movq	$DIFFS, %rdi		# First argument: char buffer to concatenate to
	call	strcat

	# 2. Concatenate BUFF2 to DIFFS
	movq	$0, %rax		# Clear rax
	movq	$BUFF2, %rsi		# Second argument: char buffer to read from
	movq	$DIFFS, %rdi		# First argument: char buffer to concatenate to
	call	strcat

	jmp	main_loop

file2_null:
	# Simply print BUFF1
	movq	$0, %rax		# Clear rax
	movq	$BUFF1, %rsi		# Second argument: char buffer
	movq	$diffformat1, %rdi	# First argument: format str
	call	printf

	jmp	main_loop		# Back to main loop

difference:		
	# Print BUFF1
	movq	$0, %rax		# Clear rax
	movq	$BUFF1, %rsi		# Second argument: char buffer
	movq	$diffformat1, %rdi	# First argument: format str
	call	printf

	# Concatenate BUFF2 onto DIFFS
	# 1. Add '< ' to DIFFS
	movq	$0, %rax		# Clear rax
	movq	$diffformat2, %rsi	# Second argument: char buffer to read from
	movq	$DIFFS, %rdi		# First argument: char buffer to concatenate to
	call	strcat

	# 2. Concatenate BUFF2 to DIFFS
	movq	$0, %rax		# Clear rax
	movq	$BUFF2, %rsi		# Second argument: char buffer to read from
	movq	$DIFFS, %rdi		# First argument: char buffer to concatenate to
	call	strcat

	jmp	main_loop

print_diffs:
	movq	$0, %rax		# Clear rax
	movq	$DIFFS, %rdi		# First argument: char buffer	
	call	strlen

	cmpq	$0, %rax		# Compare len(DIFFS) to 0
	je	my_diff_end		# If equal, go to end

	movq	$0, %rax		# Clear rax
	movq	$seperator, %rdi	# First argument: string literal
	call	printf

	movq 	$0, %rax		# Clear rax
	movq 	$DIFFS, %rsi		# Second argument: char buffer
	movq	$printstr, %rdi		# First argument: format str
	call	printf

	jmp	my_diff_end		# Go to end

file_error:
	movq	$0, %rax
	movq	%rdi, %rsi		# Second argument: filename
	movq	$invalidfile, %rdi	# First argument: format str
	call	printf
	jmp	end

invalid_argc:
	movq	$0, %rax		# Clear rax
	movq	$invalidargc, %rdi	# First argument: string literal
	call	printf			# Print it

	jmp	end			# Go to end

my_diff_end:	
	movq	$0, %rax		# Clear rax
	movq	%r12, %rdi		# First argument: 'fp1'
	call	fclose

	movq	$0, %rax		# Clear rax
	movq	%r13, %rdi		# First argument: 'fp2'	
	call	fclose
	
	jmp	end
end:
	
	movq	$0, %rdi		# Load exit code
	call	exit			# Call exit
