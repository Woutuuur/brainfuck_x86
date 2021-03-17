.global set_handlers, curr_key, curr_key2

.text

.equ    UP,     0x48
.equ    DOWN,   0x50
.equ    SPACE,  0x39
.equ    ESC,    1
.equ    ENTER,  0x1c
.equ    DOWN2,  0x1f
.equ    UP2,  0x11

.data
    curr_key:   .zero  1
    curr_key2:  .zero  1

set_handlers:
	pushl	$irq0
	pushl	$0
	call	set_irq_handler
	call	enable_irq
	addl	$8, %esp

	pushl   $irq1                       # \
    pushl   $1                          # | Bootlib's method in creating a interupt handler.
    call    set_irq_handler             # |
    call    enable_irq                  # |
    addl    $8, %esp                    # /

	ret

irq0:
	incl	time
	jmp	end_of_irq0

irq1:
	wait:
		
		mov 	$0x01, %al				# Check if there is key buffer
		inb 	$0x16, %al
		jz		return
		
		movl    $0, %eax                # Empty %eax
		inb     $0x60, %al              # Get scancode from keyboard's in and put it into %eax
		
		jmp case_up
		jmp wait
		
		
	case_up:
		cmpb    $UP, %al              	# | If the scancode does not equal the scancode for UP
		jne     case_down               # | Jump to the next case.
		movb    $1, curr_key            # | Else, move 1 into curr_key variable.
	case_down:
		cmpb    $DOWN, %al              # | If the scancode does not equal the scancode for DOWN
		jne     case_space              # | Jump to the next case.
		movb    $2, curr_key            # | Else, move 2 into curr_key variable.
	case_space:
		cmpb    $SPACE, %al             # | If the scancode does not equal the scancode for SPACE
		jne     case_esc                # | Jump to the next case.
		movb    $3, curr_key            # | Else, move 3 into curr_key variable.
	case_esc:
		cmpb    $ESC, %al               # | If the scancode does not equal the scancode for ESC
		jne     case_enter              # | Jump to the next case.
		movb    $4, curr_key            # | Else, move 4 into curr_key variable.
	case_enter:
		cmpb    $ENTER, %al             # | If the scancode does not equal the scancode for ENTER
		jne     case_up2                  # | Jump to the next case.
		movb    $5, curr_key            # | Else, move 4 into curr_key variable.
	case_up2:
		cmpb    $UP2, %al             # | If the scancode does not equal the scancode for ENTER
		jne     case_down2                  # | Jump to the next case.
		movb    $1, curr_key2           # | Else, move 4 into curr_key variable.
	case_down2:
		cmpb    $DOWN2, %al             # | If the scancode does not equal the scancode for ENTER
		jne     return                  # | Jump to the next case.
		movb    $2, curr_key2            # | Else, move 4 into curr_key variable.
		ret
	return:
		movb    $0, %al                 # No keys were found so clear the scancode.
		jmp     end_of_irq1             # Exit.

