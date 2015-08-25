//
//  BHSocketRecMsgStatusMsg.h
//  BHJingYingHui
//
//  Created by hepeilin on 14-8-7.
//  Copyright (c) 2014年 boyce. All rights reserved.
//

#import "BHSocketBaseMsg.h"

@interface BHSocketRecMsgStatusMsg : BHSocketBaseMsg
@property (nonatomic) int chat_type;    //聊天类型，0系统，1私聊，2群聊，3系统通信
@property (nonatomic) int login_type;    //登录类型，1app，2web
@property (nonatomic) unsigned long long chat_id;   //聊天ID
@property (nonatomic) unsigned long long from_cust_id;    //发信人ID
@property (nonatomic) unsigned long long to_cust_id;    //收信人ID
@property (nonatomic) unsigned int status_code;    //状态码
@property (nonatomic) unsigned long long msg_time;    //消息发送时间
@end
