#include "stdio.h"

int main(){
    __block int a = 10;
    void(^block)(void) = ^{
        a++;
        printf("hello --- %d",a);
    };
    block();
    return 0;
}
