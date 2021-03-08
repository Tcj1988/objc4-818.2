//
//  TCJDetailViewController.m
//  ① - KVO初探
//
//  Created by tangchangjiang on 2020/9/16.
//  Copyright © 2020 tangchangjiang. All rights reserved.
//

#import "TCJDetailViewController.h"
#import "TCJStudent.h"

@interface TCJDetailViewController ()
@property (nonatomic, strong) TCJStudent *student;
@end

@implementation TCJDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor orangeColor];
    self.student = [TCJStudent shareInstance];
    [self.student addObserver:self forKeyPath:@"name" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.student.name = @"hello word";
}
#pragma mark - KVO回调
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    
    NSLog(@"TCJDetailViewController :%@",change);
}

- (void)dealloc{
     [self.student removeObserver:self forKeyPath:@"name"];
}

@end
