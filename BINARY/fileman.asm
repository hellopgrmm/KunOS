[org 0x9E02]
[bits 16]
driven equ 0x01
fsfs equ 0x53464B58
sups equ 0
data0 equ 1
maxf equ 15
entrys equ 32
filenl equ 15
start:
    push ds
    xor ax,ax
    mov ds,ax
    mov es,ax
    call main
    ret
main:
	call cls
	mov si,filemanui
	mov al,0x0d
	call cprintf
	mov si,options
	mov al,0x0e
	call cprintf
	call getch 
	cmp al,'1'
	je .create
	cmp al,'2'
	je .read
	cmp al,'3'
	je .dir
	cmp al,'4'
	je .quit
	call main
	ret
.create:
	call cls
	call fwrite
	call main
	ret
.read:
	call cls
	call fread
	call main
	ret
.dir:
	call cls
	call dir
	call anykey 
	call main
	ret
.quit:
	call cls
	jmp 0x7e00
	ret
filemanui db 'Bascella File Manager(XKFS)',0x0d,0x0a,
		  db 'Choose an option...',0x0d,0x0a,0
options db '(1)Create a file',0x0d,0x0a,
	    db '(2)Read a file',0x0d,0x0a,
	    db '(3)Show files',0x0d,0x0a,
	    db '(4)Quit',0
filenf db 'File does not exist, please create it.',0x0d,0x0a,0
nameask db 'Type a file name',0x0d,0x0a,'    ',0
textask db 'EDIT(When you finish, press ENTER):',0x0d,0x0a,'    ',0
fullm db 'Oh no, disk full!',0x0d,0x0a,0
diskerr db 'FAILED!',0x0d,0x0a,
		db 'Please comfirm that you inserted the second floppy disk.',0x0d,0x0a,0
pressanykey db 0x0d,0x0a,'Press any key to continue...',0x0d,0x0a,0
anykey:
	mov si,pressanykey
	mov al,0x20|0x0f
	call cprintf
	call getch
	ret
;fs begin
dushanqu:
    push ax
    push bx
    push cx
    push dx   
    push cx
    push bx
    call lba2chs
    pop bx
    pop ax
    mov ah,0x02
    mov dl,driven
    int 0x13
    jc .error
    pop dx
    pop cx
    pop bx
    pop ax
    clc
    ret
.error:
    pop dx
    pop cx
    pop bx
    pop ax
    stc
    ret	
xieshanqu:
	push ax
	push bx
	push cx
	push dx
	push cx
	push bx
	call lba2chs
    pop bx
    pop ax
    mov ah,0x03
    mov dl,driven
    int 0x13
    jc .error   
    pop dx
    pop cx
    pop bx
    pop ax
    clc
    ret
.error:
    pop dx
    pop cx
    pop bx
    pop ax
    stc
    ret
lba2chs:
    push ax
    push bx
    push dx
    xor dx,dx
    mov bx,18
    div bx
    inc dx
    mov cl,dl  
    xor dx,dx
    mov bx,2
    div bx
    mov ch,al
    mov dh,dl
    pop dx
    pop bx
    pop ax
    ret
loadsb:
    push ax
    push bx
    push cx
    mov ax,sups
    mov cx, 1
    mov bx,sbuffer
    call dushanqu
    pop cx
    pop bx
    pop ax
    ret
savesb:
    push ax
    push bx
    push cx    
    mov ax,sups
    mov cx, 1
    mov bx,sbuffer
    call xieshanqu
    pop cx
    pop bx
    pop ax
    ret
initialize:
    call loadsb
    jc .error
    mov ax,[sbuffer]
    cmp ax,0x5346
    jne .format
    mov ax,[sbuffer+2]
    cmp ax,0x4B58
    jne .format
    clc
    ret
.format:
    mov di,sbuffer
    mov cx,512
    xor al,al
    rep stosb
    mov word [sbuffer],0x5346
    mov word [sbuffer+2],0x4B58
    mov word [sbuffer+4],0
    call savesb
    clc
    ret
.error:
    stc
    ret
freeslots:
	push si
	push cx
	mov si,sbuffer+8
	mov cx,maxf
.loop:
	mov al,[si]
	cmp al,0
	je .found
	add si,entrys
	dec cx
	jnz .loop
	pop cx
	pop si
	stc
	ret
.found:
	mov bx,si
	pop cx
	pop si
	clc
	ret
findfile:
    push si
    push di
    push cx
    push dx    
    call loadsb
    mov di,sbuffer+8
    mov cx,maxf
.loop:
    mov al,[di]
    cmp al,0
    je .nf
    push si
    push di
    push cx
    mov cx,filenl
.compare:
    mov al,[si]
    mov bl,[di]
    cmp al,bl
    jne .next
    cmp al,0
    je .match
    inc si
    inc di
    loop .compare
.match:
    pop cx
    pop di
    pop si
    mov bx,di
    clc
    jmp .done
.next:
    pop cx
    pop di
    pop si
    add di,entrys
    dec cx
    jnz .loop
.nf:
    pop dx
    pop cx
    pop di
    pop si
    stc
    call cls
    mov si,filenf
    mov al,0x0c
    call cprintf
    call anykey
    call main
    ret
.done:
    pop dx
    pop cx
    pop di
    pop si
    ret
freesq:
    push si
    push cx
    push bx 
    xor ax, ax
    mov si,sbuffer+8
    mov cx,maxf
.loop:
    mov bl,[si]
    cmp bl, 0
    je .next
    mov bx,[si+16]
    add bx,[si+18]
    cmp bx,ax
    jle .next
    mov ax,bx
.next:
    add si,entrys
    dec cx
    jnz .loop
    cmp ax,0
    jne .have
    mov ax,data0
    jmp .done
.have:
	nop
.done:
    pop bx
    pop cx
    pop si
    ret
fread:
    mov si,nameask
    call printf
    mov di,filename
    call readl
    mov si,filename
    call findfile
    jc .notfound
    mov ax,[bx+16]
    mov cx,[bx+18]
    mov bx,fbuffer
    call dushanqu
    jc .error
    call cls
    mov si,fbuffer
    mov cx,[length_of_ctxt]
    mov al,0x0f
    call cprintf
    call pline
    call anykey
    ret
.notfound:
	call cls
	mov si,filenf
	mov al,0x0c
	call cprintf
	call anykey
	call main
    ret
.error:
	call cls
	mov si,diskerr
	mov al,0x0c
	call cprintf
	call anykey
    ret
fwrite:
	mov si,nameask
	call printf
	mov di,filename
	call readl
	call cls
	mov si,textask
	call printf
	mov di,filetext
	call readl
	mov si,filename
	call strlen
	mov [length_of_name],ax
	mov si,filetext
	call strlen
	mov [length_of_ctxt],ax
	mov ax,[length_of_ctxt]
	add ax,511
	shr ax,9
	mov [reqsect],ax
	call loadsb
	jc .error
	call freeslots
	jc .full
	call freesq
	mov [sect0],ax
	push bx
	mov di,bx
	mov si,filename
	mov cx,filenl
.copyname:
    lodsb
    stosb
    cmp al, 0
    je .named
    loop .copyname
.named:
    mov cx, filenl
    sub cx, [length_of_name]
    xor al, al
    rep stosb
    pop bx
    mov ax, [sect0]
    mov [bx + 16], ax
    mov ax, [reqsect]
    mov [bx + 18], ax
    mov ax, [length_of_ctxt]
    mov [bx + 20], ax
    inc word [sbuffer+4]
    call savesb
    jc .error
    mov ax, [sect0]
    mov cx, [reqsect]
    mov bx, filetext
    call xieshanqu
    jc .error
    ret
.full:
	call cls
	mov si,fullm
	mov al,0x0c
	call cprintf
	call anykey
    ret
.error:
	call cls
	mov si,diskerr
	mov al,0x0c
	call cprintf
	call anykey
    ret	
dir:
	call loadsb
	jc .err
	mov si,sbuffer+8
	mov cx,maxf
.loop:
	mov al,[si]
	cmp al,0
	je .done
	push cx
	push si
	mov cx,filenl
.print:
	lodsb
	cmp al,'0'
	je .endname
	call printc
	loop .print
.endname:
	call pline
	pop si
	pop cx
	add si,entrys
	dec cx
	jnz .loop
.done:
	ret
.err:
	call cls
	mov si,diskerr
	mov al,0x0c
	call cprintf
	call anykey
	ret
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
input times 16 db 0
;ends
filename times 16 db 0
filetext times 512 db 0
sbuffer times 512 db 0
fbuffer times 512 db 0
length_of_name dw 0
length_of_ctxt dw 0
reqsect dw 0
sect0 dw 0
times 6*512-($-$$) db 0
