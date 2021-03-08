//
//  TCJPushViewController.m
//  ③ - 强引用NSTime相关
//
//  Created by tangchangjiang on 2021/2/8.
//

#ifdef DEBUG
#define CJNSLog(format, ...) printf("%s\n", [[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String]);
#else
#define CJNSLog(format, ...);
#endif

#import "TCJPushViewController.h"

@interface TCJPushViewController ()

@end

@implementation TCJPushViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)dealloc{
    CJNSLog(@"%s",__func__);
}

@end
