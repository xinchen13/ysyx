#include <stdio.h>

#define STACK_SIZE 50

typedef struct {
    int stack_body[STACK_SIZE];
    int stack_top;
} mystack;

void stack_init(mystack* st) {
    st->stack_top = -1;
}

void stack_display(mystack* st) {
    int cnt = st->stack_top;
    if (cnt >= 0) {
        printf("\n\t %d \t <--\n", st->stack_body[cnt--]);
        while(cnt != -1) {
            printf("\t %d \t\n", st->stack_body[cnt]);
            cnt--;
        }
        printf("\n");
    }
    else {
        printf("empty stack~\n");
    }
}

void push(mystack *st, int data) {
    if (st->stack_top < STACK_SIZE-1) {
        st->stack_top++;
        st->stack_body[st->stack_top] = data;
    }
    else {
        printf("push error: full!!\n");
    }
}

int pop(mystack *st) {
    if (st->stack_top != -1) {
        st->stack_top--;
        return st->stack_body[st->stack_top+1];
    }
    else {
        printf("pop error: empty stack~\n");
        return 0;
    }
}



int main () {
    mystack test_st;
    mystack* st_p = &test_st;                               
    stack_init(st_p);
    stack_display(st_p);
    pop(st_p);

    push(st_p, 5);
    push(st_p, 44);
    push(st_p, 56);
    push(st_p, 1);
    stack_display(st_p);

    pop(st_p);
    pop(st_p);
    push(st_p, 33);
    stack_display(st_p);
    return 0;
}