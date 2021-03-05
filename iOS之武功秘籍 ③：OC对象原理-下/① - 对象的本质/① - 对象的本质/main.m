//
//  main.m
//  ① - 对象的本质
//
//  Created by tangchangjiang on 2020/10/1.
//

#import <Foundation/Foundation.h>
#ifdef DEBUG
#define CJNSLog(format, ...) printf("%s\n", [[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String]);
#else
#define CJNSLog(format, ...);
#endif

@interface TCJPerson : NSObject
{
    NSString *helloName;
}
@property (nonatomic, copy) NSString *name;
@end

@implementation TCJPerson

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        CJNSLog(@"Hello, World!");
    }
    return 0;
}
