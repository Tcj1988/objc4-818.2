//
//  TCJPerson.h
//  ⑥ - Method-Swizzling坑
//
//  Created by tangchangjiang on 2021/2/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TCJPerson : NSObject
- (void)personInstanceMethod;
+ (void)personClassMethod;
@end

NS_ASSUME_NONNULL_END
