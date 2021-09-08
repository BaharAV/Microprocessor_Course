
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h

.DATA    
    
str1 db 100 dup("$")
str2 db 100 dup("$") 
enter db 0ah,0dh,"$",

.CODE

    mov ax,@DATA
    mov ds,ax 
    
    mov dx,offset str1
    mov ah,0ah
    int 21h 
    
    mov si,offset str1
    mov bx,offset str2
    
    
    mov cx,100
    back:
        mov al,[si]
        cmp al,61h
        jb over
        cmp al,7ah
        ja over
        and al,11011111b
    over:
        mov [bx],al
        inc si
        inc bx
        loop back
         
        mov dx,offset enter
        mov ah,09h
        int 21h 

        mov dx,offset str2+2
        mov ah,09h
        int 21h 
ret









