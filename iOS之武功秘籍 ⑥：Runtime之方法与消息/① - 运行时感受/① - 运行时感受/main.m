//
//  main.m
//  ① - 运行时感受
//
//  Created by tangchangjiang on 2021/2/16.
//

#import <Foundation/Foundation.h>
#import <objc/message.h>
#ifdef DEBUG
#define CJNSLog(format, ...) printf("%s\n", [[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String]);
#else
#define CJNSLog(format, ...);
#endif

@interface TCJPerson : NSObject
- (void)sayHello;
- (void)sayCode;
+ (void)sayNA;
@end

@implementation TCJPerson
- (void)sayHello{
    CJNSLog(@"666--%s",__func__);
}
- (void)sayCode{
    CJNSLog(@"666--%s",__func__);
}
+ (void)sayNA{
    CJNSLog(@"666--%s",__func__);
}
@end

@interface TCJTeacher : TCJPerson
- (void)sayHello;
- (void)sayNB;
+ (void)sayNC;
@end

@implementation TCJTeacher
- (void)sayNB{
    CJNSLog(@"666--%s",__func__);
}
+ (void)sayNC{
    CJNSLog(@"666--%s",__func__);
}

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // sel_registerName = @seletor() = NSSeletorFromString()
        // 方法: 消息 : (消息的接受者 . 消息主体)
//        TCJPerson *person = [TCJPerson alloc];
//        objc_msgSend(person,sel_registerName("sayHello"));
//        [person sayHello];
        
//        TCJTeacher *teacher = [TCJTeacher alloc];
//        objc_msgSend(teacher, sel_registerName("sayNB"));
//        objc_msgSend(objc_getClass("TCJTeacher"), sel_registerName("sayNC"));
//        [teacher sayHello];
        
//        struct objc_super cjsuper;
//        cjsuper.receiver = teacher; //消息的接收者还是teacher
//        cjsuper.super_class = [TCJPerson class]; //告诉父类是谁
//        //消息的接受者还是自己 - 父类 - 请你直接找我的父亲
//        objc_msgSendSuper(&cjsuper, sel_registerName("sayHello"));
        
//        TCJTeacher *teacher = [TCJTeacher alloc];
//        struct objc_super superInstanceMethod;
//        superInstanceMethod.receiver = teacher;
//        superInstanceMethod.super_class = objc_getClass("TCJPerson");
//        objc_msgSendSuper(&superInstanceMethod, sel_registerName("sayCode"));
        
        TCJTeacher *teacher = [TCJTeacher alloc];
        struct objc_super superClassMethod;
        superClassMethod.receiver = [teacher class];
        superClassMethod.super_class = class_getSuperclass(object_getClass([teacher class]));
        objc_msgSendSuper(&superClassMethod, sel_registerName("sayNA"));
    }
    return 0;
}
