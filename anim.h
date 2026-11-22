.ifndef ANIM_H
.define ANIM_H

ANIM_Loop               EQU     $0300
ANIM_pLoopLo            EQU     $0318
ANIM_pLoopHi            EQU     $0330
ANIM_Cel                EQU     $0348
ANIM_pCelLo             EQU     $0360
ANIM_pCelHi             EQU     $0378
ANIM_NumCels            EQU     $0390
ANIM_Speed              EQU     $03A8
ANIM_Tick               EQU     $03C0
ANIM_Method             EQU     $03D8
ANIM_CHRPage            EQU     $03F0

ANIM_pLoop              EQU     $BC
ANIM_pCel               EQU     $BE

amNoCycling             EQU     $80
amForward               EQU     $40
amForwardLoop           EQU     $20
amReverse               EQU     $10
amReverseLoop           EQU     $08


; Exported symbols.
.extrn ANIM_SetLoop:proc
.extrn ANIM_SetCel:proc
.extrn ANIM_GoMethod:proc
.extrn ANIM_DrawCel:proc

.endif
