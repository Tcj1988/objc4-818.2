//
//  TCJPerson.h
//  TCJObjc
//
//  Created by tangchangjiang on 2021/2/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TCJPerson : NSObject
@property (nonatomic, copy) NSString *cj_name;
@property (nonatomic, assign) int cj_age;
- (void)cj_instanceMethod1;
- (void)cj_instanceMethod2;
- (void)cj_instanceMethod3;

+ (void)cj_classMethod;

// macho -> data -> rw -> rwe
// 非懒加载的类 lazy-class
// 拓展 - 分析思维
// 整体 - 局部 - 细节
@end

NS_ASSUME_NONNULL_END
