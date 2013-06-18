//
//  XFBlockDelegate.m
//  BlockDelegate
//
//  Created by Manu Wallner on 17.06.13.
//  Copyright (c) 2013 Xforge. All rights reserved.
//

#import "XFBlockDelegate.h"
#import <objc/runtime.h>
#import "CTBlockDescription.h"

@implementation XFBlockDelegate {
    Protocol *_implementedProtocol;
}

static unsigned _classCounter = 0;
+ (instancetype)delegateWithProtocol:(Protocol *)protocol {
    if(protocol == nil) return nil;
    static const size_t bufsize = 128;
    char buffer[bufsize];
    __block unsigned currentSubclass = 0;
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        currentSubclass = _classCounter++;
    });
    snprintf(buffer, bufsize, "XFBlockDelegateSub%u", currentSubclass);
    Class newSubclass = objc_allocateClassPair(self, buffer, 0);
    NSAssert(newSubclass, @"Couldn't create XFBlockDelegate subclass");
    BOOL didAddProtocol = class_addProtocol(newSubclass, protocol);
    NSAssert(didAddProtocol, @"Couldn't add Protocol to XFBlockDelegate subclass");
    objc_registerClassPair(newSubclass);
    return [[newSubclass alloc] initWithProtocol:protocol];
}

- (instancetype)initWithProtocol:(Protocol *)protocol {
    self = [super init];
    if (self) {
        _implementedProtocol = protocol;
    }
    return self;
}

- (SEL)selectorFromString:(id)string {
    NSAssert([string isKindOfClass:[NSString class]], @"Key must be a String!");
    SEL selector = NSSelectorFromString(string);
    return selector;
}

- (id)objectAtKeyedSubscript:(id<NSCopying>)key {
    SEL selector = [self selectorFromString:key];
    Method method = class_getInstanceMethod([self class], selector);
    if(!method) return nil;
    return imp_getBlock(method_getImplementation(method));
}

- (void)setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key {
    SEL selector = [self selectorFromString:key];
    [self implementSelector:selector withBlock:obj];
}

- (void)implementSelector:(SEL)selector withBlock:(id)block {
    if(!block) {
        [NSException raise:@"XFBlockDelegateException" format:@"Got nil passed as implementation"];
    }
    unsigned int descriptionCount = 0;
    CTBlockDescription *blockDescription = [[CTBlockDescription alloc] initWithBlock:block];
    for(int required = NO; required <= 1; ++required) { // NO == 0, YES == 1 -> that's what this loop uses to pass the "isRequiredMethod" to the copyMethodDescriptionList call
        struct objc_method_description *descriptionList = protocol_copyMethodDescriptionList(_implementedProtocol, required, YES, &descriptionCount);
        for (int descriptionIndex = 0; descriptionIndex < descriptionCount; ++descriptionIndex) {
            struct objc_method_description description = descriptionList[descriptionIndex];
            if (sel_isEqual(selector, description.name)) {
                NSMethodSignature *methodSignature = [NSMethodSignature signatureWithObjCTypes:description.types];
                if (![blockDescription isCompatibleForBlockSwizzlingWithMethodSignature:methodSignature]) {
                    [NSException raise:@"XFBlockDelegateException" format:@"Signature Mismatch between Block and Protocol Method!"];
                }
                if(class_addMethod([self class], selector, imp_implementationWithBlock([block copy]), description.types)) {
                    return;
                } else {
                    [NSException raise:@"XFBlockDelegateException" format:@"Couldn't add method to class, better check your parameters!"];
                }
            }
        }
        free(descriptionList);
    }
    [NSException raise:@"XFBlockDelegateException" format:@"Couldn't find a selector to implement!"];
}

- (Protocol *)protocol {
    return _implementedProtocol;
}

@end
