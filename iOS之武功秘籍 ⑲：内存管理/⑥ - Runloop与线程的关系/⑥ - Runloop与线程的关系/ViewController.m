//
//  ViewController.m
//  ⑥ - Runloop与线程的关系
//
//  Created by tangchangjiang on 2021/2/9.
//

#ifdef DEBUG
#define CJNSLog(format, ...) printf("%s\n", [[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String]);
#else
#define CJNSLog(format, ...);
#endif

#import "ViewController.h"
#import "TCJThread.h"

@interface ViewController ()
@property (nonatomic, assign) BOOL isStopping;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // runloop 和 线程
    // 主运行循环
    CFRunLoopRef mainRunloop = CFRunLoopGetMain();
    // 当前运行循环
    CFRunLoopRef currentRunloop = CFRunLoopGetCurrent();

    // 子线程runloop 默认不启动
    
    self.isStopping = NO;
    TCJThread *thread = [[TCJThread alloc] initWithBlock:^{

        // thread.name = nil 因为这个变量只是捕捉
        // TCJThread *thread = nil
        // thread = 初始化 捕捉一个nil进来
        NSLog(@"%@---%@",[NSThread currentThread],[[NSThread currentThread] name]);
        [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
            CJNSLog(@"hello word");            // 退出线程--结果runloop也停止了
            if (self.isStopping) {
                [NSThread exit];
            }
        }];
         [[NSRunLoop currentRunLoop] run];
    }];

    thread.name = @"cjcode.com";
    [thread start];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
//    [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
//
//        CJNSLog(@"99999");
//    }];
    self.isStopping = YES;
}

@end
