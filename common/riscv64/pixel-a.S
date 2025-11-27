/*****************************************************************************
 * pixel.S: riscv pixel metrics
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

// writes output to `a`, clobbers `tmp`
.macro VABDU.vv a, b, tmp
    vminu.vv  \tmp, \a, \b
    vmaxu.vv  \a, \a, \b
    vsub.vv   \a, \a, \tmp
.endm

.macro SAD_FUNC w, h
function pixel_sad_\w\()x\h\()_rvv256, ext=v, export=1
    vsetivli x0, \w, e16, m1, ta, ma
    vmv.v.i v0, 0
    vsetvli x0, x0, e8, mf2, ta, ma
    li t0, \h
1:
    vle8.v v2, (a0)
    add a0, a0, a1
    vle8.v v4, (a2)
    add a2, a2, a3
    VABDU.vv v2, v4, v6
    vwaddu.wv v0, v0, v2
    addi t0, t0, -1
    bnez t0, 1b
    vsetvli x0, x0, e16, m1, ta, ma
    vmv.v.i v2, 0
    vredsum.vs v2, v0, v2
    vmv.x.s a0, v2
    li t0, 0xFFFF
    and a0, a0, t0
    ret
endfunc
.endm

.macro SAD_X_FUNC x, w, h
function pixel_sad_x\x\()_\w\()x\h\()_rvv256, ext=v, export=1
    vsetivli x0, \w, e16, m1, ta, ma
    vmv.v.i v0, 0
    vmv.v.i v2, 0
    vmv.v.i v4, 0
.if \x == 4
    vmv.v.i v6, 0
.endif
    vsetvli x0, x0, e8, mf2, ta, ma
    li t0, \h
1:
    vle8.v v8,  (a0)
    vle8.v v9,  (a1)
    vle8.v v10, (a2)
    vle8.v v11, (a3)
.if \x == 4
    vle8.v v12, (a4)
    add a0, a0, a5
    add a1, a1, a5
    add a2, a2, a5
    add a3, a3, a5
    add a4, a4, a5
.else
    add a0, a0, a4
    add a1, a1, a4
    add a2, a2, a4
    add a3, a3, a4
.endif
    VABDU.vv v9,  v8, v13
    VABDU.vv v10, v8, v13
    VABDU.vv v11, v8, v13
    vwaddu.wv v0, v0, v9
    vwaddu.wv v2, v2, v10
    vwaddu.wv v4, v4, v11
.if \x == 4
    VABDU.vv v12, v8, v13
    vwaddu.wv v6, v6, v12
.endif
    addi t0, t0, -1
    bnez t0, 1b

    vsetvli x0, x0, e16, m1, ta, ma
    vmv.v.i v8, 0
    vredsum.vs v0, v0, v8
    vredsum.vs v2, v2, v8
    vredsum.vs v4, v4, v8
.if \x == 4
    vredsum.vs v6, v6, v8
.endif
    li t0, 0xFFFF
    vmv.x.s a0, v0
    vmv.x.s a1, v2
    vmv.x.s a2, v4
    and a0, a0, t0
    and a1, a1, t0
    and a2, a2, t0
.if \x == 4
    vmv.x.s a3, v6
    and a3, a3, t0
.endif
.if \x == 4
    sw a0,  0(a6)
    sw a1,  4(a6)
    sw a2,  8(a6)
    sw a3, 12(a6)
.else
    sw a0,  0(a5)
    sw a1,  4(a5)
    sw a2,  8(a5)
.endif
    ret
endfunc
.endm

.macro SSD_FUNC w, h
function pixel_ssd_\w\()x\h\()_rvv256, ext=v, export=1
    vsetivli x0, \w, e32, m2, ta, ma
    vmv.v.i v0, 0
    li t0, \h
1:
    vsetvli x0, x0, e8, mf2, ta, ma
    vle8.v v6, (a0)
    add a0, a0, a1
    vle8.v v8, (a2)
    add a2, a2, a3
    vwsubu.vv v4, v6, v8
    vsetvli x0, x0, e16, m1, ta, ma
    vmul.vv v4, v4, v4
    vwaddu.wv v0, v0, v4
    addi t0, t0, -1
    bnez t0, 1b
    vsetvli x0, x0, e32, m2, ta, ma
    vmv.v.i v4, 0
    vredsum.vs v4, v0, v4
    vmv.x.s a0, v4
    ret
endfunc
.endm

.macro VAR_FUNC w, h
function pixel_var_\w\()x\h\()_rvv256, ext=v, export=1
    vsetivli x0, \w, e32, m2, ta, ma
    vmv.v.i v0, 0
    vsetvli x0, x0, e16, m1, ta, ma
    vmv.v.i v4, 0
    li t0, \h
1:
    vle8.v v8, (a0)
    add a0, a0, a1
    vzext.vf2 v6, v8
    vadd.vv v4, v4, v6
    vwmaccu.vv v0, v6, v6
    addi t0, t0, -1
    bnez t0, 1b
    vmv.v.i v6, 0
    vredsum.vs v6, v4, v6
    vmv.x.s a0, v6
    vsetvli x0, x0, e32, m2, ta, ma
    vmv.v.i v4, 0
    vredsum.vs v4, v0, v4
    vmv.x.s a1, v4
    slli a1, a1, 32
    li t0, 0xFFFFFFFF
    and a0, a0, t0
    or a0, a0, a1
    ret
endfunc
.endm

SAD_FUNC  4,  4
SAD_FUNC  4,  8
SAD_FUNC  4,  16
SAD_FUNC  8,  4
SAD_FUNC  8,  8
SAD_FUNC  8,  16
SAD_FUNC  16, 8
SAD_FUNC  16, 16

SAD_X_FUNC  3, 4,  4
SAD_X_FUNC  3, 4,  8
SAD_X_FUNC  3, 8,  4
SAD_X_FUNC  3, 8,  8
SAD_X_FUNC  3, 8,  16
SAD_X_FUNC  3, 16, 8
SAD_X_FUNC  3, 16, 16

SAD_X_FUNC  4, 4,  4
SAD_X_FUNC  4, 4,  8
SAD_X_FUNC  4, 8,  4
SAD_X_FUNC  4, 8,  8
SAD_X_FUNC  4, 8,  16
SAD_X_FUNC  4, 16, 8
SAD_X_FUNC  4, 16, 16

SSD_FUNC  4,  4
SSD_FUNC  4,  8
SSD_FUNC  4,  16
SSD_FUNC  8,  4
SSD_FUNC  8,  8
SSD_FUNC  8,  16
SSD_FUNC  16, 8
SSD_FUNC  16, 16

VAR_FUNC  8,  8
VAR_FUNC  8, 16
VAR_FUNC 16, 16
