.include "game.h"
.include "obj.h"

.codeseg

.public CheckIfCollided
.public CheckObjColl

;----------------------[ OBJ <--> OBJ crash detection ]-----------------------

; CheckObjColl
; ============
; Detects collisions between object in X and other visible objects.

    CheckObjColl:
    lda     OBJ_Type,x
    jsr     MakeObjRect
    sta     OBJ2_Right
    lda     OBJ1_Left
    sta     OBJ2_Left
    lda     OBJ1_Bottom
    sta     OBJ2_Bottom
    lda     OBJ1_Top
    sta     OBJ2_Top
    stx     Index
    ldx     #23
    ldy     #0
    CheckOneObj:
    cpx     Index
    beq     +   ; don't test object with itself!
    lda     OBJ_Type,x
    ora     OBJ_State,x
    bmi     +   ; skip if object inactive or offscreen
    jsr     MakeObjRect
; test for collision between OBJ1 and OBJ2
    cmp     OBJ2_Left
    bcc     +               ; no collision if OBJ1_Right < OBJ2_Left
    lda     OBJ2_Right
    cmp     OBJ1_Left
    bcc     +               ; no collision if OBJ2_Right < OBJ1_Left
    lda     OBJ1_Bottom
    cmp     OBJ2_Top
    bcc     +               ; no collision if OBJ1_Bottom < OBJ2_Top
    lda     OBJ2_Bottom
    cmp     OBJ1_Top        ; no collision if OBJ2_Bottom < OBJ1_Top
    bcc     +
; crash!
    txa
    sta     CollObjNums,y
    lda     OBJ_Type,x
    sta     CollObjTypes,y
    iny
    cpy     #8  ; max. 8 objects can be crashed with
    bcs     ++
  + dex
    bpl     CheckOneObj
 ++ sty     CollObjCount
    ldx     Index
    rts

; MakeObjRect
; ===========

    MakeObjRect:
    lda     OBJ_ScreenY,x
    sec
    sbc     OBJ_RangeY,x
    bcs     +
    sec
    lda     #0
  + sta     OBJ1_Top

    lda     OBJ_ScreenX,x
    sbc     OBJ_RangeX,x
    bcs     +
    lda     #0
  + sta     OBJ1_Left

    lda     OBJ_ScreenY,x
    clc
    adc     OBJ_RangeY,x
    bcc     +
    clc
    lda     #239
  + sta     OBJ1_Bottom

    lda     OBJ_ScreenX,x
    adc     OBJ_RangeX,x
    bcc     +
    lda     #255
  + sta     OBJ1_Right
    rts

; CheckIfCollided
; ===============
; Checks if there's a collision with object of specified type.
; In: A = object type
; Out: ZF = 1 if collision, else 0
;      Y = object index if collision, else $FF

    CheckIfCollided:
    ldy     CollObjCount
  - dey
    bmi     +
    cmp     CollObjTypes,y
    bne     -
  + rts

.end
