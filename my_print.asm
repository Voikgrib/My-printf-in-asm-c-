;===============================================================;
;		My printf whith %b, %o, %c, %b, %s, %x
;			Author: Vladimir Gribanov
;===============================================================;


SECTION .text 
global my_printf

;===============================================================;
;						MAIN START
;===============================================================;
;RDI RSI RDX RCX R8 R9 

my_printf:
		pop r15
		mov qword [main_ret], r15

		push r9
		push r8
		push rcx
		push rdx
		push rsi
 
		mov qword [str_adr], rdi		; get str_adr

		call uber_printf

kones:		

		mov r15, qword [main_ret]
		push r15

		retn
;==============================================================;
;						MAIN END
;==============================================================;

;========================= MY PRINT ===========================;
;!!	Input:	offset my_string in stack && arg to stack, bp = adr of start args in stack
;!! Exit:	printf string
;!! Destroy:	I don't know what is here!
;!!
;==============================================================;

uber_printf:
		pop rcx
		mov qword [saved_adr], rcx		; save adr of return
		mov  rsi, qword [str_adr]			; get string adr

sycle_start:	
		mov al, [rsi]				; al = *si
		cmp al, 0			   		; 
		je printf_end
				
		cmp al, '%'					; if(is arg?)
		jne dump_print				;

		add rsi, 1					; si++

		mov al, [rsi]				; get symbol after '%'

		mov qword [s_counter], rsi 		; Save counter


		cmp al, 'c'					; ascii +
		jne Next_0				
		pop rcx
		mov [cur_per], rcx
		mov rcx, cur_per
		mov rax, 4  	; rax = 1
		mov rbx, 1		; where write? (in terminal)
		mov rdx, 1		; len of write
		int 80h
		jmp Next_5

Next_0:			
		cmp rax, 'd'					; 10-rich 	+-
		jne Next_1			
		pop rcx
		mov qword [cur_per], rcx	
		call T_create
		jmp Next_5

Next_1:	
		cmp rax, 'o'					; 8-rich 	+
		jne Next_2
		pop rcx
		mov qword [cur_per], rcx
		call E_create
		jmp Next_5

Next_2:
		cmp rax, 'b'					; binary 	+
		jne Next_3
		pop rcx
		mov qword [cur_per], rcx
		call B_create
		jmp Next_5

Next_3:	
		cmp rax, 'x'					; 16-rich 	+	
		jne Next_4
		pop rcx
		mov qword [cur_per], rcx
		call H_create
		jmp Next_5

Next_4:			
		cmp rax, 's'					; string	+
		jne Next_5		
		pop rcx
		mov qword [arg_str_adr], rcx
		call Printer

Next_5:
		mov rsi, qword [s_counter]			; recower counter
				
							; !-!-!-!-!-!-!-!-!-!-!-!-!-!-!
							; !     many moves with %	  !
							; !-!-!-!-!-!-!-!-!-!-!-!-!-!-!
		jmp end_dump_print

dump_print:
		mov rcx, rsi
		mov rax, 4  	; rax = 1
		mov rbx, 1		; where write? (in terminal)
		mov rdx, 1		; len of write
		int 80h

end_dump_print:								

		add rsi, 1					; si++
		jmp sycle_start


printf_end:
		mov rcx, qword [saved_adr]
		push rcx					; return of saved adr 
		
		ret
;====================== ascii --> 10-razr ===============================;
;!! Input:	cur_per = curren peremennaya, bx = adress in videoseg
;!!	Exit:	bx = end of printf
;!!	Destroy:	ax, bx, dx, si
;========================================================================;
;rdx:rax / rbx = rax (ost. rdx)

T_create:

		xor r13, r13
		
		mov rax, qword [cur_per]					; Get symbol
		mov rbx, 0ah			

T_start:
		xor rdx, rdx
		mov rbx, 0ah
		div rbx								; Get fir cifra

		cmp rax, 0h							; if end of num
		je T_end							; break

		add [ten], rdx
		mov r14, qword [ten]
		shl r14, 3
		add r14, [ten]
		add r14, [ten]
		mov qword [ten], r14
											; push nums into stack
		jmp T_start
T_end:		

		add [ten], rdx
		mov r14, qword [ten]
		shl r14, 3
		add r14, [ten]
		add r14, [ten]
		mov qword [ten], r14 
		
;----------

		mov rax, qword [ten]					; Get symbol
		

T_1start:
		xor rdx, rdx
		mov rbx, 0ah
		div rbx								; Get fir cifra

		cmp rax, 0h							; if end of num
		je T_1end							; break

		mov qword [cur_per], rax

		cmp r13, 0
		je T_fir_per

		add rdx, '0'
		mov qword [cur_byte], rdx
		mov rcx, cur_byte
		mov rax, 4  	; rax = 4
		mov rbx, 1		; where write? (in terminal)
		mov rdx, 1		; len of write
		int 80h

T_fir_per:
		mov r13, 1488
											; push nums into stack

		mov rax, qword [cur_per]

		jmp T_1start
T_1end:		

;----------

		add rdx, '0'
		mov qword [cur_byte], rdx
		mov rcx, cur_byte
		mov rax, 4  	; rax = 4
		mov rbx, 1		; where write? (in terminal)
		mov rdx, 1		; len of write
		int 80h

		ret


		
;========================= ascii --> binary =============================;
;!! Input:	cur_per = curren peremennaya, bx = adress in videoseg
;!!	Exit:	bx = end of printf
;!!	Destroy:	rbx, rdx, r10
;========================================================================;

B_create:
		pop rcx
		mov qword [local_ret], rcx

		xor rbx, rbx
		xor r13, r13
		xor r14, r14
	


B_start:	
		xor rdx, rdx
		or rdx, 10000000000000000000000000000000b
		and rdx, qword [cur_per]
		shr rdx, 63
		mov rcx, qword [cur_per]
		shl rcx, 1					; Get the leftest bit
		mov qword [cur_per], rcx

		add rdx, '0'
		mov qword [cur_byte], rdx

		cmp rdx, '0'					; Super flag
		je B_nend_print
		mov r14, 1
B_nend_print:
		cmp r14, 0
		je B_end_print					; Super flag
		
		mov rcx, cur_byte
		mov rax, 4  	; rax = 1
		mov rbx, 1		; where write? (in terminal)
		mov rdx, 1		; len of write
		int 80h

B_end_print:

		add r13, 1
		cmp r13, 64							; do it again
		jne B_start


		mov rcx, qword [local_ret]
		push rcx					; return of saved adr 
	
		ret

;====================== ascii --> 8-razr (cur_per = symbol) ===============;
;!! Input:	cur_per = current peremennaya, bx = where printf
;!!	Exit:	bx = end of printf
;!!	Destroy:	rbx, rdx, rax
;!!
;==========================================================================;

E_create:
		xor r13, r13
		xor r14, r14

E_start:	add bx, 2
		xor ax, ax
		xor dx, dx

		cmp r13, 0
		je E_fir
		or rdx, 11100000000000000000000000000000b
		and rdx, [cur_per]
		shr rdx, 61
		mov rcx, qword [cur_per]
		shl rcx, 3					; Pick 3 bits
		mov qword [cur_per], rcx
		jmp E_calc		

E_fir:		
		or rdx, 10000000000000000000000000000000b
		and rdx, [cur_per]
		shr rdx, 63
		mov rcx, qword [cur_per]
		shl rcx, 1					; Pick 2 left bits
		mov qword [cur_per], rcx
E_calc:

		add rdx, '0'
		mov qword [cur_byte], rdx

		cmp rdx, '0'					; Super flag
		je E_nend_print
		mov r14, 1
E_nend_print:
		cmp r14, 0
		je E_end_print					; Super flag

		mov rcx, cur_byte
		mov rax, 4  	; rax = 1
		mov rbx, 1		; where write? (in terminal)
		mov rdx, 1		; len of write
		int 80h
	
E_end_print:	

		add r13, 1
		cmp r13, 22
		jne E_start							; -2 hour of my life

		ret
;======================== ascii --> h DECLARE (cx = accii) =================;
;!!	input:	cur_per = accii	bx = start of print
;!!	exit:	bx = end of printf
;!!	Destroy:	rbx, dx, ax
;===========================================================================;

H_create:	

		xor r13, r13
		xor r14, r14

H_start:	
		xor rdx, rdx							; dx = 0
		mov rax, qword [cur_per]
		or rdx, 11110000000000000000000000000000b					
											; -2 chasa zisny na otladky
		and rdx, rax						; get last 4 bits from al
		shl rax, 4							; move to next 4 bits in al
		shr rdx, 60							; dl looks like "0000 xxxx"	

		mov qword [cur_per], rax	

		cmp rdx, 0					; Super flag
		je H_nend_print
		mov r14, 1
H_nend_print:
		cmp r14, 0
		je H_end					; Super flag		

		cmp rdx, 10							; is num or letter?
		jb H_num

		add rdx, 'A'							; if dl >= 10
		sub rdx, 10
		mov qword [cur_byte], rdx
		
		mov rcx, cur_byte
		mov rax, 4  	; rax = 1
		mov rbx, 1		; where write? (in terminal)
		mov rdx, 1		; len of write
		int 80h

		jmp H_end

H_num:		
		add rdx, '0'						; if dl < 10
		mov qword [cur_byte], rdx		

		mov rcx, cur_byte
		mov rax, 4  	; rax = 1
		mov rbx, 1		; where write? (in terminal)
		mov rdx, 1		; len of write
		int 80h

H_end:		
		add r13, 1
		cmp r13, 16
		jne H_start

		ret

;========================== PRINT DECLARE ==============================;
;!!	Entry	arg_str_adr = offset str
;!!	Exit	bx = adr end of printf
;!!		cx = start of printf
;!!	Destroy	dl, ax, si
;=======================================================================;

Printer:	
		mov rsi, qword [arg_str_adr]
Next:	
		mov al, [rsi]					; al = si*
		add rsi, 1

		cmp al, 0							; if(al == '$')
		je End_t							;   jump End_t

		mov qword [cur_byte], rax

		mov rcx, cur_byte
		mov rax, 4  	; rax = 1
		mov rbx, 1		; where write? (in terminal)
		mov rdx, 1		; len of write
		int 80h		

		cmp al, 0
		jne Next							; while end

End_t:		add dx, 2
			ret


;--------------------------------------------------------------;
;						MEMORY PART					 
;--------------------------------------------------------------;

SECTION .data

arg_str_adr		dq	0

str_adr			dq	0
saved_adr		dq	0
local_ret		dq	0

s_bp			dq	0
s_counter		dq	0
cur_per			dq  '4'
cur_byte		dq	0
ten				dq  0

main_ret		dq  0



