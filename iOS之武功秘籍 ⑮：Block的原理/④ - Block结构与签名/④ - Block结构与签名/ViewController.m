//
//  ViewController.m
//  ④ - Block结构与签名
//
//  Created by tangchangjiang on 2021/1/22.
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
    int a = 10;
    void (^block1)(void) = ^{
        NSLog(@"CJ_Block - %d",a);
    };
    block1();
}


@end
