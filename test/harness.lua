-- Behaviour test harness for NeoToxin (runs inside FCEUX via --loadlua).
-- Replays deterministic input sessions across Title, Music Player, Select Game,
-- Enter Name, Intro Cutscene, Building, Status Screen, NPC Dialog, Save/Reload,
-- Base, City Ruins (including the 827-frame recorded demo input stream from
-- data/demo.dat), Boss 0, Title Attract-Mode Demo (two loops), Power Plant,
-- the Boss 1 area, Level-Up, Game Over & Continue, Save Point Terminal, and the
-- End Credits Scroller, verifying 256x240 screen hashes at each checkpoint.
--
-- Every scenario after the first starts with emu.poweron() rather than
-- emu.softreset(): a soft reset keeps the CPU/PPU phase left behind by the
-- previous scenario, so a change in one scenario could alter the IRQ timing
-- (see hash_gd) of every later one. Battery-backed WRAM survives a power cycle.

emu.speedmode("turbo")

-- Advances one emulated frame. Turbo is requested again on every frame: a run
-- has occasionally timed out with no progress logged, consistent with FCEUX
-- resetting the speed after the first request while it finishes starting up.
local function advance()
    emu.speedmode("turbo")
    emu.frameadvance()
end

local script_path = debug.getinfo(1, "S").source:sub(2)
local test_dir = script_path:match("^(.*)/[^/]+$") or "."
local root_dir = test_dir:match("^(.*)/[^/]+$") or "."

local LOG_PATH = os.getenv("NEOTOXIN_TEST_LOG") or "/tmp/neotoxin_test.log"
local MODE = os.getenv("NEOTOXIN_TEST_MODE") or "verify" -- "verify" or "record"
local EXPECTED_PATH = test_dir .. "/expected_hashes.txt"
local DEMO_PATH = root_dir .. "/data/demo.dat"
local SHOT_DIR = os.getenv("NEOTOXIN_SHOT_DIR") -- if set, save each checkpoint as <id>.ppm

local out = io.open(LOG_PATH, "w")
local function log(s)
    if out then
        out:write(s .. "\n")
        out:flush()
    end
end

-- One line per checkpoint as it is taken, with the emulated frame number and
-- the wall-clock time, so a run that stalls or slows down shows where.
local progress = io.open(LOG_PATH .. ".progress", "w")
local function note_progress(what)
    if progress then
        progress:write(string.format("%s frame=%d time=%d\n", what, emu.framecount(), os.time()))
        progress:flush()
    end
end
note_progress("start")

local function finish()
    if out then
        out:flush()
        out:close()
        out = nil
    end
    -- Idle until test/run_test.sh sees the final PASS/FAIL line and kills
    -- FCEUX. Exiting from here (os.exit) races FCEUX's GUI thread and crashes.
    while true do
        emu.frameadvance()
    end
end

local report -- compares/records the checkpoints and finishes; defined below

-- Stops the run if a RAM/WRAM state check fails, still reporting the
-- checkpoints taken up to that point.
local function check_state(cond, msg)
    if not cond then
        report(tostring(msg))
    end
end

local function hash_gd(s, mode)
    if not s then return "nil" end
    local h1 = 5381
    local h2 = 0
    local mod1 = 4294967291
    local mod2 = 4294967279
    for y = 0, 239 do
        -- Scanlines 231-232 are never hashed: in Area2D and the status screen
        -- fade, the MMC3 IRQ (IRQCount = 231) runs IRQScreenOff, which turns
        -- rendering off mid-scanline at a dot that depends on IRQ latency,
        -- i.e. on whichever instruction the main loop happened to be
        -- executing. Any change to code timing would otherwise flip a few
        -- pixels there.
        local skip_row = (y == 231 or y == 232)
            or (mode == "title_static" and y >= 175 and y <= 214)
        if not skip_row then
            local row_off = 12 + y * 1024
            for x = 0, 255 do
                -- On title_boot, TitleWaveLoop (114 CPU cycles = 342 PPU dots/scanline)
                -- writes PPUScroll ($2005) mid-scanline around X=115..155 on scanlines 175..214
                -- after a 7-cycle $2002 poll loop, so the exact transition dot within X=110..160
                -- jitters with sub-scanline CPU phase.
                if not (mode == "title_wave" and y >= 175 and y <= 214 and x >= 110 and x <= 160) then
                    local i = row_off + x * 4
                    local r, g, b = s:byte(i + 1, i + 3)
                    local v = r * 65536 + g * 256 + b + 1
                    h1 = (h1 * 33 + v) % mod1
                    h2 = (h2 * 131 + v) % mod2
                end
            end
        end
    end
    return string.format("%08x%08x", h1, h2)
end

-- Writes the screenshot as a binary PPM (P6) image.
local function save_ppm(s, path)
    local f = io.open(path, "wb")
    if not f then
        log("WARN: cannot write " .. path)
        return
    end
    f:write("P6\n256 240\n255\n")
    for y = 0, 239 do
        local row = {}
        local row_off = 12 + y * 1024
        for x = 0, 255 do
            local i = row_off + x * 4
            row[x + 1] = s:sub(i + 1, i + 3)
        end
        f:write(table.concat(row))
    end
    f:close()
end

-- Hash of the writes to the APU's sound registers ($4000-$4013, $4015, $4017;
-- not $4014 sprite DMA or $4016 joypad strobe) since the previous checkpoint.
-- FCEUX runs with sound off, so this is what covers the music and sound
-- effect engine.
local apu_h1, apu_h2 = 5381, 0
memory.registerwrite(0x4000, 0x18, function(addr, size, value)
    if addr == 0x4014 or addr == 0x4016 then
        return
    end
    local v = (addr - 0x4000) * 256 + value + 1
    apu_h1 = (apu_h1 * 33 + v) % 4294967291
    apu_h2 = (apu_h2 * 131 + v) % 4294967279
end)

local checkpoints = {}
local function checkpoint(id)
    local gd = gui.gdscreenshot()
    local mode = nil
    if id == "title_boot" then
        mode = "title_wave"
    elseif id == "title_from_music" or id == "attract_demo_exit" then
        mode = "title_static"
    end
    local hash = hash_gd(gd, mode)
    table.insert(checkpoints, {id = id, hash = hash})
    table.insert(checkpoints, {id = id .. ".apu", hash = string.format("%08x%08x", apu_h1, apu_h2)})
    apu_h1, apu_h2 = 5381, 0
    note_progress(id)
    if SHOT_DIR then
        save_ppm(gd, SHOT_DIR .. "/" .. id .. ".ppm")
    end
end

-- In record mode, writes the checkpoint hashes to test/expected_hashes.txt.
-- Otherwise compares them with that file; a checkpoint listed there but never
-- taken is a failure too. Ends with one PASS:/FAIL: line, which run_test.sh
-- waits for. abort_msg is set when a state check stopped the run early.
report = function(abort_msg)
    if MODE == "record" then
        if abort_msg then
            log("FAIL: " .. abort_msg .. " (nothing recorded)")
            finish()
        end
        local ef = assert(io.open(EXPECTED_PATH, "w"))
        for _, cp in ipairs(checkpoints) do
            ef:write(string.format("%-24s %s\n", cp.id, cp.hash))
            log(string.format("RECORD %-24s %s", cp.id, cp.hash))
        end
        ef:close()
        log(string.format("PASS: recorded %d checkpoints to %s", #checkpoints, EXPECTED_PATH))
        finish()
    end

    local ef = io.open(EXPECTED_PATH, "r")
    if not ef then
        log("FAIL: missing " .. EXPECTED_PATH)
        finish()
    end
    local expected, expected_order = {}, {}
    for line in ef:lines() do
        local id, h = line:match("^(%S+)%s+(%S+)$")
        if id and h then
            expected[id] = h
            table.insert(expected_order, id)
        end
    end
    ef:close()

    local failures, total, taken = 0, 0, {}
    for _, cp in ipairs(checkpoints) do
        local exp = expected[cp.id]
        taken[cp.id] = true
        total = total + 1
        if exp == cp.hash then
            log(string.format("OK   %-24s %s", cp.id, cp.hash))
        else
            log(string.format("FAIL %-24s expected=%s actual=%s", cp.id, tostring(exp), cp.hash))
            failures = failures + 1
        end
    end
    if abort_msg then
        log(string.format("FAIL: %s (stopped after %d checkpoints, %d mismatched)",
                          abort_msg, #checkpoints, failures))
        finish()
    end
    for _, id in ipairs(expected_order) do
        if not taken[id] then
            log(string.format("FAIL %-24s expected=%s but never taken", id, expected[id]))
            failures = failures + 1
            total = total + 1
        end
    end
    if failures == 0 then
        log(string.format("PASS: all %d checkpoints matched", total))
    else
        log(string.format("FAIL: %d/%d checkpoints mismatched or missing", failures, total))
    end
    finish()
end

local function step(n, btns)
    for i = 1, n do
        if btns then
            joypad.set(1, btns)
        else
            joypad.set(1, {})
        end
        advance()
    end
end

local function tap(btn, hold, wait)
    step(hold or 2, {[btn] = true})
    step(wait or 10, nil)
end

local function byte_to_buttons(b)
    return {
        right  = (b % 2 >= 1),
        left   = (b % 4 >= 2),
        down   = (b % 8 >= 4),
        up     = (b % 16 >= 8),
        start  = (b % 32 >= 16),
        select = (b % 64 >= 32),
        B      = (b % 128 >= 64),
        A      = (b % 256 >= 128),
    }
end

local function replay_demo_file(path)
    local f = assert(io.open(path, "rb"))
    local data = f:read("*all")
    f:close()
    local total = 0
    local idx = 1
    while idx <= #data do
        local stat = data:byte(idx)
        if stat == 0xFF then break end
        local count = data:byte(idx + 1) or 0
        local btns = byte_to_buttons(stat)
        for i = 1, count do
            joypad.set(1, btns)
            advance()
            total = total + 1
            if total == 250 then
                checkpoint("demo_replay_f250")
            elseif total == 500 then
                checkpoint("demo_replay_f500")
            end
        end
        idx = idx + 2
    end
    checkpoint("demo_replay_end")
end

-- Helper to write a valid 64-byte save slot into battery-backed WRAM ($6000 + slot * 64)
local function write_wram_slot(slot, area, section, warp, weapon, opts)
    opts = opts or {}
    local exp = opts.exp or 0
    local base = 0x6000 + slot * 64
    for i = 0, 63 do
        memory.writebyte(base + i, 0)
    end
    local hdr = {
        opts.health or 24, -- Health
        32, -- HealthFrac
        opts.level or 0,  -- Level
        24, -- MaxHealth
        32, -- Defense
        exp % 256, math.floor(exp / 256), -- Experience
        32, -- ExpFrac
        0, 0, 0, 0, -- Hours, Minutes, Seconds, ClockTicks
        area,
        section,
        warp,
        0,  -- WarpType
        weapon or 0, -- ProjectileType
    }
    for i, v in ipairs(hdr) do
        memory.writebyte(base + i - 1, v)
    end
    if opts.flags then
        for idx, val in pairs(opts.flags) do
            memory.writebyte(base + 17 + idx, val)
        end
    end
    memory.writebyte(base + 49, 0x8A) -- 'A'
    local sum = 0
    for i = 0, 58 do
        sum = sum + memory.readbyte(base + i)
    end
    memory.writebyte(base + 60, sum % 256)
    memory.writebyte(base + 61, math.floor(sum / 256))
end

-- Returns true if WRAM save slot `slot` has a valid checksum (sum of bytes 0..58
-- stored as a little-endian word at offset 60, see CalcSaveGameCheckSum).
local function wram_slot_valid(slot)
    local base = 0x6000 + slot * 64
    local sum = 0
    for i = 0, 58 do
        sum = sum + memory.readbyte(base + i)
    end
    return memory.readbyte(base + 60) + memory.readbyte(base + 61) * 256 == sum
end

-- Returns true if bit `flag` of the StatusFlags saved in WRAM slot `slot` is set.
local function wram_slot_flag(slot, flag)
    local v = memory.readbyte(0x6000 + slot * 64 + 17 + math.floor(flag / 8))
    return math.floor(v / 2 ^ (flag % 8)) % 2 == 1
end

-- Locate MainRoutine's zero-page address from GoMainHandler in the fixed PRG
-- bank, so the test does not depend on the RAM layout. Both GoMainHandler and
-- GoIRQRoutine are "lda zp / jsr GoRoutine" followed by a jump table of
-- (addr-1) words, high byte first (TC_SLOT); GoMainHandler is the one whose
-- table has an entry for every mr* routine.
local MR_COUNT = 28 -- mrTitleInit .. mrMusicPlayerMain
local function find_main_routine_zp()
    local function is_go_routine(a)
        return a >= 0xC000
           and memory.readbyte(a) == 0x0A      -- asl
           and memory.readbyte(a + 1) == 0xA8  -- tay
           and memory.readbyte(a + 2) == 0xC8  -- iny
           and memory.readbyte(a + 3) == 0x68  -- pla
    end
    local found = {}
    for addr = 0xC000, 0xFFF0 do
        if memory.readbyte(addr) == 0xA5 and memory.readbyte(addr + 2) == 0x20
           and is_go_routine(memory.readbyte(addr + 3) + memory.readbyte(addr + 4) * 256) then
            local entries = 0
            local p = addr + 5
            -- a routine at $8000..$FFFF is stored as $7FFF..$FFFE
            while p < 0xFFFA and memory.readbyte(p) >= 0x7F do
                entries = entries + 1
                p = p + 2
            end
            if entries >= MR_COUNT then
                table.insert(found, memory.readbyte(addr + 1))
            end
        end
    end
    check_state(#found == 1, "expected exactly one GoMainHandler, found " .. #found)
    return found[1]
end
local main_routine_zp = find_main_routine_zp()

-- ============================================================================
-- Scenario 1: Boot, Title Screen & Music Player
-- ============================================================================
step(90)
checkpoint("title_boot")

tap("select", 2, 70)
checkpoint("music_player_open")
tap("right", 2, 30)
checkpoint("music_player_next")
tap("B", 2, 70)
checkpoint("title_from_music")

-- ============================================================================
-- Scenario 2: New Game, Name Entry, Intro Cutscene, Building, Status & NPC
-- ============================================================================
tap("start", 2, 120)
checkpoint("select_game_empty")

tap("start", 2, 70)
checkpoint("enter_name_open")

tap("A", 2, 15)
tap("start", 2, 15)
checkpoint("enter_name_typed")

tap("start", 2, 60)
checkpoint("intro_script_start")

for i = 1, 90 do
    tap("A", 2, 8)
end
step(80)
checkpoint("building_spawn")

-- Pause to Status Screen and return
tap("start", 2, 80)
checkpoint("status_screen_open")
tap("start", 2, 80)
checkpoint("status_screen_exit")

-- Walk left to Dr. Norton (NPC 6) and talk
step(16, {left = true})
step(10)
tap("up", 4, 60)
checkpoint("npc6_dialog_open")
for i = 1, 35 do
    tap("A", 2, 8)
end
step(80)
checkpoint("npc6_dialog_done")

-- ============================================================================
-- Scenario 3: Power Cycle, Reload Slot 0 & Play Base Area
-- ============================================================================
emu.poweron()
step(90)
write_wram_slot(1, 0, 0, 0, 0)
write_wram_slot(2, 4, 0, 0, 0)

tap("start", 2, 120)
checkpoint("select_game_slot0")
tap("start", 2, 30)
checkpoint("game_menu_slot0")
tap("start", 2, 120)
checkpoint("base_sect0_spawn")

-- Walk left into InstantWarp -> Base sect 1
step(20, {left = true})
step(100)
checkpoint("base_sect1_warp")

-- Fight enemies going left in Base sect 1
step(40, {left = true})
tap("B", 2, 20)
step(50, {left = true})
tap("B", 2, 20)
step(50, {left = true, A = true})
checkpoint("base_sect1_action")

-- ============================================================================
-- Scenario 4: Load Slot 1 -> City Ruins & Replay 827-Frame Demo Input Stream
-- ============================================================================
emu.poweron()
step(90)
write_wram_slot(1, 0, 0, 0, 0)
write_wram_slot(2, 4, 0, 0, 0)

tap("start", 2, 120)
tap("down", 2, 20)
checkpoint("select_game_slot1")
tap("start", 2, 30)
tap("start", 2, 120)
checkpoint("ruins_spawn")

replay_demo_file(DEMO_PATH)

-- ============================================================================
-- Scenario 5: Load Slot 2 -> Boss 0 (Area 4, Section 0)
-- ============================================================================
emu.poweron()
step(90)
write_wram_slot(1, 0, 0, 0, 0)
write_wram_slot(2, 4, 0, 0, 0)

tap("start", 2, 120)
tap("down", 2, 20)
tap("down", 2, 20)
checkpoint("select_game_slot2")
tap("start", 2, 30)
tap("start", 2, 120)
checkpoint("boss0_spawn")

-- Fight Boss 0
step(30, {right = true})
tap("B", 2, 20)
step(35, {right = true, A = true})
tap("B", 2, 20)
step(40)
checkpoint("boss0_action")

-- ============================================================================
-- Scenario 6: Title Screen Attract-Mode Demo (PlayDemo & Second Loop)
-- ============================================================================
emu.poweron()
-- TitleInit sets Timer = $40 (64 ticks * 12 frames = 768 frames);
-- idle until PlayDemo starts and runs in City Ruins
step(1150)
checkpoint("attract_demo_mid")
step(250)
checkpoint("attract_demo_late")
-- Let the first attract demo finish naturally, return to Title Screen,
-- and idle into the second attract loop at the exact same offset as attract_demo_late
step(1711)
checkpoint("attract_demo_loop2")
-- Press Start to interrupt PlayDemo (StopDemo -> TitleInit)
tap("start", 2, 90)
checkpoint("attract_demo_exit")

-- ============================================================================
-- Scenario 7: Power Plant (Area 1, Section 0 & Section 14)
-- ============================================================================
emu.poweron()
step(90)
write_wram_slot(0, 1, 0, 0, 0)

tap("start", 2, 120)
tap("start", 2, 30)
tap("start", 2, 120)
checkpoint("plant_sect0_spawn")

-- Move right and jump in Power Plant section 0
step(35, {right = true})
step(25, {right = true, A = true})
tap("B", 2, 20)
checkpoint("plant_sect0_action")

-- Walk back left into InstantWarp ($A0) -> Power Plant section 14
step(80, {left = true})
step(100)
checkpoint("plant_sect14_warp")

-- ============================================================================
-- Scenario 8: Boss 1 Area (Area 5, Section 1 -> Section 0)
-- ============================================================================
-- The Boss 1 and Boss 2 areas are unfinished: no OT_BOSS1/OT_POWERCORE/
-- OT_WALLEYE object is placed in either Boss 1 section, and neither Boss 2
-- section has any warp, so there is no defined place to spawn in Boss 2.
-- This scenario covers loading and scrolling the Boss 1 area only.
emu.poweron()
step(90)
write_wram_slot(1, 5, 1, 1, 0)

-- Load Slot 1 -> Boss 1 corridor (Area 5, Section 1, Warp 1)
tap("start", 2, 120)
tap("down", 2, 20)
tap("start", 2, 30)
tap("start", 2, 120)
checkpoint("boss1_sect1_spawn")

-- Walk left across corridor into InstantWarp ($80) -> Section 0, room 3
step(140, {left = true})
step(100)
checkpoint("boss1_sect0_warp")

-- Walk left into room 2 (a flip-screen transition), wait for it to finish,
-- and fire
step(90, {left = true})
step(40)
tap("B", 2, 25)
checkpoint("boss1_sect0_room2")

-- ============================================================================
-- Scenario 9: Level-Up Screen (Kill enemy at 100 XP -> AdvanceLevel)
-- ============================================================================
emu.poweron()
step(90)
-- Area 0 (Ruins), Section 0, Warp 18 (room 47, pos $8B; AcidZombie is in the same room at $80).
-- Set weapon = 0 (straight energy bullet, 1 damage/shot), exp = 100, and flag 1 set ($02) so ZombieScript is skipped.
write_wram_slot(0, 0, 0, 18, 0, {exp = 100, flags = {[0] = 0x02}})

tap("start", 2, 120)
tap("start", 2, 30)
tap("start", 2, 120)

-- Turn left towards room 47's AcidZombie ($80) and fire three shots to kill it (3 HP)
step(20, {left = true})
tap("B", 2, 15)
tap("B", 2, 15)
tap("B", 2, 35)
check_state(memory.readbyte(main_routine_zp) == 8, "Expected mrLevelUpMain (8), got " .. memory.readbyte(main_routine_zp))
checkpoint("levelup_screen")

-- Wait for LevelUpMain fanfare timer (13 * 12 = 156 frames) to return to Area2DMain
step(170)
check_state(memory.readbyte(main_routine_zp) == 4, "Expected mrArea2DMain (4), got " .. memory.readbyte(main_routine_zp))
checkpoint("levelup_done")

-- The level-up screen itself shows no numbers; the status screen shows the
-- new Level, Defense and Exp/Next values set by AdvanceLevel
tap("start", 2, 80)
checkpoint("levelup_status")
tap("start", 2, 80)

-- ============================================================================
-- Scenario 10: Game Over & Continue (Die at 1 HP -> GameOver -> Continue)
-- ============================================================================
emu.poweron()
step(90)
write_wram_slot(0, 0, 0, 18, 0, {health = 1, flags = {[0] = 0x02}})

tap("start", 2, 120)
tap("start", 2, 30)
tap("start", 2, 120)

-- Walk left into room 47's AcidZombie at 1 HP to trigger PlayerDead -> GameOverInit
step(95, {left = true})
step(240)
check_state(memory.readbyte(main_routine_zp) == 10, "Expected mrGameOverMain (10), got " .. memory.readbyte(main_routine_zp))
checkpoint("gameover_screen")

-- Toggle cursor to End and back to Continue, then press Start to respawn
tap("down", 2, 20)
checkpoint("gameover_cursor")
tap("up", 2, 20)
tap("start", 2, 120)
check_state(memory.readbyte(main_routine_zp) == 4, "Expected mrArea2DMain (4), got " .. memory.readbyte(main_routine_zp))
checkpoint("gameover_continue")

-- ============================================================================
-- Scenario 11: Saving at a Save Point (building_save0 -> SaveScript -> Reload)
-- ============================================================================
emu.poweron()
step(90)
-- Area 3 (Building), Section 23 ($17 = building_save0), Warp 0 ($A5)
write_wram_slot(0, 3, 23, 0, 0)

tap("start", 2, 120)
tap("start", 2, 30)
tap("start", 2, 120)
checkpoint("save_point_spawn")

-- Switch weapon to ProjectileType 1, then walk right into save terminal ($AA)
tap("select", 2, 10)
step(50, {right = true})
step(80)
-- SaveScript: the first A finishes printing String 3 ("Interfacing with
-- NTX2NES adapter... OK."), the second starts the MultChoice prompt and the
-- third finishes printing it
for i = 1, 3 do
    tap("A", 2, 8)
end
checkpoint("save_point_prompt")

-- Choose "Yes, please" (choice 0) -> SO_SAVE. Flag 7 is not yet set, so the
-- script then sets it, saves again and prints String 10 (the transmission).
tap("A", 2, 8)
check_state(wram_slot_valid(0), "Slot 0 checksum invalid after SaveScript")
check_state(wram_slot_flag(0, 7), "SaveScript did not save StatusFlags flag 7 to slot 0")
tap("A", 2, 8)
checkpoint("save_point_transmission")

-- Page through the rest of String 10 (9 more pages) and return to the area
for i = 1, 19 do
    tap("A", 2, 8)
end
step(80)
checkpoint("save_point_done")

-- Power-cycle and reload Slot 0. The status screen shows the play time and
-- stats that were read back from the save (the slot written above had 00:00:00).
emu.poweron()
step(90)
tap("start", 2, 120)
tap("start", 2, 30)
tap("start", 2, 120)
checkpoint("save_point_reload")
tap("start", 2, 80)
checkpoint("save_point_reload_status")
tap("start", 2, 80)

-- ============================================================================
-- Scenario 12: End Credits Scroller (mrCreditsInit / mrCreditsMain)
-- ============================================================================
-- Nothing in the game sets mrCreditsInit, so the credits are unreachable in
-- normal play; the test enters them by writing MainRoutine directly.
-- Enter Select Game first so Bank 0 (containing CreditsInit/CreditsMain) is mapped
-- at $8000-$BFFF and IRQCount is 0.
emu.poweron()
step(90)
tap("start", 2, 120)
memory.writebyte(main_routine_zp, 18) -- mrCreditsInit
step(200)
check_state(memory.readbyte(main_routine_zp) == 19, "Expected mrCreditsMain (19), got " .. memory.readbyte(main_routine_zp))
checkpoint("credits_scroll_1")
step(400)
check_state(memory.readbyte(main_routine_zp) == 19, "Expected mrCreditsMain (19), got " .. memory.readbyte(main_routine_zp))
checkpoint("credits_scroll_2")

-- ============================================================================
-- Record or Verify Checkpoints
-- ============================================================================
report(nil)
