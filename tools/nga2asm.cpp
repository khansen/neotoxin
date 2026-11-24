// nga2asm: converts a map made with the NGA map editor to assembly source.
//
// Usage: nga2asm NGAFILE [-a -p -m -r -w -h]
//
// The output goes to standard output; -a (the default) prints everything,
// the other options select the palette, macros, rooms (with their objects
// and the map), warp locations and the area header.

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define CHR_SIZE 4096
#define MAX_MAP_WIDTH 16    // a room's position is stored as a $YX byte
#define MAX_MAP_HEIGHT 16
#define MAX_ROOMS (MAX_MAP_WIDTH * MAX_MAP_HEIGHT)
#define MAX_MACROS 256      // the macro count is one byte
#define ROOM_OBJECT_SIZE 33 // per room: objects (2 or 4 bytes each), $FF

static const char *ngafile;
static char areaname[256];
static unsigned char roomdata[MAX_ROOMS * 8 * 8];
static unsigned char macrodata[MAX_MACROS * 16];
static unsigned char macroattribs[MAX_MACROS];
static unsigned char macrowalkabilities[MAX_MACROS * 4];
static unsigned char objectdata[MAX_ROOMS * ROOM_OBJECT_SIZE];
static int objectdatasize[MAX_ROOMS];
static int mapwidth;
static int mapheight;
static int mapsize;
static int macrocount;
static int paramcount;
static char **params;

static void printbytes(const unsigned char *buf, int size, int cols);
static void printchunk(const char *name, const unsigned char *buf, int size, int cols);
static bool paramexists(const char *param);

static void fail(const char *message)
{
    fprintf(stderr, "nga2asm: %s: %s\n", ngafile, message);
    exit(1);
}

// Reads exactly size bytes; a short read means the file is not a complete
// NGA map.
static void readbytes(FILE *fp, void *buf, size_t size, const char *what)
{
    if (fread(buf, 1, size, fp) != size) {
        char message[128];
        snprintf(message, sizeof(message), "file ends in the %s", what);
        fail(message);
    }
}

static int readbyte(FILE *fp, const char *what)
{
    unsigned char b;
    readbytes(fp, &b, 1, what);
    return b;
}

int main(int argc, char *argv[])
{
    static char defaultparam[] = "-a";
    static char *defaultparams[] = { defaultparam };
    if (argc < 2) {
        fprintf(stderr, "Usage: nga2asm NGAFILE [-a -p -m -r -w -h]\n");
        return 1;
    }
    ngafile = argv[1];
    paramcount = argc - 2;
    params = argv + 2;
    if (paramcount == 0) {
        paramcount = 1;
        params = defaultparams;
    }
    for (int i = 0; i < paramcount; i++) {
        const char *p = params[i];
        if ((strlen(p) != 2) || (p[0] != '-') || !strchr("apmrwh", p[1])) {
            fprintf(stderr, "nga2asm: unknown option '%s'\n", p);
            return 1;
        }
    }
    FILE *fp = fopen(ngafile, "rb");
    if (!fp) {
        fprintf(stderr, "nga2asm: cannot open '%s'\n", ngafile);
        return 1;
    }
    const char *base = strrchr(ngafile, '/');
    base = base ? base + 1 : ngafile;
    strncpy(areaname, base, sizeof(areaname) - 1);
    areaname[sizeof(areaname) - 1] = '\0';
    strtok(areaname, ".");

    unsigned char buf[CHR_SIZE];
    char temp[256];
    readbytes(fp, buf, CHR_SIZE, "CHR data");   // skipped
    readbytes(fp, buf, 16, "palette");
    if (paramexists("-a") || paramexists("-p")) {
        printchunk("palette", buf, 16, 4);
    }

    // read map data
    mapwidth = readbyte(fp, "map size");
    mapheight = readbyte(fp, "map size");
    if ((mapwidth < 1) || (mapwidth > MAX_MAP_WIDTH) ||
        (mapheight < 1) || (mapheight > MAX_MAP_HEIGHT)) {
        snprintf(temp, sizeof(temp), "map is %d x %d rooms; the limit is %d x %d",
                 mapwidth, mapheight, MAX_MAP_WIDTH, MAX_MAP_HEIGHT);
        fail(temp);
    }
    mapsize = mapwidth * mapheight;
    readbytes(fp, roomdata, mapsize * 8 * 8, "room data");

    // read macro data
    macrocount = readbyte(fp, "macro count");
    readbytes(fp, macrodata, macrocount * 16, "macros");
    readbytes(fp, macroattribs, macrocount, "macro attributes");
    readbytes(fp, macrowalkabilities, macrocount * 4, "macro walkabilities");

    // read object data
    for (int i = 0; i < mapsize; i++) {
        int k = i * ROOM_OBJECT_SIZE;  // start of object data for room i
        int end = k + ROOM_OBJECT_SIZE - 1;  // room for the end marker
        int n = readbyte(fp, "objects");  // # of objects in room i
        for (int j = 0; j < n; j++) {
            int ot = readbyte(fp, "objects");  // type
            int op = readbyte(fp, "objects");  // position
            int size = (ot == 2 || ot == 3) ? 4 : 2;  // warps have a target
            if (k + size > end) {
                snprintf(temp, sizeof(temp), "room %d has more objects than fit in %d bytes",
                         i, ROOM_OBJECT_SIZE);
                fail(temp);
            }
            objectdata[k++] = ot;
            objectdata[k++] = op;
            if (size == 4) {
                // read warp data
                objectdata[k++] = readbyte(fp, "objects");
                objectdata[k++] = readbyte(fp, "objects");
            }
        }
        objectdata[k++] = 0xFF;  // end marker
        objectdatasize[i] = k - (i * ROOM_OBJECT_SIZE);
    }
    if (fgetc(fp) != EOF) {
        fail("unexpected data after the objects");
    }
    fclose(fp);

    if (paramexists("-a") || paramexists("-r")) {
        // print all rooms
        for (int i = 0; i < mapsize; i++) {
            snprintf(temp, sizeof(temp), "room%d", i);
            printchunk(temp, &roomdata[i * 64], 64, 8);
            printf("; %s_room%d_objects:\n", areaname, i);
            printbytes(&objectdata[i * ROOM_OBJECT_SIZE], objectdatasize[i], 8);
        }
        // print map
        int k = 0;
        printf("%s_map:\n", areaname);
        for (int i = 0; i < mapsize / 4; i++) {
            printf(".dw ");
            for (int j = 0; j < 3; j++) {
                printf("%s_room%d,", areaname, k++);
            }
            printf("%s_room%d\n", areaname, k++);
        }
        int m = mapsize % 4;
        if (m > 0) {
            printf(".dw ");
            for (int j = 0; j < m - 1; j++) {
                printf("%s_room%d,", areaname, k++);
            }
            printf("%s_room%d\n", areaname, k++);
        }
    }
    if (paramexists("-a") || paramexists("-m")) {
        // print all macros
        for (int i = 0; i < macrocount; i++) {
            snprintf(temp, sizeof(temp), "macro%d", i);
            printchunk(temp, &macrodata[i * 16], 16, 4);
        }
        // print macro attributes
        printchunk("macroattribs", macroattribs, macrocount, 16);
        // print macro walkabilities
        printchunk("macrowalkabilities", macrowalkabilities, macrocount * 4, 4);
        // print macro pointer table
        int k = 0;
        printf("%s_macroptrtable:\n", areaname);
        for (int i = 0; i < macrocount / 4; i++) {
            printf(".dw ");
            for (int j = 0; j < 3; j++) {
                printf("%s_macro%d,", areaname, k++);
            }
            printf("%s_macro%d\n", areaname, k++);
        }
        int m = macrocount % 4;
        if (m > 0) {
            printf(".dw ");
            for (int j = 0; j < m - 1; j++) {
                printf("%s_macro%d,", areaname, k++);
            }
            printf("%s_macro%d\n", areaname, k++);
        }
    }
    if (paramexists("-a") || paramexists("-w")) {
        // print warp locations
        printf("%s_warps:\n", areaname);
        int warpnum = 0;
        for (int i = 0; i < mapsize; i++) {
            unsigned char *pObjs = &objectdata[i * ROOM_OBJECT_SIZE];
            int k = 0;
            while (pObjs[k] != 0xFF) {
                int ot = pObjs[k++];
                int op = pObjs[k++];
                if (ot == 2 || ot == 3) {
                    // this is a warp, print its location
                    k += 2;  // skip warp target bytes
                    if (ot == 3) {
                        if ((op & 0x0F) < 8) {
                            op |= 1;
                        } else {
                            op &= 0xFE;
                        }
                    }
                    printf(".db $%.2X, $%.2X ; %.2X\n",
                           ((i / mapwidth) << 4) | ((i % mapwidth) & 0x0F),
                           op, warpnum++);
                }
            }
        }
    }
    if (paramexists("-a") || paramexists("-h")) {
        // print header
        printf("%s_header:\n", areaname);
        printf(".db 1\n");
        printf(".db %d\n", mapwidth);
        printf(".db %d\n", mapheight);
        printf(".dw %s_map\n", areaname);
        printf(".dw %s_macroptrtable\n", areaname);
        printf(".dw %s_macroattribs\n", areaname);
        printf(".dw %s_macrowalkabilities\n", areaname);
    }
    if ((fflush(stdout) != 0) || ferror(stdout)) {
        fprintf(stderr, "nga2asm: error writing the output\n");
        return 1;
    }
    return 0;
}

static void printbytes(const unsigned char *buf, int size, int cols)
{
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

static void printchunk(const char *name, const unsigned char *buf, int size, int cols)
{
    printf("%s_%s:\n", areaname, name);
    printbytes(buf, size, cols);
}

static bool paramexists(const char *param)
{
    for (int i = 0; i < paramcount; i++) {
        if (strcmp(params[i], param) == 0) {
            return true;
        }
    }
    return false;
}
