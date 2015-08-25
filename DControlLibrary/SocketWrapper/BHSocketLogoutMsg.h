//
//  BHSocketLogoutMsg.h
//  BHJingYingHui
//
//  Created by hepeilin on 14-8-7.
//  Copyright (c) 2014年 boyce. All rights reserved.
//

#import "BHSocketBaseMsg.h"

@interface BHSocketLogoutMsg : BHSocketBaseMsg

@property (nonatomic) char login_type;    //登录类型，1app，2web
@property (nonatomic) unsigned long long from_cust_id;    //发信人ID
@property (nonatomic) unsigned int status_code;    //状态码


@end
