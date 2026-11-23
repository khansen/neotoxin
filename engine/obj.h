.ifndef OBJ_H
.define OBJ_H

;--------------------------------[ Defines ]----------------------------------

; variables for 24 objects

MAX_OBJECTS             EQU     24      ; object slots; slot 0 is the player

; The object table: one array per attribute, indexed by object slot.
.struc obj_table
OBJ_Type                .byte[MAX_OBJECTS]
OBJ_State               .byte[MAX_OBJECTS]   ; D0: direction, D1: collision mode, D2: bg collision ignore (1=yes), D6: invisible (1=yes), D7: offscreen (1=yes)
OBJ_Action              .byte[MAX_OBJECTS]
OBJ_SpeedX              .byte[MAX_OBJECTS]
OBJ_SpeedY              .byte[MAX_OBJECTS]
OBJ_SpeedXFrac          .byte[MAX_OBJECTS]
OBJ_SpeedYFrac          .byte[MAX_OBJECTS]
OBJ_AccelX              .byte[MAX_OBJECTS]
OBJ_AccelY              .byte[MAX_OBJECTS]
OBJ_AccelXFrac          .byte[MAX_OBJECTS]
OBJ_AccelYFrac          .byte[MAX_OBJECTS]
OBJ_RangeX              .byte[MAX_OBJECTS]
OBJ_RangeY              .byte[MAX_OBJECTS]
OBJ_Health              .byte[MAX_OBJECTS]
OBJ_Blink               .byte[MAX_OBJECTS]
OBJ_CollIndex           .byte[MAX_OBJECTS]
OBJ_Flag                .byte[MAX_OBJECTS]
OBJ_ScreenX             .byte[MAX_OBJECTS]
OBJ_ScreenY             .byte[MAX_OBJECTS]
OBJ_WorldXLo            .byte[MAX_OBJECTS]
OBJ_WorldXHi            .byte[MAX_OBJECTS]
OBJ_WorldYLo            .byte[MAX_OBJECTS]
OBJ_WorldYHi            .byte[MAX_OBJECTS]
OBJ_WorldXFrac          .byte[MAX_OBJECTS]
OBJ_WorldYFrac          .byte[MAX_OBJECTS]
OBJ_MapOfs              .byte[MAX_OBJECTS]
OBJ_NextAction          .byte[MAX_OBJECTS]
OBJ_Var0                .byte[MAX_OBJECTS]
OBJ_Var1                .byte[MAX_OBJECTS]
OBJ_Var2                .byte[MAX_OBJECTS]
OBJ_Var3                .byte[MAX_OBJECTS]
.ends

.extrn OBJ:obj_table       ; engine/obj.asm

OBJ_Type                EQU     OBJ.OBJ_Type
OBJ_State               EQU     OBJ.OBJ_State
OBJ_Action              EQU     OBJ.OBJ_Action
OBJ_SpeedX              EQU     OBJ.OBJ_SpeedX
OBJ_SpeedY              EQU     OBJ.OBJ_SpeedY
OBJ_SpeedXFrac          EQU     OBJ.OBJ_SpeedXFrac
OBJ_SpeedYFrac          EQU     OBJ.OBJ_SpeedYFrac
OBJ_AccelX              EQU     OBJ.OBJ_AccelX
OBJ_AccelY              EQU     OBJ.OBJ_AccelY
OBJ_AccelXFrac          EQU     OBJ.OBJ_AccelXFrac
OBJ_AccelYFrac          EQU     OBJ.OBJ_AccelYFrac
OBJ_RangeX              EQU     OBJ.OBJ_RangeX
OBJ_RangeY              EQU     OBJ.OBJ_RangeY
OBJ_Health              EQU     OBJ.OBJ_Health
OBJ_Blink               EQU     OBJ.OBJ_Blink
OBJ_CollIndex           EQU     OBJ.OBJ_CollIndex
OBJ_Flag                EQU     OBJ.OBJ_Flag
OBJ_ScreenX             EQU     OBJ.OBJ_ScreenX
OBJ_ScreenY             EQU     OBJ.OBJ_ScreenY
OBJ_WorldXLo            EQU     OBJ.OBJ_WorldXLo
OBJ_WorldXHi            EQU     OBJ.OBJ_WorldXHi
OBJ_WorldYLo            EQU     OBJ.OBJ_WorldYLo
OBJ_WorldYHi            EQU     OBJ.OBJ_WorldYHi
OBJ_WorldXFrac          EQU     OBJ.OBJ_WorldXFrac
OBJ_WorldYFrac          EQU     OBJ.OBJ_WorldYFrac
OBJ_MapOfs              EQU     OBJ.OBJ_MapOfs
OBJ_NextAction          EQU     OBJ.OBJ_NextAction
OBJ_Var0                EQU     OBJ.OBJ_Var0
OBJ_Var1                EQU     OBJ.OBJ_Var1
OBJ_Var2                EQU     OBJ.OBJ_Var2
OBJ_Var3                EQU     OBJ.OBJ_Var3


; Exported symbols.
.extrn ObjCount:byte
.extrn ObjPageX:byte
.extrn ObjPageY:byte
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
