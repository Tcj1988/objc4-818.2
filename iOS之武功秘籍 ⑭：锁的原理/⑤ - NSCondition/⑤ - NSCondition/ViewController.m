//
//  ViewController.m
//  ⑤ - NSCondition
//
//  Created by tangchangjiang on 2021/1/21.
//
#ifdef DEBUG
#define CJNSLog(format, ...) printf("%s\n", [[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String]);
#else
#define CJNSLog(format, ...);
#endif
#import "ViewController.h"
#import "TCJLock.h"

@interface ViewController ()
@property (nonatomic, assign) NSUInteger ticketCount;
@property (nonatomic, strong) NSCondition *testCondition;
@property (nonatomic, strong) TCJLock *myLock;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.ticketCount = 0;
//    self.myLock = [[TCJLock alloc] init];
    [self cj_testConditonLock];
}

#pragma mark -- NSCondition
- (void)cj_testConditon{
    
    _testCondition = [[NSCondition alloc] init];
    //创建生产-消费者
    for (int i = 0; i < 50; i++) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [self cj_producer];
        });
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [self cj_consumer];
        });
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [self cj_consumer];
        });
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [self cj_producer];
        });
    }
}

- (void)cj_producer{
    [_testCondition lock]; // 操作的多线程影响
    self.ticketCount = self.ticketCount + 1;
    CJNSLog(@"生产一个 现有 count %zd",self.ticketCount);
    [_testCondition signal]; // 信号
    [_testCondition unlock];
}

- (void)cj_consumer{
 
     [_testCondition lock];  // 操作的多线程影响
    if (self.ticketCount == 0) {
        CJNSLog(@"等待 count %zd",self.ticketCount);
        [_testCondition wait];
    }
    //注意消费行为，要在等待条件判断之后
    self.ticketCount -= 1;
    CJNSLog(@"消费一个 还剩 count %zd ",self.ticketCount);
     [_testCondition unlock];
}

// swift NSlock
// 条件变量
// 条件锁 有什么关系
// 汇编 - arm64 底层
// 要明白 你想探索的是什么  NSConditionLock -> NSCondition 封装 -> pthread

#pragma mark -- NSConditionLock
- (void)cj_testConditonLock{
    // 信号量
    NSConditionLock *conditionLock = [[NSConditionLock alloc] initWithCondition:2];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
         [conditionLock lockWhenCondition:1]; // conditoion = 1 内部 Condition 匹配
        // -[NSConditionLock lockWhenCondition: beforeDate:]
        CJNSLog(@"线程 1");
         [conditionLock unlockWithCondition:0];
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
       
        [conditionLock lockWhenCondition:2];
        sleep(0.1);
        CJNSLog(@"线程 2");
        // self.myLock.value = 1;
        [conditionLock unlockWithCondition:1]; // _value = 2 -> 1
    });
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
       
       [conditionLock lock];
        CJNSLog(@"线程 3");
       [conditionLock unlock];
    });
}

- (void)cj_testInit{
    
    //初始化
    NSCondition *condition = [[NSCondition alloc] init];

    //一般用于多线程同时访问、修改同一个数据源，保证在同一 时间内数据源只被访问、修改一次，其他线程的命令需要在lock 外等待，只到 unlock ，才可访问
    [condition lock];

    //与lock 同时使用
    [condition unlock];

    //让当前线程处于等待状态
    [condition wait];

    //CPU发信号告诉线程不用在等待，可以继续执行
    [condition signal];
    
}
@end
