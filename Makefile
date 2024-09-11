# SPDX-FileCopyrightText: 2024 Mete Balci
#
# SPDX-License-Identifier: GPL-3.0-or-later

# set debug to 0 or 1
# adjust optimization flag accordingly below
debug = 1
# set fpu to soft, softfp or hard
# soft:   software fpu, soft abi
# softfp: hardware fpu, soft abi
# hard:   harwdare fpu, hard abi
fpu = soft

# specify an aarch32 bare-metal eabi toolchain
CC = arm-none-eabi-gcc

# modify these to add/remove different code/object files
C_OBJECTS = main.o syscalls.o
S_OBJECTS = minimum_arm_image_def_block.o
ELF = program.elf

# sets DEBUGFLAGS based on debug above
ifeq ($(debug), 1)
	DEBUGFLAGS = -g3 -O0
else
	# change optimization options to whatever suits you
	DEBUGFLAGS = -O2
endif

# sets FLOATFLAGS based on fpu above
ifeq ($(fpu), softfp)
	FLOATFLAGS = -mfloat-abi=softfp -mfpu=fpv5-sp-d16
else ifeq ($(fpu), hard)
	FLOATFLAGS = -mfloat-abi=hard -mfpu=fpv5-sp-d16
else
	FLOATFLAGS = -mfloat-abi=soft
endif

# cpu target and instruction set
CFLAGS = -mcpu=cortex-m33 -mthumb -std=gnu11
# floating point model
CFLAGS += $(FLOATFLAGS)
# includes
CFLAGS += -I. -Ipico-sdk/src/rp2_common/cmsis/stub/CMSIS/Core/Include -Ipico-sdk/src/rp2_common/cmsis/stub/CMSIS/Device/RP2350/Include

# use newlib nano
CFLAGS += --specs=nano.specs
# put functions and data into individual sections
CFLAGS += -ffunction-sections -fdata-sections
CFLAGS += -Wall
CFLAGS += $(DEBUGFLAGS)

ASFLAGS = -mcpu=cortex-m33 -mthumb
ASFLAGS += $(FLOATFLAGS)
ASFLAGS += --specs=nano.specs
# enable c preprocessor in assembly source files
ASFLAGS += -x assembler-with-cpp
ASFLAGS += $(DEBUGFLAGS)

LDFLAGS = -mcpu=cortex-m33 -mthumb
LDFLAGS += $(FLOATFLAGS)
# use the linker script
LDFLAGS += -T"linker.ld"
# use the system call stubs
LDFLAGS += --specs=nosys.specs 
# remove empty sections only if not for debug
LDFLAGS += -Wl,--gc-sections
LDFLAGS += -static
LDFLAGS += --specs=nano.specs
LDFLAGS += -Wl,--start-group -lc -lm -Wl,--end-group

all: clean $(ELF)

clean:
	rm -rf $(ELF) *.o

%.o: %.c Makefile | pico-sdk
	$(CC) $(CFLAGS) -c -o $@ $<

%.o: %.s Makefile | pico-sdk
	$(CC) $(ASFLAGS) -c -o $@ $<

$(ELF): $(C_OBJECTS) $(S_OBJECTS) Makefile linker.ld
	$(CC) -o $@ $(C_OBJECTS) $(S_OBJECTS) $(LDFLAGS)

flash: clean $(ELF)
	openocd -f interface/cmsis-dap.cfg -f target/rp2350.cfg -c "adapter speed 5000" -c "program $(ELF) verify reset exit"

debug: clean $(ELF)
	arm-none-eabi-gdb -ex "target remote localhost:3333" -ex "monitor reset init" -ex "break Reset_Handler" $(ELF)

openocd-server:
	openocd -f interface/cmsis-dap.cfg -f target/rp2350.cfg -c "adapter speed 5000"

reset:
	openocd -f interface/cmsis-dap.cfg -f target/rp2350.cfg -c "init; reset; exit;"

pico-sdk:
	git clone --depth 1 -b 2.0.0 https://github.com/raspberrypi/pico-sdk.git $@
