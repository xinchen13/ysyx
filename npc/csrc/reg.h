#ifndef __REG_H__
#define __REG_H__

#include "common.h"

void isa_reg_display();

word_t isa_reg_str2val(const char *s, bool *success);

#endif