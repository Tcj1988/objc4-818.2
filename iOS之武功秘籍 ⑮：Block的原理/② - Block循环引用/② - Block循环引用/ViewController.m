//
//  ViewController.m
//  ② - Block循环引用
//
//  Created by tangchangjiang on 2021/1/22.
//
#ifdef DEBUG
#define CJNSLog(format, ...) printf("%s\n", [[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String]);
#else
#define CJNSLog(format, ...);
#endif
#import "ViewController.h"
#import "TCJProxy.h"

//********Cat类********
@interface TCJCat : NSObject
@end

@implementation TCJCat
- (void)eat{
    CJNSLog(@"吃------");
}
@end

//********Dog类********
@interface TCJDog : NSObject
@end

@implementation TCJDog
- (void)shut{
    CJNSLog(@"叫-----");
}
@end

typedef void(^CJBlock)(ViewController *);
//typedef void(^CJBlock)(void);
@interface ViewController ()
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) TCJProxy *proxy;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) CJBlock block;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.proxy = [TCJProxy proxyWithTransformObject:self];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self.proxy selector:@selector(fireHome) userInfo:nil repeats:YES];
}

- (void)fireHome{
    CJNSLog(@"hello word ");
}

- (void)dealloc{
    [self.timer invalidate];
    self.timer = nil;
    CJNSLog(@"dealloc 来了 %s",__func__);
}

- (void)cj_proxyTest{
    TCJDog *dog = [[TCJDog alloc] init];
    TCJCat *cat = [[TCJCat alloc] init];
    TCJProxy *proxy = [TCJProxy alloc];
    
    [proxy transformObject:cat];
    [proxy performSelector:@selector(eat)];
    
    [proxy transformObject:dog];
    [proxy performSelector:@selector(shut)];
}


//- (void)cj_blockDemo{
//    __weak typeof(self) weakSelf = self;
//    self.block = ^(void){
//        __strong typeof(self) strongSelf = weakSelf;
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            CJNSLog(@"%@",strongSelf.name);
//        });
//    };
//    self.block();
//
//    __block ViewController *vc = self;
//    self.block = ^(void){
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            CJNSLog(@"%@",vc.name);
//            vc = nil; //手动释放
//        });
//    };
//    self.block();

//    self.name = @"CJ";
//    self.block = ^(ViewController *vc){
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            CJNSLog(@"%@",vc.name);
//        });
//    };
//    self.block(self);

//}

- (void)cj_test{
    
//    CJNSLog(@"%ld",(long)CFGetRetainCount((__bridge CFTypeRef)(self)));
//    __weak typeof(self) weakSelf = self;
//    CJNSLog(@"%ld",(long)CFGetRetainCount((__bridge CFTypeRef)(self)));
//    self.block = ^(void){
//        CJNSLog(@"%@",weakSelf.name);
//    };
//    self.block();
//    CJNSLog(@"%p --- %p",weakSelf, self);
//    CJNSLog(@"%ld",(long)CFGetRetainCount((__bridge CFTypeRef)(self.block)));
//    CJNSLog(@"%ld",(long)CFGetRetainCount((__bridge CFTypeRef)(self)));
}

@end
