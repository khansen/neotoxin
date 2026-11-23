#!/bin/sh
# Runs test/harness.lua in a headless FCEUX and prints the checkpoint results.
# Exits 0 if every checkpoint matched test/expected_hashes.txt.
#
# Usage: test/run_test.sh [ROM]
#
# Environment:
#   FCEUX_BIN              FCEUX executable (default: fceux on PATH). Works
#                          with FCEUX 2.8.0 (Homebrew) and 2.7.0 Qt builds.
#   NEOTOXIN_TEST_MODE     "verify" (default), or "record" to rewrite
#                          test/expected_hashes.txt from this ROM.
#   NEOTOXIN_TEST_TIMEOUT  Seconds before giving up (default 60).
#   NEOTOXIN_SHOT_DIR      If set, save every checkpoint's screen there as
#                          <checkpoint>.ppm (to see what a failing hash shows).
#
# FCEUX gets a throwaway home/config directory per run, which is kept (and its
# path printed) when the run fails. The harness never quits
# FCEUX itself; it writes a final PASS:/FAIL: line and idles, and this script
# then kills FCEUX with SIGKILL. FCEUX traps SIGTERM and segfaults on its
# emulator thread while shutting down, which leaves a macOS crash report each
# time, so SIGTERM is not used.
set -u

ROM="${1:-neotoxin.nes}"
case "$ROM" in
    /*) ;;
    *) ROM="$(pwd)/$ROM" ;;
esac
if [ ! -f "$ROM" ]; then
    echo "FAIL: ROM not found: $ROM"
    exit 1
fi
if [ -n "${NEOTOXIN_SHOT_DIR:-}" ]; then
    case "$NEOTOXIN_SHOT_DIR" in
        /*) ;;
        *) NEOTOXIN_SHOT_DIR="$(pwd)/$NEOTOXIN_SHOT_DIR" ;;
    esac
    mkdir -p "$NEOTOXIN_SHOT_DIR" || exit 1
    export NEOTOXIN_SHOT_DIR
fi
cd "$(dirname "$0")/.." || exit 1

FCEUX="${FCEUX_BIN:-fceux}"
TIMEOUT="${NEOTOXIN_TEST_TIMEOUT:-60}"

# Removed after a passing run; kept after a failure (with FCEUX's own output
# in fceux.out) so the failure can be investigated.
CFG_DIR=$(mktemp -d "${TMPDIR:-/tmp}/neotoxin_test.XXXXXX") || exit 1
trap 'rm -rf "$CFG_DIR"; exit 1' INT TERM HUP
LOG_FILE="$CFG_DIR/test.log"

# Software rendering; the OpenGL view cannot start under the offscreen platform.
mkdir -p "$CFG_DIR/.fceux"
printf "SDL.VideoDriver = 2\nSDL.OpenGL = 0\n" > "$CFG_DIR/fceux.cfg"
cp "$CFG_DIR/fceux.cfg" "$CFG_DIR/.fceux/fceux.cfg"

python3 - "$FCEUX" "$CFG_DIR" "$LOG_FILE" "$ROM" "$TIMEOUT" <<'PY'
import os, signal, subprocess, sys, time

fceux, cfg_dir, log_file, rom, timeout = sys.argv[1:6]
fceux_out = open(os.path.join(cfg_dir, "fceux.out"), "wb")
env = dict(
    os.environ,
    HOME=cfg_dir,
    # FCEUX 2.8 asks for a storage location on first run unless one is given.
    FCEUX_HOME=cfg_dir,
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

# FCEUX occasionally loads the script and then never emulates a frame
# (seen on the first run after FCEUX has been idle for a few minutes). The
# first checkpoint normally comes within a second, so a run that has logged
# none after STARTUP_TIMEOUT seconds is restarted, once.
STARTUP_TIMEOUT = 15
ATTEMPTS = 2

def read_lines(path):
    try:
        with open(path, "rb") as f:
            return f.read().splitlines()
    except FileNotFoundError:
        return []

def finished():
    return any(l.startswith((b"PASS:", b"FAIL:")) for l in read_lines(log_file))

def emulating():
    return any(not l.startswith(b"start ") for l in read_lines(log_file + ".progress"))

def run_once(attempt):
    """Returns True to retry (FCEUX never started emulating)."""
    try:
        proc = subprocess.Popen(
            cmd,
            stdin=subprocess.DEVNULL,
            stdout=fceux_out,
            stderr=subprocess.STDOUT,
            env=env,
            start_new_session=True,
        )
    except OSError as e:
        print("FAIL: cannot run %s: %s" % (fceux, e))
        sys.exit(1)
    started = time.monotonic()
    deadline = started + float(timeout)
    try:
        while not finished():
            if proc.poll() is not None:
                print("FAIL: FCEUX exited before the harness finished (status %d)" % proc.returncode)
                return False
            now = time.monotonic()
            if attempt + 1 < ATTEMPTS and now - started >= STARTUP_TIMEOUT and not emulating():
                print("NOTE: FCEUX emulated no frames in %ds; restarting it" % STARTUP_TIMEOUT)
                return True
            if now >= deadline:
                print("FAIL: test harness timed out after %ss" % timeout)
                return False
            time.sleep(0.05)
        return False
    finally:
        try:
            os.killpg(proc.pid, signal.SIGKILL)
        except ProcessLookupError:
            pass
        proc.wait()

for attempt in range(ATTEMPTS):
    if not run_once(attempt):
        break
PY

if [ -f "$LOG_FILE" ]; then
    cat "$LOG_FILE"
else
    echo "FAIL: test harness produced no log output"
fi
if grep -q "^PASS:" "$LOG_FILE" 2>/dev/null; then
    rm -rf "$CFG_DIR"
    exit 0
fi
if [ -s "$LOG_FILE.progress" ]; then
    echo "Last progress: $(tail -1 "$LOG_FILE.progress")"
fi
echo "Harness log and FCEUX output kept in $CFG_DIR"
exit 1
