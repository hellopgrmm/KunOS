[org 0x9E01]
[bits 16]
start:
    push ds
    xor ax, ax
    mov ds, ax
    mov es, ax
    call calculator
    ret
calculator:
	call cls
	mov si,calcui
	mov al,0x0d
	call cprintf
	mov si,calsele
	mov al,0x0e
	call cprintf
	call getch
	cmp al,'Q'
	je .quit
	cmp al,'q'
	je .quit
	cmp al,'C'
	je .ccalc
	cmp al,'c'
	je .ccalc
	
	call calculator
	ret
.ccalc:
	call cls
	mov si,cal1
	mov al,0x0f
	call cprintf
	mov di,num1in
	call readl
	mov si,num1in
	call Number
	mov [n1],ax
	
	mov si,cal2
	mov al,0x0f
	call cprintf
	mov di,num2in
	call readl
	mov si,num2in
	call Number
	mov [n2],ax
	
	mov si,cal3
	mov al,0x0f
	call cprintf
	call getch
	cmp al,'+'
	je .plusa
	cmp al,'-'
	je .suba
	cmp al,'*'
	je .mula
	cmp al,'/'
	je .diva
	
	call cls
	mov si,notaoption
	mov al,0x0c
	call cprintf
	call pause
	call .quita
.plusa:
	mov si,cal_theresult
	mov al,0x0f
	call cprintf
	mov ax,[n1]
	mov bx,[n2]
	
	add ax,bx
	call printn
	
	call pause
	call .quita
	ret
.suba:
	mov si,cal_theresult
	mov al,0x0f
	call cprintf
	mov ax,[n1]
	mov bx,[n2]
	
	sub ax,bx
	call printn
	
	call pause
	call .quita
	ret
.mula:
	mov si,cal_theresult
	mov al,0x0f
	call cprintf
	mov ax,[n1]
	mov bx,[n2]
	
	push dx
	mul bx
	pop dx
	call printn
	
	call pause
	call .quita
	ret
.diva:
	mov ax,[n1]
	mov bx,[n2]
	cmp bx,0
	je .divzero
	
	mov si,cal_theresult
	mov al,0x0f
	call cprintf
	
	xor dx,dx
	div bx
	call printn
	
	call pause
	call .quita
	ret
.divzero:
	call cls
	mov si,divzeromsg
	mov al,0x0c
	call cprintf
	call pause
	call .quita
	ret
.quita:
	call cls
	call calculator
	ret
.quit:
	call cls
	jmp 0x7E00
	ret
pause:
	mov si,cal_anykey
	mov al,0x0d
	call cprintf
	call getch
	ret
;functions
printc:
    push ax
    mov ah,0x0e
    int 0x10
    pop ax
    ret
Number:
    push bx
    push cx
    push si
    xor ax,ax
    xor bx,bx
    xor cx,cx   
.nloop:
    lodsb
    cmp al,0
    je .done
    cmp al,'0'
    jb .done
    cmp al,'9'
    ja .done
    sub al,'0'
    push ax
    mov ax,bx
    mov cx,10
    mul cx
    pop bx
    add ax,bx
    mov bx,ax
    jmp .nloop    
.done:
    mov ax,bx
    pop si
    pop cx
    pop bx
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
printf:
	lodsb
	or al,al
	jz .done
	mov ah,0x0e
	int 0x10
	jmp printf
.done:
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
cls:
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
calcui db 'KunOS Calculator',0x0d,0x0a,'Choose an option...',0x0d,0x0a,0
calsele db '(C)alculate',0x0d,0x0a,'(Q)uit',0
cal1 db 'Enter the first number:',0x0d,0x0a,0
cal2 db 'Enter the second number:',0x0d,0x0a,0
cal3 db 0x0d,0x0a,'Choose an operation symbol:(+)(-)(*)(/)',0x0d,0x0a,'HIT the corresponding key...',0
cal_anykey db 0x0d,0x0a,'Press any key to return...',0
cal_theresult db 0x0d,0x0a,'The result is:',0x0d,0x0a,'    ',0
notaoption db 'Hey!',0x0d,0x0a,'That is not a valid option,try again.',0
divzeromsg db 'Hey Bro!',0x0d,0x0a,"You CAN'T divide by ZERO, I'm unable to calculate it.",0x0d,0x0a,0
n1 dw 0
n2 dw 0
input times 16 db 0
num1in times 16 db 0
num2in times 16 db 0
times 3*512-($-$$) db 0