//
//  main.m
//  ② - 内存偏移
//
//  Created by tangchangjiang on 2020/1/6.
//  Copyright © 2020 tangchangjiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCJPerson.h"

#ifdef DEBUG
#define TCJNSLog(format, ...) printf("TCJ打印: %s\n", [[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String]);
#else
#define TCJNSLog(format, ...);
#endif

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        // 普通指针
        // 值拷贝
//        int a = 10; //
//        int b = 10; //
//        TCJNSLog(@"%d -- %p",a,&a);
//        TCJNSLog(@"%d -- %p",b,&b);
        
        // 对象 - 指针拷贝
//        TCJPerson *obj1 = [TCJPerson alloc];
//        TCJPerson *obj2 = [TCJPerson alloc];
//        TCJNSLog(@"%@ -- %p", obj1, &obj1);
//        TCJNSLog(@"%@ -- %p", obj2, &obj2);
        
        // 数组指针
        int a[4] = {1,2,3,4};
        int *d = a;
        TCJNSLog(@"%p - %p - %p", &a, &a[0], &a[1]);
        TCJNSLog(@"%p - %p - %p", d, d+1, d+2);
        for (int i = 0; i<4; i++) {
            // int value = c[i];
            int value = *(d+i);
            TCJNSLog(@"%d",value);
        }        
        NSLog(@"指针 - 内存偏移");
    }
    return 0;
}
