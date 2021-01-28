# The TRS-80 Model 1 for the Ulx3s FPGA Ecp5 board

This version has been created from the ulxs3_z80_template code base.

##Introduction

This is a reimplementsation of ulx3s_trs_80 using the ulx3s_z80_template, so that it shares a common up-to-date code base with my other Z80 computers.

The main changes from ther template are:

* video.v is updated to produce the TRS-80 Model 1 character output, using a character rom.
* keyboard.v from the Mister project is used to convert PS/2 scan codes to the keyboard matrix.
* the ACIA and SDRAM options are not used.
* The chip select and memory decoding code in the top level Verilog module is changed to implement the Model 1 memory model and I/O ports.
* The esp32 code is changed to use an osd.py that uses ld_trs80.py, to load cassette tape images.

## ROM

The ROM used is the variant of the Video Genie rom from the Mister project.

The original TRS-80 rom is also available.

## Installation

You need a recent version of yosys, nextpnr-ecp5, project trellis and fujprog.

Then, after cloning the repository, do:

```sh
cd ulx3s
make prog
```

Upload esp32/osd/osd.py and esp32/osd/ld_trs80.py to the ESP32 (which must be running micropython).

## Running

You will need a PS/2 keyboard plugged into us2 via an OTG adapter. You can either use a USB keyboard that supports the PS/2 protocol, or use a PS/2 keyboard with a green adapter.

By default the Video Genie/Dick Smith System 80 rom runs and gives a `Ready?` prompt. Press Enter to use all the memory. You are then in Basic.

You can load a program, such as a game, written in assembly via the OSD.

To do this do `import osd.py` from web repl.

You can then start the OSD by pressing all 4 direction buttons at the same time and select a .cas file from the ESP32 flash memory or from an sd card.

Only system programs written in assemler are supported.

The Galaxy Invasion game running:

![Galaxy Invasion](https://raw.githubusercontent.com/lawrie/lawrie.github.io/master/images/galaxy.jpg)

The only way to run a Basic program is to to change convert a basic ,cas file to a hex file and use MEM_FILE_INIT in top.v to load the file into the game rom.

You can run the Basic program in the game rom by typing "CLOAD" from Basic.

The dslogo.cas Basic program running, showing the famous Australian, Dick Smith:

![Dick Smith](https://raw.githubusercontent.com/lawrie/lawrie.github.io/master/images/dslogo.jpg)

## Bugs

The CPU speed is not correct.

The shift and backspace keys are not working correctly.

