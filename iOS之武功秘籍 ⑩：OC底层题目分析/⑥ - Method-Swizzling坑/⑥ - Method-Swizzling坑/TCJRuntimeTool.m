//
//  TCJRuntimeTool.m
//  ⑥ - Method-Swizzling坑
//
//  Created by tangchangjiang on 2021/2/24.
//
#ifdef DEBUG
#define CJNSLog(format, ...) printf("%s\n", [[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String]);
#else
#define CJNSLog(format, ...);
#endif
#import "TCJRuntimeTool.h"
#import <objc/runtime.h>

@implementation TCJRuntimeTool
+ (void)cj_methodSwizzlingWithClass:(Class)cls oriSEL:(SEL)oriSEL swizzledSEL:(SEL)swizzledSEL{
    
    if (!cls) CJNSLog(@"传入的交换类不能为空");

    Method oriMethod = class_getInstanceMethod(cls, oriSEL);
    Method swiMethod = class_getInstanceMethod(cls, swizzledSEL);
    method_exchangeImplementations(oriMethod, swiMethod);
}


+ (void)cj_betterMethodSwizzlingWithClass:(Class)cls oriSEL:(SEL)oriSEL swizzledSEL:(SEL)swizzledSEL{
    
    if (!cls) CJNSLog(@"传入的交换类不能为空");
    // oriSEL       personInstanceMethod
    // swizzledSEL  cj_studentInstanceMethod
    
    Method oriMethod = class_getInstanceMethod(cls, oriSEL);
    Method swiMethod = class_getInstanceMethod(cls, swizzledSEL);
   
    // 尝试添加
    BOOL success = class_addMethod(cls, oriSEL, method_getImplementation(swiMethod), method_getTypeEncoding(oriMethod));

    /**
     personInstanceMethod(sel) - cj_studentInstanceMethod(imp)
     cj_studentInstanceMethod (swizzledSEL) - personInstanceMethod(imp)
     */
    
    if (success) {// 自己没有 - 交换 - 没有父类进行处理 (重写一个)
        class_replaceMethod(cls, swizzledSEL, method_getImplementation(oriMethod), method_getTypeEncoding(oriMethod));
    }else{ // 自己有
        method_exchangeImplementations(oriMethod, swiMethod);
    }
    
    
}
@end
