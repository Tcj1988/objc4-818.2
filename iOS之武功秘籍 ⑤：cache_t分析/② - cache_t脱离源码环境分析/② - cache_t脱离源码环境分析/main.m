//
//  main.m
//  ② - cache_t脱离源码环境分析
//
//  Created by tangchangjiang on 2021/1/16.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#ifdef DEBUG
#define CJNSLog(format, ...) printf("%s\n", [[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String]);
#else
#define CJNSLog(format, ...);
#endif

@interface TCJPerson : NSObject
@property (nonatomic, copy) NSString *cjName;
@property (nonatomic, strong) NSString *nickName;
- (void)sayHello;
- (void)sayCode;
- (void)sayMaster;
- (void)sayNA;
- (void)sayNB;
- (void)sayNC;
- (void)sayND;
+ (void)sayHappy;
@end

@implementation TCJPerson
- (void)sayHello{
    CJNSLog(@"TCJPerson say : %s",__func__);
}
- (void)sayCode{
    CJNSLog(@"TCJPerson say : %s",__func__);
}
- (void)sayMaster{
    CJNSLog(@"TCJPerson say : %s",__func__);
}
- (void)sayNA{
    CJNSLog(@"TCJPerson say : %s",__func__);
}
- (void)sayNB{
    CJNSLog(@"TCJPerson say : %s",__func__);
}
- (void)sayNC{
    CJNSLog(@"TCJPerson say : %s",__func__);
}
- (void)sayND{
    CJNSLog(@"TCJPerson say : %s",__func__);
}
+ (void)sayHappy{
    CJNSLog(@"TCJPerson say : %s",__func__);
}
@end

typedef uint32_t mask_t;  // x86_64 & arm64 asm are less efficient with 16-bits

struct cj_bucket_t {
    SEL _sel;
    IMP _imp;
};

struct cj_cache_t {
    struct cj_bucket_t * _buckets;
    mask_t _mask;
    uint16_t _flags;
    uint16_t _occupied;
};

struct cj_class_data_bits_t {
    uintptr_t bits;
};

struct cj_objc_class {
    Class ISA;
    Class superclass;
    struct cj_cache_t cache;             // formerly cache pointer and vtable
    struct cj_class_data_bits_t bits;    // class_rw_t * plus custom rr/alloc flags
};

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        TCJPerson *person  = [TCJPerson alloc];
        Class pClass = [TCJPerson class]; // objc_clas
        [person sayHello];
        [person sayCode];
        [person sayMaster];
        [person sayNA];

        // _occupied  _mask 是什么  cup - 1
        // 会变化 2-3 -> 2-7
        // bucket 会有丢失  重新申请
        // 顺序有点问题  哈希
        
        // cache_t 底层原理
        // 线索 :
        
        struct cj_objc_class *cj_pClass = (__bridge struct cj_objc_class *)(pClass);
        CJNSLog(@"%hu - %u",cj_pClass->cache._occupied,cj_pClass->cache._mask);
        for (mask_t i = 0; i<cj_pClass->cache._mask; i++) {
            // 打印获取的 bucket
            struct cj_bucket_t bucket = cj_pClass->cache._buckets[i];
            CJNSLog(@"%@ - %p",NSStringFromSelector(bucket._sel),bucket._imp);
        }
        CJNSLog(@"%@",pClass);
    }
    return 0;
}
