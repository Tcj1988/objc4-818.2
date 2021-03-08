//
//  main.m
//  TCJObjc
//
//  Created by tangchangjiang on 2021/1/6.
//


#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "TCJPerson.h"
#import "TCJPerson+EXT.h"
#ifdef DEBUG
#define CJNSLog(format, ...) printf("%s\n", [[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String]);
#else
#define CJNSLog(format, ...);
#endif

//@interface TCJPerson : NSObject
//- (void)instanceMethod;
//- (void)classMethod;
//@end
//
//@interface TCJPerson ()
//
//@property (nonatomic, copy) NSString *ext_name;
//
//- (void)ext_instanceMethod;
//- (void)ext_classMethod;
//
//@end
//
//@implementation TCJPerson
//
//- (void)ext_instanceMethod{
//
//}
//- (void)ext_classMethod{
//
//}
//
//- (void)instanceMethod{
//
//}
//- (void)classMethod{
//
//}
//
//@end

@interface TCJPerson (TCJA)
@property (nonatomic, copy) NSString *cate_name;
- (void)cate_instanceMethod1;
- (void)cate_instanceMethod3;
- (void)cate_instanceMethod2;
+ (void)cate_sayClassMethod;
@end

@implementation TCJPerson (TCJA)
- (void)cate_instanceMethod1{
    NSLog(@"%s",__func__);
}
- (void)cate_instanceMethod3{
    NSLog(@"%s",__func__);
}
- (void)cate_instanceMethod2{
    NSLog(@"%s",__func__);
}
+ (void)cate_sayClassMethod{
    NSLog(@"%s",__func__);
}
- (void)setCate_name:(NSString *)cate_name{
     //1: 对象  2: 标识符 3: value 4: 策略
    objc_setAssociatedObject(self, "cate_name", cate_name, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (NSString *)cate_name{
    return  objc_getAssociatedObject(self, "cate_name");
}

@end


int main(int argc, const char * argv[]) {
    @autoreleasepool {

        TCJPerson *person  = [TCJPerson alloc];
        person.cate_name = @"CJ";
        CJNSLog(@"%@",person.cate_name);
    }
    return 0;
}





