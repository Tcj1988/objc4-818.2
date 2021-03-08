//
//  TCJTimerWapper.m
//  ③ - 强引用NSTime相关
//
//  Created by tangchangjiang on 2021/2/8.
//

#import "TCJTimerWapper.h"
#import <objc/message.h>

@interface TCJTimerWapper ()
@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL aSelector;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation TCJTimerWapper

// 中介者 vc dealloc
// objc 骚 vc -/-> TCJTimerWapper <-/- runloop
// vc 释放 fireHome

- (instancetype)cj_initWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo{
    if (self == [super init]) {
        self.target     = aTarget; // vc
        self.aSelector  = aSelector; // 方法 -- vc 释放
        
        if ([self.target respondsToSelector:self.aSelector]) {
            Method method = class_getInstanceMethod([self.target class], aSelector);
            const char *type = method_getTypeEncoding(method);
            //给timerWapper添加方法
            class_addMethod([self class], aSelector, (IMP)fireHomeWapper, type);
            
            //启动一个timer，target是self，即监听自己
            self.timer = [NSTimer scheduledTimerWithTimeInterval:ti target:self selector:aSelector userInfo:userInfo repeats:yesOrNo];
        }
    }
    return self;
}

// 一直跑 runloop
void fireHomeWapper(TCJTimerWapper *warpper){
    //判断target是否存在
    if (warpper.target) { // vc - dealloc
        //如果存在则需要让vc知道，即向传入的target发送selector消息，并将此时的timer参数也一并传入，所以vc就可以得知`fireHome`方法，就这事这种方式定时器方法能够执行的原因
         //objc_msgSend发送消息，执行定时器方法
        void (*cj_msgSend)(void *,SEL, id) = (void *)objc_msgSend;
        cj_msgSend((__bridge void *)(warpper.target), warpper.aSelector,warpper.timer);
    }else{ // warpper.target
        //如果target不存在，已经释放了，则释放当前的timerWrapper
        [warpper.timer invalidate];
        warpper.timer = nil;
    }
}

//在vc的dealloc方法中调用，通过vc释放，从而让timer释放
- (void)cj_invalidate{
    [self.timer invalidate];
    self.timer = nil;
}

- (void)dealloc{
    NSLog(@"%s",__func__);
}

@end
