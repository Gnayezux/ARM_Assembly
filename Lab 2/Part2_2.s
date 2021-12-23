TwoMHz: .long 2000000
.global _start
_start:
	ldr r0, TwoMHz //The load value
	
	ldr r2, =#0xFFFEC600
	mov r5, #0 //count value
	mov r4, #1 //used to write into the F value
	mov r11, #1
	mov r12, #10
ARM_TIM_config_ASM:
	str r0, [r2, #0]
	mov r0, #0 //Used to get the returned F value
	ldr r3, =#0xFF200050


MAIN:
	push {sp, lr}
	bl READ_PUSHBUTTON
	pop {sp, lr}
	cmp r0, #1
	moveq r0, #0xF
	streq r0, [r3, #12]
	beq TIMER_START
CONTINUE1:
	cmp r0, #2
	moveq r0, #0xF
	streq r0, [r3, #12]
	beq TIMER_STOP
CONTINUE2:
	cmp r0, #4
	moveq r0, #0xF
	streq r0, [r3, #12]
	beq TIMER_RESET
CONTINUE3:
	push {sp, lr}
	bl ARM_TIM_read_INT_ASM
	pop {sp, lr}
	cmp r0, #1
	addeq r5, r5, #1
	cmp r5, #10
	addeq r6, r6, #1
	moveq r5, #0 
	cmp r6, #10
	addeq r7, r7, #1
	moveq r6, #0
	cmp r7, #10
	addeq r8, r8, #1
	moveq r7, #0
	muleq r1, r12, r8
	push {r0-r12,lr}
	bl UpdateHex0123
	pop {r0-r12,lr}
	cmp r1, #60
	addeq r9, r9, #1
	moveq r8, #0
	moveq r1, #10
	moveq r7, #0
	cmp r9, #10
	addeq r10, #1
	moveq r9, #0
	push {r0-r12,lr}
	bl UpdateHex45
	pop {r0-r12,lr}

	
	cmp r0, #1
	beq ARM_TIM_clear_INT_ASM
	b MAIN
	
	
READ_PUSHBUTTON:
	ldr r0, [r3, #12]
	bx lr
ARM_TIM_read_INT_ASM:
	ldr r0, [r2, #12]
	bx lr
ARM_TIM_clear_INT_ASM:
	str r11, [r2, #12]
	b MAIN

UpdateHex0123:
	push {r5, r10, r11}
	mov r0, #0
	mov r11, #0
	mov r3, #1
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
	pop {r5, r10, r11}
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

TIMER_START: 
	push {r1}
	mov r1, #3 //Configuration bits for start
	str r1, [r2, #8]
	pop {r1}
	b CONTINUE1

TIMER_STOP: 
	push {r1}
	mov r1, #0 //Configuration bits for start
	str r1, [r2, #8]
	pop {r1}
	b CONTINUE2

TIMER_RESET:
	mov r5, #0
	mov r6, #0
	mov r7, #0
	mov r8, #0
	mov r9, #0
	mov r10, #0
	b CONTINUE3


	
	
	
	
	
	
	