//
//  NSObject+TCJ.m
//  TCJObjc
//
//  Created by tangchangjiang on 2021/2/17.
//

#import "NSObject+TCJ.h"
#import <objc/message.h>
#ifdef DEBUG
#define CJNSLog(format, ...) printf("%s\n", [[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String]);
#else
#define CJNSLog(format, ...);
#endif

@implementation NSObject (TCJ)
// 调用方法的时候 - 分类

+ (BOOL)resolveInstanceMethod:(SEL)sel{
    
    if (sel == @selector(say666)) {
        CJNSLog(@"%@ 来了",NSStringFromSelector(sel));

        IMP imp           = class_getMethodImplementation(self, @selector(sayMaster));
        Method sayMethod = class_getInstanceMethod(self, @selector(sayMaster));
        const char *type  = method_getTypeEncoding(sayMethod);
        return class_addMethod(self, sel, imp, type);
    }
    else if (sel == @selector(sayNB)) {
        CJNSLog(@"%@ 来了",NSStringFromSelector(sel));
        IMP imp           = class_getMethodImplementation(objc_getMetaClass("TCJPerson"), @selector(sayHappy));
        Method sayMethod = class_getInstanceMethod(objc_getMetaClass("TCJPerson"), @selector(sayHappy));
        const char *type  = method_getTypeEncoding(sayMethod);
        return class_addMethod(objc_getMetaClass("TCJPerson"), sel, imp, type);
    }
    return NO;
}
@end
