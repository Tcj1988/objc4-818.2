//
//  ViewController.m
//  ⑤ - Runloop初探
//
//  Created by tangchangjiang on 2021/2/9.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

+ (void)load{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotNotification:) name:@"helloMyNotification" object:nil];
    [self sourceDemo];
}

- (void)sourceDemo{
    
    //__CFRUNLOOP_IS_CALLING_OUT_TO_A_TIMER_CALLBACK_FUNCTION__
    [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        NSLog(@"天王盖地虎");
    }];
    [self performSelector:@selector(fire) withObject:nil afterDelay:1.0];
    
    // __CFRUNLOOP_IS_SERVICING_THE_MAIN_DISPATCH_QUEUE__
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"hello word");
    });
    
    // __CFRUNLOOP_IS_CALLING_OUT_TO_A_BLOCK__
    void (^block)(void) = ^{
        NSLog(@"123");
    };
    
    block();
}

// __CFRUNLOOP_IS_CALLING_OUT_TO_A_TIMER_CALLBACK_FUNCTION__
- (void)fire{
    NSLog(@"performSeletor");
}

#pragma mark - 触摸事件
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    // __CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE0_PERFORM_FUNCTION__
    NSLog(@"来了,老弟!!!");
    
    // [[NSNotificationCenter defaultCenter] postNotificationName:@"helloMyNotification" object:@"cooci"];

}
- (void)gotNotification:(NSNotification *)noti{
    // __CFNOTIFICATIONCENTER_IS_CALLING_OUT_TO_AN_OBSERVER__
    // NSLog(@"gotNotification = %@",noti);
}

@end
