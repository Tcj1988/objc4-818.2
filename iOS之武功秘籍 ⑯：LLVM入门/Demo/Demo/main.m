//
//  main.m
//  Demo
//
//  Created by tangchangjiang on 2021/1/3.
//

#import <stdio.h>
int test(int a, int b){
    return a + b + 3;
}

typedef int CJ_INT_64;

int main(int argc, const char * argv[]) {
    int a = test(1, 2);
    printf("%d",a);
    return 0;
}
