//
//  ViewController.m
//  ⑦ - NSOperation
//
//  Created by tangchangjiang on 2021/1/27.
//
#ifdef DEBUG
#define CJNSLog(format, ...) printf("%s\n", [[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String]);
#else
#define CJNSLog(format, ...);
#endif
#import "ViewController.h"
#import "TCJOperation.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self cj_testOperationNoti];
}

//线程间通讯
- (void)cj_testOperationNoti{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.name = @"CJ";
    [queue addOperationWithBlock:^{
        CJNSLog(@"请求网络%@--%@", [NSOperationQueue currentQueue], [NSThread currentThread]);
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            CJNSLog(@"刷新UI%@--%@", [NSOperationQueue currentQueue], [NSThread currentThread]);
        }];
    }];

    // 挂起
    queue.suspended = YES;
    // 继续
    queue.suspended = NO;
    // 取消
    [queue cancelAllOperations];

}

//添加依赖
- (void)cj_testOperationDependency{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    NSBlockOperation *bo1 = [NSBlockOperation blockOperationWithBlock:^{
        CJNSLog(@"你好");
    }];
    
    NSBlockOperation *bo2 = [NSBlockOperation blockOperationWithBlock:^{
        CJNSLog(@"我很好");
    }];
    
    NSBlockOperation *bo3 = [NSBlockOperation blockOperationWithBlock:^{
        CJNSLog(@"他好不好");
    }];
    
    [bo2 addDependency:bo1];
    [bo3 addDependency:bo2];
    [queue addOperations:@[bo1,bo2,bo3] waitUntilFinished:YES];
    CJNSLog(@"执行完了?我要干其他事");
}

//设置并发数
- (void)cj_testOperationMaxCount{
    /*
     在GCD中只能使用信号量来设置并发数
     而NSOperation轻易就能设置并发数
     通过设置maxConcurrentOperationCount来控制单次出队列去执行的任务数
     */
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.name = @"CJ";
    queue.maxConcurrentOperationCount = 1;
    
    for (int i = 0; i < 5; i++) {
        [queue addOperationWithBlock:^{ // 一个任务
          
            CJNSLog(@"%d-%@",i,[NSThread currentThread]);
        }];
    }
}

- (void)cj_testOperationQuality{
    /*
     NSOperation设置优先级只会让CPU有更高的几率调用，不是说设置高就一定全部先完成
     - 不使用sleep——高优先级的任务一先于低优先级的任务二
     - 使用sleep进行延时——高优先级的任务一慢于低优先级的任务二
     */
    NSBlockOperation *bo1 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 5; i++) {
            sleep(1);
            CJNSLog(@"第一个操作 %d --- %@", i, [NSThread currentThread]);
        }
    }];
    // 设置最高优先级
    bo1.qualityOfService = NSQualityOfServiceUserInteractive;
    
    NSBlockOperation *bo2 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 5; i++) {
            CJNSLog(@"第二个操作 %d --- %@", i, [NSThread currentThread]);
        }
    }];
    // 设置最低优先级
    bo2.qualityOfService = NSQualityOfServiceBackground;
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:bo1];
    [queue addOperation:bo2];
}

- (void)cj_testOperationQueue {
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    for (int i = 0; i < 5; i++) {
        [queue addOperationWithBlock:^{
            CJNSLog(@"%@---%d", [NSThread currentThread], i);
        }];
    }
}


//运用继承自NSOperation的子类 首先我们定义一个继承自NSOperation的类，然后重写它的main方法
- (void)cj_customOperation
{
    //1.封装操作
    TCJOperation *op1 = [[TCJOperation alloc]init];
    //2.创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    //3.添加操作到队列
    [queue addOperation:op1];
}

//基本使用
- (void)cj_invocationOpeation{
    //处理事务
    NSInvocationOperation *op =  [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(handleInvocation:) object:@"CJ"];
    //创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    //操作加入队列
    [queue addOperation:op];
    
}

- (void)cj_invocationOpeation1{
    NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(handleInvocation:) object:@"CJ"];
    [op start];
}

- (void)cj_invocationOpeation2 {
    NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(handleInvocation:) object:@"CJ"];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:op];
    [op start];
}

- (void)handleInvocation:(id)operation{
    CJNSLog(@"%@ - %@", operation, [NSThread currentThread]);
}

- (void)cj_blockOperation {
    // 初始化添加事务
    NSBlockOperation *bo = [NSBlockOperation blockOperationWithBlock:^{
        CJNSLog(@"任务1————%@",[NSThread currentThread]);
    }];
    // 添加事务
    [bo addExecutionBlock:^{
        CJNSLog(@"任务2————%@",[NSThread currentThread]);
    }];
    // 回调监听
    bo.completionBlock = ^{
        CJNSLog(@"完成了!!!");
    };
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:bo];
    CJNSLog(@"事务添加进了NSOperationQueue");
}

- (void)cj_blockOperation1{
    //通过addExecutionBlock这个方法可以让NSBlockOperation实现多线程.
    //NSBlockOperation创建时block中的任务是在主线程执行，而运用addExecutionBlock加入的任务是在子线程执行的.
    NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
        CJNSLog(@"1------- %@", [NSThread currentThread]);
    }];
    
    [blockOperation addExecutionBlock:^{
        CJNSLog(@"2------- %@", [NSThread currentThread]);
    }];
    
    [blockOperation addExecutionBlock:^{
        CJNSLog(@"3------- %@", [NSThread currentThread]);
    }];
    
    [blockOperation addExecutionBlock:^{
        CJNSLog(@"4------- %@", [NSThread currentThread]);
    }];
    
    [blockOperation start];
}


@end
