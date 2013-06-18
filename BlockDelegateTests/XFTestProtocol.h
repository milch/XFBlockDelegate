//
//  XFTestProtocol.h
//  BlockDelegate
//
//  Created by Manu Wallner on 18.06.13.
//  Copyright (c) 2013 Xforge. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol XFTestProtocol <NSObject>
@required
- (void)requiredMethod;
- (void)requiredMethodWithParam:(BOOL)param;
@optional
- (void)optionalMethodWithParam:(BOOL)param;
@end
