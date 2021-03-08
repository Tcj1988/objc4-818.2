//
//  main.m
//  ④ - Block结构与签名
//
//  Created by tangchangjiang on 2021/1/22.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char * argv[]) {
    NSString * appDelegateClassName;
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
        // Block -> CJ
        // bref  结构体 拷贝 对象
        // bref  结构体 内存平移 -> lg_name
        __block NSString *cj_name = [NSString stringWithFormat:@"hello"];
        void (^block1)(void) = ^{ // block_copy
            cj_name = @"CJ";
            NSLog(@"CJ - %@",cj_name);
            
            // block 内存
        };
        block1();
    }
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
