//
//  TCJPerson.h
//  ③ - 系统内存开辟分析
//
//  Created by tangchangjiang on 2020/9/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TCJPerson : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, assign) int age;
@property (nonatomic, assign) long height;

@end

NS_ASSUME_NONNULL_END
