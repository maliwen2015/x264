/*****************************************************************************
 * mc-c.c: aarch64 motion compensation
 *****************************************************************************
 * Copyright (C) 2009-2025 x264 project
 *
 * Authors: David Conrad <lessen42@gmail.com>
 *          Janne Grunau <janne-x264@jannau.net>
 *          Niklas Haas <nand@haasn.dev>
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

#include "common/common.h"
#include "mc.h"

#define x264_pixel_avg2_rvv256 x264_template(pixel_avg2_rvv256)
void x264_pixel_avg2_rvv256 ( pixel *, intptr_t, pixel *, pixel *, intptr_t, int, int );

static pixel *get_ref_rvv256( pixel *dst,   intptr_t *i_dst_stride,
                           pixel *src[4], intptr_t i_src_stride,
                           int mvx, int mvy,
                           int i_width, int i_height, const x264_weight_t *weight )
{
    int qpel_idx = ((mvy&3)<<2) + (mvx&3);
    intptr_t offset = (mvy>>2)*i_src_stride + (mvx>>2);
    pixel *src1 = src[x264_hpel_ref0[qpel_idx]] + offset + ((mvy&3) == 3) * i_src_stride;
    if( qpel_idx & 5 ) /* qpel interpolation needed */
    {
        pixel *src2 = src[x264_hpel_ref1[qpel_idx]] + offset + ((mvx&3) == 3);
        x264_pixel_avg2_rvv256( dst, *i_dst_stride, src1, src2, i_src_stride,
                                i_width, i_height );
        if( weight->weightfn )
            weight->weightfn[i_width>>2]( dst, *i_dst_stride, dst, *i_dst_stride, weight, i_height );
        return dst;
    }
    else if( weight->weightfn )
    {
        weight->weightfn[i_width>>2]( dst, *i_dst_stride, src1, i_src_stride, weight, i_height );
        return dst;
    }
    else
    {
        *i_dst_stride = i_src_stride;
        return src1;
    }
}


void x264_mc_init_riscv64( uint32_t cpu, x264_mc_functions_t *pf )
{

    if( !( cpu&X264_CPU_RVV256 ) )
        return;

    pf->get_ref = get_ref_rvv256;
}
