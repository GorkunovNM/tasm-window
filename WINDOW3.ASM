locals @@
.model tiny
.code
org 100h

;-----------------------------------------------------------------------------------------------------
VIDEOSEG			equ 0b800h
W_HEIGHT			equ 13
W_WIDTH				equ 40
DOS_WINDOW_HEIGHT	equ 25
DOS_WINDOW_WIDTH	equ 80
COLOR_THEME			equ 78h
MID_OF_SCREEN		equ DOS_WINDOW_WIDTH * DOS_WINDOW_HEIGHT
WINDOW_START		equ DOS_WINDOW_WIDTH * (DOS_WINDOW_HEIGHT - W_HEIGHT) + DOS_WINDOW_WIDTH - W_WIDTH
BTW_LINES_STEP		equ (DOS_WINDOW_WIDTH - W_WIDTH) * 2
;-----------------------------------------------------------------------------------------------------

Start:			mov cx, VIDEOSEG								; cx = VIDEOSEG
				mov es, cx										; es = cx 

				mov cx, W_WIDTH - 2								; cx = W_WIDTH - 2
				mov bx, (0bbh shl 8) or 0cdh					; bh = 0bbh, bl = 0cdh
				mov ax, (COLOR_THEME shl 8) or 0c9h				; ah = COLOR_THEME, al = 0c9h
				mov di, WINDOW_START							; di = WINDOW_START
				call DrawLineHoriz								; DrawLineHoriz
				add di, BTW_LINES_STEP							; di += BTW_LINES_STEP

				mov bx, (0bah shl 8) or 20h						; bh = 0bah, bl = 20h
				mov al, 0bah									; al = 0bah
				mov cx, W_HEIGHT - 2							; cx = W_HEIGHT - 2
LoopMain:		mov dx, cx										; dx = cx
				mov cx, W_WIDTH - 2								; cx = W_WIDTH - 2
				call DrawLineHoriz								; DrawLineHoriz
				add di, BTW_LINES_STEP							; di += BTW_LINES_STEP
				mov cx, dx										; cx = dx
				loop LoopMain									; for (cx = W_WIDTH - 2; i >= 0; --i)

				mov cx, W_WIDTH - 2								; cx = W_WIDTH - 2
				mov bx, (0bch shl 8) or 0cdh					; bh = 0bch, bl = 0cdh
				mov al, 0c8h									; al = 0c8h
				call DrawLineHoriz								; DrawLineHoriz
				add di, BTW_LINES_STEP + 2						; di += BTW_LINES_STEP + 2

				mov dh, ah										; dh = ah
				mov ah, 0eeh									; ah = 0eeh
				mov cx, W_WIDTH - 2								; cx = W_WIDTH - 2
				mov bx, (20h shl 8) or 20h						; bh = 20h, bl = 20h
				mov al, 20h										; al = 20h
				call DrawLineHoriz								; DrawLineHoriz

				mov di, WINDOW_START + W_WIDTH * 2 + DOS_WINDOW_WIDTH * 2	; di = ...
				mov bx, DOS_WINDOW_WIDTH * 2								; bx = ...
				mov cx, W_HEIGHT - 1										; cx = ...
				call DrawLineVert											; DrawLineVert
				mov ah, dh													; ah = dh

				mov bx, offset Msg								; bx = &Msg
				mov di, MID_OF_SCREEN							; di = MID_OF_SCREEN
				call StrToMid									; StrToMid

				ret												; return 0

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

DrawLineHoriz	proc
				
				cld
				stosw						; mov es:[di], ax
				mov al, bl
				rep stosw					; while (--cx) mov es:[di], ax
				mov al, bh
				stosw						; mov es:[di], ax

				ret
				endp

;=====================================================
; Count string lenght
; Entry:	bx - & of first byte of string
; Exit:		ax is leght of the line
; Destr:	bx
;=====================================================

Strlen			proc
				
				xor ax, ax					; ax = 0
@@Until_nz:		inc bx						; bx++
				inc ax						; ax++
				cmp byte ptr [bx], 00h 		;
				jne @@Until_nz				;

				ret
				endp

;=====================================================
; Print string in videoseg
; Entry:	bx			- & of first byte of string
;			es:[di]		- start pos
;			ah     		- color attr
; Exit:		es:[di] is on the end of string in videoseg
; Destr:	bx, dl
;=====================================================

Strvid			proc

@@Str_to_vid:	mov dl, [bx]						; dl = [bx]
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
				call Strlen							; Strlen
				shr ax, 1							;
				shl ax, 1							; ax -= ax % 2
				sub di, ax							; di -= ax
				pop ax
				pop bx
				call Strvid							; Strvid

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

Msg:			db 'Hello, World!!!', 00h			; "Hello, World!!!\0"

end				Start