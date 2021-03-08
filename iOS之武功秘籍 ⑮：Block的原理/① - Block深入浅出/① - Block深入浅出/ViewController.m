//
//  ViewController.m
//  ① - Block深入浅出
//
//  Created by tangchangjiang on 2021/1/22.
//
#ifdef DEBUG
#define CJNSLog(format, ...) printf("%s\n", [[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String]);
#else
#define CJNSLog(format, ...);
#endif
#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self cj_testStackBlock1];
}

- (void)cj_testStackBlock1{
    int a = 10;
   void(^__weak block)(void) = ^{
       CJNSLog(@"hello - %d", a);
   };
    CJNSLog(@"%@", block);
}

- (void)cj_testStackBlock{
    int a = 10;
   void(^block)(void) = ^{
       CJNSLog(@"hello - %d", a);
   };
    CJNSLog(@"%@", ^{
        NSLog(@"hello - %d", a);
   });
}

- (void)cj_testMallocBlock{
    int a = 10;
    void(^block)(void) = ^ {
        CJNSLog(@"hello --- %d", a);
    };
    CJNSLog(@"%@", block);
}

- (void)cj_testGlobalBlock{
    void(^block)(void) = ^ {
        CJNSLog(@"111");
    };
    CJNSLog(@"%@",block);
}

@end
