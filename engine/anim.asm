.include "engine/anim.h"
.include "game.h"
.include "common/nes.h"
.include "engine/obj.h"
.include "common/mmc3.h"

.dataseg zeropage

ScreenX             .byte
ScreenY             .byte
SpriteBase          .byte
SpriteIndex         .byte   ; next free sprite
CelLength           .byte

.codeseg

.public SpriteBase
.public SpriteIndex
.public ANIM_SetLoop
.public ANIM_SetCel
.public ANIM_GoMethod
.public ANIM_DrawCel

; Animation function library

; DrawCel
; =======

.proc ANIM_DrawCel
    lda     OBJ_ScreenX,x
    sta     ScreenX
    lda     OBJ_WorldXFrac,x
    bpl     +
    inc     ScreenX
    bne     +
    rts
  + lda     OBJ_ScreenY,x
    sta     ScreenY

    lda     ANIM_pCelLo,x
    sta     ANIM_pCel
    lda     ANIM_pCelHi,x
    sta     ANIM_pCel+1

    ldy     #0
    lda     [ANIM_pCel],y           ; # of sprites in the cel
    iny
    sta     CelLength
    lda     OBJ_State,x
    lsr                             ; CF = object's direction
    php
    stx     Temp                    ; save object #
    ldx     SpriteIndex             ; X = index into sprite RAM

; Loop which draws all sprites that make up the cel, one at a time
; ... this should be as FAST as possible, since it might be executed
; up to 64 times per frame!! (not very likely though)

    @@ANIM_DrawOneSprite:
; 1st byte [Y coord]
    lda     [ANIM_pCel],y   ; signed Y coord relative to obj's center
    php
    iny
    clc
    adc     ScreenY         ; add obj's Y coord to get sprite's Y coord
    plp
    bmi     +               ; branch if relative Y coord was negative
    cmp     ScreenY         ; RelY was positive: ScreenY+RelY should be >= ScreenY
    bcc     @@ANIM_SkipSprite ; otherwise, it wrapped around, don't display
    bcs     ++
  + cmp     ScreenY         ; RelY was negative: ScreenY+RelY should be < ScreenY
    bcs     @@ANIM_SkipSprite ; otherwise, it wrapped around, don't display
 ++ sta     SPR_PosY,x
; 2nd byte [tile value]
    lda     [ANIM_pCel],y
    iny
    sta     SPR_Tile,x
; 3rd byte [attributes]
    lda     [ANIM_pCel],y
    iny
    plp                     ; CF contains flip status
    php                     ; push it back
    bcc     +               ; branch if sprite should not be flipped
    eor     #$40            ; else, toggle x flip
  + sta     SPR_Attrib,x
; 4th byte [X coord]
    lda     [ANIM_pCel],y   ; signed X coord relative to obj's center
    bcc     +               ; branch if sprite should not be flipped
    eor     #$FF
    sbc     #$07
    clc
  + php
    iny
    adc     ScreenX
    plp
    bmi     +
    cmp     ScreenX
    bcc     @@ANIM_NextSprite
    bcs     ++
  + cmp     ScreenX
    bcs     @@ANIM_NextSprite
 ++ sta     SPR_PosX,x
    txa
    clc
    adc     #15*4
    tax                     ; X is now ready to index next sprite
    @@ANIM_NextSprite:
    dec     CelLength       ; done all sprites?
    bne     @@ANIM_DrawOneSprite
    plp                     ; fix stack
    stx     SpriteIndex     ; store new position in sprite RAM
    ldx     Temp            ; restore object #
    rts

    @@ANIM_SkipSprite:
    iny
    iny
    iny
    bne     @@ANIM_NextSprite
.endp

; GoMethod
; ========

.proc ANIM_GoMethod
    lda     ANIM_Method,x
    bmi     @@ANIM_NoCycling

    dec     ANIM_Tick,x
    bne     @@ANIM_NoCycling

    asl
    bmi     @@ANIM_CycleForward
    asl
    bmi     @@ANIM_CycleForwardLoop
    asl
    bmi     @@ANIM_CycleReverse
    asl
    bmi     @@ANIM_CycleReverseLoop

; NoCycling
; =========
; Do nothing!

    @@ANIM_NoCycling:
    rts

; CycleForward
; ============
; Plays the animation once.

    @@ANIM_CycleForward:
    inc     ANIM_Cel,x              ; advance to next cel
    lda     ANIM_Cel,x
    cmp     ANIM_NumCels,x          ; reached end of animation?
    bcc     ANIM_SetCel             ; if not, set new cel
    lda     #amNoCycling
    sta     ANIM_Method,x           ; stop cycling
    dec     ANIM_Cel,x              ; undo the INC above
    rts

; CycleForwardLoop
; ================
; Plays the animation repeatedly.

    @@ANIM_CycleForwardLoop:
    inc     ANIM_Cel,x              ; advance to next cel
    lda     ANIM_Cel,x
    cmp     ANIM_NumCels,x          ; reached end of animation?
    bcc     ANIM_SetCel             ; if not, set new cel
    lda     #$00                    ; else, reset animation
    beq     ANIM_SetCel

; CycleReverse
; ============
; Plays the animation backwards once.

    @@ANIM_CycleReverse:
    dec     ANIM_Cel,x              ; next cel to show
    lda     ANIM_Cel,x
    bpl     ANIM_SetCel
    lda     #amNoCycling
    sta     ANIM_Method,x           ; stop cycling
    inc     ANIM_Cel,x              ; undo the DEC above
    rts

; CycleReverseLoop
; ================
; Plays the animation backwards repeatedly.

    @@ANIM_CycleReverseLoop:
    dec     ANIM_Cel,x              ; next cel to show
    lda     ANIM_Cel,x
    bpl     ANIM_SetCel
    ldy     ANIM_NumCels,x
    dey
    tya
.endp

; SetCel
; ======

.proc ANIM_SetCel
    sta     ANIM_Cel,x
    asl
    adc     #3
    tay
    lda     ANIM_pLoopLo,x
    sta     ANIM_pLoop
    lda     ANIM_pLoopHi,x
    sta     ANIM_pLoop+1
    lda     [ANIM_pLoop],y
    sta     ANIM_pCelLo,x
    iny
    lda     [ANIM_pLoop],y
    sta     ANIM_pCelHi,x
    lda     ANIM_Speed,x
    sta     ANIM_Tick,x
; set CHR bank
    lda     ANIM_NumCels,x
    asl
    adc     ANIM_Cel,x
    adc     #3
    tay
    lda     [ANIM_pLoop],y
    ldy     ANIM_CHRPage,x
    sta     SelectedCHR+2,y
    rts
.endp

; SetLoop
; =======
; Y = loop #
; A = cel #

.proc ANIM_SetLoop
    pha
    tya
    sta     ANIM_Loop,x
    asl
    tay
    lda     [ah_pLoopPtrTable],y
    sta     ANIM_pLoopLo,x
    sta     ANIM_pLoop
    iny
    lda     [ah_pLoopPtrTable],y
    sta     ANIM_pLoopHi,x
    sta     ANIM_pLoop+1
    ldy     #$00
    lda     [ANIM_pLoop],y
    sta     ANIM_Speed,x
    iny
    lda     [ANIM_pLoop],y
    sta     ANIM_NumCels,x
    iny
    lda     [ANIM_pLoop],y
    sta     ANIM_CHRPage,x
    ;
    pla
    jmp     ANIM_SetCel
.endp

.end
