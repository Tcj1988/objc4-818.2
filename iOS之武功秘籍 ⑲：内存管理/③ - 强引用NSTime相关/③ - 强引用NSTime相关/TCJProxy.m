//
//  TCJProxy.m
//  ③ - 强引用NSTime相关
//
//  Created by tangchangjiang on 2021/2/8.
//

#import "TCJProxy.h"

@interface TCJProxy ()
@property (nonatomic, weak) id object;
@end

@implementation TCJProxy
+ (instancetype)proxyWithTransformObject:(id)object{
    TCJProxy *proxy = [TCJProxy alloc];
    proxy.object = object;
    return proxy;
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    return self.object;
}

@end
