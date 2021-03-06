//
//  main.m
//  TCJObjc
//
//  Created by tangchangjiang on 2021/1/6.
//


#import <Foundation/Foundation.h>
#import "TCJPerson.h"
#import <objc/runtime.h>
#ifdef DEBUG
#define CJNSLog(format, ...) printf("%s\n", [[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String]);
#else
#define CJNSLog(format, ...);
#endif

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        TCJPerson *person  = [TCJPerson alloc];
//        [person sayHello];
        [person say666];
//        [TCJPerson sayNB];
    }
    return 0;
}




