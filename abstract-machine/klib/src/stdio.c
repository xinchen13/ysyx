#include <am.h>
#include <klib.h>
#include <klib-macros.h>
#include <stdarg.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)

int printf(const char *fmt, ...) {
    // panic("Not implemented");
    va_list ap;
    va_start(ap, fmt);
    char str_tmp[128];
    char *p = str_tmp;
    char *rp = str_tmp;
    const char *fmt_ptr = fmt;
    int length = 0;  // the size of str
    int width;

   while (*fmt_ptr) {
        if (*fmt_ptr == '%') {
            fmt_ptr++;  // skip '%'

            // tackle width
            width = 0;
            if (*fmt_ptr >= '0' && *fmt_ptr <= '9') {
                while (*fmt_ptr >= '0' && *fmt_ptr <= '9') {
                    width = width * 10 + (*fmt_ptr - '0');
                    fmt_ptr++;
                }
            }

            switch (*fmt_ptr) {
                case 'c':
                    char arg_char = va_arg(ap, int);
                    *p = arg_char;
                    p++;
                    length++;
                    break;
                case 's':   // string
                    char *arg = va_arg(ap, char*);
                    while (*arg) {
                        *p = *arg++;
                        p++;
                        length++;
                    }
                    break;
                case 'd':   // decimal
                    int num = va_arg(ap, int);
                    int num_digits = 0;   
                    int neg = 0;
                    if (num < 0) {
                        neg = 1;
                        num = -num;
                        num_digits = 1;
                    } 
                    else if (num == 0) {
                        num_digits = 1;
                    }
                    int temp = num;
                    while (temp > 0) {
                        temp /= 10;
                        num_digits++;
                    }
                    int real_width = (width > num_digits) ? width : num_digits;
                    int width_counter = real_width;
                    p = p + real_width - 1;
                    if (num == 0) {
                        *p = '0';
                        p--;
                        width_counter--;
                    }
                    else {
                        while (num > 0) {
                            *p = '0' + num % 10;
                            p--;
                            width_counter--;
                            num /= 10;
                        }
                    }
                    if (neg) {
                        *p = '-';
                        p--;
                        width_counter--;
                    }
                    while (width_counter-- > 0) {
                        *p = ' ';
                        p--;
                    }
                    p = p + real_width + 1; 
                    length += real_width;
                    break;
                default:
                    *p = *fmt_ptr;
                    p++;
                    length++;
                    break;
            }
        }
        else {
            *p = *fmt_ptr;
            p++;
            length++;
        }
        fmt_ptr++;
    }
    *p = '\0';  // terminating sign
    va_end(ap);

    while (*rp != '\0') {
        putch(*rp);
        rp++;
    }

    return length;
}

int vsprintf(char *out, const char *fmt, va_list ap) {
    panic("Not implemented");
}

int sprintf(char *out, const char *fmt, ...) {
    // panic("Not implemented");
    // produce output according to a format: fmt
    // write output to the character string: out
    va_list ap;
    va_start(ap, fmt);
    char *p = out;
    const char *fmt_ptr = fmt;
    int length = 0;  // the size of str
    int width;

    while (*fmt_ptr) {
        if (*fmt_ptr == '%') {
            fmt_ptr++;  // skip '%'

            // tackle width
            width = 0;
            if (*fmt_ptr >= '0' && *fmt_ptr <= '9') {
                while (*fmt_ptr >= '0' && *fmt_ptr <= '9') {
                    width = width * 10 + (*fmt_ptr - '0');
                    fmt_ptr++;
                }
            }

            switch (*fmt_ptr) {
                case 'c':
                    char arg_char = va_arg(ap, int);
                    *p = arg_char;
                    p++;
                    length++;
                    break;
                case 's':   // string
                    char *arg = va_arg(ap, char*);
                    while (*arg) {
                        *p = *arg++;
                        p++;
                        length++;
                    }
                    break;
                case 'd':   // decimal
                    int num = va_arg(ap, int);
                    int num_digits = 0;   
                    int neg = 0;
                    if (num < 0) {
                        neg = 1;
                        num = -num;
                        num_digits = 1;
                    } 
                    else if (num == 0) {
                        num_digits = 1;
                    }
                    int temp = num;
                    while (temp > 0) {
                        temp /= 10;
                        num_digits++;
                    }
                    int real_width = (width > num_digits) ? width : num_digits;
                    int width_counter = real_width;
                    p = p + real_width - 1;
                    if (num == 0) {
                        *p = '0';
                        p--;
                        width_counter--;
                    }
                    else {
                        while (num > 0) {
                            *p = '0' + num % 10;
                            p--;
                            width_counter--;
                            num /= 10;
                        }
                    }
                    if (neg) {
                        *p = '-';
                        p--;
                        width_counter--;
                    }
                    while (width_counter-- > 0) {
                        *p = ' ';
                        p--;
                    }
                    p = p + real_width + 1; 
                    length += real_width;
                    break;
                default:
                    *p = *fmt_ptr;
                    p++;
                    length++;
                    break;
            }
        }
        else {
            *p = *fmt_ptr;
            p++;
            length++;
        }
        fmt_ptr++;
    }
    *p = '\0';  // terminating sign
    va_end(ap);
    return length;
}

int snprintf(char *out, size_t n, const char *fmt, ...) {
    panic("Not implemented");
}

int vsnprintf(char *out, size_t n, const char *fmt, va_list ap) {
    panic("Not implemented");
}

#endif
