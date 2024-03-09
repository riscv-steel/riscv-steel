OUTPUT_ARCH("riscv")
ENTRY(_start)

__STACK_SIZE = 1K;

MEMORY
{
  RAM (wx)  : ORIGIN = 0x00000000, LENGTH = 16K
}

PHDRS
{
  text PT_LOAD FLAGS(5); /* PF_R+PF_X (Read, execute) */
  data PT_LOAD FLAGS(6); /* PF_R+PF_W (Read, write) */
}

SECTIONS
{  
  .text :
  {
    *(.rvsteel_boot)
    *(.trap_vector)
    *(.text*)
    *(.rodata*)
    *(.srodata*)
  } > RAM :text
  .data : ALIGN(4)
  {
    *(.data*)
    *(.sdata*)
    . = ALIGN(4);
  } > RAM :data
  .bss : ALIGN(4)
  {
    *(.sbss*)
    *(.bss*)
    . = ALIGN(4);
  } > RAM :data
  .stack : ALIGN(4)
  {
    . += __STACK_SIZE;
    . = ALIGN(4);
  } > RAM :data
  /DISCARD/ :
  {
    *(.comment)
    *(.riscv.attributes)
  }
}

PROVIDE(__trap_vector              = ADDR(.trap_vector));
PROVIDE(__stack_limit              = ORIGIN(RAM) + LENGTH(RAM) - __STACK_SIZE);
PROVIDE(__stack_top                = ORIGIN(RAM) + LENGTH(RAM));
PROVIDE(__freertos_irq_stack_top   = __stack_top);
