
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h

.DATA

number db 100 dup("$")   
msg1 db "enter a number: $" 
msg2 db "binary form of your number is: $"  
msg3 db "reversed binary form of your number is: $"
is db "binary from of entered number is palindrom!$"
isnot db "binary from of entered number is not palindrom!$" 
enter db 0ah,0dh,"$" 
num dw 16 dup("$")  
print db 2 dup("$")

.CODE

mov ax,@DATA
mov ds,ax  

;printing the msg 
    mov dx,offset msg1
    mov ah,09h
    int 21h 
            
;getting the number
    mov dx,offset number
    mov ah,0ah
    int 21h 
    
    mov si,offset number+2   
    mov di,0   
    mov bp,0
gogo:    
    mov bx,[si]   
    mov bh,00h  
    
    inc si
    mov cx,[si] 
    mov ch,00h 
    inc bp
    cmp cx,0dh
    je gotnumber
    dec si 
    
    sub bx,30h 
    add bx,di 
    mov ah,00h
    mov al,0ah
    mul bx   
    mov di,ax
    inc si
    jmp gogo 
    
gotnumber:  
    cmp bp,1
    je onenumber
    sub bx,30h 
    add di,bx
    mov ax,di 
    jmp startbinary  
    
onenumber:
    mov ax,bx
    sub ax,30h
    
startbinary: 
   
;calculating th binary from of the number using shift
    mov si,offset num  
    mov cx,0000h

tobinary:  
        mov bx,0001h 
        cmp cx,0010h 
        je fill
        inc cx
        and bx,ax
        mov [si],bx 
        add [si],48 
        inc si 
        sar ax,1
        jmp tobinary

fill:

;printing the msg 
    mov dx,offset enter
    mov ah,09h
    int 21h 
    mov dx,offset msg2
    mov ah,09h
    int 21h 

;printing the binary form 
    dec si
    mov cx,si ;to keep end of the binary form in memory  
    mov bx,offset num-1 
    
cont:    
    mov di,offset print
    mov al,[si]
    mov [di],al
    mov dx,offset print
    mov ah,09h
    int 21h
    dec si
    mov [di],0000h 
    cmp si,bx
    je printed
    jmp cont 
     
printed:    
    mov si,cx
    mov dx,offset enter
    mov ah,09h
    int 21h  

;printing the msg 
    mov dx,offset msg3
    mov ah,09h
    int 21h    
    
;printing the reversed binary form 
    mov dx,offset num
    mov ah,09h
    int 21h    
    mov dx,offset enter
    mov ah,09h
    int 21h 
    

;check if binary form is palindrom
    mov di,si
    mov si,offset num 

up: 
    mov bh,[di] 
    mov bl,[si]
    cmp bl,bh
    jne notpalindrom 
    inc si
    dec di
    cmp di,si
    jnb up
    
    mov dx,offset is 
    mov ah,09h
    int 21h
    mov dx,1
    ret
    
notpalindrom: 
    mov dx,offset isnot 
    mov ah,09h
    int 21h
    mov dx,0  
    ret




