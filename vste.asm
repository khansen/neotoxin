.include "game.h"
.include "mmc3.h"
.include "rnme.h"
.include "vste.h"

.charmap "font.tbl"

.codeseg

.public CreditsInit
.public CreditsMain

.extrn ScreenOff:proc
.extrn ClearDisplay:proc
.extrn StatusScreenPal:label
.extrn PAL_LoadPalette:proc
.extrn StatusScreenCHR:label
.extrn LoadCHR:proc
.extrn ScreenOn:proc
.extrn PAL_FadeFromBlack:proc
.extrn SetTimer:proc
.extrn EndPPUString:proc

; End credits vertical scroller, movie-style.

; CreditsInit
; ===========
; Call once to initialize the scroller.

        CreditsInit:
        jsr     ScreenOff
        lda     #H_MIRROR
        sta     MMC3_MIRROR_REG           ; horizontal mirroring
        jsr     ClearDisplay
; set initial PPU write address
        lda     #$28
        sta     pScrollPPU+1
        lda     #$20
        sta     pScrollPPU
        lda     #$23
        sta     pAttribPPU+1
        lda     #$C0
        sta     pAttribPPU
; reset the scroll values
        lda     #$00
        sta     ScrollX
        sta     ScrollY
; start with nametable 0
        lda     ZPCtrl0
        and     #$FC            ; nametable address = $2000
        sta     ZPCtrl0
; set data start address
        lda     #<ScrollData
        sta     pScroller
        lda     #>ScrollData
        sta     pScroller+1
; load palette and CHR
        lda     #<StatusScreenPal
        ldy     #>StatusScreenPal
        jsr     PAL_LoadPalette
        lda     #<StatusScreenCHR
        ldy     #>StatusScreenCHR
        jsr     LoadCHR
; load the credits tune
        lda     #8
        sta     RNME_LoadTune
;
        jsr     ScreenOn
        jsr     PAL_FadeFromBlack
        inc     MainRoutine
      - rts

; CreditsMain
; ===========
; Call every frame to update the scroller.

        CreditsMain:
        lda     FrameCount
        and     #$03            ; only update every 4th frame
        bne     -               ; (we don't want it to scroll too fast :-) )
        inc     ScrollY
        lda     ScrollY
        and     #$07            ; only update nametable every 8th line
        bne     -
        lda     ScrollY
        cmp     #240            ; ScrollY wrap-around?
        bcc     +               ; branch if not
; screen wrap
        lda     #0
        sta     ScrollY         ; reset ScrollY
        lda     ZPCtrl0
        eor     #$02            ; switch to the other nametable
        sta     ZPCtrl0
;
      + lda     pScrollPPU
        clc
        adc     #$20            ; next row on nametable
        sta     pScrollPPU
        bcc     +
        inc     pScrollPPU+1
; check if end of nametable ($3C0) has been reached
      + lda     pScrollPPU
        ora     pScrollPPU+1
        and     #$C3
        cmp     #$C3
        bne     +
; reached end of nametable
        lda     pScrollPPU+1
        and     #$28
        eor     #$08            ; switch to the other nametable
        sta     pScrollPPU+1
        lda     #$00
        sta     pScrollPPU
; set up the data string that is to be written to nametable
      + ldx     PPUStrIndex
        lda     pScrollPPU+1
        sta     PPUString,x     ; high PPU address
        inx
        lda     pScrollPPU
        sta     PPUString,x     ; low PPU address
        inx
        lda     #32
        sta     PPUString,x     ; length = 32 bytes = one row
        inx
        ldy     #0
        lda     [pScroller],y
        cmp     #$FF            ; if A=FF, scroller has reached end
        bne     +               ; otherwise, A = starting column for text
; end of scroller
        lda     #$FF
        ldx     #mrWaitTimer
        jmp     SetTimer
; fill PPUString with desired # of spaces
      + tay                     ; Y = # of spaces before text begins
        beq     +
        lda     #BLANK_TILE
      - sta     PPUString,x
        inx
        dey
        bne     -
; write the text to PPUString
      +
      - iny
        lda     [pScroller],y
        cmp     #$FF            ; end of text?
        beq     +
        sta     PPUString,x
        inx
        bne     -               ; branch always
; point pScroller to next row's data
      + tya
        sec
        adc     pScroller
        sta     pScroller
        bcc     +
        inc     pScroller+1
; fill the rest of the row with spaces
      + lda     #BLANK_TILE
      - cpx     #32+3
        beq     +
        sta     PPUString,x
        inx
        bne     -
      + jmp     EndPPUString
      - rts

;-----------------------------------------------------------------------------

        UpdateAttrib:
        lda     ScrollY
        and     #$0F
        cmp     #$01
        bne     -

        lda     pAttribPPU+1
        sta     pWorkPPU+1
        lda     pAttribPPU
        sta     pWorkPPU

        lda     ScrollY
        and     #$10
        lsr
        tay
        ldx     PPUStrIndex

      - lda     pWorkPPU+1
        sta     PPUString+0,x
        lda     pWorkPPU
        sta     PPUString+1,x
        lda     #$48
        sta     PPUString+2,x

        lda     AttribData,y
        sta     PPUString+3,x

        lda     pWorkPPU
        clc
        adc     #$08
        bcc     +

        lda     pWorkPPU+1
        eor     #$08
        sta     pWorkPPU+1
        lda     #$C0
      + sta     pWorkPPU

        inx
        inx
        inx
        inx
        iny
        tya
        and     #$07
        bne     -
        jsr     EndPPUString

        lda     ScrollY
        and     #$10
        beq     ++

        lda     pAttribPPU
        clc
        adc     #$08            ; next row on attrib table
        bcc     +

; end of attrib table reached
        lda     pAttribPPU+1
        eor     #$08
        sta     pAttribPPU+1
        lda     #$C0
      + sta     pAttribPPU
     ++ rts

;-----------------------------------------------------------------------------

AttribData:
.db $05,$AF,$FF,$FF,$FF,$FF,$A5,$00
.db $00,$5A,$FF,$FF,$FF,$FF,$FA,$50

ScrollData:
.db 13 : .asc "Staff*"
.db 32, $FF
.db 32, $FF
.db 32, $FF
.db 12 : .asc "Program*"
.db 32, $FF
.db 10 : .asc "Kent Hansen*"
.db 32, $FF
.db 32, $FF
.db 32, $FF
.db 12 : .asc "Design*"
.db 32, $FF
.db 10 : .asc "Kent Hansen*"
.db 32, $FF
.db 11 : .asc "Rob Mocca*"
.db 32, $FF
.db 32, $FF
.db 32, $FF
.db 11 : .asc "Graphics*"
.db 32, $FF
.db 10 : .asc "Kent Hansen*"
.db 32, $FF
.db 32, $FF
.db 32, $FF
.db 13 : .asc "Sound*"
.db 32, $FF
.db 10 : .asc "Kent Hansen*"
.db 32, $FF
.db 32, $FF
.db 32, $FF
.db 13 : .asc "Tools*"
.db 32, $FF
.db 10 : .asc "Kent Hansen*"
.db 32, $FF
.db 32, $FF
.db 32, $FF
.db 12 : .asc "Testing*"
.db 32, $FF
.db 10 : .asc "Kent Hansen*"
.db 32, $FF
.db 11 : .asc "Rob Mocca*"
.db 32, $FF
.db 32, $FF
.db 32, $FF
.db 9 : .asc "Moral support*"
.db 32, $FF
.db 11 : .asc "Rob Mocca*"
.db 32, $FF
.db 32, $FF
.db 32, $FF
.db 32, $FF
.db 32, $FF
.db 11 : .asc "Thanks to*"
.db 32, $FF
.db 8 : .asc "minus/Ballistics*"
.db 32, $FF
.db 13 : .asc "loopy*"
.db 32, $FF
.db 8 : .asc "Jeremy Chadwick*"
.db 32, $FF
.db 10 : .asc "Thomas Steen*"
.db 32, $FF
.db 11 : .asc "Eugene Ng*"
.db 32, $FF
.db 13 : .asc "Triton*"
.db 32, $FF
.db 32, $FF
.db 32, $FF
.db 32, $FF
.db 32, $FF
.db 6 : .asc "Thanks for playing!*"
.db 32, $FF
.db 11 : .asc "See you...*"
.db 32, $FF
.db 9 : .asc "...on the GBA!*"
.db 32, $FF
.db 32, $FF
.db 32, $FF
.db 32, $FF
.db 32, $FF
.db 32, $FF
.db 32, $FF
.db 32, $FF
.db 32, $FF
.db 32, $FF
.db 32, $FF
.db 32, $FF
.db 32, $FF
.db 32, $FF
.db 32, $FF
.db 32, $FF
.db 32, $FF
.db 12 : .asc "The End!*"
.db 32, $FF
.db 32, $FF
.db 2 : .asc $C9, " 1999-2003 SnowBro Software*"
.db 32, $FF
.db 32, $FF
.db 32, $FF
.db 32, $FF
.db 32, $FF
.db 32, $FF
.db 32, $FF
.db 32, $FF
.db 32, $FF
.db 32, $FF
.db 32, $FF
.db 32, $FF
.db 32, $FF
.db 32, $FF
.db 32, $FF
.db $FF,$FF

.end
