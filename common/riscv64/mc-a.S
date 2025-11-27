/*****************************************************************************
 * mc-a.S: riscv MC
 *****************************************************************************
 * Copyright (C) 2009-2025 x264 project
 *
 * Authors: Niklas Haas <nand@haasn.dev>
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

#include "asm.S"

function pixel_avg2_rvv256, ext=v, export=1
    vsetvli zero, a5, e8, m1, ta, ma
1:
    vle8.v v0, (a2)
    add a2, a2, a4
    vle8.v v1, (a3)
    add a3, a3, a4
    vaaddu.vv v0, v0, v1
    vse8.v v0, (a0)
    add a0, a0, a1
    addi a6, a6, -1
    bnez a6, 1b
    ret
endfunc
