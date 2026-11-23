; Description:
; The eight countdown timers (Timer), decremented every TIMER_SPEED frames.

.ifndef TEMPS_H
.define TEMPS_H

; Zero page temporaries shared by all code; a routine may use them only
; until it calls another routine that might.

.extrn pCode:word               ; GoRoutine's jump table pointer
.extrn pData:word               ; general purpose data pointer
.extrn Temp:byte                ; 4 bytes; Temp/Temp+1 is also used as a word
.extrn Count:byte
.extrn Count2:byte
.extrn Count3:byte
.extrn Index:byte
.extrn Index2:byte
.extrn Index3:byte
.extrn Index4:byte

Temp2                   EQU     Temp+1
Temp3                   EQU     Temp+2
Temp4                   EQU     Temp+3

.endif  ; !TEMPS_H
