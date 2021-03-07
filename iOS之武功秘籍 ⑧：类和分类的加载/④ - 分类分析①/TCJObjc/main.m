//
//  main.m
//  TCJObjc
//
//  Created by tangchangjiang on 2021/1/6.
//


#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "TCJPerson.h"
#ifdef DEBUG
#define CJNSLog(format, ...) printf("%s\n", [[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String]);
#else
#define CJNSLog(format, ...);
#endif
#pragma mark ---TCJPerson分类
@interface TCJPerson (TCJ)
@property (nonatomic, copy) NSString *cate_name;
@property (nonatomic, assign) int cate_age;
- (void)cate_instanceMethod1;
- (void)cate_instanceMethod3;
- (void)cate_instanceMethod2;
+ (void)cate_classMethod;
@end

@implementation TCJPerson (TCJ)

- (void)cate_instanceMethod1{
    CJNSLog(@"%s",__func__);
}
- (void)cate_instanceMethod2{
    CJNSLog(@"%s",__func__);
}
- (void)cate_instanceMethod3{
    CJNSLog(@"%s",__func__);
}

+ (void)cate_classMethod{
    CJNSLog(@"%s",__func__);
}

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        TCJPerson *person  = [TCJPerson alloc];
        [person cj_instanceMethod1];
        CJNSLog(@"%p",person);
    }
    return 0;
}





