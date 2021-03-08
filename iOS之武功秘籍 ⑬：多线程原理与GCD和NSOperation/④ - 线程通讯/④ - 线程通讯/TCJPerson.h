//
//  TCJPerson.h
//  ④ - 线程通讯
//
//  Created by tangchangjiang on 2021/1/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TCJPerson : NSObject
- (void)personLaunchThreadWithPort:(NSPort *)port;
@end

NS_ASSUME_NONNULL_END
