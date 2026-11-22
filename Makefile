AFLAGS = --debug -I. $(DEFINES)

LFLAGS = 

XASM = xasm $(AFLAGS)

XLNK = xlnk $(LFLAGS)

CXX = c++

CXXFLAGS = -O2 -Wall -Wextra

TOOLS = tools/nga2asm tools/xm2muz tools/comp

SCRIPTS = script/introscript.bin script/npc6script.bin

OBJS = vste.o ngsl.o huff.o titlescreen.o gameinfo.o selectgame.o \
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

HEADERS = $(wildcard *.h) $(wildcard area/*/*.h)

CHRFILES = $(wildcard chr/*.chr)

# Generated assets. They are committed too, so a checkout builds without the
# converters having run, but each is rebuilt whenever its source or tool
# changes, and must come out identical to the committed copy.
#
# Sources that are kept as reference only, because the committed output was
# edited by hand after conversion and is now the file to edit:
#   music/*.xm except neox009.xm   patterns shortened to fit bank 6
#   area/*/*.nga for every section not listed below (item IDs, script
#   pointers and warps were added to the .inc by hand, and bsSect12.inc
#   has one changed warp target)
PLANT_GEN_SECTS = $(patsubst %,area/plant/plSect%.inc,1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16)

BASE_GEN_SECTS = $(patsubst %,area/base/bsSect%.inc,1 2 3 4 5 6 7 8 9 10 11 13 14 15)

GEN_DATS = data/dialog.dat data/name2.dat data/select22.dat

GEN_MUSIC = music/neox009.inc

all: $(TOOLS) $(BINFILE)

# Never leave a half-written generated file (e.g. a converter's error message
# redirected into a tracked .inc) behind with a fresh timestamp.
.DELETE_ON_ERROR:

$(BINFILE): $(OBJS) $(HEADERFILE) $(SCRIPTFILE) $(CHRFILES)
	$(XLNK) $(SCRIPTFILE) -o $@

%.o: %.asm
	$(XASM) $< -o $@

# xasm cannot emit dependency files, and a full build takes under a second,
# so every unit depends on every shared header.
$(OBJS): $(HEADERS)

# Additional inputs pulled in via .incsrc, .include, .incbin and .charmap.
# Generated files are listed by name, not only through $(wildcard), so that
# make can recreate one that is missing.
ngsl.o: $(SCRIPTS) huff/strings.inc
huff.o: huff/huffpuff.tab
songs.o: $(wildcard music/*.inc) $(GEN_MUSIC)
vste.o: font.tbl
screendata.o: font.tbl $(wildcard data/*.dat) $(GEN_DATS) data/title.pal
gamedata.o: data/demo.dat
dmcdata.o: $(wildcard sound/*)

ruins.o: area/ruins/rnMain.asm $(wildcard area/ruins/*.inc)
	$(XASM) $< -o $@

plant.o: area/plant/plMain.asm $(wildcard area/plant/*.inc) $(PLANT_GEN_SECTS)
	$(XASM) $< -o $@

base.o: area/base/bsMain.asm $(wildcard area/base/*.inc) $(BASE_GEN_SECTS)
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

tools/%: tools/%.cpp
	$(CXX) $(CXXFLAGS) $< -o $@

# huffpuff (installed separately) writes both files in one run, so it is only
# needed when strings.txt or font.tbl changes. A pattern rule with two targets is run
# once for both (an explicit two-target rule would run twice under make -j, and
# GNU make 3.81 has no &: grouped targets), hence the "huf%" stem.
huf%/huffpuff.tab huf%/strings.inc: huf%/strings.txt font.tbl
	huffpuff --character-map=font.tbl --table-output=huff/huffpuff.tab --data-output=huff/strings.inc --table-label= --generate-string-table --string-table-label= huff/strings.txt

data/dialog.dat: data/dialog.nam tools/comp
	tools/comp $< 32 24 0x2082 $@

data/name2.dat: data/name.nam tools/comp
	tools/comp $< 32 23 0x2062 $@

data/select22.dat: data/select2.nam tools/comp
	tools/comp $< 32 24 0x2065 $@

$(PLANT_GEN_SECTS): area/plant/plSect%.inc: area/plant/plant_sect%.nga tools/nga2asm
	tools/nga2asm $< -r -w > $@

$(BASE_GEN_SECTS): area/base/bsSect%.inc: area/base/base_sect%.nga tools/nga2asm
	tools/nga2asm $< -r -w > $@

$(GEN_MUSIC): music/%.inc: music/%.xm tools/xm2muz
	tools/xm2muz $< > $@

test: $(BINFILE)
	./test/run_test.sh $(BINFILE)

.PHONY: all clean test

clean:
	rm -f $(BINFILE) $(OBJS) $(SCRIPTS) $(TOOLS)
