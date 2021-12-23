RESULT: .space 4
.global _start
_start: mov r1, #168 //a
		mov r0, #1 //xi
		mov r2, #100 //cnt (k=10, t=2)
		mov r6, #0 //initialize i
		mov r3, #0 //initialize step
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
		str r0, RESULT
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

		
		
		
		
		
		
		

		
	   	
	
	