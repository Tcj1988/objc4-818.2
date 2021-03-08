//
//  TCJPerson.m
//  ② - KVC取值&赋值过程
//
//  Created by tangchangjiang on 2020/9/16.
//  Copyright © 2020 tangchangjiang. All rights reserved.
//

#import "TCJPerson.h"

@implementation TCJPerson
#pragma mark - 关闭或开启实例变量赋值
+ (BOOL)accessInstanceVariablesDirectly{
    return YES;
}

//MARK: - setKey. 的流程分析
//- (void)setName:(NSString *)name{
//    NSLog(@"%s - %@",__func__,name);
//}

//- (void)_setName:(NSString *)name{
//    NSLog(@"%s - %@",__func__,name);
//}

//- (void)setIsName:(NSString *)name{
//    NSLog(@"%s - %@",__func__,name);
//}


//MARK: - valueForKey 流程分析 - get<Key>, <key>, is<Key>, or _<key>,

//- (NSString *)getName{
//    return NSStringFromSelector(_cmd);
//}

//- (NSString *)name{
//    return NSStringFromSelector(_cmd);
//}

//- (NSString *)isName{
//    return NSStringFromSelector(_cmd);
//}

//- (NSString *)_name{
//    return NSStringFromSelector(_cmd);
//}

//MARK: - 集合类型的走

// 个数
- (NSUInteger)countOfPens{
    NSLog(@"%s",__func__);
    return [self.arr count];
}

// 获取值
- (id)objectInPensAtIndex:(NSUInteger)index {
    NSLog(@"%s",__func__);
    return [NSString stringWithFormat:@"pens %lu", index];
}


//MARK: - set

// 个数
- (NSUInteger)countOfBooks{
    NSLog(@"%s",__func__);
    return [self.set count];
}

// 是否包含这个成员对象
- (id)memberOfBooks:(id)object {
    NSLog(@"%s",__func__);
    return [self.set containsObject:object] ? object : nil;
}

// 迭代器
- (id)enumeratorOfBooks {
    // objectEnumerator
    NSLog(@"来了 迭代编译");
    return [self.arr reverseObjectEnumerator];
}


//MARK: - 可变数组NSMutableArray

//插入一个数组对象
-(void)insertNamesArrM:(NSArray *)array atIndexes:(NSIndexSet *)indexes{
    NSLog(@"%s",__func__);
}

//插入一个对象
-(void)insertObject:(NSString *)object inNamesArrMAtIndex:(NSUInteger)index{
    NSLog(@"%s",__func__);
}

//移除一个数组
-(void)removeNamesArrMAtIndexes:(NSIndexSet *)indexes{
    NSLog(@"%s",__func__);
}

//移除一个对象
-(void)removeObjectFromNamesArrMAtIndex:(NSUInteger)index{
    NSLog(@"%s",__func__);
}

//根据下标，替换数组
-(void)replaceNamesArrMAtIndexes:(NSIndexSet *)indexes withNamesArrM:(NSArray *)array{
    NSLog(@"%s",__func__);
}

//根据下标替换一个对象
-(void)replaceObjectInNamesArrMAtIndex:(NSUInteger)index withObject:(id)object{
    NSLog(@"%s",__func__);
}


//MARK: - NSMutableOrderedSet

//插入单个对象
-(void)insertObject:(NSString *)object inOrderedSetMAtIndex:(NSUInteger)index{
     NSLog(@"%s",__func__);
}

//插入多个对象
-(void)insertOrderedSetM:(NSArray *)array atIndexes:(NSIndexSet *)indexes{
    NSLog(@"%s",__func__);
}

//替换单个对象
-(void)replaceObjectInOrderedSetMAtIndex:(NSUInteger)index withObject:(id)object{
    NSLog(@"%s",__func__);
}

//替换多个对象（set）
-(void)replaceOrderedSetMAtIndexes:(NSIndexSet *)indexes withOrderedSetM:(NSArray *)array{
    NSLog(@"%s",__func__);
}

//移除单个对象
-(void)removeObjectFromOrderedSetMAtIndex:(NSUInteger)index{
    NSLog(@"%s",__func__);
}
//移除多个对象
-(void)removeOrderedSetMAtIndexes:(NSIndexSet *)indexes{
    NSLog(@"%s",__func__);
}

//MARK: - NSMutablSet

//添加多个对象、并集
-(void)addNamesSetM:(NSSet *)objects{
    NSLog(@"%s",__func__);
}

//添加单个对象
-(void)addNamesSetMObject:(NSString *)object{
    NSLog(@"%s",__func__);
}

//移除多个对象
-(void)removeNamesSetM:(NSSet *)objects{
    NSLog(@"%s",__func__);
}
//移除单个对象
-(void)removeNamesSetMObject:(NSString *)object{
   NSLog(@"%s",__func__);
}

//交集
-(void)intersectNamesSetM:(NSSet *)objects{
    NSLog(@"%s",__func__);
}
@end
