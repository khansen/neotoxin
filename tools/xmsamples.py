#!/usr/bin/env python3
"""Synthesizes the instrument samples of the songs in music/*.xm, so that a
tracker plays each instrument roughly the way the NES does. They replace the
recorded samples the songs were written with.

Usage: python3 tools/xmsamples.py sound/samples IN.xm OUT.xm [WAVDIR]

The first argument is the directory with the game's DMC data: bassdrum.bin,
snare.bin and hurt.dmc, which the ROM holds in that order from $FC00 (each
sample plays one byte of the next). Everything in the song except the sample
data and the sample names is copied unchanged: the patterns, the instruments,
and each sample's tuning, volume and peak level. One-shot samples may change
length. IN and OUT may be the same file, and running the script again gives
the same file. If WAVDIR is given, each sample is also written there as a WAV
file.

The songs all use the same instrument set, by number:
   1-15  pulse channels: one looped cycle of a pulse wave, at the duty in the
         sample name (pulse 12.5%, 25% or 50%)
  33-39  triangle channel: one looped cycle of the NES's 32-step triangle
  49-51  noise channel: closed hihat, open hihat, "snare", rendered from the
         noise period and volume envelope the game uses (sound/rnmedata.asm)
  57-58  DMC channel: the game's bass drum and bass drum+snare samples
     59  "bass", which no song uses: a looped sawtooth
The one-shots are rendered for the note the songs play them at, and the
noise and DMC drums go through the NES's output filters.
"""

import math
import os
import struct
import sys
import wave

CPU_HZ = 1789773.0
FRAME_CYCLES = 29780.5           # NTSC frame
C4_HZ = 8363.0                   # XM playback rate of C-4 (no relative note)

NOISE_PERIODS = [4, 8, 16, 32, 64, 96, 128, 160, 202, 254, 380, 508, 762, 1016, 2034, 4068]
DMC_PERIODS = [428, 380, 340, 320, 286, 254, 226, 214, 190, 160, 142, 128, 106, 84, 72, 54]


def fail(msg):
    sys.exit("xmsamples: " + msg)


# ----------------------------------------------------------------- the NES

def envelope(start, step_hi, step_lo, dest=0):
    """Volume per frame of an RNME envelope with one point (envelope.asm)."""
    vols = [start]
    cur, frac = start, 0
    while cur != dest:
        frac += step_lo
        carry = frac >> 8
        frac &= 0xFF
        nxt = cur - step_hi - carry
        cur = dest if nxt <= dest else nxt
        vols.append(cur)
    return vols


def noise_segments(period_index, vols):
    """(cycle, level) steps of the noise channel, long mode, over the frames."""
    period = NOISE_PERIODS[period_index]
    lfsr = 1
    segs = []
    end = len(vols) * FRAME_CYCLES
    t = 0.0
    while t < end:
        vol = vols[int(t // FRAME_CYCLES)]
        segs.append((t, 0 if lfsr & 1 else vol))
        fb = (lfsr ^ (lfsr >> 1)) & 1
        lfsr = (lfsr >> 1) | (fb << 14)
        t += period
    segs.append((end, 0))
    return segs


def dmc_segments(data, rate_index, start_level, length):
    """(cycle, level) steps of the DMC output for length bytes of data."""
    period = DMC_PERIODS[rate_index]
    level = start_level
    segs = [(0.0, level)]
    t = 0.0
    for byte in data[:length]:
        for bit in range(8):
            if (byte >> bit) & 1:
                if level <= 125:
                    level += 2
            elif level >= 2:
                level -= 2
            t += period
            segs.append((t, level))
    return segs


def render(segs, rate, tail_seconds):
    """Box-filters a step signal to rate Hz; the last level is held for the
    tail, which the output filters then take down to zero."""
    step = CPU_HZ / rate
    end = segs[-1][0] + tail_seconds * CPU_HZ
    segs = segs + [(end, segs[-1][1])]
    out = []
    i = 0
    t0 = 0.0
    while t0 + step <= end:
        t1 = t0 + step
        acc = 0.0
        while segs[i + 1][0] <= t0:
            i += 1
        j = i
        while segs[j][0] < t1:
            a = max(segs[j][0], t0)
            b = min(segs[j + 1][0], t1)
            if b > a:
                acc += segs[j][1] * (b - a)
            j += 1
        out.append(acc / step)
        t0 = t1
    return out


def nes_filters(x, rate):
    """The NES's output high-pass filters (90 Hz and 440 Hz, first order)."""
    for fc in (90.0, 440.0):
        k = 1.0 / (1.0 + 2 * math.pi * fc / rate)
        y, prev_in, prev_out = [], x[0], 0.0
        for v in x:
            prev_out = k * (prev_out + v - prev_in)
            prev_in = v
            y.append(prev_out)
        x = y
    return x


def one_shot(segs, rate):
    x = nes_filters(render(segs, rate, 0.01), rate)
    fade = min(len(x), int(rate * 0.002))      # no click at the very end
    for n in range(fade):
        x[len(x) - fade + n] *= (fade - n - 1) / fade
    return x


def pulse(frames, duty):
    high = round(frames * duty)
    return [(1 - duty) if n < high else -duty for n in range(frames)]


def triangle(frames):
    steps = list(range(15, -1, -1)) + list(range(16))
    return [(steps[n * 32 // frames] - 7.5) / 7.5 for n in range(frames)]


def sawtooth(frames):
    return [-1 + 2 * (n + 0.5) / frames for n in range(frames)]


# ----------------------------------------------------------------- XM I/O

def decode(raw, sixteen):
    pcm, acc = [], 0
    if sixteen:
        for (d,) in struct.iter_unpack('<h', raw):
            acc = (acc + d + 32768) % 65536 - 32768
            pcm.append(acc)
    else:
        for d in raw:
            acc = (acc + d) % 256
            pcm.append(acc - 256 if acc > 127 else acc)
    return pcm


def encode(pcm, sixteen):
    out, prev = bytearray(), 0
    for v in pcm:
        if sixteen:
            out += struct.pack('<h', (v - prev + 32768) % 65536 - 32768)
        else:
            out.append((v - prev) % 256)
        prev = v
    return bytes(out)


def scaled(x, peak, sixteen):
    m = max(abs(v) for v in x) or 1
    lim = 32767 if sixteen else 127
    return [max(-lim - 1, min(lim, round(v * peak / m))) for v in x]


def playback_rate(note, relnote, finetune):
    """Sample rate at which an XM note plays a sample (linear frequency)."""
    return C4_HZ * 2 ** ((note - 49 + relnote + finetune / 128.0) / 12.0)


def note_number(name):
    names = ['C-', 'C#', 'D-', 'D#', 'E-', 'F-', 'F#', 'G-', 'G#', 'A-', 'A#', 'B-']
    return names.index(name[:2]) + 12 * int(name[2]) + 1


def new_sample(ins, hdr, old_pcm, dmc):
    """Returns (name, pcm, loop start, loop length, preview rate), or None;
    the loop is in frames."""
    sixteen = bool(hdr['type'] & 16)
    peak = max(abs(v) for v in old_pcm)
    frames = len(old_pcm)
    c4 = playback_rate(note_number('C-4'), hdr['rel'], hdr['fine'])
    if 1 <= ins <= 15:
        # The names of the samples these replaced (the NES duty bits) also work.
        duties = {'pulse 12.5%': 0.125, 'pulse 25%': 0.25, 'pulse 50%': 0.5,
                  'Ssqr00.wav': 0.125, 'Ssqr01.wav': 0.25, 'Ssqr10.wav': 0.5}
        if hdr['name'] not in duties:
            return None
        duty = duties[hdr['name']]
        return ('pulse %g%%' % (duty * 100), scaled(pulse(frames, duty), peak, sixteen), 0, frames, c4)
    if 33 <= ins <= 39:
        return ('triangle', scaled(triangle(frames), peak, sixteen), 0, frames, c4)
    if ins == 59:
        return ('sawtooth', scaled(sawtooth(32), peak, sixteen), 0, 32, c4)
    # One-shots, rendered at the rate of the note the songs play them at.
    rate = lambda note: playback_rate(note_number(note), hdr['rel'], hdr['fine'])
    if ins == 49:   # noise_env0, period 3
        r = rate('F-6')
        x = one_shot(noise_segments(3, envelope(0x0E, 0x06, 0x00)), r)
        name = 'noise closed hihat'
    elif ins == 50:  # noise_env1, period 0
        r = rate('C#5')
        x = one_shot(noise_segments(0, envelope(0x0C, 0x01, 0x00)), r)
        name = 'noise open hihat'
    elif ins == 51:  # noise_env2, period 9
        r = rate('C-5')
        x = one_shot(noise_segments(9, envelope(0x0C, 0x01, 0x40)), r)
        name = 'noise snare'
    elif ins == 57:  # $0F,$00,$F0,$10: rate 15, level 0, $FC00, 257 bytes
        r = rate('F-6')
        x = one_shot(dmc_segments(dmc, 15, 0, 257), r)
        name = 'dmc bass drum'
    elif ins == 58:  # $0F,$00,$F4,$20: rate 15, level 0, $FD00, 513 bytes
        r = rate('F-6')
        x = one_shot(dmc_segments(dmc[0x100:], 15, 0, 513), r)
        name = 'dmc bass drum+snare'
    else:
        return None
    return (name, scaled(x, peak, sixteen), 0, 0, r)


def convert(sample_dir, src, dst, wav_dir=None):
    dmc = b''.join(open(os.path.join(sample_dir, f), 'rb').read()
                   for f in ('bassdrum.bin', 'snare.bin', 'hurt.dmc'))
    d = open(src, 'rb').read()
    hs, songlen, restart, nch, npat, nins = struct.unpack_from('<IHHHHH', d, 60)
    pos = 60 + hs
    for _ in range(npat):
        phl, pack, rows, psize = struct.unpack_from('<IBHH', d, pos)
        pos += phl + psize
    out = bytearray(d[:pos])
    for ins in range(1, nins + 1):
        ihs, = struct.unpack_from('<I', d, pos)
        nsmp, = struct.unpack_from('<H', d, pos + 27)
        if nsmp == 0:
            out += d[pos:pos + ihs]
            pos += ihs
            continue
        shs, = struct.unpack_from('<I', d, pos + 29)
        out += d[pos:pos + ihs]
        sp = pos + ihs
        hdrs = []
        for _ in range(nsmp):
            ln, ls, ll, vol, fine, typ, pan, rel = struct.unpack_from('<IIIBbBBb', d, sp)
            name = d[sp + 18:sp + 40].rstrip(b'\0 ').decode('latin1')
            hdrs.append(dict(raw=d[sp:sp + shs], len=ln, type=typ, fine=fine, rel=rel, name=name))
            sp += shs
        datas = []
        for h in hdrs:
            raw = d[sp:sp + h['len']]
            sp += h['len']
            sixteen = bool(h['type'] & 16)
            new = new_sample(ins, h, decode(raw, sixteen), dmc)
            if new is None:
                fail('%s: instrument %d has a sample this script does not know' % (src, ins))
            name, pcm, loop_start, loop_len, preview_rate = new
            width = 2 if sixteen else 1
            hraw = bytearray(h['raw'])
            struct.pack_into('<III', hraw, 0, len(pcm) * width, loop_start * width, loop_len * width)
            hraw[14] = (hraw[14] & ~3) | (1 if loop_len else 0)   # forward loop, or none
            hraw[18:40] = name.encode('latin1').ljust(22, b'\0')
            out += hraw
            datas.append(encode(pcm, sixteen))
            if wav_dir:
                write_wav(os.path.join(wav_dir, '%02d %s.wav' % (ins, name)), pcm, sixteen,
                          preview_rate, loop_len)
        for data in datas:
            out += data
        pos = sp
    if pos != len(d):
        fail('%s: %d bytes after the last instrument' % (src, len(d) - pos))
    open(dst, 'wb').write(bytes(out))


def write_wav(path, pcm, sixteen, rate, loop_len):
    if loop_len:                     # a looped cycle: half a second of it
        pcm = (pcm * (int(rate / 2) // len(pcm) + 1))[:int(rate / 2)]
    w = wave.open(path, 'wb')
    w.setnchannels(1)
    w.setsampwidth(2)
    w.setframerate(int(round(rate)))
    w.writeframes(b''.join(struct.pack('<h', v if sixteen else v * 256) for v in pcm))
    w.close()


if __name__ == '__main__':
    if len(sys.argv) not in (4, 5):
        sys.exit(__doc__)
    convert(*sys.argv[1:])
