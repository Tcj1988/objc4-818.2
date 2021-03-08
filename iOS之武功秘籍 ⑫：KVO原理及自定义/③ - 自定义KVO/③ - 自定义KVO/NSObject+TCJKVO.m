//
//  NSObject+TCJKVO.m
//  ③ - 自定义KVO
//
//  Created by tangchangjiang on 2020/9/17.
//  Copyright © 2020 tangchangjiang. All rights reserved.
//

#import "NSObject+TCJKVO.h"
#import <objc/message.h>

static NSString *const kTCJKVOPrefix = @"TCJKVONotifying_";
static NSString *const kTCJKVOAssiociateKey = @"kTCJKVO_AssiociateKey";

@interface TCJInfo : NSObject
@property (nonatomic, weak) NSObject  *observer;
@property (nonatomic, copy) NSString    *keyPath;
@property (nonatomic, copy) TCJKVOBlock  handleBlock;
@end

@implementation TCJInfo

- (instancetype)initWithObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath handleBlock:(TCJKVOBlock)block{
    if (self=[super init]) {
        _observer = observer;
        _keyPath  = keyPath;
        _handleBlock = block;
    }
    return self;
}

@end

@implementation NSObject (TCJKVO)

#pragma mark - 方法交换

//+ (void)load {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        [self cj_methodSwizzlingWithClass:self oriSEL:NSSelectorFromString(@"dealloc") swizzledSEL:@selector(cj_dealloc)];
//    });
//}

- (void)cj_dealloc {
    Class superClass = [self class];
    object_setClass(self, superClass);
    [self cj_dealloc];
}

- (void)cj_methodSwizzlingWithClass:(Class)cls oriSEL:(SEL)oriSEL swizzledSEL:(SEL)swizzledSEL {
    
    if (!cls) NSLog(@"传入的交换类不能为空");
    
    Method oriMethod = class_getInstanceMethod(cls, oriSEL);
    Method swiMethod = class_getInstanceMethod(cls, swizzledSEL);
    
    if (!oriMethod) {
        class_addMethod(cls, oriSEL, method_getImplementation(swiMethod), method_getTypeEncoding(swiMethod));
        method_setImplementation(swiMethod, imp_implementationWithBlock(^(id self, SEL _cmd) {
            NSLog(@"方法未实现");
        }));
    }

    BOOL didAddMethod = class_addMethod(cls, oriSEL, method_getImplementation(swiMethod), method_getTypeEncoding(swiMethod));
    if (didAddMethod) {
        class_replaceMethod(cls, swizzledSEL, method_getImplementation(oriMethod), method_getTypeEncoding(oriMethod));
    } else {
        method_exchangeImplementations(oriMethod, swiMethod);
    }
}

- (void)cj_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath block:(TCJKVOBlock)block{
    
    // 判空
    if (keyPath == nil || keyPath.length == 0) return;
    
    // 判断是否有keyPath这个属性————分类中的属性没有setter方法也会返回YES
//    if (![self isContainProperty:keyPath]) return;
    
    // 判断是否有setter方法
    if (![self isContainSetterMethodFromKeyPath:keyPath]) return;
    
    // 判断automaticallyNotifiesObserversForKey方法返回的布尔值
    BOOL isAutomatically = [self cj_performSelectorWithMethodName:@"automaticallyNotifiesObserversForKey:" keyPath:keyPath];
    if (!isAutomatically) return ;
    
    // 2: 动态生成子类
    Class newClass = [self createChildClassWithKeyPath:keyPath];
    // 3: isa的指向 : LGKVONotifying_LGPerson
    object_setClass(self, newClass);
    // 4: 保存信息
    TCJInfo *info = [[TCJInfo alloc] initWithObserver:observer forKeyPath:keyPath handleBlock:block];
    NSMutableArray *mArray = objc_getAssociatedObject(self, (__bridge const void * _Nonnull)(kTCJKVOAssiociateKey));
    if (!mArray) {
        mArray = [NSMutableArray arrayWithCapacity:1];
        objc_setAssociatedObject(self, (__bridge const void * _Nonnull)(kTCJKVOAssiociateKey), mArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    [mArray addObject:info];
}

#pragma mark - 判断方法
/// 判断属性是否存在
/// @param keyPath 属性名
- (BOOL)isContainProperty:(NSString *)keyPath {
    unsigned int number;
    objc_property_t *propertiList = class_copyPropertyList([self class], &number);
    for (unsigned int i = 0; i < number; i++) {
        const char *propertyName = property_getName(propertiList[i]);
        NSString *propertyString = [NSString stringWithUTF8String:propertyName];
        
        if ([keyPath isEqualToString:propertyString]) {
            NSLog(@"找到了该属性%@", keyPath);
            return YES;
        }
    }
    free(propertiList);
    NSLog(@"没找到该属性%@", keyPath);
    return NO;
}

/// 判断setter方法
/// @param keyPath 属性名
- (BOOL)isContainSetterMethodFromKeyPath:(NSString *)keyPath {
    Class superClass    = object_getClass(self);
    SEL setterSeletor   = NSSelectorFromString(setterForGetter(keyPath));
    Method setterMethod = class_getInstanceMethod(superClass, setterSeletor);
    if (!setterMethod) {
        NSLog(@"没找到该属性的setter方法%@", keyPath);
        return NO;
    }
    return YES;
}

/// 动态调用类方法，返回调用方法的返回值
/// @param methodName 方法名
/// @param keyPath 观察属性
- (BOOL)cj_performSelectorWithMethodName:(NSString *)methodName keyPath:(id)keyPath {

    if ([[self class] respondsToSelector:NSSelectorFromString(methodName)]) {

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        BOOL i = [[self class] performSelector:NSSelectorFromString(methodName) withObject:keyPath];
        return i;
#pragma clang diagnostic pop
    }
    return NO;
}

- (void)cj_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath{
    
    NSMutableArray *observerArr = objc_getAssociatedObject(self, (__bridge const void * _Nonnull)(kTCJKVOAssiociateKey));
    if (observerArr.count<=0) {
        return;
    }
    
    for (TCJInfo *info in observerArr) {
        if ([info.keyPath isEqualToString:keyPath]) {
            [observerArr removeObject:info];
            objc_setAssociatedObject(self, (__bridge const void * _Nonnull)(kTCJKVOAssiociateKey), observerArr, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            break;
        }
    }
    
    if (observerArr.count<=0) {
        // 指回给父类
        Class superClass = [self class];
        object_setClass(self, superClass);
    }
}

#pragma mark - 验证是否存在setter方法
- (void)judgeSetterMethodFromKeyPath:(NSString *)keyPath{
    Class superClass    = object_getClass(self);
    SEL setterSeletor   = NSSelectorFromString(setterForGetter(keyPath));
    Method setterMethod = class_getInstanceMethod(superClass, setterSeletor);
    if (!setterMethod) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"老铁没有当前 %@ 的setter",keyPath] userInfo:nil];
    }
}

#pragma mark - 创建类
- (Class)createChildClassWithKeyPath:(NSString *)keyPath{
    
    NSString *oldClassName = NSStringFromClass([self class]);
    NSString *newClassName = [NSString stringWithFormat:@"%@%@",kTCJKVOPrefix,oldClassName];
    Class newClass = NSClassFromString(newClassName);
    // 防止重复创建生成新类
    if (newClass) return newClass;
    /**
     * 如果内存不存在,创建生成
     * 参数一: 父类
     * 参数二: 新类的名字
     * 参数三: 新类的开辟的额外空间
     */
    // 2.1 : 申请类
    newClass = objc_allocateClassPair([self class], newClassName.UTF8String, 0);
    // 2.2 : 注册类
    objc_registerClassPair(newClass);
    // 2.3.1 : 添加class : class的指向是TCJPerson
    SEL classSEL = NSSelectorFromString(@"class");
    Method classMethod = class_getInstanceMethod([self class], classSEL);
    const char *classTypes = method_getTypeEncoding(classMethod);
    class_addMethod(newClass, classSEL, (IMP)cj_class, classTypes);
    // 2.3.2 : 添加setter
    SEL setterSEL = NSSelectorFromString(setterForGetter(keyPath));
    Method setterMethod = class_getInstanceMethod([self class], setterSEL);
    const char *setterTypes = method_getTypeEncoding(setterMethod);
    class_addMethod(newClass, setterSEL, (IMP)cj_setter, setterTypes);
    
    // 2.3.3 : 添加dealloc
//    SEL deallocSEL = NSSelectorFromString(@"dealloc");
//    Method deallocMethod = class_getInstanceMethod([self class], deallocSEL);
//    const char *deallocTypes = method_getTypeEncoding(deallocMethod);
//    class_addMethod(newClass, deallocSEL, (IMP)cj_dealloc, deallocTypes);
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self cj_methodSwizzlingWithClass:[self class] oriSEL:NSSelectorFromString(@"dealloc") swizzledSEL:@selector(cj_dealloc)];
    });
    
    return newClass;
}

static void cj_setter(id self,SEL _cmd,id newValue){
    NSLog(@"来了:%@",newValue);
    NSString *keyPath = getterForSetter(NSStringFromSelector(_cmd));
    id oldValue = [self valueForKey:keyPath];
    // 4: 消息转发 : 转发给父类
    // 改变父类的值 --- 可以强制类型转换
    void (*cj_msgSendSuper)(void *,SEL , id) = (void *)objc_msgSendSuper;
    // void /* struct objc_super *super, SEL op, ... */
    struct objc_super superStruct = {
        .receiver = self,
        .super_class = class_getSuperclass(object_getClass(self)),
    };
    //objc_msgSendSuper(&superStruct,_cmd,newValue)
    cj_msgSendSuper(&superStruct,_cmd,newValue);
    
    // 5: 信息数据回调
    NSMutableArray *mArray = objc_getAssociatedObject(self, (__bridge const void * _Nonnull)(kTCJKVOAssiociateKey));
    
    for (TCJInfo *info in mArray) {
        if ([info.keyPath isEqualToString:keyPath] && info.handleBlock) {
            info.handleBlock(info.observer, keyPath, oldValue, newValue);
        }
    }
}

Class cj_class(id self,SEL _cmd){
    return class_getSuperclass(object_getClass(self));
}

#pragma mark - 从get方法获取set方法的名称 key ===>>> setKey:
static NSString *setterForGetter(NSString *getter){
    
    if (getter.length <= 0) { return nil;}
    
    NSString *firstString = [[getter substringToIndex:1] uppercaseString];
    NSString *leaveString = [getter substringFromIndex:1];
    
    return [NSString stringWithFormat:@"set%@%@:",firstString,leaveString];
}

#pragma mark - 从set方法获取getter方法的名称 set<Key>:===> key
static NSString *getterForSetter(NSString *setter){
    
    if (setter.length <= 0 || ![setter hasPrefix:@"set"] || ![setter hasSuffix:@":"]) { return nil;}
    
    NSRange range = NSMakeRange(3, setter.length-4);
    NSString *getter = [setter substringWithRange:range];
    NSString *firstString = [[getter substringToIndex:1] lowercaseString];
    return  [getter stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:firstString];
}
@end
