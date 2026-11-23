.ifndef DEMOMODE_H
.define DEMOMODE_H

; WRAM buffer that a DEMOREC build records the player's input to.
DEMO_BUFFER             EQU     $7100   ; page aligned

; Exported symbols.
.extrn pDemo:word
.extrn OldStat:byte
.extrn JoyCount:byte
.extrn DemoMode:byte
.extrn DemoNumber:byte
.extrn PlayDemo:proc
.extrn RecordDemo:proc

.endif  ; !DEMOMODE_H
