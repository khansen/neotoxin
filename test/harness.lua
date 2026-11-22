-- Behaviour test harness for NeoToxin (runs inside FCEUX via --loadlua).
-- Replays deterministic input sessions across Title, Music Player, Select Game,
-- Enter Name, Intro Cutscene, Building, Status Screen, NPC Dialog, Save/Reload,
-- Base, City Ruins (including the 827-frame recorded demo input stream from
-- data/demo.dat), Boss 0, Title Attract-Mode Demo (two loops), Power Plant,
-- Boss 1, Boss 2, Level-Up Screen, Game Over & Continue, Save Point Terminal,
-- and the End Credits Scroller, verifying 256x240 screen hashes at 50 checkpoints.

emu.speedmode("turbo")

local script_path = debug.getinfo(1, "S").source:sub(2)
local test_dir = script_path:match("^(.*)/[^/]+$") or "."
local root_dir = test_dir:match("^(.*)/[^/]+$") or "."

local LOG_PATH = os.getenv("NEOTOXIN_TEST_LOG") or "/tmp/neotoxin_test.log"
local MODE = os.getenv("NEOTOXIN_TEST_MODE") or "verify" -- "verify" or "record"
local EXPECTED_PATH = test_dir .. "/expected_hashes.txt"
local DEMO_PATH = root_dir .. "/data/demo.dat"

local out = io.open(LOG_PATH, "w")
local function log(s)
    if out then
        out:write(s .. "\n")
        out:flush()
    end
end

local function finish()
    if out then
        out:flush()
        out:close()
        out = nil
    end
    -- Wait for the test runner supervisor to terminate FCEUX after observing
    -- the final PASS/FAIL line (avoiding FCEUX's cross-thread os.exit race).
    while true do
        emu.frameadvance()
    end
end

local function check_state(cond, msg)
    if not cond then
        log("FAIL: " .. tostring(msg))
        finish()
    end
end

local function hash_gd(s, mode)
    if not s then return "nil" end
    local h1 = 5381
    local h2 = 0
    local mod1 = 4294967291
    local mod2 = 4294967279
    for y = 0, 239 do
        if not (mode == "title_static" and y >= 175 and y <= 214) then
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
end

local function step(n, btns)
    for i = 1, n do
        if btns then
            joypad.set(1, btns)
        else
            joypad.set(1, {})
        end
        emu.frameadvance()
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
            emu.frameadvance()
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

-- Locate MainRoutine's zero-page address dynamically from GoMainHandler in PRG-ROM
-- (lda MainRoutine / jsr GoRoutine), so the test remains independent of ZP layout.
local function find_main_routine_zp()
    local matches = {}
    for addr = 0xC000, 0xFFF0 do
        if memory.readbyte(addr) == 0xA5 and memory.readbyte(addr + 2) == 0x20 then
            local target = memory.readbyte(addr + 3) + memory.readbyte(addr + 4) * 256
            if target >= 0xC000 and addr > target
               and memory.readbyte(target) == 0x0A
               and memory.readbyte(target + 1) == 0xA8
               and memory.readbyte(target + 2) == 0xC8
               and memory.readbyte(target + 3) == 0x68 then
                table.insert(matches, memory.readbyte(addr + 1))
            end
        end
    end
    -- GoIRQRoutine is the first match; GoMainHandler is the second match.
    return assert(matches[2], "Failed to locate MainRoutine in GoMainHandler")
end

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
-- Scenario 3: Soft Reset, Reload Slot 0 & Play Base Area
-- ============================================================================
emu.softreset()
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
emu.softreset()
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
emu.softreset()
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
emu.softreset()
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
emu.softreset()
step(90)
write_wram_slot(0, 1, 0, 0, 0)
write_wram_slot(1, 5, 1, 1, 0)
write_wram_slot(2, 6, 0, 19, 0)

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
-- Scenario 8: Boss 1 (Area 5, Section 1 -> 0) & Boss 2 (Area 6, Section 0)
-- ============================================================================
emu.softreset()
step(90)
write_wram_slot(0, 1, 0, 0, 0)
write_wram_slot(1, 5, 1, 1, 0)
write_wram_slot(2, 6, 0, 19, 0)

-- Load Slot 1 -> Boss 1 corridor (Area 5, Section 1, Warp 1)
tap("start", 2, 120)
tap("down", 2, 20)
tap("start", 2, 30)
tap("start", 2, 120)
checkpoint("boss1_sect1_spawn")

-- Walk left across corridor into InstantWarp ($80) -> Boss 1 chamber (Section 0)
step(140, {left = true})
step(100)
checkpoint("boss1_sect0_warp")

-- Walk left to reveal the Boss 1 eye chamber and fire weapon
step(90, {left = true})
tap("B", 2, 25)
checkpoint("boss1_action")

-- Soft reset and load Slot 2 -> Boss 2 chamber (Area 6, Section 0, Warp 19)
emu.softreset()
step(90)
write_wram_slot(2, 6, 0, 19, 0)
tap("start", 2, 120)
tap("down", 2, 20)
tap("down", 2, 20)
tap("start", 2, 30)
tap("start", 2, 120)
checkpoint("boss2_spawn")

step(45, {right = true, A = true})
tap("B", 2, 25)
checkpoint("boss2_action")

-- ============================================================================
-- Scenario 9: Level-Up Screen (Kill enemy at 100 XP -> AdvanceLevel)
-- ============================================================================
emu.softreset()
step(90)
-- Area 0 (Ruins), Section 0, Warp 18 (room 47, pos $8B; AcidZombie is in the same room at $80).
-- Set weapon = 0 (straight energy bullet, 1 damage/shot), exp = 100, and flag 1 set ($02) so ZombieScript is skipped.
write_wram_slot(0, 0, 0, 18, 0, {exp = 100, flags = {[0] = 0x02}})

tap("start", 2, 120)
tap("start", 2, 30)
tap("start", 2, 120)

-- Turn left towards room 47's AcidZombie ($80) and fire three shots to kill it (3 HP)
local main_routine_zp = find_main_routine_zp()
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

-- ============================================================================
-- Scenario 10: Game Over & Continue (Die at 1 HP -> GameOver -> Continue)
-- ============================================================================
emu.softreset()
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

-- Toggle cursor to QUIT and back to CONTINUE, then press Start to respawn
tap("down", 2, 20)
checkpoint("gameover_cursor")
tap("up", 2, 20)
tap("start", 2, 120)
check_state(memory.readbyte(main_routine_zp) == 4, "Expected mrArea2DMain (4), got " .. memory.readbyte(main_routine_zp))
checkpoint("gameover_continue")

-- ============================================================================
-- Scenario 11: Saving at a Save Point (building_save0 -> SaveScript -> Reload)
-- ============================================================================
emu.softreset()
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
-- Advance past String 3 ("Interfacing with NTX2NES adapter...") to MultChoice ("Save your data?")
for i = 1, 10 do
    tap("A", 2, 8)
end
step(30)
checkpoint("save_point_prompt")

-- Choose "Yes, please" (choice 0) -> WriteSaveGame + String 10
tap("A", 2, 40)
checkpoint("save_point_saved")
for i = 1, 25 do
    tap("A", 2, 8)
end
step(80)
checkpoint("save_point_done")

-- Soft-reset and reload Slot 0 to verify the saved game loads cleanly
emu.softreset()
step(90)
tap("start", 2, 120)
tap("start", 2, 30)
tap("start", 2, 120)
checkpoint("save_point_reload")

-- ============================================================================
-- Scenario 12: End Credits Scroller (mrCreditsInit / mrCreditsMain)
-- ============================================================================
-- Enter Select Game first so Bank 0 (containing CreditsInit/CreditsMain) is mapped
-- at $8000-$BFFF and IRQCount is 0.
emu.softreset()
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
if MODE == "record" then
    local ef = assert(io.open(EXPECTED_PATH, "w"))
    for _, cp in ipairs(checkpoints) do
        ef:write(string.format("%-24s %s\n", cp.id, cp.hash))
        log(string.format("RECORD %-24s %s", cp.id, cp.hash))
    end
    ef:close()
    log(string.format("PASS: recorded %d checkpoints to %s", #checkpoints, EXPECTED_PATH))
    finish()
else
    local expected = {}
    local ef = io.open(EXPECTED_PATH, "r")
    if not ef then
        log("FAIL: missing " .. EXPECTED_PATH)
        finish()
    end
    for line in ef:lines() do
        local id, h = line:match("^(%S+)%s+(%S+)$")
        if id and h then
            expected[id] = h
        end
    end
    ef:close()

    local failures = 0
    for _, cp in ipairs(checkpoints) do
        local exp = expected[cp.id]
        if exp == cp.hash then
            log(string.format("OK   %-24s %s", cp.id, cp.hash))
        else
            log(string.format("FAIL %-24s expected=%s actual=%s", cp.id, tostring(exp), cp.hash))
            failures = failures + 1
        end
    end
    if failures == 0 then
        log(string.format("PASS: all %d checkpoints matched", #checkpoints))
        finish()
    else
        log(string.format("FAIL: %d/%d checkpoints mismatched", failures, #checkpoints))
        finish()
    end
end
