.ifndef SAVEGAME_H
.define SAVEGAME_H

; Exported symbols.
.extrn SaveSlot:byte
.extrn WriteSaveGame:proc
.extrn LoadSaveGame:proc
.extrn CalcSaveGameCheckSum:proc

.endif  ; !SAVEGAME_H
