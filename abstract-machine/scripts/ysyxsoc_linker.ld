ENTRY(_start)
PHDRS { text PT_LOAD; data PT_LOAD; bss PT_LOAD;}

MEMORY {
  sram  : ORIGIN = 0x0f000000, LENGTH = 8K
  psram : ORIGIN = 0x80000000, LENGTH = 4M
  flash : ORIGIN = 0x30000000, LENGTH = 16M
}

SECTIONS {
  . = ORIGIN(flash);
  .text : {
    *(entry)
    *(.text*)
  } > flash AT> flash : text
  etext = .;
  _etext = .;
  .rodata : {
    *(.rodata*)
    *(.srodata*)
  } > flash AT> flash
  _mdata = .;
  .data : {
    _data_start = .;
    *(.data*)
    *(.sdata*)
    _data_end = .;
  } > psram AT> flash : data 
  edata = .;
  _data = .;
  .bss : {
	  _bss_start = .;
    *(.bss*)
    *(.sbss*)
    *(.scommon)
    _bss_end = .;
  } > psram AT> flash : bss

  _tmp_psram_load_start = ALIGN(0x10);
  _tmp_psram_load_end = _tmp_psram_load_start + 0x2000;
  _heap_start = ALIGN(0x10);
  _heap_end = ORIGIN(psram) + LENGTH(psram);

  _stack_top = ORIGIN(sram);
  _stack_pointer = _stack_top + LENGTH(sram);

  end = .;
  _end = .;
}
