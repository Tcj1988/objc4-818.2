//
//  main.m
//  TCJObjc
//
//  Created by tangchangjiang on 2021/1/6.
//


#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#ifdef DEBUG
#define CJNSLog(format, ...) printf("%s\n", [[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String]);
#else
#define CJNSLog(format, ...);
#endif

void cjObjc_copyIvar_copyProperies(Class pClass){
    
    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList(pClass, &count);
    for (unsigned int i=0; i < count; i++) {
        Ivar const ivar = ivars[i];
        //获取实例变量名
        const char*cName = ivar_getName(ivar);
        NSString *ivarName = [NSString stringWithUTF8String:cName];
        CJNSLog(@"class_copyIvarList:%@",ivarName);
    }
    free(ivars);

    unsigned int pCount = 0;
    objc_property_t *properties = class_copyPropertyList(pClass, &pCount);
    for (unsigned int i=0; i < pCount; i++) {
        objc_property_t const property = properties[i];
        //获取属性名
        NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
        //获取属性值
        CJNSLog(@"class_copyProperiesList:%@",propertyName);
    }
    free(properties);
}

// 用于获取类的方法列表
void cjObjc_copyMethodList(Class pClass){
    unsigned int count = 0;
    Method *methods = class_copyMethodList(pClass, &count);
    for (unsigned int i=0; i < count; i++) {
        Method const method = methods[i];
        //获取方法名
        NSString *key = NSStringFromSelector(method_getName(method));
        
        CJNSLog(@"Method, name: %@", key);
    }
    free(methods);
}

//用于获取类的实例方法 -- 如果在传入的类或者类的父类中没有找到指定的实例方法，则返回NULL
void cjInstanceMethod_classToMetaclass(Class pClass){
    
    const char *className = class_getName(pClass);
    Class metaClass = objc_getMetaClass(className);
    
    Method method1 = class_getInstanceMethod(pClass, @selector(sayHello));
    Method method2 = class_getInstanceMethod(metaClass, @selector(sayHello));

    Method method3 = class_getInstanceMethod(pClass, @selector(sayNB));
    Method method4 = class_getInstanceMethod(metaClass, @selector(sayNB));
    
    CJNSLog(@"%s - %p-%p-%p-%p",__func__,method1,method2,method3,method4);
    CJNSLog(@"%s",__func__);
}

//用于获取类的类方法 -- 如果在传入的类或者类的父类中没有找到指定的类方法，则返回NULL
void cjClassMethod_classToMetaclass(Class pClass){
    
    const char *className = class_getName(pClass);
    Class metaClass = objc_getMetaClass(className);
    
    Method method1 = class_getClassMethod(pClass, @selector(sayHello));
    Method method2 = class_getClassMethod(metaClass, @selector(sayHello));

    Method method3 = class_getClassMethod(pClass, @selector(sayNB));
    // 元类 为什么有 sayNB 类方法 0 1
    //
    Method method4 = class_getClassMethod(metaClass, @selector(sayNB));
    
    CJNSLog(@"%s-%p-%p-%p-%p",__func__,method1,method2,method3,method4);
    CJNSLog(@"%s",__func__);
}
//用于获取方法的实现
void cjIMP_classToMetaclass(Class pClass){
    
    const char *className = class_getName(pClass);
    Class metaClass = objc_getMetaClass(className);

    IMP imp1 = class_getMethodImplementation(pClass, @selector(sayHello));
    IMP imp2 = class_getMethodImplementation(metaClass, @selector(sayHello));

    IMP imp3 = class_getMethodImplementation(pClass, @selector(sayNB));
    IMP imp4 = class_getMethodImplementation(metaClass, @selector(sayNB));

    CJNSLog(@"%p-%p-%p-%p",imp1,imp2,imp3,imp4);
    CJNSLog(@"%s",__func__);
}

#pragma mark - 各种类型编码
void cjTypes(){
    NSLog(@"char --> %s",@encode(char));
    NSLog(@"int --> %s",@encode(int));
    NSLog(@"short --> %s",@encode(short));
    NSLog(@"long --> %s",@encode(long));
    NSLog(@"long long --> %s",@encode(long long));
    NSLog(@"unsigned char --> %s",@encode(unsigned char));
    NSLog(@"unsigned int --> %s",@encode(unsigned int));
    NSLog(@"unsigned short --> %s",@encode(unsigned short));
    NSLog(@"unsigned long --> %s",@encode(unsigned long long));
    NSLog(@"float --> %s",@encode(float));
    NSLog(@"bool --> %s",@encode(bool));
    NSLog(@"void --> %s",@encode(void));
    NSLog(@"char * --> %s",@encode(char *));
    NSLog(@"id --> %s",@encode(id));
    NSLog(@"Class --> %s",@encode(Class));
    NSLog(@"SEL --> %s",@encode(SEL));
    int array[] = {1,2,3};
    NSLog(@"int[] --> %s",@encode(typeof(array)));
    typedef struct person{
        char *name;
        int age;
    }Person;
    NSLog(@"struct --> %s",@encode(Person));
    
    typedef union union_type{
        char *name;
        int a;
    }Union;
    NSLog(@"union --> %s",@encode(Union));

    int a = 2;
    int *b = {&a};
    NSLog(@"int[] --> %s",@encode(typeof(b)));
}

@interface TCJPerson : NSObject
{
    NSString *hobby;
}
@property (nonatomic, copy) NSString *tcj_name;
@property (nonatomic, strong) NSString *nickName;
+ (void)sayNB;
- (void)sayHello;
@end

@implementation TCJPerson
+ (void)sayNB{}
- (void)sayHello{}
@end
//class_data_bits_t
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        TCJPerson *person = [TCJPerson alloc];
//        person.tcj_name = @"tcj";
        person.nickName = @"nickName";
//        Class cls = object_getClass(person);
//        cjObjc_copyIvar_copyProperies(cls);
//        cjTypes();
//        cjObjc_copyMethodList(cls);
//        cjInstanceMethod_classToMetaclass(cls);
//        cjClassMethod_classToMetaclass(cls);
//        cjIMP_classToMetaclass(cls);
    }
    return 0;
}




