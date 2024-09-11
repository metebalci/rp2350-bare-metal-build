/*
 * SPDX-FileCopyrightText: 2024 Mete Balci
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

__XIP_BASE = 0x10000000;
/* 32M is allocated to QSPI flash */
/* actual can be less than this, on Pico 2 it is 4M */
__XIP_SIZE = 32M;

__SRAM_BASE = 0x20000000;
__SRAM_SIZE = 520K;

/* heap is just after bss section */
__HEAP_SIZE  = 32K;

/* stack is at the end of memory, growing down */
__STACK_SIZE = 32K;

/* Memories */
MEMORY
{
  RAM   (rwx) : ORIGIN = __SRAM_BASE,  LENGTH = __SRAM_SIZE
  FLASH (rx)  : ORIGIN = __XIP_BASE,   LENGTH = __XIP_SIZE
}

/* this is to eliminate RWX permission error for text segment */
PHDRS
{
  text PT_LOAD FLAGS(5);
  data PT_LOAD FLAGS(6);
  bss PT_LOAD FLAGS(6);
}

/* Sections */
SECTIONS
{
  .text :
  {
    . = ALIGN(4);
    KEEP(*(.vectors))
    KEEP(*(.picobin_block))
    *(.text*)
    KEEP(*(.init))
    KEEP(*(.fini))
    *(.rodata*)
    . = ALIGN(4);
  } >FLASH :text

  . = ALIGN(4);
  __data_source__ = .;

  .data :
  {
    __data_start__ = .;
    *(.data*)
    . = ALIGN(4);
    __data_end__ = .;
  } >RAM AT> FLASH :data

  .bss :
  {
    . = ALIGN(4);
    __bss_start__ = .;  /* used by NEWLIB */
    *(.bss*)
    . = ALIGN(4);
    __bss_end__ = .;    /* used by NEWLIB */
  } >RAM :bss

  /* heap starts after bss and grows bottom up */
  .heap (COPY) :
  {
    . = ALIGN(4);
    . = . + __HEAP_SIZE;
    . = ALIGN(4);
    __HeapLimit = .;    /* used for checking stack/heap overflow */
    end = .;            /* used by NEWLIB */

  } > RAM

  /* start stack from the end of ram - stack size */
  /* stack grows top down */
  .stack (ORIGIN(RAM) + LENGTH(RAM) - __STACK_SIZE) (COPY) :
  {
    . = ALIGN(4);
    __StackLimit = .;   /* used by CMSIS, will be initial PSPLIM/MSPLIM */
                        /* also used for checking stack/heap overflow */
    . = . + __STACK_SIZE;
    . = ALIGN(4);
    __StackTop = .;     /* used by CMSIS, will be initial PSP */
    __stack = .;        /* used by NEWLIB */
  } > RAM

  ASSERT(__StackLimit >= __HeapLimit, "stack or heap overflow")
}

