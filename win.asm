locals @@
.model tiny

.code
org 100h

;-------------------MACRO_BOX_START-------------------

;=====================================================
; Move to screen part of videoseg
; Entry:     
; Exit:      es         - start of screen
; Destr:     cx
;=====================================================

GoVideoSegScr   macro

                mov cx, 0b800h                ; cx = VIDEOSEG
                mov es, cx                    ; es = cx 

                endm

;=====================================================
; Puts arg from PSP to dest
; Entry:     bx         - arg pos
; Exit:      dest       - arg
;            bx         - pos after arg
; Destr:     ax, cx
;=====================================================

GetArg          macro dest

                mov cx, [bx]
                sub cx, '00'
                mov ax, 10d
                mul cl
                xor cl, cl
                add al, ch
                xor ah, ah
                mov dest, ax
                add bx, 3d

                endm

;--------------------MACRO_BOX_END--------------------

Start:          W_HEIGHT            dw 0h     ; not for user
                W_WIDTH             dw 0h     ; not for user
                WINDOW_START        dw 0h     ; not for user
                BTW_LINES_STEP      dw 0h     ; not for user
                MID_OF_SCREEN       dw 0h     ; not for user
                DOS_WINDOW_HEIGHT   dw 25     ; might be cnst (for user)
                DOS_WINDOW_WIDTH    dw 80     ; might be cnst (for user)
                W_HEIGHT_START      dw 0h     ; must be > 3, %2 must be = 1, for user
                W_WIDTH_START       dw 0h     ; must be > 3, %2 must be = 0, for user
                WINDOW_START_X      dw 0h     ; for user
                WINDOW_START_Y      dw 0h     ; for user
                COLOR_THEME         db 0h     ; for user

                MSG_START_X         dw 0h     ; for user
                MSG_START_Y         dw 0h     ; for user

                mov bx, 82h
                GetArg dx
                ;GetArg W_HEIGHT_START
                mov W_HEIGHT_START, dx
                GetArg dx
                ;GetArg W_WIDTH_START
                mov W_WIDTH_START, dx
                GetArg dx
                ;GetArg WINDOW_START_X
                mov WINDOW_START_X, dx
                GetArg dx
                ;GetArg WINDOW_START_Y
                mov WINDOW_START_Y, dx
                ;mov W_HEIGHT_START, 13       ; W_HEIGHT_START = 13
                ;mov W_WIDTH_START, 40        ; W_WIDTH_START = 40
                ;mov WINDOW_START_X, 22       ; WINDOW_START_X = 22
                ;mov WINDOW_START_Y, 12       ; WINDOW_START_Y = 12
                mov COLOR_THEME, 4eh         ; COLOR_THEME = 4eh
                call MakeWindow               ; first window

                mov MSG_START_X, 22           ; MSG_START_X = 22
                mov MSG_START_Y, 11           ; MSG_START_Y = 11
                mov bx, offset Msg2           ; bx = &Msg2
                call StrToCoord               ; StrToCoord

                mov W_HEIGHT_START, 7         ; W_HEIGHT_START = 7
                mov W_WIDTH_START, 20         ; W_WIDTH_START = 20
                mov WINDOW_START_X, 60        ; WINDOW_START_X = 60
                mov WINDOW_START_Y, 18        ; WINDOW_START_Y = 18
                mov COLOR_THEME, 3bh          ; COLOR_THEME = 3bh
                call MakeWindow               ; second window

                mov MSG_START_X, 60           ; MSG_START_X = 60
                mov MSG_START_Y, 17           ; MSG_START_Y = 17
                mov bx, offset Msg            ; bx = &Msg
                call StrToCoord

                ret

;=====================================================
; Draw a horizontal line
; Entry:     ah         - color attr
;            al         - first char to draw
;            bl         - second char to draw W_WIDTH - 2 times
;            bb         - third char to draw
;            es:[di]    - start pos
;            cx         - line length - 2
; Exit:      es:[di] is on the end of line
; Destr:     al
;=====================================================

DrawLineHoriz   proc
                
                cld
                stosw                         ; mov es:[di], ax
                mov al, bl
                rep stosw                     ; while (--cx) mov es:[di], ax
                mov al, bh
                stosw                         ; mov es:[di], ax

                ret
                endp

;=====================================================
; Count string lenght
; Entry:     bx - & of first byte of string
; Exit:      ax is leght of the line
; Destr:     bx
;=====================================================

Strlen          proc
                
                xor ax, ax                    ; ax = 0
@@Until_nz:     inc bx                        ; bx++
                inc ax                        ; ax++
                cmp byte ptr [bx], 00h        ;
                jne @@Until_nz                ;

                ret
                endp

;=====================================================
; Print string in videoseg
; Entry:     bx         - & of first byte of string
;            es:[di]    - start pos
;            ah         - color attr
; Exit:      es:[di] is on the end of string in videoseg
; Destr:     bx, dl
;=====================================================

Strvid          proc

@@Str_to_vid:   mov dl, [bx]                  ; dl = [bx]
                mov byte ptr es:[di], dl      ; es:[di] = [bx]
                inc di                        ; ++di
                mov byte ptr es:[di], ah      ; es:[di] = ah
                inc di                        ; ++di
                inc bx                        ; ++bx
                cmp byte ptr [bx], 00h 
                jne @@Str_to_vid              ; if ([bx - 1] != '\0') {goto Str_to_vid}

                ret
                endp

;=====================================================
; Print string centered
; Entry:     ah         - color attr
;            bx         - first byte of string
;            es:[di]    - center pos
; Exit:      es:[di] is on the end of string in videoseg
; Destr:     ax, bx, dl
;=====================================================

StrToCoord      proc

                push bx
                push ax
                mov ax, MSG_START_Y
                mul DOS_WINDOW_WIDTH
                add ax, MSG_START_X
                shl ax, 1
                mov di, ax
                call Strlen                   ; Strlen
                shr ax, 1                     ;
                shl ax, 1                     ; ax -= ax % 2
                sub di, ax                    ; di -= ax
                pop ax
                pop bx
                call Strvid                   ; Strvid

                ret
                endp


;=====================================================
; NOT FOR USER (PRIVATE)! Calculate coordinates for drawing window
; Entry:     W_HEIGHT            not for user
;            W_WIDTH             not for user
;            WINDOW_START        not for user
;            BTW_LINES_STEP      not for user
;            MID_OF_SCREEN       not for user
;            DOS_WINDOW_HEIGHT   might be cnst (for user)
;            DOS_WINDOW_WIDTH    might be cnst (for user)
;            W_HEIGHT_START      must be > 3, %2 must be = 1, for user
;            W_WIDTH_START       must be > 3, %2 must be = 0, for user
;            WINDOW_START_X      for user
;            WINDOW_START_Y      for user
;            COLOR_THEME         for user
; Exit:      W_HEIGHT
;            W_WIDTH
;            WINDOW_START
;            BTW_LINES_STEP
; Destr:     ax, cx, dx
;=====================================================

CalcWindow      proc

                mov ax, W_WIDTH_START
                sub ax, dx
                mov W_WIDTH, ax
                mov ax, W_HEIGHT_START
                sub ax, dx
                mov W_HEIGHT, ax
                mov ax, WINDOW_START_X
                shl ax, 1
                sub ax, W_WIDTH
                mov WINDOW_START, ax
                mov ax, WINDOW_START_Y
                shl ax, 1
                sub ax, W_HEIGHT
                dec ax
                mov cx, dx
                mul DOS_WINDOW_WIDTH
                mov dx, cx
                add WINDOW_START, ax
                mov ax, DOS_WINDOW_WIDTH
                mov BTW_LINES_STEP, ax
                sub ax, W_WIDTH
                mov BTW_LINES_STEP, ax
                shl BTW_LINES_STEP, 1
                mov ah, COLOR_THEME 

                ret
                endp

;=====================================================
; Just pause the programm for a while
; Entry:     -
; Exit:      -
; Destr:     cx
;=====================================================

WaitPls         proc

                mov cx, 65500
@@LoopNop:      nop
                loop @@LoopNop

                ret
                endp

;=====================================================
; Draw a vertical line
; Entry:     ah         - color attr
;            al         - char to draw
;            bx         - dos window width
;            es:[di]    - start pos
;            cx         - line length
; Exit:      es:[di] is on the end of line
; Destr:     cx
;=====================================================

DrawLineVert    proc
                
@@WhileVert:    mov es:[di], ax               ; es:[di] = ax
                add di, bx                    ; di += bx
                dec cx                        ; --cx
                cmp cx, 0                     ;
                jne @@WhileVert               ; if (cx != 0) {goto @@WhileVert}

                ret
                endp                          ; return

;=====================================================
; NOT FOR USER (PRIVATE)! Calculate coordinates for drawing window
; Entry:     W_HEIGHT              not for user
;            W_WIDTH               not for user
;            WINDOW_START          not for user
;            BTW_LINES_STEP        not for user
;            DOS_WINDOW_HEIGHT     might be cnst (for user)
;            DOS_WINDOW_WIDTH      might be cnst (for user)
;            W_HEIGHT_START        must be > 3, %2 must be = 1, for user
;            W_WIDTH_START         must be > 3, %2 must be = 0, for user
; Exit:      -
; Destr:     ax, bx, cx, di
;=====================================================

MakeShadow      proc

                add di, BTW_LINES_STEP        ; di += BTW_LINES_STEP + 2
                add di, 2

                mov ah, 0eeh                  ; ah = 0eeh
                mov cx, W_WIDTH               ; cx = W_WIDTH - 2
                sub cx, 2
                mov bx, (20h shl 8) or 20h    ; bh = 20h, bl = 20h
                mov al, 20h                   ; al = 20h
                call DrawLineHoriz            ; DrawLineHoriz

                mov di, DOS_WINDOW_WIDTH
                add di, W_WIDTH
                shl di, 1
                add di, WINDOW_START          ; di = WINDOW_START + W_WIDTH * 2 + DOS_WINDOW_WIDTH * 2
                mov bx, DOS_WINDOW_WIDTH
                shl bx, 1                     ; bx = DOS_WINDOW_WIDTH * 2
                mov cx, W_HEIGHT              ; cx = W_HEIGHT
                dec cx
                call DrawLineVert             ; DrawLineVert

                ret
                endp

;=====================================================
; Makes window
; Entry:    W_HEIGHT               not for user
;           W_WIDTH                not for user
;           WINDOW_START           not for user
;           BTW_LINES_STEP         not for user
;           MID_OF_SCREEN          not for user
;           DOS_WINDOW_HEIGHT      might be cnst (for user)
;           DOS_WINDOW_WIDTH       might be cnst (for user)
;           W_HEIGHT_START         must be > 3, %2 must be = 1, for user
;           W_WIDTH_START          must be > 3, %2 must be = 0, for user
;           WINDOW_START_X         for user
;           WINDOW_START_Y         for user
;           COLOR_THEME            for user
; Exit:     -
; Destr:    ax, bx, cx, dx, di
;=====================================================

MakeWindow      proc

                GoVideoSegScr

                mov dx, W_HEIGHT_START
                sub dx, 3

@@WindowFrame:  call CalcWindow

                mov di, WINDOW_START
                mov cx, W_WIDTH
                sub cx, 2

                mov bx, (0bbh shl 8) or 0cdh
                mov al, 0c9h
                call DrawLineHoriz
                add di, BTW_LINES_STEP

                mov bx, (0bah shl 8) or 20h
                mov al, 0bah
                mov cx, W_HEIGHT
                sub cx, 2

@@LoopMain:     push cx
                mov cx, W_WIDTH
                sub cx, 2

                call DrawLineHoriz
                add di, BTW_LINES_STEP
                pop cx
                loop @@LoopMain

                mov cx, W_WIDTH
                sub cx, 2

                mov bx, (0bch shl 8) or 0cdh
                mov al, 0c8h
                call DrawLineHoriz

                call MakeShadow
                mov ah, COLOR_THEME 

                call WaitPls

                sub dx, 2
                cmp dx, 0
                jg @@WindowFrame

                ret
                endp

Msg:            db 'Hello, World!!!', 00h     ; "Hello, World!!!\0"

Msg2:           db 'Hello, new day!!!', 00h   ; "Hello, World!!!\0"

end Start
