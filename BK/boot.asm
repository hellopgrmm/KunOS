[org 0x7c00]
[bits 16]
init:
	mov [boot_drive],dl
	
	xor ax,ax
	mov ds,ax
	mov es,ax
	mov ss,ax
	mov sp,0x7c00
	;print
	mov si,bootmsg
	call prints
	
	mov ah,0x02
	mov al,32
	mov ch,0
	mov cl,2
	mov dh,0
	mov dl,[boot_drive]
	mov bx,0x7e00
	int 0x13
	jc initerr ;if error then loop
	
	mov si,successmsg;If success
	call prints
	mov si,loadingmsg
	call prints
	
	jmp 0x0000:0x7e00;jump to kernel
;if init error
initerr:
	mov si,failedmsg
	call prints
	
	cli
	hlt
	jmp initerr
prints:
	lodsb
	or al,al
	jz .done
	mov ah,0x0e
	int 0x10
	jmp prints
.done:
	ret
	
boot_drive: db 0
bootmsg db 'Booting to kernel...',0x0D,0x0A,0
successmsg db 'Success!',0x0D,0x0A,0
loadingmsg db 'Entering kernel,please wait...',0x0D,0x0A,0x0D,0x0A,0
failedmsg db '!E!Failed to boot.',0x0D,0x0A,0
times 510-($-$$) db 0
dw 0xAA55