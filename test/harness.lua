-- Behaviour test harness for NeoToxin (runs inside FCEUX via --loadlua).
-- Replays deterministic input sessions across Title, Music Player, Select Game,
-- Enter Name, Intro Cutscene, Building, Status Screen, NPC Dialog, Save/Reload,
-- Base, City Ruins (including the 827-frame recorded demo input stream from
-- data/demo.dat), and Boss 0, verifying 256x240 screen hashes at 27 checkpoints.

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
local function write_wram_slot(slot, area, section, warp, weapon)
    local base = 0x6000 + slot * 64
    for i = 0, 63 do
        memory.writebyte(base + i, 0)
    end
    local hdr = {
        24, -- Health
        32, -- HealthFrac
        0,  -- Level
        24, -- MaxHealth
        32, -- Defense
        0, 0, -- Experience
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
    memory.writebyte(base + 49, 0x8A) -- 'A'
    local sum = 0
    for i = 0, 58 do
        sum = sum + memory.readbyte(base + i)
    end
    memory.writebyte(base + 60, sum % 256)
    memory.writebyte(base + 61, math.floor(sum / 256))
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
    if out then out:close() end
    os.exit(0)
else
    local expected = {}
    local ef = io.open(EXPECTED_PATH, "r")
    if not ef then
        log("FAIL: missing " .. EXPECTED_PATH)
        if out then out:close() end
        os.exit(1)
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
        if out then out:close() end
        os.exit(0)
    else
        log(string.format("FAIL: %d/%d checkpoints mismatched", failures, #checkpoints))
        if out then out:close() end
        os.exit(1)
    end
end
