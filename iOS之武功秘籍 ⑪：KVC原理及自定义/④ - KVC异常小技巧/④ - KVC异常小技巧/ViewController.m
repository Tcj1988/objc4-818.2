//
//  ViewController.m
//  ④ - KVC异常小技巧
//
//  Created by tangchangjiang on 2020/9/16.
//  Copyright © 2020 tangchangjiang. All rights reserved.
//

#import "ViewController.h"
#import "TCJPerson.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    TCJPerson *person = [[TCJPerson alloc] init];
    
    // 1: KVC 自动转换类型
    NSLog(@"******1: KVC - int -> NSNumber - 结构体******");

    [person setValue:@18 forKey:@"age"];
    // 上面那个表达 大家应该都会! 但是下面这样操作可以?
    [person setValue:@"20" forKey:@"age"]; // int - string
    NSLog(@"%@-%@",[person valueForKey:@"age"],[[person valueForKey:@"age"] class]);//__NSCFNumber
    
    [person setValue:@"20" forKey:@"sex"];
    NSLog(@"%@-%@",[person valueForKey:@"sex"],[[person valueForKey:@"sex"] class]);//__NSCFNumber

    ThreeFloats floats = {1., 2., 3.};
    NSValue *value  = [NSValue valueWithBytes:&floats objCType:@encode(ThreeFloats)];
    [person setValue:value forKey:@"threeFloats"];
    NSLog(@"%@-%@",[person valueForKey:@"threeFloats"],[[person valueForKey:@"threeFloats"] class]);//NSConcreteValue
    
    // 2: 设置空值
    NSLog(@"******2: 设置空值******");
    [person setValue:nil forKey:@"age"]; // subject不会走 - 官方注释里面说只对 NSNumber - NSValue
    [person setValue:nil forKey:@"subject"];
    
    // 3: 找不到的 key
    NSLog(@"******3: 找不到的 key******");
    [person setValue:nil forKey:@"CJ"];

    // 4: 取值时 - 找不到 key
    NSLog(@"******4: 取值时 - 找不到 key******");
    NSLog(@"%@",[person valueForKey:@"CJ"]);
    
    // 5: 键值验证
    NSLog(@"******5: 键值验证******");
    NSError *error;
    NSString *name = @"TCJ";
    if (![person validateValue:&name forKey:@"names" error:&error]) {
        NSLog(@"%@",error);
    }else{
        NSLog(@"%@",[person valueForKey:@"name"]);
    }

}


@end
