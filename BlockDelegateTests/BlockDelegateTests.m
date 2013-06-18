//
//  BlockDelegateTests.m
//  BlockDelegateTests
//
//  Created by Manu Wallner on 17.06.13.
//  Copyright (c) 2013 Xforge. All rights reserved.
//

#import "BlockDelegateTests.h"
#import "XFBlockDelegate.h"
#import "XFTestProtocol.h"

@implementation BlockDelegateTests {
    XFBlockDelegate *_delegate;
    id<XFTestProtocol> _delegateId;
}

- (void)setUp
{
    [super setUp];
    _delegate = [XFBlockDelegate delegateWithProtocol:@protocol(XFTestProtocol)];
    _delegateId = (id<XFTestProtocol>)_delegate; //Trust me on this one, clang :)
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    _delegate = nil;
    [super tearDown];
}

- (void)testInit {
    STAssertNotNil(_delegate, @"The delegate should be instantiated correctly!");
}

- (void)testConformsToProtocol {
    STAssertTrue([_delegate conformsToProtocol:@protocol(XFTestProtocol)], @"The delegate should conform to the protocol that was passed to it");
}

- (void)testHandlesNilCorrectly {
    XFBlockDelegate *nilDelegate = [XFBlockDelegate delegateWithProtocol:nil];
    STAssertNil(nilDelegate, @"Passing nil as protocol is undefined, so the constructor should return nil!");
}

- (void)testSetsProtocolProperty {
    STAssertNotNil(_delegate.protocol, @"The delegate should set the Protocol on construction!");
}

- (void)testSubscriptOperator {
    STAssertFalse([_delegate respondsToSelector:@selector(requiredMethod)], @"The delegate can't implement a method it doesn't know about yet!");
    _delegate[@"requiredMethod"] = ^{ };
    STAssertTrue([_delegate respondsToSelector:@selector(requiredMethod)], @"The subscript operator should create a new method on the delegate");
}

- (void)testMethodInvocation {
    __block BOOL worked = NO;
    _delegate[@"requiredMethod"] = ^{
        worked = YES;
    };
    [_delegate performSelector:@selector(requiredMethod)];
    STAssertTrue(worked, @"The method on the delegate should have been called");
}

- (void)testSubscriptCorrectlyHandlesNil {
    STAssertThrows(_delegate[@"requiredMethodWithParam:"] = nil, @"The delegate should fail gracefully when passing nil as method implementation");
    STAssertFalse([_delegate respondsToSelector:@selector(requiredMethodWithParam:)], @"The method shouldn't have been created on the delegate when passing nil as implementation");
}

- (void)testMethodInvocationWithSingleParam {
    __block BOOL worked = NO;
    _delegate[@"requiredMethodWithParam:"] = ^(BOOL param) {
        worked = param;
    };
    [_delegateId requiredMethodWithParam:YES];
    STAssertTrue(worked, @"Passing Parameters to Methods should work!");
}

- (void)testDoesntImplementMethodsNotInProtocolInObjcRuntime {
    STAssertThrows(_delegate[@"evictsObjectsWithDiscardedContent"] = ^{}, @"Implementing a method not in the protocol shouldn't work!");
    STAssertFalse([_delegate respondsToSelector:@selector(evictsObjectsWithDiscardedContent)], @"The method that isn't implemented on the Protocol shouldn't have been added as a selector");
}

- (void)testDoesntImplementRandomSelector {
    NSString *key = @"afgaergponergilngeialgnognreoögnfleogn"; //Let's hope no one implements this
    STAssertThrows(_delegate[key] = ^{}, @"The delegate should handle unrecognized selectors (not registered with objc runtime) gracefully");
    STAssertFalse([_delegate respondsToSelector:NSSelectorFromString(key)], @"The delegate shouldn't have implemented the Method!");
}

- (void)testImplementingOptionalMethodsWorks {
    __block BOOL worked = NO;
    _delegate[@"optionalMethodWithParam:"] = ^(BOOL param) {
        worked = param;
    };
    [_delegateId optionalMethodWithParam:NO];
    STAssertTrue(worked, @"Optional Methods should work on the delegate!");
}

- (void)testDifferentMethodSignaturesShouldntWork {
    STAssertThrows(_delegate[@"optionalMethodWithParam:"] = ^(BOOL firstParam, id secondParam) {}, @"Passing Blocks with the wrong signature shouldn't work!");
}

- (void)testOnlyAcceptsStringsAsKeys {
    STAssertThrows(_delegate[@2] = ^{}, @"The delegate should only accept Strings as keys!");
}

@end
