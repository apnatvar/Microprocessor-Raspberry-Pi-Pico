#include "hardware/regs/addressmap.h"
#include "hardware/regs/m0plus.h"

.syntax unified                 @ Specify unified assembly syntax
.cpu    cortex-m0plus           @ Specify CPU type is Cortex M0+
.thumb                          @ Specify thumb assembly for RP2040
.global main_asm                @ Provide program starting address to the linker
.align 4                        @ Specify code alignment

.equ    SLEEP_TIME, 500         @ Specify the sleep time (in ms)
.equ    LED_GPIO_PIN, 25        @ Specify the pin that the LED is connected to
.equ    LED_GPIO_OUT, 1         @ Specify the direction of the GPIO pin
.equ    LED_VALUE_ON, 1         @ Specify the value that turns the LED "on"
.equ    LED_VALUE_OFF, 0        @ Specify the value that turns the LED "off"
.equ    SVC_ISR_OFFSET, 0x2C    @ The SVC is entry 11 in the vector table
.equ    SVC_MAX_INSTRS, 0x01    @ Maximum allowed SVC subroutines

@ Entry point to the ASM portion of the program
main_asm:
    bl      init_gpio_led       @ Initialise the GPIO LED pin
    bl      install_svc_isr     @ Install the SVC interrupt service routine
loop:
    svc     #0                  @ Call the SVC ISR with value 0 (turns on LED)
    nop                         @ Add a no-op instruction for alignment after SVC
    bl      do_sleep            @ Short pause before proceeding
    svc     #1                  @ Call the SVC ISR with value 1 (turns off LED)
    nop                         @ Add a no-op instruction for alignment after SVC
    bl      do_sleep            @ Add a short pause before proceeding
    b       loop                @ Always jump back to the start of the loop

@ Subroutine used to introduce a short delay in the application
do_sleep:
    push    {lr}                        @ Store the link register to the stack as we will call nested subroutines
    ldr     r0, =SLEEP_TIME             @ Set the value of SLEEP_TIME we want to wait for
    bl      sleep_ms                    @ Sleep until SLEEP_TIME has elapsed
    pop     {pc}                        @ Pop the link register from the stack to the program counter
    @<TODO – add assembly code to implement the sleep delay using sleep_ms>

@ Subroutine used to initialise the PI Pico built-in LED
init_gpio_led:
    push    {lr}                        @ Store the link register to the stack as we will call nested subroutines
    movs    r0, #LED_GPIO_PIN           @ This value is the GPIO LED pin on the PI PICO board
    bl      asm_gpio_init               @ Call the subroutine to initialise the GPIO pin specified by r0
    movs    r0, #LED_GPIO_PIN           @ This value is the GPIO LED pin on the PI PICO board
    movs    r1, #LED_GPIO_OUT           @ We want this GPIO pin to be setup as an output pin
    bl      asm_gpio_set_dir            @ Call the subroutine to set the GPIO pin specified by r0 to state specified by r1
    pop     {pc}                        @ Pop the link register from the stack to the program counter
    @<TODO – add assembly code to initialise the LED GPIO pin>

@ Subroutine used to install the SVC interrupt service handler
install_svc_isr:
    ldr     r2, =(PPB_BASE + M0PLUS_VTOR_OFFSET)    @ Calculate the base address of the vector table
    ldr     r1, [r2]                                @ Load the value found at the location r2 is pointing to
    movs    r2, #SVC_ISR_OFFSET                     @ Store offset of the address of SVC ISR
    add     r2, r1                                  @ Add the offset and the base address to get the final address to install SVC Interrupt Service 
    ldr     r0, =svc_isr                            @ Store a pointer to the routine in r0
    str     r0, [r2]                                @ Load the value found at the location r2 is pointing to into the location r0 is pointing to
    bx      lr                                      @ Branches to the last instruction in the link register

@ SVC interrupt service handler routine
.thumb_func                     @ Required for all interrupt service routines
svc_isr:
    push    {lr}                @ Store the link register to the stack as we will call nested subroutines
    ldr     r0, [sp, #0x1C]     @ Retrieve address of the SVC opcode from the PC in the stack
    subs    r0, #0x2            @ Correct the address after pushing the link register
    ldr     r0, [r0]            @ Fetch value stored at the address r0 is pointing to
    ldr     r1, =#0xFF          @ Setting up the mask for the 8 bit value needed
    ands    r0, r1              @ Store only the 8 bit value from r1
    cmp     r0, #SVC_MAX_INSTRS @ Check if defined subroutines does not exceed the maximum count
    bgt     svc_done            @ Branch back to the main ISR if Max Subroutines are reached
    adr     r1, svc_jmptbl      @ Go to the jumptable and retrieve the address of the correct subroutine
    lsls    r0, #2              @ Add the value back to correct addressing from earlier
    ldr     r1, [r1, r0]        @ Store the address of the next subroutine added to the offset from r0
    mov     pc, r1              @ Modify the program counter push the value to program counter, we have the address of svcnum0 or svcnum1 
svc_done:
    pop     {pc}                @ Pop the link register from the stack to the program counter

@ First function of SVC subroutine - turn on the LED
svc_num0:
    movs    r0, #LED_GPIO_PIN           @ Set the LED GPIO pin number to r0 for use by asm_gpio_put
    movs    r1, #LED_VALUE_ON           @ The LED is currently "off" so we want to turn it "on"
    bl      asm_gpio_put                @ Update the the value of the LED GPIO pin (based on value in r1)
    @<TODO – add assembly code to turn on the LED>
    b       svc_done            @ Branch back to the main ISR when done

@ Second function of SVC subroutine - turn off the LED
svc_num1:
    movs    r0, #LED_GPIO_PIN           @ Set the LED GPIO pin number to r0 for use by asm_gpio_put
    movs    r1, #LED_VALUE_OFF          @ The LED is currently "off" so we want to turn it "on"
    bl      asm_gpio_put                @ Update the the value of the LED GPIO pin (based on value in r1)
    @<TODO – add assembly code to turn off the LED>
    b       svc_done            @ Branch back to the main ISR when done

@ SVC function entry jump table.
.align 2
svc_jmptbl:
    .word svc_num0              @ Entry zero goes to SVC function #0.
    .word svc_num1              @ Entry one goes to SVC function #1.
    .word 0                     @ Null termination of the jump table.

@ Set data alignment
.data
    .align 4
