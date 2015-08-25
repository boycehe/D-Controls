//
//  BHLocationManager.h
//  BHAirConditionControls
//
//  Created by heboyce on 6/11/15.
//  Copyright (c) 2015 boyce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface BHLocationManager : NSObject
@property (copy, nonatomic) void (^locationBlock)(BHLocationManager *manager, CLLocation *location);
+ (BHLocationManager*)shareLocationManager;
- (void)getLocationWithBlock:(void (^)(BHLocationManager *manager, CLLocation *location))locationBlock;
@end
