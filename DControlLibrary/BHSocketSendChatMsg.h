//
//  BHSocketSendChatMsg.h
//  BHJingYingHui
//
//  Created by hepeilin on 14-8-7.
//  Copyright (c) 2014年 boyce. All rights reserved.
//

#import "BHSocketBaseMsg.h"

@interface BHSocketSendChatMsg : BHSocketBaseMsg
@property (nonatomic) int chat_type;    //聊天类型，0系统，1私聊，2群聊，3系统通信
@property (nonatomic) int login_type;    //登录类型，1app，2web
@property (nonatomic) NSString* login_auth;    //登录验证key
@property (nonatomic) unsigned int msg_expire_time;    //消息过期时间
@property (nonatomic) unsigned long long msg_time;    //消息发送时间
@property (nonatomic) unsigned long long chat_id;   //聊天ID
@property (nonatomic) unsigned long long from_cust_id;    //发信人ID
@property (nonatomic) unsigned long long to_cust_id;    //收信人ID
@property (nonatomic) unsigned int content_len;    //内容长度
@property (nonatomic) short        contentType;//Content内容类型
@property (nonatomic,strong) NSData* content;    //内容JSON格式


@end
