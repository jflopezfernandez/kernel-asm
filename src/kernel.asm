org 0x7C00
bits 16

	mov ax, 0
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov sp, 0x7C00

	mov si, welcome
	call print_string

mainloop:
	mov si, prompt
	call print_string

	mov di, buffer
	call get_string

	mov si, buffer
	cmp byte [si], 0
	je mainloop

	mov si, buffer
	mov di, cmd_hi
	call strcmp
	jc .helloworld

	mov si, buffer
	mov di, cmd_help
	call strcmp
	jc .help

	mov si, badcommand
	call print_string
	jmp mainloop

.helloworld:
	mov si, msg_helloworld
	call print_string

	jmp mainloop

.help:
	mov si, msg_help
	call print_string

	jmp mainloop

welcome db 'Welcome to My OS', 0x0D, 0x0A, 0
msg_helloworld db 'Hello OSDev World', 0x0D, 0x0A, 0
badcommand db'Bad command entered.', 0x0D, 0x0A, 0
prompt db '>', 0
cmd_hi db 'hi', 0
cmd_help db 'help', 0
msg_help db 'help', 0
buffer times 64 db 0

print_string:
	lodsb

	or al, al
	jz .done

	mov ah, 0x0E
	int 0x10

	jmp print_string

.done:
	ret

get_string:
	xor cl, cl

.loop:
	mov ah, 0
	int 0x16 ; wait for keypress

	cmp al, 0x08 ; backspace pressed?
	je .backspace

	cmp al, 0x0D ; enter pressed?
	je .done

	cmp cl, 0x3F ; 63 chars entered?
	je .loop

	mov ah, 0x0E
	int 0x10     ; print out character

	stosb ; put character in buffer
	inc cl
	jmp .loop

.backspace:
	cmp cl, 0
	je .loop

	dec di
	mov byte [di], 0
	dec cl

	mov ah, 0x0E
	mov al, 0x08
	int 10h

	mov al, ' '
	int 10h

	mov al, 0x08
	int 10h

	jmp .loop

.done:
	mov al, 0
	stosb

	mov ah, 0x0E
	mov al, 0x0D
	int 0x10
	mov al, 0x0A
	int 0x10

	ret

strcmp:
.loop:
	mov al, [si]
	mov bl, [di]
	cmp al, bl
	jne .notequal

	cmp al, 0
	je .done

	inc di
	inc si
	jmp .loop

.notequal:
	clc ; not equal, clear the carry flag
	ret

.done:
	stc ; equal, set the carry flag
	ret

	times 510-($-$$) db 0
	dw 0AA55h ; BIOS-required signature

