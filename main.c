// Copyright 2024 Mete Balci
//
// SPDX-License-Identifier: GPL-3.0-or-later

#include <stdbool.h>

#include "RP2350.h"
#include "core_cm33.h"

// On Pico2, LED is connected to GPIO25

// defined in CMSIS as __StackTop
extern uint32_t __INITIAL_SP;

extern __NO_RETURN void _start(void);

void Default_Handler(void);
__NO_RETURN void Reset_Handler(void);
void NMI_Handler(void) __attribute__ ((weak, alias("Default_Handler")));
void HardFault_Handler(void) __attribute__ ((weak));
void MemManage_Handler(void) __attribute__ ((weak, alias("Default_Handler")));
void BusFault_Handler(void) __attribute__ ((weak, alias("Default_Handler")));
void UsageFault_Handler(void) __attribute__ ((weak, alias("Default_Handler")));
void SecureFault_Handler(void) __attribute__ ((weak, alias("Default_Handler")));
void SVC_Handler(void) __attribute__ ((weak, alias("Default_Handler")));
void DebugMon_Handler(void) __attribute__ ((weak, alias("Default_Handler")));
void PendSV_Handler(void) __attribute__ ((weak, alias("Default_Handler")));
void SysTick_Handler(void);

// defined in system_RP2350.h
typedef void(*VECTOR_TABLE_Type)(void);
// __VECTOR_TABLE is __Vectors (m-profile/cmsis_gcc.h)
extern const VECTOR_TABLE_Type __VECTOR_TABLE[496];
// attribute is defined as (used, section(".vectors"))
const VECTOR_TABLE_Type __VECTOR_TABLE[496] __VECTOR_TABLE_ATTRIBUTE = {
  (VECTOR_TABLE_Type)(&__INITIAL_SP),
  Reset_Handler,
  NMI_Handler,
  HardFault_Handler,
  MemManage_Handler,
  BusFault_Handler,
  UsageFault_Handler,
  SecureFault_Handler,
  0,
  0,
  0,
  SVC_Handler,
  DebugMon_Handler,
  0,
  PendSV_Handler,
  SysTick_Handler
};

void Default_Handler(void)
{
  while (1);
}

__NO_RETURN void Reset_Handler(void)
{
  // defined in CMSIS as __StackLimit
  extern uint32_t __STACK_LIMIT;

  __set_PSP((uint32_t)(&__INITIAL_SP));
  __set_MSPLIM((uint32_t)(&__STACK_LIMIT));
  __set_PSPLIM((uint32_t)(&__STACK_LIMIT));

  // copy data section from FLASH to RAM
  extern uint32_t* __data_start__;
  extern uint32_t* __data_end__;
  extern uint32_t* __data_source__;

  uint32_t* p = __data_start__;
  uint32_t* q = __data_source__;

  while (p < __data_end__)
  {
    *p++ = *q++;
  }

  // start newlib._start in newlib/libc/sys/arm/crt0.S
  _start();
}

void HardFault_Handler(void)
{
  while (1);
}

// system_init is called very early from startup
// configure power and clock here
void SystemInit(void) 
{
  // if clksource = external, then hclk/8 is used for systick
  // then LOAD should be 32MHz/8/1000, 4000 for every ms
  // if clksource = processor, then sysclk is used for systick
  // then LOAD should be 32MHz/1000, 32000 for every ms
  SysTick->LOAD = 32000;
  // set current value to 0
  SysTick->VAL = 0;
  // bit 2 = clksource = processor (set to 0 for external)
  // bit 1 = systick exception generation enabled
  // bit 0 = systick counter enabled
  SysTick->CTRL = 0b111;
}

// a simple systick implementation for timeinms counter
static volatile uint32_t timeinms = 0;

// this name is used in the vector table for systick exception
void SysTick_Handler(void)
{
  timeinms++;
}

__STATIC_FORCEINLINE void configure_led()
{
  // function 5 = SIO 
  IO_BANK0->GPIO25_CTRL = 0x05;
  PADS_BANK0->GPIO25 = 0x34;
  // enable output
  SIO->GPIO_OE_SET = 0x01U << 25;
}

__STATIC_FORCEINLINE void turn_led_on()
{
  SIO->GPIO_OUT_SET = 0x01U << 25;
}

__STATIC_FORCEINLINE void turn_led_off()
{
  SIO->GPIO_OUT_CLR = 0x01U << 25;
}

__STATIC_FORCEINLINE void flip_led()
{
  SIO->GPIO_OUT_XOR = 0x01U << 25;
}

int main(void) 
{

  configure_led();
  turn_led_on();
  
  while (1) {
    for (int i = 0; i < 1000000; i++) __NOP();
    flip_led();
  }

  return 0;
}
