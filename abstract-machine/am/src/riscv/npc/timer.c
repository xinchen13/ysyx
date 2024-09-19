#include <am.h>

// ------- simulate rtc -------
#define DEVICE_BASE     0xa0000000
#define RTC_ADDR        (DEVICE_BASE + 0x0000048)
static inline uint32_t inl(uintptr_t addr) { return *(volatile uint32_t *)addr; }
// ----------------------------

void __am_timer_init() {
}

void __am_timer_uptime(AM_TIMER_UPTIME_T *uptime) {
    uint32_t low_time = inl(RTC_ADDR);
    uptime->us = (uint64_t)low_time;

    // uint32_t low_time = inl(RTC_ADDR);
    // uint32_t high_time = inl(RTC_ADDR + 4);
    // uptime->us = ((uint64_t)low_time + (((uint64_t)high_time) << 32)) / 500;
}

void __am_timer_rtc(AM_TIMER_RTC_T *rtc) {
  rtc->second = 0;
  rtc->minute = 0;
  rtc->hour   = 0;
  rtc->day    = 0;
  rtc->month  = 0;
  rtc->year   = 1900;
}
