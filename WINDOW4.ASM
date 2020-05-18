locals @@
.model tiny

.data

W_HEIGHT			dw 0h
W_WIDTH				dw 0h
WINDOW_START		dw 0h
BTW_LINES_STEP		dw 0h
TEMP_VAR			dw 0h

.code
org 100h

;--------------------------
VIDEOSEG			equ 0b800h
;W_HEIGHT			equ 13
;W_WIDTH			equ 40
W_HEIGHT_START		equ 13
W_WIDTH_START		equ 40
DOS_WINDOW_HEIGHT	equ 25
DOS_WINDOW_WIDTH	equ 80
COLOR_THEME			equ 4eh
MID_OF_SCREEN		equ DOS_WINDOW_WIDTH * DOS_WINDOW_HEIGHT
;WINDOW_START		equ DOS_WINDOW_WIDTH * (DOS_WINDOW_HEIGHT - W_HEIGHT) + DOS_WINDOW_WIDTH - W_WIDTH
;BTW_LINES_STEP		equ (DOS_WINDOW_WIDTH - W_WIDTH) * 2
;--------------------------

Start:			mov cx, VIDEOSEG								; cx = VIDEOSEG
				mov es, cx										; es = cx 
				mov dx, W_HEIGHT_START - 3

WindowFrame:	call CalcWindow

				mov di, WINDOW_START
				mov cx, W_WIDTH
				sub cx, 2

				mov bx, (0bbh shl 8) or 0cdh
				mov al, 0c9h
				call DrawLine
				add di, BTW_LINES_STEP

				mov bx, (0bah shl 8) or 20h
				mov al, 0bah
				mov cx, W_HEIGHT
				sub cx, 2

LoopMain:		push cx				;!!!!!!!!!!!
				mov cx, W_WIDTH
				sub cx, 2

				call DrawLine
				add di, BTW_LINES_STEP
				pop cx
				loop LoopMain

				mov cx, W_WIDTH
				sub cx, 2

				mov bx, (0bch shl 8) or 0cdh
				mov al, 0c8h
				call DrawLine

				call MakeShadow
				mov ah, COLOR_THEME 

				call WaitPls

				sub dx, 2
				cmp dx, 0
				jg WindowFrame

				mov bx, offset Msg			; bx = &Msg
				mov di, MID_OF_SCREEN
				call StrToMid

				ret

;=====================================================
; Draw a horizontal line
; Entry:	ah     	- color attr
;			al     	- first char to draw
;			bl     	- second char to draw W_WIDTH - 2 times
;			bb     	- third char to draw
;			es:[di]	- start pos
;			cx     	- line length - 2
; Exit:		es:[di] is on the end of line
; Destr:	al
;=====================================================

DrawLine		proc
				
				cld
				stosw
				mov al, bl
				rep stosw
				mov al, bh
				stosw

				ret
				endp

;=====================================================
; Count string lenght
; Entry:	bx - first byte of string
; Exit:		ax is leght of the line
; Destr:	bx
;=====================================================

Strlen			proc
				
				xor ax, ax
@@Until_nz:		inc bx						; bx++
				inc ax						; ax++
				cmp byte ptr [bx], 00h 
				jne @@Until_nz

				ret
				endp

;=====================================================
; Print string in videoseg
; Entry:	bx			- first byte of string
;			es:[di]		- start pos
;			ah     		- color attr
; Exit:		es:[di] is on the end of string in videoseg
; Destr:	bx, dl
;=====================================================

Strvid			proc

@@Str_to_vid:	mov dl, [bx]
				mov byte ptr es:[di], dl			; es:[di] = [bx]
				inc di								; ++di
				mov byte ptr es:[di], ah			; es:[di] = ah
				inc di								; ++di
				inc bx								; ++bx
				cmp byte ptr [bx], 00h 
				jne @@Str_to_vid					; if ([bx - 1] != '\0') {goto Str_to_vid}

				ret
				endp

;=====================================================
; Print string centered
; Entry:	ah     	- color attr
;			bx		- first byte of string
;			es:[di]	- center pos
; Exit:		es:[di] is on the end of string in videoseg
; Destr:	ax, bx, dl
;=====================================================

StrToMid		proc

				push bx
				push ax
				call Strlen
				shr ax, 1
				shl ax, 1
				sub di, ax
				pop ax
				pop bx
				call Strvid

				ret
				endp


;=====================================================
; -
; Entry:	-
; Exit:		-
; Destr:	-
;=====================================================

CalcWindow		proc

				;mov W_WIDTH, W_WIDTH_START
				mov ax, W_WIDTH_START
				sub ax, dx
				mov W_WIDTH, ax
				mov ax, W_HEIGHT_START
				sub ax, dx
				mov W_HEIGHT, ax
				mov WINDOW_START, DOS_WINDOW_WIDTH
				mov ax, WINDOW_START
				sub ax, W_WIDTH
				mov WINDOW_START, ax
				mov TEMP_VAR, DOS_WINDOW_HEIGHT
				mov ax, TEMP_VAR
				sub ax, W_HEIGHT
				mov TEMP_VAR, ax
				mov ax, TEMP_VAR
				mov bx, DOS_WINDOW_WIDTH
				mov cx, dx
				mul bx
				mov dx, cx
				add WINDOW_START, ax
				mov BTW_LINES_STEP, DOS_WINDOW_WIDTH
				mov ax, BTW_LINES_STEP
				sub ax, W_WIDTH
				mov BTW_LINES_STEP, ax
				shl BTW_LINES_STEP, 1
				mov ah, COLOR_THEME 

				ret
				endp

;=====================================================
; -
; Entry:	-
; Exit:		-
; Destr:	-
;=====================================================

WaitPls			proc

				mov cx, 65500
@@LoopNop:		nop
				loop @@LoopNop

				ret
				endp

;=====================================================
; Draw a vertical line
; Entry:	ah     	- color attr
;			al     	- char to draw
;			bx		- dos window width
;			es:[di]	- start pos
;			cx     	- line length
; Exit:		es:[di] is on the end of line
; Destr:	cx
;=====================================================

DrawLineVert	proc
				
@@WhileVert:	mov es:[di], ax						; es:[di] = ax
				add di, bx							; di += bx
				dec cx								; --cx
				cmp cx, 0							;
				jne @@WhileVert						; if (cx != 0) {goto @@WhileVert}

				ret
				endp								; return

;=====================================================
; -
; Entry:	-
; Exit:		-
; Destr:	-
;=====================================================

MakeShadow		proc

				add di, BTW_LINES_STEP				; di += BTW_LINES_STEP + 2
				add di, 2

				mov ah, 0eeh						; ah = 0eeh
				mov cx, W_WIDTH						; cx = W_WIDTH - 2
				sub cx, 2
				mov bx, (20h shl 8) or 20h			; bh = 20h, bl = 20h
				mov al, 20h							; al = 20h
				call DrawLine						; DrawLineHoriz

				mov di, DOS_WINDOW_WIDTH
				add di, W_WIDTH
				shl di, 1
				add di, WINDOW_START				; di = WINDOW_START + W_WIDTH * 2 + DOS_WINDOW_WIDTH * 2
				mov bx, DOS_WINDOW_WIDTH * 2		; bx = DOS_WINDOW_WIDTH * 2
				mov cx, W_HEIGHT					; cx = W_HEIGHT
				dec cx
				call DrawLineVert					; DrawLineVert

				ret
				endp

Msg:			db 'Hello, World!!!', 00h			; "Hello, World!!!\0"

end				Start
