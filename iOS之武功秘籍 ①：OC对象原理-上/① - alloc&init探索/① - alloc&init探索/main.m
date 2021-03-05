//
//  main.m
//  ① - alloc&init探索
//
//  Created by tangchangjiang on 2020/9/18.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

// 底层  dyld 启动加载动态库
// libsytem
// 类 - 分类 方法 -协议 - 属性 对象
// runtime
// runloop
// kvc kvo
// ...
int main(int argc, char * argv[]) {
    NSString * appDelegateClassName;
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
    }
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
