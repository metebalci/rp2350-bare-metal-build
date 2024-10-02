
# Introduction

This is a simple RP2350 application that runs on a [Raspberry Pi Pico 2](https://www.raspberrypi.com/products/raspberry-pi-pico-2/) microcontroller board that blinks the LED. The application can be built with Arm GNU Toolchain without using the Pico SDK build system (but Pico SDK is still required for CMSIS files). More information about this is given in my blog post [Using a Pico 2 RP2350 without the Pico SDK Build System](https://metebalci.com/blog/using-a-pico2-rp2350-without-the-pico-sdk-build-system/).

# Requirements

[Arm GNU Toolchain](https://developer.arm.com/Tools%20and%20Software/GNU%20Toolchain) is required to build the code. In order to flash (and debug if required), [openocd](https://github.com/raspberrypi/openocd) and a debug probe like [Raspberry Pi Debug Probe](https://www.raspberrypi.com/products/debug-probe/) is required. Alternatively, picotool can be used for flashing. Makefile's flash target uses openocd.

[Pico SDK](https://github.com/raspberrypi/pico-sdk) is required to build the code, as it contains the CMSIS header and source files, but it is automatically downloaded by the Makefile. 

The project is tested on a Raspberry Pi Pico 2 microcontroller board and built on Linux (Ubuntu 24.04) using Arm GNU Toolchain 13.3.Rel1 and Pico SDK 2.0.0.

# Files

- minimum_arm_image_def_block.s: minimal IMAGE_DEF block definition
- main.c: main application
- syscalls.c: syscall stubs
- linker.ld: linker description script

## Makefile targets

- all (default target): clean and builds program.elf
- reset: resets RP2350 (can be used with BOOTSEL button)
- flash: flashes program.elf (does not rebuild the program.elf)
- openocd-server: runs openocd gdb server
- debug: runs gdb (connects to openocd gdb server, resets, puts a breakpoint to Reset_Handler)

# License

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
