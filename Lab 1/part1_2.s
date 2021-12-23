.global _start
_start: mov r1, #168 //a
		mov r0, #1 //xi
		mov r2, #100 //cnt (k=10, t=2)
		
sqrtRecur:
		mov r3, #0 //initialize grad
		cmp r2, #0
		beq END
		mul r3, r0, r0
		sub r3, r3, r1
		mul r3, r3, r0
		asr r3, r3, #10
		cmp r3, #2
		ble ELSE // check if grad <= t if so end if and switch to else (if)
		mov r3, #2
ELSE:
		cmp r3, #-2
		bge ELSE2
		mov r3, #0
		sub r3, #2 //grad = -t = -2


ELSE2:
		sub r0, r0, r3 //xi = xi-grad
		sub r2, #1 //cnt-1
		push {r0-r3, lr}
		bl sqrtRecur
		pop {r0-r3, lr}
		bx lr
END:
		b end
end:
		b end
		



		

	
	