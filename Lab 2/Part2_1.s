TwoMHz: .long 200000000
.global _start
_start:
	ldr r0, TwoMHz //The load value
	
	ldr r2, =#0xFFFEC600
	mov r5, #1 //count value
	mov r4, #1 //used to write into the F value
	mov r11, #1
	mov r12, #10
ARM_TIM_config_ASM:
	str r0, [r2, #0]
	mov r0, #0 //Used to get the returned F value
	ldr r3, =#0xFF200050
	mov r1, #3 //Configuration bits for start
	str r1, [r2, #8]
MAIN:
	cmp r0, #1
	bl ARM_TIM_read_INT_ASM
	cmp r0, #1
	addeq r5, r5, #1
	cmp r5, #15
	moveq r5, #0
	push {r0-r12,lr}
	bl UpdateHex0
	pop {r0-r12,lr}
	cmp r0, #1
	beq ARM_TIM_clear_INT_ASM
	b MAIN

ARM_TIM_read_INT_ASM:
	push {lr}
	ldr r0, [r2, #12]
	pop {pc}
ARM_TIM_clear_INT_ASM:
	push {lr}
	str r11, [r2, #12]
	b MAIN
	pop {pc}
UpdateHex0:
	push {r5, r9, r10, r11}
	mov r0, #0
	mov r3, #1
	mov r9, r5
	push {lr}
	bl ConvertEncoding
	pop {lr}
	ldr r3, =#0xff200020
	str r0, [r3, #0]
	pop {r5, r9, r10, r11}
	bx lr

ConvertEncoding:
	push {r5, r6}
	cmp r9, #0
	moveq r5, #113
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
	cmp r9, #10
	moveq r5, #119
	cmp r9, #11
	moveq r5, #124
	cmp r9, #12
	moveq r5, #57
	cmp r9, #13
	moveq r5, #94
	cmp r9, #14
	moveq r5, #121
	mul r6, r5, r3
	add r0, r0, r6
	pop {r5, r6}
	bx lr