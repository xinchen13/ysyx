#include <nvboard.h>
#include "Vtop.h"

void nvboard_bind_all_pins(Vtop* top) {
	nvboard_bind_pin( &top->a, 4, SW3, SW2, SW1, SW0);
	nvboard_bind_pin( &top->b, 4, SW7, SW6, SW5, SW4);
	nvboard_bind_pin( &top->opcode, 3, SW15, SW14, SW13);
	nvboard_bind_pin( &top->y, 4, LD3, LD2, LD1, LD0);
	nvboard_bind_pin( &top->y_carry, 1, LD4);
	nvboard_bind_pin( &top->y_overflow, 1, LD5);
	nvboard_bind_pin( &top->y_zero, 1, LD6);
}
