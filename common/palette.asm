.include "game.h"
.include "common/fade.h"
.include "common/palette.h"
.include "common/ppu.h"

.codeseg

.public PAL_LoadPalette
.public PAL_SetPalette
.public PAL_SetBlackPalette

; PAL_LoadPalette
; ===============

.proc PAL_LoadPalette
        sta     pData
        sty     pData+1
        ldy     #$1F
      - lda     [pData],y
        sta     RAMPalette,y
        dey
        bpl     -
        rts
.endp

; PAL_SetPalette
; ==============

.proc PAL_SetPalette
        jsr     PAL_StrSetup
        ldx     #$1F
      - lda     RAMPalette,x
        sta     PPUString+3,x
        dex
        bpl     -
        lda     #$01
        sta     PPUDataPending
        jmp     WaitNMIPass
.endp

; PAL_SetBlackPalette
; ===================

.proc PAL_SetBlackPalette
        ldx     #$1F
      - lda     #$0F    ; color black
        sta     RAMPalette,x
        dex
        bpl     -
        bmi     PAL_SetPalette
.endp

.end
