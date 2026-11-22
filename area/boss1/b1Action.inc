boss1_actionptrtable:
;;; common actions
.dw PlayerStand         ; 00
.dw PlayerRun           ; 01
.dw PlayerJump          ; 02
.dw PlayerFall          ; 03
.dw PlayerLadder        ; 04
.dw PlayerDuck          ; 05
.dw PlayerDead          ; 06
.dw PlayerHurt          ; 07
.dw ProjectileMain      ; 08
.dw ManualWarpMain      ; 09
.dw InstantWarpMain     ; 0A
.dw ItemMain            ; 0B
.dw NPCMain             ; 0C
.dw NeoDoorMain         ; 0D
.dw BlockingDoorMain    ; 0E
.dw DiscardObject       ; 0F
.dw Return              ; 10
.dw HealthItemMain      ; 11
.dw WaitAnimEnd         ; 12
.dw DiscardEnemy        ; 13
;;; area-specific actions
.dw Boss1WaitPlayerApproach
.dw Boss1Activate
.dw Boss1Startup
.dw Boss1Main

OE_BOSS1WAIT            EQU $14
OE_BOSS1ACTIVATE        EQU $15
OE_BOSS1STARTUP         EQU $16
OE_BOSS1MAIN            EQU $17
OE_ENERGYWAVEMAIN       EQU $18

;-----------------------------------------------------------------------------

; Boss1WaitPlayerApproach
; =======================
; Waits for the player to approach.

    Boss1WaitPlayerApproach:
    lda     OBJ_State,x
    bmi     +   ; exit if not visible
    ; check if player is close enough
    lda     OBJ_ScreenX
    sec
    sbc     OBJ_ScreenX,x
    cmp     #64
    bcs     +
    ; yes he is... start next phase
    jsr     ProgramControl
    lda     #OE_BOSS1ACTIVATE
    sta     OBJ_Action,x
    lda     #4
    sta     OBJ_Var0,x  ; how many times eye should pulsate
    lda     #0
    sta     OBJ_Var1,x  ; eye palette index
    ; maybe start some tense music?
  + rts

; Boss1Activate
; =============
; Fades in and out the boss's eye a couple of times.

    Boss1Activate:
    lda     FrameCount
    and     #7
    bne     +           ; only do something every 8th frame
    ; fade eyes
    lda     OBJ_Var1,x  ; palette #
    jsr     Boss1SetEyePalette
    ; next palette
    inc     OBJ_Var1,x
    lda     OBJ_Var1,x
    and     #7
    sta     OBJ_Var1,x
    bne     +
    dec     OBJ_Var0,x
    beq     ++
  + rts
    ; next phase
 ++ lda     #OE_BOSS1STARTUP
    sta     OBJ_Action,x    ; action triggered after cutscene
    lda     #<Boss1IntroScript
    ldy     #>Boss1IntroScript
    jmp     LoadScript  ; initiate the boss intro cutscene

; Boss1SetEyePalette
; ==================
; In: A = palette (0..7)

    Boss1SetEyePalette:
    asl
    asl
    tay
    txa
    pha
    ldx     PPUStrIndex
    lda     #$3F
    sta     PPUString,x
    inx
    lda     #$11
    sta     PPUString,x
    inx
    lda     #3
    sta     PPUString,x
    inx
    lda     Boss1EyePals+1,y
    sta     PPUString,x
    inx
    lda     Boss1EyePals+2,y
    sta     PPUString,x
    inx
    lda     Boss1EyePals+3,y
    sta     PPUString,x
    inx
    jsr     EndPPUString
    pla
    tax
    rts

Boss1EyePals:
.db $0F,$0F,$0F,$0F
.db $0F,$0F,$0F,$0B
.db $0F,$0F,$0B,$1B
.db $0F,$0B,$1B,$2B
.db $0F,$1B,$2B,$3B
.db $0F,$0B,$1B,$2B
.db $0F,$0F,$0B,$1B
.db $0F,$0F,$0F,$0B

; Boss1Startup
; ============
; 

    Boss1Startup:
    ; load blocking door
    lda     #$11
    ldy     #$8E
    jsr     LoadBlockingDoor
    ; next phase
    lda     #OE_BOSS1MAIN
    sta     OBJ_Action,x
    ;
    jmp     PlayerControl

; Boss1Main
; =========
; First part of boss fight.
; The boss fires energy waves at the player occasionally.
; At this stage, the core has not been destroyed, so
; the player can't kill the boss.

    Boss1Main:
    jsr     TestProjectileCollide
    bne     +
    ; boss hit by player's weapon
    ; can't do any damage at this point
    ; ...
    ; see if an energy wave should be fired
  + jsr     RND
    lsr
    bcc     +
    ; fire energy wave
    ldy     #OT_ENERGYWAVE
    jmp     SpawnObject
  + rts
