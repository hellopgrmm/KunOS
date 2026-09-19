[org 0x7e00]
[bits 16]
;color table
BLACK equ 0x00
BLUE equ 0x01
GREEN equ 0x02
CYAN equ 0x03
RED equ 0x04
MAGENTA equ 0x05
BROWN equ 0x06
YELLOW equ 0x0e
WHITE equ 0x0f
BGBLACK equ 0x00
BGBLUE equ 0x10
BGGREEN equ 0x20
BGCYAN equ 0x30
BGRED equ 0x40
BGMAGENTA equ 0x50
BGBROWN equ 0x60
start:
	xor ax,ax
	mov ds,ax
	mov es,ax
	mov ss,ax
	mov sp,0x7e00
	
	;printf
	
	mov si,msg
	mov al,WHITE
	call cprintf
	
	call debugit
	
	call getusername
	
	mov byte [filecount],0
;Ö÷Ñ­»·
kunkun:
	mov si,uinput
	mov al,0x0b
	call cprintf
	mov si,pmt
	mov al,WHITE
	call cprintf
	mov di,input
	call readl
	mov si,input
	call pcmd	
	jmp kunkun
;get username
getusername:
	mov ax,[userflag]
	cmp ax,0
	je .getit
	jne .tocmd
	ret
.getit:
	mov si,upmt
	mov al,0x0a
	call cprintf
	call getun
	ret
.tocmd:
	mov si,youback
	mov al,YELLOW
	call cprintf
	ret
youback db 'Welcome back to the command line, try more commands!',0x0d,0x0a,0
getun:
	mov di,uinput
	mov cx,0
.loop:
	mov ah,0x00
	int 0x16
	cmp al,0x0d
	je .uenter
	cmp al,0x08
	je .ubks
	mov ah,0x0e
	int 0x10
	stosb
	jmp .loop
.ubks:
	cmp di,uinput
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
.uenter:
	mov byte [userflag],1
	mov al,0
	stosb
	call pline
	ret
;command input
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
pcmd:
	mov si,chelp
	call strcmp
	jc .help
	
	mov si,ctime
	call strcmp
	jc .time
	
	mov si,ccls
	call strcmp
	jc .cls
	
	mov si,cikun
	call strcmp
	jc .ikunikun
	
	mov si,creb
	call strcmp
	jc .restart
	
	mov si,cinfo
	call strcmp
	jc .info

	mov si,chlt
	call strcmp
	jc .hlt
	
	mov si,cchusr
	call strcmp
	jc .chusr
	
	mov si,cdate
	call strcmp
	jc .date
	
	mov si,cblue
	call strcmp
	jc .blue
	
	mov si,cwrite
	call strcmp
	jc .fsw
	
	mov si,clist
	call strcmp
	jc .fsl
	
	mov si,cread
	call strcmp
	jc .fsr
	
	mov si,cout
	call strcmp_pro
	jc .echo
	
	mov si,ccount
	call strcmp
	jc .jishu	
	
	;applications command
	mov si,capp
	call strcmp
	jc .dapp
	
	mov si,capp_calc
	call strcmp
	jc .calcapp
	;ok
	mov si,cal
	call strcmp
	jc .dal
	
	mov si,cdebug
	call strcmp
	jc .osdebug
	
	mov si,ccolortest
	call strcmp
	jc .colortestpart
		
	mov si,unknown
	mov al,0x0c
	call cprintf
	mov si,unknown2
	mov al,0x0e
	call cprintf
	ret
.help:
	mov si,helptext
	mov al,WHITE
	call cprintf
	mov si,helptext2
	mov al,WHITE
	call cprintf
	mov si,helptext3
	mov al,WHITE
	call cprintf
	mov si,helptext4
	mov al,WHITE
	call cprintf
	ret
.time:
	call gettime
	ret
.cls:
	call cls
	ret
.ikunikun:
	call ikunikun
	ret
.info:
	mov si,infoinfo
	mov al,YELLOW
	call cprintf
	mov si,infoinfo2
	mov al,0x0a
	call cprintf
	mov si,infoinfo3
	mov al,0x50|WHITE
	call cprintf
	ret
.date:
	mov ah,0x04
	int 0x1A
	call pline
	mov si,dmsg
	call printf
	call pline
	mov si,lines
	call printf
	mov al,ch
	call pbcdb
	mov al,cl
	call pbcdb
	mov al,'-'
	call printc
	mov al,dh
	call pbcdb
	mov al,'-'
	call printc
	mov al,dl
	call pbcdb
	call pline
	mov si,lines
	mov al,WHITE
	call cprintf
	call pline
	ret
.blue:
	call blue
	ret
.dal:
	mov si,infoapl
	mov al,YELLOW
	call cprintf
	ret
.osdebug:
	call debugit
	ret
.fsw:
	call pline
	call fs_write
	call pline
	ret
.fsl:
	call pline
	mov si,filebeginmsg
	mov al,YELLOW
	call cprintf
	call pline
	mov si,line2
	mov al,WHITE
	call cprintf
	call pline
	call fs_list
	call pline
	ret
.fsr:
	call pline
	call fs_read
	call pline
	ret
.dapp:
	pusha
	mov bx,0x9E00
	mov cl,22
	call runprog
	call 0x0000:0x9E00
	ret
.calcapp:
	pusha
	mov bx,0x9E01
	mov cl,19
	call runprog
	call 0x0000:0x9E01
	ret
.hlt:
	call pline
	mov si,haltmsg
	mov al,0x0c
	call cprintf
	cli
	hlt
	syscall
	ret
.jishu:
	call count_main
	ret
.chusr:
	mov si,chusrmsg
	mov al,0x0d
	call cprintf
	call getun
	ret
.echo:
	mov si,input
	add si,3
.skipspc:
	lodsb
	cmp al,' '
	je .skipspc
	dec si
	mov al,[si]
	cmp al,0
	je .edone
	mov al,YELLOW
	call cprintf
.edone:
	call pline
	ret
.colortestpart:
	mov si,exampletext
	mov al,BLUE
	call cprintf
	mov al,GREEN
	call cprintf
	mov al,CYAN
	call cprintf
	mov al,RED
	call cprintf
	mov al,MAGENTA
	call cprintf
	mov al,BROWN
	call cprintf
	mov al,0x09
	call cprintf
	mov al,0x0a
	call cprintf
	mov al,0x0c
	call cprintf
	mov al,0x0d
	call cprintf
	mov al,0x0e
	call cprintf
	mov al,0x0f
	call cprintf
	call pline
	
	mov al,BGBLUE
	call cprintf
	mov al,BGGREEN
	call cprintf
	mov al,BGCYAN
	call cprintf
	mov al,BGRED
	call cprintf
	mov al,BGMAGENTA
	call cprintf
	mov al,BGBROWN
	call cprintf
	mov al,0x90
	call cprintf
	mov al,0xa0
	call cprintf
	mov al,0xc0
	call cprintf
	mov al,0xd0
	call cprintf
	mov al,0xe0
	call cprintf
	mov al,0xf0
	call cprintf
	call pline
	ret
.restart:
	jmp 0xffff:0x0000
;out hex
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
;count
count_main:
	mov si,mcfrom
	mov al,0x10|WHITE
	call cprintf
	mov di,countbuf
	call readl
	mov si,countbuf
	call Number
	mov [COUNTFROM],ax
	
	mov si,mcto
	mov al,0x10|WHITE
	call cprintf
	mov di,countbuf
	call readl
	mov si,countbuf
	call Number
	mov [COUNTTO],ax
	mov ax,[COUNTFROM]
	mov bx,[COUNTTO]
	cmp ax,bx
	jle .cloop
	xchg ax,bx
	mov [COUNTFROM],ax
	mov [COUNTTO],bx
.cloop:
	push ax
	call printn
	pop ax
	cmp ax,[COUNTTO]
	je .done
	inc ax
	jmp .cloop
.done:
	call pline
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
    mov bx,10
    mov cx,0
    mov dx,0
.pushdigits:
    inc cx
    div bx
    push dx
    xor dx,dx
    cmp ax,0
    jne .pushdigits   
.popdigits:
    pop dx
    add dl,'0'
    mov al,dl
    call printc
    loop .popdigits
.done:
    pop dx
    pop cx
    pop bx
    pop ax
    mov si,comma
    mov al,WHITE
	call cprintf
    ret
;fs
fs_write:
	mov si,whatname
	mov al,0x90 | WHITE
	call cprintf
	mov di,fnbuf
	call readl
	mov si,writewhat
	mov al,0x90 | WHITE
	call cprintf
	mov di,fcbuf
	call readl
	mov bx,filetable
	mov cx,0
.findgunmu:;¹÷Ä¸
	cmp cx,MAX_FILES
	jge .full
	mov al,[bx]
	cmp al,0
	je .foundit
	add bx,FILE_ENTRY_SIZE
	inc cx
	jmp .findgunmu
.foundit:
	push di
	push si
	mov si,fnbuf
	mov di,bx
	call strcpy
	add bx,16
	mov si,fcbuf
	mov di,bx
	call strcpy
	pop si
	pop di
	inc byte [filecount]
	mov si,fssuccess
	mov al,0x0a
	call cprintf
	ret
.full:
	mov si,fsfull
	mov al,0x0c
	call cprintf
	ret
fs_list:
	mov bx,filetable
	mov cx,0
.loop:
	cmp cx,MAX_FILES
	jge .done
	mov al,[bx]
	cmp al,0
	je .next
	mov si,bx
	call printf
	call pline
.next:
	add bx,FILE_ENTRY_SIZE
	inc cx
	jmp .loop
.done:
	ret
fs_read:
	mov si,fsreadmsg
	mov al,0x90 | WHITE
	call cprintf
	mov di,fnbuf
	call readl
	mov si,readbeginmsg
	mov al,YELLOW
	call cprintf
	call pline
	mov si,line2
	call printf
	mov bx,filetable
	mov cx,0
.finds:
	cmp cx,MAX_FILES
	jge .gugugaga
	mov al,[bx]
	cmp al,0
	je .next
	push di
	push si
	mov si,fnbuf
	mov di,bx
	call strcmp
	pop si
	pop di
	jc .foundfile
.next:
	add bx,FILE_ENTRY_SIZE
	inc bx
	jmp .finds
.foundfile:
	add bx,16
	call pline
	mov si,bx
	mov al,WHITE
	call cprintf
	call pline
	ret
.gugugaga:
	mov si,fsnotfound
	call printf
	ret

strcpy:
	push ax
.loop:
	lodsb
	stosb
	cmp al,0
	jne .loop
	pop ax
	ret	
;strcmp
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
strcmp_pro:
    push si
    push di
    push bx
.loop:
    mov al,[si]
    cmp al,0
    je .match
    mov bl,[di]
    cmp al,bl
    jne .nomatch
    inc si
    inc di
    jmp .loop
.match:
    stc
    jmp .done
.nomatch:
    clc
.done:
    pop bx
    pop di
    pop si
    ret
    
runprog:
	mov ah,0x00
    mov dl,0x00
    int 0x13
	jc .lerr
	mov ax,0x0000
	mov es,ax
	;mov bx,0x9E00
	mov ah,0x02
	mov al,3
	mov ch,0
	;mov cl,22
	mov dh,0
	mov dl,0x00
	int 0x13
	jc .lerr
	ret
.lerr:
	mov si,comma
	call printf
	ret
;current time
gettime:
    mov ah,0x02
    int 0x1a               
    mov al,ch
    call pbcdb
    mov al,':'
    call printc
    mov al,cl
    call pbcdb
    mov al,':'
    call printc
    mov al,dh
    call pbcdb
    call pline
    ret
pbcdb:
    push ax
    push cx
    mov cl,al
    shr al,4
    add al,'0'
    call printc
    mov al,cl
    and al,0x0f
    add al,'0'
    call printc
    pop cx
    pop ax
    ret
printc:
    push ax
    mov ah,0x0e
    int 0x10
    pop ax
    ret
pline:
    mov al,0x0d
    call printc
    mov al,0x0a
    call printc
    ret
debugit:
	;save them!
	mov [savedax],ax
    mov [savedbx],bx
    mov [savedcx],cx
    mov [saveddx],dx
    mov [savedsi],si
    mov [saveddi],di
    mov [savedbp],bp
    mov [savedsp],sp
    mov [savedcs],cs
    mov [savedds],ds
    mov [savedes],es
    mov [savedss],ss
    pushf
    pop ax
    
    call pline
    ;start debug
    mov si,de_ax
    mov al,YELLOW
    call cprintf
    mov ax,[savedax]
    call printh
    mov si,comma
    mov al,WHITE
    call cprintf
    
    mov si,de_bx
    mov al,YELLOW
    call cprintf
    mov ax,[savedbx]
    call printh
    mov si,comma
    mov al,WHITE
    call cprintf    
    
    mov si,de_cx
    mov al,YELLOW
    call cprintf
    mov ax,[savedcx]
    call printh
    mov si,comma
    mov al,WHITE
    call cprintf   

    mov si,de_dx
    mov al,YELLOW
    call cprintf
    mov ax,[saveddx]
    call printh
    mov si,comma
    mov al,WHITE
    call cprintf  
    call pline
    mov si,de_si
    mov al,YELLOW
    call cprintf
    mov ax,[savedsi]
    call printh
    mov si,comma
    mov al,WHITE
    call cprintf
    
    mov si,de_di
    mov al,YELLOW
    call cprintf
    mov ax,[saveddi]
    call printh
    mov si,comma
    mov al,WHITE
    call cprintf
    
    mov si,de_bp
    mov al,YELLOW
    call cprintf
    mov ax,[savedbp]
    call printh
    mov si,comma
    mov al,WHITE
    call cprintf
    
    mov si,de_sp
    mov al,YELLOW
    call cprintf
    mov ax,[savedsp]
    call printh
    mov si,comma
    mov al,WHITE
    call cprintf
    call pline
    
    mov si,de_cs
    mov al,YELLOW
    call cprintf
    mov ax,[savedcs]
    call printh
    mov si,comma
    mov al,WHITE
    call cprintf
    
    mov si,de_ds
    mov al,YELLOW
    call cprintf
    mov ax,[savedds]
    call printh
    mov si,comma
    mov al,WHITE
    call cprintf
    
    mov si,de_ss
    mov al,YELLOW
    call cprintf
    mov ax,[savedss]
    call printh
    mov si,comma
    mov al,WHITE
    call cprintf
    
    mov si,de_es
    mov al,YELLOW
    call cprintf
    mov ax,[savedes]
    call printh
    
    call pline
    ;end
    call pline
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
ikunikun:
	mov si,abcde
	call printf
	call ikunikun
blue:
	mov ax,0x0003
	int 0x10
	mov ax,0xB800
	mov es,ax
	xor di,di
	mov cx,2000
	mov ax,0x1F20
	cld
	rep stosw
	mov si,bosd
	call printf
	mov si,bosd2
	call printf
	syscall
	ret

;main
msg db 'iKun Operating System(KunOS) Kernel',0x0D,0x0A,'Copyright(C)Hello-Programming 2023-2026',0x0D,0x0A,'Type "help" to get the guide.',0x0D,0x0A,0
pmt db '~root$',0
chelp db 'help',0
ctime db 'time',0
ccls db 'clear',0
cikun db 'ikun',0
creb db 'reb',0
cinfo db 'info',0
cblue db 'blue',0
cdate db 'date',0
chlt db 'hlt',0
cchusr db 'chusr',0
cwrite db 'fsw',0
clist db 'fsl',0
cread db 'fsr',0
cout db 'out',0
ccount db 'count',0
ccolortest db 'ctest',0
capp db 'sd',0
capp_calc db 'calc',0
cal db 'al',0
cdebug db 'debug',0

boot_drive db 0x80
sector_s db 0
sector_c db 0

de_ax db 'AX=',0
de_bx db 'BX=',0
de_cx db 'CX=',0
de_dx db 'DX=',0
de_si db 'SI=',0
de_di db 'DI=',0
de_bp db 'BP=',0
de_sp db 'SP=',0
de_cs db 'CS=',0
de_ds db 'DS=',0
de_ss db 'SS=',0
de_es db 'ES=',0
savedax dw 0
savedbx dw 0
savedcx dw 0
saveddx dw 0
savedsi dw 0
saveddi dw 0
savedbp dw 0
savedsp dw 0
savedcs dw 0
savedds dw 0
savedes dw 0
savedss dw 0

dmsg db 'Current date:',0
lines db '============',0x0D,0x0A,0
upmt db 'Before using,please enter your username:',0
helptext db 'KunOS Available Commands:',0x0D,0x0A,'================',0x0D,0x0A,'time:Get the current time.',0x0D,0x0A,'clear:Clean all contents.',0x0D,0x0A,0
helptext2 db 'reb:Re-start the system',0x0D,0x0A,'info:Show information about KunOS',0x0D,0x0A,'blue:Blue Screen(?)',0x0D,0x0A,'date:Get current date.',0x0D,0x0A,'hlt:Shutdown',0x0D,0x0A,0
helptext3 db 'chusr:Change the username.',0x0D,0x0A,'fsw:Create a file.',0x0D,0x0A,'fsl:Show file list.',0x0A,0x0D,'fsr:Read a file.',0x0D,0x0A,'(Easter egg:try to type "ikun")',0x0D,0x0A,0
helptext4 db 'out [Text]:Display [Text] on the screen.',0x0A,0x0D,'count:Count numbers from <X> to <Y>.',0x0A,0x0D,'ctest:Color test.',0x0A,0x0D,"al:Get KunOS Applications list.",0x0A,0x0D,'debug:Show registers.',0x0d,0x0a,'================',0x0D,0x0A,0
chusrmsg db 'Please Enter Your New Username,then press ENTER>>>',0
unknown db "Oops,that isn't a available command!",0x0D,0x0A,0
unknown2 db "Type 'HELP' to get available commands.",0x0D,0x0A,0
abcde db 'N         ',0x0A,0x0D,
	  db 'UN        ',0x0A,0x0D,
	  db 'KUN       ',0x0A,0x0D,
	  db ' KUN      ',0x0A,0x0D,
	  db '  KUN     ',0x0A,0x0D,
	  db '   KUN    ',0x0A,0x0D,
	  db '    KUN   ',0x0A,0x0D,
	  db '     KUN  ',0x0A,0x0D,
	  db '      KUN ',0x0A,0x0D,
	  db '       KUN',0x0A,0x0D,
	  db '        KU',0x0A,0x0D,
	  db '         K',0x0A,0x0D,0
bosd db 0x0D,0x0A,0x0D,0x0A,':(',0x0D,0x0A,0x0D,0x0A,0
bosd2 db 'Your PC ran into a problem and needs to restart.',0x0D,0x0A,'We are just collecting some error info,and then we will restart for you.',0x0D,0x0A,0x0D,0x0A,'0% complete.',0
haltmsg db 'SYSTEM HALTED!',0x0D,0x0A,"Now you can turn off your computer.",0
whatname db 'Bro what is the file name?',0 
writewhat db 'Bro write what?',0
fssuccess db 'Success,jinitaimei!',0x0A,0x0D,0
fsfailed db 'Oh no I can not write it!',0x0A,0x0D,0
fsfull db 'I cannot write it because:full!',0
fsreadmsg db 'Enter a file name:',0
fsnotfound db 'No such file.',0x0A,0x0D,0
filebeginmsg db 'Files',0
line2 db '-----------------',0
readbeginmsg db 'Here is the content',0
exampletext db 'Kun',0
mcfrom db "From:",0
mcto db "To:",0
comma db ", ",0
infoinfo db 0x0A,0x0D,'KunOS version 2.1(2026/8/28 13:09:50)',0x0A,0x0D,0
infoinfo2 db '[Update log]',0x0A,0x0D,'File system simulation',0x0A,0x0D,'colorful text display',0x0A,0x0D,'"out" and "count" command',0x0A,0x0D,0
infoinfo3 db '[Personal Website]',0x0A,0x0D,'https://hellopgrmm.github.io/',0x0A,0x0D,'Have fun,bro!',0x0A,0x0D,0x0A,0x0D,0
infoapl db 'sd:Simple Draw Program',0x0A,0x0D,'calc:Calculator',0x0d,0x0a,0

uinput times 16 db 0
input times 64 db 0
fnbuf times 16 db 0
fcbuf times 256 db 0
countbuf times 16 db 0

COUNTFROM dw 0
COUNTTO dw 0

userflag dw 0

MAX_FILES equ 16
FILE_ENTRY_SIZE equ 16 + 256
filetable:
	times MAX_FILES * FILE_ENTRY_SIZE db 0
filecount:
	db 0
times 17*512-($-$$) db 0