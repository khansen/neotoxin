.include "chr.h"
.include "game.h"
.include "nes.h"
.include "rnme.h"

.codeseg

.public LevelUpInit
.public LevelUpMain
.public AdjustExpGain
.public AddExpPoints
.public CheckLevelAdvance

.extrn DestroyAllSprites:proc
.extrn ExpPtsLevelTable:label

; LevelUpInit
; ===========

    LevelUpInit:
    jsr     DestroyAllSprites
    lda     #CHR_LEVELUP
    sta     SelectedCHR+3
; play sfx
    lda     #SFX_LEVELUP
    sta     SFX_Number+1
; set up the sprites that spell "LEVEL UP"
    ldx     SpriteIndex
    ldy     #7
  - cpy     #5
    beq     +   ; don't draw the space!
    lda     LevelUpSprites,y
    sta     SPR_Tile,x
    lda     #111
    sta     SPR_PosY,x
    lda     #0
    sta     SPR_Attrib,x
    tya
    asl
    asl
    asl
    adc     #96
    sta     SPR_PosX,x
    txa
    clc
    adc     #15*4
    tax                     ; X is now ready to index next sprite
  + dey
    bpl     -
;        lda     #TUNE_LEVEL_UP
;        sta     RNME_LoadTune  ; play "Level Up" music
    lda     #13     ; fanfare lasts about this many time units
    sta     Timer
    lda     #1      ; time units per blink (see LevelUpMain below)
    sta     Timer+1
    inc     MainRoutine
    rts

LevelUpSprites:
.db $41,$43,$45,$43,$41,$FF,$47,$49

; LevelUpMain
; ===========

    LevelUpMain:
    lda     Timer
    bne     +
; hand over control to the game engine again
    lda     #CHR_STATUS
    sta     SelectedCHR+3
    lda     #mrArea2DMain
    sta     MainRoutine
    rts
  + lda     Timer+1
    bne     +   ; time to blink the "Level up" text?
    lda     #1
    sta     Timer+1
    ldx     SpriteIndex
    lda     #244    ; Y coord when sprite is invisible (offscreen)
    cmp     SPR_PosY,x  ; is the sprite offscreen?
    bne     ++      ; branch if not (put it offscreen)
    lda     #111    ; else make it visible
 ++ ldy     #6
  - sta     SPR_PosY,x
    pha
    txa
    clc
    adc     #15*4
    tax                     ; X is now ready to index next sprite
    pla
    dey
    bpl     -
  + rts

; AddExpPoints
; ============
; In: A = # of pts to add

    AddExpPoints:
    clc
    adc     Experience
    sta     Experience
    bcc     +
    inc     Experience+1
  + rts

; AdjustExpGain
; =============
; In: A = original # of exp
; Out: A = # of exp adjusted to account for current level
; Destroys: Temp

    AdjustExpGain:
    tay
    txa
    pha
    ldx     #0
    lda     Level
    asl
    asl
    adc     #32
    sta     Temp
    lda     ExpFrac
  - sec
    sbc     #32
    beq     ++
    bcs     +
 ++ clc
    adc     Temp
    inx
  + dey
    bne     -
    sta     ExpFrac
    stx     Temp
    pla
    tax
    lda     Temp
    rts

; CheckLevelAdvance
; =================

    CheckLevelAdvance:
    lda     Level
    asl
    tay
    lda     ExpPtsLevelTable,y
    sec
    sbc     Experience
    lda     ExpPtsLevelTable+1,y
    sbc     Experience+1
    bmi     AdvanceLevel
    rts
; advance to next level
    AdvanceLevel:
    inc     Level
; decrease ease of gaining exp.
    lda     ExpFrac
    clc
    adc     #8
    sta     ExpFrac
; increase defense
    lda     Defense
    clc
    adc     Level
    sta     Defense
;
    lda     #mrLevelUpInit
    sta     MainRoutine
    rts
    

.end
