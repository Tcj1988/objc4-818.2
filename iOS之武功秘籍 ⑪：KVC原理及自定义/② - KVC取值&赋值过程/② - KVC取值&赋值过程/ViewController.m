//
//  ViewController.m
//  ② - KVC取值&赋值过程
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
    
    // 1: KVC - 设置值的过程
//    [person setValue:@"TCJ" forKey:@"name"];

//    NSLog(@"%@-%@-%@-%@",person->_name,person->_isName,person->name,person->isName);
//    NSLog(@"%@-%@-%@",person->_isName,person->name,person->isName);
//    NSLog(@"%@-%@",person->name,person->isName);
//    NSLog(@"%@",person->isName);

    // 2: KVC - 取值的过程
//     person->_name = @"_name";
//     person->_isName = @"_isName";
//     person->name = @"name";
     person->isName = @"isName";

     NSLog(@"取值:%@",[person valueForKey:@"name"]);
    
}

//MARK: - 集合类型的KVC 注意

- (void)arraysAndSet{
    
    TCJPerson *person = [[TCJPerson alloc] init];
    // 3: KVC - 集合类型
    person.arr = @[@"pen0", @"pen1", @"pen2", @"pen3"];
    NSArray *array = [person valueForKey:@"pens"];
    NSLog(@"%@",[array objectAtIndex:1]);
    NSLog(@"%d",[array containsObject:@"pen1"]);
    
    // set 集合
    
    person.set = [NSSet setWithArray:person.arr];
    NSSet *set = [person valueForKey:@"books"];
    [set enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSLog(@"set遍历 %@",obj);
    }];
}

@end
