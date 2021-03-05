//
//  main.m
//  TCJObjc
//
//  Created by tangchangjiang on 2021/1/6.
//


#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <malloc/malloc.h>

#ifdef DEBUG
#define CJNSLog(format, ...) printf("%s\n", [[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String]);
#else
#define CJNSLog(format, ...);
#endif

@interface TCJPerson : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, assign) int age;
@property (nonatomic, assign) long height;
//@property (nonatomic, assign) float height;
//@property (nonatomic, assign) double height;
@property (nonatomic, assign) char c1;
@property (nonatomic, assign) char c2;
@end

@implementation TCJPerson

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {

        TCJPerson *person = [TCJPerson alloc];
        person.name = @"TCJ";
        person.nickName = @"CJ";
        person.age = 18;
        person.height = 185;
        person.c1 = 'a';
        person.c2 = 'b';
        
        CJNSLog(@"sizeof——%lu\nclass_getInstanceSize——%lu\nmalloc_size——%lu", sizeof([person class]), class_getInstanceSize([person class]), malloc_size((__bridge const void *)(person)));
    }
    return 0;
}

// float转换为16进制
void cj_float2HEX(float f){
    union uuf { float f; char s[4];} uf;
    uf.f = f;
    printf("0x");
    for (int i = 3; i>=0; i--) {
        printf("%02x", 0xff & uf.s[i]);
    }
    printf("\n");
}

// double转换为16进制
void cj_double2HEX(float f){
    union uuf { float f; char s[8];} uf;
    uf.f = f;
    printf("0x");
    for (int i = 7; i>=0; i--) {
        printf("%02x", 0xff & uf.s[i]);
    }
    printf("\n");
}
