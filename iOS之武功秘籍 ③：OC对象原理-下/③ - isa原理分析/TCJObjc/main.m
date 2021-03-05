//
//  main.m
//  TCJObjc
//
//  Created by tangchangjiang on 2021/1/6.
//


#import <Foundation/Foundation.h>
#ifdef DEBUG
#define CJNSLog(format, ...) printf("%s\n", [[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String]);
#else
#define CJNSLog(format, ...);
#endif

@interface TCJPerson : NSObject

@end

@implementation TCJPerson

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
//        NSObject *obj = [NSObject alloc];
        TCJPerson *person = [TCJPerson alloc];
        CJNSLog(@"Hello, World! - %@", person);
    }
    return 0;
}
