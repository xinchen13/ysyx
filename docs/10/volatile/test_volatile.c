void fun() {
    extern unsigned char _end;  
    // _end是什么?
    // 程序的末尾地址
    volatile unsigned char *p = &_end;
    *p = 0;
    while(*p != 0xff);
    *p = 0x33;
    *p = 0x34;
    *p = 0x86;
}

int main () {
    fun();
    return 0;
}