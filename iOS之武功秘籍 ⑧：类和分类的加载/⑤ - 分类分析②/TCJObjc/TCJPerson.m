//
//  TCJPerson.m
//  TCJObjc
//
//  Created by tangchangjiang on 2021/2/17.
//

#import "TCJPerson.h"
#ifdef DEBUG
#define CJNSLog(format, ...) printf("%s\n", [[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String]);
#else
#define CJNSLog(format, ...);
#endif

@implementation TCJPerson

+ (void)load{

}

- (void)cj_instanceMethod1{
    CJNSLog(@"%s",__func__);
}
- (void)cj_instanceMethod2{
    CJNSLog(@"%s",__func__);
}
- (void)cj_instanceMethod3{
    CJNSLog(@"%s",__func__);
}

+ (void)cj_classMethod{
    CJNSLog(@"%s",__func__);
}

@end
