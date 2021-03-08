//
//  TCJTimerViewController.m
//  ③ - 强引用NSTime相关
//
//  Created by tangchangjiang on 2021/2/8.
//

#ifdef DEBUG
#define CJNSLog(format, ...) printf("%s\n", [[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String]);
#else
#define CJNSLog(format, ...);
#endif

#import "TCJTimerViewController.h"
#import <objc/runtime.h>
#import "TCJTimerWapper.h"
#import "TCJProxy.h"

static int num = 0;

@interface TCJTimerViewController ()
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) id  target;
@property (nonatomic, strong) TCJTimerWapper *timerWapper;
@property (nonatomic, strong) TCJProxy *proxy;
@end

@implementation TCJTimerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    CJNSLog(@"%ld",CFGetRetainCount((__bridge CFTypeRef)self));
    
    // self.timer -> self 释放不掉
    // timer vc 对象 内存
    // self -> timer - weakSelf -> self 循环
    // [NSRunLoop currentRunLoop] 强持有 -> timer -> weakSelf -> self
    // block -> 指针地址
    // self -> block - weakSelf -> self
    
    // weakSelf : 没有对内存加1
    
    // 对象的地址
    // self 的地址 和 weakSelf 的地址不一样!!!!
    // self -> block -> weakSelf (临时变量的指针地址) 地址->内存
    // weakSelf 能够释放
    // 强持有 - 对象
    // timer : <TCJTimerViewController: 0x7fa46f62a2f0>
    // NSRunLoop -> timer -> weakSelf (<TCJTimerViewController: 0x7fa46f62a2f0>)
    
//    __weak typeof(self) weakSelf = self;
//    CJNSLog(@"%ld",CFGetRetainCount((__bridge CFTypeRef)self));
//    self.timer = [NSTimer timerWithTimeInterval:1 target:weakSelf selector:@selector(fireHome) userInfo:nil repeats:YES];
//    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    
    // 解决思路 : 我们需要打破这一层强持有 - self
    
    // 思路一: dealloc 不能来 那我们能不能看看有没有其他的方法在pop的时候 就销毁timer
    // 把 核心timer 销毁 那么 强持有 - 循环引用就不存在
    
    // 思路二: 中介者模式 - 不方便使用 self
    // 换其他对象
//     self.target = [[NSObject alloc] init];
//     class_addMethod([NSObject class], @selector(fireHome), (IMP)fireHomeObjc, "v@:");
//     self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self.target selector:@selector(fireHome) userInfo:nil repeats:YES];
    
    // 思路三: 感觉 NSObject 这里写在这里好恶心! 裹脚布藏起来
//     self.timerWapper = [[TCJTimerWapper alloc] cj_initWithTimeInterval:1 target:self selector:@selector(fireHome) userInfo:nil repeats:YES];
    
    // 思路四: proxy 虚基类的方式
    self.proxy = [TCJProxy proxyWithTransformObject:self];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self.proxy selector:@selector(fireHome) userInfo:nil repeats:YES];
}

// 思路一: dealloc 不能来 那我们能不能看看有没有其他的方法在pop的时候 就销毁timer
// 把 核心timer 销毁 那么 强持有 - 循环引用就不存在
//- (void)didMoveToParentViewController:(UIViewController *)parent{
//    // 无论push 进来 还是 pop 出去 正常跑
//    // 就算继续push 到下一层 pop 回去还是继续
//    if (parent == nil) {
//       [self.timer invalidate];
//        self.timer = nil;
//        CJNSLog(@"timer 走了");
//    }
//}

// 与业务不符
//- (void)viewWillDisappear:(BOOL)animated{
//    [super viewWillDisappear:animated];
//    // push 到下一层返回就不走了!!!
//    [self.timer invalidate];
//    self.timer = nil;
//    CJNSLog(@"timer 走了");
//}

//定义timer时，采用闭包的形式，因此不需要指定target
//- (void)blockTimer{
//    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
//        CJNSLog(@"timer fire - %@",timer);
//    }];
//}

//void fireHomeObjc(id obj){
//    CJNSLog(@"%s -- %@",__func__,obj);
//}

- (void)fireHome{
    num++;
    CJNSLog(@"hello word - %d",num);
}

- (void)dealloc{
//    [self.timerWapper cj_invalidate];
    [self.timer invalidate];
    self.timer = nil;
    CJNSLog(@"%s",__func__);
}

@end
