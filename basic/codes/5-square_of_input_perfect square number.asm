
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h

.DATA  

number db 100 dup("$")
result db 100 dup("$") 
print db 2 dup("$")
msg1 db "enter a number: $"
msg2 db " result is: $"    


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
    jmp gosqr  
    
onenumber:
    mov ax,bx
    sub ax,30h
    
gosqr: 

mov bx,ax
mov cx,-1  ;result is stored in cx

    
plusone:       
        inc cx
        mov ax,cx
        mul cx 
        cmp bx,ax
        jne plusone
        
        
;printing the msg
    mov dx,offset msg2
    mov ah,09h
    int 21h    
        
;putting value in memory 

    mov ax,cx
    mov bx,cx
    
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
mov ax,bx    
ret


