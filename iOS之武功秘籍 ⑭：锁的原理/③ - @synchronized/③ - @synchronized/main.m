//
//  main.m
//  ③ - @synchronized
//
//  Created by tangchangjiang on 2021/1/21.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char * argv[]) {
    NSString * appDelegateClassName;
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
//        @synchronized (appDelegateClassName) {
//
//        }
    }
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
