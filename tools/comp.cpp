// comp: compresses a nametable into the PPU string format the game's
// screen loader reads.
//
// Usage: comp INPUT WIDTH HEIGHT STARTADDR OUTPUT
//
// INPUT holds at least WIDTH * HEIGHT tile bytes, row by row; anything after
// them (such as the attribute table of a full .nam file) is ignored.

#include <stdio.h>
#include <stdlib.h>

#define RLE_TRIGGER 5
#define MAX_NAMETABLE_WIDTH 32
#define MAX_NAMETABLE_HEIGHT 32

// Every run of output (an address, a length and the bytes or the RLE value)
// consumes at least one input byte and is at most 4 bytes per byte consumed,
// plus the terminator.
#define MAX_OUTPUT_SIZE (4 * MAX_NAMETABLE_WIDTH * MAX_NAMETABLE_HEIGHT + 1)

static int EncodeNameTable(const unsigned char *in, unsigned char *out, int addr, int width, int height);
static int EncodeRow(const unsigned char *in, unsigned char *out, int addr, int length);
static bool RLE_OK(const unsigned char *in, int length);

static bool RLE_OK(const unsigned char *in, int length)
{
    if (length < RLE_TRIGGER) {
        return false;
    }
    for (int i = 0; i < RLE_TRIGGER; i++) {
        if (in[0] != in[i]) {
            return false;
        }
    }
    return true;
}

// Encode one row of nametable data.
static int EncodeRow(const unsigned char *in, unsigned char *out, int addr, int length)
{
    int i = 0, j = 0, k, m;
    int resetaddr = addr;
    unsigned char c, l;
    while (i < length) {
        while (in[i] == 0x00) {
            i++;    // skip fillvalue
            if (i == length) {
                return j;
            }
        }
        addr = resetaddr + i;
        out[j++] = addr >> 8;   // high address
        out[j++] = addr & 0xFF; // low address
        if (RLE_OK(&in[i], length - i)) {    // do RLE
            l = RLE_TRIGGER;    // length
            c = in[i++];        // RLE value
            while (RLE_OK(&in[i], length - i)) {
                l++;
                i++;
            }
            i += RLE_TRIGGER - 1;
            out[j++] = l | 0x40;
            out[j++] = c;
        } else {
            k = j;  // index of length byte
            out[j++] = 0;
            l = 0;  // length
            while ((i < length) && (!RLE_OK(&in[i], length - i))) {
                out[j++] = in[i++];
                l++;
            }
            if (i == length) {
                m = i - 1;
                while ((m >= 0) && (in[m--] == 0x00)) {
                    l--;
                    j--;
                }
            }
            out[k] = l;
        }
    }
    return j;
}

static int EncodeNameTable(const unsigned char *in, unsigned char *out, int addr, int width, int height)
{
    int ppusize = 0;
    for (int i = 0; i < height; i++) {
        ppusize += EncodeRow(&in[i * width], &out[ppusize], addr, width);
        addr += MAX_NAMETABLE_WIDTH;
    }
    out[ppusize++] = 0; // terminator
    return ppusize;
}

// Parses a whole argument as an integer (decimal, or hex with 0x).
static bool ParseInt(const char *s, int *value)
{
    char *end;
    long v = strtol(s, &end, 0);
    if ((*s == '\0') || (*end != '\0') || (v < -0x10000) || (v > 0x10000)) {
        return false;
    }
    *value = (int)v;
    return true;
}

int main(int argc, char *argv[])
{
    int width, height, namesize, ppusize, addr;
    unsigned char nametable[MAX_NAMETABLE_WIDTH * MAX_NAMETABLE_HEIGHT];
    unsigned char ppustring[MAX_OUTPUT_SIZE];
    FILE *infile, *outfile;

    if (argc != 6) {
        fprintf(stderr, "Usage: comp INPUT WIDTH HEIGHT STARTADDR OUTPUT\n");
        return 1;
    }

    if (!ParseInt(argv[2], &width) || (width <= 0) || (width > MAX_NAMETABLE_WIDTH)) {
        fprintf(stderr, "comp: width must be 1..%d\n", MAX_NAMETABLE_WIDTH);
        return 1;
    }

    if (!ParseInt(argv[3], &height) || (height <= 0) || (height > MAX_NAMETABLE_HEIGHT)) {
        fprintf(stderr, "comp: height must be 1..%d\n", MAX_NAMETABLE_HEIGHT);
        return 1;
    }

    if (!ParseInt(argv[4], &addr) || (addr < 0x2000) || (addr >= 0x3000)) {
        fprintf(stderr, "comp: start address must be 0x2000..0x2FFF\n");
        return 1;
    }

    infile = fopen(argv[1], "rb");
    if (infile == 0) {
        fprintf(stderr, "comp: cannot open '%s'\n", argv[1]);
        return 1;
    }

    namesize = width * height;
    if ((int)fread(nametable, 1, namesize, infile) != namesize) {
        fprintf(stderr, "comp: '%s' is shorter than %d x %d bytes\n", argv[1], width, height);
        fclose(infile);
        return 1;
    }
    fclose(infile);

    ppusize = EncodeNameTable(nametable, ppustring, addr, width, height);

    outfile = fopen(argv[5], "wb");
    if (outfile == 0) {
        fprintf(stderr, "comp: cannot create '%s'\n", argv[5]);
        return 1;
    }
    bool ok = ((int)fwrite(ppustring, 1, ppusize, outfile) == ppusize);
    if (fclose(outfile) != 0) {
        ok = false;
    }
    if (!ok) {
        fprintf(stderr, "comp: error writing '%s'\n", argv[5]);
        remove(argv[5]);
        return 1;
    }
    return 0;
}
