.model small
.stack 100h
.data        

message db 'Hello, I am a child! $'
 
newline macro                   ;make newline
    push dx
    push ax
    mov dl, 13                  ;13 is askii of '\n'
    mov ah, 02h
    int 21h
    mov dl, 10                  ;10 is askii of begin of string
    int 21h
    pop ax
    pop dx
endm
                                    
output macro str                ;output stirng
    push dx
    push ax  
    lea dx, str
    mov ah, 09h
    int 21h
    pop ax 
    pop dx
endm 
start:
    mov ax, @data
    mov ds, ax
  
    output message
    newline
    mov ah, 4Ch
    int 21h
end start