//
//  ViewController.m
//  ② - atomic分析
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
@property (atomic, copy) NSString *cj_name;
@property (atomic, strong) NSArray *array;
@property (atomic, assign) NSInteger index;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.index = 0;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (int i = 0; i < 10000; i++) {
            self.index = self.index + 1;
            CJNSLog(@"%d --- %ld",i, (long)self.index);
        }
    });
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (int i = 0; i < 10000; i++) {
            self.index = self.index + 1;
            CJNSLog(@"%d --- %ld",i, (long)self.index);
        }
    });
}

- (void)cj_test_atomic1{
    self.cj_name = @"CJ";
}


- (void)cj_test_atomic2{
    //Thread A
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (int i = 0; i < 100000; i ++) {
            if (i % 2 == 0) {
                self.array = @[@"Hello", @"World", @"OBJC"];
            }
            else {
                self.array = @[@"Good"];
            }
            NSLog(@"Thread A: %@\n", self.array);
        }
    });
    
    //Thread B
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (int i = 0; i < 100000; i ++) {
            if (self.array.count >= 2) {
                NSString* str = [self.array objectAtIndex:1];
            }
            NSLog(@"Thread B: %@\n",self.array);
        }
    });
}


@end
