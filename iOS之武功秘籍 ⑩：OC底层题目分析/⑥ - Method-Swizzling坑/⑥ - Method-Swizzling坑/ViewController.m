//
//  ViewController.m
//  ⑥ - Method-Swizzling坑
//
//  Created by tangchangjiang on 2021/2/24.
//

#import "ViewController.h"
#import "TCJPerson.h"
#import "TCJStudent.h"
#import "TCJStudent+TCJ.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 黑魔法坑点二: 子类没有实现 - 父类实现
    TCJStudent *student = [[TCJStudent alloc] init];
    [student personInstanceMethod];
    
    TCJPerson *person = [[TCJPerson alloc] init];
    [person personInstanceMethod];
}


@end
