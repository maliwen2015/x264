/*****************************************************************************
 * mc-a.S: riscv64 motion compensation
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

#include "asm.S"
#if BIT_DEPTH == 8

// void pixel_avg( pixel *dst,  intptr_t dst_stride,
//                 pixel *src1, intptr_t src1_stride,
//                 pixel *src2, intptr_t src2_stride, int weight );
.macro PIXEL_AVG_RVV w h
function pixel_avg_\w\()x\h\()_rvv, export=1, ext=v
    csrwi vxrm, 0
    addi       t0, a6, -32
    li         t1, \h
    bnez       t0, pixel_avg_weight_w\w\()_rvv
    j       pixel_avg_w\w\()_rvv
endfunc
.endm
PIXEL_AVG_RVV 16, 16
PIXEL_AVG_RVV 16,  8
PIXEL_AVG_RVV  8, 16
PIXEL_AVG_RVV  8,  8
PIXEL_AVG_RVV  8,  4
PIXEL_AVG_RVV  4, 16
PIXEL_AVG_RVV  4,  8
PIXEL_AVG_RVV  4,  4
PIXEL_AVG_RVV  4,  2

function pixel_avg_weight_w4_rvv, export=0, ext=v
    li   t0, 64
    sub  a7, t0, a6
    csrwi  vxrm, 0
    vsetivli    zero, 4, e8, mf4, ta, ma
    vmv.v.x v30, a6
    vmv.v.x v31, a7
1:
    addi  t1, t1, -2

    vle8.v    v1, (a2)
    add       a2, a2, a3
    vle8.v    v2, (a4) 
    add       a4, a4, a5
    vwmulsu.vv v16, v30, v1
    vwmaccsu.vv v16, v31, v2

    vle8.v    v3, (a2)
    add       a2, a2, a3
    vle8.v    v4, (a4) 
    add       a4, a4, a5
    vwmulsu.vv v17, v30, v3
    vwmaccsu.vv v17, v31, v4

    vsetivli    zero, 4, e16, mf2, ta, ma
    vmax.vx   v16, v16, zero
    vmax.vx   v17, v17, zero

    vsetivli    zero, 4, e8, mf4, ta, ma
    vnclipu.wi v5, v16, 6
    vnclipu.wi v6, v17, 6

    vse8.v    v5, (a0)
    add       a0, a0, a1
    vse8.v    v6, (a0)
    add       a0, a0, a1

    bgt       t1, zero, 1b
    ret
endfunc

function pixel_avg_weight_w8_rvv, export=0, ext=v
    li   t0, 64
    sub  a7, t0, a6

    csrwi  vxrm, 0
    vsetivli    zero, 8, e8, mf2, ta, ma
    vmv.v.x v30, a6
    vmv.v.x v31, a7
1:
    addi  t1, t1, -4
    
    vle8.v    v1, (a2)
    add       a2, a2, a3
    vle8.v    v2, (a4) 
    add       a4, a4, a5
    vwmulsu.vv  v16, v30, v1
    vwmaccsu.vv v16, v31, v2


    vle8.v    v3, (a2)
    add       a2, a2, a3
    vle8.v    v4, (a4) 
    add       a4, a4, a5
    vwmulsu.vv  v17, v30, v3
    vwmaccsu.vv v17, v31, v4

    vle8.v    v5, (a2)
    add       a2, a2, a3
    vle8.v    v6, (a4) 
    add       a4, a4, a5
    vwmulsu.vv  v18, v30, v5
    vwmaccsu.vv v18, v31, v6

    vle8.v    v7, (a2)
    add       a2, a2, a3
    vle8.v    v8, (a4) 
    add       a4, a4, a5
    vwmulsu.vv  v19, v30, v7
    vwmaccsu.vv v19, v31, v8

    vsetivli    zero, 8, e16, m1, ta, ma
    vmax.vx   v16, v16, zero
    vmax.vx   v17, v17, zero
    vmax.vx   v18, v18, zero
    vmax.vx   v19, v19, zero

    vsetivli    zero, 8, e8, mf2, ta, ma
    vnclipu.wi v1, v16, 6
    vnclipu.wi v2, v17, 6
    vnclipu.wi v3, v18, 6
    vnclipu.wi v4, v19, 6

    vse8.v    v1, (a0)
    add       a0, a0, a1
    vse8.v    v2, (a0)
    add       a0, a0, a1
    vse8.v    v3, (a0)
    add       a0, a0, a1
    vse8.v    v4, (a0)
    add       a0, a0, a1

    bgt       t1, zero, 1b
    ret
endfunc

function pixel_avg_weight_w16_rvv, export=0, ext=v
    li   t0, 64
    sub  a7, t0, a6

    csrwi  vxrm, 0
    vsetivli    zero, 16, e8, m1, ta, ma
    vmv.v.x v30, a6
    vmv.v.x v31, a7
1:
    addi  t1, t1, -2

    vle8.v    v1, (a2)
    add       a2, a2, a3
    vle8.v    v2, (a4) 
    add       a4, a4, a5
    vwmulsu.vv  v16, v30, v1
    vwmaccsu.vv v16, v31, v2

    vle8.v    v3, (a2)
    add       a2, a2, a3
    vle8.v    v4, (a4) 
    add       a4, a4, a5
    vwmulsu.vv  v18, v30, v3
    vwmaccsu.vv v18, v31, v4

    vsetivli    zero, 16, e16, m2, ta, ma
    vmax.vx   v16, v16, zero
    vmax.vx   v18, v18, zero

    vsetivli    zero, 16, e8, m1, ta, ma
    vnclipu.wi v5, v16, 6
    vnclipu.wi v6, v18, 6

    vse8.v    v5, (a0)
    add       a0, a0, a1
    vse8.v    v6, (a0)
    add       a0, a0, a1

    bgt       t1, zero, 1b
    ret
endfunc

function pixel_avg_w4_rvv, export=0, ext=v
    csrwi  vxrm, 0
1:
    addi  t1, t1, -2
    vsetivli    zero, 4, e8, mf4, ta, ma
    vle8.v    v1, (a2)
    add       a2, a2, a3
    vle8.v    v2, (a4) 
    add       a4, a4, a5
    vaaddu.vv   v1, v1, v2
    vle8.v    v3, (a2)
    add       a2, a2, a3
    vle8.v    v4, (a4) 
    add       a4, a4, a5
    vaaddu.vv   v3, v3, v4

    vse8.v    v1, (a0)
    add       a0, a0, a1
    vse8.v    v3, (a0)
    add       a0, a0, a1
    bgt       t1, zero, 1b
    ret
endfunc

function pixel_avg_w8_rvv, export=0, ext=v
    csrwi  vxrm, 0
1:
    addi  t1, t1, -4
    vsetivli    zero, 8, e8, mf2, ta, ma
    vle8.v    v1, (a2)
    add       a2, a2, a3
    vle8.v    v2, (a4) 
    add       a4, a4, a5
    vaaddu.vv   v1, v1, v2

    vle8.v    v3, (a2)
    add       a2, a2, a3
    vle8.v    v4, (a4) 
    add       a4, a4, a5
    vaaddu.vv   v3, v3, v4

    vle8.v    v5, (a2)
    add       a2, a2, a3
    vle8.v    v6, (a4) 
    add       a4, a4, a5
    vaaddu.vv   v5, v5, v6

    vle8.v    v7, (a2)
    add       a2, a2, a3
    vle8.v    v8, (a4) 
    add       a4, a4, a5
    vaaddu.vv   v7, v7, v8

    vse8.v    v1, (a0)
    add       a0, a0, a1
    vse8.v    v3, (a0)
    add       a0, a0, a1
    vse8.v    v5, (a0)
    add       a0, a0, a1
    vse8.v    v7, (a0)
    add       a0, a0, a1


    bgt       t1, zero, 1b
    ret
endfunc

function pixel_avg_w16_rvv, export=0, ext=v
    csrwi  vxrm, 0
1:
    addi  t1, t1, -4
    vsetivli    zero, 16, e8, m1, ta, ma
    vle8.v    v1, (a2)
    add       a2, a2, a3
    vle8.v    v2, (a4) 
    add       a4, a4, a5
    vaaddu.vv   v1, v1, v2

    vle8.v    v3, (a2)
    add       a2, a2, a3
    vle8.v    v4, (a4) 
    add       a4, a4, a5
    vaaddu.vv   v3, v3, v4

    vle8.v    v5, (a2)
    add       a2, a2, a3
    vle8.v    v6, (a4) 
    add       a4, a4, a5
    vaaddu.vv   v5, v5, v6

    vle8.v    v7, (a2)
    add       a2, a2, a3
    vle8.v    v8, (a4) 
    add       a4, a4, a5
    vaaddu.vv   v7, v7, v8

    vse8.v    v1, (a0)
    add       a0, a0, a1
    vse8.v    v3, (a0)
    add       a0, a0, a1
    vse8.v    v5, (a0)
    add       a0, a0, a1
    vse8.v    v7, (a0)
    add       a0, a0, a1


    bgt       t1, zero, 1b
    ret
endfunc

function pixel_avg2_w4_rvv, export=1, ext=v
    csrwi  vxrm, 0
1:
    addi  a5, a5, -2
    vsetivli    zero, 4, e8, mf4, ta, ma
    vle8.v    v1, (a2)
    add       a2, a2, a3
    vle8.v    v2, (a4) 
    add       a4, a4, a3
    vaaddu.vv   v1, v1, v2
    vle8.v    v3, (a2)
    add       a2, a2, a3
    vle8.v    v4, (a4) 
    add       a4, a4, a3
    vaaddu.vv   v3, v3, v4

    vse8.v    v1, (a0)
    add       a0, a0, a1
    vse8.v    v3, (a0)
    add       a0, a0, a1
    bgt       a5, zero, 1b
    ret
endfunc

function pixel_avg2_w8_rvv, export=1, ext=v
    csrwi  vxrm, 0
1:
    addi  a5, a5, -2
    vsetivli    zero, 8, e8, mf2, ta, ma
    vle8.v    v1, (a2)
    add       a2, a2, a3
    vle8.v    v2, (a4) 
    add       a4, a4, a3
    vaaddu.vv   v1, v1, v2
    vle8.v    v3, (a2)
    add       a2, a2, a3
    vle8.v    v4, (a4) 
    add       a4, a4, a3
    vaaddu.vv   v3, v3, v4

    vse8.v    v1, (a0)
    add       a0, a0, a1
    vse8.v    v3, (a0)
    add       a0, a0, a1
    bgt       a5, zero, 1b
    ret
endfunc

function pixel_avg2_w16_rvv, export=1, ext=v
    csrwi  vxrm, 0
1:
    addi  a5, a5, -2
    vsetivli    zero, 16, e8, m1, ta, ma
    vle8.v    v1, (a2)
    add       a2, a2, a3
    vle8.v    v2, (a4) 
    add       a4, a4, a3
    vaaddu.vv   v1, v1, v2
    vle8.v    v3, (a2)
    add       a2, a2, a3
    vle8.v    v4, (a4) 
    add       a4, a4, a3
    vaaddu.vv   v3, v3, v4

    vse8.v    v1, (a0)
    add       a0, a0, a1
    vse8.v    v3, (a0)
    add       a0, a0, a1
    bgt       a5, zero, 1b
    ret
endfunc

function pixel_avg2_w20_rvv, export=1, ext=v
    csrwi  vxrm, 0
1:
    addi  a5, a5, -2
    vsetivli    zero, 20, e8, m2, ta, ma
    vle8.v    v0, (a2)
    add       a2, a2, a3
    vle8.v    v2, (a4) 
    add       a4, a4, a3
    vaaddu.vv   v0, v0, v2
    vle8.v    v4, (a2)
    add       a2, a2, a3
    vle8.v    v6, (a4) 
    add       a4, a4, a3
    vaaddu.vv   v4, v4, v6

    vse8.v    v0, (a0)
    add       a0, a0, a1
    vse8.v    v4, (a0)
    add       a0, a0, a1
    bgt       a5, zero, 1b
    ret
endfunc

#endif // BIT_DEPTH == 8

