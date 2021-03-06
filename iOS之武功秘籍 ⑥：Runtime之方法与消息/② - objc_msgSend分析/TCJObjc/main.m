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
@property (nonatomic, copy) NSString *cjName;
@property (nonatomic, strong) NSString *nickName;
- (void)sayHello;
- (void)sayCode;
- (void)sayMaster;
- (void)sayNB;
+ (void)sayHappy;
@end

@implementation TCJPerson
- (void)sayHello{
    CJNSLog(@"TCJPerson say : %s",__func__);
}
- (void)sayCode{
    CJNSLog(@"TCJPerson say : %s",__func__);
}
- (void)sayMaster{
    CJNSLog(@"TCJPerson say : %s",__func__);
}
- (void)sayNB{
    CJNSLog(@"TCJPerson say : %s",__func__);
}
+ (void)sayHappy{
    CJNSLog(@"TCJPerson say : %s",__func__);
}
@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        TCJPerson *person  = [TCJPerson alloc];
        Class pClass = [TCJPerson class];
//        person.cjName     = @"cj";
//        person.nickName   = @"nick";
        // 缓存一次方法 sayHello
        // 4
        [person sayHello];
        [person sayCode];
        [person sayMaster];
//        [person sayNB];


        CJNSLog(@"%@",pClass);
    }
    return 0;
}




