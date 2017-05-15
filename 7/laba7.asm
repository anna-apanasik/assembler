.model smoll       
.stack 100h
.data

path db 128 dup(0)
EPB dw 0000
    dw offset commandline,0
    dw 005Ch,0,006Ch,0
commandline db 125
    db "/?"
command_text db 122 dup(?)  
ERROR db "error$"
number_rep db 3 dup(0)
num dw 0             
error_path db " path",'$' 
error_memory db " memory"
.code   
output macro str      
    push dx
    push ax
    lea dx, str
    mov ah, 09h
    int 21h
    pop ax 
    pop dx
endm

  newline macro                  
    push dx
    push ax
    mov dl, 13                 
    mov ah, 02h
    int 21h
    mov dl, 10                 
    int 21h
    pop ax
    pop dx
  endm   
  
 proc show_error
    pusha 
    newline
    lea dx,ERROR
    mov ah,9
    int 21h
    popa
ret
show_error endp 
    
get_name proc
  pusha
  xor cx, cx
  mov cl, es:[80h] 
  cmp cl, 0
  je end_get_name
  mov di, 82h      
  lea si, path
cicle1:
  mov al, es:[di]                                                              
  cmp al, 0Dh
  je end_get_name
  cmp al,' '
  je numb
  mov [si], al
  inc di
  inc si
  jmp cicle1
numb:
  inc si
  mov [si],'$'
  xor si, si 
  inc di 
  lea si, number_rep  
cicle2:
  mov al, es:[di]
  cmp al, 0Dh
  je end_get_name
  mov [si], al
  inc di
  inc si
  jmp cicle2

baksinend:
  inc si
  mov [si],'$'
  
end_get_name:
  popa
ret
get_name endp        
    
str_dec proc
       push    cx
        push    bx
        push    di
        push    si                   
        
        xor     cx, cx
        xor     bx, bx
        xor     ax, ax
        xor     di, di    
                
        mov si,offset number_rep
        mov bx, 10 
        transfer:     
            mov al,[si]
            sub al,30h
            cbw
            xchg ax,cx
            mul bx 
            add cx,ax
            inc si
            cmp [si],0
        jne transfer 
		mov num,cx
        pop     si
        pop     di
        pop     bx
        pop     cx 
    ret
str_dec endp    
    
start:  
    mov ax,@data
    mov ds,ax  
    
      call get_name 
      call str_dec
       cycle:   
        mov sp,program_lenght+100h+200h
        mov ah,4ah
        stack_shift = program_lenght+100h+200h
        mov bx,stack_shift shr 4+1
        int 21h
        
        mov ax,cs
        mov word ptr EPB+4,ax
        mov word ptr EPB+8,ax
        mov word ptr EPB+0Ch,ax
             mov ax,4B00h
        mov dx,offset path
        mov bx,offset EPB
        int 21h          
        jnc go   
        call show_error
        cmp ax,2
        jne go1:    
          output error_path
        go1:
        cmp ax,8
        jne go2:
        output error_memory
        go2:
        jmp endfun
        go:
      newline        
      sub num,1
      cmp num,0
      jne cycle 
endfun: 
   mov ah,4ch
   int 21h
   program_lenght equ $-start
end start