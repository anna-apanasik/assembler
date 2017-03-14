    .model small;  tiny - com, small -exe 
    .stack 100h     ; instal size of stack   
    .data            ; begining of the segment data

    For1number db 'Enter the first number, pls: $'  
    For2number db 'Enter the second number, pls: $' 
    
    Mas  db 10  dup('$')
    First db 10  dup('$')
    Second db 10  dup('$')  
    
    Flag db 1    
    Flag1 db 1
    Flag2 db 1    
    Menu db 'Choose operation, pls: 1.AND 2.OR 3.XOR 4.All operation. Enter only number $'
    Mes1 db ' You entered incorrect character or space/enter $' 
    OpAnd db ' After operation AND:  $' 
    OpOr db ' After operation OR:  $'
    OpXor db ' After operation XOR:  $'
    ;OpNo db ' After operation No:  $'
    new_line db 0dh, 0ah, '$'
    .code   
Start: 

    mov ax, @data       ;   send adress segment data in ax
    mov ds, ax          ;    install dx on seg.data
    
    mov ah, 09h
    lea dx, For1number  ; get an adress
    int 21h  
    
    mov Flag,0
    mov Flag1,0
    mov Flag2,0 
   
    xor bx,bx
    call Input
    
    lea si,Mas
    lea di,First
    mov cx,10
    rep movsb
    
    mov ah,Flag    ; send flag to special flag1 for first number
    mov Flag1,ah
    mov Flag,0
    
    mov ah, 09h
    lea dx, For2number  ; get an adress
    int 21h   
    xor bx,bx
    call Input
    
    lea si,Mas
    lea di,Second
    mov cx,10
    rep movsb  
    
    mov ah,Flag  ; send current flag to Flag2
    mov Flag2,ah
    
    mov ah, 09h
    lea dx, Menu  ; get an adress
    int 21h
    mov ah, 01h     ; enter number and show him
    int  21h 
    
    xor ah,ah
    
    cmp al, '1'
    je MENU1 
    jne Point2
MENU1:
    call ProcOpAND
    jmp EndStart 
    
Point2:    
    cmp al,'2'
    je MENU2
    jne Point3
MENU2:
    call ProcOpOR
    jmp EndStart 
    
Point3:    
     cmp al,'3'
     je MENU3
     jne Point4
MENU3:
    call ProcOpXOR 
    jmp EndStart
Point4:    
    cmp al, '4'
    je MENU4
    jne EndStart
MENU4:
    call ProcOpAND    
; return to mas value (Second value)   
    lea si,Second
    lea di,Mas
    mov cx,10
    rep movsb
    call ProcOpOR
; return to mas value (Second value)   
    lea si,Second
    lea di,Mas
    mov cx,10
    rep movsb 
    call ProcOpXOR
    jmp EndStart
    
EndStart:    
    int 20h
    
Input proc 
       
Input_next_symbol:    
    mov ah, 01h     ; enter number and show him
    int  21h 
    
    cmp al, '-'
    je ForFlags
    
    sub al, 30h     ; -30h because need  change ascii  to number 
    
; if number until '0' in ascii or 'enter' because sub install flags
    
    jb NoNumber     ; if < or our occasion SUb install flag,  if symbol != number   
    
    cmp al, 09h      
    jbe Number       ; if less or  RAVNO, can add this  numeral to our data(number)
  
;now we have 11h-16h or 31h-36h (early they are symbols "A"-"F" or "a"-"f"  
    
    sub al, 11h     ;  for do 0-5 or 20h-25h 
    jb NoNumber     ; if this symbols is located between '9' and 'A' he isn't fit us
   
; if early we had "A"-"F" (now they are 0-5), we need to addition 10 for get 16number
   
    cmp al,5
    jbe Add10   ;if less or  RAVNO
     
; now we check if we have 20h-25h, TODO 0-5
    sub al, 20h 
    jb NoNumber  ; if we have less 0, this symbol doesn't fit
    
    cmp al,5      
    ja NoNumber  ;(>) if we have more then 5,this symbol doesn't fit 
    
; if all are ok, TODO addition 10 for get 16number
Add10: 
    add al,10
Number:
    mov Mas[bx],al
    inc bx
    jmp Input_next_symbol  

NoNumber: 
    mov dx,offset new_line  ; do new line(such as '\n'in c)
    mov ah,9h
    int 21h 
    
    mov dx,offset Mes1  ; 
    mov ah,9h
    int 21h 
    
    mov dx,offset new_line  ; do new line(such as '\n'in c)
    mov ah,9h
    int 21h  
    jmp en
ForFlags:
    mov Flag, 1
    ;mov Flag, ah
    jmp Input_next_symbol
en:       
    ret
Input endp  

Output proc
    
Show:  
    mov dl, Mas[bx] 
    cmp dl,'$'
    je EndShow 
    
    cmp Flag, 1
    je Negative
    cmp dl,9 ; if it's 0-9 we need to do ascii for this number(30h-39h we need to addition 30h) 
  ; or it's "A"-"F" to addition 37h
    jbe Numberal     ; if less or  RAVNO   
   
    add dl, 7h ; if more then 9

Numberal: 
    add dl,30h
      
    mov ah,02h 
    int 21h
    inc bx
    loop Show
    
    cmp cx,0
    je EndShow
    
Negative: 
    mov ah,02h  
    mov dx,'-' 
    mov Flag,0
    int 21h
    jmp Show
    
EndShow:    
    ret
Output endp 

ProcOpAND proc    
    mov ah,Flag2   ; compare our flags
    and ah,Flag1
    mov Flag, ah
    mov cx,10 
    xor di,di 
    xor si,si
OperAnd:       
    mov al, First[si]
    and Mas[di],al    
    inc di
    inc si
    loop OperAnd
;show result after AND    
    mov dx,offset new_line  ; do new line(such as '\n'in c)
    mov ah,9h
    int 21h   
    mov dx,offset OpAnd  
    mov ah,9h
    int 21h 
    xor bx,bx
    mov cx, 10
    call Output  
    ret
ProcOpAND endp 

ProcOpOR proc 
         mov al,Flag2  ; compare our flags
    or al,Flag1 
    mov Flag, al
    mov cx,10 
    xor di,di 
    xor si,si 
OperOr:       
    mov al, First[si]
    or Mas[di],al    
    inc di
    inc si
    loop OperOr
;show result after OR         
    mov dx,offset new_line  ; do new line(such as '\n'in c)
    mov ah,9h
    int 21h    
    mov dx,offset OpOr  
    mov ah,9h
    int 21h   
    xor bx,bx
    mov cx, 10
    call Output
     ret
ProcOpOR endp

ProcOpXOR proc   
    mov al,Flag      ; compare our flags
    xor al,Flag1 
    mov Flag, al
    mov cx,10 
    xor di,di 
    xor si,si 
OperXor:       
    mov al, First[si]
    xor Mas[di],al    
    inc di
    inc si
    loop OperXor
;show result after XOR         
    mov dx,offset new_line  ; do new line(such as '\n'in c)
    mov ah,9h
    int 21h    
    mov dx,offset OpXor  
    mov ah,9h
    int 21h   
    xor bx,bx
    mov cx, 10
    call Output  
    ret
ProcOpXOR endp 

End Start


