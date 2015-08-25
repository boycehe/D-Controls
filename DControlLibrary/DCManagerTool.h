//
//  DCManagerTool.h
//  D-Controls
//
//  Created by heboyce on 8/25/15.
//  Copyright © 2015 boycehe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GlobalDef.h"
@class RecModel;

@interface DCManagerTool : NSObject
+ (UDP_TYPE)getUdpTypeWithModel:(RecModel*)model;
+ (NSString*)randomString;
+ (NSArray*)SortArray:(NSArray*)array;
+ (NSArray*)SortDicArray:(NSArray*)array;
+ (NSString*)generateDeviceName:(long)deviceSN;
@end

