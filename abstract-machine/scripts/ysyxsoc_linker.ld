ENTRY(_start)
PHDRS {fsbl PT_LOAD; ssbl PT_LOAD; text PT_LOAD; rodata PT_LOAD; data PT_LOAD; bss PT_LOAD;}

MEMORY {
    mrom  : ORIGIN = 0x20000000, LENGTH = 4K
    sram  : ORIGIN = 0x0f000000, LENGTH = 8K
    psram : ORIGIN = 0x80000000, LENGTH = 4M
    flash : ORIGIN = 0x30000000, LENGTH = 16M
}

SECTIONS {
    . = ORIGIN(flash);

    /* first stage bootloader */
    .fsbl : {
        *(entry)
        *(.fsbl)
    } > flash AT> flash : fsbl

    /* second stage bootloader */
    _ssbl_section_src = LOADADDR(.ssbl);
    .ssbl : {
        _ssbl_section_start = .;
        *(.ssbl)
        _ssbl_section_end = .;
    } > sram AT> flash : ssbl

    /* text section */
    _text_section_src = LOADADDR(.text);
    .text : {
        _text_section_start = .;
        *(.text*)
        _text_section_end = .;
    } > psram AT> flash : text
    etext = .;
    _etext = .;

    /* read-only data section */
    .rodata : {
        *(.rodata*)
        *(.srodata*)
    } > psram AT> flash : rodata

    /* data section */
    _data_section_src = LOADADDR(.data);
    .data : {
        _data_section_start = .;
        *(.data*)
        *(.sdata*)
        _data_section_end = .;
    } > psram AT> flash : data 
    edata = .;
    _data = .;

    /* bss section */
    .bss : {
        _bss_start = .;
        *(.bss*)
        *(.sbss*)
        *(.scommon)
        _bss_end = .;
    } > psram AT> flash : bss

    _heap_start = ALIGN(0x10);
    _heap_end = ORIGIN(psram) + LENGTH(psram);

    _stack_top = ORIGIN(sram);
    _stack_pointer = _stack_top + LENGTH(sram);

    end = .;
    _end = .;
}
