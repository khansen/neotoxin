AFLAGS = --debug -I. $(DEFINES)

LFLAGS = 

XASM = xasm $(AFLAGS)

XLNK = xlnk $(LFLAGS)

SCRIPTS = script/introscript.bin script/npc6script.bin

OBJS = blur.o vste.o ngsl.o huff.o titlescreen.o gameinfo.o selectgame.o \
entername.o musicplayer.o screendata.o ruins.o plant.o base.o building.o \
boss0.o boss1.o boss2.o sequencer.o envelope.o effect.o rnmedata.o songs.o \
sfxdata.o bgcollision.o objcollision.o movement.o scroller.o nametable.o \
attribtable.o renderer.o obj.o anim.o mmc3.o palette.o fade.o gbObj.o \
gbAction.o player.o gbLoop.o main.o warp.o savegame.o statusscreen.o \
flags.o ppu.o joypad.o clearram.o math.o maincycle.o area2d.o demomode.o \
statusmain.o gameover.o levelup.o enemy.o nmi.o irq.o gamedata.o areahdrs.o \
dmcdata.o vectors.o

HEADERFILE = ines.hdr

SCRIPTFILE = link.s

BINFILE = neotoxin.nes

BINFILE_SHA1 = f0139b8e0f211074e41a20255930f12a72f328d7

HEADERS = $(wildcard *.h)

CHRFILES = $(wildcard chr/*.chr)

all: $(BINFILE)

$(BINFILE): $(OBJS) $(HEADERFILE) $(SCRIPTFILE) $(CHRFILES)
	$(XLNK) $(SCRIPTFILE) -o $@

%.o: %.asm
	$(XASM) $< -o $@

# xasm cannot emit dependency files, and a full build takes under a second,
# so every unit depends on every shared header.
$(OBJS): $(HEADERS)

# Additional inputs pulled in via .incsrc, .include, .incbin and .charmap
ngsl.o: $(SCRIPTS) huff/strings.inc
huff.o: huff/huffpuff.tab
songs.o: $(wildcard music/*.inc)
vste.o: font.tbl
screendata.o: font.tbl $(wildcard data/*.dat) data/title.pal
gamedata.o: data/demo.dat
dmcdata.o: $(wildcard sound/*)

ruins.o: area/ruins/rnMain.asm $(wildcard area/ruins/*.inc)
	$(XASM) $< -o $@

plant.o: area/plant/plMain.asm $(wildcard area/plant/*.inc)
	$(XASM) $< -o $@

base.o: area/base/bsMain.asm $(wildcard area/base/*.inc)
	$(XASM) $< -o $@

building.o: area/building/bdMain.asm $(wildcard area/building/*.inc)
	$(XASM) $< -o $@

boss0.o: area/boss0/b0Main.asm $(wildcard area/boss0/*.inc)
	$(XASM) $< -o $@

boss1.o: area/boss1/b1Main.asm $(wildcard area/boss1/*.inc)
	$(XASM) $< -o $@

boss2.o: area/boss2/b2Main.asm $(wildcard area/boss2/*.inc)
	$(XASM) $< -o $@

script/%.bin: script/%.asm script/script.h
	$(XASM) --pure-binary -Iscript $< -o $@

check: $(BINFILE)
	echo "$(BINFILE_SHA1)  $(BINFILE)" | shasum -c -

test: $(BINFILE)
	./test/run_test.sh $(BINFILE)

.PHONY: all check clean test

clean:
	rm -f $(BINFILE) $(OBJS) $(SCRIPTS)
