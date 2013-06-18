//
//  XFBlockDelegate.h
//  BlockDelegate
//
//  Created by Manu Wallner on 17.06.13.
//  Copyright (c) 2013 Xforge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XFBlockDelegate : NSObject

+ (instancetype)delegateWithProtocol:(Protocol *)protocol;
- (id)objectAtKeyedSubscript:(id <NSCopying>)key;
- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key;
- (void)implementSelector:(SEL)selector withBlock:(id)block;

@property (nonatomic, readonly, strong) Protocol *protocol;

@end