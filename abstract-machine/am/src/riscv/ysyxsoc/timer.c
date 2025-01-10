#include <am.h>
#include "ysyxsoc.h"

static uint64_t time_init = 0;

static uint64_t get_time() {
    uint32_t low_time = inl(RTC_ADDR);
    uint32_t high_time = inl(RTC_ADDR + 4);
    return ((uint64_t)low_time + (((uint64_t)high_time) << 32));
}

void __am_timer_init() {
    time_init = get_time();
}

void __am_timer_uptime(AM_TIMER_UPTIME_T *uptime) {
    uptime->us = get_time() - time_init;
}

void __am_timer_rtc(AM_TIMER_RTC_T *rtc) {
  rtc->second = 0;
  rtc->minute = 0;
  rtc->hour   = 0;
  rtc->day    = 0;
  rtc->month  = 0;
  rtc->year   = 1900;
}
