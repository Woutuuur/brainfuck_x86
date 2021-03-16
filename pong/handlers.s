.global set_handlers

.text

set_handlers:
	pushl	$irq0
	pushl	$0
	call	set_irq_handler
	call	enable_irq
	addl	$8, %esp

	ret

irq0:
	incl	time
	jmp	end_of_irq0
