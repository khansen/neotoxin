boss2_actionptrtable:
;;; common actions
.dw PlayerStand         ; 00
.dw PlayerRun           ; 01
.dw PlayerJump          ; 02
.dw PlayerFall          ; 03
.dw PlayerLadder        ; 04
.dw PlayerDuck          ; 05
.dw PlayerDead          ; 06
.dw PlayerHurt          ; 07
.dw ProjectileMain      ; 08
.dw ManualWarpMain      ; 09
.dw InstantWarpMain     ; 0A
.dw ItemMain            ; 0B
.dw NPCMain             ; 0C
.dw NeoDoorMain         ; 0D
.dw BlockingDoorMain    ; 0E
.dw DiscardObject       ; 0F
.dw Return              ; 10
.dw HealthItemMain      ; 11
.dw WaitAnimEnd         ; 12
.dw DiscardEnemy        ; 13
;;; area-specific actions
.dw Boss2WaitPlayerApproach
.dw Boss2Activate
.dw Boss2Startup
.dw Boss2Main

OE_BOSS2WAIT            EQU $14
OE_BOSS2ACTIVATE        EQU $15
OE_BOSS2STARTUP         EQU $16
OE_BOSS2MAIN            EQU $17

Boss2WaitPlayerApproach:

Boss2Activate:

Boss2Startup:

Boss2Main:

