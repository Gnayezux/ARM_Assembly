//Name: Zeyang Xu, Student ID: 260923070
.global _start
_start:
        bl      input_loop
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



read_PS2_data_ASM:
	push {r4,r5}
	ldr r4, =0xff200100
	ldr r5, [r4, #0]
	mov r5, r5, LSR #15
	and r5, r5, #0x1
	cmp r5, #1
	movne r0, r5
	popne {r4, r5}
	bxne lr
	ldrb r5, [r4, #0]
	strb r5, [r0, #0]
	mov r0, #1
	pop {r4, r5}
	bx lr
	
	

write_hex_digit:
        push    {r4, lr}
        cmp     r2, #9
        addhi   r2, r2, #55
        addls   r2, r2, #48
        and     r2, r2, #255
        bl      VGA_write_char_ASM
        pop     {r4, pc}
write_byte:
        push    {r4, r5, r6, lr}
        mov     r5, r0
        mov     r6, r1
        mov     r4, r2
        lsr     r2, r2, #4
        bl      write_hex_digit
        and     r2, r4, #15
        mov     r1, r6
        add     r0, r5, #1
        bl      write_hex_digit
        pop     {r4, r5, r6, pc}
input_loop:
        push    {r4, r5, lr}
        sub     sp, sp, #12
        bl      VGA_clear_pixelbuff_ASM
        bl      VGA_clear_charbuff_ASM
        mov     r4, #0
        mov     r5, r4
        b       .input_loop_L9
.input_loop_L13:
        ldrb    r2, [sp, #7]
        mov     r1, r4
        mov     r0, r5
        bl      write_byte
        add     r5, r5, #3
        cmp     r5, #79
        addgt   r4, r4, #1
        movgt   r5, #0
.input_loop_L8:
        cmp     r4, #59
        bgt     .input_loop_L12
.input_loop_L9:
        add     r0, sp, #7
        bl      read_PS2_data_ASM
        cmp     r0, #0
        beq     .input_loop_L8
        b       .input_loop_L13
.input_loop_L12:
        add     sp, sp, #12
        pop     {r4, r5, pc}
