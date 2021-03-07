//
//  main.m
//  ① - 应用程序加载分析
//
//  Created by tangchangjiang on 2021/2/18.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#ifdef DEBUG
#define CJNSLog(format, ...) printf("%s\n", [[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String]);
#else
#define CJNSLog(format, ...);
#endif

// 内存 main() dyld image init 注册回调通知 - dyld_start  -> dyld::main()  -> main()
int main(int argc, char * argv[]) {
    NSString * appDelegateClassName;
    
    CJNSLog(@"211111313");
    
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
    }
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}

// load -> Cxx -> main
__attribute__((constructor)) void cjFunc(){
    printf("来了 : %s \n",__func__);
}
