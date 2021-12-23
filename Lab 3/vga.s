//Name: Zeyang Xu, Student ID: 260923070
.global _start
_start:


        bl      draw_test_screen
end:
        b       end

VGA_clear_pixelbuff_ASM:
	ldr r10, =0xc8000000
	mov r11, #160
	mov r12, #240
	ldr r1, =0x00000000
	str r1, [r10, r9]
	add r9, r9, #4
	add r4, r4, #1
	cmp r4, r11
	moveq r4, #0
	addeq r8, r8, #1024
	moveq r9, r8
	addeq r5, r5, #1
	cmp r5, r12
	blt VGA_clear_pixelbuff_ASM
	beq back
back:
	mov r10, #0
	mov r5, #0
	mov r8, #0
	mov r9, #0
	mov r11, #0
	mov r3, #0
	mov r12, #0
	mov r4, #0
	bx lr


VGA_draw_point_ASM:
	push {r4, r9, r10}
	ldr r10, =0xc8000000
	mov r4, #1024
	mul r4, r4, r1
	mov r9, #2
	mul r9, r9, r0
	add r4, r4, r9
	strH r2, [r10, r4]
	pop {r4, r9, r10}
	bx lr

VGA_write_char_ASM:
	push {r4,r5, r6, r7, r8,r9, r10, r11}
	mov r11, #256
	ldr r10, =0xc9000000
	mov r4, #128
	mul r4, r4, r1
	mov r6, r0, ASR #2
	mov r7, r6, ASL #2
	add r4, r4, r7
	sub r7, r0, r7
	mov r6, r6, ASL #2
	mov r8, r7, ASR #1
	mov r3, r8, ASL #1
	add r4, r4, r3
	mov r9, r8, ASL #1
	sub r9, r7, r9
	cmp r9, #1
	muleq r2, r11, r2
	ldrH r5, [r10, r4]
	mov r6, r5, ASR #8
	sub r7, r5, r6
	addeq r2, r2, r7
	addne r2, r2, r6
	strH r2, [r10, r4]
	pop {r4,r5, r6, r7, r8,r9, r10, r11}
	bx lr

VGA_clear_charbuff_ASM:
	ldr r10, =0xc8000000
	mov r11, #20
	mov r12, #60
	ldr r1, =0x00000000
	str r1, [r10, r9]
	add r9, r9, #4
	add r4, r4, #1
	cmp r4, r11
	moveq r4, #0
	addeq r8, r8, #128
	moveq r9, r8
	addeq r5, r5, #1
	cmp r5, r12
	blt VGA_clear_charbuff_ASM
	beq back


draw_test_screen:
        push    {r4, r5, r6, r7, r8, r9, r10, lr}
        bl      VGA_clear_pixelbuff_ASM
        bl      VGA_clear_charbuff_ASM
        mov     r6, #0
        ldr     r10, .draw_test_screen_L8
        ldr     r9, .draw_test_screen_L8+4
        ldr     r8, .draw_test_screen_L8+8
        b       .draw_test_screen_L2
.draw_test_screen_L7:
        add     r6, r6, #1
        cmp     r6, #320
        beq     .draw_test_screen_L4
.draw_test_screen_L2:
        smull   r3, r7, r10, r6
        asr     r3, r6, #31
        rsb     r7, r3, r7, asr #2
        lsl     r7, r7, #5
        lsl     r5, r6, #5
        mov     r4, #0
.draw_test_screen_L3:
        smull   r3, r2, r9, r5
        add     r3, r2, r5
        asr     r2, r5, #31
        rsb     r2, r2, r3, asr #9
        orr     r2, r7, r2, lsl #11
        lsl     r3, r4, #5
        smull   r0, r1, r8, r3
        add     r1, r1, r3
        asr     r3, r3, #31
        rsb     r3, r3, r1, asr #7
        orr     r2, r2, r3
        mov     r1, r4
        mov     r0, r6
        bl      VGA_draw_point_ASM
        add     r4, r4, #1
        add     r5, r5, #32
        cmp     r4, #240
        bne     .draw_test_screen_L3
        b       .draw_test_screen_L7
.draw_test_screen_L4:
        mov     r2, #72
        mov     r1, #5
        mov     r0, #20
        bl      VGA_write_char_ASM
        mov     r2, #101
        mov     r1, #5
        mov     r0, #21
        bl      VGA_write_char_ASM
        mov     r2, #108
        mov     r1, #5
        mov     r0, #22
        bl      VGA_write_char_ASM
        mov     r2, #108
        mov     r1, #5
        mov     r0, #23
        bl      VGA_write_char_ASM
        mov     r2, #111
        mov     r1, #5
        mov     r0, #24
        bl      VGA_write_char_ASM
        mov     r2, #32
        mov     r1, #5
        mov     r0, #25
        bl      VGA_write_char_ASM
        mov     r2, #87
        mov     r1, #5
        mov     r0, #26
        bl      VGA_write_char_ASM
        mov     r2, #111
        mov     r1, #5
        mov     r0, #27
        bl      VGA_write_char_ASM
        mov     r2, #114
        mov     r1, #5
        mov     r0, #28
        bl      VGA_write_char_ASM
        mov     r2, #108
        mov     r1, #5
        mov     r0, #29
        bl      VGA_write_char_ASM
        mov     r2, #100
        mov     r1, #5
        mov     r0, #30
        bl      VGA_write_char_ASM
        mov     r2, #33
        mov     r1, #5
        mov     r0, #31
        bl      VGA_write_char_ASM
        pop     {r4, r5, r6, r7, r8, r9, r10, pc}
.draw_test_screen_L8:
        .word   1717986919
        .word   -368140053
        .word   -2004318071





	
	
	
	
	