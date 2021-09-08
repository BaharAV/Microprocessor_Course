
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h

.DATA 

arr db 3h,12h,24h,0fah,0ffh,7h,45h,25h,00h,23h,0ah,0abh,14h,01h,65h,76h,0a5h,11h,0aah,0bbh,3h,17h,0eh,12h,04h 
save db ?  
counter db 24 
on dw ?
result db 100 dup("$")   
print db 2 dup("$")
space db " $"

.CODE 

mov ax,@DATA
mov ds,ax  

mov si,1000h 
mov di,offset arr 
mov cx,19h

changer:
    mov ax,[di]  
    mov ah,00h
    mov [si],ax
    inc si
    inc di 
    dec cx
    cmp cx,0
    je changed
    jmp changer 

changed:

mov si,1000h 
mov cx,si 
 
inc si  
mov al,[si]
mov save,al
mov on,si

up:
    cmp si,cx
    jb exit
    dec si  
    mov bl,[si]
    cmp bl,save
    jnb change
    jmp exit
    
change:    
    mov al,[si] 
    inc si
    mov [si],al
    dec si
    jmp up 
    
exit:      
    inc si    
    mov al,save
    mov [si],al
    dec counter 
    jz done
    inc on
    mov si,on
    mov al,[si] 
    mov save,al
    jmp up

;araye dar in marhale be soorate moratab shode dar hafeze ghara darad
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;printing the sorted array in decimal from
done:
    mov si,1000h 
    dec si 
    mov on,si  
    mov bx,25
    jmp here
herehere:
    mov dx,offset space
    mov ah,09h 
    int 21h 
here:     
    mov si,on
    cmp bx,0
    je paian 
    dec bx
    inc si    
    mov ax,[si]
    mov ah,00h
    
;changing a member of the array to decimal form   
    mov cx,000ah  
    mov on,si 
    mov si,offset result
    
stillhavenumber:
    cmp ax, 0ah
    jb donedone
    sub dx,dx
    div cx
    add dx, 0030h
    mov [si], dx 
    inc si
    mov dx, 0000h
    jmp stillhavenumber
donedone:
    add ax, 30h
    mov [si], ax 

;printing a member of the array     
    mov di,si
    mov si,offset result-1
    mov bp,offset print
    
edame:  
    cmp si,di
    je herehere
    mov al,[di]
    mov [bp],al
    mov dx,offset print
    mov ah,09h 
    int 21h 
    dec di
    jmp edame
     
     
paian:     
ret





