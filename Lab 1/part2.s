.global _start
_start:
array:
        .int   5
        .int   6
        .int   7   
        .int   8
		mov r5, #4 //size of array = 4, (n)
		mov r4, #0 //initialize log2_n
		ldr r3, =array //initialize ptr, load array's base address into it
		mov r1, #0 //initialize tmp
		mov r0, #1 //initialize norm
		mov r2, #100 //initialize cnt
		mov r7, #0 //initialize a temporary variable
		mov r6, #0 //initialize i
WHILELOOP: //calculate log2_n
		mov r7, #1
		lsl r7, r7, r4
		cmp r7, r5
		bge ENDWHILELOOP
		add r4, r4, #1
		b WHILELOOP
ENDWHILELOOP:
		mov r1, #0
FORLOOP:
		
		cmp r6, r5
		bge ENDFORLOOP
		ldr r7, [r3]
		mla r1, r7, r7, r1 //tmp += (*ptr)*(*ptr)
		add r3, r3, #4
		add r6, r6, #1 //i++
		b FORLOOP
ENDFORLOOP:
		asr r1, r1, r4
//start of sqrtiter
LOOP:   
		cmp r6, r2
		bge ENDLOOP //check if i>=cnt if so end the loop
		mul r3, r0, r0
		sub r3, r3, r1
		mul r3, r3, r0
		asr r3, r3, #10
		cmp r3, #2
		ble ELSE // check if step <= t if so end if and switch to else (if)
		mov r3, #2
		sub r0, r0, r3
		add r6, r6, #1 //i++
		b LOOP
ENDLOOP:
		b end
end:
		b end
ELSE:
		cmp r3, #-2
		bge ELSE2
		mov r3, #0
		sub r3, #2
		sub r0, r0, r3
		add r6, r6, #1 //i++
		b LOOP
ELSE2:
		sub r0, r0, r3
		add r6, r6, #1 //i++
		b LOOP