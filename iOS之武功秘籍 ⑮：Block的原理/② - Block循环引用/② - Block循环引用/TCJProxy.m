//
//  TCJProxy.m
//  ③ - 强引用NSTime相关
//
//  Created by tangchangjiang on 2021/2/8.
//

#import "TCJProxy.h"

@interface TCJProxy ()
@property (nonatomic, weak, readonly) NSObject *object;
@end

@implementation TCJProxy

- (id)transformObject:(NSObject *)object{
    _object = object;
    return self;
}

+ (instancetype)proxyWithTransformObject:(id)object{
    return [[self alloc] transformObject:object];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel{
    NSMethodSignature *signature;
    if (self.object) {
        signature = [self.object methodSignatureForSelector:sel];
    } else {
        signature = [super methodSignatureForSelector:sel];
    }
    return signature;
}

- (void)forwardInvocation:(NSInvocation *)invocation{
    SEL sel = [invocation selector];
    if ([self.object respondsToSelector:sel]) {
        [invocation invokeWithTarget:self.object];
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector{
    return [self.object respondsToSelector:aSelector];
}

//- (id)forwardingTargetForSelector:(SEL)aSelector {
//    return self.object;
//}

@end
