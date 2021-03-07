//
//  ViewController.m
//  ① - 应用程序加载分析
//
//  Created by tangchangjiang on 2021/2/18.
//

#import "ViewController.h"
#ifdef DEBUG
#define CJNSLog(format, ...) printf("%s\n", [[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String]);
#else
#define CJNSLog(format, ...);
#endif

@interface ViewController ()

@end

@implementation ViewController

+ (void)load{
    CJNSLog(@"%s",__func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


@end
