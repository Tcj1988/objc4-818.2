//
//  ViewController.m
//  ③ - @synchronized
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
@property (nonatomic, assign) NSUInteger ticketCount;
@property (nonatomic, strong) NSMutableArray *testArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.ticketCount = 20;
//    [self cj_testSaleTicket];
    
//    _testArray = [NSMutableArray array];
//
    [self cj_crash];
}


- (void)cj_testSaleTicket{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (int i = 0; i < 5; i++) {
            [self saleTicket];
        }
    });
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (int i = 0; i < 5; i++) {
            [self saleTicket];
        }
    });
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (int i = 0; i < 3; i++) {
            [self saleTicket];
        }
    });
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (int i = 0; i < 10; i++) {
            [self saleTicket];
        }
    });
}

- (void)saleTicket{
    // 枷锁 - 线程安全
    // 研究 底层原理
    // 分析 请问怎么分析?
    // objc_sync_enter  lock
    // objc_sync_exit
    // libobjc.A.dylib
    // 思路 清晰
    @synchronized (self) {
        
        if (self.ticketCount > 0) {
            self.ticketCount--;
            sleep(0.1);
            CJNSLog(@"当前余票还剩：%ld张",self.ticketCount);
            
        }else{
            CJNSLog(@"当前车票已售罄");
        }

    }

}

- (void)cj_crash{
//    _testArray = [NSMutableArray array];
//    for (int i = 0; i < 200000; i++) {
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//           _testArray = [NSMutableArray array];
//        });
//    }
    
    self.testArray = [NSMutableArray array];
    NSLock *lock = [[NSLock alloc] init];
    for (int i = 0; i < 200000; i++) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [lock lock];
           self.testArray = [NSMutableArray array];
            [lock unlock];
        });
    }
}

@end
