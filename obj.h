.ifndef OBJ_H
.define OBJ_H

;--------------------------------[ Defines ]----------------------------------

; variables for 24 objects

OBJ_Type                EQU     $0408
OBJ_State               EQU     $0420    ; D0: direction, D1: collision mode, D2: bg collision ignore (1=yes), D6: invisible (1=yes), D7: offscreen (1=yes)
OBJ_Action              EQU     $0438
OBJ_SpeedX              EQU     $0450
OBJ_SpeedY              EQU     $0468
OBJ_SpeedXFrac          EQU     $0480
OBJ_SpeedYFrac          EQU     $0498
OBJ_AccelX              EQU     $04B0
OBJ_AccelY              EQU     $04C8
OBJ_AccelXFrac          EQU     $04E0
OBJ_AccelYFrac          EQU     $04F8
OBJ_RangeX              EQU     $0510
OBJ_RangeY              EQU     $0528
OBJ_Health              EQU     $0540
OBJ_Blink               EQU     $0558
OBJ_CollIndex           EQU     $0570
OBJ_Flag                EQU     $0588
OBJ_ScreenX             EQU     $05A0
OBJ_ScreenY             EQU     $05B8
OBJ_WorldXLo            EQU     $05D0
OBJ_WorldXHi            EQU     $05E8
OBJ_WorldYLo            EQU     $0600
OBJ_WorldYHi            EQU     $0618
OBJ_WorldXFrac          EQU     $0630
OBJ_WorldYFrac          EQU     $0648
OBJ_MapOfs              EQU     $0660
OBJ_NextAction          EQU     $0678
OBJ_Var0                EQU     $0690
OBJ_Var1                EQU     $06A8
OBJ_Var2                EQU     $06C0
OBJ_Var3                EQU     $06D8


; Exported symbols.
.extrn DiscardObject:proc
.extrn ToggleDirection:proc
.extrn FaceLeft:proc
.extrn FaceRight:proc
.extrn ResetMotion:proc
.extrn FacePlayer:proc
.extrn SpawnObject:proc
.extrn RemoveObject:proc
.extrn OBJ_CalcMapOfs:proc
.extrn FindObjSlot:proc
.extrn GoCodePtr:proc
.extrn OBJ_IncY:proc
.extrn OBJ_DecY:proc
.extrn OBJ_DecX:proc
.extrn OBJ_IncX:proc
.extrn TestSetObjFlag:proc
.extrn RemoveProjectile:proc
.extrn ObjectToHealthItem:proc
.extrn OBJ_CoordsToScreen:proc
.extrn DestroyAllSprites:proc
.extrn DestroyAllObjects:proc
.extrn OBJ_PerformAction:proc

.endif
