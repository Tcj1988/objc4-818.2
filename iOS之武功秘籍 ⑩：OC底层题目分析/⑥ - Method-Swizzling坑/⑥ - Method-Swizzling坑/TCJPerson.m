//
//  TCJPerson.m
//  ⑥ - Method-Swizzling坑
//
//  Created by tangchangjiang on 2021/2/24.
//
#ifdef DEBUG
#define CJNSLog(format, ...) printf("%s\n", [[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String]);
#else
#define CJNSLog(format, ...);
#endif
#import "TCJPerson.h"

@implementation TCJPerson
- (void)personInstanceMethod{
    CJNSLog(@"person对象方法:%s",__func__);
}
+ (void)personClassMethod{
    CJNSLog(@"person类方法:%s",__func__);
}
@end
