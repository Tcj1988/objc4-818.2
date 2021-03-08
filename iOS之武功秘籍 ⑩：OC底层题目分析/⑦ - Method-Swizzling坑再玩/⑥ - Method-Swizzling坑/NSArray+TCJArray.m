//
//  NSArray+TCJArray.m
//  ⑥ - Method-Swizzling坑
//
//  Created by tangchangjiang on 2021/2/24.
//

#import "NSArray+TCJArray.h"
#import <objc/runtime.h>

@implementation NSArray (TCJArray)
//如果下面代码不起作用，造成这个问题的原因大多都是其调用了super load方法。在下面的load方法中，不应该调用父类的load方法。这样会导致方法交换无效
+ (void)load{
    Method fromMethod = class_getInstanceMethod(objc_getClass("__NSArrayI"), @selector(objectAtIndex:));
    Method toMethod = class_getInstanceMethod(objc_getClass("__NSArrayI"), @selector(cj_objectAtIndex:));
    method_exchangeImplementations(fromMethod, toMethod);
}
//如果下面代码不起作用，造成这个问题的原因大多都是其调用了super load方法。在下面的load方法中，不应该调用父类的load方法。这样会导致方法交换无效
- (id)cj_objectAtIndex:(NSUInteger)index{
    //判断下标是否越界，如果越界就进入异常拦截
    if (self.count-1 < index) {
        // 这里做一下异常处理，不然都不知道出错了。
#ifdef DEBUG  // 调试阶段
        return [self cj_objectAtIndex:index];
#else // 发布阶段
        @try {
            return [self cj_objectAtIndex:index];
        } @catch (NSException *exception) {
            // 在崩溃后会打印崩溃信息，方便我们调试。
            NSLog(@"---------- %s Crash Because Method %s  ----------\n", class_getName(self.class), __func__);
            NSLog(@"%@", [exception callStackSymbols]);
            return nil;
        } @finally {
            
        }
#endif
    }else{ // 如果没有问题，则正常进行方法调用
        return [self cj_objectAtIndex:index];
    }
}
@end
