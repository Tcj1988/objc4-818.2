//
//  ViewController.m
//  ③ - 资源共享
//
//  Created by tangchangjiang on 2021/1/26.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, assign) NSInteger tickets;
@property (nonatomic, strong) NSMutableArray *mArray;
/**
 atomic     是原子属性，是为多线程开发准备的，是默认属性！
            仅仅在属性的 `setter` 方法中，增加了锁(自旋锁)，能够保证同一时间，只有一条线程对属性进行`写`操作
            同一时间 单(线程)写多(线程)读的线程处理技术
 nonatomic  是非原子属性
            没有锁！性能高！
 */
@property (nonatomic, copy)   NSString *name;
@end

@implementation ViewController

// 在 OC 中，如果同时重写 了 setter & getter 方法，系统不再提供 _成员变量，需要使用合成指令
// @synthesize name 取个别名:_name
@synthesize name = _name;
#pragma mark - 模拟原子属性示例代码
- (NSString *)name {
    return _name;
}
- (void)setName:(NSString *)name {
    /**
     * 增加一把锁，就能够保证一条线程在同一时间写入!
     */
    @synchronized (self) {
        _name = name;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
        // 同步 ---
        // > 0
        // GCD 控制并发数

    self.name = @"cj"; // 写 - 读
    // 读 不会影响写
    // 子线程runloop 默认不开启
    // 开启的子线程 - 不会执行
    // runloop = dict[key 线程指针]
    // 保证不退出
    // 常驻线程 do while
    // runloop
    //
    
    NSThread *t1 = [[NSThread alloc] initWithTarget:self selector:@selector(childThreadTimer) object:nil];
    t1.name = @"售票 A";
    
    [t1 start];

    

}

- (void)childThreadTimer{
    
    NSLog(@"%@ - %@",[NSThread currentThread],[NSThread currentThread].name);

    
    // runloop
    // run -- doit
    // addtimer - addrunloop
//    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(fireHome) userInfo:nil repeats:YES];
    
//    [[NSRunLoop currentRunLoop] run];
}


- (void)fireHome{
    NSLog(@"122");
}



- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.tickets = 20;

    
    // 资源问题
    // 数据库
    // 增删改查
    // 199 -- 100
    
    // 1. 开启一条售票线程
//    NSThread *t1 = [[NSThread alloc] initWithTarget:self selector:@selector(saleTickets) object:nil];
//    t1.name = @"售票 A";
//    [t1 start];
//
//    // 2. 再开启一条售票线程
//    NSThread *t2 = [[NSThread alloc] initWithTarget:self selector:@selector(saleTickets) object:nil];
//    t2.name = @"售票 B";
//    [t2 start];
    
 
    
    dispatch_semaphore_t lock =  dispatch_semaphore_create(100);
    for (int i = 0; i < 1000; i++) {
        dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            sleep(5);
            NSLog(@"%d-%@",i,[NSThread currentThread]);
            dispatch_semaphore_signal(lock);
            NSLog(@"*************");

        });

    }

}
- (void)saleTickets {
    
    // runloop & 线程 不是一一对应
    
    while (YES) {
        // 0. 模拟延时
    
        //NSObject *obj = [[NSObject alloc] init];
        //obj 是自己的临时对象,对其他访问该区域的无影响
        //可以锁self 那么访问该方法的时候所有的都锁住,可以根据需求特定锁
        @synchronized(self){
        // 递归 非递归
            [NSThread sleepForTimeInterval:1];
            // 1. 判断是否还有票
            if (self.tickets > 0) {
                // 2. 如果有票，卖一张，提示用户
                self.tickets--;
                NSLog(@"剩余票数 %zd %@", self.tickets, [NSThread currentThread]);
            } else {
                // 3. 如果没票，退出循环
                NSLog(@"没票了，来晚了 %@", [NSThread currentThread]);
                break;
            }
            //在锁里面操作其他的变量的影响
            [self.mArray addObject:[NSDate date]];
            NSLog(@"%@ *** %@",[NSThread currentThread],self.mArray);
        }
    }
    
}


#pragma mark - lazy

- (NSMutableArray *)mArray{
    if (!_mArray) {
        _mArray = [NSMutableArray arrayWithCapacity:10];
    }
    return _mArray;
}


@end
