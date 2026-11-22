#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_ROOMS 128
#define MAX_MACROS 128

static char areaname[256];
static unsigned char roomdata[MAX_ROOMS * 8 * 8];
static unsigned char macrodata[MAX_MACROS * 16];
static unsigned char macroattribs[MAX_MACROS];
static unsigned char macrowalkabilities[MAX_MACROS * 4];
static unsigned char objectdata[MAX_ROOMS * 33];
static int objectdatasize[MAX_ROOMS];
static int mapwidth;
static int mapheight;
static int mapsize;
static int macrocount;
static char params[16][256];
static int paramcount;

static void printbytes(const unsigned char *buf, int size, int cols);
static void printchunk(const char *name, const unsigned char *buf, int size, int cols);
static bool paramexists(const char *param);

int main(int argc, char *argv[])
{
    if (argc < 2) {
        printf("\nSyntax: NGA2ASM [ngafile] [-a -p -m -r -w -h]\n");
        return 1;
    }
    FILE *fp = fopen(argv[1], "rb");
    if (!fp) {
        printf("\nError: Could not open '%s'.\n", argv[1]);
        return 1;
    }
    paramcount = argc - 2;
    if (paramcount == 0) {
        strcpy(params[paramcount++], "-a");
    } else {
        for (int i = 0; i < paramcount; i++) {
            strcpy(params[i], argv[i + 2]);
        }
    }
    const char *base = strrchr(argv[1], '/');
    base = base ? base + 1 : argv[1];
    strncpy(areaname, base, sizeof(areaname) - 1);
    areaname[sizeof(areaname) - 1] = '\0';
    strtok(areaname, ".");

    unsigned char buf[1024];
    char temp[256];
    fseek(fp, 4096, SEEK_SET);  // skip CHR data
    fread(buf, 1, 16, fp);      // read palette
    if (paramexists("-a") || paramexists("-p")) {
        printchunk("palette", buf, 16, 4);
    }

    // read map data
    mapwidth = 0;
    mapheight = 0;
    fread(&mapwidth, 1, 1, fp);
    fread(&mapheight, 1, 1, fp);
    mapsize = mapwidth * mapheight;
    fread(roomdata, 1, mapsize * 8 * 8, fp);

    // read macro data
    macrocount = 0;
    fread(&macrocount, 1, 1, fp);
    fread(macrodata, 1, macrocount * 16, fp);
    fread(macroattribs, 1, macrocount, fp);
    fread(macrowalkabilities, 1, macrocount * 4, fp);

    // read object data
    for (int i = 0; i < mapsize; i++) {
        int k = i * 33;  // start of object data for room i
        unsigned char n = 0;
        fread(&n, 1, 1, fp);  // # of objects in room i
        for (int j = 0; j < n; j++) {
            unsigned char ot = 0, op = 0;  // type, position
            fread(&ot, 1, 1, fp);
            fread(&op, 1, 1, fp);
            objectdata[k++] = ot;
            objectdata[k++] = op;
            if (ot == 2 || ot == 3) {
                // read warp data
                unsigned char b1 = 0, b2 = 0;
                fread(&b1, 1, 1, fp);
                fread(&b2, 1, 1, fp);
                objectdata[k++] = b1;
                objectdata[k++] = b2;
            }
        }
        objectdata[k++] = 0xFF;  // end marker
        objectdatasize[i] = k - (i * 33);
    }
    fclose(fp);

    if (paramexists("-a") || paramexists("-r")) {
        // print all rooms
        for (int i = 0; i < mapsize; i++) {
            snprintf(temp, sizeof(temp), "room%d", i);
            printchunk(temp, &roomdata[i * 64], 64, 8);
            printf("; %s_room%d_objects:\n", areaname, i);
            printbytes(&objectdata[i * 33], objectdatasize[i], 8);
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
            unsigned char *pObjs = &objectdata[i * 33];
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
