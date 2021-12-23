TwoMHz: .long 2000000
.section .vectors, "ax"
B _start // reset vector
B SERVICE_UND // undefined instruction vector
B SERVICE_SVC // software interrrupt vector
B SERVICE_ABT_INST // aborted prefetch vector
B SERVICE_ABT_DATA // aborted data vector
.word 0 // unused vector
B SERVICE_IRQ // IRQ interrupt vector
B SERVICE_FIQ // FIQ interrupt vector
.text
.global _start
_start:
/* Set up stack pointers for IRQ and SVC processor modes */
MOV R1, #0b11010010 // interrupts masked, MODE = IRQ
MSR CPSR_c, R1 // change to IRQ mode
LDR SP, =0xFFFFFFFF - 3 // set IRQ stack to A9 onchip memory
/* Change to SVC (supervisor) mode with interrupts disabled */
MOV R1, #0b11010011 // interrupts masked, MODE = SVC
MSR CPSR, R1 // change to supervisor mode
LDR SP, =0x3FFFFFFF - 3 // set SVC stack to top of DDR3 memory
BL CONFIG_GIC // configure the ARM GIC
BL ARM_TIM_CONFIG_ASM
BL enable_PB_INT_ASM
// write to the pushbutton KEY interrupt mask register
LDR R0, =0xFF200050 // pushbutton KEY base address
MOV R1, #0xF // set interrupt mask bits
STR R1, [R0, #0x8] // interrupt mask register (base + 8)
// enable IRQ interrupts in the processor
MOV R0, #0b01010011 // IRQ unmasked, MODE = SVC
MSR CPSR_c, R0
IDLE:
	mov r11, #10
	ldr r0, PB_int_flag
	cmp r0, #1
	beq TIMER_START
CONTINUE1:
	cmp r0, #2
	beq TIMER_STOP
CONTINUE2:
	cmp r0, #4
	beq TIMER_RESET
CONTINUE3:
	ldr r4, tim_int_flag
	cmp r4, #1
	addeq r12, r12, #1
	ldr r4, =tim_int_flag
	mov r0, #0
	str r0, [r4, #0]
	cmp r12, #10
	addeq r6, r6, #1
	moveq r12, #0 
	cmp r6, #10
	addeq r7, r7, #1
	moveq r6, #0
	cmp r7, #10
	addeq r8, r8, #1
	moveq r7, #0
	muleq r1, r11, r8
	push {r1-r12,lr}
	bl UpdateHex0123
	pop {r1-r12,lr}
	cmp r1, #60
	addeq r9, r9, #1
	moveq r8, #0
	moveq r1, #10
	moveq r7, #0
	cmp r9, #10
	addeq r10, #1
	moveq r9, #0
	push {r0, r1-r12,lr}
	bl UpdateHex45
	pop {r0, r1-r12,lr}

	b IDLE
/* Define the exception service routines */
/*--- Undefined instructions --------------------------------------------------*/
SERVICE_UND:
	B SERVICE_UND
/*--- Software interrupts -----------------------------------------------------*/
SERVICE_SVC:
	B SERVICE_SVC
/*--- Aborted data reads ------------------------------------------------------*/
SERVICE_ABT_DATA:
	B SERVICE_ABT_DATA
/*--- Aborted instruction fetch -----------------------------------------------*/
SERVICE_ABT_INST:
	B SERVICE_ABT_INST
/*--- IRQ ---------------------------------------------------------------------*/
SERVICE_IRQ:
	PUSH {R0-R7, LR}
/* Read the ICCIAR from the CPU Interface */
	LDR R4, =0xFFFEC100
	LDR R5, [R4, #0x0C] // read from ICCIAR
INTERRUPT_ID_CHECK:
	cmp r5, #29 
	bne Pushbutton_Check
	bl ARM_TIM_ISR
	b EXIT_IRQ
Pushbutton_Check:
	CMP R5, #73
UNEXPECTED:
	BNE UNEXPECTED // if not recognized, stop here
	BL KEY_ISR
EXIT_IRQ:
/* Write to the End of Interrupt Register (ICCEOIR) */
	STR R5, [R4, #0x10] // write to ICCEOIR
	POP {R0-R7, LR}
	SUBS PC, LR, #4
/*--- FIQ ---------------------------------------------------------------------*/
SERVICE_FIQ:
	B SERVICE_FIQ
.global CONFIG_GIC
CONFIG_GIC:
PUSH {LR}
/* To configure the FPGA KEYS interrupt (ID 73):
* 1. set the target to cpu0 in the ICDIPTRn register
* 2. enable the interrupt in the ICDISERn register */
/* CONFIG_INTERRUPT (int_ID (R0), CPU_target (R1)); */
MOV R0, #73 // KEY porta (Interrupt ID = 73)
MOV R1, #1 // this field is a bit-mask; bit 0 targets cpu0
BL CONFIG_INTERRUPT
MOV R0, #29 // KEY porta (Interrupt ID = 29)
MOV R1, #1 // this field is a bit-mask; bit 0 targets cpu0
BL CONFIG_INTERRUPT
/* configure the GIC CPU Interface */
LDR R0, =0xFFFEC100 // base address of CPU Interface
/* Set Interrupt Priority Mask Register (ICCPMR) */
LDR R1, =0xFFFF // enable interrupts of all priorities levels
STR R1, [R0, #0x04]
/* Set the enable bit in the CPU Interface Control Register (ICCICR).
* This allows interrupts to be forwarded to the CPU(s) */
MOV R1, #1
STR R1, [R0]
/* Set the enable bit in the Distributor Control Register (ICDDCR).
* This enables forwarding of interrupts to the CPU Interface(s) */
LDR R0, =0xFFFED000
STR R1, [R0]
POP {PC}	
/*
* Configure registers in the GIC for an individual Interrupt ID
* We configure only the Interrupt Set Enable Registers (ICDISERn) and
* Interrupt Processor Target Registers (ICDIPTRn). The default (reset)
* values are used for other registers in the GIC
* Arguments: R0 = Interrupt ID, N
* R1 = CPU target
*/
CONFIG_INTERRUPT:
PUSH {R4-R5, LR}
/* Configure Interrupt Set-Enable Registers (ICDISERn).
* reg_offset = (integer_div(N / 32) * 4
* value = 1 << (N mod 32) */
LSR R4, R0, #3 // calculate reg_offset
BIC R4, R4, #3 // R4 = reg_offset
LDR R2, =0xFFFED100
ADD R4, R2, R4 // R4 = address of ICDISER
AND R2, R0, #0x1F // N mod 32
MOV R5, #1 // enable
LSL R2, R5, R2 // R2 = value
/* Using the register address in R4 and the value in R2 set the
* correct bit in the GIC register */
LDR R3, [R4] // read current register value
ORR R3, R3, R2 // set the enable bit
STR R3, [R4] // store the new register value
/* Configure Interrupt Processor Targets Register (ICDIPTRn)
* reg_offset = integer_div(N / 4) * 4
* index = N mod 4 */
BIC R4, R0, #3 // R4 = reg_offset
LDR R2, =0xFFFED800
ADD R4, R2, R4 // R4 = word address of ICDIPTR
AND R2, R0, #0x3 // N mod 4
ADD R4, R2, R4 // R4 = byte address in ICDIPTR
/* Using register address in R4 and the value in R2 write to
* (only) the appropriate byte */
STRB R1, [R4]
POP {R4-R5, PC}
/*************************************************************************
* Pushbutton - Interrupt Service Routine
*
* This routine checks which KEY has been pressed. It writes to HEX0
************************************************************************/
.global KEY_ISR
PB_int_flag:
	.word 0x0
KEY_ISR:
LDR R0, =0xFF200050 // base address of pushbutton KEY port
LDR R1, [R0, #0xC] // read edge capture register
ldr r3, =PB_int_flag
str r1, [r3, #0]
MOV R2, #0xF
STR R2, [R0, #0xC] // clear the interrupt
END_KEY_ISR:
BX LR
.global ARM_TIM_ISR
tim_int_flag:
	.word 0x0
ARM_TIM_ISR:
ldr r2, =#0xFFFEC600
ldr r1, [r2, #12]
ldr r3, =tim_int_flag
str r1, [r3, #0]
mov r1, #0xF
str r1, [r2, #12]
END_TIM_ISR:
bx lr
enable_PB_INT_ASM:
	push {r0, r1, lr}
	LDR R1, =#0xFF200058
	MOV R0, #0xF
	STR R0, [R1]
	pop {r0, r1, pc}
ARM_TIM_CONFIG_ASM:
	push {r0,r2,r3,lr}
	ldr r0, TwoMHz
	ldr r2, =#0xFFFEC600 
	str r0, [r2, #0]
	ldr r3, =#0xFF200050
	pop {r0,r2,r3,pc}
TIMER_START: 
	push {r1,r2}
	ldr r2, =#0xFFFEC600
	mov r1, #7 //Configuration bits for start
	str r1, [r2, #8]
	ldr r2, =PB_int_flag
	mov r1, #0
	str r1, [r2, #0]
	pop {r1,r2}
	b CONTINUE1

TIMER_STOP: 
	push {r1,r2}
	ldr r2, =#0xFFFEC600
	mov r1, #0 //Configuration bits for stop
	str r1, [r2, #8]
	ldr r2, =PB_int_flag
	mov r1, #0
	str r1, [r2, #0]
	pop {r1,r2}
	b CONTINUE2

TIMER_RESET:
	push {r1,r2}
	mov r12, #0
	mov r6, #0
	mov r7, #0
	mov r8, #0
	mov r9, #0
	mov r10, #0
	ldr r2, =PB_int_flag
	mov r1, #0
	str r1, [r2, #0]
	pop {r1,r2}
	b CONTINUE3

UpdateHex0123:
	push {r2, r5, r10, r11}
	mov r0, #0
	mov r11, #0
	mov r3, #1
	mov r5, r12
	push {lr}
	bl ConvertEncoding
	pop { lr}
	mov r3, #0x100
	mov r5, r6
	push { lr}
	bl ConvertEncoding
	pop {lr}
	ldr r3, =#0x10000
	mov r5, r7
	push { lr}
	bl ConvertEncoding
	pop { lr}
	ldr r3, =#0x1000000
	mov r5, r8
	push { lr}
	bl ConvertEncoding
	pop { lr}
	ldr r3, =#0xff200020
	str r0, [r3, #0]
	pop {r2,r5, r10, r11}
	bx lr
ConvertEncoding:
	push {r9, r10}
	cmp r5, #0
	moveq r10, #63
	cmp r5, #1
	moveq r10, #6
	cmp r5, #2
	moveq r10, #91
	cmp r5, #3
	moveq r10, #79
	cmp r5, #4
	moveq r10, #102
	cmp r5, #5
	moveq r10, #109
	cmp r5, #6
	moveq r10, #125
	cmp r5, #7
	moveq r10, #7
	cmp r5, #8
	moveq r10, #127
	cmp r5, #9
	moveq r10, #111
	mul r9, r10, r3
	add r0, r0, r9
	pop {r9, r10}
	bx lr

UpdateHex45:
	push {r5, r9, r10, r11}
	mov r0, #0
	mov r3, #1
	push {lr}
	bl ConvertEncoding2
	pop {lr}
	mov r3, #0x100
	mov r9, r10
	push {lr}
	bl ConvertEncoding2
	pop {lr}
	ldr r3, =#0xff200030
	str r0, [r3, #0]
	pop {r5, r9, r10, r11}
	bx lr

ConvertEncoding2:
	push {r5, r6}
	cmp r9, #0
	moveq r5, #63
	cmp r9, #1
	moveq r5, #6
	cmp r9, #2
	moveq r5, #91
	cmp r9, #3
	moveq r5, #79
	cmp r9, #4
	moveq r5, #102
	cmp r9, #5
	moveq r5, #109
	cmp r9, #6
	moveq r5, #125
	cmp r9, #7
	moveq r5, #7
	cmp r9, #8
	moveq r5, #127
	cmp r9, #9
	moveq r5, #111
	mul r6, r5, r3
	add r0, r0, r6
	pop {r5, r6}
	bx lr


.end