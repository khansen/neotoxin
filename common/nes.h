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

; The sprite page: 64 sprites of 4 bytes, copied to the PPU by the NMI with
; sprite DMA. It is the only fixed RAM besides the stack ($0100-$01FF is
; shared with linker-placed variables below $01A0).
SPRITE_PAGE             EQU     $0200
SPR_PosY                EQU     SPRITE_PAGE
SPR_Tile                EQU     SPRITE_PAGE+1
SPR_Attrib              EQU     SPRITE_PAGE+2
SPR_PosX                EQU     SPRITE_PAGE+3

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
