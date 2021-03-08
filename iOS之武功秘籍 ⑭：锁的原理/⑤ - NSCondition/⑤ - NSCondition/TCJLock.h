//
//  TCJLock.h
//  ⑤ - NSCondition
//
//  Created by tangchangjiang on 2021/1/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TCJLock : NSObject
@property (nonatomic, copy) NSThread *thread;
@property (nonatomic, assign) int value;
@property (nonatomic, assign) int condition;
- (void)cjlockWithCondition:(int)condition;
- (void)cjUnlockWithCondition:(int)condition;
@end

NS_ASSUME_NONNULL_END
