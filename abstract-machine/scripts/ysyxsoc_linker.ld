ENTRY(_start)
PHDRS { text PT_LOAD; data PT_LOAD; }

MEMORY {
  mrom : ORIGIN = 0x20000000, LENGTH = 4K
  sram : ORIGIN = 0x0f000000, LENGTH = 8K
}

SECTIONS {
  . = ORIGIN(mrom);
  .text : {
    *(entry)
    *(.text*)
  } > mrom AT> mrom : text
  etext = .;
  _etext = .;
  .rodata : {
    *(.rodata*)
  } > mrom AT> mrom
  _mdata = .;
  .data : {
    _data_start = .;
    *(.data)
    _data_end = .;
  } > sram AT> mrom : data 
  edata = .;
  _data = .;
  .bss : {
	  _bss_start = .;
    *(.bss*)
    *(.sbss*)
    *(.scommon)
    _bss_end = .;
  } > sram AT> mrom
  _stack_top = 0x0f001000;
  . = _stack_top + 0x0ffc;
  _stack_pointer = .;
  end = .;
  _end = .;
  _heap_start = 0x0f000000;
}
