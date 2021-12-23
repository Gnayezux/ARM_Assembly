.global _start
_start:
array:
		.int 3
		.int 4
		.int 5
		.int 4
		mov r0, #4 //set r0 as n which is 4
		mov r1, #0 //initialize mean as 0
		mov r2, #0 //initialize pointer ptr
		mov r3, #0 //initialize log2_n
		mov r7, #0 //initialize a temporary variable
WHILELOOP: //calculate log2_n
		mov r7, #1
		lsl r7, r7, r3
		cmp r7, r0
		bge ENDWHILELOOP
		add r3, r3, #1
		b WHILELOOP
ENDWHILELOOP:
		mov r1, #0
		mov r6, #0 //initialize i in the for loop
		ldr r2, =array //load array's memory base address into it
FORLOOP1:
		cmp r6, r0
		bge ENDFORLOOP1
		ldr r7, [r2]
		add r1, r1, r7
		add r2, #4
		add r6, r6, #1
		b FORLOOP1
ENDFORLOOP1:
		asr r1, r1, r3
		ldr r2, =array //load array's memory base address into it
		mov r6, #0 //initialize i in the for loop
FORLOOP2:
		cmp r6, r0
		bge end
		ldr r7, [r2]
		sub r7, r7, r1
		str r7, [r2]
		add r2, r2, #4
		add r6, r6, #1 //i++
		b FORLOOP2
end:
		b end