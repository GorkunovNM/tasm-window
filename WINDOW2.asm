.model tiny
.code
org 100h

;--------------------------
VIDEOSEG	equ 0b800h
W_HEIGHT	equ 13
W_WIDTH		equ 40
;--------------------------

Prepare_to_vid:	;mov dx, W_HEIGHT - 1
				mov cx, VIDEOSEG								; cx = VIDEOSEG
				mov es, cx										; es = cx 
Dx_step:		;mov ax, 25 - W_HEIGHT
				;add ax, dx
				;mov cx, 80
				;mul cx
				mov bx, 80 * (25 - W_HEIGHT) + (80 - W_WIDTH)	; bx = 80 * ...
				;mov bx, ax
				;add bx, 80 - W_WIDTH
				;add bx, dx
				xor ax, ax					; ax = 0
				xor cx, cx					; cx = 0

Until1:			push bx
				add bx, ax					; bx += ax
				add ax, 80 * 2				; bx += cx

Until2:			push bx
				add bx, cx					; bx += cx
				mov byte ptr es:[bx], 20h
				inc cx						; ++cx
				inc bx						; ++bx
				mov byte ptr es:[bx], 4eh
				inc cx						; ++cx
				pop bx

				;push cx
				;add cx, dx
				;add cx, dx
				cmp cx, W_WIDTH * 2			;
				;mov cx, 0
Pause:			;inc cx
				;nop
				;nop
				;nop
				;cmp cx, 100
				;jne Pause
				;pop cx
				;jne Until2
				jl Until2					; if (cx < W_WIDTH * 2) goto Until2

				xor cx, cx					; cx = 0
				pop bx

				;push ax
				;mov cx, 160
				;div cx
				;mov cx, 0
				;add ax, dx
				cmp ax, W_HEIGHT * 80 * 2	;
				;cmp ax, W_HEIGHT
				;pop ax
				;jne Until1
				jl Until1					; if (ax < W_HEIGHT * 80 * 2) goto Until1

				;sub dx, 2
				;cmp dx, 0
				;jge Dx_step

Start_vid:		mov bx, offset Msg			; bx = &Msg
				mov cx, 80 * 12 + 40		; mid of screen
				xor ax, ax					; ax = 0

Msg_len_func:	inc bx						; bx++
				inc ax						; ax++
				cmp byte ptr [bx], 00h 
				jne Msg_len_func			; if ([bx] != '\0') {goto Msg_len_func}

To_mid_of_scr:	mov bx, offset Msg			; bx = &Msg	
				shr ax, 1					; ax /= bx
				sub cx, ax					; cx -= ax
				add cx, cx					; cx *= 2

Str_to_vid:		mov dl, [bx]				; dl = [bx]
				push bx
				mov bx, cx					; bx = cx
				mov byte ptr es:[bx], dl	; [bx] = dl
				inc bx						; bx++
				mov byte ptr es:[bx], 4eh	; [bx] = 4eh
				inc bx						; bx++
				mov cx, bx					; cx = bx
				pop bx
				inc bx						; bx++
				cmp byte ptr [bx], 00h 
				jne Str_to_vid				; if ([bx] != '\0') {goto Str_to_vid}

				mov ax, 4c00h 				;
				int 21h						; {exit(0)}

Msg:			db 'Hello, World!!!!!!!!!!!!!!!!!!!!!!!', 00h	; "Hello, World!!!\0"

end				Prepare_to_vid