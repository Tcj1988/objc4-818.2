//
//  TCJPerson.m
//  TCJObjc
//
//  Created by tangchangjiang on 2021/2/17.
//

#import "TCJPerson.h"
#import <objc/message.h>
#import "TCJStudent.h"
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

+ (BOOL)resolveInstanceMethod:(SEL)sel
{
    CJNSLog(@"%s -- %@来了",__func__,NSStringFromSelector(sel));
//    if (sel == @selector(say666)) {
//        CJNSLog(@"%s -- %@来了",__func__,NSStringFromSelector(sel));
//        IMP imp = class_getMethodImplementation(self, @selector(sayMaster));
//        Method sayMethod = class_getInstanceMethod(self, @selector(sayMaster));
//        const char *type = method_getTypeEncoding(sayMethod);
//        return class_addMethod(self, sel, imp, type);
//    }
    return [super resolveInstanceMethod:sel];
}
- (id)forwardingTargetForSelector:(SEL)aSelector{
    CJNSLog(@"%s -- %@来了",__func__,NSStringFromSelector(aSelector));
//    return [TCJStudent alloc];
    return [super forwardingTargetForSelector:aSelector];
}
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector{
    CJNSLog(@"%s -- %@来了",__func__,NSStringFromSelector(aSelector));
    return [NSMethodSignature signatureWithObjCTypes:"v@:"];
}
- (void)forwardInvocation:(NSInvocation *)anInvocation{
    CJNSLog(@"%s 来了",__func__);
}

@end
