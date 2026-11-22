.ifndef PPU_H
.define PPU_H

; Exported symbols.
.extrn ScreenOff:proc
.extrn ClearDisplay:proc
.extrn LoadCHR:proc
.extrn ScreenOn:proc
.extrn EndPPUString:proc
.extrn WaitNMIPass:proc
.extrn WriteRAMPPUString:proc
.extrn WriteROMPPUString:proc
.extrn Return:proc
.extrn CheckPPUWrite:proc
.extrn FrameDelay:proc
.extrn UpdateTimers:proc
.extrn Load2DAreaHdr:proc
.extrn WritePPUString:proc

.endif  ; !PPU_H
