/*****************************************************************************
 * pixel.h: aarch64 pixel metrics
 *****************************************************************************
 * Copyright (C) 2009-2025 x264 project
 *
 * Authors: David Conrad <lessen42@gmail.com>
 *          Janne Grunau <janne-x264@jannau.net>
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

#ifndef X264_RISCV_PIXEL_H
#define X264_RISCV_PIXEL_H

#define x264_pixel_sad_16x16_rvv256 x264_template(pixel_sad_16x16_rvv256)
#define x264_pixel_sad_16x8_rvv256 x264_template(pixel_sad_16x8_rvv256)
#define x264_pixel_sad_4x16_rvv256 x264_template(pixel_sad_4x16_rvv256)
#define x264_pixel_sad_4x4_rvv256 x264_template(pixel_sad_4x4_rvv256)
#define x264_pixel_sad_4x8_rvv256 x264_template(pixel_sad_4x8_rvv256)
#define x264_pixel_sad_8x16_rvv256 x264_template(pixel_sad_8x16_rvv256)
#define x264_pixel_sad_8x4_rvv256 x264_template(pixel_sad_8x4_rvv256)
#define x264_pixel_sad_8x8_rvv256 x264_template(pixel_sad_8x8_rvv256)

#define x264_pixel_sad_x3_16x16_rvv256 x264_template(pixel_sad_x3_16x16_rvv256)
#define x264_pixel_sad_x3_16x8_rvv256 x264_template(pixel_sad_x3_16x8_rvv256)
#define x264_pixel_sad_x3_4x4_rvv256 x264_template(pixel_sad_x3_4x4_rvv256)
#define x264_pixel_sad_x3_4x8_rvv256 x264_template(pixel_sad_x3_4x8_rvv256)
#define x264_pixel_sad_x3_8x16_rvv256 x264_template(pixel_sad_x3_8x16_rvv256)
#define x264_pixel_sad_x3_8x4_rvv256 x264_template(pixel_sad_x3_8x4_rvv256)
#define x264_pixel_sad_x3_8x8_rvv256 x264_template(pixel_sad_x3_8x8_rvv256)

#define x264_pixel_sad_x4_16x16_rvv256 x264_template(pixel_sad_x4_16x16_rvv256)
#define x264_pixel_sad_x4_16x8_rvv256 x264_template(pixel_sad_x4_16x8_rvv256)
#define x264_pixel_sad_x4_4x4_rvv256 x264_template(pixel_sad_x4_4x4_rvv256)
#define x264_pixel_sad_x4_4x8_rvv256 x264_template(pixel_sad_x4_4x8_rvv256)
#define x264_pixel_sad_x4_8x16_rvv256 x264_template(pixel_sad_x4_8x16_rvv256)
#define x264_pixel_sad_x4_8x4_rvv256 x264_template(pixel_sad_x4_8x4_rvv256)
#define x264_pixel_sad_x4_8x8_rvv256 x264_template(pixel_sad_x4_8x8_rvv256)

#define x264_pixel_ssd_16x16_rvv256 x264_template(pixel_ssd_16x16_rvv256)
#define x264_pixel_ssd_16x8_rvv256 x264_template(pixel_ssd_16x8_rvv256)
#define x264_pixel_ssd_4x16_rvv256 x264_template(pixel_ssd_4x16_rvv256)
#define x264_pixel_ssd_4x4_rvv256 x264_template(pixel_ssd_4x4_rvv256)
#define x264_pixel_ssd_4x8_rvv256 x264_template(pixel_ssd_4x8_rvv256)
#define x264_pixel_ssd_8x16_rvv256 x264_template(pixel_ssd_8x16_rvv256)
#define x264_pixel_ssd_8x4_rvv256 x264_template(pixel_ssd_8x4_rvv256)
#define x264_pixel_ssd_8x8_rvv256 x264_template(pixel_ssd_8x8_rvv256)

#define DECL_PIXELS( ret, name, suffix, args ) \
    ret x264_pixel_##name##_16x16_##suffix args;\
    ret x264_pixel_##name##_16x8_##suffix args;\
    ret x264_pixel_##name##_8x16_##suffix args;\
    ret x264_pixel_##name##_8x8_##suffix args;\
    ret x264_pixel_##name##_8x4_##suffix args;\
    ret x264_pixel_##name##_4x16_##suffix args;\
    ret x264_pixel_##name##_4x8_##suffix args;\
    ret x264_pixel_##name##_4x4_##suffix args;

#define DECL_X1( name, suffix ) \
    DECL_PIXELS( int, name, suffix, ( pixel *, intptr_t, pixel *, intptr_t ) )

#define DECL_X4( name, suffix ) \
    DECL_PIXELS( void, name##_x3, suffix, ( pixel *, pixel *, pixel *, pixel *, intptr_t, int * ) )\
    DECL_PIXELS( void, name##_x4, suffix, ( pixel *, pixel *, pixel *, pixel *, pixel *, intptr_t, int * ) )

DECL_X1( sad,  rvv256 )
DECL_X4( sad,  rvv256 )
DECL_X1( satd, rvv256 )
DECL_X1( ssd,  rvv256 )

#define x264_pixel_var_8x8_rvv256 x264_template(pixel_var_8x8_rvv256)
uint64_t x264_pixel_var_8x8_rvv256  ( pixel *, intptr_t );
#define x264_pixel_var_8x16_rvv256 x264_template(pixel_var_8x16_rvv256)
uint64_t x264_pixel_var_8x16_rvv256 ( pixel *, intptr_t );
#define x264_pixel_var_16x16_rvv256 x264_template(pixel_var_16x16_rvv256)
uint64_t x264_pixel_var_16x16_rvv256( pixel *, intptr_t );

#endif
