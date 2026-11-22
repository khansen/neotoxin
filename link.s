# iNES Header (16 bytes):
#   0-3: 'N', 'E', 'S', $1A
#   4:   $08 (8 x 16K PRG-ROM banks = 128K)
#   5:   $10 (16 x 8K CHR-ROM banks = 128K)
#   6:   $43 (Mapper = 4 / MMC3, Mirroring = 1 / vertical, WRAM = yes)
#   7-15: $00
copy{file=ines.hdr}
# Bank 0
bank{size=$4000,origin=$8000}
link{file=vste.o}
link{file=ngsl.o}
link{file=huff.o}
link{file=titlescreen.o}
link{file=gameinfo.o}
link{file=selectgame.o}
link{file=entername.o}
link{file=musicplayer.o}
link{file=screendata.o}
# Bank 1
bank{size=$4000,origin=$8000}
link{file=ruins.o}
# Bank 2
bank{size=$4000,origin=$8000}
link{file=plant.o}
# Bank 3
bank{size=$4000,origin=$8000}
link{file=base.o}
# Bank 4
bank{size=$4000,origin=$8000}
link{file=building.o}
link{file=boss0.o}
link{file=boss1.o}
link{file=boss2.o}
# Bank 5
bank{size=$4000,origin=$8000}
# Bank 6 - MUSIC
bank{size=$4000,origin=$8000}
link{file=sequencer.o}
link{file=envelope.o}
link{file=effect.o}
link{file=rnmedata.o}
link{file=songs.o}
link{file=sfxdata.o}
# Bank 7 - GAME KERNEL
bank{size=$4000,origin=$C000}
link{file=bgcollision.o}
link{file=objcollision.o}
link{file=movement.o}
link{file=scroller.o}
link{file=nametable.o}
link{file=attribtable.o}
link{file=renderer.o}
link{file=obj.o}
link{file=anim.o}
link{file=mmc3.o}
link{file=palette.o}
link{file=fade.o}
link{file=gbObj.o}
link{file=gbAction.o}
link{file=player.o}
link{file=gbLoop.o}
link{file=main.o}
link{file=warp.o}
link{file=savegame.o}
link{file=statusscreen.o}
link{file=flags.o}
link{file=ppu.o}
link{file=joypad.o}
link{file=clearram.o}
link{file=math.o}
link{file=maincycle.o}
link{file=area2d.o}
link{file=demomode.o}
link{file=statusmain.o}
link{file=gameover.o}
link{file=levelup.o}
link{file=enemy.o}
link{file=nmi.o}
link{file=irq.o}
link{file=gamedata.o}
link{file=areahdrs.o}
pad{origin=$FC00}
link{file=dmcdata.o}
pad{origin=$FFFA}
link{file=vectors.o}
# CHR banks (128 1K pages)
bank{size=$20000}
# 00-07: title screen
copy{file=chr/title2.chr}               # 0
copy{file=chr/title.chr}                # 4
# 08-1F: character animations
copy{file=chr/guystnd1.chr}             # 8
copy{file=chr/guystnd2.chr}             # 9
copy{file=chr/guyduck1.chr}             # 10
copy{file=chr/guyduck2.chr}             # 11
copy{file=chr/guyrun1.chr}              # 12
copy{file=chr/guyrun2.chr}              # 13
copy{file=chr/guyrun3.chr}              # 14
copy{file=chr/guyrun4.chr}              # 15
copy{file=chr/guyjump1.chr}             # 16
copy{file=chr/guyjump2.chr}             # 17
copy{file=chr/guyclmb1.chr}             # 18
copy{file=chr/guyclmb2.chr}             # 19
copy{file=chr/guydead1.chr}             # 20
copy{file=chr/guydead2.chr}             # 21
copy{file=chr/blank2.chr}               # 22
copy{file=chr/blank4.chr}               # 24
copy{file=chr/blank4.chr}               # 28
# 20-2F: area backgrounds
copy{file=chr/CityRuins.chr}            # 32
copy{file=chr/PowerPlant.chr}           # 36
copy{file=chr/Base.chr}                 # 40
copy{file=chr/Building.chr}             # 44
# 30-37: enemy animations
copy{file=chr/ruins_sprites2.chr}       # 48
copy{file=chr/Plant_Sprites.chr}        # 50
copy{file=chr/Base_Sprites2.chr}        # 52
copy{file=chr/Building_Sprites.chr}     # 54
# 38-49: boss CHR
copy{file=chr/boss0bg.chr}              # 56
copy{file=chr/boss0spr.chr}             # 60
copy{file=chr/boss1bg.chr}              # 62
copy{file=chr/boss1spr.chr}             # 66
copy{file=chr/boss2bg.chr}              # 68
copy{file=chr/boss2spr.chr}             # 72
# 4A-4C: NPC sprites
copy{file=chr/NPC_Sprites.chr}          # 74
copy{file=chr/blank4.chr}               # 76
# 50-53: meter, items, weapons, explosion
copy{file=chr/status.chr}               # 80
copy{file=chr/levelup.chr}              # 81
copy{file=chr/itemspr.chr}              # 82
copy{file=chr/blank1.chr}               # 83
# 54-57: status screen
copy{file=chr/blank4.chr}               # 84
# 58: font
copy{file=chr/gf99.chr}                 # 88
copy{file=chr/cursors.chr}              # 90
copy{file=chr/blank1.chr}               # 91
# 5C-5F: ending
copy{file=chr/theend.chr}               # 92
# 60-7F: cutscenes
copy{file=chr/robbie.chr}               # 96
copy{file=chr/intro1.chr}               # 98
copy{file=chr/zombie.chr}               # 100
copy{file=chr/save.chr}                 # 102
copy{file=chr/bosspic.chr}              # 104
copy{file=chr/blank2.chr}               # 106
copy{file=chr/blank2.chr}               # 108
copy{file=chr/blank2.chr}               # 110
# NPC mugshots
copy{file=chr/NPC0pic.chr}              # 112
copy{file=chr/NPC1pic.chr}              # 114
copy{file=chr/NPC2pic.chr}              # 116
copy{file=chr/NPC3pic.chr}              # 118
copy{file=chr/NPC4pic.chr}              # 120
copy{file=chr/NPC5pic.chr}              # 122
copy{file=chr/NPC6pic.chr}              # 124
copy{file=chr/NPC7pic.chr}              # 126
