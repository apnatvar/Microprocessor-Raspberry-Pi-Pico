#include "hardware/regs/addressmap.h"
#include "hardware/regs/io_bank0.h"
#include "hardware/regs/timer.h"
#include "hardware/regs/m0plus.h"

.syntax unified
.cpu    cortex-m0plus
.thumb
.global main_asm
.align  4

.equ    DFLT_STATE_STRT, 1            @ Specify the value to start flashing
.equ    DFLT_STATE_STOP, 0            @ Specify the value to stop flashing
.equ    DFLT_ALARM_TIME, 1000000      @ Specify the default alarm timeout

.equ    GPIO_BTN_DN_MSK, 0x00040000   @ Bit-18 for falling-edge event on GP20
.equ    GPIO_BTN_EN_MSK, 0x00400000   @ Bit-22 for falling-edge event on GP21
.equ    GPIO_BTN_UP_MSK, 0x04000000   @ Bit-26 for falling-edge event on GP22

.equ    GPIO_BTN_DN,  20              @ Specify pin for the "down" button
.equ    GPIO_BTN_EN,  21              @ Specify pin for the "enter" button
.equ    GPIO_BTN_UP,  22              @ Specify pin for the "up" button
.equ    GPIO_LED_PIN, 25              @ Specify pin for the built-in LED
.equ    GPIO_DIR_IN,   0              @ Specify input direction for a GPIO pin
.equ    GPIO_DIR_OUT,  1              @ Specify output direction for a GPIO pin

.equ    LED_VAL_ON,    1              @ Specify value that turns the LED "on"
.equ    LED_VAL_OFF,   0              @ Specify value that turns the LED "off"

.equ    GPIO_ISR_OFFSET, 0x74         @ GPIO is int #13 (vector table entry 29)
.equ    ALRM_ISR_OFFSET, 0x40         @ ALARM0 is int #0 (vector table entry 16)

@ Entry point to the ASM portion of the program
//
// Main entry point into the ASM portion of the code
//
main_asm:
    bl    init_leds           // Same as previous labs
    bl    init_btns           // Use asm_gpio_set_irq C function to setup falling-edge interrutps
    bl    install_alrm_isr    // See below
    bl    install_gpio_isr    // See below

loop:
    bl    set_alarm            // Set a new alarm
    wfi                       // Wait here until any interrupt fires
    b     loop                // Always branch back to loop

init_leds:
    push    {lr}                       @ Store the link register to the stack as we will call nested subroutines
    movs    r0, #GPIO_LED_PIN          @ This value is the GPIO LED pin on the PI PICO board
    bl      asm_gpio_init              @ Call the subroutine to initialise the GPIO pin specified by r0
    movs    r0, #GPIO_LED_PIN          @ This value is the GPIO LED pin on the PI PICO board
    movs    r1, #GPIO_DIR_OUT          @ We want this GPIO pin to be setup as an output pin
    bl      asm_gpio_set_dir           @ Call the subroutine to set the GPIO pin specified by r0 to state specified by r1
    pop     {pc}                       @ Pop the link register from the stack to the program counter

init_btns:
    push    {lr}                       @ Store the link register to the stack as we will call nested subroutines

    movs    r0, #GPIO_BTN_DN           @ This value is the GPIO 20 pin on the PI PICO board
    bl      asm_gpio_init              @ Call the subroutine to initialise the GPIO pin specified by r0
    movs    r0, #GPIO_BTN_DN           @ This value is the GPIO 20 pin on the PI PICO board
    bl      asm_gpio_set_irq           @ Call the subroutine to set up falling edge on the GPIO pin specified by r0

    movs    r0, #GPIO_BTN_EN           @ This value is the GPIO 21 pin on the PI PICO board
    bl      asm_gpio_init              @ Call the subroutine to initialise the GPIO pin specified by r0
    movs    r0, #GPIO_BTN_EN           @ This value is the GPIO 21 pin on the PI PICO board
    bl      asm_gpio_set_irq           @ Call the subroutine to set up falling edge on the GPIO pin specified by r0

    movs    r0, #GPIO_BTN_UP           @ This value is the GPIO 22 pin on the PI PICO board
    bl      asm_gpio_init              @ Call the subroutine to initialise the GPIO pin specified by r0
    movs    r0, #GPIO_BTN_UP           @ This value is the GPIO 22 pin on the PI PICO board
    bl      asm_gpio_set_irq           @ Call the subroutine to set up falling edge on the GPIO pin specified by r0

    pop     {pc}                       @ Pop the link register from the stack to the program counter

set_alarm:
    ldr     r2,=TIMER_BASE                   @ Get the TIMER_BASE register address
    movs    r1, #1                           @ 1 is the appropriate value to set the alarm
    str     r1, [r2, #TIMER_INTE_OFFSET]     @ Enable the timer 0 interrupt
    ldr     r1, [r2, #TIMER_TIMELR_OFFSET]   
    ldr     r3, =ltimer                      @ Get the current flashing interval address
    ldr     r0, [r3]                         @ Get the current flashing interval
    add     r1, r0                           @ Update current alarm interval value
    str     r1, [r2, #TIMER_ALARM0_OFFSET]   @ Set the new alarm
    bx      lr                               @ Branch and exchange with the last instruction in link register

install_alrm_isr:
    ldr     r2, =(PPB_BASE + M0PLUS_VTOR_OFFSET)       @ Adds the base address of the CPU in RP2040 to vector offset address to find out where vector table is
    ldr     r1, [r2]                                   @ Hexadecimal address of where the vector table(value stored in r2) should be loaded in r1. r1 now has actual vector table base address
    movs    r2, #ALRM_ISR_OFFSET                       @ Move offset address to r2
    add     r2, r1                                     @ Adds offset address to the base address, stores the whole value in r2. r2 now has the address to the service routine
    ldr     r0, =alrm_isr                              @ Address of the subroutine alrm_isr is stored in r0
    str     r0, [r2]                                   @ Installs the subroutine where we have the offset address of the table
    movs    r0, #1                                     @ Moves the appropriate value into r0
    ldr     r1, =(PPB_BASE + M0PLUS_NVIC_ICPR_OFFSET)  @ Adds the base address of the CPU in RP2040 to NVIC ICPR offset address
    str     r0, [r1]                                   @ Disable the ALARM0 IRQ by writing #1 to the procured address
    ldr     r1, =(PPB_BASE + M0PLUS_NVIC_ISER_OFFSET)  @ Adds the base address of the CPU in RP2040 to NVIC ISER offset address
    str     r0, [r1]                                   @ Enable the ALARM0 IRQ by writing #1 to the procured address
    bx      lr                                         @ Branch and exchange with the last instruction in link register

.thumb_func                     @ Required for all interrupt service routines
alrm_isr:
    push    {lr}                          @ Store the link register to the stack as we will call nested subroutines
    ldr     r2, =TIMER_BASE               @ Get the Timer_Base register address
    movs    r1, #1                        @ 1 is the appropriate value to set the alarm
    str     r1, [r2, #TIMER_INTR_OFFSET]  @ Reset the alarm 
    bl      sub_toggle                    @ Branch with link to sub_toggle
    ldr     r2, =ltimer                   @ Get the current flashing interval address
    pop     {pc}                          @ Pop the link register from the stack to the program counter
sub_toggle:
    push    {lr}                      @ Store the link register to the stack as we will call nested subroutines
    ldr     r2, =lstate               @ Get the current flashing state address
    ldr     r1, [r2]                  @ get the current flashing state
    cmp     r1, DFLT_STATE_STOP       @ Check if we are in the 'off' or 'stop' state
    beq     finish_toggle             @ Branch to finish_toggle if the LED is currently not flashing
    movs    r0, #GPIO_LED_PIN         @ Set the LED GPIO pin number to r0 for use by asm_gpio_get
    bl      asm_gpio_get              @ Get current the value of the LED GPIO pin (returns to r0)
    cmp     r0, #LED_VAL_OFF          @ Check if the LED GPIO pin value is "off"
    beq     led_set_on                @ If it is "off" then then jump code to to turn it on
led_set_off:
    movs    r1, #LED_VAL_OFF          @ The LED is currently "on" so we want to turn it "off"
    b       led_set_state             @ Jump to portion of code where we set the state of the LED
led_set_on:
    movs    r1, #LED_VAL_ON           @ The LED is currently "off" so we want to turn it "on"
led_set_state:
    movs    r0, #GPIO_LED_PIN         @ Set the LED GPIO pin number to r0 for use by asm_gpio_put
    bl      asm_gpio_put              @ Update the the value of the LED GPIO pin (based on value in r1)
    ldr     r0, =al_msg               @ Store the appropriate message in r0
    bl      printf                    @ Call the subroutine to print the message passed by r0
finish_toggle:    
    pop     {pc}                      @ Pop the link register from the stack to the program counter

install_gpio_isr:
    ldr     r2, =(PPB_BASE + M0PLUS_VTOR_OFFSET)       @ Adds the base address of the CPU in RP2040 to vector offset address to find out where vector table is
    ldr     r1, [r2]                                   @ Hexadecimal address of where the vector table(value stored in r2) should be loaded in r1. r1 now has actual vector table base address
    movs    r2, #GPIO_ISR_OFFSET                       @ Move offset address to r2
    add     r2, r1                                     @ Adds offset address to the base address, stores the whole value in r2. r2 now has the address to the service routine
    ldr     r0, =gpio_isr                              @ Address of the subroutine gpio_isr is stored in r0
    str     r0, [r2]                                   @ Installs the subroutine where we have the offset address of the table
    ldr     r0, =8192                                  @ Activate the 14th bit in the table
    ldr     r2, =(PPB_BASE + M0PLUS_NVIC_ICPR_OFFSET)  @ Adds the base address of the CPU in RP2040 to NVIC ICPR offset address
    str     r0, [r2]                                   @ Disable the GPIO IRQ by writing 8192 to the procured address
    ldr     r2, =(PPB_BASE + M0PLUS_NVIC_ISER_OFFSET)  @ Adds the base address of the CPU in RP2040 to NVIC ISER offset address
    str     r0, [r2]                                   @ Disable the GPIO IRQ by writing 8192 to the procured address
    bx      lr                                         @ Branch and exchange with the last instruction in link register

.thumb_func                     @ Required for all interrupt service routines
gpio_isr:
    push    {lr}                                                @ Store the link register to the stack as we will call nested subroutines
    ldr     r2, =(IO_BANK0_BASE + IO_BANK0_PROC0_INTS2_OFFSET)  @ Get the address of the register which informs if an interupt happened
    ldr     r1, [r2]                                            @ Load the value from that register into r1
    ldr     r0, =GPIO_BTN_DN_MSK                                @ Store mask for GP20 
    cmp     r1, r0                                              @ Compare with mask to check if GP20 was pressed
    beq     dn_press_detected                                   @ Branch if equal to dn_press_detected 
    ldr     r0, =GPIO_BTN_EN_MSK                                @ Store mask for GP21 
    cmp     r1, r0                                              @ Compare with mask to check if GP21 was pressed
    beq     en_press_detected                                   @ Branch if equal to en_press_detected
    ldr     r0, =GPIO_BTN_UP_MSK                                @ Store mask for GP22 
    cmp     r1, r0                                              @ Compare with mask to check if GP22 was pressed
    beq     up_press_detected                                   @ Branch if qual to up_press_detected
gpio_isr_done:
    ldr     r2, =(IO_BANK0_BASE + IO_BANK0_PROC0_INTS2_OFFSET)  @ Get the address of the INTS register 2
    ldr     r0, =8192                                           @ Set the mask for th 14th bit
    str     r0, [r2]                                            @ Reset the GPIO ISR interrupt
    pop     {pc}                                                @ Pop the link register from the stack to the program counter

dn_press_detected:
    ldr     r2, =lstate             @ Get the current flashing state address
    ldr     r1, [r2]                @ Get the current flashing state
    movs    r0, #0                  @ Store 'off' state in r0
    cmp     r0, r1                  @ Check if we are in off state
    beq     change_to_default_dn    @ Branch to change_to_default_dn if we are in 'off' state
    ldr     r0, =dn_msg             @ Store the appropriate message in r0
    bl      printf                  @ Call the subroutine to print the message passed by r0
    ldr     r2, =ltimer             @ Get the current flashing interval address
    ldr     r1, [r2]                @ Get the current flashing interval
    movs    r0, r1                  @ Store the current flashing interval in r0 and half it using repeated subtraction
    b       half_current_interval   @ Branch to half_current_interval to calculate the half of the current flashing interval

change_to_default_dn:
    ldr     r2, =ltimer                                     @ Get the current flashing interval address
    ldr     r1, =DFLT_ALARM_TIME                            @ Get the default flashing interval
    ldr     r1, [r2]                                        @ Update the current flashing interval to the Default Value
    ldr     r2, =(IO_BANK0_BASE + IO_BANK0_INTR2_OFFSET)    @ Get the address of the INTR Register 2
    ldr     r1, =GPIO_BTN_DN_MSK                            @ Get mask for GP20
    str     r1, [r2]                                        @ Reset the INTR Register 2 for GP20 Press
    ldr     r0, =rst_msg                                    @ Store the appropriate message in r0
    bl      printf                                          @ Call the subroutine to print the message passed by r0
    b       gpio_isr_done                                   @ Branch to gpio_isr_done

half_current_interval:
    subs    r0, #2                  @ Repeated Substraction to calculate the half of the value
    movs    r2, r0                  @ Store new value in R2
    adds    r2, r2                  @ Double the new result
    cmp     r2, r1                  @ Check if equal to original
    bgt     half_current_interval   @ Branch to itself if the value is still greater
    b       dn_done                 @ Branch to dn_done once the value is halved

dn_done:
    ldr     r2, =ltimer                                     @ Get the current flashing interval address
    str     r0, [r2]                                        @ Update the current flashing interval
    ldr     r2, =(IO_BANK0_BASE + IO_BANK0_INTR2_OFFSET)    @ Get the address of the INTR Register 2
    ldr     r1, =GPIO_BTN_DN_MSK                            @ Get the mask for GP20
    str     r1, [r2]                                        @ Reset the GPIO ISR for GP20
    b       gpio_isr_done                                   @ Branch to gpio_isr_done

en_press_detected:
    ldr     r2, =lstate         @ Get the current flashing state address
    ldr     r1, [r2]            @ Get the current state
    movs    r0, #1              @ Store 1 in the r0
    cmp     r0, r1              @ Check if we are in 'on' state
    beq     change_state_to_off @ Branch if equal to change_state_to_off to change to 'off' state
    str     r0, [r2]            @ Change state to 'on'
    ldr     r0, =en_msg_s       @ Store the appropriate message in r0
    bl      printf              @ Call the subroutine to print the message passed by r0
    movs    r0, #1              @ Restore the value disturbed by the requirements of printf subroutine
    b       en_done             @ Branch to en_done to complete handling the interrupt

en_done:
    ldr     r2, =lstate                                     @ Get the current flashing state address
    str     r0, [r2]                                        @ Store the new state 
    ldr     r2, =(IO_BANK0_BASE + IO_BANK0_INTR2_OFFSET)    @ Get the address of the INTR Register 2
    ldr     r1, =GPIO_BTN_EN_MSK                            @ Get the mask for GP21
    str     r1, [r2]                                        @ Reset the GPIO ISR for GP21
    b       gpio_isr_done                                   @ Branch to gpio_isr_done

change_state_to_off:
    ldr     r0, =en_msg_p       @ Store the appropriate message in r0
    bl      printf              @ Call the subroutine to print the message passed by r0
    movs    r0, #0              @ Store the value of the new state
    b       en_done             @ Branch to en_done 

up_press_detected:
    ldr     r2, =lstate             @ Get the current flashing state address
    ldr     r1, [r2]                @ Get the current state
    movs    r0, #0                  @ Store 'off' state in r0
    cmp     r0, r1                  @ Check if we are in flashing off state
    beq     change_to_default_up    @ If equal, branch to change_to_default_up
    ldr     r2, =ltimer             @ Get the current flashing interval address
    ldr     r1, [r2]                @ Get the value of the current flashing interval
    adds    r1, r1                  @ Double the value of the current flashing interval
    str     r1, [r2]                @ Store this value again in the interval
    ldr     r0, =up_msg             @ Store the appropriate message in r0
    bl      printf                  @ Call the subroutine to print the message passed by r0
    b       up_done                 @ Unconditional branch to up_done

up_done:
    ldr     r2, =(IO_BANK0_BASE + IO_BANK0_INTR2_OFFSET)    @ Get the address of the INTR Register 2
    ldr     r1, =GPIO_BTN_UP_MSK                            @ Get the mask for GPIO for GP22
    str     r1, [r2]                                        @ Reset the GPIO ISR for GP22
    b       gpio_isr_done                                   @ Branch to gpio_isr_done

change_to_default_up:
    ldr     r0, =rst_msg            @ Store the appropriate message in r0
    bl      printf                  @ Call the subroutine to print the message passed by r0
    ldr     r2, =ltimer             @ Get the current flashing interval address
    ldr     r1, =DFLT_ALARM_TIME    @ Get the default flashing interval
    str     r1, [r2]                @ Change the flashing interval to the default value
    b       up_done                 @ Unconditional Branch to up_done

.align 4
up_msg:    .asciz "Increasing the Blinking Interval.\n"             @ Message when GP22 is pressed
dn_msg:    .asciz "Decreasing the Blinking Interval.\n"             @ Message when GP20 is pressed
en_msg_p:  .asciz "Flashing Paused.\n"                              @ Message when GP21 is pressed in 'on' state
en_msg_s:  .asciz "Flashing Resumed.\n"                             @ Message when GP21 is pressed in 'off' state
rst_msg:   .asciz "Blinking Interval Reset.\n"                      @ Message when either GP20 or GP22 is pressed while flashing is paused
al_msg:    .asciz "Toggling the LED through the Alarm Interrupt.\n" @ Message when alarm toggles the LED

.data
lstate: .word   DFLT_STATE_STRT         @ Variable to keep track of the current state of flashing
ltimer: .word   DFLT_ALARM_TIME         @ Variable to keep track of the current flashing interval