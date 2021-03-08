//
//  ViewController.m
//  ① - 启动优化Demo
//
//  Created by tangchangjiang on 2021/2/5.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

void test1(){
    printf("1");
}


void  test2(){
    
    printf("2");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    test1();//MachO 文件中.创建一个符号!NSLog --> NSLog地址
}

+(void)load
{
    
    printf("3");
    test2();
}


@end
