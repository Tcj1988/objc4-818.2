//
//  ViewController.m
//  ① - 多线程的作用
//
//  Created by tangchangjiang on 2021/1/26.
//

#import "ViewController.h"
#import <pthread.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [self threadTest];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    //0: pthread
    
    /**
     pthread_create 创建线程
     参数：
     1. pthread_t：要创建线程的结构体指针，通常开发的时候，如果遇到 C 语言的结构体，类型后缀 `_t / Ref` 结尾
     同时不需要 `*`
     2. 线程的属性，nil(空对象 - OC 使用的) / NULL(空地址，0 C 使用的)
     3. 线程要执行的`函数地址`
     void *: 返回类型，表示指向任意对象的指针，和 OC 中的 id 类似
     (*): 函数名
     (void *): 参数类型，void *
     4. 传递给第三个参数(函数)的`参数`
     
     返回值：C 语言框架中非常常见
     int
     0          创建线程成功！成功只有一种可能
     非 0       创建线程失败的错误码，失败有多种可能！
     */
    
    // 1: pthread
    pthread_t threadId = NULL;
    //c字符串
    char *cString = "HelloCode";
//    NSString *ocString = @"Good";
    //延伸到: OC--C的混编 尤其在智能家居,SDK封装
    //抛出一个问题: 在ARC需要这样操作,在MRC不需要
    // OC prethread -- 跨平台
    // 锁
    int result = pthread_create(&threadId, NULL, pthreadTest, cString);
    if (result == 0) {
        NSLog(@"成功");
    } else {
        NSLog(@"失败");
    }
    // 2: NSThread
    [NSThread detachNewThreadSelector:@selector(threadTest) toTarget:self withObject:nil];
    // 3: GCD
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self threadTest];
    });
    
    // 4: NSOperation
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        [self threadTest];
    }];
    
    
}

/**
 1. 循环的执行速度很快
 2. 栈区／常量区的内存操作也挺快
 3. 堆区的内存操作有点慢
 4. I(Input输入) / O(Output 输出) 操作的速度是最慢的！
 * 会严重的造成界面的卡顿，影响用户体验！
 * 多线程：开启一条线程，将耗时的操作放在新的线程中执行
 */
- (void)threadTest{
    NSLog(@"begin");
    NSInteger count = 1000 * 100;
    for (NSInteger i = 0; i < count; i++) {
        // 栈区
        NSInteger num = i;
        // 常量区
        NSString *name = @"jiang";
        // 堆区
        NSString *myName = [NSString stringWithFormat:@"%@ - %zd", name, num];
        NSLog(@"%@", myName);
    }
    NSLog(@"over");
}

void *pthreadTest(void *para){
    // 接 C 语言的字符串
    //    NSLog(@"===> %@ %s", [NSThread currentThread], para);
    // __bridge 将 C 语言的类型桥接到 OC 的类型
    NSString *name = (__bridge NSString *)(para);
    
    NSLog(@"===>%@ %@", [NSThread currentThread], name);
    
    return NULL;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
