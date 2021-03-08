//
//  TCJPerson+TCJB.m
//  TCJObjc
//
//  Created by tangchangjiang on 2021/2/21.
//
#ifdef DEBUG
#define CJNSLog(format, ...) printf("%s\n", [[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String]);
#else
#define CJNSLog(format, ...);
#endif
#import "TCJPerson+TCJB.h"

@implementation TCJPerson (TCJB)

+ (void)load{
    CJNSLog(@"%s",__func__);
}

+ (void)initialize
{
    CJNSLog(@"%s",__func__);
}

- (void)cj_instanceMethod1{
    CJNSLog(@"%s",__func__);
}

- (void)cateB_2{
    CJNSLog(@"%s",__func__);
}
- (void)cateB_1{
    CJNSLog(@"%s",__func__);
}
- (void)cateB_3{
    CJNSLog(@"%s",__func__);
}
@end
