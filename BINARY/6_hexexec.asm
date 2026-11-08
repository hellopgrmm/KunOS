[org 0xc400]
[bits 16]
exbuf equ 0xca00
exmax equ 512
start:
    xor ax,ax
    mov ds,ax
    mov es,ax
    mov si,tips
    call printf
    call main
    ret
main:
	mov al,'#'
	call putch
	mov di,hexin
	call readl
	
	cmp byte [hexin],0
	je main
	
	
	mov si,quitcmd
	call strcmp
	jc .quit
	
	call execute
	call main
.quit:
	jmp 0x7e00
	ret
execute:
	mov si,hexin
	mov di,exbuf
	call parsehex
	jc .err
	call 0x0000:exbuf
	mov al,0x0d
	call putch
	mov al,0x0a
	call putch
	call main
	ret
.err:
	ret
parsehex:
	pusha
	xor cx,cx
.emp_char:
	nop
.space:
	lodsb
	cmp al,0
	je .done
	cmp al,' '
	je .space
	cmp al,0x09
	je .space
	call h2n
	jc .err
	mov bl,al
	shl bl,4
	lodsb
	call h2n
	jc .err
	or bl,al
	mov [di],bl
	inc di
	inc cx
	cmp cx,exmax
	jge .done
	jmp .emp_char
.done:
	popa
	clc
	ret
.err:
	mov si,error
	call printf
	popa
	stc
	ret
h2n:
    cmp al,'0'
    jb .bad
    cmp al,'9'
    jbe .digit
    cmp al,'A'
    jb .lower
    cmp al,'F'
    jbe .upper
.lower:
    cmp al,'a'
    jb .bad
    cmp al,'f'
    ja .bad
    sub al,'a'-10
    clc
    ret
.upper:
    sub al,'A'-10
    clc
    ret
.digit:
    sub al,'0'
    clc
    ret
.bad:
    stc
    ret
;necessary subprograms
strcmp:
    push si
    push di
    push bx
.loop:
    mov al,[si]
    cmp al,0
    je .checke
    mov bl,[di]
    cmp al,bl
    jne .badcmd
    inc si
    inc di
    jmp .loop
.checke:
    mov bl,[di]
    cmp bl,0
    jne .badcmd
    stc
    jmp .done
.badcmd:
    clc
.done:
    pop bx
    pop di
    pop si
    ret
putch:
	mov ah,0x0e
	mov bx,0x0f
	int 0x10
	ret
printf:
	lodsb
	or al,al
	jz .done
	mov ah,0x0e
	mov bx,0x0f
	int 0x10
	jmp printf
.done:
	ret
readl:
	push di
	push ax
.loop:
	mov ah,0x00
	int 0x16
	cmp al,0x0d
	je .enter
	cmp al,0x08
	je .bks
	mov ah,0x0e
	mov bx,0x0d
	int 0x10
	stosb
	jmp .loop
.bks:
	cmp di,input
	je .loop
	dec di
	mov al,0x08
	mov ah,0x0e
	int 0x10
	mov al,' '
	int 0x10
	mov al,0x08
	int 0x10
	jmp .loop
.enter:
	mov al,0x0d
	mov ah,0x0e
	int 0x10
	mov al,0x0a
	int 0x10
	mov al,0
	stosb
	pop ax
	pop di
	ret
;ends	
tips db 'Type "quit" to exit',0x0d,0x0a,'REMEMBER: write "c3" to the end of code!',0x0d,0x0a,0
error db 'CRASH!!! Illegal machine code',0x0d,0x0a,0
quitcmd db 'quit',0
input times 16 db 0
hexin times 1024 db 0
times 3*512-($-$$) db 0
