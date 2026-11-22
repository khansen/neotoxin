.include "engine/anim.h"
.include "engine/coll.h"
.include "game.h"
.include "engine/gbLoop.h"
.include "engine/gbObj.h"
.include "common/nes.h"
.include "engine/obj.h"
.include "engine/player.h"
.include "sound/rnme.h"
.include "engine/bgcollision.h"
.include "game/flags.h"
.include "engine/movement.h"
.include "engine/objcollision.h"
.include "engine/warp.h"
.include "sound/sfx.h"

.codeseg

.public PlayerStand
.public PlayerRun
.public PlayerJump
.public PlayerFall
.public PlayerLadder
.public PlayerDuck
.public PlayerDead
.public PlayerHurt
.public SetStanding
.public PlayerStartFall
.public PlayerStandUp

;-----------------------------------------------------------------------------

; PlayerStand
; ===========

.proc PlayerStand
    jsr     CheckFire
    jsr     CheckJump
    jsr     CheckDuck
    jsr     CheckManualWarp
    jsr     CheckLadder
    jmp     CheckBeginRun
.endp
    
; CheckFire
; =========

.proc CheckFire
    lda     #btnB
    and     JoyFirst
    beq     +
    lda     ProjectileCount
    cmp     #3
    bcs     +
    lda     ObjCount
    cmp     #23
    bcs     +
    ; missile fire OK
    lda     OBJ_Action
    cmp     #OE_PLAYERRUN
    beq     ++
    lda     #1
    jsr     ANIM_SetCel
 ++ inc     ProjectileCount
    ldy     #OT_PROJECTILE
    jmp     SpawnObject
  + rts
.endp

; CheckJump
; =========

.proc CheckJump
    lda     #btnA
    and     JoyFirst
    beq     NoJump
; initiate jump
    lda     #$FC
    sta     OBJ_SpeedY
    lda     #$00
    sta     OBJ_SpeedYFrac
    sta     OBJ_AccelY
    sta     OBJ_AccelYFrac
    lda     #19
    sta     OBJ_Var3
    lda     #OE_PLAYERJUMP
    sta     OBJ_Action
 ; play jump sfx
    lda     #SFX_PLAYERJUMP
    jsr     PlaySFX
    SetJumpAnim:
    lda     #amNoCycling
    sta     ANIM_Method
    ldy     #LOOP_PLAYERJUMP
    lda     #0
    jmp     ANIM_SetLoop
    NoJump:
  - rts
.endp
    
; CheckDuck
; =========

.proc CheckDuck
    lda     JoyStat
    and     #btnDOWN
    beq     -
; duck
    lda     #OE_PLAYERDUCK
    sta     OBJ_Action
    lda     #17
    sta     OBJ_RangeY
    lda     #6
    sta     OBJ_RangeX
    lda     OBJ_WorldYLo
    clc
    adc     #6
    sta     OBJ_WorldYLo
    bcc     +
    inc     OBJ_WorldYHi
    lda     OBJ_MapOfs
    clc
    adc     MapWidth
    sta     OBJ_MapOfs
  + jsr     OBJ_CoordsToScreen
    lda     #amNoCycling
    sta     ANIM_Method
    ldy     #LOOP_PLAYERDUCK
    lda     #0
    jsr     ANIM_SetLoop
    lda     #0
    sta     OBJ_AccelXFrac
    sta     OBJ_AccelX
    sta     OBJ_SpeedXFrac
    sta     OBJ_SpeedX
    pla
    pla
  - rts

; CheckBeginRun
; =============

    CheckBeginRun:
    lda     JoyStat
    and     #$03
    beq     -
    and     #btnRIGHT
    bne     PlayerMoveRight
; LEFT pressed
    jsr     OBJ_CheckMoveLeft
    bcs     -
; start running left
    StartRunningLeft:
    lda     #$FF
    sta     OBJ_AccelX
    lda     #$D0
    sta     OBJ_AccelXFrac
    lda     #OE_PLAYERRUN
    sta     OBJ_Action
    jsr     FaceLeft
; start the run animation
    SetRunAnim:
    lda     #amForwardLoop
    sta     ANIM_Method
    ldy     #LOOP_PLAYERRUN
    lda     #5
    jmp     ANIM_SetLoop

; RIGHT pressed
    PlayerMoveRight:
    jsr     OBJ_CheckMoveRight
    bcs     -
; start running right
    StartRunningRight:
    lda     #$00
    sta     OBJ_AccelX
    lda     #$30
    sta     OBJ_AccelXFrac
    lda     #OE_PLAYERRUN
    sta     OBJ_Action
    jsr     FaceRight
    jmp     SetRunAnim
    rts
.endp

; CheckLadder
; ===========

.proc CheckLadder
    lda     JoyFirst
    and     #btnUP
    bne     @@CheckClimbUp
    lda     JoyFirst
    and     #btnDOWN
    bne     @@CheckClimbDown
  - rts

    @@CheckClimbDown:
    jsr     OBJ_CheckMoveDown
    lda     Temp
    cmp     #TA_LADDERBELOW
    bne     -
    lda     OBJ_WorldXLo
    and     #$1F
    cmp     #$10
    bcs     -
; start climbing down
    lda     OBJ_WorldYLo
    clc
    adc     #$1F
    sta     OBJ_WorldYLo
    jmp     @@PlayerStartClimb

    @@CheckClimbUp:
    jsr     OBJ_GetCenterAttrib
    cmp     #TA_LADDER
    bne     -
    @@PlayerStartClimb:
    lda     #$00
    sta     OBJ_SpeedX
    lda     OBJ_WorldXLo
    and     #$F0
    ora     #$08
    sta     OBJ_WorldXLo
    lda     #OE_PLAYERLADDER
    sta     OBJ_Action
  - rts
.endp

; CheckManualWarp
; ===============

.proc CheckManualWarp
    lda     JoyFirst
    and     #btnUP
    beq     -
; player pressed UP... see if he's touching a warp spot
    lda     #OT_MANUALWARP
    jsr     CheckIfCollided
    beq     +
    lda     #OT_NPC
    jsr     CheckIfCollided
    bne     -
; enter door!
  + stx     Index
    ldx     CollObjNums,y
    lda     #$03    ; door warp
    jsr     SetupWarp
    ldx     Index
    rts
.endp

;-----------------------------------------------------------------------------

; PlayerRun
; =========

.proc PlayerRun
    jsr     CheckRunning
    jsr     CheckFire
    jsr     CheckDuck
    jsr     CheckManualWarp
    jsr     CheckLadder
    jsr     CheckJump
    jmp     @@CheckBeginFall
    
; CheckBeginFall
; ==============

    @@CheckBeginFall:
    jsr     OBJ_CheckMoveDown
    bcs     +
.endp
; no ground under player, start falling
.proc PlayerStartFall
    lda     #0
    sta     OBJ_SpeedY
    lda     #0
    sta     OBJ_SpeedYFrac
    lda     #$50
    sta     OBJ_AccelYFrac
    lda     #OE_PLAYERFALL
    sta     OBJ_Action
    jmp     SetJumpAnim
  + rts
.endp

; CheckRunning
; ============
; update speed and such

.proc CheckRunning
    lda     OBJ_SpeedX
    ora     OBJ_SpeedXFrac
    beq     SetStanding
    lda     OBJ_SpeedX
    bpl     RunningRight
; running left
    lda     #btnRIGHT
    and     JoyStat
    beq     +
; start running the other way
    lda     #0
    sta     OBJ_SpeedX
    sta     OBJ_SpeedXFrac
    jmp     StartRunningRight
  + lda     CollStat
    and     #COLL_LEFT
    bne     SetStanding     ; player crashed into something
    lda     #btnLEFT
    and     JoyStat
    beq     @@StopRunningLeft ; player released left button
    jsr     InvertXSpeed
    cmp     #$01
    bcc     @@KeepRunningLeft
    cpy     #$E0
    bcc     @@KeepRunningLeft
; reached max speed
    lda     #$00
    sta     OBJ_AccelX
    sta     OBJ_AccelXFrac
    rts

    @@KeepRunningLeft:
    lda     #$FF
    sta     OBJ_AccelX
    lda     #$D0
    sta     OBJ_AccelXFrac
    rts
    
    @@StopRunningLeft:
    jsr     FaceLeft
    lda     #$00
    sta     OBJ_AccelX
    lda     #$10
    sta     OBJ_AccelXFrac
    rts
.endp

; SetStanding
; ===========

.proc SetStanding
    lda     #23
    sta     OBJ_RangeY
    lda     #6
    sta     OBJ_RangeX
    lda     #amNoCycling
    sta     ANIM_Method
    ldy     #LOOP_PLAYERSTAND
    lda     #0
    jsr     ANIM_SetLoop
    lda     #OE_PLAYERSTAND
    sta     OBJ_Action
    lda     #0
    sta     OBJ_SpeedX
    sta     OBJ_SpeedXFrac
    sta     OBJ_AccelX
    sta     OBJ_AccelXFrac
    rts

    RunningRight:
    lda     #btnLEFT
    and     JoyStat
    beq     +
; start running the other way
    lda     #0
    sta     OBJ_SpeedX
    sta     OBJ_SpeedXFrac
    jmp     StartRunningLeft
  + lda     CollStat
    and     #COLL_RIGHT
    bne     SetStanding
    lda     #btnRIGHT
    and     JoyStat
    beq     @@StopRunningRight
    lda     OBJ_SpeedX
    cmp     #$01
    bcc     @@KeepRunningRight
    lda     OBJ_SpeedXFrac
    cmp     #$E0
    bcc     @@KeepRunningRight
; reached max speed
    lda     #$00
    sta     OBJ_AccelX
    sta     OBJ_AccelXFrac
    rts

    @@KeepRunningRight:
    lda     #$00
    sta     OBJ_AccelX
    lda     #$30
    sta     OBJ_AccelXFrac
    rts

    @@StopRunningRight:
    jsr     FaceRight
    lda     #$FF
    sta     OBJ_AccelX
    lda     #$F0
    sta     OBJ_AccelXFrac
    rts
.endp

;-----------------------------------------------------------------------------

; PlayerJump
; ==========

.proc PlayerJump
    jsr     CheckGravityApply
    jsr     CheckFire
    jsr     CheckJumpRelease
    jsr     CheckCeilingCollide
    jsr     CheckMoveJump
    lda     OBJ_SpeedY
    bmi     +
    jmp     PlayerStartFall
  + rts
.endp
  
; CheckCeilingCollide
; ===================

.proc CheckCeilingCollide
    lda     CollStat
    and     #COLL_UP
    beq     +
; collided with ceiling
    jmp     PlayerStartFall
  + rts
.endp
    
; CheckGravityApply
; =================

.proc CheckGravityApply
    lda     OBJ_Var3
    beq     +
    dec     OBJ_Var3
    bne     +
    lda     #$50
    sta     OBJ_AccelYFrac
  + rts
.endp
    
; CheckJumpRelease
; ================

.proc CheckJumpRelease
; check if jump button is being held
    lda     JoyStat
    and     #btnA
    bne     +
    lda     #1
    sta     OBJ_Var3
  + rts
.endp
    
; CheckMoveJump
; =============
; move left/right if requested

.proc CheckMoveJump
    lda     #(btnLEFT | btnRIGHT)
    and     JoyStat
    beq     @@ResetXAccel
    lsr     ; CF = status of btnRIGHT (1=pressed)
    bcs     @@JumpAccelRight
; accelerate left
    lda     OBJ_SpeedX
    bmi     +
    lda     #0
    sta     OBJ_SpeedX
    sta     OBJ_SpeedXFrac
  + jsr     FaceLeft
    lda     #$FF
    sta     OBJ_AccelX
    lda     #$D0
    sta     OBJ_AccelXFrac
    bne     @@CheckJumpSpeed
; accelerate right
    @@JumpAccelRight:
    lda     OBJ_SpeedX
    bpl     +
    lda     #0
    sta     OBJ_SpeedX
    sta     OBJ_SpeedXFrac
  + jsr     FaceRight
    lda     #$00
    sta     OBJ_AccelX
    lda     #$30
    sta     OBJ_AccelXFrac

; CheckJumpSpeed
; ==============

    @@CheckJumpSpeed:
    lda     OBJ_SpeedX
    beq     +
    bpl     @@MovingRight
; moving to the left
    jsr     InvertXSpeed
    cmp     #$01
    bcc     +
    cpy     #$E0
    bcc     +
    lda     OBJ_AccelX
    bpl     +
; stop accelerating
    @@ResetXAccel:
    lda     #0
    sta     OBJ_AccelX
    sta     OBJ_AccelXFrac
  + rts

    @@MovingRight:
; moving to the right
    lda     OBJ_SpeedX
    cmp     #$01
    bcc     +
    lda     OBJ_SpeedXFrac
    cmp     #$E0
    bcc     +
    lda     OBJ_AccelX
    bpl     @@ResetXAccel
  + rts
.endp

;-----------------------------------------------------------------------------

; PlayerFall
; ==========

.proc PlayerFall
    jsr     CheckFallSpeed
    jsr     CheckFire
; check for double jump
    lda     #2
    jsr     GetStatusFlag   ; double jump aquired?
    beq     +
    lda     AllowDblJmp     ; double jump allowed?
    beq     +
    jsr     CheckJump
    lda     #OE_PLAYERJUMP
    cmp     OBJ_Action      ; did he actually jump?
    bne     +
    lda     #0
    sta     AllowDblJmp
;
  + jsr     CheckMoveJump
    jsr     CheckFloorCollide
    jmp     CheckLadder
.endp

; CheckFallSpeed
; ==============

.proc CheckFallSpeed
    lda     OBJ_SpeedY
    bmi     +
    cmp     #4
    bcc     +
    lda     #4
    sta     OBJ_SpeedY
    lda     #0
    sta     OBJ_SpeedYFrac
  + rts
.endp
    
; CheckFloorCollide
; =================

.proc CheckFloorCollide
    lda     CollStat
    and     #COLL_DOWN
    beq     NoFloorCollide
; collided with floor
    PlayerFloorCollide:
    lda     #1
    sta     AllowDblJmp
    lda     #$01
    sta     OBJ_SpeedY
    lda     #$00
    sta     OBJ_SpeedYFrac
    lda     OBJ_SpeedX
    ora     OBJ_SpeedXFrac
    bne     +
 -- lda     #OE_PLAYERSTAND
    sta     OBJ_Action
    jmp     SetStanding
  + lda     OBJ_State
    lsr
    lda     OBJ_SpeedX
    bmi     +
    bcc     ++
  - lda     #0
    sta     OBJ_SpeedX
    sta     OBJ_SpeedXFrac
    beq     --
  + bcc     -
 ++ lda     #OE_PLAYERRUN
    sta     OBJ_Action
    jmp     SetRunAnim
    NoFloorCollide:
  - rts
.endp

;-----------------------------------------------------------------------------

; PlayerDuck
; ==========

.proc PlayerDuck
    jsr     CheckFire
    lda     JoyStat
    and     #btnDOWN
    bne     -
.endp
; DOWN button released, stand up
.proc PlayerStandUp
    lda     OBJ_WorldYLo
    sec
    sbc     #6
    sta     OBJ_WorldYLo
    bcs     +
    dec     OBJ_WorldYHi
    lda     OBJ_MapOfs
    sec
    sbc     MapWidth
    sta     OBJ_MapOfs
  + jsr     OBJ_CoordsToScreen
    jmp     SetStanding
.endp

;-----------------------------------------------------------------------------

; PlayerLadder
; ============

.proc PlayerLadder
    lda     #(btnLEFT | btnRIGHT)
    and     JoyFirst
    beq     +
    jmp     PlayerStartFall
  + lda     #btnDOWN
    and     JoyStat
    bne     @@ClimbLadderDown
    lda     #btnUP
    and     JoyStat
    bne     @@ClimbLadderUp
    @@NoLadderClimb:
    lda     #$00
    sta     OBJ_SpeedY
    sta     OBJ_SpeedYFrac
    lda     #amNoCycling
    sta     ANIM_Method
    rts

    @@ClimbLadderDown:
    lda     CollStat
    and     #COLL_DOWN
    beq     @@ContinueClimbDown
    jmp     PlayerFloorCollide
    @@ContinueClimbDown:
    lda     #$01
    sta     OBJ_SpeedY
    lda     #amForwardLoop
    sta     ANIM_Method
    rts

    @@ClimbLadderUp:
    lda     CollStat
    and     #COLL_UP
    bne     @@NoLadderClimb
    lda     OBJ_WorldYLo
    cmp     #$11
    bcs     @@ContinueClimbUp
    @@ContinueClimbUp:
    jsr     OBJ_CheckMoveUp
    lda     Temp
    cmp     #TA_AIR
    beq     @@ClimbOffLadder

    lda     #$FF
    sta     OBJ_SpeedY
    lda     #amForwardLoop
    sta     ANIM_Method
    rts

    @@ClimbOffLadder:
    lda     OBJ_WorldYLo
    sec
    sbc     #$1F
    sta     OBJ_WorldYLo
    jmp     PlayerFloorCollide
.endp

;-----------------------------------------------------------------------------

; PlayerHurt
; ==========

.proc PlayerHurt
    lda     CollStat
    and     #COLL_UP
    beq     +
    lda     #0
    sta     OBJ_SpeedY
    sta     OBJ_SpeedYFrac
  + lda     OBJ_SpeedX
    ora     OBJ_SpeedXFrac
    bne     +
    sta     OBJ_AccelX
    sta     OBJ_AccelXFrac
    lda     #OE_PLAYERFALL
    sta     OBJ_Action
  + rts
.endp

;-----------------------------------------------------------------------------

; PlayerDead
; ==========

.proc PlayerDead
    lda     ANIM_Method
    cmp     #amNoCycling
    bne     +
    lda     #$40    ; hide
    sta     OBJ_State
  + lda     Timer
    bne     +
    lda     #0
    sta     RNME_LastTune
    lda     #mrGameOverInit
    sta     MainRoutine
  + rts
.endp

.end
