// ----------------------------------------------------------------------------
// Copyright (c) 2020-2024 RISC-V Steel contributors
//
// This work is licensed under the MIT License, see LICENSE file for details.
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

#ifndef __LIBSTEEL_GLOBALS__
#define __LIBSTEEL_GLOBALS__

#include <stdbool.h>
#include <stdint.h>

#ifndef __ASM
#define __ASM __asm
#endif

#ifndef __ASM_VOLATILE
#define __ASM_VOLATILE __asm volatile
#endif

#ifndef __STATIC_FORCEINLINE
#define __STATIC_FORCEINLINE __attribute__((always_inline)) static inline
#endif

#ifndef __NO_RETURN
#define __NO_RETURN __attribute__((__noreturn__))
#endif

#ifndef __USED
#define __USED __attribute__((used))
#endif

#ifndef __UNUSED
#define __UNUSED __attribute__((unused))
#endif

#ifndef __WEAK
#define __WEAK __attribute__((weak))
#endif

#ifndef __NAKED
#define __NAKED __attribute__((naked))
#endif

#ifndef __ALIAS
#define __ALIAS(weak_alias) __attribute__((alias(weak_alias)))
#endif

#ifndef __WEAK_ALIAS
#define __WEAK_ALIAS(weak_alias) __attribute__((weak, alias(weak_alias)))
#endif

#ifndef __ALIGNED_PACKED
#define __ALIGNED_PACKED(align) __attribute__((packed, aligned(align)))
#endif

#ifndef __PACKED
#define __PACKED __attribute__((packed, aligned(1)))
#endif

#ifndef __PACKED_STRUCT
#define __PACKED_STRUCT struct __attribute__((packed, aligned(1)))
#endif

#ifndef __PACKED_UNION
#define __PACKED_UNION union __attribute__((packed, aligned(1)))
#endif

#ifndef __IRQ_M
#define __IRQ_M(vector) __attribute__((interrupt("machine"))) void vector(void)
#endif

#ifndef __IRQ_M_WEAK
#define __IRQ_M_WEAK(vector) __attribute__((weak, interrupt("machine"))) void vector(void)
#endif

#ifndef __IRQ_M_WEAK_DEFAULT
#define __IRQ_M_WEAK_DEFAULT(vector) __WEAK_ALIAS("default_handler") void vector(void)
#endif

#define __NOP() __ASM_VOLATILE("nop")

#define __ECALL() __ASM_VOLATILE("ecall")

#define __EBREAK() __ASM_VOLATILE("ebreak")

#define SET_FLAG(REG, FLAG) ((REG) |= (FLAG))

#define CLR_FLAG(REG, FLAG) ((REG) &= ~(FLAG))

#define INV_FLAG(REG, FLAG) ((REG) ^= (FLAG))

#define SET_BIT(REG, BIT) ((REG) |= (1 << (BIT)))

#define CLR_BIT(REG, BIT) ((REG) &= ~(1 << (BIT)))

#define INV_BIT(REG, BIT) ((REG) ^= (1 << (BIT)))

#define READ_BIT(REG, BIT) (((REG) >> BIT) & 1)

#define MODIFY_REG(REG, CLEARMASK, SETMASK) ((REG) = (REG & (~(CLEARMASK))) | (SETMASK))

#define NUMBER_OF(a) (sizeof a / sizeof a[0])

#endif // __LIBSTEEL_GLOBALS__
