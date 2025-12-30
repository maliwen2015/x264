/*****************************************************************************
 * mc-c.c: riscv64 motion compensation
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

#include "common/common.h"
#include "mc.h"

#define x264_pixel_avg_16x16_rvv x264_template(pixel_avg_16x16_rvv)
void x264_pixel_avg_16x16_rvv( pixel *, intptr_t, pixel *, intptr_t, pixel *, intptr_t, int );
#define x264_pixel_avg_16x8_rvv x264_template(pixel_avg_16x8_rvv)
void x264_pixel_avg_16x8_rvv ( pixel *, intptr_t, pixel *, intptr_t, pixel *, intptr_t, int );
#define x264_pixel_avg_8x16_rvv x264_template(pixel_avg_8x16_rvv)
void x264_pixel_avg_8x16_rvv ( pixel *, intptr_t, pixel *, intptr_t, pixel *, intptr_t, int );
#define x264_pixel_avg_8x8_rvv x264_template(pixel_avg_8x8_rvv)
void x264_pixel_avg_8x8_rvv  ( pixel *, intptr_t, pixel *, intptr_t, pixel *, intptr_t, int );
#define x264_pixel_avg_8x4_rvv x264_template(pixel_avg_8x4_rvv)
void x264_pixel_avg_8x4_rvv  ( pixel *, intptr_t, pixel *, intptr_t, pixel *, intptr_t, int );
#define x264_pixel_avg_4x16_rvv x264_template(pixel_avg_4x16_rvv)
void x264_pixel_avg_4x16_rvv ( pixel *, intptr_t, pixel *, intptr_t, pixel *, intptr_t, int );
#define x264_pixel_avg_4x8_rvv x264_template(pixel_avg_4x8_rvv)
void x264_pixel_avg_4x8_rvv  ( pixel *, intptr_t, pixel *, intptr_t, pixel *, intptr_t, int );
#define x264_pixel_avg_4x4_rvv x264_template(pixel_avg_4x4_rvv)
void x264_pixel_avg_4x4_rvv  ( pixel *, intptr_t, pixel *, intptr_t, pixel *, intptr_t, int );
#define x264_pixel_avg_4x2_rvv x264_template(pixel_avg_4x2_rvv)
void x264_pixel_avg_4x2_rvv  ( pixel *, intptr_t, pixel *, intptr_t, pixel *, intptr_t, int );


#define x264_pixel_avg2_w4_rvv x264_template(pixel_avg2_w4_rvv)
void x264_pixel_avg2_w4_rvv ( pixel *, intptr_t, pixel *, intptr_t, pixel *, int );
#define x264_pixel_avg2_w8_rvv x264_template(pixel_avg2_w8_rvv)
void x264_pixel_avg2_w8_rvv ( pixel *, intptr_t, pixel *, intptr_t, pixel *, int );
#define x264_pixel_avg2_w16_rvv x264_template(pixel_avg2_w16_rvv)
void x264_pixel_avg2_w16_rvv( pixel *, intptr_t, pixel *, intptr_t, pixel *, int );
#define x264_pixel_avg2_w20_rvv x264_template(pixel_avg2_w20_rvv)
void x264_pixel_avg2_w20_rvv( pixel *, intptr_t, pixel *, intptr_t, pixel *, int );


static void (* const pixel_avg_wtab_rvv[6])( pixel *, intptr_t, pixel *, intptr_t, pixel *, int ) =
{
    NULL,
    x264_pixel_avg2_w4_rvv,
    x264_pixel_avg2_w8_rvv,
    x264_pixel_avg2_w16_rvv,   // no slower than w12, so no point in a separate function
    x264_pixel_avg2_w16_rvv,
    x264_pixel_avg2_w20_rvv,
};


static void mc_copy( pixel *src, intptr_t i_src_stride, pixel *dst, intptr_t i_dst_stride, int i_width, int i_height )
{
    for( int y = 0; y < i_height; y++ )
    {
        memcpy( dst, src, i_width * SIZEOF_PIXEL );

        src += i_src_stride;
        dst += i_dst_stride;
    }
}

static void mc_luma_rvv( pixel *dst,    intptr_t i_dst_stride,
                          pixel *src[4], intptr_t i_src_stride,
                          int mvx, int mvy,
                          int i_width, int i_height, const x264_weight_t *weight )
{
    int qpel_idx = ((mvy&3)<<2) + (mvx&3);
    intptr_t offset = (mvy>>2)*i_src_stride + (mvx>>2);
    pixel *src1 = src[x264_hpel_ref0[qpel_idx]] + offset;
    if( (mvy&3) == 3 )             // explicit if() to force conditional add
        src1 += i_src_stride;

    if( qpel_idx & 5 ) /* qpel interpolation needed */
    {
        pixel *src2 = src[x264_hpel_ref1[qpel_idx]] + offset + ((mvx&3) == 3);
        pixel_avg_wtab_rvv[i_width>>2](
                dst, i_dst_stride, src1, i_src_stride,
                src2, i_height );
        if( weight->weightfn )
            weight->weightfn[i_width>>2]( dst, i_dst_stride, dst, i_dst_stride, weight, i_height );
    }
    else if( weight->weightfn )
        weight->weightfn[i_width>>2]( dst, i_dst_stride, src1, i_src_stride, weight, i_height );
    else
        mc_copy( src1, i_src_stride, dst, i_dst_stride, i_width, i_height );

}

static pixel *get_ref_rvv( pixel *dst,   intptr_t *i_dst_stride,
                              pixel *src[4], intptr_t i_src_stride,
                              int mvx, int mvy,
                              int i_width, int i_height, const x264_weight_t *weight )
{
    int qpel_idx = ((mvy&3)<<2) + (mvx&3);
    intptr_t offset = (mvy>>2)*i_src_stride + (mvx>>2);
    pixel *src1 = src[x264_hpel_ref0[qpel_idx]] + offset;
    if( (mvy&3) == 3 )             // explicit if() to force conditional add
        src1 += i_src_stride;

    if( qpel_idx & 5 ) /* qpel interpolation needed */
    {
        pixel *src2 = src[x264_hpel_ref1[qpel_idx]] + offset + ((mvx&3) == 3);
        pixel_avg_wtab_rvv[i_width>>2](
                dst, *i_dst_stride, src1, i_src_stride,
                src2, i_height );
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

void x264_mc_init_rvv( uint32_t cpu, x264_mc_functions_t *pf )
{
#if !HIGH_BIT_DEPTH
    if( cpu&X264_CPU_RVV )
    {
        pf->avg[PIXEL_16x16] = x264_pixel_avg_16x16_rvv;
        pf->avg[PIXEL_16x8]  = x264_pixel_avg_16x8_rvv;
        pf->avg[PIXEL_8x16]  = x264_pixel_avg_8x16_rvv;
        pf->avg[PIXEL_8x8]   = x264_pixel_avg_8x8_rvv;
        pf->avg[PIXEL_8x4]   = x264_pixel_avg_8x4_rvv;
        pf->avg[PIXEL_4x16]  = x264_pixel_avg_4x16_rvv;
        pf->avg[PIXEL_4x8]   = x264_pixel_avg_4x8_rvv;
        pf->avg[PIXEL_4x4]   = x264_pixel_avg_4x4_rvv;
        pf->avg[PIXEL_4x2]   = x264_pixel_avg_4x2_rvv;

        pf->mc_luma = mc_luma_rvv;
        pf->get_ref = get_ref_rvv;
    }
#endif // !HIGH_BIT_DEPTH
}
