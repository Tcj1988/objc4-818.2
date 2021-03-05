//
//  main.m
//  TCJObjc
//
//  Created by tangchangjiang on 2021/1/6.
//


#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#ifdef DEBUG
#define CJNSLog(format, ...) printf("%s\n", [[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String]);
#else
#define CJNSLog(format, ...);
#endif

@interface TCJPerson : NSObject

@end

@implementation TCJPerson

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        BOOL re1 = [(id)[NSObject class] isKindOfClass:[NSObject class]];  // 1
        BOOL re2 = [(id)[NSObject class] isMemberOfClass:[NSObject class]];// 0
        BOOL re3 = [(id)[TCJPerson class] isKindOfClass:[TCJPerson class]];  // 0
        BOOL re4 = [(id)[TCJPerson class] isMemberOfClass:[TCJPerson class]]; // 0
        CJNSLog(@" re1 :%hhd\n re2 :%hhd\n re3 :%hhd\n re4 :%hhd\n",re1,re2,re3,re4);

        BOOL re5 = [(id)[NSObject alloc] isKindOfClass:[NSObject class]]; // 1
        BOOL re6 = [(id)[NSObject alloc] isMemberOfClass:[NSObject class]];// 1
        BOOL re7 = [(id)[TCJPerson alloc] isKindOfClass:[TCJPerson class]]; // 1
        BOOL re8 = [(id)[TCJPerson alloc] isMemberOfClass:[TCJPerson class]];// 1
        CJNSLog(@" re5 :%hhd\n re6 :%hhd\n re7 :%hhd\n re8 :%hhd\n",re5,re6,re7,re8);
    }
    return 0;
}




