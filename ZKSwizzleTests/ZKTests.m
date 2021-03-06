//
//  ZKTests.m
//  ZKSwizzle
//
//  Created by Alexander S Zielenski on 7/24/14.
//  Copyright (c) 2014 Alexander S Zielenski. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "ZKSwizzle.h"

@interface ZKOriginalClass : NSObject {
    int ivar;
}
+ (NSString *)classMethod;
+ (NSString *)description;
- (NSString *)instanceMethod;
- (NSString *)description;
- (int)ivar;
@end

@implementation ZKOriginalClass
- (id)init { if ((self = [super init])) { ivar = 1; } return self; }
+ (BOOL)isSubclassOfClass:(Class)aClass { return YES; }
+ (NSString *)classMethod { return @"original"; }
+ (NSString *)description { return @"original"; }
- (NSString *)instanceMethod { return @"original"; }
- (NSString *)description { return @"original"; }
- (int)ivar { return ivar; }
- (NSString *)selectorName { return NSStringFromSelector(_cmd); }
@end

@interface ZKSwizzleClass : ZKOriginalClass @end
@implementation ZKSwizzleClass

+ (BOOL)isSubclassOfClass:(Class)aClass {
    return ZKOrig(BOOL);
}

- (NSString *)className {
    return [ZKOrig(NSString *) stringByAppendingString:@"_replaced"];
}

+ (NSString *)classMethod {
    return @"replaced";
}

+ (NSString *)description {
    return ZKSuper(NSString *);
}

- (NSString *)instanceMethod {
    return @"replaced";
}

- (NSString *)description {
    return ZKSuper(NSString *);
}

- (int)ivar {
    int *hooked = &ZKHookIvar(self, int, "ivar");
    *hooked = 3;
    return ZKOrig(int);
}

- (NSString *)selectorName { return ZKOrig(NSString *); }

@end

@interface ZKTests : XCTestCase
@end

@implementation ZKTests

- (void)setUp {
    [super setUp];
    ZKSwizzleClass(ZKSwizzleClass);
}

- (void)testExample {
    ZKOriginalClass *instance = [[ ZKOriginalClass alloc] init];
    XCTAssertEqualObjects([ ZKOriginalClass classMethod], @"replaced", @"replacing class methods");
    XCTAssertEqualObjects([instance instanceMethod], @"replaced", @"replacing instance methods");
    XCTAssertNotEqualObjects([ ZKOriginalClass description], @"original", @"calling super on class");
    XCTAssertNotEqualObjects([instance description], @"original", @"calling super on instance");
    XCTAssertEqual([ ZKOriginalClass isSubclassOfClass:[NSString class]], YES, @"calling super imp on class");
    XCTAssertEqualObjects([instance className], @"ZKOriginalClass_replaced", @"calling original imp on instance");
    XCTAssertEqualObjects([instance selectorName], @"selectorName", @"_cmd correct on original imps");
    XCTAssertEqual([instance ivar], 3, @"hooking ivars");
}

@end
