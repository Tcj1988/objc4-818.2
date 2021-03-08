//
//  ViewController.m
//  ⑤ - 利用runtime-API创建对象
//
//  Created by tangchangjiang on 2021/2/24.
//

#import "ViewController.h"
#import <objc/runtime.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    /*
     *1.创建类
     *
     *superClass: 父类，传Nil会创建一个新的根类
     *name: 类名
     *extraBytes: 额外的内存空间，一般传0
     *return:返回新类，创建失败返回Nil，如果类名已经存在，则创建失败
     */
    Class TCJPerson = objc_allocateClassPair([NSObject class], "TCJPerson", 0);

    /*
    *2.添加成员变量
    *这个函数只能在objc_allocateClassPair和objc_registerClassPair之间调用。不支持向现有类添加一个实例变量
    *这个类不能是元类，不支持在元类中添加一个实例变量
    *实例变量的最小对齐为1 << align，实例变量的最小对齐依赖于ivar的类型和机器架构。对于任何指针类型的变量，请通过log2(sizeof(pointer_type))
    *
    *cls 往哪个类添加
    *name 添加的名字
    *size 大小
    *alignment 对齐处理方式
    *types 签名
    */
    class_addIvar(TCJPerson, "name", sizeof(NSString *), log2(sizeof(NSString *)), "@");

    /*
     * 3.往内存注册类
     *
     * cls 要注册的类
     */
     objc_registerClassPair(TCJPerson);
    
    // 4.添加属性变量
    cj_class_addProperty(TCJPerson, "hobby");
    cj_printerProperty(TCJPerson);
    
    /*
     * 5. 往类里面添加方法
     *
     *cls 要添加方法的类
     *sel 方法编号
     *imp 函数实现指针
     *types 签名
     */
    class_addMethod(TCJPerson, @selector(setHobby:), (IMP)cjSetter, "v@:@");
    class_addMethod(TCJPerson, @selector(hobby), (IMP)cjHobby, "@@:");
    
    // 开始使用
    id person = [TCJPerson alloc];
    [person setValue:@"TCJ" forKey:@"name"];
    NSLog(@"TCJPerson的名字是：%@ 爱好是：%@", [person valueForKey:@"name"], [person valueForKey:@"hobby"]);
}

// hobby的setter-IMP
void cjSetter(NSString *value) {
    printf("%s/n",__func__);
}

// hobby的getter-IMP
NSString *cjHobby() {
    return @"iOS...";
}

// 添加属性变量的封装方法
void cj_class_addProperty(Class targetClass, const char *propertyName) {
    objc_property_attribute_t type = { "T", [[NSString stringWithFormat:@"@\"%@\"",NSStringFromClass([NSString class])] UTF8String] }; //type
    objc_property_attribute_t ownership0 = { "C", "" }; // C = copy
    objc_property_attribute_t ownership = { "N", "" }; //N = nonatomic
    objc_property_attribute_t backingivar  = { "V", [NSString stringWithFormat:@"_%@",[NSString stringWithCString:propertyName encoding:NSUTF8StringEncoding]].UTF8String };  //variable name
    objc_property_attribute_t attrs[] = {type, ownership0, ownership, backingivar};
    /**
    * 4.往类里面添加属性
    *
    *cls 要添加属性的类
    *name 属性名字
    *attributes 属性的属性数组。
    *attriCount 属性中属性的数量。
    */
    class_addProperty(targetClass, propertyName, attrs, 4);
}

// 打印属性变量的封装方法
void cj_printerProperty(Class targetClass){
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(targetClass, &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        fprintf(stdout, "%s %s\n", property_getName(property), property_getAttributes(property));
    }
}


@end
