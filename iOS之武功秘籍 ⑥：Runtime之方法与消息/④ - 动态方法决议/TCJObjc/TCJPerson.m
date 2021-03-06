//
//  TCJPerson.m
//  TCJObjc
//
//  Created by tangchangjiang on 2021/2/17.
//

#import "TCJPerson.h"
#import <objc/message.h>
#ifdef DEBUG
#define CJNSLog(format, ...) printf("%s\n", [[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String]);
#else
#define CJNSLog(format, ...);
#endif

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

+ (void)sayHappy{
    CJNSLog(@"TCJPerson say : %s",__func__);
}

//+ (BOOL)resolveInstanceMethod:(SEL)sel
//{
//    if (sel == @selector(say666)) {
//        CJNSLog(@"%@来了",NSStringFromSelector(sel));
//        //获取sayMaster方法的imp
//        IMP imp = class_getMethodImplementation(self, @selector(sayMaster));
//        //获取sayMaster的实例方法
//        Method sayMethod = class_getInstanceMethod(self, @selector(sayMaster));
//        //获取sayMaster的类型签名
//        const char *type = method_getTypeEncoding(sayMethod);
//        //将sel的实现指向sayMaster
//        return class_addMethod(self, sel, imp, type);
//    }
//    
//    return [super resolveInstanceMethod:sel];
//}

//+ (BOOL)resolveClassMethod:(SEL)sel{
//
//    if (sel == @selector(sayNB)) {
//        NSLog(@"%@ 来了", NSStringFromSelector(sel));
//
//        IMP imp = class_getMethodImplementation(objc_getMetaClass("TCJPerson"), @selector(sayHappy));
//        Method sayClassMethod  = class_getInstanceMethod(objc_getMetaClass("TCJPerson"), @selector(sayHappy));
//        const char *type = method_getTypeEncoding(sayClassMethod);
//        return class_addMethod(objc_getMetaClass("TCJPerson"), sel, imp, type);
//    }
//
//    return [super resolveClassMethod:sel];
//}
@end
