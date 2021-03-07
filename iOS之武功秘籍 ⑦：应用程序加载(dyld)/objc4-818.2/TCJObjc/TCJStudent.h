//
//  TCJStudent.h
//  TCJObjc
//
//  Created by tangchangjiang on 2021/2/18.
//

#import <Foundation/Foundation.h>
#ifdef DEBUG
#define CJNSLog(format, ...) printf("%s\n", [[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String]);
#else
#define CJNSLog(format, ...);
#endif

NS_ASSUME_NONNULL_BEGIN

@interface TCJStudent : NSObject
- (void)say666;
@end

NS_ASSUME_NONNULL_END
