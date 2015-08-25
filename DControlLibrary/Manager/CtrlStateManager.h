//
//  CtrlStateManager.h
//  D-Controls Plus
//
//  Created by Liu Tao on 12-11-16.
//  Copyright (c) 2012年 D-Haus Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CtrlStateManager : NSObject

- (void)setOnOff:(int)onoff mode:(int)mode fan:(int)fan temperature:(int)temperature forAddress:(int)addr warning:(int)warning;
- (NSDictionary *)getAcStateForAddress:(NSNumber *)addr;
- (NSDictionary *)getAcStateForAcMenuForAddress:(NSNumber *)addr;

@end
