.include "game.h"
.include "engine/hsge.h"
.include "engine/obj.h"
.include "engine/attribtable.h"
.include "game/flags.h"
.include "engine/nametable.h"
.include "common/ppu.h"
.include "engine/renderer.h"
.include "engine/scroller.h"
.include "engine/warp.h"

.dataseg zeropage

ObjMapOfs       .byte

.codeseg

.public ObjMapOfs
.public HSGE_DeleteFarObjects
.public ExecObjConstr
.public LoadObject
.public HSGE_RenderScreen
.public HSGE_LoadObjects
.public HSGE_CheckScreenWrite

; HSGE_CheckScreenWrite
; =====================

.proc HSGE_CheckScreenWrite
    lda     HSGE_QueueSize
    beq     @@HSGE_NoScrollWrite
    lda     HSGE_ScrollQueue    ; get top item
    sta     HSGE_QueueItem
    ; dequeue
    lda     HSGE_ScrollQueue+1
    sta     HSGE_ScrollQueue
    lda     HSGE_ScrollQueue+2
    sta     HSGE_ScrollQueue+1
    lda     #0
    sta     HSGE_ScrollQueue+2
    dec     HSGE_QueueSize
    ; process request
    lda     HSGE_QueueItem
    lsr
    bcc     +
    jmp     @@HSGE_WriteScreenRight
  + lsr
    bcc     +
    jmp     HSGE_WriteScreenLeft
  + lsr
    bcc     +
    jmp     HSGE_WriteScreenDown
  + jmp     HSGE_WriteScreenUp
    @@HSGE_NoScrollWrite:
    rts

; WriteScreenRight
; ================

    @@HSGE_WriteScreenRight:
    ldy     HSGE_MapOfs
    iny
    sty     Temp4
    tya
    jsr     HSGE_SetRoomPtr
    jsr     HSGE_CalcRoomOfs
    jsr     HSGE_WriteNameTableCol
    lda     HSGE_QueueItem
    and     #%00010000  ; update attribute table as well?
    beq     +
    lda     Temp4
    jsr     HSGE_SetRoomPtr
    jsr     HSGE_WriteAttribTableCol
  + inc     HSGE_RoomCol
    lda     HSGE_RoomCol
    and     #31     ; check for wrap
    sta     HSGE_RoomCol
    bne     +
    inc     HSGE_MapOfs
  + rts
.endp

;;;;;;;;;;;;;;;;;; TEMP
; WriteScreenRightX
; =================

.proc HSGE_WriteScreenRightX
    ldy     HSGE_MapOfs
    iny
    sty     Temp4
    tya
    jsr     HSGE_SetRoomPtr
    jsr     HSGE_CalcRoomOfs
    jsr     HSGE_WriteNameTableCol
    lda     HSGE_QueueItem
    and     #%00010000  ; update attribute table as well?
    beq     +
    lda     Temp4
    jsr     HSGE_SetRoomPtr
    jsr     HSGE_WriteAttribTableCol
  + inc     HSGE_RoomCol
    lda     HSGE_RoomCol
    and     #31     ; check for wrap
    sta     HSGE_RoomCol
    bne     +
    ; horizontal room wrap
    inc     HSGE_MapOfs
  + rts
;;;;;;;;;;;;;;;;;; TEMP

; HSGE_WriteScreenLeft
; ====================

    HSGE_WriteScreenLeft:
    dec     HSGE_RoomCol
    lda     HSGE_RoomCol
    and     #31
    sta     HSGE_RoomCol
    eor     #31     ; check for wrap
    bne     +
    ; horizontal room wrap
    dec     HSGE_MapOfs
  + lda     HSGE_MapOfs
    sta     Temp4
    jsr     HSGE_SetRoomPtr
    jsr     HSGE_CalcRoomOfs
    jsr     HSGE_WriteNameTableCol
    lda     HSGE_QueueItem
    and     #%00100000  ; update attribute table as well?
    beq     +
    lda     Temp4
    jsr     HSGE_SetRoomPtr
    jsr     HSGE_WriteAttribTableCol
  + rts

; WriteScreenDown
; ===============

    HSGE_WriteScreenDown:
    ldy     HSGE_MapOfs
    lda     HSGE_RoomRow
    cmp     #2
    bcc     +
    tya
    clc
    adc     MapWidth
    tay
  + sty     Temp4
    tya
    jsr     HSGE_SetRoomPtr
    lda     HSGE_RoomCol
    lsr
    lsr
    sta     Temp
    lda     HSGE_RoomRow
    clc
    adc     #30
    cmp     #32
    bcc     +
    sbc     #32
  + sta     HSGE_TempRow
    and     #$FC
    asl
    ora     Temp
    sta     HSGE_RoomOfs
    lda     HSGE_ScreenTable
    eor     #1
    tay
    jsr     HSGE_WriteNameTableRow
    lda     HSGE_QueueItem
    and     #%01000000  ; update attribute table as well?
    beq     +
    lda     Temp4
    jsr     HSGE_SetRoomPtr
    lda     HSGE_ScreenTable
    eor     #1
    tay
    jsr     HSGE_WriteAttribTableRow
  + inc     HSGE_RoomRow
    lda     HSGE_RoomRow
    and     #31
    sta     HSGE_RoomRow
    bne     +
    ; vertical room wrap
    lda     HSGE_MapOfs
    clc
    adc     MapWidth
    sta     HSGE_MapOfs
  + inc     HSGE_ScreenRow
    lda     HSGE_ScreenRow
    cmp     #30
    bne     +
    lda     #0
    sta     HSGE_ScreenRow
    lda     HSGE_ScreenTable
    eor     #1
    sta     HSGE_ScreenTable
  + rts

; WriteScreenUp
; =============

    HSGE_WriteScreenUp:
    dec     HSGE_RoomRow
    ; check for wrap
    lda     HSGE_RoomRow
    and     #31
    sta     HSGE_RoomRow
    eor     #31
    bne     +
    ; vertical room wrap
    lda     HSGE_MapOfs
    sec
    sbc     MapWidth
    sta     HSGE_MapOfs
  + lda     HSGE_MapOfs
    sta     Temp4
    jsr     HSGE_SetRoomPtr
    jsr     HSGE_CalcRoomOfs
    dec     HSGE_ScreenRow
    lda     HSGE_ScreenRow
    cmp     #255
    bne     +
    ; vertical screen wrap
    lda     #29
    sta     HSGE_ScreenRow
    lda     HSGE_ScreenTable
    eor     #1
    sta     HSGE_ScreenTable
  + lda     HSGE_RoomRow
    sta     HSGE_TempRow
    ldy     HSGE_ScreenTable
    jsr     HSGE_WriteNameTableRow
    lda     HSGE_QueueItem
    and     #%10000000  ; update attribute table as well?
    beq     +
    lda     Temp4
    jsr     HSGE_SetRoomPtr
    ldy     HSGE_ScreenTable
    jsr     HSGE_WriteAttribTableRow
  + rts
.endp

; HSGE_RenderScreen
; =================

.proc HSGE_RenderScreen
    lda     #32
  - pha
    ldy     #%00000001
    lda     HSGE_RoomCol
    lsr
    bcc     +
    ldy     #%00010001
  + sty     HSGE_QueueItem
    jsr     HSGE_WriteScreenRightX
    jsr     CheckPPUWrite
    pla
    sec
    sbc     #1
    bne     -
 -- rts
.endp

;-----------------------------------------------------------------------------

; HSGE_DeleteFarObjects
; =====================
; Deletes objects that are too far away from the current world view.
; In: A = map pos X
;     Y = map pos Y

.proc HSGE_DeleteFarObjects
    cmp     MapWidth
    bcs     --
    cpy     MapHeight
    bcs     --
    sta     ObjPageX
    sty     ObjPageY
    ldx     #23
  - ldy     OBJ_Type,x
    bmi     +
    lda     ObjPageX
    cmp     OBJ_WorldXHi,x
    bne     +
    lda     ObjPageY
    cmp     OBJ_WorldYHi,x
    bne     +
    jsr     RemoveObject
  + dex
    bne     -
  - rts
.endp

; HSGE_LoadObjects
; ================
; A = Map pos X
; Y = Map pos Y

.proc HSGE_LoadObjects
    cmp     MapWidth
    bcs     -
    cpy     MapHeight
    bcs     -
    sta     ObjPageX
    sty     ObjPageY
    jsr     OBJ_CalcMapOfs
    sta     ObjMapOfs
    asl
    tay
    lda     [pMap],y
    sta     HSGE_pObject
    iny
    lda     [pMap],y
    sta     HSGE_pObject+1
    ldy     #64                 ; object data begins after room data
    sty     Index
    @@HSGE_LoadOneObj:
    ldy     Index
    lda     [HSGE_pObject],y
    bmi     @@HSGE_ObjSpecial
    sta     Temp2               ; object type
    lda     ObjCount
    cmp     #21                 ; no slots available?
    bcs     @@HSGE_ObjectOverflow
    jsr     FindObjSlot         ; find available object slot
    @@HSGE_FoundNewSlot:
    iny
    lda     [HSGE_pObject],y    ; position
    iny
    sty     Index
    ldy     Temp2               ; type
    jsr     LoadObject
    jmp     @@HSGE_LoadOneObj
    @@HSGE_ObjectOverflow:        ; make room for object
    lda     Temp2
    cmp     #4
    bcc     +
    iny
    iny
    sty     Index
    bne     @@HSGE_LoadOneObj
    ; attempt to find an enemy that can be squeezed out
  + ldx     #23
  - lda     OBJ_Type,x
    bmi     +
    cmp     #4
    bcc     +
    jsr     RemoveObject
    jmp     @@HSGE_FoundNewSlot
  + dex
    bne -
    ; no slots available!!
    rts     ; no option but to stop loading objects
    @@HSGE_ObjSpecial:
    cmp     #$FE
    beq     @@HSGE_RunObjCode
    bcc     @@HSGE_CheckObjFlag
    rts                         ; $FF = end of object data
    @@HSGE_CheckObjFlag:
    and     #$7F
    sta     Temp2               ; type
    iny
    lda     [HSGE_pObject],y    ; flag to check
    sty     Index
    jsr     GetStatusFlag
    beq     +   ; load object only if flag is zero
    inc     Index
    inc     Index
    jmp     @@HSGE_LoadOneObj
  + jsr     FindObjSlot
    ldy     Index
    lda     [HSGE_pObject],y
    sta     OBJ_Flag,x
    jmp     @@HSGE_FoundNewSlot
    @@HSGE_RunObjCode:
    iny
    lda     [HSGE_pObject],y
    sta     pCode+1
    iny
    lda     [HSGE_pObject],y
    sta     pCode
    iny
    sty     Index
    jsr     GoCodePtr
    jmp     @@HSGE_LoadOneObj
.endp

; LoadObject
; ==========
; A = Position: $YX
; Y = Object type

.proc LoadObject
    inc     ObjCount
; set starting position
    pha
    and     #$F0
    sta     OBJ_WorldYLo,x
    pla
    and     #$0F
    asl
    asl
    asl
    asl
    sta     OBJ_WorldXLo,x
    lda     ObjPageX
    sta     OBJ_WorldXHi,x
    lda     ObjPageY
    sta     OBJ_WorldYHi,x
    lda     ObjMapOfs
    sta     OBJ_MapOfs,x
;
    tya
    sta     OBJ_Type,x
.endp
.proc ExecObjConstr
; execute object constructor
    asl
    tay
    lda     [ah_pObjConstructors],y
    sta     pCode
    iny
    lda     [ah_pObjConstructors],y
    sta     pCode+1
    jmp     [pCode]
.endp

.end
