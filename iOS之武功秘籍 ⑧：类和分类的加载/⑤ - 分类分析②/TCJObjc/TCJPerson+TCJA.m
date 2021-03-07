//
//  TCJPerson+TCJA.m
//  TCJObjc
//
//  Created by tangchangjiang on 2021/2/21.
//
#ifdef DEBUG
#define CJNSLog(format, ...) printf("%s\n", [[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String]);
#else
#define CJNSLog(format, ...);
#endif
#import "TCJPerson+TCJA.h"

@implementation TCJPerson (TCJA)
+ (void)load{

}

- (void)cj_instanceMethod1{
    CJNSLog(@"%s",__func__);
}

- (void)cateA_2{
    CJNSLog(@"%s",__func__);
}
- (void)cateA_1{
    CJNSLog(@"%s",__func__);
}
- (void)cateA_3{
    CJNSLog(@"%s",__func__);
}
@end
