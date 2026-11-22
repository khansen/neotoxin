.ifndef NGSL_H
.define NGSL_H

; NES Game Script Language

NGSL_Temp               EQU     $E6
NGSL_pScript            EQU     $EA
NGSL_pDataItem          EQU     $EC
NGSL_LineAddr           EQU     $EE
NGSL_TextSpeed          EQU     $F0
NGSL_CharsPerFrame      EQU     $F1

; Script Opcode defines

SO_END              EQU     0
SO_SET              EQU     1
SO_RESET            EQU     2
SO_JMPIFSET         EQU     3
SO_JMPIFNSET        EQU     4
SO_JMP              EQU     5
SO_PRINT            EQU     6
SO_PLAYSONG         EQU     7
SO_GOAREA           EQU     8
SO_LOADPIC          EQU     9
SO_FADEIN           EQU     10
SO_FADEOUT          EQU     11
SO_TXTSPEED         EQU     12  ; default: 1
SO_SCRON            EQU     13
SO_SCROFF           EQU     14
SO_DELAY            EQU     15
SO_CLRSCR           EQU     16
SO_GOSCRIPT         EQU     17
SO_PRINTX           EQU     18
SO_MULTCHOICE       EQU     19
SO_SETPAL           EQU     20
SO_SETTITLE         EQU     21
SO_SAVE             EQU     22
SO_PLAYSFX          EQU     23


.endif
