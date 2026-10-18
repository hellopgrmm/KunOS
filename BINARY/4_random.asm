;
 ;                    _ooOoo_
 ;                   o8888888o
 ;                   88" . "88
 ;                   (| -_- |)
 ;                    O\ = /O
 ;                ____/`---'\____
 ;              .   ' \\| |// `.
 ;               / \\||| : |||// \
 ;             / _||||| -:- |||||- \
 ;               | | \\\ - /// | |
 ;             | \_| ''\---/'' | |
 ;              \ .-\__ `-` ___/-. /
 ;           ___`. .' /--.--\ `. . __
 ;        ."" '< `.___\_<|>_/___.' >'"".
 ;       | | : `- \`.;`\ _ /`;.`/ - ` : | |
 ;         \ \ `-. \_ __\ /__ _/ .-` / /
 ; ======`-.____`-.___\_____/___.-`____.-'======
 ;                    `=---='
 ;
 ; .............................................
 ;          佛祖保佑             永无BUG
 ;  佛曰:
 ;          写字楼里写字间，写字间里程序员；
 ;          程序人员写程序，又拿程序换酒钱。
 ;          酒醒只在网上坐，酒醉还来网下眠；
 ;          酒醉酒醒日复日，网上网下年复年。
 ;          但愿老死电脑间，不愿鞠躬老板前；
 ;          奔驰宝马贵者趣，公交自行程序员。
 ;          别人笑我忒疯癫，我笑自己命太贱；
 ;          不见满街漂亮妹，哪个归得程序员？
 ;
[org 0x9E03]
[bits 16]
start:
	;pusha
    push ds
    xor ax,ax
    mov ds,ax
    mov es,ax
    
    mov si,rand0
	mov al,0x0e
	call cprintf
    mov byte [maxvalue],100
	call rand
	
	mov [final],ax
	
    call main
    ret
main:
	mov si,prom
	mov al,0x0f
	call cprintf
	
	mov di,gbuf
	call readl
	mov si,gbuf
	call Number
	cmp ax,101
	je .quit
	cmp ax,[final]
	je .right
	ja .big
	jl .small
	
	call main
	ret
.right:
	mov si,rand3
	mov al,0x0a
	call cprintf
	call getch 
	jmp 0x7e00
	ret
.big:
	mov si,rand2
	mov al,0x0c
	call cprintf
	call main
	ret
.small:
	mov si,rand1
	mov al,0x0c
	call cprintf
	call main
	ret
.quit:
	jmp 0x7e00
	ret
final db 0
rand0 db 'Guess a number between 0~100 (Type "101" to quit game)',0x0d,0x0a,0
rand1 db 'Too small',0x0d,0x0a,'try again',0x0d,0x0a,0
rand2 db 'Too big',0x0d,0x0a,'try again',0x0d,0x0a,0
rand3 db 'Yes,you are right!',0x0d,0x0a,'Press any key to return',0x0d,0x0a,0
prom db '-->',0
rand:
	mov ah,0x00
	int 0x1a
	mov ax,dx
	mov [rseed],ax
	mov ax,[rseed]
	mov bx,25173
	mul bx
	add ax,13849
	mov [rseed],ax
	xor dx,dx
	mov bx,[maxvalue]
	div bx
	mov ax,dx
	ret
maxvalue dw 10
rseed dw 0
;necessary functions for kunos
strlen:
    push si
    xor ax,ax
.loop:
    cmp byte [si],0
    je .done
    inc si
    inc ax
    jmp .loop
.done:
    pop si
    ret
printh:
	push ax
	push bx
	push cx
	push dx
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
	pop dx
	pop cx
	pop bx
	pop ax
	ret	
pline:
    mov al,0x0d
    call printc
    mov al,0x0a
    call printc
    ret
printc:
    push ax
    mov ah,0x0e
    mov bx,0x0007
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
	mov bx,0x0007
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
	mov bx,0x0007
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
input times 16 db 0
;ends
gbuf times 16 db 0
times 3*512-($-$$) db 0
