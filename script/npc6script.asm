.incsrc "script.h"

CDDeliveredFlag = 25
HasCDRomFlag = 15

LoadPic 11
ScreenOn
FadeIn
GoTrue CDDeliveredFlag, @@AlreadyDelivered
GoTrue HasCDRomFlag, @@HasCDRom
PrintX 6 ; "Help me"
Jump @@Leave

@@HasCDRom:
PlaySFX 2
SetTrue CDDeliveredFlag
PrintX 7 ; "Thank you"
Jump @@Leave

@@AlreadyDelivered:
PrintX 9 ; "Beat it, punk"

@@Leave:
FadeOut
ReturnToArea
