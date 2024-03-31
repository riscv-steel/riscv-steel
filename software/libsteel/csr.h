// ----------------------------------------------------------------------------
// Copyright (c) 2020-2024 RISC-V Steel contributors
//
// This work is licensed under the MIT License, see LICENSE file for details.
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

#ifndef __LIBSTEEL_CSR__
#define __LIBSTEEL_CSR__

#include "libsteel/globals.h"

#if __riscv_xlen != 32
#error "Unsupported XLEN"
#endif

// Address of the Machine Architecture ID CSR (MARCHID)
#define CSR_MARCHID 0xF12

// Address of the Machine Implementation ID CSR (MIMPID)
#define CSR_MIMPID 0xF13

// Address of the 32 lowest bits of the U-mode Cycle CSR (CYCLE)
#define CSR_CYCLE 0xC00

// Address of the 32 lowest bits of the U-mode Time CSR (TIME)
#define CSR_TIME 0xC01

// Address of the 32 lowest bits of the U-mode Instruction Retired Counter CSR (INSTRET)
#define CSR_INSTRET 0xC02

// Address of the 32 highest bits of the U-mode Cycle CSR (CYCLEH)
#define CSR_CYCLEH 0xC80

// Address of the 32 highest bits of the U-mode Time CSR (TIMEH)
#define CSR_TIMEH 0xC81

// Address of the 32 highest bits of the U-mode Instruction Retired Counter CSR (INSTRETH)
#define CSR_INSTRETH 0xC82

// Address of the 32 lowest bits of the Machine Status CSR (MSTATUS)
#define CSR_MSTATUS 0x300

// Address of the 32 highest bits of the Machine Status CSR (MSTATUSH)
#define CSR_MSTATUSH 0x310

// Address of the Machine Instruction Set Architecture CSR (MISA)
#define CSR_MISA 0x301

// Address of the Machine Interrupt Enable CSR (MIE)
#define CSR_MIE 0x304

// Address of the Machine Trap-Vector CSR (MTVEC)
#define CSR_MTVEC 0x305

// Address of the Machine Scratch CSR (MSCRATCH)
#define CSR_MSCRATCH 0x340

// Address of the Machine Exception Program Counter CSR (MEPC)
#define CSR_MEPC 0x341

// Address of the Machine Trap Cause CSR (MCAUSE)
#define CSR_MCAUSE 0x342

// Address of the Machine Trap Value CSR (MTVAL)
#define CSR_MTVAL 0x343

// Address of the Machine Interrupt Pending CSR (MIP)
#define CSR_MIP 0x344

// Address of the 32 lowest bits of the M-mode Cycle CSR (MCYCLE)
#define CSR_MCYCLE 0xB00

// Address of the 32 lowest bits of the M-mode Instruction Retired Counter CSR (MINSTRET)
#define CSR_MINSTRET 0xB02

// Address of the 32 highest bits of the M-mode Cycle CSR (MCYCLEH)
#define CSR_MCYCLEH 0xB80

// Address of the 32 highest bits of the M-mode Instruction Retired Counter CSR (MINSTRET)
#define CSR_MINSTRETH 0xB82

// Offset of the Machine Interrupt Enable (MIE) bit in the MSTATUS CSR
#define MSTATUS_MIE_OFFSET 3U

// Offset of the Machine Prior Interrupt Enable (MPIE) bit in the MSTATUS CSR
#define MSTATUS_MPIE_OFFSET 7U

// Bit mask used to read/set/clear the Machine Interrupt Enable (MIE) bit in the MSTATUS CSR
#define MSTATUS_MIE_MASK (1U << MSTATUS_MIE_OFFSET)

// Bit mask used to read/set/clear the Machine Priot Interrupt Enable (MPIE) bit in the MSTATUS CSR
#define MSTATUS_MPIE_MASK (1U << MSTATUS_MPIE_OFFSET)

// Bit mask used to read/set/clear the MODE field of the MTVEC CSR
#define MTVEC_MODE_MASK (0x0000_0003)

// Bit mask used to read/set/clear the base field of the MTVEC CSR
#define MTVEC_BASE_MASK (0xffff_fffc)

// Offset of the Machine Software Interrupt (MSI) bit in the Machine Interrupt Enable (MIE) and
// Machine Interrupt Pending (MIP) CSRs
#define MIP_MIE_OFFSET_MSI 3U

// Offset of the Machine Timer Interrupt (MTI) bit in the Machine Interrupt Enable (MIE) and
// Machine Interrupt Pending (MIP) CSRs
#define MIP_MIE_OFFSET_MTI 7U

// Offset of the Machine External Interrupt (MEI) bit in the Machine Interrupt Enable (MIE) and
// Machine Interrupt Pending (MIP) CSRs
#define MIP_MIE_OFFSET_MEI 11U

// Offset of the Supervisor Software Interrupt (SSI) bit in the Machine Interrupt Enable (MIE) and
// Machine Interrupt Pending (MIP) CSRs
#define MIP_MIE_OFFSET_SSI 1U

// Offset of the Supervisor Timer Interrupt (STI) bit in the Machine Interrupt Enable (MIE) and
// Machine Interrupt Pending (MIP) CSRs
#define MIP_MIE_OFFSET_STI 5U

// Offset of the Supervisor External Interrupt (SEI) bit in the Machine Interrupt Enable (MIE) and
// Machine Interrupt Pending (MIP) CSRs
#define MIP_MIE_OFFSET_SEI 9U

// Offset of RISC-V Steel Fast Interrupt 0 bit in the Machine Interrupt Enable (MIE) and
// Machine Interrupt Pending (MIP) CSRs
#define MIP_MIE_OFFSET_F0I 16U

// Offset of RISC-V Steel Fast Interrupt 1 bit in the Machine Interrupt Enable (MIE) and
// Machine Interrupt Pending (MIP) CSRs
#define MIP_MIE_OFFSET_F1I 17U

// Offset of RISC-V Steel Fast Interrupt 2 bit in the Machine Interrupt Enable (MIE) and
// Machine Interrupt Pending (MIP) CSRs
#define MIP_MIE_OFFSET_F2I 18U

// Offset of RISC-V Steel Fast Interrupt 3 bit in the Machine Interrupt Enable (MIE) and
// Machine Interrupt Pending (MIP) CSRs
#define MIP_MIE_OFFSET_F3I 19U

// Offset of RISC-V Steel Fast Interrupt 4 bit in the Machine Interrupt Enable (MIE) and
// Machine Interrupt Pending (MIP) CSRs
#define MIP_MIE_OFFSET_F4I 20U

// Offset of RISC-V Steel Fast Interrupt 5 bit in the Machine Interrupt Enable (MIE) and
// Machine Interrupt Pending (MIP) CSRs
#define MIP_MIE_OFFSET_F5I 21U

// Offset of RISC-V Steel Fast Interrupt 6 bit in the Machine Interrupt Enable (MIE) and
// Machine Interrupt Pending (MIP) CSRs
#define MIP_MIE_OFFSET_F6I 22U

// Offset of RISC-V Steel Fast Interrupt 7 bit in the Machine Interrupt Enable (MIE) and
// Machine Interrupt Pending (MIP) CSRs
#define MIP_MIE_OFFSET_F7I 23U

// Offset of RISC-V Steel Fast Interrupt 8 bit in the Machine Interrupt Enable (MIE) and
// Machine Interrupt Pending (MIP) CSRs
#define MIP_MIE_OFFSET_F8I 24U

// Offset of RISC-V Steel Fast Interrupt 9 bit in the Machine Interrupt Enable (MIE) and
// Machine Interrupt Pending (MIP) CSRs
#define MIP_MIE_OFFSET_F9I 25U

// Offset of RISC-V Steel Fast Interrupt 10 bit in the Machine Interrupt Enable (MIE) and
// Machine Interrupt Pending (MIP) CSRs
#define MIP_MIE_OFFSET_F10I 26U

// Offset of RISC-V Steel Fast Interrupt 11 bit in the Machine Interrupt Enable (MIE) and
// Machine Interrupt Pending (MIP) CSRs
#define MIP_MIE_OFFSET_F11I 27U

// Offset of RISC-V Steel Fast Interrupt 12 bit in the Machine Interrupt Enable (MIE) and
// Machine Interrupt Pending (MIP) CSRs
#define MIP_MIE_OFFSET_F12I 28U

// Offset of RISC-V Steel Fast Interrupt 13 bit in the Machine Interrupt Enable (MIE) and
// Machine Interrupt Pending (MIP) CSRs
#define MIP_MIE_OFFSET_F13I 29U

// Offset of RISC-V Steel Fast Interrupt 14 bit in the Machine Interrupt Enable (MIE) and
// Machine Interrupt Pending (MIP) CSRs
#define MIP_MIE_OFFSET_F14I 30U

// Offset of RISC-V Steel Fast Interrupt 15 bit in the Machine Interrupt Enable (MIE) and
// Machine Interrupt Pending (MIP) CSRs
#define MIP_MIE_OFFSET_F15I 31U

// Bit mask used to read/set/clear the Machine Software Interrupt (MSI) bit in the Machine Interrupt
// Enable (MIE) and Machine Interrupt Pending (MIP) CSRs
#define MIP_MIE_MASK_MSI (1U << MIP_MIE_OFFSET_MSI)

// Bit mask used to read/set/clear the Machine Timer Interrupt (MTI) bit in the Machine Interrupt
// Enable (MIE) and Machine Interrupt Pending (MIP) CSRs
#define MIP_MIE_MASK_MTI (1U << MIP_MIE_OFFSET_MTI)

// Bit mask used to read/set/clear the Machine External Interrupt (MEI) bit in the Machine Interrupt
// Enable (MIE) and Machine Interrupt Pending (MIP) CSRs
#define MIP_MIE_MASK_MEI (1U << MIP_MIE_OFFSET_MEI)

// Bit mask used to read/set/clear the Supervisor Software Interrupt (SSI) bit in the Machine
// Interrupt Enable (MIE) and Machine Interrupt Pending (MIP) CSRs
#define MIP_MIE_MASK_SSI (1U << MIP_MIE_OFFSET_SSI)

// Bit mask used to read/set/clear the Supervisor Timer Interrupt (STI) bit in the Machine Interrupt
// Enable (MIE) and Machine Interrupt Pending (MIP) CSRs
#define MIP_MIE_MASK_STI (1U << MIP_MIE_OFFSET_STI)

// Bit mask used to read/set/clear the Supervisor External Interrupt (SEI) bit in the Machine
// Interrupt Enable (MIE) and Machine Interrupt Pending (MIP) CSRs
#define MIP_MIE_MASK_SEI (1U << MIP_MIE_OFFSET_SEI)

// Bit mask used to read/set/clear RISC-V Steel Fast Interrupt 0 bit in the Machine Interrupt
// Enable (MIE) and Machine Interrupt Pending (MIP) CSRs
#define MIP_MIE_MASK_F0I (1U << MIP_MIE_OFFSET_F0I)

// Bit mask used to read/set/clear RISC-V Steel Fast Interrupt 1 bit in the Machine Interrupt
// Enable (MIE) and Machine Interrupt Pending (MIP) CSRs
#define MIP_MIE_MASK_F1I (1U << MIP_MIE_OFFSET_F1I)

// Bit mask used to read/set/clear RISC-V Steel Fast Interrupt 2 bit in the Machine Interrupt
// Enable (MIE) and Machine Interrupt Pending (MIP) CSRs
#define MIP_MIE_MASK_F2I (1U << MIP_MIE_OFFSET_F2I)

// Bit mask used to read/set/clear RISC-V Steel Fast Interrupt 3 bit in the Machine Interrupt
// Enable (MIE) and Machine Interrupt Pending (MIP) CSRs
#define MIP_MIE_MASK_F3I (1U << MIP_MIE_OFFSET_F3I)

// Bit mask used to read/set/clear RISC-V Steel Fast Interrupt 4 bit in the Machine Interrupt
// Enable (MIE) and Machine Interrupt Pending (MIP) CSRs
#define MIP_MIE_MASK_F4I (1U << MIP_MIE_OFFSET_F4I)

// Bit mask used to read/set/clear RISC-V Steel Fast Interrupt 5 bit in the Machine Interrupt
// Enable (MIE) and Machine Interrupt Pending (MIP) CSRs
#define MIP_MIE_MASK_F5I (1U << MIP_MIE_OFFSET_F5I)

// Bit mask used to read/set/clear RISC-V Steel Fast Interrupt 6 bit in the Machine Interrupt
// Enable (MIE) and Machine Interrupt Pending (MIP) CSRs
#define MIP_MIE_MASK_F6I (1U << MIP_MIE_OFFSET_F6I)

// Bit mask used to read/set/clear RISC-V Steel Fast Interrupt 7 bit in the Machine Interrupt
// Enable (MIE) and Machine Interrupt Pending (MIP) CSRs
#define MIP_MIE_MASK_F7I (1U << MIP_MIE_OFFSET_F7I)

// Bit mask used to read/set/clear RISC-V Steel Fast Interrupt 8 bit in the Machine Interrupt
// Enable (MIE) and Machine Interrupt Pending (MIP) CSRs
#define MIP_MIE_MASK_F8I (1U << MIP_MIE_OFFSET_F8I)

// Bit mask used to read/set/clear RISC-V Steel Fast Interrupt 9 bit in the Machine Interrupt
// Enable (MIE) and Machine Interrupt Pending (MIP) CSRs
#define MIP_MIE_MASK_F9I (1U << MIP_MIE_OFFSET_F9I)

// Bit mask used to read/set/clear RISC-V Steel Fast Interrupt 10 bit in the Machine Interrupt
// Enable (MIE) and Machine Interrupt Pending (MIP) CSRs
#define MIP_MIE_MASK_F10I (1U << MIP_MIE_OFFSET_F10I)

// Bit mask used to read/set/clear RISC-V Steel Fast Interrupt 11 bit in the Machine Interrupt
// Enable (MIE) and Machine Interrupt Pending (MIP) CSRs
#define MIP_MIE_MASK_F11I (1U << MIP_MIE_OFFSET_F11I)

// Bit mask used to read/set/clear RISC-V Steel Fast Interrupt 12 bit in the Machine Interrupt
// Enable (MIE) and Machine Interrupt Pending (MIP) CSRs
#define MIP_MIE_MASK_F12I (1U << MIP_MIE_OFFSET_F12I)

// Bit mask used to read/set/clear RISC-V Steel Fast Interrupt 13 bit in the Machine Interrupt
// Enable (MIE) and Machine Interrupt Pending (MIP) CSRs
#define MIP_MIE_MASK_F13I (1U << MIP_MIE_OFFSET_F13I)

// Bit mask used to read/set/clear RISC-V Steel Fast Interrupt 14 bit in the Machine Interrupt
// Enable (MIE) and Machine Interrupt Pending (MIP) CSRs
#define MIP_MIE_MASK_F14I (1U << MIP_MIE_OFFSET_F14I)

// Bit mask used to read/set/clear RISC-V Steel Fast Interrupt 15 bit in the Machine Interrupt
// Enable (MIE) and Machine Interrupt Pending (MIP) CSRs
#define MIP_MIE_MASK_F15I (1U << MIP_MIE_OFFSET_F15I)

// Bit mask used to enable/disable all interrupts, regardless of its type
#define MIP_MIE_MASK_ALL 0xFFFFFFFF

// Offset of the Interrupt (IRQ) bit in the MCAUSE CSR
#define MCAUSE_IRQ_OFFSET (__riscv_xlen - 1)

// Bit mask used to read/set/clear the Interrupt (IRQ) bit in the MCAUSE CSR
#define MCAUSE_IRQ_MASK (1U << MCAUSE_INTER_OFFSET)

// Bit mask used to read/set/clear the CODE field in the MCAUSE CSR
#define MCAUSE_EXCP_CODE_MASK (0x7FFFFFFF)

// Value of the MCAUSE CSR for an instruction address misaligned exception
#define MCAUSE_EXCP_INSTRUCTION_ADDRESS_MISALIGNED 0U

// Value of the MCAUSE CSR for an instruction access fault exception
#define MCAUSE_EXCP_INSTRUCTION_ACCESS_FAULT 1U

// Value of the MCAUSE CSR for an illegal instruction exception
#define MCAUSE_EXCP_ILLEGAL_INSTRUCTION 2U

// Value of the MCAUSE CSR for a breakpoint exception
#define MCAUSE_EXCP_BREAKPOINT 3U

// Value of the MCAUSE CSR for a load address misaligned exception
#define MCAUSE_EXCP_LOAD_ADDRESS_MISALIGNED 4U

// Value of the MCAUSE CSR for a load access fault exception
#define MCAUSE_EXCP_LOAD_ACCESS_FAULT 5U

// Value of the MCAUSE CSR for a store/AMO address misaligned exception
#define MCAUSE_EXCP_STORE_AMO_ADDRESS_MISALIGNED 6U

// Value of the MCAUSE CSR for a store/AMO access fault exception
#define MCAUSE_EXCP_STORE_AMO_ACCESS_FAULT 7U

// Value of the MCAUSE CSR for an environment call from U-mode exception
#define MCAUSE_EXCP_ENVIRONMENT_CALL_FROM_U_MODE 8U

// Value of the MCAUSE CSR for an environment call from S-mode exception
#define MCAUSE_EXCP_ENVIRONMENT_CALL_FROM_S_MODE 9U

// Value of the MCAUSE CSR for an environment call from M-mode exception
#define MCAUSE_EXCP_ENVIRONMENT_CALL_FROM_M_MODE 11U

// Value of the MCAUSE CSR for an instruction page fault exception
#define MCAUSE_EXCP_INSTRUCTION_PAGE_FAULT 12U

// Value of the MCAUSE CSR for a load page fault exception
#define MCAUSE_EXCP_LOAD_PAGE_FAULT 13U

// Value of the MCAUSE CSR for a store/AMO page fault exception
#define MCAUSE_EXCP_STORE_AMO_PAGE_FAULT 15U

// Value of the MCAUSE CSR for a Supervisor Software Interrupt (SSI)
#define MCAUSE_IRQ_SSI 0x80000001

// Value of the MCAUSE CSR for a Supervisor Machine Interrupt (MSI)
#define MCAUSE_IRQ_MSI 0x80000003

// Value of the MCAUSE CSR for a Supervisor Timer Interrupt (STI)
#define MCAUSE_IRQ_STI 0x00000005

// Value of the MCAUSE CSR for a Machine Timer Interrupt (MTI)
#define MCAUSE_IRQ_MTI 0x00000007

// Value of the MCAUSE CSR for a Supervisor External Interrupt (SEI)
#define MCAUSE_IRQ_SEI 0x80000009

// Value of the MCAUSE CSR for a Machine External Interrupt (MEI)
#define MCAUSE_IRQ_MEI 0x8000000B

/**
 * @brief Read the value of a Control and Status Register.
 *
 * Example usage:
 * ```
 * uint32_t mstatus_value;
 * CSR_READ(CSR_MSTATUS, mstatus_value);
 * ```
 *
 * @param uint32_var The name of an uint32_t variable where the read value will be saved
 * @param csr_address The 12-bit address of the CSR to be read. `rvsteel_csr.h` provides named
 * macros with the addresses of all CSRs implemented in RISC-V Steel. The macro names are in the
 * form `CSR_<csr_name>`. Example: CSR_MSTATUS.
 *
 */
#define CSR_READ(csr_address, uint32_var)                                                          \
  asm volatile("csrr %0, %1" : "=r"(uint32_var) : "I"(csr_address))

/**
 * @brief Write a value to a Control and Status Register.
 *
 * Example usage:
 * ```
 * CSR_WRITE(CSR_MSTATUS, 0x00000004);
 * ```
 *
 * @param uint32_value The value to be written to the CSR
 * @param csr_address The 12-bit address of the CSR to be written. `rvsteel_csr.h` provides named
 * macros with the addresses of all CSRs implemented in RISC-V Steel. The macro names are in the
 * form `CSR_<csr_name>`. Example: CSR_MSTATUS.
 *
 */
#define CSR_WRITE(csr_address, uint32_value)                                                       \
  asm volatile("csrw %0, %1" : : "I"(csr_address), "r"(uint32_value))

/**
 * @brief Atomic read/write a value to a Control and Status Register.
 *
 * Example usage:
 * ```
 * uint32_var mstatus_value;
 * CSR_READ_WRITE(CSR_MSTATUS, mstatus_value, 0x00000004);
 * ```
 *
 * @param uint32_var The name of an uint32_t variable where the read value will be saved
 * @param uint32_value The value to be written to the CSR
 * @param csr_address The 12-bit address of the CSR to be read/written. `rvsteel_csr.h` provides
 * named macros with the addresses of all CSRs implemented in RISC-V Steel. The macro names are in
 * the form `CSR_<csr_name>`. Example: CSR_MSTATUS.
 *
 */
#define CSR_READ_WRITE(csr_address, uint32_var, uint32_value)                                      \
  asm volatile("csrrw %0, %1, %2" : "=r"(uint32_var) : "I"(csr_address), "r"(uint32_value))

/**
 * @brief Set specific bits in a Control and Status Register based on the bit mask provided.
 *
 * Example usage:
 * ```
 * CSR_SET(CSR_MSTATUS, 0x00000004);
 * ```
 *
 * @param bit_mask A 32-bit mask indicating which bits must be set to 1.
 * @param csr_address The 12-bit address of the CSR to be affected. `rvsteel_csr.h` provides named
 * macros with the addresses of all CSRs implemented in RISC-V Steel. The macro names are in the
 * form `CSR_<csr_name>`. Example: CSR_MSTATUS.
 *
 */
#define CSR_SET(csr_address, bit_mask)                                                             \
  asm volatile("csrrs zero, %0, %1" : : "I"(csr_address), "r"(bit_mask))

/**
 * @brief Clear specific bits in a Control and Status Register based on the bit mask provided.
 *
 * Example usage:
 * ```
 * CSR_CLEAR(CSR_MSTATUS, 0x00000004);
 * ```
 *
 * @param bit_mask A 32-bit mask indicating which bits must be cleared to 0.
 * @param csr_address The 12-bit address of the CSR to be affected. `rvsteel_csr.h` provides named
 * macros with the addresses of all CSRs implemented in RISC-V Steel. The macro names are in the
 * form `CSR_<csr_name>`. Example: CSR_MSTATUS.
 *
 */
#define CSR_CLEAR(csr_address, bit_mask)                                                           \
  asm volatile("csrrc zero, %0, %1" : : "I"(csr_address), "r"(bit_mask))

/**
 * @brief Atomic read/set bits in a Control and Status Register. The bits are set based on the bit
 * mask provided.
 *
 * Example usage:
 * ```
 * uint32_var mstatus_value;
 * CSR_READ_SET(CSR_MSTATUS, mstatus_value, 0x00000004);
 * ```
 *
 * @param uint32_var The name of an uint32_t variable where the read value will be saved
 * @param bit_mask A 32-bit mask indicating which bits must be set to 1.
 * @param csr_address The 12-bit address of the CSR to be read/written. `rvsteel_csr.h` provides
 * named macros with the addresses of all CSRs implemented in RISC-V Steel. The macro names are in
 * the form `CSR_<csr_name>`. Example: CSR_MSTATUS.
 *
 */
#define CSR_READ_SET(csr_address, uint32_var, bit_mask)                                            \
  asm volatile("csrrs %0, %1, %2" : "=r"(uint32_var) : "I"(csr_address), "r"(bit_mask))

/**
 * @brief Atomic read/clear bits in a Control and Status Register. The bits are cleared based on the
 * bit mask provided.
 *
 * Example usage:
 * ```
 * uint32_var mstatus_value;
 * CSR_READ_CLEAR(CSR_MSTATUS, mstatus_value, 0x00000004);
 * ```
 *
 * @param uint32_var The name of an uint32_t variable where the read value will be saved
 * @param bit_mask A 32-bit mask indicating which bits must be cleared to 0.
 * @param csr_address The 12-bit address of the CSR to be read/written. `rvsteel_csr.h` provides
 * named macros with the addresses of all CSRs implemented in RISC-V Steel. The macro names are in
 * the form `CSR_<csr_name>`. Example: CSR_MSTATUS.
 *
 */
#define CSR_READ_CLEAR(csr_address, uint32_var, bit_mask)                                          \
  asm volatile("csrrc %0, %1, %2" : "=r"(uint32_var) : "I"(csr_address), "r"(bit_mask))

/**
 * @brief Globally enable interrupt requests by setting the global Machine Interrupt Enable (MIE)
 * bit in the Machine Status (MSTATUS) CSR. Note that an interrupt only causes a trap if it is also
 * enabled in the Machine Interrupt Enable (CSR).
 *
 * Function `csr_enable_irq(uint32_t mask)` can be used to enable specific interrupt types. For
 * example, to enable Machine External Interrupts, do:
 *
 * ```
 * csr_global_enable_irq();
 * CSR_SET(CSR_MIE, MIP_MIE_MASK_MEI);
 * ```
 *
 * To enable all interrupts, regardless of its type, do:
 * ```
 * csr_global_enable_irq();
 * CSR_SET(CSR_MIE, MIP_MIE_MASK_ALL);
 * ```
 *
 */
inline void csr_global_enable_irq()
{
  CSR_SET(CSR_MSTATUS, MSTATUS_MIE_MASK);
}

/**
 * @brief Globally disable all interrupt requests by clearing the global Machine Interrupt Enable
 * (MIE) bit in the Machine Status (MSTATUS) CSR.
 *
 */
inline void csr_global_disable_irq()
{
  CSR_CLEAR(CSR_MSTATUS, MSTATUS_MIE_MASK);
}

/**
 * @brief Enable vectored mode for interrupt requests.
 *
 */
inline void csr_enable_vectored_mode_irq()
{
  CSR_SET(CSR_MTVEC, 1U);
}

/**
 * @brief Enable direct mode for interrupt requests.
 *
 */
inline void csr_enable_direct_mode_irq()
{
  CSR_CLEAR(CSR_MTVEC, 1U);
}

#endif // __LIBSTEEL_CSR__
