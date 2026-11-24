// xm2muz: converts a FastTracker 2 module (.xm) to the RNME music engine's
// MUZ format, as assembly source on standard output.
//
// Usage: xm2muz XMFILE
//
// Channels 1-5 become the NES's square 1, square 2, triangle, noise and DPCM
// channels; any further channels are ignored. Instruments and samples are not
// read.

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static void printchunk(const char *name, const unsigned char *buf, int size, int cols);

#define MAX_CHANNELS 32
#define MAX_PATTERN_ROWS 256
#define NES_CHANNELS 5
// A MUZ order byte with bit 7 set is a command, so the pattern numbers of all
// five channels (pattern_count * channel + XM pattern) must be below 128.
#define MAX_PATTERNS (128 / NES_CHANNELS)
// Per 8 rows: a flags byte, then per row at most a volume (2 bytes), an
// instrument (2), an effect (2) and the note (1).
#define MAX_MUZ_PATTERN_SIZE (1 + (MAX_PATTERN_ROWS / 8) * (1 + 8 * 7))

typedef struct {
    unsigned char note;
    unsigned char instrument;
    unsigned char volume;
    unsigned char effect;
    unsigned char effect_param;
} note;

typedef struct {
    note notes[MAX_PATTERN_ROWS];
} column;

typedef struct {
    int16_t row_count;
    column columns[MAX_CHANNELS];
} pattern;

static pattern **patterns;
static char songname[256];
static const char *xmfile;

// XM header fields
static char id_text[17];
static char module_name[20];
static char tracker_name[20];
static int16_t version_number;
static int32_t header_size;
static int16_t song_length;
static int16_t restart_pos;
static int16_t channel_count;
static int16_t pattern_count;
static int16_t instrument_count;
static int16_t flags;
static int16_t default_tempo;
static int16_t default_bpm;
static unsigned char pattern_order_table[256];
static int patcounts[5];

static void fail(const char *message)
{
    fprintf(stderr, "xm2muz: %s: %s\n", xmfile, message);
    exit(1);
}

// Reads exactly size bytes; a short read means the file is not a complete XM
// module.
static void readbytes(FILE *fp, void *buf, size_t size, const char *what)
{
    if (fread(buf, 1, size, fp) != size) {
        char message[128];
        snprintf(message, sizeof(message), "file ends in the %s", what);
        fail(message);
    }
}

static void seekto(FILE *fp, long offset, const char *what)
{
    if (fseek(fp, offset, SEEK_SET) != 0) {
        char message[128];
        snprintf(message, sizeof(message), "cannot seek to the %s", what);
        fail(message);
    }
}

// Packed pattern data of one pattern, read byte by byte.
typedef struct {
    const unsigned char *data;
    int size;
    int pos;
    int index;  // pattern number, for errors
} packed_pattern;

static unsigned char packedbyte(packed_pattern *p)
{
    if (p->pos >= p->size) {
        char message[128];
        snprintf(message, sizeof(message), "pattern %d ends before its last row", p->index);
        fail(message);
    }
    return p->data[p->pos++];
}

int main(int argc, char *argv[])
{
    if (argc != 2) {
        fprintf(stderr, "Usage: xm2muz XMFILE\n");
        return 1;
    }
    xmfile = argv[1];
    FILE *xmfp = fopen(xmfile, "rb");
    if (xmfp == NULL) {
        fprintf(stderr, "xm2muz: cannot open '%s'\n", xmfile);
        return 1;
    }
    const char *base = strrchr(xmfile, '/');
    base = base ? base + 1 : xmfile;
    strncpy(songname, base, sizeof(songname) - 1);
    songname[sizeof(songname) - 1] = '\0';
    strtok(songname, ".");

    // read header fields (little-endian, as on the machines this runs on)
    readbytes(xmfp, &id_text, 17, "header");
    if (memcmp(id_text, "Extended Module: ", 17) != 0) {
        fail("not an XM module");
    }
    readbytes(xmfp, &module_name, 20, "header");
    unsigned char eof_marker;
    readbytes(xmfp, &eof_marker, 1, "header");   // $1A
    readbytes(xmfp, &tracker_name, 20, "header");
    readbytes(xmfp, &version_number, 2, "header");
    readbytes(xmfp, &header_size, 4, "header");
    readbytes(xmfp, &song_length, 2, "header");
    readbytes(xmfp, &restart_pos, 2, "header");
    readbytes(xmfp, &channel_count, 2, "header");
    readbytes(xmfp, &pattern_count, 2, "header");
    readbytes(xmfp, &instrument_count, 2, "header");
    readbytes(xmfp, &flags, 2, "header");
    readbytes(xmfp, &default_tempo, 2, "header");
    readbytes(xmfp, &default_bpm, 2, "header");
    // header_size counts from its own field; the order table follows the
    // 20 bytes of fields above, and the patterns follow the header
    if ((header_size < 20) || (header_size > 20 + 256)) {
        fail("unsupported header size");
    }
    if ((song_length < 1) || (song_length > header_size - 20)) {
        fail("song length does not fit in the order table");
    }
    readbytes(xmfp, &pattern_order_table, header_size - 20, "order table");
    if ((channel_count < 1) || (channel_count > MAX_CHANNELS)) {
        fail("unsupported number of channels");
    }
    if ((pattern_count < 1) || (pattern_count > MAX_PATTERNS)) {
        char message[128];
        snprintf(message, sizeof(message), "has %d patterns; MUZ allows 1..%d",
                 pattern_count, MAX_PATTERNS);
        fail(message);
    }
    for (int i = 0; i < song_length; i++) {
        if (pattern_order_table[i] >= pattern_count) {
            fail("order table refers to a pattern that does not exist");
        }
    }

    // read patterns
    long pattern_start = 60 + header_size;
    patterns = (pattern **)calloc(pattern_count, sizeof(pattern *));
    for (int i = 0; i < pattern_count; i++) {
        uint32_t pattern_header_size = 0;
        unsigned char packing_type = 0;
        uint16_t row_count = 0;
        uint16_t packed_data_size = 0;
        unsigned char pattern_byte = 0, _note = 0, instrument = 0, volume = 0, effect = 0, effect_param = 0;
        // read pattern header
        seekto(xmfp, pattern_start, "patterns");
        readbytes(xmfp, &pattern_header_size, 4, "pattern header");
        readbytes(xmfp, &packing_type, 1, "pattern header");
        readbytes(xmfp, &row_count, 2, "pattern header");
        readbytes(xmfp, &packed_data_size, 2, "pattern header");
        if ((pattern_header_size < 9) || (row_count < 1) || (row_count > MAX_PATTERN_ROWS)) {
            fail("invalid pattern header");
        }
        // read the packed pattern data; none means an empty pattern
        seekto(xmfp, pattern_start + pattern_header_size, "pattern data");
        unsigned char *data = (unsigned char *)malloc(packed_data_size + 1);
        readbytes(xmfp, data, packed_data_size, "pattern data");
        pattern_start += pattern_header_size + packed_data_size;
        packed_pattern packed = { data, packed_data_size, 0, i };
        // allocate pattern (rows without data stay empty)
        pattern *pat = (pattern *)calloc(1, sizeof(pattern));
        pat->row_count = row_count;
        patterns[i] = pat;
        if (packed_data_size == 0) {
            free(data);
            continue;
        }
        // unpack pattern data
        for (int j = 0; j < row_count; j++) {
            for (int k = 0; k < channel_count; k++) {
                pattern_byte = packedbyte(&packed);
                if (pattern_byte & 0x80) {
                    // compressed
                    if (pattern_byte & 0x01) {  // note follows
                        _note = packedbyte(&packed);
                    } else {
                        _note = 0;
                    }
                    if (pattern_byte & 0x02) {  // instrument follows
                        instrument = packedbyte(&packed);
                    } else {
                        instrument = 0;
                    }
                    if (pattern_byte & 0x04) {  // volume column byte follows
                        volume = packedbyte(&packed);
                    } else {
                        volume = 0;
                    }
                    if (pattern_byte & 0x08) {  // effect follows
                        effect = packedbyte(&packed);
                    } else {
                        effect = 0;
                    }
                    if (pattern_byte & 0x10) {  // effect param follows
                        effect_param = packedbyte(&packed);
                    } else {
                        effect_param = 0;
                    }
                } else {
                    // uncompressed
                    _note = pattern_byte;
                    instrument = packedbyte(&packed);
                    volume = packedbyte(&packed);
                    effect = packedbyte(&packed);
                    effect_param = packedbyte(&packed);
                }
                note *n = &pat->columns[k].notes[j];
                n->note = _note;
                n->instrument = instrument;
                n->volume = volume;
                if ((effect == 0) && (effect_param != 0)) {
                    effect = 5;  // arpeggio
                }
                n->effect = effect;
                n->effect_param = effect_param;
            }
        }
        if (packed.pos != packed.size) {
            char message[128];
            snprintf(message, sizeof(message), "pattern %d has data after its last row", i);
            fail(message);
        }
        free(data);
    }
    fclose(xmfp);

    // convert patterns to MUZ format
    for (int j = 0; j < channel_count; j++) {
        if (j >= NES_CHANNELS) {
            break;   // the NES only has 5 channels
        }
        for (int i = 0; i < pattern_count; i++) {
            pattern *pat = patterns[i];
            // convert the channel data to a MUZ pattern
            column *c = &pat->columns[j];
            unsigned char muz_pat[MAX_MUZ_PATTERN_SIZE];
            muz_pat[0] = (unsigned char)pat->row_count;  // 1st byte = row count
            int pos = 1;  // current position in MUZ pattern
            unsigned char lastinstr = 0xFF;
            unsigned char lastvol = 0xFF;
            unsigned char lasteff = 0x00;
            unsigned char lasteffparam = 0x00;
            // process pattern in 8-row chunks
            for (int k = 0; k < pat->row_count; k += 8) {
                unsigned char row_flags = 0;  // clear row-active flags
                for (int l = 0; l < 8; l++) {
                    note *n = &c->notes[k + l];
                    if (n->note != 0) {
                        row_flags |= 1 << l;  // non-zero note, mark row l as active
                    }
                }
                muz_pat[pos++] = row_flags;  // put flags in pattern
                // flags are then followed by the actual note/effect data for these 8 rows
                for (int l = 0; l < 8; l++) {  // do one row
                    note *n = &c->notes[k + l];
                    if (n->note != 0) {
                        switch (j) {  // channel #
                            // square
                            case 0:
                            case 1:
                                if ((n->volume >= 0x10) && (n->volume < 0x50)) {
                                    // set new channel volume
                                    if (n->volume != lastvol) {  // only if it is different from last value
                                        muz_pat[pos++] = 0xEB;  // set volume
                                        muz_pat[pos++] = ((n->volume - 0x10) >> 2) << 4;
                                        lastvol = n->volume;
                                    }
                                } else if (lastvol != 0x50) {
                                    muz_pat[pos++] = 0xEB;  // initialize volume
                                    muz_pat[pos++] = 0xF0;  // to max.
                                    lastvol = 0x50;
                                }
                                /* fall through */
                            // square & tri
                            case 2:
                                if (n->instrument != lastinstr) {
                                    muz_pat[pos++] = 0xE8;  // set instrument
                                    muz_pat[pos++] = (n->instrument - 1) & 0x1F;
                                    lastinstr = n->instrument;
                                }
                                if ((n->effect != lasteff) ||
                                    ((n->effect == lasteff) && (n->effect_param != lasteffparam))) {
                                    muz_pat[pos++] = 0xE0 | n->effect;  // set effect
                                    if (n->effect != 0) {
                                        muz_pat[pos++] = n->effect_param;  // set effect parameter
                                    }
                                    lasteff = n->effect;
                                    lasteffparam = n->effect_param;
                                }
                                muz_pat[pos++] = n->note - 15;
                                break;
                            // noise
                            case 3:
                                if ((n->volume >= 0x10) && (n->volume < 0x50)) {
                                    // set new channel volume
                                    if (n->volume != lastvol) {  // only if it is different from last value
                                        muz_pat[pos++] = 0xEB;  // set volume
                                        muz_pat[pos++] = ((n->volume - 0x10) >> 2) << 4;
                                        lastvol = n->volume;
                                    }
                                } else if (lastvol != 0x50) {
                                    muz_pat[pos++] = 0xEB;  // initialize volume
                                    muz_pat[pos++] = 0xF0;  // to max.
                                    lastvol = 0x50;
                                }
                                muz_pat[pos++] = n->instrument - 0x31;
                                break;
                            // dpcm
                            case 4:
                                if (n->instrument == 0x39) {
                                    muz_pat[pos++] = 0x1B;  // bassdrum
                                } else if (n->instrument == 0x3A) {
                                    muz_pat[pos++] = 0x1C;  // combined bassdrum+snare
                                } else if (n->instrument == 0x3B) {
                                    muz_pat[pos++] = n->note - 49;  // bass note
                                }
                                break;
                        }
                    }
                }
            }
            char name[256];
            snprintf(name, sizeof(name), "%s_chn%d_pat%d", songname, j, patcounts[j]++);
            printchunk(name, muz_pat, pos, 16);
            if (pos >= 256) {
                fprintf(stderr, "xm2muz: %s: warning: %s is %d bytes, more than 256\n",
                        xmfile, name, pos);
            }
        }
        printf("\n");
    }

    // print pattern pointer table
    printf("%s_patterns:\n", songname);
    for (int i = 0; i < 5; i++) {
        for (int j = 0; j < patcounts[i]; j++) {
            printf(".dw %s_chn%d_pat%d\n", songname, i, j);
        }
    }

    // print order tables
    for (int i = 0; i < 5; i++) {
        printf("%s_order%d:\n.db ", songname, i);
        for (int j = 0; j < song_length; j++) {
            printf("$%.2X,", pattern_order_table[j] + (pattern_count * i));
        }
        printf("$FE,0\n\n");
    }

    // print the song header
    printf("%s:\n", songname);
    for (int i = 0; i < 5; i++) {
        if (patcounts[i] > 0) {
            printf(".dw %s_order%d : .db %d\n", songname, i, default_tempo + 1);
        } else {
            printf(".db 0,0,0\n");
        }
    }
    printf(".dw %s_patterns\n", songname);

    // free pattern memory
    for (int i = 0; i < pattern_count; i++) {
        free(patterns[i]);
    }
    free(patterns);
    if ((fflush(stdout) != 0) || ferror(stdout)) {
        fprintf(stderr, "xm2muz: error writing the output\n");
        return 1;
    }
    return 0;
}

static void printchunk(const char *name, const unsigned char *buf, int size, int cols)
{
    printf("%s:\n", name);
    int k = 0;
    for (int i = 0; i < size / cols; i++) {
        printf(".db ");
        for (int j = 0; j < cols - 1; j++) {
            printf("$%.2X,", buf[k++]);
        }
        printf("$%.2X\n", buf[k++]);
    }
    int m = size % cols;
    if (m > 0) {
        printf(".db ");
        for (int j = 0; j < m - 1; j++) {
            printf("$%.2X,", buf[k++]);
        }
        printf("$%.2X\n", buf[k++]);
    }
}
