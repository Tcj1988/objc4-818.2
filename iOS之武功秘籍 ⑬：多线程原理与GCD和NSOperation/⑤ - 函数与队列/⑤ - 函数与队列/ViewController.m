//
//  ViewController.m
//  ⑤ - 函数与队列
//
//  Created by tangchangjiang on 2021/1/26.
//
#ifdef DEBUG
#define CJNSLog(format, ...) printf("%s\n", [[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String]);
#else
#define CJNSLog(format, ...);
#endif
#import "ViewController.h"
#import <objc/runtime.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 队列总共有几种 3 - 4
    // libdispatch.dylib - GCD 底层源码
    // 队列怎么创建 : DISPATCH_QUEUE_SERIAL / DISPATCH_QUEUE_CONCURRENT
    
    // OS_dispatch_queue_serial
    dispatch_queue_t serial = dispatch_queue_create("hello", DISPATCH_QUEUE_SERIAL);
    // OS_dispatch_queue_concurrent
    // OS_dispatch_queue_concurrent
    dispatch_queue_t conque = dispatch_queue_create("hello", DISPATCH_QUEUE_CONCURRENT);
    // DISPATCH_QUEUE_SERIAL max && 1
    // queue 对象 alloc init class
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    
    // 多个 - 集合
    dispatch_queue_t globQueue = dispatch_get_global_queue(0, 0);
    
    /*
     *  - DISPATCH_QUEUE_PRIORITY_HIGH:         QOS_CLASS_USER_INITIATED
     *  - DISPATCH_QUEUE_PRIORITY_DEFAULT:      QOS_CLASS_DEFAULT
     *  - DISPATCH_QUEUE_PRIORITY_LOW:          QOS_CLASS_UTILITY
     *  - DISPATCH_QUEUE_PRIORITY_BACKGROUND:   QOS_CLASS_BACKGROUND
     */
    
    CJNSLog(@"%@-%@-%@-%@",serial,conque,mainQueue,globQueue);
    
    // dispatch_async
    // block
    // block() 内部
    // block()
    // _dispatch_call_block_and_release
    // _dispatch_call_block_and_release()
    // 同步和异步函数
    dispatch_async(conque, ^{
        CJNSLog(@"12334");
    });
//
//    [self wbinterDemo];
    
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        CJNSLog(@"单例应用");
//    });
    
//    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
//    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
//    dispatch_semaphore_signal(sem);
//
//    dispatch_group_t group = dispatch_group_create();
//    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
//    dispatch_group_enter(group);
//    dispatch_group_leave(group);
//    dispatch_group_async(group, queue, ^{});
//    dispatch_group_notify(group, queue, ^{});


}

/**
 主队列同步
 不会开线程
 */
- (void)mainSyncTest{
    
    CJNSLog(@"0");
    // 等
    dispatch_sync(dispatch_get_main_queue(), ^{
        CJNSLog(@"1");
    });
    CJNSLog(@"2");
}
/**
 主队列异步
 不会开线程 顺序
 */
- (void)mainAsyncTest{
    CJNSLog(@"主线程-%@", [NSThread currentThread]);
    for (int i = 0; i < 5; i++) {
        dispatch_async(dispatch_get_main_queue(), ^{
            CJNSLog(@"1");
            CJNSLog(@"主线程-%@", [NSThread currentThread]);
        });
    }
    
    CJNSLog(@"2");
}

/**
 全局异步
 全局队列:一个并发队列
 */
- (void)globalAsyncTest{
    CJNSLog(@"主线程-%@", [NSThread currentThread]);
    for (int i = 0; i<20; i++) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            CJNSLog(@"%d-%@",i,[NSThread currentThread]);
        });
    }
    CJNSLog(@"hello queue");
}

/**
 全局同步
 全局队列:一个并发队列
 */
- (void)globalSyncTest{
    CJNSLog(@"主线程-%@", [NSThread currentThread]);
    for (int i = 0; i<20; i++) {
        dispatch_sync(dispatch_get_global_queue(0, 0), ^{
            CJNSLog(@"%d-%@",i,[NSThread currentThread]);
        });
    }
    CJNSLog(@"hello queue");
    
//    //主队列 + 全局并发队列的日常使用
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//            //执行耗时操作
//            dispatch_async(dispatch_get_main_queue(), ^{
//                //回到主线程进行UI操作
//            });
//        });
//
}

#pragma mark - 队列函数的应用

- (void)textDemo2{
    // 同步队列
    dispatch_queue_t queue = dispatch_queue_create("hello", NULL);
    CJNSLog(@"1");
    // 异步函数
    dispatch_async(queue, ^{
        CJNSLog(@"2");
        // 同步
        dispatch_sync(queue, ^{
            CJNSLog(@"3");
        });
//         CJNSLog(@"4");
    });
    CJNSLog(@"5");
    
    // 1 5 2 死锁
    //

}

- (void)textDemo1{
    
    dispatch_queue_t queue = dispatch_queue_create("hello", DISPATCH_QUEUE_CONCURRENT);
    CJNSLog(@"1");
    dispatch_async(queue, ^{
        CJNSLog(@"2");
        dispatch_sync(queue, ^{
            CJNSLog(@"3");
        });
        CJNSLog(@"4");
    });
    
    CJNSLog(@"5");

}

- (void)textDemo{
    
    dispatch_queue_t queue = dispatch_queue_create("hello", DISPATCH_QUEUE_CONCURRENT);
    CJNSLog(@"1");
    // 耗时
    dispatch_async(queue, ^{
        CJNSLog(@"2");
        dispatch_async(queue, ^{
            CJNSLog(@"3");
        });
        CJNSLog(@"4");
    });
    
    CJNSLog(@"5");

    // 15243
}

/**
 同步并发 : 堵塞 同步锁  队列 : resume supend   线程 操作, 队列挂起 任务能否执行
 */
- (void)concurrentSyncTest{
    CJNSLog(@"主线程-%@", [NSThread currentThread]);
    //1:创建并发队列
    dispatch_queue_t queue = dispatch_queue_create("hello", DISPATCH_QUEUE_CONCURRENT);
    for (int i = 0; i<20; i++) {
        dispatch_sync(queue, ^{
            CJNSLog(@"%d-%@",i,[NSThread currentThread]);
        });
    }
    CJNSLog(@"hello queue");
}


/**
 异步并发: 有了异步函数不一定开辟线程
 */
- (void)concurrentAsyncTest{
    CJNSLog(@"主线程-%@", [NSThread currentThread]);
    //1:创建并发队列
    dispatch_queue_t queue = dispatch_queue_create("hello", DISPATCH_QUEUE_CONCURRENT);
    for (int i = 0; i<20; i++) {
        dispatch_async(queue, ^{
            CJNSLog(@"%d-%@",i,[NSThread currentThread]);
        });
    }
    CJNSLog(@"hello queue");
}

/**
 串行异步队列
 */
- (void)serialAsyncTest{
    //1:创建串行队列
    CJNSLog(@"主线程-%@", [NSThread currentThread]);
    dispatch_queue_t queue = dispatch_queue_create("hello", DISPATCH_QUEUE_SERIAL);
//    dispatch_queue_t queue2 = dispatch_queue_create("hello", NULL);
    
    for (int i = 0; i<20; i++) {
        dispatch_async(queue, ^{
            CJNSLog(@"%d-%@",i,[NSThread currentThread]);
        });
    }
    CJNSLog(@"hello queue");
}

/**
 串行同步队列 : FIFO: 先进先出
 */
- (void)serialSyncTest{
    //1:创建串行队列
    CJNSLog(@"主线程-%@", [NSThread currentThread]);
    dispatch_queue_t queue = dispatch_queue_create("hello", DISPATCH_QUEUE_SERIAL);
    for (int i = 0; i<20; i++) {
        dispatch_sync(queue, ^{
            CJNSLog(@"%d-%@",i,[NSThread currentThread]);
        });
    }

}


/**
 * 还原最基础的写法,很重要
 */

- (void)syncTest{
    
//    dispatch_async(dispatch_queue_create("com.cj.cn", NULL), ^{
//        CJNSLog(@"hello GCD");
//    });
    
    // 把任务添加到队列 --> 函数
    // 任务 _t ref c对象
    dispatch_block_t block = ^{
        CJNSLog(@"hello GCD");
    };
    //串行队列
    dispatch_queue_t queue = dispatch_queue_create("com.cj.cn", NULL);
    // 函数
    dispatch_async(queue, block);
    
    // 函数 队列
    // 函数队列
    // block () - GCD 下层封装
    
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
       
        CJNSLog(@"%@",[NSThread currentThread]);
    });
}

- (void)wbinterDemo{//
    dispatch_queue_t queue = dispatch_queue_create("com.cj.cn", DISPATCH_QUEUE_CONCURRENT);
    // 1 2 3
    //  0 (7 8 9)
    dispatch_async(queue, ^{ // 耗时
        CJNSLog(@"1");
    });
    dispatch_async(queue, ^{
        CJNSLog(@"2");
    });
    
    // 堵塞哪一行
    dispatch_sync(queue, ^{
        CJNSLog(@"3");
    });
    
    CJNSLog(@"0");

    dispatch_async(queue, ^{
        CJNSLog(@"7");
    });
    dispatch_async(queue, ^{
        CJNSLog(@"8");
    });
    dispatch_async(queue, ^{
        CJNSLog(@"9");
    });
    // A: 1230789
    // B: 1237890
    // C: 3120798
    // D: 2137890
}

void testMethod(){
    sleep(3);
}

- (void)wbinterDemo2{
    
    // 耗能问题 - 同步和异步
    // 用 - 并发 多线程问题
    
    CFAbsoluteTime time = CFAbsoluteTimeGetCurrent();
    
    dispatch_queue_t queue = dispatch_queue_create("com.cj.cn", DISPATCH_QUEUE_SERIAL);
   
//    dispatch_async(queue, ^{
////        testMethod();
//    });
////
    dispatch_sync(queue, ^{
        //testMethod();
    });
//    testMethod();
        
    CJNSLog(@"%f",CFAbsoluteTimeGetCurrent()-time);
}

- (void)wbinterDemo3{
    
    dispatch_queue_t queue1 = dispatch_queue_create("com.cj2.cn", DISPATCH_QUEUE_CONCURRENT);

    dispatch_async(queue1, ^{
        CJNSLog(@"1");
    });
    dispatch_async(queue1, ^{
        CJNSLog(@"2");
    });

    dispatch_barrier_async(queue1, ^{
        CJNSLog(@"3");
    });
    dispatch_async(queue1, ^{
        CJNSLog(@"4");
    });
}

//1、NSThread创建
- (void)cj_createNSThread{
    NSString *threadName1 = @"NSThread1";
    NSString *threadName2 = @"NSThread2";
    NSString *threadName3 = @"NSThread3";
    NSString *threadNameMain = @"NSThreadMain";
    
    //方式一：初始化方式，需要手动启动
    NSThread *thread1 = [[NSThread alloc] initWithTarget:self selector:@selector(doSomething:) object:threadName1];
    [thread1 start];
    
    //方式二：构造器方式，自动启动
    [NSThread detachNewThreadSelector:@selector(doSomething:) toTarget:self withObject:threadName2];
    
    //方式三：performSelector...方法创建
    [self performSelectorInBackground:@selector(doSomething:) withObject:threadName3];
    
    //方式四
    [self performSelectorOnMainThread:@selector(doSomething:) withObject:threadNameMain waitUntilDone:YES];
    
    /*
     isExecuting    //线程是否在执行
     isCancelled    //线程是否被取消
     isFinished     //是否完成
     isMainThread   //是否是主线程
     threadPriority //线程的优先级，取值范围0.0-1.0,默认优先级0.5，1.0表示最高优先级，优先级高，CPU调度的频率高
     */
    
}
- (void)doSomething:(NSObject *)objc{
    NSLog(@"%@ - %@", objc, [NSThread currentThread]);
}

- (void)cj_NSThreadClassMethod{
    //当前线程
    [NSThread currentThread];
    // 如果number=1，则表示在主线程，否则是子线程
    NSLog(@"%@", [NSThread currentThread]);
    
    //阻塞休眠
    [NSThread sleepForTimeInterval:2];//休眠多久
    [NSThread sleepUntilDate:[NSDate date]];//休眠到指定时间
    
    //其他
    [NSThread exit];//退出线程
    [NSThread isMainThread];//判断当前线程是否为主线程
    [NSThread isMultiThreaded];//判断当前线程是否是多线程
    NSThread *mainThread = [NSThread mainThread];//主线程的对象
    NSLog(@"%@", mainThread);
}
    
@end
