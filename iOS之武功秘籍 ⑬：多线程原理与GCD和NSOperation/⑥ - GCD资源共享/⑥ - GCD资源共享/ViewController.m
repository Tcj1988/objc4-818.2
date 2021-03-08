//
//  ViewController.m
//  ⑥ - GCD资源共享
//
//  Created by tangchangjiang on 2021/1/26.
//
#ifdef DEBUG
#define CJNSLog(format, ...) printf("%s\n", [[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String]);
#else
#define CJNSLog(format, ...);
#endif
#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, assign) NSInteger tickets;
@property (nonatomic, strong) dispatch_queue_t queue;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 准备票数
    _tickets = 20;
    // 创建串行队列
    _queue = dispatch_queue_create("hello", DISPATCH_QUEUE_SERIAL);
    
    [self cj_testGroup2];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    // 第一个线程卖票
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self saleTickes];
    });

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // 第二个线程卖票
        [self saleTickes];
    });

}

- (void)saleTickes {
    
    while (self.tickets > 0) {
        // 模拟延时
        [NSThread sleepForTimeInterval:1.0];
        // 苹果不推荐程序员使用互斥锁，串行队列同步任务可以达到同样的效果！
        // @synchronized
        // 使用串行队列，同步任务卖票
        dispatch_sync(_queue, ^{
            // 检查票数
            if (self.tickets > 0) {
                self.tickets--;
                CJNSLog(@"还剩 %zd %@", self.tickets, [NSThread currentThread]);
            } else {
                CJNSLog(@"没有票了");
            }
        });
    }
}

- (void)cj_testAfter{
    /*
     dispatch_after表示在某队列中的block延迟执行
     应用场景：在主队列上延迟执行一项任务，如viewDidload之后延迟1s，提示一个alertview（是延迟加入到队列，而不是延迟执行）
     */
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CJNSLog(@"2s后输出");
    });
}

- (void)cj_testOnce{
    /*
     dispatch_once保证在App运行期间，block中的代码只执行一次
     应用场景：单例、method-Swizzling
     */
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //创建单例、method swizzled或其他任务
        CJNSLog(@"创建单例");
    });
}

- (void)cj_testApply{
    /*
     dispatch_apply将指定的Block追加到指定的队列中重复执行，并等到全部的处理执行结束——相当于线程安全的for循环

     应用场景：用来拉取网络数据后提前算出各个控件的大小，防止绘制时计算，提高表单滑动流畅性
     - 添加到串行队列中——按序执行
     - 添加到主队列中——死锁
     - 添加到并发队列中——乱序执行
     - 添加到全局队列中——乱序执行
     */
    
    dispatch_queue_t queue = dispatch_queue_create("CJ", DISPATCH_QUEUE_SERIAL);
    CJNSLog(@"dispatch_apply前");
    /**
         param1：重复次数
         param2：追加的队列
         param3：执行任务
         */
    dispatch_apply(10, queue, ^(size_t index) {
        CJNSLog(@"dispatch_apply 的线程 %zu - %@", index, [NSThread currentThread]);
    });
    CJNSLog(@"dispatch_apply后");
}

- (void)cj_testGroup1{
    /*
     dispatch_group_t：调度组将任务分组执行，能监听任务组完成，并设置等待时间

     应用场景：多个接口请求之后刷新页面
     */
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    dispatch_group_async(group, queue, ^{
        CJNSLog(@"请求一完成");
    });
    
    dispatch_group_async(group, queue, ^{
        CJNSLog(@"请求二完成");
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        CJNSLog(@"刷新页面");
    });
}

- (void)cj_testGroup2{
    /*
     dispatch_group_enter和dispatch_group_leave成对出现，使进出组的逻辑更加清晰
     */
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        CJNSLog(@"请求一完成");
        dispatch_group_leave(group);
    });
    
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        CJNSLog(@"请求二完成");
        dispatch_group_leave(group);
    });
    
    dispatch_group_async(group, queue, ^{
        CJNSLog(@"请求三完成");
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        CJNSLog(@"刷新界面");
    });
}

- (void)cj_testGroup3{
    /*
     long dispatch_group_wait(dispatch_group_t group, dispatch_time_t timeout)

     group：需要等待的调度组
     timeout：等待的超时时间（即等多久）
        - 设置为DISPATCH_TIME_NOW意味着不等待直接判定调度组是否执行完毕
        - 设置为DISPATCH_TIME_FOREVER则会阻塞当前调度组，直到调度组执行完毕


     返回值：为long类型
        - 返回值为0——在指定时间内调度组完成了任务
        - 返回值不为0——在指定时间内调度组没有按时完成任务

     */
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        CJNSLog(@"请求一完成");
        dispatch_group_leave(group);
    });
    
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        CJNSLog(@"请求二完成");
        dispatch_group_leave(group);
    });
    
//    long timeout = dispatch_group_wait(group, DISPATCH_TIME_NOW);
//    long timeout = dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    long timeout = dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, 1 *NSEC_PER_SEC));
    CJNSLog(@"timeout = %ld", timeout);
    if (timeout == 0) {
        CJNSLog(@"按时完成任务");
    }else{
        CJNSLog(@"超时");
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        CJNSLog(@"刷新界面");
    });
}

/*
 dispatch_barrier_sync & dispatch_barrier_async
 
 应用场景：同步锁
 
 等栅栏前追加到队列中的任务执行完毕后，再将栅栏后的任务追加到队列中。
 简而言之，就是先执行栅栏前任务，再执行栅栏任务，最后执行栅栏后任务
 
 - dispatch_barrier_async：前面的任务执行完毕才会来到这里
 - dispatch_barrier_sync：作用相同，但是这个会堵塞线程，影响后面的任务执行

 - dispatch_barrier_async可以控制队列中任务的执行顺序，
 - 而dispatch_barrier_sync不仅阻塞了队列的执行，也阻塞了线程的执行（尽量少用）
 */
- (void)cj_testBarrier1{
    //串行队列使用栅栏函数
    
    dispatch_queue_t queue = dispatch_queue_create("CJ", DISPATCH_QUEUE_SERIAL);
    
    CJNSLog(@"开始 - %@", [NSThread currentThread]);
    dispatch_async(queue, ^{
        sleep(2);
        CJNSLog(@"延迟2s的任务1 - %@", [NSThread currentThread]);
    });
    CJNSLog(@"第一次结束 - %@", [NSThread currentThread]);
    
    //栅栏函数的作用是将队列中的任务进行分组，所以我们只要关注任务1、任务2
    dispatch_barrier_async(queue, ^{
        CJNSLog(@"------------栅栏任务------------%@", [NSThread currentThread]);
    });
    CJNSLog(@"栅栏结束 - %@", [NSThread currentThread]);
    
    dispatch_async(queue, ^{
        sleep(1);
        CJNSLog(@"延迟1s的任务2 - %@", [NSThread currentThread]);
    });
    CJNSLog(@"第二次结束 - %@", [NSThread currentThread]);
}

- (void)cj_testBarrier2{
    //并发队列使用栅栏函数
    
    dispatch_queue_t queue = dispatch_queue_create("CJ", DISPATCH_QUEUE_CONCURRENT);
    
    CJNSLog(@"开始 - %@", [NSThread currentThread]);
    dispatch_async(queue, ^{
        sleep(2);
        CJNSLog(@"延迟2s的任务1 - %@", [NSThread currentThread]);
    });
    CJNSLog(@"第一次结束 - %@", [NSThread currentThread]);
    
    //由于并发队列异步执行任务是乱序执行完毕的，所以使用栅栏函数可以很好的控制队列内任务执行的顺序
    dispatch_barrier_async(queue, ^{
        CJNSLog(@"------------栅栏任务------------%@", [NSThread currentThread]);
    });
    CJNSLog(@"栅栏结束 - %@", [NSThread currentThread]);
    
    dispatch_async(queue, ^{
        sleep(1);
        CJNSLog(@"延迟1s的任务2 - %@", [NSThread currentThread]);
    });
    CJNSLog(@"第二次结束 - %@", [NSThread currentThread]);
}

- (void)test {
    dispatch_queue_t queue = dispatch_queue_create("hello", DISPATCH_QUEUE_CONCURRENT);
    
    for (int i = 0; i < 10; i++) {
        dispatch_async(queue, ^{
            CJNSLog(@"当前%d----线程%@", i, [NSThread currentThread]);
        });
        // 使用栅栏函数
//        dispatch_barrier_async(queue, ^{});
    }
}

- (void)test1 {
    // 创建信号量
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    dispatch_queue_t queue = dispatch_queue_create("hello", DISPATCH_QUEUE_CONCURRENT);
    
    for (int i = 0; i < 10; i++) {
        dispatch_async(queue, ^{
            CJNSLog(@"当前%d----线程%@", i, [NSThread currentThread]);
            // 打印任务结束后信号量解锁
            dispatch_semaphore_signal(sem);
        });
        // 由于异步执行，打印任务会较慢，所以这里信号量加锁
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
}

- (void)cj_testSource{
    /*
     dispatch_source
     
     应用场景：GCDTimer
     在iOS开发中一般使用NSTimer来处理定时逻辑，但NSTimer是依赖Runloop的，而Runloop可以运行在不同的模式下。如果NSTimer添加在一种模式下，当Runloop运行在其他模式下的时候，定时器就挂机了；又如果Runloop在阻塞状态，NSTimer触发时间就会推迟到下一个Runloop周期。因此NSTimer在计时上会有误差，并不是特别精确，而GCD定时器不依赖Runloop，计时精度要高很多
     
     dispatch_source是一种基本的数据类型，可以用来监听一些底层的系统事件
        - Timer Dispatch Source：定时器事件源，用来生成周期性的通知或回调
        - Signal Dispatch Source：监听信号事件源，当有UNIX信号发生时会通知
        - Descriptor Dispatch Source：监听文件或socket事件源，当文件或socket数据发生变化时会通知
        - Process Dispatch Source：监听进程事件源，与进程相关的事件通知
        - Mach port Dispatch Source：监听Mach端口事件源
        - Custom Dispatch Source：监听自定义事件源

     主要使用的API：
        - dispatch_source_create: 创建事件源
        - dispatch_source_set_event_handler: 设置数据源回调
        - dispatch_source_merge_data: 设置事件源数据
        - dispatch_source_get_data： 获取事件源数据
        - dispatch_resume: 继续
        - dispatch_suspend: 挂起
        - dispatch_cancle: 取消
     */
    
    //1.创建队列
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    //2.创建timer
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    //3.设置timer首次执行时间，间隔，精确度
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 2.0*NSEC_PER_SEC, 0.1*NSEC_PER_SEC);
    //4.设置timer事件回调
    dispatch_source_set_event_handler(timer, ^{
        NSLog(@"GCDTimer");
    });
    //5.默认是挂起状态，需要手动激活
    dispatch_resume(timer);
    
}

@end
