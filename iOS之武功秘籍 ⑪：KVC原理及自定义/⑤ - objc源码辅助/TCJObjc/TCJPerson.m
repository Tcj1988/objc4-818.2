//
//  TCJPerson.m
//  TCJObjc
//
//  Created by tangchangjiang on 2021/2/17.
//

#import "TCJPerson.h"
#import <objc/message.h>
#import "TCJStudent.h"
#ifdef DEBUG
#define CJNSLog(format, ...) printf("%s\n", [[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String]);
#else
#define CJNSLog(format, ...);
#endif

@implementation TCJPerson


@end
