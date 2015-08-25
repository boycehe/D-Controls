//
//  BHSocketConnectInfo.h
//  BHJingYingHui
//
//  Created by hepeilin on 14-8-6.
//  Copyright (c) 2014年 boyce. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BHSocketConnectInfo : NSObject
@property (nonatomic,strong) NSString *socketIP;
@property (nonatomic,assign) int       socketPort;
@property (nonatomic,strong) NSString *socketAuth;

+ (BHSocketConnectInfo*)dicToConntectInfo:(NSDictionary*)dic;
- (BOOL)isValidSocketInfo;
@end
