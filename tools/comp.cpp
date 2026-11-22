#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define RLE_TRIGGER 5
#define MAX_NAMETABLE_WIDTH 32
#define MAX_NAMETABLE_HEIGHT 32

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

int main(int argc, char *argv[])
{
    int width, height, namesize, ppusize, addr;
    unsigned char nametable[MAX_NAMETABLE_WIDTH * MAX_NAMETABLE_HEIGHT];
    unsigned char ppustring[MAX_NAMETABLE_WIDTH * MAX_NAMETABLE_HEIGHT];
    FILE *infile, *outfile;

    if (argc <= 5) {
        printf("Syntax is comp [inputfile] [width] [height] [startaddr] [outputfile]\n");
        return 1;
    }

    width = strtol(argv[2], 0, 0);
    if ((width <= 0) || (width > MAX_NAMETABLE_WIDTH)) {
        printf("Width is outside allowed range (0..%d).\n", MAX_NAMETABLE_WIDTH);
        return 1;
    }

    height = strtol(argv[3], 0, 0);
    if ((height <= 0) || (height > MAX_NAMETABLE_HEIGHT)) {
        printf("Height is outside allowed range (0..%d).\n", MAX_NAMETABLE_HEIGHT);
        return 1;
    }

    addr = strtol(argv[4], 0, 0);
    if ((addr < 0x2000) || (addr >= 0x3000)) {
        printf("Startaddr is outside allowed range (0x2000..0x2FFF).\n");
        return 1;
    }

    infile = fopen(argv[1], "rb");
    if (infile == 0) {
        printf("Couldn't open input file '%s', exiting.\n", argv[1]);
        return 1;
    }

    namesize = width * height;
    fread(nametable, 1, namesize, infile);
    fclose(infile);

    ppusize = EncodeNameTable(nametable, ppustring, addr, width, height);

    outfile = fopen(argv[5], "wb");
    if (outfile == 0) {
        printf("Couldn't open output file '%s', exiting.\n", argv[5]);
        return 1;
    }
    fwrite(ppustring, 1, ppusize, outfile);
    fclose(outfile);
    return 0;
}
