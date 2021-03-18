.global set_handlers, curr_key

.text

# Scancodes for various keyboard keys
.equ    UP,     0x48
.equ    DOWN,   0x50
.equ    SPACE,  0x39
.equ    ESC,    0x01

.data
    curr_key:   .zero  1

set_handlers:
	# Register timer interrupt handler in bootlib
	pushl	$irq0
	pushl	$0
	call	set_irq_handler
	call	enable_irq
	addl	$8, %esp

	# Register keyboard interrupt handler in bootlib
	pushl	$irq1
    pushl   $1
    call    set_irq_handler
    call    enable_irq
    addl    $8, %esp

	ret

# On every timer interrupt, increment 'time'
irq0:
	incl	time
	jmp	end_of_irq0

irq1:
	# Get scancode from keyboard (%al will have the ASCII value)
	xor    	%eax, %eax
	inb     $0x60, %al

	# Set the current key depending on the input
	case_up:
		cmpb    $UP, %al
		jne     case_down
		movb    $1, curr_key
	case_down:
		cmpb    $DOWN, %al
		jne     case_esc
		movb    $2, curr_key
	case_esc:
		cmpb    $ESC, %al
		jne     case_space
		movb    $3, curr_key
	case_space:
		cmpb    $SPACE, %al
		jne     return
		movb    $4, curr_key
	return:
		jmp     end_of_irq1
