; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h

.DATA

msg1 db "enter first number: $"
msg2 db " enetr second number: $" 
msg3 db " result is: $"
num1 db 100 dup('$')
num2 db 100 dup('$')
space db " $"   
print db 2 dup("$")
result db 100 dup("$")  
save dw ?

.CODE 

main proc
    
    mov ax,@DATA
    mov ds,ax
     
;print first msg             
    mov dx,offset msg1
    mov ah,09h
    int 21h  
     
;getting the first number
    mov dx,offset num1
    mov ah,0ah
    int 21h 
    
    mov si,offset num1+2   
    mov di,0   
    mov bp,0
gogoone:    
    mov bx,[si]   
    mov bh,00h  
    
    inc si
    mov cx,[si] 
    mov ch,00h 
    inc bp
    cmp cx,0dh
    je gotfirstnumber
    dec si 
    
    sub bx,30h 
    add bx,di 
    mov ah,00h
    mov al,0ah
    mul bx   
    mov di,ax
    inc si
    jmp gogoone 
    
gotfirstnumber:  
    cmp bp,1
    je onenumberone
    sub bx,30h 
    add di,bx
    jmp getnext  
    
onenumberone:
    mov di,bx
    sub di,30h
    
getnext:

mov save,di 
   
;print second msg             
    mov dx,offset msg2
    mov ah,09h
    int 21h     
    
;getting the second number
    mov dx,offset num2
    mov ah,0ah
    int 21h 
    
    mov si,offset num2+2   
    mov di,0   
    mov bp,0
gogotwo:    
    mov bx,[si]   
    mov bh,00h  
    
    inc si
    mov cx,[si] 
    mov ch,00h 
    inc bp
    cmp cx,0dh
    je gotsecondnumber
    dec si 
    
    sub bx,30h 
    add bx,di 
    mov ah,00h
    mov al,0ah
    mul bx   
    mov di,ax
    inc si
    jmp gogotwo 
    
gotsecondnumber:  
    cmp bp,1
    je onenumbertwo
    sub bx,30h 
    add di,bx
    jmp getgcd  
    
onenumbertwo:
    mov di,bx
    sub di,30h
    
getgcd: 
   
  
;initialize ax and bx        
    mov ax,save
    mov bx,di
        
    
;calling the gcd function
    call gcd   
;printing the msg
    mov bx,dx
    mov dx,offset msg3
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

    
;exiing
    mov ah,4ch
    int 21h 
    
    main endp 

;if bx=0, end the program with ax as the result
;else,call the funcion with ax and ax%bx
gcd proc
    cmp bx,0
    jne notzero
    mov dx,ax
    ret
    
notzero:
    sub dx,dx
    div bx
    mov ax,bx
    mov bx,dx
    call gcd
    
    ret
    gcd endp

end main 


