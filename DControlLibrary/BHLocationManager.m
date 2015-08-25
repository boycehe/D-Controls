//
//  BHLocationManager.m
//  BHAirConditionControls
//
//  Created by heboyce on 6/11/15.
//  Copyright (c) 2015 boyce. All rights reserved.
//

#import "BHLocationManager.h"


BHLocationManager *_locationManager = nil;

@interface BHLocationManager()<CLLocationManagerDelegate>
@property (nonatomic,strong) CLLocationManager *manager;
@end

@implementation BHLocationManager

- (id)init{

    self = [super init];
    
   
    
    return self;
}

+ (BHLocationManager*)shareLocationManager{

    if (_locationManager == nil) {
        _locationManager = [[BHLocationManager alloc] init];
    }
    
    return _locationManager;

}


- (void)start{
    
    if (_manager == nil)
        _manager = [[CLLocationManager alloc] init];
    
     _manager.delegate           = self;//设置代理
     _manager.desiredAccuracy    = kCLLocationAccuracyBest;//指定需要的精度级别
    // _manager.distanceFilter     = 10.0f;//设置距离筛选器
    [_manager startUpdatingLocation];//启动位置管理器

}

- (void)stop{
    
    [_manager stopUpdatingLocation];
    _manager = nil;

}

- (void)getLocationWithBlock:(void (^)(BHLocationManager *manager, CLLocation *location))locationBlock{


    self.locationBlock = locationBlock;
    
    [self start];

}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation{

    
    if (self.locationBlock != NULL) {
        self.locationBlock(self,newLocation);
        [self stop];
    }
    NSLog(@"latitude:%f,longitude:%f",newLocation.coordinate.latitude,newLocation.coordinate.longitude);
    
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {

    if (self.locationBlock != NULL) {
        self.locationBlock(self,[locations objectAtIndex:0]);
        [self stop];
    }


}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error{

    NSLog(@"定位出错:%@",error);


}

@end
