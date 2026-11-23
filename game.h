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


; shared temporaries (Temp, Count, Index, ...)
.include "common/temps.h"

; collision scratch (OBJ2_*, CollObjCount/Nums/Types)
.include "engine/scratch.h"


; current game status (Health, Level, CurrentArea, ..., NameStr, StatusFlags)
.include "game/savedata.h"

; 2D area header (ah_AreaBank, ah_pMaps, ...)
.include "area/areahdrs.h"


PPUString               EQU     $0100
RAMPalette              EQU     $0160


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
MR_COUNT                EQU     28      ; number of mr* routines

INITIAL_DEFENSE         EQU     32
INITIAL_HEALTH          EQU     24
INITIAL_MAXHEALTH       EQU     24

; DEMOREC EQU 1 ; uncomment to record demo


.endif
