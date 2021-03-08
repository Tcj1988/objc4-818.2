//
//  ViewController.m
//  ① - KVC简介
//
//  Created by tangchangjiang on 2020/9/16.
//  Copyright © 2020 tangchangjiang. All rights reserved.
//

#import "ViewController.h"
#import "TCJPerson.h"
#import "TCJStudent.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    TCJPerson *person = [[TCJPerson alloc] init];
    // 一般setter 方法
    person.name      = @"TCJ_CJ"; // setter -- llvm 底层编译期间
    person.age       = 18;
    person->myName   = @"CJ";
    NSLog(@"%@ - %ld - %@",person.name,(long)person.age,person->myName);

    // 1:Key-Value Coding (KVC) : 基本类型
    [person setValue:@"TCJ" forKey:@"name"];
    [person setValue:@19 forKey:@"age"];
    [person setValue:@"CJ" forKey:@"myName"];
    NSLog(@"%@ - %@ - %@",[person valueForKey:@"name"],[person valueForKey:@"age"],[person valueForKey:@"myName"]);
     
    // 2:KVC - 集合类型 -
    person.array = @[@"1",@"2",@"3"];
    // 由于不是可变数组 - 无法做到
    // person.array[0] = @"100";
    // 搞一个新的数组 - KVC 赋值就OK
    NSArray *array = [person valueForKey:@"array"];
    // 用 array 的值创建一个新的数组
    array = @[@"100",@"2",@"3"];
    [person setValue:array forKey:@"array"];
    NSLog(@"%@",[person valueForKey:@"array"]);
     
    // KVC 的方式
    NSMutableArray *ma = [person mutableArrayValueForKey:@"array"];
    ma[0] = @"100";
    NSLog(@"%@",[person valueForKey:@"array"]);
     
     
    // 3:KVC - 集合操作符
    //[self dictionaryTest];
    //[self arrayMessagePass];
    [self aggregationOperator];
    //[self arrayOperator];
    //[self arrayNesting];
    //[self setNesting];
    //[self arrayDemo];


    // 4:KVC - 访问非对象属性 - 面试可能问到
    // 4.1 赋值
    ThreeFloats floats = {1., 2., 3.};
    NSValue *value  = [NSValue valueWithBytes:&floats objCType:@encode(ThreeFloats)];
    [person setValue:value forKey:@"threeFloats"];
    NSValue *reslut = [person valueForKey:@"threeFloats"];
    NSLog(@"非对象类型%@",reslut);
     
    // 4.2 取值
    ThreeFloats th;
    [reslut getValue:&th] ;
    NSLog(@"非对象类型的值%f - %f - %f",th.x,th.y,th.z);
     
    // 5:KVC - 层层访问
    TCJStudent *student = [[TCJStudent alloc] init];
    student.subject    = @"iOS";
    person.student     = student;
    [person setValue:@"葵花宝典" forKeyPath:@"student.subject"];
    NSLog(@"%@",[person valueForKeyPath:@"student.subject"]);
}

#pragma mark - array取值
- (void)arrayDemo{
    TCJStudent *p = [TCJStudent new];
    p.penArr = [NSMutableArray arrayWithObjects:@"pen0", @"pen1", @"pen2", @"pen3", nil];
    NSArray *arr = [p valueForKey:@"pens"]; // 动态成员变量
    NSLog(@"pens = %@", arr);
    //NSLog(@"%@",arr[0]);
    NSLog(@"%d",[arr containsObject:@"pen9"]);
    // 遍历
    NSEnumerator *enumerator = [arr objectEnumerator];
    NSString* str = nil;
    while (str = [enumerator nextObject]) {
        NSLog(@"%@", str);
    }
}

#pragma mark - 字典操作

- (void)dictionaryTest{
    
    NSDictionary* dict = @{
                           @"name":@"TCJ",
                           @"nick":@"CJ",
                           @"subject":@"iOS",
                           @"age":@18,
                           @"length":@180
                           };
    TCJStudent *p = [[TCJStudent alloc] init];
    // 字典转模型
    [p setValuesForKeysWithDictionary:dict];
    NSLog(@"%@",p);
    // 键数组转模型到字典
    NSArray *array = @[@"name",@"age"];
    NSDictionary *dic = [p dictionaryWithValuesForKeys:array];
    NSLog(@"%@",dic);
}

#pragma mark - KVC消息传递
- (void)arrayMessagePass{
    NSArray *array = @[@"A",@"B",@"C",@"D"];
    NSArray *lenStr= [array valueForKeyPath:@"length"];
    NSLog(@"%@",lenStr);// 消息从array传递给了string
    NSArray *lowStr= [array valueForKeyPath:@"lowercaseString"];
    NSLog(@"%@",lowStr);
}

#pragma mark - 聚合操作符
// @avg、@count、@max、@min、@sum
- (void)aggregationOperator{
    NSMutableArray *personArray = [NSMutableArray array];
    for (int i = 0; i < 6; i++) {
        TCJStudent *p = [TCJStudent new];
        NSDictionary* dict = @{
                               @"name":@"Tom",
                               @"age":@(18+i),
                               @"nick":@"Cat",
                               @"length":@(175 + 2*arc4random_uniform(6)),
                               };
        [p setValuesForKeysWithDictionary:dict];
        [personArray addObject:p];
    }
    NSLog(@"%@", [personArray valueForKey:@"length"]);
    
    /// 平均身高
    float avg = [[personArray valueForKeyPath:@"@avg.length"] floatValue];
    NSLog(@"%f", avg);
    
    int count = [[personArray valueForKeyPath:@"@count.length"] intValue];
    NSLog(@"%d", count);
    
    int sum = [[personArray valueForKeyPath:@"@sum.length"] intValue];
    NSLog(@"%d", sum);
    
    int max = [[personArray valueForKeyPath:@"@max.length"] intValue];
    NSLog(@"%d", max);
    
    int min = [[personArray valueForKeyPath:@"@min.length"] intValue];
    NSLog(@"%d", min);
}

// 数组操作符 @distinctUnionOfObjects @unionOfObjects
- (void)arrayOperator{
    NSMutableArray *personArray = [NSMutableArray array];
    for (int i = 0; i < 6; i++) {
        TCJStudent *p = [TCJStudent new];
        NSDictionary* dict = @{
                               @"name":@"Tom",
                               @"age":@(18+i),
                               @"nick":@"Cat",
                               @"length":@(175 + 2*arc4random_uniform(6)),
                               };
        [p setValuesForKeysWithDictionary:dict];
        [personArray addObject:p];
    }
    NSLog(@"%@", [personArray valueForKey:@"length"]);
    // 返回操作对象指定属性的集合
    NSArray* arr1 = [personArray valueForKeyPath:@"@unionOfObjects.length"];
    NSLog(@"arr1 = %@", arr1);
    // 返回操作对象指定属性的集合 -- 去重
    NSArray* arr2 = [personArray valueForKeyPath:@"@distinctUnionOfObjects.length"];
    NSLog(@"arr2 = %@", arr2);
    
}

// 嵌套集合(array&set)操作 @distinctUnionOfArrays @unionOfArrays @distinctUnionOfSets
- (void)arrayNesting{
    
    NSMutableArray *personArray1 = [NSMutableArray array];
    for (int i = 0; i < 6; i++) {
        TCJStudent *student = [TCJStudent new];
        NSDictionary* dict = @{
                               @"name":@"Tom",
                               @"age":@(18+i),
                               @"nick":@"Cat",
                               @"length":@(175 + 2*arc4random_uniform(6)),
                               };
        [student setValuesForKeysWithDictionary:dict];
        [personArray1 addObject:student];
    }
    
    NSMutableArray *personArray2 = [NSMutableArray array];
    for (int i = 0; i < 6; i++) {
        TCJPerson *person = [TCJPerson new];
        NSDictionary* dict = @{
                               @"name":@"Tom",
                               @"age":@(18+i),
                               @"nick":@"Cat",
                               @"length":@(175 + 2*arc4random_uniform(6)),
                               };
        [person setValuesForKeysWithDictionary:dict];
        [personArray2 addObject:person];
    }
    
    // 嵌套数组
    NSArray* nestArr = @[personArray1, personArray2];
    
    NSArray* arr = [nestArr valueForKeyPath:@"@distinctUnionOfArrays.length"];
    NSLog(@"arr = %@", arr);
    
    NSArray* arr1 = [nestArr valueForKeyPath:@"@unionOfArrays.length"];
    NSLog(@"arr1 = %@", arr1);
}

- (void)setNesting{
    
    NSMutableSet *personSet1 = [NSMutableSet set];
    for (int i = 0; i < 6; i++) {
        TCJStudent *person = [TCJStudent new];
        NSDictionary* dict = @{
                               @"name":@"Tom",
                               @"age":@(18+i),
                               @"nick":@"Cat",
                               @"length":@(175 + 2*arc4random_uniform(6)),
                               };
        [person setValuesForKeysWithDictionary:dict];
        [personSet1 addObject:person];
    }
    NSLog(@"personSet1 = %@", [personSet1 valueForKey:@"length"]);
    
    NSMutableSet *personSet2 = [NSMutableSet set];
    for (int i = 0; i < 6; i++) {
        TCJPerson *person = [TCJPerson new];
        NSDictionary* dict = @{
                               @"name":@"Tom",
                               @"age":@(18+i),
                               @"nick":@"Cat",
                               @"length":@(175 + 2*arc4random_uniform(6)),
                               };
        [person setValuesForKeysWithDictionary:dict];
        [personSet2 addObject:person];
    }
    NSLog(@"personSet2 = %@", [personSet2 valueForKey:@"length"]);

    // 嵌套set
    NSSet* nestSet = [NSSet setWithObjects:personSet1, personSet2, nil];
    // 交集
    NSArray* arr1 = [nestSet valueForKeyPath:@"@distinctUnionOfSets.length"];
    NSLog(@"arr1 = %@", arr1);
}



@end
