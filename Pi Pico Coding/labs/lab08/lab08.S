.syntax unified                 @ Specify unified assembly syntax
.cpu    cortex-m0plus           @ Specify CPU type is Cortex M0+
.thumb                          @ Specify thumb assembly for RP2040
.global main_asm                @ Provide program starting address to the linker
.align 4                        @ Specify code alignment

.equ    INITIAL_VAL, 0

@ Entry point to the ASM portion of the program
main_asm:
    pop
    movs    r0, #INITIAL_VAL
    b       loop

loop:
    movs    r1, #1
    ldr     r2, =crnt_val
    ldr     r0, [r2]
    adds    r0, r1
    str     r0, [r2]
    b       loop            @ Infinite loop


@ Set data alignment
.data
    .align 4
    crnt_val: .word INITIAL_VAL