#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static void printchunk(const char *name, const unsigned char *buf, int size, int cols);

#define MAX_CHANNELS 32
#define MAX_PATTERNS 256
#define MAX_PATTERN_ROWS 256

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

int main(int argc, char *argv[])
{
    if (argc <= 1) {
        printf("\nSyntax: XM2MUZ [XM-file]\n");
        return 1;
    }
    FILE *xmfp = fopen(argv[1], "rb");
    if (xmfp == NULL) {
        printf("\nERROR: Could not open '%s'.\n", argv[1]);
        return 1;
    }
    const char *base = strrchr(argv[1], '/');
    base = base ? base + 1 : argv[1];
    strncpy(songname, base, sizeof(songname) - 1);
    songname[sizeof(songname) - 1] = '\0';
    strtok(songname, ".");

    // read header fields
    fread(&id_text, 1, 17, xmfp);
    fread(&module_name, 1, 20, xmfp);
    fseek(xmfp, 1, SEEK_CUR);   // skip $1A byte
    fread(&tracker_name, 1, 20, xmfp);
    fread(&version_number, 1, 2, xmfp);
    fread(&header_size, 1, 4, xmfp);
    fread(&song_length, 1, 2, xmfp);
    fread(&restart_pos, 1, 2, xmfp);
    fread(&channel_count, 1, 2, xmfp);
    fread(&pattern_count, 1, 2, xmfp);
    fread(&instrument_count, 1, 2, xmfp);
    fread(&flags, 1, 2, xmfp);
    fread(&default_tempo, 1, 2, xmfp);
    fread(&default_bpm, 1, 2, xmfp);
    fread(&pattern_order_table, 1, 256, xmfp);

    // read patterns
    patterns = (pattern **)malloc(pattern_count * sizeof(pattern *));
    for (int i = 0; i < pattern_count; i++) {
        int32_t pattern_header_size = 0;
        unsigned char packing_type = 0;
        int16_t row_count = 0;
        int16_t packed_data_size = 0;
        unsigned char pattern_byte = 0, _note = 0, instrument = 0, volume = 0, effect = 0, effect_param = 0;
        // read pattern header
        fread(&pattern_header_size, 1, 4, xmfp);
        fread(&packing_type, 1, 1, xmfp);
        fread(&row_count, 1, 2, xmfp);
        fread(&packed_data_size, 1, 2, xmfp);
        // allocate pattern
        pattern *pat = (pattern *)malloc(sizeof(pattern));
        pat->row_count = row_count;
        patterns[i] = pat;
        // unpack pattern data
        for (int j = 0; j < row_count; j++) {
            for (int k = 0; k < channel_count; k++) {
                fread(&pattern_byte, 1, 1, xmfp);
                if (pattern_byte & 0x80) {
                    // compressed
                    if (pattern_byte & 0x01) {
                        fread(&_note, 1, 1, xmfp);
                    } else {
                        _note = 0;
                    }
                    if (pattern_byte & 0x02) {
                        fread(&instrument, 1, 1, xmfp);
                    } else {
                        instrument = 0;
                    }
                    if (pattern_byte & 0x04) {
                        fread(&volume, 1, 1, xmfp);
                    } else {
                        volume = 0;
                    }
                    if (pattern_byte & 0x08) {
                        fread(&effect, 1, 1, xmfp);
                    } else {
                        effect = 0;
                    }
                    if (pattern_byte & 0x10) {
                        fread(&effect_param, 1, 1, xmfp);
                    } else {
                        effect_param = 0;
                    }
                } else {
                    // uncompressed
                    _note = pattern_byte;
                    fread(&instrument, 1, 1, xmfp);
                    fread(&volume, 1, 1, xmfp);
                    fread(&effect, 1, 1, xmfp);
                    fread(&effect_param, 1, 1, xmfp);
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
    }
    fclose(xmfp);

    // convert patterns to MUZ format
    for (int j = 0; j < channel_count; j++) {
        if (j >= 5) {
            break;   // the NES only has 5 channels
        }
        for (int i = 0; i < pattern_count; i++) {
            pattern *pat = patterns[i];
            column *c = &pat->columns[j];
            unsigned char muz_pat[1024];
            muz_pat[0] = (unsigned char)pat->row_count;
            int pos = 1;
            unsigned char lastinstr = 0xFF;
            unsigned char lastvol = 0xFF;
            unsigned char lasteff = 0x00;
            unsigned char lasteffparam = 0x00;
            for (int k = 0; k < pat->row_count; k += 8) {
                unsigned char row_flags = 0;
                for (int l = 0; l < 8; l++) {
                    note *n = &c->notes[k + l];
                    if (n->note != 0) {
                        row_flags |= 1 << l;
                    }
                }
                muz_pat[pos++] = row_flags;
                for (int l = 0; l < 8; l++) {
                    note *n = &c->notes[k + l];
                    if (n->note != 0) {
                        switch (j) {
                            case 0:
                            case 1:
                                if ((n->volume >= 0x10) && (n->volume < 0x50)) {
                                    if (n->volume != lastvol) {
                                        muz_pat[pos++] = 0xEB;
                                        muz_pat[pos++] = ((n->volume - 0x10) >> 2) << 4;
                                        lastvol = n->volume;
                                    }
                                } else if (lastvol != 0x50) {
                                    muz_pat[pos++] = 0xEB;
                                    muz_pat[pos++] = 0xF0;
                                    lastvol = 0x50;
                                }
                                /* fall through */
                            case 2:
                                if (n->instrument != lastinstr) {
                                    muz_pat[pos++] = 0xE8;
                                    muz_pat[pos++] = (n->instrument - 1) & 0x1F;
                                    lastinstr = n->instrument;
                                }
                                if ((n->effect != lasteff) ||
                                    ((n->effect == lasteff) && (n->effect_param != lasteffparam))) {
                                    muz_pat[pos++] = 0xE0 | n->effect;
                                    if (n->effect != 0) {
                                        muz_pat[pos++] = n->effect_param;
                                    }
                                    lasteff = n->effect;
                                    lasteffparam = n->effect_param;
                                }
                                muz_pat[pos++] = n->note - 15;
                                break;
                            case 3:
                                if ((n->volume >= 0x10) && (n->volume < 0x50)) {
                                    if (n->volume != lastvol) {
                                        muz_pat[pos++] = 0xEB;
                                        muz_pat[pos++] = ((n->volume - 0x10) >> 2) << 4;
                                        lastvol = n->volume;
                                    }
                                } else if (lastvol != 0x50) {
                                    muz_pat[pos++] = 0xEB;
                                    muz_pat[pos++] = 0xF0;
                                    lastvol = 0x50;
                                }
                                muz_pat[pos++] = n->instrument - 0x31;
                                break;
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
                fprintf(stderr, "Warning: pattern exceeds 256 bytes\n");
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
