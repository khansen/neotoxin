.ifndef AREAHDRS_H
.define AREAHDRS_H

; Header of a 2D area, as listed in AreaHdrTable. Load2DAreaHdr copies the
; current area's header to AreaHdr.
.struc area_header
AreaBank            .byte
pMaps               .word
pMacroPtrTable      .word
pMacroAttribTable   .word
pMacroStateTable    .word
pAreaPalette        .word
AreaCHR             .word
pObjConstructors    .word
pActionPtrTable     .word
pLoopPtrTable       .word
.ends

.extrn AreaHdr:area_header      ; area/areahdrs.asm

ah_AreaBank             EQU     AreaHdr.AreaBank
ah_pMaps                EQU     AreaHdr.pMaps
ah_pMacroPtrTable       EQU     AreaHdr.pMacroPtrTable
ah_pMacroAttribTable    EQU     AreaHdr.pMacroAttribTable
ah_pMacroStateTable     EQU     AreaHdr.pMacroStateTable
ah_pAreaPalette         EQU     AreaHdr.pAreaPalette
ah_AreaCHR              EQU     AreaHdr.AreaCHR
ah_pObjConstructors     EQU     AreaHdr.pObjConstructors
ah_pActionPtrTable      EQU     AreaHdr.pActionPtrTable
ah_pLoopPtrTable        EQU     AreaHdr.pLoopPtrTable

; Exported symbols.
.extrn AreaHdrTable:label
.extrn Load2DAreaHdr:proc

.endif  ; !AREAHDRS_H
