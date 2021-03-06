//
//  TCJPerson.m
//  ⑤ - instrumentObjcMessageSends辅助分析
//
//  Created by tangchangjiang on 2021/2/18.
//

#import "TCJPerson.h"
#import "TCJStudent.h"
#ifdef DEBUG
#define CJNSLog(format, ...) printf("%s\n", [[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String]);
#else
#define CJNSLog(format, ...);
#endif

@implementation TCJPerson

- (id)forwardingTargetForSelector:(SEL)aSelector{
    CJNSLog(@"%s -- %@",__func__,NSStringFromSelector(aSelector));
//    return [TCJStudent alloc];
//    return [super forwardingTargetForSelector:aSelector];
    return nil;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector{
    CJNSLog(@"%s -- %@",__func__,NSStringFromSelector(aSelector));
    return [NSMethodSignature signatureWithObjCTypes:"v@:"];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation{
    CJNSLog(@"%s -- %@",__func__,anInvocation);
    //第一种写法
//    if ([[TCJStudent alloc] respondsToSelector:[anInvocation selector]]) {
//        [anInvocation invokeWithTarget:[TCJStudent alloc]];
//    }else{
//        [super forwardInvocation:anInvocation];
//    }
    //第二种写法
//    anInvocation.target = [TCJStudent alloc];
//    [anInvocation invoke];
    //第三种写法
//    [anInvocation invokeWithTarget:[TCJStudent alloc]];
    
    //第四种,什么都不做处理
}

@end
