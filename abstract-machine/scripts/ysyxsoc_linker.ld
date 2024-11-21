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
  }
  _data_start = .;
  .data : {
    *(.data)
  } > mrom AT > sram : data 
  _data_end = .;
  edata = .;
  _data = .;
  .bss : {
	_bss_start = .;
    *(.bss*)
    *(.sbss*)
    *(.scommon)
  }
  _stack_top = 0x0f001000;
  . = _stack_top + 0x0fff;
  _stack_pointer = .;
  end = .;
  _end = .;
  _heap_start = (ORIGIN(sram) + _data_end - _data_start);
}
