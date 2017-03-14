    .model small;  tiny - com, small -exe 
    .stack 100h     ; instal size of stack   
    .data            ; begining of the segment data
    i dw 0h
    String db 'Enter string, pls: $' 
    Stg db 200h dup(0h)     ;   our string  
    
    .code   
Start:
Sort proc
    mov ax, @data   ;   send adress segment data in ax
    mov ds, ax  ;      instal dx on seg.data

    mov ah, 00h ;     clear display ( black-white)
    mov al, 2h  ; 
    int 10h

    mov ah, 09h
    Lea dx, String ; get an adress
    int 21h  

    mov ah, 1h  ;  function for input symbol
    mov si, 0h
    mov bx, 0h

Input:   ;input massive
    int 21h
    mov cx, si
    mov Stg[bx], cl     ;    lenght of the world
    cmp al, 32  ;  if this symbol == space
    jne Skip1   ; jne- if != ; zf=0 if it isn't space go to SKIP1
   
    mov si, 0h
    add bx, 10h ;     begining of the next world
    jmp Input 
    
Skip1:
    inc si
    mov Stg[bx+si], al      ; add symbol to massive 
    cmp al, 13       ; ifit isn't the  end of the string
    jne Input            ; go to input
   
    mov Stg[bx+si], 0h      ;  delete "enter"
    mov i, bx   ;   amount of worlds
    mov bx, 0h 
    
Sort1:   ;choose's sort
    mov di, bx  ;  index of the little length
    mov ax, bx
    add ax, 10h 
    
Sort2:
    mov si, ax      ; lenght of the current world
 
    mov cl, Stg[di]  ; lenght of the world
    cmp cl, Stg[si]   ; compare lenghts of worlds
    jae Skip2        ;  if less (men'she)    stg[di] < stg[si]
    mov di, si     
    
Skip2: 
    add ax, 10h
    cmp ax, i
    jbe Sort2     ; if amount of worlds less or equality (ravno) go to this mark
    
    mov si, 0h    
Swap:
    mov cl, Stg[bx+si]; change worlds
    mov al, Stg[di]
    mov Stg[bx+si], al
    mov Stg[di], cl
    inc si
    inc di
    cmp si, 10h
    jb Swap     ; go to if less (si < 10)
    
    add bx, 10h
    cmp bx, i
    jb Sort1    ; go to if less
    
    mov ah, 02h ; function for instal position of cursor
    mov bh, 0h  ;  number of th page 
    mov dh, 2h  ;  number of the string
    mov dl, 0h  ; numer of the collum
    int 10h     ; clear

    mov bx, 0h
    mov si, 0h
    mov ah, 2h  ;  function for output symbol 
    
Output:         ;output massive
    inc si
    mov dx, word ptr Stg[bx+si]
    cmp dx, 0h  ; if != continue(don't do jump)
    jne Skip3 
    
    cmp bx, i
    je Exit     ; == compare amout worlds
    
    mov si, 0h
    add bx, 10h
    mov dx, ' ' 
    
Skip3:
    int 21h
    cmp bx, i
    jbe Output   ; if != continue output
    
Exit:
    ;mov ah, 4ch; 
    int 20h
Sort endp  

End Start






