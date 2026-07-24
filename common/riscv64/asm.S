/*****************************************************************************
 * asm.S: riscv64 utility macros
 *****************************************************************************
 * Copyright (C) 2025 x264 project
 *
 * Authors: Qian Jiayan <qianjiayan.1@bytedance.com>
 *          Deng Zewen <deng.zewen@zte.com.cn>
 *          Huang Shangcheng <huang.shangcheng@zte.com.cn>
 *          Xing Ziyue <xing.ziyue@zte.com.cn>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02111, USA.
 *
 * This program is also available under a commercial proprietary license.
 * For more information, contact us at licensing@x264.com.
 *****************************************************************************/

#include "config.h"

#define GLUE(a, b) a ## b
#define JOIN(a, b) GLUE(a, b)

#ifdef PREFIX
#   define BASE _x264_
#   define SYM_PREFIX _
#else
#   define BASE x264_
#   define SYM_PREFIX
#endif

#ifdef BIT_DEPTH
#   define EXTERN_ASM JOIN(JOIN(BASE, BIT_DEPTH), _)
#else
#   define EXTERN_ASM BASE
#endif

#define X(s) JOIN(EXTERN_ASM, s)
#define X264(s) JOIN(BASE, s)
#define EXT(s) JOIN(SYM_PREFIX, s)

#ifdef __ELF__
# define ELF
#else
# define ELF #
#endif

#ifdef __MACH__
#   define MACH
#else
#   define MACH #
#endif

#if HAVE_AS_FUNC
# define FUNC
#else
# define FUNC #
#endif

.macro arch ext:req, more:vararg
    .option arch, +\ext
    .ifnb \more
        arch \more
    .endif
.endm

.macro function name, export=1, ext=
    .text
    .align  2
    .option push
    .ifnb \ext
        arch \ext
    .endif
    .if \export == 1
        .global EXTERN_ASM\name
        ELF .hidden EXTERN_ASM\name
        ELF .type EXTERN_ASM\name, %function
        FUNC .func EXTERN_ASM\name
        EXTERN_ASM\name:
    .else
        ELF .hidden \name
        ELF .type \name, %function
        FUNC .func \name
        \name:
    .endif

    .macro endfunc
    .if \export
        ELF .size EXTERN_ASM\name, . - EXTERN_ASM\name
    .else
        ELF .size \name, . - \name
    .endif
        .option pop 
        FUNC .endfunc
        .purgem endfunc
    .endm
.endm

