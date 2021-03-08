//
//  TCJStudent.m
//  TCJObjc
//
//  Created by tangchangjiang on 2021/2/18.
//
#ifdef DEBUG
#define CJNSLog(format, ...) printf("%s\n", [[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String]);
#else
#define CJNSLog(format, ...);
#endif
#import "TCJStudent.h"

@implementation TCJStudent
- (instancetype)init{
    self = [super init];
    if (self) {
        CJNSLog(@"%@ - %@",[self class],[super class]);
    }
    return self;
}
@end
