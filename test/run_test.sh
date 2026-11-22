#!/bin/sh
set -u

ROM="${1:-neotoxin.nes}"
CFG_DIR="/tmp/fceux_neotoxin_test"
LOG_FILE="$CFG_DIR/test.log"

NESREV_FCEUX="${XDG_DATA_HOME:-$HOME/.local/share}/nesrev/fceux/current/bin/fceux"
if [ -n "${FCEUX_BIN:-}" ]; then
    FCEUX="$FCEUX_BIN"
elif [ -x "$NESREV_FCEUX" ]; then
    FCEUX="$NESREV_FCEUX"
else
    FCEUX="fceux"
fi

rm -rf "$CFG_DIR"
mkdir -p "$CFG_DIR/.fceux"
printf "SDL.VideoDriver = 2\nSDL.OpenGL = 0\n" > "$CFG_DIR/fceux.cfg"
cp "$CFG_DIR/fceux.cfg" "$CFG_DIR/.fceux/fceux.cfg"

python3 - "$FCEUX" "$CFG_DIR" "$LOG_FILE" "$ROM" <<'PY'
import os, signal, subprocess, sys, time

fceux, cfg_dir, log_file, rom = sys.argv[1:5]
env = dict(
    os.environ,
    HOME=cfg_dir,
    FCEUX_CONFIG_DIR=cfg_dir,
    QT_QPA_PLATFORM="offscreen",
    NEOTOXIN_TEST_LOG=log_file,
)
cmd = [
    fceux,
    "--no-config", "1",
    "--gamegenie", "0",
    "--sound", "0",
    "--loadlua", "test/harness.lua",
    rom,
]

proc = subprocess.Popen(
    cmd,
    stdin=subprocess.DEVNULL,
    stdout=subprocess.DEVNULL,
    stderr=subprocess.DEVNULL,
    env=env,
    start_new_session=True,
)

def done_written():
    if not os.path.isfile(log_file):
        return False
    with open(log_file, "rb") as f:
        data = f.read()
    for line in data.splitlines():
        if line.startswith(b"PASS:") or line.startswith(b"FAIL:"):
            return True
    return False

def stop_group():
    for sig in (signal.SIGTERM, signal.SIGKILL):
        try:
            os.killpg(proc.pid, sig)
        except ProcessLookupError:
            break
        deadline = time.monotonic() + 0.5
        while time.monotonic() < deadline:
            if proc.poll() is not None:
                return
            time.sleep(0.05)

deadline = time.monotonic() + 30.0
while proc.poll() is None:
    if done_written():
        stop_group()
        break
    if time.monotonic() >= deadline:
        stop_group()
        print("FAIL: test harness timed out after 30s")
        sys.exit(1)
    time.sleep(0.05)

stop_group()
PY

if [ ! -f "$LOG_FILE" ]; then
    echo "FAIL: test harness produced no log output"
    exit 1
fi

cat "$LOG_FILE"
grep -q "^PASS:" "$LOG_FILE"
