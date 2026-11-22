.ifndef GAME_H
.define GAME_H

; Constants

NULL                    EQU     0
TIMER_SPEED             EQU     12
;CHRANIM_SPEED           EQU     8
BLANK_TILE              EQU     $00
MAX_SCROLLSPEED         EQU     2
SCROLL_TRESHOLD         EQU     80

; Zero page defs

ScrollX                 EQU     $00
ScrollY                 EQU     $01
ZPCtrl0                 EQU     $02
ZPCtrl1                 EQU     $03
MainRoutine             EQU     $04
IRQRoutine              EQU     $05
FrameStat               EQU     $06
FrameCount              EQU     $07
JoyStat                 EQU     $0B
JoyFirst                EQU     $0C
FlashPos                EQU     $0D
ScreenX                 EQU     $0E
ScreenY                 EQU     $0F
SpriteBase              EQU     $10
SpriteIndex             EQU     $11
CelLength               EQU     $12
Timer                   EQU     $13     ; 8 bytes
TimerDelay              EQU     $1B
PPUDataPending          EQU     $1C
Temp                    EQU     $1D
Temp2                   EQU     $1E
Temp3                   EQU     $1F
Temp4                   EQU     $20
Random                  EQU     $21
Count                   EQU     $22
Count2                  EQU     $23
Count3                  EQU     $24
Count4                  EQU     $25
ComboPos                EQU     $26
AllowDblJmp             EQU     $27
RoomFlags               EQU     $28
;CHRAnimStat             EQU     $27
;CHRAnimFrame            EQU     $28
;CHRAnimDelay            EQU     $29
CurrentBank             EQU     $2A
NextRoutine             EQU     $2B
SelectedCHR             EQU     $2C     ; 6 bytes
PPUStrIndex             EQU     $32
SinePos                 EQU     $33
IRQCount                EQU     $34
CollStat                EQU     $35
DemoNumber              EQU     $36
ObjLoadEnable           EQU     $37
DemoMode                EQU     $38
Index                   EQU     $39
Index2                  EQU     $3A
Index3                  EQU     $3B
Index4                  EQU     $3C
ProjectileCount         EQU     $3D
XIndexStart             EQU     $3E
YIndexStart             EQU     $3F
CurrentSpeed            EQU     $40
MaxSpeed                EQU     $41
ObjCount                EQU     $42
ObjPageX                EQU     $43
ObjPageY                EQU     $44
CurrentGame             EQU     $45
AreaStartX              EQU     $46
AreaStartY              EQU     $47
PlayerStart             EQU     $48
SaveSlot                EQU     $49
MenuSelect              EQU     $4A
MenuItemCount           EQU     $4B

OBJ1_Left               EQU     $4C
OBJ1_Top                EQU     $4D
OBJ1_Right              EQU     $4E
OBJ1_Bottom             EQU     $4F
OBJ2_Left               EQU     $50
OBJ2_Top                EQU     $51
OBJ2_Right              EQU     $52
OBJ2_Bottom             EQU     $53
CollObjCount            EQU     $54
CollObjNums             EQU     $55
CollObjTypes            EQU     $5C ; 8 bytes

ObjMapOfs               EQU     $63
LetterCol               EQU     $64
LetterRow               EQU     $65
NamePos                 EQU     $66
NameStr                 EQU     $67 ; 10 bytes

; current game status

Health                  EQU     $72
HealthFrac              EQU     $73
Level                   EQU     $74
MaxHealth               EQU     $75
Defense                 EQU     $76
Experience              EQU     $77
ExpFrac                 EQU     $79
Hours                   EQU     $7A
Minutes                 EQU     $7B
Seconds                 EQU     $7C
ClockTicks              EQU     $7D
CurrentArea             EQU     $7E
CurrentSection          EQU     $7F
CurrentWarp             EQU     $80
WarpType                EQU     $81
ProjectileType          EQU     $82

; 2D area header

ah_AreaBank             EQU     $84
ah_pMaps                EQU     $85
ah_pMacroPtrTable       EQU     $87
ah_pMacroAttribTable    EQU     $89
ah_pMacroStateTable     EQU     $8B
ah_pAreaPalette         EQU     $8D
ah_AreaCHR              EQU     $8F
ah_pObjConstructors     EQU     $91
ah_pActionPtrTable      EQU     $93
ah_pLoopPtrTable        EQU     $95

; current section
MapWidth                EQU     $97
MapHeight               EQU     $99
pMap                    EQU     $9B
p2DWarps                EQU     $9D

ObjLoadQueueXSize       EQU     $D4
ObjLoadQueueX           EQU     $D5 ; 8 bytes
ObjLoadQueueYSize       EQU     $DD
ObjLoadQueueY           EQU     $DE ; -$E5, 8 bytes

pCode                   EQU     $FC
pData                   EQU     $FE

PPUString               EQU     $0100
RAMPalette              EQU     $0160
StatusFlags             EQU     $0180


mrTitleInit             EQU     0
mrTitleMain             EQU     1
mrExecWarp              EQU     2
mrArea2DInit            EQU     3
mrArea2DMain            EQU     4
mrPlayDemo              EQU     5
mrStatusMain            EQU     6
mrLevelUpInit           EQU     7
mrLevelUpMain           EQU     8
mrGameOverInit          EQU     9
mrGameOverMain          EQU     10
mrEnterNameInit         EQU     11
mrEnterNameMain         EQU     12
mrSelectGameInit        EQU     13
mrSelectGameMain        EQU     14
mrGameMenuMain          EQU     15
mrStartNewGame          EQU     16
mrPerformNameChange     EQU     17
mrCreditsInit           EQU     18
mrCreditsMain           EQU     19
mrGameInfoInit          EQU     20
mrGameInfoInit2         EQU     21
mrGameInfoMain          EQU     22
mrWaitTimer             EQU     23
mrScriptInit            EQU     24
mrScriptMain            EQU     25
mrMusicPlayerInit       EQU     26
mrMusicPlayerMain       EQU     27

INITIAL_DEFENSE         EQU     32
INITIAL_HEALTH          EQU     24
INITIAL_MAXHEALTH       EQU     24

; DEMOREC EQU 1 ; uncomment to record demo

AC0    EQU $F2  ; initial dividend & resulting quotient
AC1    EQU $F3
AC2    EQU $F4
XTND0  EQU $F5  ; remainder
XTND1  EQU $F6
XTND2  EQU $F7
AUX0   EQU $F8  ; divisor
AUX1   EQU $F9
AUX2   EQU $FA
TMP0   EQU $FB

pDemo       EQU     $75
OldStat     EQU     $77
JoyCount    EQU     $78

.endif
