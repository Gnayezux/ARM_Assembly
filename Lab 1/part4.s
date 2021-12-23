.global _start
_start:
		
array:
		.int 4
		.int 2
		.int 1
		.int 4
		mov r0, #16
		mov r1, #0
		sub r1, r1, #1
		ldr r2, =array
		add r0, r0, r2
		str r1, [r0] //unknow bug preventing loading -1 as the fifth element of array
		//thus mannualy writing -1 to array[4]'s address
		
		mov r0, #5 // initialize n, set to 5 (size of array)
		ldr r1, =array //initialize r1 and set array's base address to it. 
		mov r11, #0 //initialize ptr+i
		mov r6, #0 //initialize i
		mov r8, #0 //initialize j
		mov r7, #0 //initialize the temporary variable 1
		mov r9, #4 //initialize temporary variable 2 (now used as indicator
		//for one memory address shift (#4)
		mov r2, #0 //initialize tmp
		mov r3, #0 //initialize cur_min_idx
		mov r4, #0 //initialize ptr+j
		mov r10, #0 //initialize ptr+ cur_min_idx
		mov r5, #0 //initialize another temporary variable
		sub r7, r0, #1 //set temporary variable = n-1 used for outer loop
OUTERLOOP:
		cmp r6, r7
		bge end
		mla r11, r9, r6, r1
		ldr r2, [r11] //tmp = *(ptr+i)
		mov r3, r6 //cur_min_idx = i
		add r8, r6, #1 //j= i=1
INNERLOOP:
		cmp r8, r0
		bge ENDINNERLOOP
		mla r4, r9, r8, r1
		ldr r5, [r4]
		cmp r2, r5
		ble SKIPIF
		mov r2, r5
		mov r3, r8
SKIPIF:
		add r8, r8, #1 //j++
		b INNERLOOP
ENDINNERLOOP:
		mla r10, r3, r9, r1
		ldr r2, [r11] //tmp = *(ptr+i)
		ldr r5, [r10]
		str r5, [r11]
		str r2, [r10]
		add r6,r6, #1 //i++
		b OUTERLOOP
end:
		b end