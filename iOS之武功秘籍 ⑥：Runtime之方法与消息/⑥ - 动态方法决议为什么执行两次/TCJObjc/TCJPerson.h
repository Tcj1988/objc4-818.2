//
//  TCJPerson.h
//  TCJObjc
//
//  Created by tangchangjiang on 2021/2/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TCJPerson : NSObject
@property (nonatomic, copy) NSString *cjName;
@property (nonatomic, strong) NSString *nickName;
- (void)sayHello;
- (void)sayCode;
- (void)sayMaster;
+ (void)sayNB;
+ (void)sayHappy;
- (void)say666;
@end

NS_ASSUME_NONNULL_END
