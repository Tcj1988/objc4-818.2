//
//  CTMediatorUITests.m
//  CTMediatorUITests
//
//  Created by casa on 2016/11/20.
//  Copyright © 2016年 casa. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface CTMediatorUITests : XCTestCase

@end

@implementation CTMediatorUITests

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = YES;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [[[XCUIApplication alloc] init] launch];
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testPresentDetailViewController
{
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app.tables.staticTexts[@"present detail view controller"] tap];
    [app.buttons[@"return"] tap];
    XCTAssertTrue(app.exists);
}

- (void)testCrashTableViewController
{
    XCUIApplication *app = [[XCUIApplication alloc] init];
    XCUIElement *cellToCrash = app.tables.staticTexts[@"table view cell"];
    [cellToCrash tap];
    XCTAssertTrue(app.exists);
}

@end
