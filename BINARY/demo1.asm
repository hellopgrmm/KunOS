[org 0x9E00]
[bits 16]
start:
	;pusha
    push ds
    xor ax,ax
    mov ds,ax
    mov es,ax
    call acls
    mov ah,11h
	mov al,30h
	mov bl,0
	int 10h
	mov dl,0
	mov dh,cl
	call gotoxy
	mov si,infomsg
	mov al,0x20|0x0f
	call cprintf
	mov dh,0
	mov dl,0
	call gotoxy
    mov si,block
    mov al,0x30
    call cprintf
    call mainloop
    ret
cprintf:
	push ax
	push bx
	;push cx
	;push dx
	push si
	;push di
	mov bh,0
	mov bl,al
	;mov di,si
.cprintfl:
	lodsb
	cmp al,0
	je .done
	cmp al,0x0d ;if enter?
	je .crr
	cmp al,0x0a ;if newline?
	je .newline
	mov ah,0x09
	mov cx,1
	int 0x10
	mov ah,0x03
	int 0x10
	inc dl
	mov ah,0x02
	int 0x10
	jmp .cprintfl
.crr:
	mov ah,0x03
	int 0x10
	mov dl,0
	mov ah,0x02
	int 0x10
	jmp .cprintfl
.newline:
	mov ah,0x03
	int 0x10
	mov dl,0
	inc dh
	cmp dh,25
	jl .setcur
	call scrollit
	mov dh,24
.setcur:
	mov ah,0x02
	int 0x10
	jmp .cprintfl
.done:
	pop si
	pop bx
	pop ax
	ret
scrollit:
	push ax
	push bx
	push cx
	push dx
	mov ah,0x06
	mov al,1
	mov bh,0x07
	mov cx,0
	mov dx,0x184f
	int 0x10
	pop dx
	pop cx
	pop bx
	pop ax
	ret
printf:
	lodsb
	or al,al
	jz .done
	mov ah,0x0e
	int 0x10
	jmp printf
.done:
	ret
acls:
	mov ah,0x06
	mov al,0
	mov bh,0x07
	mov cx,0
	mov dx,0x184f
	int 0x10
	mov ah,0x02
	mov bh,0
	mov dx,0
	int 0x10
	ret
;mainloop	
mainloop:
	mov ah,0x00
    int 0x16
	cmp al,'a'
	je .moveL
	cmp al,'A'
	je .moveL
	cmp al,'w'
	je .moveU
	cmp al,'W'
	je .moveU
	cmp al,'d'
	je .moveR
	cmp al,'D'
	je .moveR
	cmp al,'s'
	je .moveD
	cmp al,'S'
	je .moveD

	cmp al,'q'
	je .quit
	cmp al,'Q'
	je .quit	
	
	cmp al,'c'
	je .clearall
	cmp al,'C'
	je .clearall	
	
	cmp al,'0'
	je .penup
	cmp al,'1'
	je .pendown
	cmp al,'2'
	je .cc_red
	cmp al,'3'
	je .cc_yellow
	cmp al,'4'
	je .cc_cyan
	cmp al,'5'
	je .cc_blue
	cmp al,'6'
	je .cc_white
	
.moveR:
	mov ax,[xpos]
	add ax,1
	mov [xpos],ax
	call moveblock
.moveD:
	mov bx,[ypos]
	add bx,1
	mov [ypos],bx
	call moveblock
.moveL:
	mov ax,[xpos]
	sub ax,1
	mov [xpos],ax
	call moveblock
.moveU:
	mov bx,[ypos]
	sub bx,1
	mov [ypos],bx
	call moveblock
.clearall:
	call acls
.penup:
	mov byte [colorvalue],0x00
	call moveblock
.pendown:
	mov byte [colorvalue],0x30
	call moveblock
	ret
.cc_red:
	mov byte [colorvalue],0xc0
	call moveblock
	ret
.cc_yellow:
	mov byte [colorvalue],0xe0
	call moveblock
	ret
.cc_cyan:
	mov byte [colorvalue],0x30
	call moveblock
	ret
.cc_blue:
	mov byte [colorvalue],0x90
	call moveblock
	ret
.cc_white:
	mov byte [colorvalue],0xf0
	call moveblock
	ret
.quit:
	call acls
	jmp 0x7E00
	ret
moveblock:
	mov dh,[ypos]
	mov dl,[xpos]
	call gotoxy
	mov si,block
    mov al,[colorvalue]
    call cprintf
    call mainloop
;mainloop ends
gotoxy:
	mov ah,02h
	mov bh,0
	int 10h
	ret
block db ' ',0
xpos db 0
ypos db 0
colorvalue db 0x30
infomsg db 'Press W,A,S,D to move the block, C=Clear all, Q=Quit.',0x0d,0x0a,'0=Pen up,1=Pen down',0x0d,0x0a,'2~6=Change color',0
times 3*512-($-$$) db 0