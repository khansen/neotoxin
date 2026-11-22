#!/bin/sh
set -u

ROM="${1:-neotoxin.nes}"
CFG_DIR="/tmp/fceux_neotoxin_test"
LOG_FILE="$CFG_DIR/test.log"

mkdir -p "$CFG_DIR"
rm -f "$LOG_FILE"

HOME="$CFG_DIR" \
QT_QPA_PLATFORM=offscreen \
NEOTOXIN_TEST_LOG="$LOG_FILE" \
fceux --no-config 1 --sound 0 --config-dir "$CFG_DIR" --loadlua test/harness.lua "$ROM" >/dev/null 2>&1 || true

if [ ! -f "$LOG_FILE" ]; then
    echo "FAIL: test harness produced no log output"
    exit 1
fi

cat "$LOG_FILE"
grep -q "^PASS:" "$LOG_FILE"
