.ifndef HSGE_H
.define HSGE_H

;-----------------------------[ HSGE defines ]--------------------------------

; The engine's state, all in zero page (instance HSGE in engine/renderer.asm).
.struc hsge_state
MapOfs              .byte
RoomOfs             .byte
RoomCol             .byte
RoomRow             .byte
ScreenRow           .byte
ScrollQueue         .byte[3]
QueueSize           .byte
QueueItem           .byte
ScrollY             .byte
ScreenTable         .byte
TempRow             .byte
Temp2000            .byte
WorldViewX          .word
WorldViewY          .word
pRoom               .word   ; pointer to room data
pMacro              .word   ; pointer to macro data
pObject             .word   ; pointer to room objects data
pObjInfo            .word
VRAMAddr            .word
.ends

.extrn HSGE:hsge_state

HSGE_MapOfs         EQU     HSGE.MapOfs
HSGE_RoomOfs        EQU     HSGE.RoomOfs
HSGE_RoomCol        EQU     HSGE.RoomCol
HSGE_RoomRow        EQU     HSGE.RoomRow
HSGE_ScreenRow      EQU     HSGE.ScreenRow
HSGE_ScrollQueue    EQU     HSGE.ScrollQueue
HSGE_QueueSize      EQU     HSGE.QueueSize
HSGE_QueueItem      EQU     HSGE.QueueItem
HSGE_ScrollY        EQU     HSGE.ScrollY
HSGE_ScreenTable    EQU     HSGE.ScreenTable
HSGE_TempRow        EQU     HSGE.TempRow
HSGE_Temp2000       EQU     HSGE.Temp2000
HSGE_WorldViewX     EQU     HSGE.WorldViewX
HSGE_WorldViewY     EQU     HSGE.WorldViewY
HSGE_pRoom          EQU     HSGE.pRoom
HSGE_pMacro         EQU     HSGE.pMacro
HSGE_pObject        EQU     HSGE.pObject
HSGE_pObjInfo       EQU     HSGE.pObjInfo
HSGE_VRAMAddr       EQU     HSGE.VRAMAddr


.endif
