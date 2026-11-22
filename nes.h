.ifndef NES_H
.define NES_H

; Hardware reg defs

PPUCtrl0                EQU     $2000
PPUCtrl1                EQU     $2001
PPUStat                 EQU     $2002
SPRAddr                 EQU     $2003
SPRIOReg                EQU     $2004
PPUScroll               EQU     $2005
PPUAddr                 EQU     $2006
PPUIOReg                EQU     $2007
SPRDMAReg               EQU     $4014
JoyReg                  EQU     $4016


; Sprite RAM defs

SPR_PosX                EQU     $0203
SPR_PosY                EQU     $0200
SPR_Tile                EQU     $0201
SPR_Attrib              EQU     $0202

; Joy pad defs

btnRIGHT                EQU     %00000001
btnLEFT                 EQU     %00000010
btnDOWN                 EQU     %00000100
btnUP                   EQU     %00001000
btnSTART                EQU     %00010000
btnSELECT               EQU     %00100000
btnB                    EQU     %01000000
btnA                    EQU     %10000000


.endif
