#!/usr/bin/env python3
"""Generate sound/samples/hurt.dmc, the player-hurt sound. It is an
original sound that replaces a sample taken from another game.

The game plays it with DMC rate 15 (33144 Hz) and length register $0C, i.e.
193 bytes = 1544 one-bit deltas, about 47 ms. The sound is a pulse wave whose
pitch falls from about 330 Hz to 130 Hz under a fast-decaying envelope, with
a short burst of noise for the impact. The output is deterministic.

Usage: hurtsfx.py OUT.dmc [PREVIEW.wav]
"""
import math
import struct
import sys

RATE = 33144
LENGTH = 193                     # bytes; $4013 = $0C -> 12 * 16 + 1
SAMPLES = LENGTH * 8


def target(i):
    t = i / RATE
    dur = SAMPLES / RATE
    # pitch glide 330 Hz -> 130 Hz, exponential
    f0, f1 = 330.0, 130.0
    k = math.log(f1 / f0) / dur
    phase = f0 * (math.exp(k * t) - 1) / k          # integral of f(t)
    pulse = 1.0 if (phase % 1.0) < 0.35 else -1.0   # 35% duty
    # envelope: 2 ms attack, then exponential decay, fading to 0 at the end
    att = min(1.0, t / 0.002)
    env = att * math.exp(-t / 0.030) * (1.0 - (t / dur) ** 4)
    # impact noise for the first 6 ms (fixed LFSR, so the output is stable)
    noise = 0.0
    if t < 0.006:
        global lfsr
        lfsr = ((lfsr >> 1) | (((lfsr ^ (lfsr >> 1)) & 1) << 14)) & 0x7FFF
        noise = (1.0 if lfsr & 1 else -1.0) * (1.0 - t / 0.006)
    return 64 + 46 * env * (0.8 * pulse + 0.6 * noise)


lfsr = 1


def encode():
    level = 64
    bits = []
    levels = []
    for i in range(SAMPLES):
        if target(i) > level:
            bits.append(1)
            level = min(level + 2, 126)
        else:
            bits.append(0)
            level = max(level - 2, 0)
        levels.append(level)
    data = bytearray()
    for b in range(LENGTH):
        byte = 0
        for k in range(8):                       # the DMC plays bit 0 first
            byte |= bits[b * 8 + k] << k
        data.append(byte)
    return bytes(data)


def decode(data, start=64):
    level = start
    out = []
    for byte in data:
        for k in range(8):
            if (byte >> k) & 1:
                level = min(level + 2, 126)
            else:
                level = max(level - 2, 0)
            out.append(level)
    return out


def write_wav(path, levels, pad_ms=150):
    pad = [levels[-1]] * int(RATE * pad_ms / 1000)
    pcm = b"".join(struct.pack("<h", int((v - 64) * 400)) for v in pad + levels + pad)
    with open(path, "wb") as f:
        f.write(b"RIFF" + struct.pack("<I", 36 + len(pcm)) + b"WAVE")
        f.write(b"fmt " + struct.pack("<IHHIIHH", 16, 1, 1, RATE, RATE * 2, 2, 16))
        f.write(b"data" + struct.pack("<I", len(pcm)) + pcm)


if __name__ == "__main__":
    data = encode()
    assert len(data) == LENGTH
    with open(sys.argv[1], "wb") as f:
        f.write(data)
    if len(sys.argv) > 2:
        write_wav(sys.argv[2], decode(data))
