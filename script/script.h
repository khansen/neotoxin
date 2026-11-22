.ifndef SCRIPT_H
.define SCRIPT_H

.enum Command
Cmd_End = 0
Cmd_SetTrue
Cmd_SetFalse
Cmd_GoTrue
Cmd_GoFalse
Cmd_Jump
Cmd_Print
Cmd_PlaySong
Cmd_GoArea
Cmd_LoadPic
Cmd_FadeIn
Cmd_FadeOut
Cmd_TextSpeed
Cmd_ScreenOn
Cmd_ScreenOff
Cmd_Delay
Cmd_ClearScreen
Cmd_GoScript
Cmd_PrintX
Cmd_MultipleChoice
Cmd_SetPalette
Cmd_SetTitle
Cmd_Save
Cmd_PlaySFX
.ende

.macro PlaySong songNo
.db Cmd_PlaySong, songNo
.endm

.macro LoadPic picNo
.db Cmd_LoadPic : .db picNo
.endm

.macro ScreenOn
.db Cmd_ScreenOn
.endm

.macro FadeIn
.db Cmd_FadeIn
.endm

.macro PrintX strNo
.db Cmd_PrintX : .db strNo
.endm

.macro ScreenOff
.db Cmd_ScreenOff
.endm

.macro SetPalette
.db Cmd_SetPalette
.endm

.macro FadeOut
.db Cmd_FadeOut
.endm

.macro GoArea byte0, byte1
.db Cmd_GoArea : db byte0, byte1
.endm

.macro SetTrue flag
.db Cmd_SetTrue : .db flag
.endm

.macro GoTrue flag, where
.db Cmd_GoTrue : .db flag : .db where - ($ + 1)
.endm

.macro GoFalse flag, where
.db Cmd_GoFalse : .db flag : .db where - ($ + 1)
.endm

.macro Jump where
.db Cmd_Jump : .db where - ($ + 1)
.endm

.macro PlaySFX sfxNo
.db Cmd_PlaySFX : .db sfxNo
.endm

.macro ReturnToArea
.db Cmd_GoArea : .db $FF, $FF
.endm

.endif ; !SCRIPT_H
