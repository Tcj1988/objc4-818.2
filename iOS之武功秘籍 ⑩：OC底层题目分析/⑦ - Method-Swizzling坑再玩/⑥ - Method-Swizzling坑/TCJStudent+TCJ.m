//
//  TCJStudent+TCJ.m
//  ⑥ - Method-Swizzling坑
//
//  Created by tangchangjiang on 2021/2/24.
//
#ifdef DEBUG
#define CJNSLog(format, ...) printf("%s\n", [[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String]);
#else
#define CJNSLog(format, ...);
#endif
#import "TCJStudent+TCJ.h"
#import "TCJRuntimeTool.h"
#import <objc/runtime.h>

@implementation TCJStudent (TCJ)
+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 坑点报错
//        [TCJRuntimeTool cj_methodSwizzlingWithClass:self oriSEL:@selector(personInstanceMethod) swizzledSEL:@selector(cj_studentInstanceMethod)];
        // 修正坑点-再玩坑
//        [TCJRuntimeTool cj_betterMethodSwizzlingWithClass:self oriSEL:@selector(personInstanceMethod) swizzledSEL:@selector(cj_studentInstanceMethod)];
        [TCJRuntimeTool cj_bestMethodSwizzlingWithClass:self oriSEL:@selector(personInstanceMethod) swizzledSEL:@selector(cj_studentInstanceMethod)];
        
    });
}

// personInstanceMethod 我需要父类的这个方法的一些东西
// 给你加一个personInstanceMethod 方法
// imp

- (void)cj_studentInstanceMethod{
    [self cj_studentInstanceMethod];
    CJNSLog(@"TCJStudent分类添加的cj对象方法:%s",__func__);
}

+ (void)cj_studentClassMethod{
    CJNSLog(@"TCJStudent分类添加的lg类方法:%s",__func__);
   [[self class] cj_studentClassMethod];
}
@end
