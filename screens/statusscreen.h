.ifndef STATUSSCREEN_H
.define STATUSSCREEN_H

; Exported symbols.
.extrn AC0:byte
.extrn AC1:byte
.extrn AC2:byte
.extrn PrintValue:proc
.extrn UpdateClock:proc
.extrn CheckPause:proc
.extrn StatusMain:proc
.extrn ExitStatusScreen:proc
.extrn ResumeArea:proc

.endif  ; !STATUSSCREEN_H
