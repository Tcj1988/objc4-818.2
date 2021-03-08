//
//  ViewController.m
//  ④ - NSLock分析
//
//  Created by tangchangjiang on 2021/1/21.
//
#ifdef DEBUG
#define CJNSLog(format, ...) printf("%s\n", [[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String]);
#else
#define CJNSLog(format, ...);
#endif
#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, strong) NSMutableArray *testArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//     [self cj_crash];
    [self cj_testRecursive];
    // NSLock 多 非常简单
//    NSLock *lock = [[NSLock alloc] init];
//    [lock lock];
//    [lock unlock];

    // @protocol NSLocking
    // 对下层 pthread 封装 GCD
}

#pragma mark -- NSLock

- (void)cj_crash{
    for (int i = 0; i < 200; i++) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            _testArray = [NSMutableArray array];
        });
    }
}

#pragma mark -- NSRecursiveLock

- (void)cj_testRecursive{

//    NSRecursiveLock *recursiveLock = [[NSRecursiveLock alloc] init];
//    NSLock *lock = [[NSLock alloc] init];
    // 睡觉等待
    // 嵌套 - 递归
    // 问题 lock 加载哪里 ???
    // @sys - recursiveLock
    // NSlock
    //
    
//    for (int i= 0; i<100; i++) {
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//            static void (^testMethod)(int);
//            testMethod = ^(int value){
//                if (value > 0) {
//                  CJNSLog(@"current value = %d",value);
//                  testMethod(value - 1);
//                }
//            };
//            testMethod(10);
//        });
//    }
    
//    NSLock *lock = [[NSLock alloc] init];
//    for (int i= 0; i<100; i++) {
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//            static void (^testMethod)(int);
//            testMethod = ^(int value){
//                [lock lock];
//                if (value > 0) {
//                  CJNSLog(@"current value = %d",value);
//                  testMethod(value - 1);
//                }
//            };
//            testMethod(10);
//            [lock unlock];
//        });
//    }

//    NSLock *lock = [[NSLock alloc] init];
//    for (int i= 0; i<100; i++) {
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//            static void (^testMethod)(int);
//            [lock lock];
//            testMethod = ^(int value){
//                if (value > 0) {
//                  CJNSLog(@"current value = %d",value);
//                  testMethod(value - 1);
//                }
//            };
//            testMethod(10);
//            [lock unlock];
//        });
//    }
    
//    for (int i= 0; i<100; i++) {
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//            static void (^testMethod)(int);
//            testMethod = ^(int value){
//                @synchronized (self) {
//                    if (value > 0) {
//                      CJNSLog(@"current value = %d",value);
//                      testMethod(value - 1);
//                    }
//                }
//            };
//            testMethod(10);
//        });
//    }
    
    
    NSRecursiveLock *recursiveLock = [[NSRecursiveLock alloc] init];
    for (int i = 0; i < 100; i++) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            static void (^testMethod)(int);
            [recursiveLock lock];
            testMethod = ^(int value){
                if (value > 0) {
                  CJNSLog(@"current value = %d",value);
                  testMethod(value - 1);
                }
            };
            testMethod(10);
            [recursiveLock unlock];
        });
    }
    
    // 多线程 - 单一线程 2 递归  + 3 4 5
//    NSRecursiveLock *recursiveLock = [[NSRecursiveLock alloc] init];
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        static void (^testMethod)(int);
//        testMethod = ^(int value){
//            [recursiveLock lock];
//            if (value > 0) {
//              CJNSLog(@"current value = %d",value);
//              testMethod(value - 1);
//            }
//            [recursiveLock unlock];
//        };
//        testMethod(10);
//    });

}


@end
