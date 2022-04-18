#include "hardware/regs/addressmap.h"
#include "hardware/regs/adc.h"
#include "hardware/regs/timer.h"
#include "hardware/regs/m0plus.h"

.syntax unified                 @ Specify unified assembly syntax
.cpu    cortex-m0plus           @ Specify CPU type is Cortex M0+
.thumb                          @ Specify thumb assembly for RP2040
.global main_asm                @ Provide program starting address to the linker
.align 4                        @ Specify code alignment

.equ    TEMPADC, 4                     @ Temperature sensor is on the ADC Line 4
.equ    ALARM_TIME, 2000000            @ Time interval for alarm interrupt - 2 seconds.
.equ    ALRM_ISR_OFFSET, 0x40          @ Vector table entry 16 for ALARM Interrupt

.thumb_func
@ Entry point to the ASM portion of the program
main_asm:
    ldr     r1, =pointer            @ Load the pointer so we can manipulate its value
    str     r0, [r1]                @ Storing the address in a variable for immediate access
    bl      install_alrm_isr        @ Installs the alarm interrupt
    bl      init_tempsensor         @ Turn on the ADC and Temperature Sensor

loop: 
    bl      set_alarm           @ Set a new alarm after each interrupt
    wfi                         @ Wait for Interrupt
    b       loop                @ Infinite Loop

set_alarm:
    ldr     r2, =TIMER_BASE                  @ Get the TIMER_BASE register address
    movs    r1, #1                           @ 1 is the appropriate value to set the alarm
    str     r1, [r2, #TIMER_INTE_OFFSET]     @ Enable the timer 0 interrupt
    ldr     r1, [r2, #TIMER_TIMELR_OFFSET]   @ Get the lower Time registers
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

init_tempsensor:                                         
    movs    r1, #TEMPADC                                @ Bit to turn Temperature Sensor On        
    lsls    r1, #ADC_CS_AINSEL_LSB                      @ Set the appropriate 
    adds    r1, #(ADC_CS_TS_EN_BITS + ADC_CS_EN_BITS)   @ Add bits to enable Temperature Sensor
    ldr     r2, =ADC_BASE                               @ ADC Register base value
    str     r1, [r2, #ADC_CS_OFFSET]                    @ Store the bits at the correct offset

wait_for_ready:                         @ Wait for Temperature Sensor to be ready
    ldr     r2, =ADC_BASE               @ ADC Register base value
    ldr     r1, [r2, #ADC_CS_OFFSET]    @ Read the bits at the correct offset
    movs    r0, #1                      @ Decimal 256 indicates it is enabled
    lsls    r0, #ADC_CS_READY_LSB       @ 256 in hexadecimal
    ands    r1, r0                      @ Compares the value in Register to default Disabled
    beq     wait_for_ready              @ If equal, the sensor is not ready and we wait
    bx      lr                          @ Branch and exchange with the last instruction in link register

.thumb_func                     @ Required for all interrupt service routines
alrm_isr:
    push    {lr}                          @ Store the link register to the stack as we will call nested subroutines
    ldr     r2, =TIMER_BASE               @ Get the Timer_Base register address
    movs    r1, #1                        @ 1 is the appropriate value to set the alarm
    str     r1, [r2, #TIMER_INTR_OFFSET]  @ Reset the alarm 
    bl      read_temp                     @ Run the subroutine to read temperature from ADC
    pop     {pc}                          @ Pop the link register from the stack to the program counter

read_temp:
    push    {lr}                            @ Store the link register to the stack as we will call nested subroutines
    ldr     r2, =ADC_BASE                   @ ADC Register base value
    ldr     r1, [r2, #ADC_CS_OFFSET]        @ Read the bits at the correct offset
    adds    r1, #ADC_CS_START_ONCE_BITS     @ Set the temperature sensor to read once again 
    str     r1, [r2, #ADC_CS_OFFSET]        @ Store the bits in teh ADC CS Register

wait_for_ready1:
    ldr     r2, =ADC_BASE                   @ ADC Register base value
    ldr     r1, [r2, #ADC_CS_OFFSET]        @ Read the bits at the correct offset
    movs    r0, #1                          @ Decimal 256 indicates it is enabled
    lsls    r0, #ADC_CS_READY_LSB           @ 256 in hexadecimal
    ands    r1, r0                          @ Compares the value in Register to default Disabled
    beq     wait_for_ready1                 @ If Ready bit is 1, wait more for Temperature Sensor to be ready
    ldr     r0, [r2, #ADC_RESULT_OFFSET]    @ Read the raw ADC voltage from the register
    ldr     r2, =pointer                    @ Load address of pointer
    ldr     r1, [r2]                        @ Load the address we passed as a pointer to arm
    str     r0, [r1]                        @ r0 has the raw ADC voltage value
    bl      calc_temperature                @ Call the C function to calculate the temperature in celcius    
    pop     {pc}                            @ Pop the link register from the stack to the program counter
    
@ Set data alignment
.data
    .align 4
    ltimer:         .word   ALARM_TIME @ Stores the current alarm time
    pointer:        .word              @ Stores the address of the parameter passed to ARM