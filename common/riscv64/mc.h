/*****************************************************************************
 * mc.h: riscv64 motion compensation
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

#ifndef X264_RISCV_MC_H
#define X264_RISCV_MC_H

#define x264_mc_init_rvv x264_template(mc_init_rvv)
void x264_mc_init_rvv( uint32_t cpu, x264_mc_functions_t *pf );

#endif
