#ifndef __REG_H__
#define __REG_H__

#include "common.h"

extern coreState core;
extern Vxcore* dut;

void isa_reg_display();
word_t isa_reg_str2val(const char *s, bool *success);
void isa_reg_update();

#endif