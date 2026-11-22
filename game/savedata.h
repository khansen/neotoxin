.ifndef SAVEDATA_H
.define SAVEDATA_H

; The saved game. A save slot in battery-backed WRAM holds the player's stats,
; the status flags and the player's name, followed by a checksum. This layout
; is the save file format: changing it makes existing saves unreadable.

NAME_LENGTH             EQU     10
STATUS_FLAG_BYTES       EQU     32
SAVE_SLOTS              EQU     $6000   ; slot n is at SAVE_SLOTS + n * 64

; Player stats, saved and restored as one block. InitialSaveGame
; (game/gamedata.asm) gives the starting values in this order.
.struc save_stats
Health          .byte
HealthFrac      .byte
Level           .byte
MaxHealth       .byte
Defense         .byte
Experience      .word
ExpFrac         .byte
Hours           .byte
Minutes         .byte
Seconds         .byte
ClockTicks      .byte
CurrentArea     .byte
CurrentSection  .byte
CurrentWarp     .byte
WarpType        .byte
ProjectileType  .byte
.ends

; One save slot (64 bytes; SetSavePtr computes slot addresses with shifts).
.struc save_slot
Stats           .save_stats
Flags           .byte[STATUS_FLAG_BYTES]
Name            .byte[NAME_LENGTH]
Unused0         .byte
Checksum        .word           ; sum of Stats, Flags and Name
Unused1         .byte[2]
.ends

; RAM copies of the saved data.
.extrn SaveStats:save_stats     ; game/savegame.asm
.extrn NameStr:byte             ; game/savegame.asm, NAME_LENGTH bytes
.extrn StatusFlags:byte         ; game/flags.asm, STATUS_FLAG_BYTES bytes

Health                  EQU     SaveStats.Health
HealthFrac              EQU     SaveStats.HealthFrac
Level                   EQU     SaveStats.Level
MaxHealth               EQU     SaveStats.MaxHealth
Defense                 EQU     SaveStats.Defense
Experience              EQU     SaveStats.Experience
ExpFrac                 EQU     SaveStats.ExpFrac
Hours                   EQU     SaveStats.Hours
Minutes                 EQU     SaveStats.Minutes
Seconds                 EQU     SaveStats.Seconds
ClockTicks              EQU     SaveStats.ClockTicks
CurrentArea             EQU     SaveStats.CurrentArea
CurrentSection          EQU     SaveStats.CurrentSection
CurrentWarp             EQU     SaveStats.CurrentWarp
WarpType                EQU     SaveStats.WarpType
ProjectileType          EQU     SaveStats.ProjectileType

.endif  ; !SAVEDATA_H
