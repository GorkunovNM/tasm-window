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
				mov bx, 80 * (25 - W_HEIGHT) + (80 - W_WIDTH)
				;mov bx, ax
				;add bx, 80 - W_WIDTH
				;add bx, dx
				mov ax, 0
				mov cx, 0

Until1:			push bx
				add bx, ax
				add ax, 80 * 2

Until2:			push bx
				add bx, cx
				mov byte ptr es:[bx], 20h
				inc cx
				inc bx
				mov byte ptr es:[bx], 4eh
				inc cx
				pop bx

				;push cx
				;add cx, dx
				;add cx, dx
				cmp cx, W_WIDTH * 2
				;mov cx, 0
Pause:			;inc cx
				;nop
				;nop
				;nop
				;cmp cx, 100
				;jne Pause
				;pop cx
				;jne Until2
				jl Until2

				mov cx, 0
				pop bx

				;push ax
				;mov cx, 160
				;div cx
				;mov cx, 0
				;add ax, dx
				cmp ax, W_HEIGHT * 80 * 2
				;cmp ax, W_HEIGHT
				;pop ax
				;jne Until1
				jl Until1

				;sub dx, 2
				;cmp dx, 0
				;jge Dx_step

				mov ax, 4c00h 
				int 21h

end				Prepare_to_vid