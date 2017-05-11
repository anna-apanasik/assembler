.model small
.stack 1024
.data
filename db 80 dup(0) 
amount db 10 dup ('$') 
buffer db 1024 dup(0) 
msg1 db "Enter length: $"  
msg2 db "Result: $" 
str1 db 10 dup('$')
handle dw 0
amount_for_compare_length dw 10  dup('$') 
current_length_of_string db 0
result dw 0 
flagforcount db 0  
flagforbuffer db 0 
flagforcmd db 0
  
.code
 
; show number from ax on display
; ax - number r=which we want to show    
Input proc        
        push    cx
        push    dx
        push    bx
;  BX - numeral
        xor     bx, bx
        xor     cx, cx
; enter first symbol
        mov     ah, 01h
        int     21h
; Check: we enter minus
        cmp     al, '-'
        jne     wrong_symbol  ; if it isn't minus then go away

        jmp exit_input  ; if it's minus -exit
; Enter next symbol
Next_symbol:  
        mov     ah, 01h
        int     21h

wrong_symbol:   
        cmp     al, 39h         ; If current symbol more than '9', go to Next_line 
        ja      Store_symbol

        sub     al, 30h      ; translate current symbol to number. If we have smth strange then go to  Next_line
        jb      Store_symbol
; Al- nummeral, which we need to add on right in our number
        mov     cl, al     ; move in cl for next action
; multiply current result on 10.
        shl     bx, 1   ; BX = 2 * bx
        mov     ax, bx  ; AX = 2 * bx
        shl     ax, 2   ; AX = 8 * bx
        add     bx, ax  ; BX = 10 * bx
        add     bx, cx  ; BX = 10 * bx + al

        jmp     Next_symbol   ;continue enter numeral
Store_symbol: 
;        call newline   
;        mov ax, bx
        mov [amount_for_compare_length],bx   
exit_input:
        pop     bx
        pop     dx
        pop     cx
        ret
Input endp

Translate proc 
    push ax  
    push bx 
    push cx
    push di
    xor di,di
    xor bx,bx   
    xor  cx, cx    
    
    mov al, amount[di]   ; read first number

    cmp  al, '-' 
    jne  Check     
    jmp en
Next_symbol_for_translate:
     mov al, amount[di] 
Check:
 cmp  al, 0Dh
 je  NoNumber    
 
    cmp  al, 39h         ; If current symbol more than '9', go to Next_line 
    ja   NoNumber
 
    sub al, 30h     ; -30h because need  change ascii  to number 
                    ; if number until '0' in ascii or 'enter' because sub install flags  
    jb NoNumber     ; if < or our occasion SUb install flag,  if symbol != number   
    
; Al- nummeral, which we need to add on right in our number
        mov     cl, al     ; move in cl for next action
; multiply current result on 10.
        shl     bx, 1   ; BX = 2 * bx
        mov     ax, bx  ; AX = 2 * bx
        shl     ax, 2   ; AX = 8 * bx
        add     bx, ax  ; BX = 10 * bx
        add     bx, cx  ; BX = 10 * bx + al 
        inc di
        jmp     Next_symbol_for_translate
NoNumber: 
         mov ax, bx
         mov [amount_for_compare_length],bx
en: 
    pop di
    pop cx
    pop bx
    pop ax  
    ret
Translate endp  

Show_AX proc
        push    ax
        push    bx
        push    cx
        push    dx
        push    di
        mov     cx, 10          ; cx - osnovanie s/s (radix)
        xor     di, di          ; di - amount numeral in number
Conv:
        xor     dx, dx
        div     cx              ; dl = num mod 10
        add     dl, '0'         ; translate in symbol
        inc     di
        push    dx              ; add to stack for store
        or      ax, ax
        jnz     Conv            ; no zero
        ; show out from stack
Show:
        pop     dx              ; dl = current symbol
        mov     ah, 2           
        int     21h
        dec     di              ; repeat while di != 0
        jnz     Show
        pop     di
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        ret
Show_AX endp
         

newline proc
    push dx
    push ax
    mov dl, 0Dh 
    mov ah, 02h
    int 21h
    mov dl, 0Ah
    mov ah, 02h
    int 21h
    pop ax
    pop dx
    ret
newline endp  

;show string
strout macro str
    mov ah, 09h
    lea dx, str
    int 21h
endm  

; name of file for open 
get_name proc 
    push cx
    push di
    push si
    mov di, 80h         ;amount of characters in cmd( 80h is storing current length of cmd) 
    xor cx,cx
    mov cl, es:[di]    ; move to cl amount of symbols in cmd  
    jcxz end_get
    lea si, filename
    mov di, 81h         ; offset of cmd in block of PSP(Program Segment Prefix) (81h is storing all cmd)
cicle:
    mov al, es:[di]   ; move to al current ssymbol from cmd
    cmp [flagforcmd],0
    je skip_first_space
    cmp al, 20h      
    je next_arg
skip_first_space:
    mov [si], al      ; write this symbol in our variable
    mov [flagforcmd],1 
    inc si
    inc di
    loop cicle  
    jmp end_get
next_arg:
    lea si, amount  
    inc di
    jmp cicle
end_get: 
    pop si
    pop di
    pop cx
    ret
get_name endp

; open file  for reading
macro fopen
   mov ah, 3dh        
   mov al, 0           ; mode: read
   lea dx, filename    ; DS:DX points the way
   int 21h             ; open file
   jc exit             ; GOTO processing mistace,  CF = 1
   mov handle, ax      ; save number of file
   
   mov bx, ax          ; copy identifier of file in  BX
   mov di, 01          ; identifier of  stdout
endm

; close file
macro fclose
   mov ah, 3eh         
   mov bx, handle      ; number of file
   int 21h             ; close
   jc exit             ; GOTO processing mistace
endm  

; read data from file and write this information in stdout 
readnwrite proc
read_data:
    mov cx, 1024       ; size of buffer
    lea dx, buffer     ; buffer
    mov ah, 3fh        ; read from file or device
    int 21h            ; read cx bytes from file
    jc close           ; if it's mistake then close file
    mov cx, ax         ; CX =amount of bytes which we have read
    jcxz close         ; if CX = 0 - close file
    mov ah, 40h        ; write in file or device
    xchg bx, di        ; BX = 1 - STDOUT
    int 21h            ; show data in STDOUT
    xchg di, bx        ; BX = identifier of file
    jc close           
jmp read_data          ; show next cx-bytes
endp  

Clear_buffer proc  
    push cx
    push si
    lea si, buffer
    mov cx,7
clear:
    mov [si], '$'
    inc si
    loop clear
    pop si
    pop cx  
    ret
Clear_buffer endp 

Count_length proc  
    push ax
    push bx
    push cx
    mov [flagforbuffer],0   
    xor si, si
start_count_lenght: 

cmp flagforbuffer, 1 ; we need this cheking because label "end_count_length"
je end_of_the_end  
    xor ax,ax 
    call Clear_buffer
   
    mov cx, 7
    lea dx, buffer 
    mov bx, handle
    mov ah, 3fh
    int 21h
    jc close  ; if cf=1 (perenos=Transfer)  
    mov cx, ax
    jcxz close   ; if cx=0 

    mov bx, ax    ;amount of symbols in buffer (after read)    
    cmp ax, 7
    jl instal_flag 
    jmp  continue    
    
instal_flag:
    mov [flagforbuffer],1  
    
continue:          
    xor si, si
    mov cl, [current_length_of_string] 
    cmp [flagforcount], 1        ; if we use buffer a second (and more) time
    je main_cycle_for_count      ; then we read at the begining of buffer
xor_cx:
    xor cx,cx
main_cycle_for_count:  
    cmp si, bx
    je if_didnot_meet_end  ; end of the string and this buffer is ending
   
    mov al, buffer[si]     ; move current symbol in al
    cmp al, 0Dh            ; compare  with end of string
    je End_of_string 
  
    cmp al, 00h; if it's end of the file then we need to check amount of symbols       
    je  End_of_string  

    cmp al, 0Ah       ;  compare  with NEWLINE
    je skip_cx

;cmp al, '$'    
;je end_of_the_end      
     
    inc cx        ; count length of the current string
skip_cx:    
    inc si
    jmp main_cycle_for_count
End_of_string:  
xor dx,dx   
dec si
mov dh, buffer[si]
inc si
cmp dh, 0Ah
 inc si               ; for read next string/end...  
je plus_result 
cmp dh, 00h
je end_of_the_end
    cmp cx, [amount_for_compare_length]
    jle plus_result      ;less or equal 

    cmp flagforbuffer, 1   
    je end_of_the_end 

    xor cx,cx 
    inc si
    jmp main_cycle_for_count
    
plus_result:
    mov ax, [result]    ; add result
    inc ax     
    mov [result], ax
    jmp if_met_end 
    
if_didnot_meet_end: 
    mov al, buffer[si]
    cmp al, 0Dh         ; end of the current string 
    je End_of_string 
  
    mov [flagforcount],1        ; if this string isn't ending
    mov [current_length_of_string], cl 
    jmp end_count_length        

if_met_end:  
    xor cx,cx 
    mov [flagforcount],0
    mov [current_length_of_string],0 

end_count_length:
    cmp si, bx
    jne main_cycle_for_count     ; continue count  
    je start_count_lenght        ; this buffer is ending

end_of_the_end:  
    pop cx
    pop bx
    pop ax   
    ret
Count_length endp

               
begin:         
    mov ax, @data
    mov ds, ax
     
   ; strout msg1 
   ; call Input  
    call get_name
    mov al, amount
    call Translate
    mov ax,[amount_for_compare_length]   
    fopen
    call Count_length 
  ;  call readnwrite
close:        
    fclose
exit:
    call newline 
    strout msg2
    mov ax, result
    call Show_AX
    mov ah, 4ch
    int 21h                                
end begin