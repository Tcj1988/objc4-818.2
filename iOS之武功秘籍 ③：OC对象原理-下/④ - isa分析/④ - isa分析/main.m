//
//  main.m
//  ④ - isa分析
//
//  Created by tangchangjiang on 2021/1/14.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#ifdef DEBUG
#define TCJNSLog(format, ...) printf("%s\n", [[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String]);
#else
#define TCJNSLog(format, ...);
#endif

@interface TCJPerson : NSObject

@end

@implementation TCJPerson

@end

#pragma mark - 分析类对象内存存在个数
void tcjTestClassNum(){
    Class class1 = [TCJPerson class];
    Class class2 = [TCJPerson alloc].class;
    Class class3 = object_getClass([TCJPerson alloc]);
    Class class4 = [TCJPerson alloc].class;
    TCJNSLog(@"%p-\n%p-\n%p-\n%p",class1,class2,class3,class4);
}

void tcjTestNSObject(){
    //NSObject实例对象
    NSObject *obj1 = [NSObject alloc];
    //NSObject类
    Class class = object_getClass(obj1);
    //NSObject元类
    Class metaClass = object_getClass(class);
    //NSObject根元类
    Class rootMetaClass = object_getClass(metaClass);
    //NSObject根根元类
    Class rootRootMetaClass = object_getClass(rootMetaClass);
    TCJNSLog(@"%p 实例对象\n%p 类\n%p 元类\n%p 根元类\n%p 根根元类",obj1,class,metaClass,rootMetaClass,rootRootMetaClass);
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        TCJPerson *obj = [TCJPerson alloc];
        TCJNSLog(@"%@",obj); //0x00007ffffffffff8ULL
//        tcjTestClassNum();
//        tcjTestNSObject();
//        TCJNSLog(@"isa 我来了");
    }
    return 0;
}
