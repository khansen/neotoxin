AFLAGS = --debug -I. $(DEFINES)

# Units are built from these directories; their objects go to $(BUILD_DIR).
SRCDIRS = common sound engine game screens area

BUILD_DIR = build

LFLAGS = 

XASM = xasm $(AFLAGS)

XLNK = xlnk $(LFLAGS)

CXX = c++

CXXFLAGS = -O2 -Wall -Wextra

TOOLS = tools/nga2asm tools/xm2muz tools/comp

SCRIPTS = script/introscript.bin script/npc6script.bin

OBJS = $(addprefix $(BUILD_DIR)/, \
    vste.o \
    ngsl.o \
    huff.o \
    titlescreen.o \
    gameinfo.o \
    selectgame.o \
    entername.o \
    musicplayer.o \
    screendata.o \
    ruins.o \
    plant.o \
    base.o \
    building.o \
    boss0.o \
    boss1.o \
    boss2.o \
    sequencer.o \
    envelope.o \
    effect.o \
    rnmedata.o \
    songs.o \
    sfxdata.o \
    bgcollision.o \
    objcollision.o \
    scratch.o \
    movement.o \
    scroller.o \
    nametable.o \
    attribtable.o \
    renderer.o \
    obj.o \
    anim.o \
    mmc3.o \
    palette.o \
    fade.o \
    gbObj.o \
    gbAction.o \
    player.o \
    gbLoop.o \
    main.o \
    warp.o \
    savegame.o \
    statusscreen.o \
    flags.o \
    ppu.o \
    timer.o \
    joypad.o \
    clearram.o \
    temps.o \
    math.o \
    maincycle.o \
    area2d.o \
    demomode.o \
    gameover.o \
    levelup.o \
    enemy.o \
    nmi.o \
    irq.o \
    gamedata.o \
    areahdrs.o \
    dmcdata.o \
    sfx.o \
    vectors.o)

HEADERFILE = ines.hdr

SCRIPTFILE = link.s

BINFILE = neotoxin.nes

HEADERS = $(wildcard *.h $(addsuffix /*.h,$(SRCDIRS)) chr/*.h area/*/*.h)

CHRFILES = $(wildcard chr/*.chr)

# Generated assets. They are committed too, so a checkout builds without the
# converters having run, but each is rebuilt whenever its source or tool
# changes, and must come out identical to the committed copy.
#
# Sources kept as reference only, because the committed output was edited
# by hand after conversion and is now the file to edit:
#   music/*.xm except neox009.xm   patterns shortened to fit bank 6
#
# Every map section with a .nga source is generated from it. Where the .inc
# needs more than the converter produces (item IDs, script pointers, hand
# written warp tables), those edits are kept as a patch next to it
# (bdSect1.patch for bdSect1.inc) and applied to the converter output. The
# patches use no fuzz: if a map edit changes the lines a patch touches, the
# build stops (patch leaves a .rej file) instead of silently dropping the
# hand edit. To change a hand edit, edit the .inc, then recreate the patch:
#   tools/nga2asm SOURCE.nga -r -w | diff -u --label "X.inc (nga2asm -r -w)" \
#       --label X.inc - X.inc > X.patch
GEN_MAPS = \
    $(patsubst area/ruins/ruins_sect%.nga,area/ruins/rnSect%.inc,$(wildcard area/ruins/ruins_sect*.nga)) \
    $(patsubst area/plant/plant_sect%.nga,area/plant/plSect%.inc,$(wildcard area/plant/plant_sect*.nga)) \
    $(patsubst area/base/base_sect%.nga,area/base/bsSect%.inc,$(wildcard area/base/base_sect*.nga)) \
    $(patsubst area/boss0/boss0_sect%.nga,area/boss0/b0Sect%.inc,$(wildcard area/boss0/boss0_sect*.nga)) \
    $(patsubst area/building/building_sect%.nga,area/building/bdSect%.inc,$(wildcard area/building/building_sect*.nga)) \
    $(patsubst area/building/building_save%.nga,area/building/bdSave%.inc,$(wildcard area/building/building_save*.nga))

PATCHED_MAPS = $(patsubst %.patch,%.inc,$(wildcard area/*/*.patch))

GEN_DATS = data/dialog.dat data/name2.dat data/select22.dat

GEN_MUSIC = music/neox009.inc

all: $(TOOLS) $(BINFILE)

# Never leave a half-written generated file (e.g. a converter's error message
# redirected into a tracked .inc) behind with a fresh timestamp.
.DELETE_ON_ERROR:

$(BINFILE): $(OBJS) $(HEADERFILE) $(SCRIPTFILE) $(CHRFILES)
	$(XLNK) $(SCRIPTFILE) -o $@

vpath %.asm . $(SRCDIRS)

$(BUILD_DIR)/%.o: %.asm | $(BUILD_DIR)
	$(XASM) $< -o $@

$(BUILD_DIR):
	mkdir -p $@

# xasm cannot emit dependency files, and a full build takes under a second,
# so every unit depends on every shared header.
$(OBJS): $(HEADERS)

# Additional inputs pulled in via .incsrc, .include, .incbin and .charmap.
# Generated files are listed by name, not only through $(wildcard), so that
# make can recreate one that is missing.
$(BUILD_DIR)/ngsl.o: $(SCRIPTS) huff/strings.inc
$(BUILD_DIR)/huff.o: huff/huffpuff.tab
$(BUILD_DIR)/songs.o: $(wildcard music/*.inc) $(GEN_MUSIC)
$(BUILD_DIR)/vste.o: font.tbl
$(BUILD_DIR)/screendata.o: font.tbl $(wildcard data/*.dat) $(GEN_DATS) data/title.pal
$(BUILD_DIR)/gamedata.o: data/demo.dat
$(BUILD_DIR)/dmcdata.o: $(wildcard sound/samples/*) sound/samples/hurt.dmc

$(BUILD_DIR)/ruins.o: area/ruins/rnMain.asm $(wildcard area/ruins/*.inc) $(filter area/ruins/%,$(GEN_MAPS)) | $(BUILD_DIR)
	$(XASM) $< -o $@

$(BUILD_DIR)/plant.o: area/plant/plMain.asm $(wildcard area/plant/*.inc) $(filter area/plant/%,$(GEN_MAPS)) | $(BUILD_DIR)
	$(XASM) $< -o $@

$(BUILD_DIR)/base.o: area/base/bsMain.asm $(wildcard area/base/*.inc) $(filter area/base/%,$(GEN_MAPS)) | $(BUILD_DIR)
	$(XASM) $< -o $@

$(BUILD_DIR)/building.o: area/building/bdMain.asm $(wildcard area/building/*.inc) $(filter area/building/%,$(GEN_MAPS)) | $(BUILD_DIR)
	$(XASM) $< -o $@

$(BUILD_DIR)/boss0.o: area/boss0/b0Main.asm $(wildcard area/boss0/*.inc) $(filter area/boss0/%,$(GEN_MAPS)) | $(BUILD_DIR)
	$(XASM) $< -o $@

$(BUILD_DIR)/boss1.o: area/boss1/b1Main.asm $(wildcard area/boss1/*.inc) | $(BUILD_DIR)
	$(XASM) $< -o $@

$(BUILD_DIR)/boss2.o: area/boss2/b2Main.asm $(wildcard area/boss2/*.inc) | $(BUILD_DIR)
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

# Map sections: converter output, plus the section's patch if it has one.
define MAP_RECIPE
tools/nga2asm $< -r -w > $@.gen
rm -f $@ $@.rej
if [ -f $(@:.inc=.patch) ]; then \
    patch -s -F 0 -o $@ $@.gen < $(@:.inc=.patch) || { rm -f $@ $@.gen; exit 1; }; \
else cp $@.gen $@; fi
rm -f $@.gen
endef

area/ruins/rnSect%.inc: area/ruins/ruins_sect%.nga tools/nga2asm
	$(MAP_RECIPE)

area/plant/plSect%.inc: area/plant/plant_sect%.nga tools/nga2asm
	$(MAP_RECIPE)

area/base/bsSect%.inc: area/base/base_sect%.nga tools/nga2asm
	$(MAP_RECIPE)

area/boss0/b0Sect%.inc: area/boss0/boss0_sect%.nga tools/nga2asm
	$(MAP_RECIPE)

area/building/bdSect%.inc: area/building/building_sect%.nga tools/nga2asm
	$(MAP_RECIPE)

area/building/bdSave%.inc: area/building/building_save%.nga tools/nga2asm
	$(MAP_RECIPE)

$(PATCHED_MAPS): %.inc: %.patch

# The player-hurt sound is synthesized (deterministic, so the committed copy
# is reproduced exactly).
sound/samples/hurt.dmc: tools/hurtsfx.py
	python3 $< $@

$(GEN_MUSIC): music/%.inc: music/%.xm tools/xm2muz
	tools/xm2muz $< > $@

test: $(BINFILE)
	./test/run_test.sh $(BINFILE)

.PHONY: all clean test

clean:
	rm -f $(BINFILE) $(SCRIPTS) $(TOOLS)
	rm -rf $(BUILD_DIR)
