# Brainfuck x86-64
Brainfuck interpreter written in Intel x86-64 assembly (AT&T syntax).

It uses some basic optimizations:
1. It uses a jumptable to jump to ']' instead of iterating through all characters until it finds it.
2. Same goes for the '[', but it uses the stack for those.
3. A sequence of '[-]' will be interpreted as setting a cell to 0, instead of iterating many times.

To build:
`gcc -no-pie brainfuck.s -o brainfuck`

To run:
`./brainfuck {filename}`
