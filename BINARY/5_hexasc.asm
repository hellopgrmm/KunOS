[org 0xc200]
[bits 16]
start:
    xor ax,ax
    mov ds,ax
    mov es,ax
    call cls
	mov ah,00h
	mov al,13h
	int 10h
	mov byte [orignum],1
    call main
    ret
main:
	call cls
	mov si,hexasctext
	mov al,0x0f
	call cprintf
	mov ax,[orignum]
	call printn
	mov dh,1
	mov dl,7
	call gotoxy
	mov ax,[orignum]
	call printh
	mov dh,1
	mov dl,14
	call gotoxy
	mov al,[orignum]
	call printc
	mov al,0x0d
	call printc
	mov al,0x0a
	call printc
	mov si,keypress
	mov al,0x0e
	call cprintf
	call getch
	cmp al,'+'
	je .addone
	cmp al,'-'
	je .subone
	cmp al,'Q'
	je .quit
	cmp al,'q'
	je .quit
	call main
.addone:
	mov ax,[orignum]
	add ax,1
	mov [orignum],ax
	call main
.subone:
	mov ax,[orignum]
	sub ax,1
	mov [orignum],ax
	call main
.quit:
	jmp 0x7e00
	ret
hexasctext db 'NUM    HEX    ASCII',0x0d,0x0a,0
keypress db 'Press a key: [Q]Quit [+]Add [-]Sub',0	
gotoxy:
	mov ah,02h
	mov bh,0
	int 10h
	ret
;necessary functions for kunos
printh:
	mov bx,ax
	mov cx,4
.hexl:
	rol bx,4
	mov al,bl
	and al,0x0f
	cmp al,10
	jb .dig
	add al,'A'-10-'0'
.dig:
	add al,'0'
	call printc
	loop .hexl
	ret	
printc:
    push ax
    mov ah,0x0e
    mov bx,0x0b
    int 0x10
    pop ax
    ret
printn:
    push ax
    push bx
    push cx
    push dx   
    cmp ax,0
    jne .positive
    mov al,'0'
    call printc
    jmp .done    
.positive:
    cmp ax,0
    jge .not_negative
    push ax
    mov al,'-'
    call printc
    pop ax
    neg ax
.not_negative:
    mov bx,10
    mov cx,0
    xor dx,dx
.push_digits:
    inc cx
    div bx
    push dx
    xor dx,dx
    cmp ax,0
    jne .push_digits
.pop_digits:
    pop dx
    add dl,'0'
    mov al,dl
    call printc
    loop .pop_digits
.done:
    pop dx
    pop cx
    pop bx
    pop ax
    ret
getch:
	mov ah,00h
	int 16h
	;compare with AL
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
	cmp dh,30
	jl .setcur
	call scrollit
	mov dh,29
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
	mov bh,0x00
	mov cx,0
	mov dx,0x1d4f
	int 0x10
	pop dx
	pop cx
	pop bx
	pop ax
	ret
cls:
	mov ah,0x06
	mov al,0
	mov bh,0x00
	mov cx,0
	mov dx,0x1d4f
	int 0x10
	mov ah,0x02
	mov bh,0
	mov dx,0
	int 0x10
	ret
;ends
orignum dw 0
times 512-($-$$) db 0
