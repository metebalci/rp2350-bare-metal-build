// SPDX-FileCopyrightText: 2024 Mete Balci
//
// SPDX-License-Identifier: GPL-3.0-or-later

// ref: RP2350 datasheet 5.9.5.1. Minimum Arm IMAGE_DEF

// this is a single block with two items (IMAGE_TYPE and LAST) in it

// include this section in linker description in the first 4K of a flash image
.section .picobin_block, "a"

.word 0xffffded3 // PICOBIN_BLOCK_MARKER_START

// item 0 IMAGE_TYPE

.byte 0x42 // PICOBIN_BLOCK_ITEM_1BS_IMAGE_TYPE
.byte 0x1 // item is 1 word
// Try Before You Buy - 0 (not set)
// Chip - b001 (RP2350)
// reserved - 0b0
// CPU - b000 (ARM)
// reserved - 0b00
// EXE Security - 0b10 (Secure mode)
// Image Type - 0b0001 (EXE)
.hword 0b0001000000100001

// item 1 LAST

.byte 0xff // PICOBIN_BLOCK_ITEM_2BS_LAST
.hword 0x0001 // item is 1 word
.byte 0 // pad

// relative pointer to next block in loop
// 0 means a link to itself, meaning there is no other block
.word 0

.word 0xab123579 // PICOBIN_BLOCK_MARKER_END
