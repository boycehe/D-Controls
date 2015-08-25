//
//  BHSocketConnectInfo.m
//  BHJingYingHui
//
//  Created by hepeilin on 14-8-6.
//  Copyright (c) 2014年 boyce. All rights reserved.
//

#import "BHSocketConnectInfo.h"

@implementation BHSocketConnectInfo

+ (BHSocketConnectInfo*)dicToConntectInfo:(NSDictionary*)dic{

    BHSocketConnectInfo  *info = [BHSocketConnectInfo new];
    
    info.socketIP = [dic objectForKey:@"ip"];
    info.socketPort = [[dic objectForKey:@"port"] intValue];
    info.socketAuth = [dic objectForKey:@"auth"];
    
    
    return info;
    
}


- (BOOL)isValidSocketInfo{


    if (self.socketIP == nil || self.socketPort == 0 || self.socketAuth == nil) {
        NSLog(@"wrong ip address or auth key");
        return NO;
    }

    return YES;

}

@end
