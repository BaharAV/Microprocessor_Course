; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h

.DATA

msg1 db "enter a number as n: $"
msg2 db " result is: $"
number db 100 dup('$')
space db " $"   
print db 2 dup("$")
result db 100 dup("$") 

.CODE 

main proc
    
    mov ax,@DATA
    mov ds,ax
     
;print msg             
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
    jmp startfactorial  
    
onenumber:
    mov ax,bx
    sub ax,30h
    
startfactorial: 
    
;calculate factorial 
    cmp ax,0000h
    je isone
    cmp ax,0001h
    je isone    
    mov cx,ax
    dec cx
notzero:
    mul cx
    dec cx  
    cmp cx,0
    jne notzero 
    jmp notone
    
    
isone:
    mov dx,0001h 
    jmp printpart
    ret 

notone:
    mov dx,ax  
    jmp printpart
    ret 

printpart:

;printing the msg
    mov bx,dx
    mov dx,offset msg2
    mov ah,09h
    int 21h 
     

;putting result in memory 

    mov ax,bx
    
    mov si, offset result
    mov cx,000ah
    
stillhavenumber:
    cmp ax, 0ah
    jb done
    sub dx,dx
    div cx
    add dx, 0030h
    mov [si], dx 
    inc si
    mov dx, 0000h
    jmp stillhavenumber
done:
    add ax, 30h
    mov [si], ax 

;printing the result    
    mov di,si
    mov si,offset result-1
    mov bp,offset print
    
edame:  
    cmp si,di
    je paian
    mov al,[di]
    mov [bp],al
    mov dx,offset print
    mov ah,09h 
    dec di
    int 21h 
    jmp edame
     
     
paian:
    mov dx,bx     
    ret

