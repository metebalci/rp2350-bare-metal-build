// SPDX-FileCopyrightText: 2024 Mete Balci
//
// SPDX-License-Identifier: GPL-3.0-or-later

#include <sys/stat.h>
#include <unistd.h>

#include "RP2350.h"
#include "core_cm33.h"

/* these methods are not defined anywhere even in nosys
 * so they have to be implemented */

int _close(int file) 
{
  return 0;
}

int _lseek(int file, char* ptr, int dir)
{
  return 0;
}

int _read(int file, char* ptr, int len)
{
  return 0;
}

int _write(int file, char* ptr, int len)
{
  if (file == STDOUT_FILENO)
  {
    for (int i = 0; i < len; i++)
    {
      ITM_SendChar(*ptr++);
    }
    return len;
  }
  return 0;
}

int _isatty(int fd)
{
  return 0;
}

int _fstat(int fd, struct stat *statbuf)
{
  return -1;
}
