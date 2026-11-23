# NeoToxin

NeoToxin is an NES action game from 2004. It was never completed and is at an
alpha stage: the Boss 1 area has no boss, the Boss 2 area cannot be entered,
and nothing in the game leads to the end credits.

The cartridge is MMC3 (iNES mapper 4) with 128 KB of PRG ROM, 128 KB of CHR
ROM and battery-backed RAM for eight save slots.

## Building

Requirements:

- [XORcyst](https://github.com/khansen/xorcyst) 2.1
- GNU make (3.81 works)
- A C++ compiler and `patch`
- [huffpuff](https://github.com/khansen/huffpuff) 1.0.6, only to change the
  game's text

```sh
make                     # builds neotoxin.nes
make clean
make DEFINES=-DDEMOREC   # a build that records the player's input, for
                         # making the attract-mode demo
```

Keep the build free of warnings: xasm reports undeclared symbols only as
warnings.

## Testing

```sh
make test
```

The test needs FCEUX (tested with 2.7.0 and 2.8.0) and `python3`. It plays
through the game with fixed input in a headless FCEUX and compares the screen
and the sound at each checkpoint with `test/expected_hashes.txt`.

| Variable | Effect |
|---|---|
| `FCEUX_BIN` | FCEUX executable (default: `fceux` on `PATH`) |
| `NEOTOXIN_TEST_MODE=record` | rewrite `test/expected_hashes.txt` from the current ROM |
| `NEOTOXIN_SHOT_DIR=dir` | save each checkpoint's screen as `dir/<checkpoint>.ppm` |
| `NEOTOXIN_TEST_TIMEOUT` | seconds before giving up (default 60) |

Only record new hashes after checking that the changed screens are right, for
example with `NEOTOXIN_SHOT_DIR`.

## Source layout

| Directory | Contents |
|---|---|
| `common/` | hardware and generic routines |
| `sound/` | the music and sound effect engine and its data |
| `engine/` | the area engine, the script interpreter, text decoding, the credits scroller |
| `game/` | game flow and state: saves, status flags, level-up, demo mode |
| `screens/` | title, menus, status screen, game over |
| `area/` | one directory per area: maps, objects and area code |
| `script/` | the game's scripts |
| `chr/`, `data/`, `music/`, `huff/` | graphics, screen data, songs, text |
| `tools/` | the asset converters |
| `test/` | the tests |

`main.asm` holds the reset code and main loop, and `link.s` places the code
in the ROM banks.

## Changing the game's data

These files are generated from a source that `make` converts whenever it
changes; edit the source, not the generated file:

| Source | Generated file | Converter |
|---|---|---|
| `area/*/*.nga` (NGA map editor) | the map sections (`plant_sect1.nga` makes `plSect1.inc`) | `tools/nga2asm` |
| `music/neox009.xm` | `music/neox009.inc` | `tools/xm2muz` |
| `data/*.nam` | the dialog, name entry and game select screens, `data/*.dat` | `tools/comp` |
| `huff/strings.txt` | the game's text, `huff/strings.inc` and `huff/huffpuff.tab` | huffpuff |

Some map sections have hand edits on top of the converter's output, kept in a
`.patch` next to the `.inc`; the Makefile explains how to change one. The
other songs are edited in their `.inc` files; their `.xm` files are for
reference.

## Credits

From the game's end credits:

- Program, graphics, sound and tools: Kent Hansen
- Design and testing: Kent Hansen and Rob Mocca
- Moral support: Rob Mocca
- Thanks to minus/Ballistics, loopy, Jeremy Chadwick, Thomas Steen, Eugene Ng
  and Triton

## License

MIT; see `LICENSE`.
