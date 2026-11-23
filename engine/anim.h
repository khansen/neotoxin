.ifndef ANIM_H
.define ANIM_H

.include "engine/obj.h"

; Animation state of each object, indexed by object slot.
.struc anim_table
ANIM_Loop               .byte[MAX_OBJECTS]
ANIM_pLoopLo            .byte[MAX_OBJECTS]
ANIM_pLoopHi            .byte[MAX_OBJECTS]
ANIM_Cel                .byte[MAX_OBJECTS]
ANIM_pCelLo             .byte[MAX_OBJECTS]
ANIM_pCelHi             .byte[MAX_OBJECTS]
ANIM_NumCels            .byte[MAX_OBJECTS]
ANIM_Speed              .byte[MAX_OBJECTS]
ANIM_Tick               .byte[MAX_OBJECTS]
ANIM_Method             .byte[MAX_OBJECTS]
ANIM_CHRPage            .byte[MAX_OBJECTS]
.ends

.extrn ANIM:anim_table       ; engine/anim.asm

ANIM_Loop               EQU     ANIM.ANIM_Loop
ANIM_pLoopLo            EQU     ANIM.ANIM_pLoopLo
ANIM_pLoopHi            EQU     ANIM.ANIM_pLoopHi
ANIM_Cel                EQU     ANIM.ANIM_Cel
ANIM_pCelLo             EQU     ANIM.ANIM_pCelLo
ANIM_pCelHi             EQU     ANIM.ANIM_pCelHi
ANIM_NumCels            EQU     ANIM.ANIM_NumCels
ANIM_Speed              EQU     ANIM.ANIM_Speed
ANIM_Tick               EQU     ANIM.ANIM_Tick
ANIM_Method             EQU     ANIM.ANIM_Method
ANIM_CHRPage            EQU     ANIM.ANIM_CHRPage


amNoCycling             EQU     $80
amForward               EQU     $40
amForwardLoop           EQU     $20
amReverse               EQU     $10
amReverseLoop           EQU     $08


; Exported symbols.
.extrn SpriteBase:byte
.extrn SpriteIndex:byte
.extrn ANIM_SetLoop:proc
.extrn ANIM_SetCel:proc
.extrn ANIM_GoMethod:proc
.extrn ANIM_DrawCel:proc

.endif
