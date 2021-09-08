
org 100h 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;data segment
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.DATA

toplinex dw 05h 
topliney dw 14h
toplinecheck dw 16h
downlinex dw 05h
downliney dw 0c3h
sidelinex dw 05h
sidelinecheck dw 07h
sideliney dw 16h           ;equal to topliney + linesize
seidelinelimit dw 0c3h 
linesize dw 02h
rocketx dw 130h
rockety dw 16h             ;equal to topliney + linesize 
rocketwidth dw 05h
rocketheight dw 1fh
rocketspeed dw 05h
ballstartx dw 010h         ;middle: 0a0h
ballstarty dw 80h          ;middle: 64h
framwidth dw 140h          ;320 px
framheight dw 0c8h         ;200 px 
framsub dw 0c3h            ;framheight - frambound 
frambound dw 05h           ;to check tap early
ballspeedx dw 03h          ;ball speed x
ballspeedy dw 03h          ;ball speed y
ballx dw 0a0h   
bally dw 64h
ballsize dw 03h 
timenow db 0               ;to check if the time has changed  
score dw 0d   
scoredecimal dw 3 dup("0$")
print db 2 dup("$")  
color db 0fh 
winscore dw 30d
winmsg dw "you won!$"
gameovermsg dw "game over!$"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;main proc 
;to run the whole thing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.CODE
main proc far 
    
	mov ax,@DATA
	mov ds,ax          
                
    call clearscreen 
    
    checktime:
        mov ah,2ch     ;get the system time 
        int 21h  
           
        cmp dl,timenow ;dl is seconds
        je checktime   ;if equal, check again
        mov timenow,dl ;if not,udate time 
        
        #start=led_display.exe#
        mov ax,score   
        out 199, ax 
        
        call clearscreen

		call drawlinetop
        call drawlinedown
		call drawlineside
		
        call moveball
        call drawball
		
		call moverocket
        call drawrocket
        
        call showscore 
        
        jmp checktime 
        
        gameover:
        call clearscreen
        call gameoverfunc
        ret 
        
        win:
        call clearscreen  
        call winfunc
        ret
        
    ret
main endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;gameover proc
;to show game over page
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gameoverfunc proc near 
    ;set curser
    mov  ah, 02               
    mov  bh, 00
    mov  dl, 15
    mov  dh, 3     
    int  10h 
    ;print msg
    mov dx,offset gameovermsg
    mov ah,09h
    int 21h 
    ret
gameoverfunc endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;win proc
;to show win page
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
winfunc proc near 
    ;set curser
    mov  ah, 02               
    mov  bh, 00
    mov  dl, 15
    mov  dh, 3     
    int  10h 
    ;print msg
    mov dx,offset winmsg
    mov ah,09h
    int 21h 
    ret
winfunc endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;make random proc
;to make a random nuber between 1 and 15 as the ball color
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
makerandom proc near
    
    mov bh,0eh
    mov al,timenow 
    mov ah,00h 
    div bh 
    inc ah 
    mov color,ah
    ret
makerandom endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;move rocket proc
;to let the player move the rockets by keys 's' 'S' 'w' 'W'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
moverocket proc near 
	;check key pressed
	mov ah,01h
	int 16h
	jz checkkeydone
	;check which key is pressed -> al:entered key
	mov ah,00h
	int 16h
	;if w or W move up
	cmp al,77h ;77 is w
	je movup
	cmp al,57h ;57h is W
	je movup
	;if s or S move down
	cmp al,73h ;77 is s
	je movdown
	cmp al,53h ;57h is S
	je movdown	
	jmp checkkeydone
	
	movup:
		mov ax,rocketspeed
		sub rockety,ax
		
		mov ax,toplinecheck
		cmp rockety,ax
		jl fixtop
		
		jmp checkkeydone	
		
		fixtop:
			mov ax,toplinecheck 
			mov rockety,ax
			jmp checkkeydone
		
	movdown:
		mov ax,rocketspeed
		add rockety,ax
		
		mov ax,framheight
		sub ax,frambound
		sub ax,rocketheight
		cmp rockety,ax
		jg fixdown
		jmp checkkeydone
		
		fixdown:
			mov rockety,ax 
			jmp checkkeydone
			
	checkkeydone:
	ret
moverocket endp  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;show score proc
;to show the score at the top of the page
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
showscore proc near

    ;set curser
    mov  ah, 02               
    mov  bh, 00
    mov  dl, 20
    mov  dh, 1     
    int  10h
    ;changing to decimal 
    mov ax,score
    
    mov si, offset scoredecimal
    mov cx,000ah
    
stillhavenumber:
    cmp ax, 0ah
    jb numbersfinished
    sub dx,dx
    div cx
    add dx, 0030h
    mov [si], dx 
    inc si
    mov dx, 0000h
    jmp stillhavenumber
numbersfinished:
    add ax, 30h
    mov [si], ax 

    ;printing the result    
    mov di,si
    mov si,offset scoredecimal-1
    mov bp,offset print
    
    nextnumber:  
    cmp si,di
    je printed
    mov al,[di]
    mov [bp],al
    mov dx,offset print
    mov ah,09h 
    dec di
    int 21h 
    jmp nextnumber 
    
    printed:
    ret
showscore endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;check ball rocket proc
;check tap between ball and rocket
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
checkballrocket proc near
	
	;maxx1 > minx2 && minx1 < maxx2 && maxy1 > miny1 && miny1 < maxy2
	;ballx+ballsize>rocketx&&ballx<rocketx+rocketwidth&&bally+ballsize>rockety&&bally<rockety+rocketheight
	
	mov ax,ballx
	add ax,ballsize 
	mov bx,rocketx
	sub bx,frambound
	cmp ax,bx
	jng nothappens
	
	mov ax,rocketx
	add ax,rocketwidth
	cmp ballx,ax
	jnl nothappens
	
	mov ax,bally
	add ax,ballsize
	cmp ax,rockety
	jng nothappens
	
	mov ax,rockety
	add ax,rocketheight
	cmp bally,ax
	jnl nothappens
	
	jmp negballspeedxonrocket 
	
	nothappens:
	    ret
	negballspeedxonrocket: 
	    neg ballspeedx 
        call makerandom 
        inc score
        ret 
checkballrocket endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;move ball proc
;to let the ball move and check its tap with walls
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
moveball proc near

        mov ax,ballspeedx ;to move the ball on x
        add ballx,ax   
		
        mov ax,sidelinecheck
		add ax,frambound
        cmp ballx,ax     ;tap on edge 
        jl negballspeedx
                           
        mov ax,framwidth ;tap on edge  
        sub ax,ballsize 
        sub ax,frambound               
        cmp ballx,ax  
        jg restartball
        
        mov ax,ballspeedy ;to move the ball on y
        add bally,ax 
        
        mov ax,toplinecheck
		add ax,frambound
        cmp bally,ax      ;tap on edge 
        jl negballspeedy
                           
        mov ax,downliney    ;tap on edge 
        sub ax,ballsize 
        sub ax,frambound                  
        cmp bally,ax
        jg  negballspeedy

        call checkballrocket
		mov ax,score
	    cmp ax,winscore
	    jge win 
	    ret
	    
        restartball: 
            mov score,0
            jmp gameover 
            ret                             
        negballspeedx:
            neg ballspeedx
            ret 
        negballspeedy: 
            neg ballspeedy
            ret  

moveball endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;reset ball position proc
;to place the ball in the middle of the page
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
resetballposition proc near 
    mov ax,ballstartx
    mov ballx,ax
    mov ax,ballstarty
    mov bally,ax
    ret
resetballposition endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;clear screen proc
;to clear the screen each time and show movements
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
clearscreen proc near
        mov ah,00h  ;change the mode 
        mov al,13h  
        int 10h 
        ret
clearscreen endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;draw ball proc
;to show the ball in its position
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
drawball proc near
    
    mov cx,ballx  ;init colomn
    mov dx,bally  ;inti line
    
    balldrawer:
        mov ah,0ch 
        mov al,color  ;white for the pixel
        mov bh,00h
        int 10h 
        inc cx
        mov ax,cx
        sub ax,ballx
        cmp ax,ballsize
        jng balldrawer
        mov cx,ballx ;cx reg goes back to initial colomn
        inc dx   
        mov ax,dx
        sub ax,bally
        cmp ax,ballsize
        jng balldrawer
    ret     
drawball endp 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;draw line top proc
;to draw the top line
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
drawlinetop proc near
	
	mov cx,toplinex
	mov dx,topliney
    
    toplinedrawer:
        mov ah,0ch 
        mov al,15d  ;white for the pixel
        mov bh,00h
        int 10h  
        inc cx
        cmp cx,framwidth
        jng toplinedrawer
        mov cx,toplinex
        inc dx
        mov ax,dx
        sub ax,topliney
        cmp ax,linesize
        jng toplinedrawer
    ret
drawlinetop endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;draw line down proc
;to draw the down line
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
drawlinedown proc near

	mov cx,downlinex
	mov dx,downliney
    
    downlinedrawer:
        mov ah,0ch 
        mov al,15d  ;white for the pixel
        mov bh,00h
        int 10h  
        inc cx
        cmp cx,framwidth
        jng downlinedrawer
        mov cx,downlinex
        inc dx
        mov ax,dx
        sub ax,downliney
        cmp ax,linesize
        jng downlinedrawer
    ret
drawlinedown endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;draw line side proc
;to draw the side line
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
drawlineside proc near

	mov cx,sidelinex
	mov dx,sideliney
    

    sidelinedrawer:
        mov ah,0ch 
        mov al,15d  ;white for the pixel
        mov bh,00h
        int 10h  
        inc cx
        mov ax,cx
        sub ax,sidelinex
        cmp ax,linesize
        jng sidelinedrawer
        mov cx,sidelinex
        inc dx
        cmp dx,seidelinelimit
        jng sidelinedrawer
    ret
drawlineside endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;draw rocket proc
;to draw the rocket in its position
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
drawrocket proc near  
    
    mov cx,rocketx  ;init colomn
    mov dx,rockety  ;inti line
     
        rocketdrawer:
        mov ah,0ch 
        mov al,15d  ;white for the pixel
        mov bh,00h
        int 10h
         
        inc cx
        mov ax,cx
        sub ax,rocketx
        cmp ax,rocketwidth
        jng rocketdrawer  
        
        mov cx,rocketx ;cx reg goes back to initial colomn
        inc dx 
          
        mov ax,dx
        sub ax,rockety
        cmp ax,rocketheight
        jng rocketdrawer
    ret
drawrocket endp
    
end


