.ifndef HSGE_H
.define HSGE_H

;-----------------------------[ HSGE defines ]--------------------------------

; All RAM locations are defined relative to this address so we can easily relocate.
HSGE_RAM            EQU     $A0 ; - $BB

; bytes

HSGE_MapOfs         EQU     HSGE_RAM
HSGE_RoomOfs        EQU     HSGE_RAM+1
HSGE_RoomCol        EQU     HSGE_RAM+2
HSGE_RoomRow        EQU     HSGE_RAM+3
HSGE_ScreenRow      EQU     HSGE_RAM+4
HSGE_ScrollQueue    EQU     HSGE_RAM+5  ; 3-byte array!
HSGE_QueueSize      EQU     HSGE_RAM+8
HSGE_QueueItem      EQU     HSGE_RAM+9
HSGE_ScrollY        EQU     HSGE_RAM+10
HSGE_ScreenTable    EQU     HSGE_RAM+11
HSGE_TempRow        EQU     HSGE_RAM+12
HSGE_Temp2000       EQU     HSGE_RAM+13

; 16-bit values/pointers

HSGE_WorldViewX     EQU     HSGE_RAM+14
HSGE_WorldViewY     EQU     HSGE_RAM+16
HSGE_pRoom          EQU     HSGE_RAM+18  ; pointer to room data
HSGE_pMacro         EQU     HSGE_RAM+20  ; pointer to macro data
HSGE_pObject        EQU     HSGE_RAM+22  ; pointer to room objects data
HSGE_pObjInfo       EQU     HSGE_RAM+24
HSGE_VRAMAddr       EQU     HSGE_RAM+26


.endif
