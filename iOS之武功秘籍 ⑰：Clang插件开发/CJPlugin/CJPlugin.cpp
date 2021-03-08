#include <iostream>
#include "clang/AST/AST.h"
#include "clang/AST/DeclObjC.h"
#include "clang/AST/ASTConsumer.h"
#include "clang/ASTMatchers/ASTMatchers.h"
#include "clang/Frontend/CompilerInstance.h"
#include "clang/ASTMatchers/ASTMatchFinder.h"
#include "clang/Frontend/FrontendPluginRegistry.h"

using namespace clang;
using namespace std;
using namespace llvm;
using namespace clang::ast_matchers;
//声明命名空间，和插件同名
namespace CJPlugin {

//第三步：扫描完毕的回调函数
//4、自定义回调类，继承自MatchCallback
class CJMatchCallback: public MatchFinder::MatchCallback {
    
private:
    //CI传递路径：CJASTAction类中的CreateASTConsumer方法参数 - CJConsumer的构造函数 - CJMatchCallback的私有属性，通过构造函数从CJASTConsumer构造函数中获取
    CompilerInstance &CI;
    
    //判断是否是自己的文件
    bool isUserSourceCode(const string filename) {
        //文件名不为空
        if (filename.empty()) return false;
        //非xcode中的源码都认为是用户的
        if (filename.find("/Applications/Xcode.app/") == 0) return false;
        return  true;
    }

    //判断是否应该用copy修饰
    bool isShouldUseCopy(const string typeStr) {
        //判断类型是否是NSString | NSArray | NSDictionary
        if (typeStr.find("NSString") != string::npos ||
            typeStr.find("NSArray") != string::npos ||
            typeStr.find("NSDictionary") != string::npos/*...*/)
        {
            return true;
        }
        
        return false;
    }
    
public:
    CJMatchCallback(CompilerInstance &CI):CI(CI){}
    
    //重写run方法
    void run(const MatchFinder::MatchResult &Result) {
        //通过result获取到相关节点 -- 根据节点标记获取（标记需要与CJASTConsumer构造方法中一致）
        const ObjCPropertyDecl *propertyDecl = Result.Nodes.getNodeAs<ObjCPropertyDecl>("objcPropertyDecl");
        //判断节点有值，并且是用户文件
        if (propertyDecl && isUserSourceCode(CI.getSourceManager().getFilename(propertyDecl->getSourceRange().getBegin()).str()) ) {
            //15、获取节点的描述信息
            ObjCPropertyAttribute::Kind attrKind = propertyDecl->getPropertyAttributes();
            //获取节点的类型，并转成字符串
            string typeStr = propertyDecl->getType().getAsString();
//            cout<<"---------拿到了："<<typeStr<<"---------"<<endl;
            
            //判断应该使用copy，但是没有使用copy
            if (propertyDecl->getTypeSourceInfo() && isShouldUseCopy(typeStr) && !(attrKind & ObjCPropertyAttribute::kind_copy)) {
                //使用CI发警告信息
                //通过CI获取诊断引擎
                DiagnosticsEngine &diag = CI.getDiagnostics();
                //通过诊断引擎 report报告 错误，即抛出异常
                /*
                错误位置：getBeginLoc 节点开始位置
                错误：getCustomDiagID（等级，提示）
                 */
                diag.Report(propertyDecl->getBeginLoc(), diag.getCustomDiagID(DiagnosticsEngine::Warning, "%0 - 这个地方推荐使用copy!!"))<< typeStr;
            }
        }
    }
};


//第二步：扫描配置完毕
//3、自定义CJASTConsumer，继承自ASTConsumer，用于监听AST节点的信息 -- 过滤器
class CJASTConsumer: public ASTConsumer {
private:
    //AST节点的查找过滤器
    MatchFinder matcher;
    //定义回调类对象
    CJMatchCallback callback;
    
public:
    //构造方法中创建matcherFinder对象
    CJASTConsumer(CompilerInstance &CI) : callback(CI) {
        //添加一个MatchFinder，每个objcPropertyDecl节点绑定一个objcPropertyDecl标识（去匹配objcPropertyDecl节点）
        //回调callback，其实是在CJMatchCallback里面重写run方法（真正回调的是回调run方法）
        matcher.addMatcher(objcPropertyDecl().bind("objcPropertyDecl"), &callback);
    }
    
    //实现两个回调方法 HandleTopLevelDecl 和 HandleTranslationUnit
    //解析完一个顶级的声明，就回调一次(顶级节点，相当于一个全局变量、函数声明)
    bool HandleTopLevelDecl(DeclGroupRef D){
//        cout<<"正在解析..."<<endl;
        return  true;
    }
    
    //整个文件都解析完成的回调
    void HandleTranslationUnit(ASTContext &context) {
//        cout<<"文件解析完毕!"<<endl;
        //将文件解析完毕后的上下文context（即AST语法树） 给 matcher
        matcher.matchAST(context);
    }
};

//2、继承PluginASTAction，实现我们自定义的Action，即自定义AST语法树行为
class CJASTAction: public PluginASTAction {
    
public:
    //重载ParseArgs 和 CreateASTConsumer方法
    bool ParseArgs(const CompilerInstance &ci, const std::vector<std::string> &args) {
        return true;
    }
    
    //返回ASTConsumer类型对象，其中ASTConsumer是一个抽象类，即基类
    /*
     解析给定的插件命令行参数。
     - param CI 编译器实例，用于报告诊断。
     - return 如果解析成功，则为true；否则，插件将被销毁，并且不执行任何操作。该插件负责使用CompilerInstance的Diagnostic对象报告错误。
     */
    unique_ptr<ASTConsumer> CreateASTConsumer(CompilerInstance &CI, StringRef iFile) {
        //返回自定义的CJASTConsumer,即ASTConsumer的子类对象
        /*
         CI用于：
         - 判断文件是否使用户的
         - 抛出警告
         */
        return unique_ptr<CJASTConsumer> (new CJASTConsumer(CI));
    }
    
};

}

//第一步：注册插件，并自定义AST语法树Action类
//1、注册插件
static FrontendPluginRegistry::Add<CJPlugin::CJASTAction> CJ("CJPlugin", "This is CJPlugin");
