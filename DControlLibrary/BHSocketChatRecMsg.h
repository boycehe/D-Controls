//
//  BHSocketChatRecMsg.h
//  BHJingYingHui
//
//  Created by hepeilin on 14-8-7.
//  Copyright (c) 2014年 boyce. All rights reserved.
//

#import "BHSocketBaseMsg.h"

@interface BHSocketChatRecMsg : BHSocketBaseMsg
@property (nonatomic) int chat_type;    //聊天类型，0系统，1私聊，2群聊，3系统通信
@property (nonatomic) long long msg_time;    //消息发送时间
@property (nonatomic) long long chat_id;   //聊天ID
@property (nonatomic) long long from_cust_id;    //发信人ID
@property (nonatomic) long long to_cust_id;    //收信人ID
@property (nonatomic) unsigned int content_len;    //内容长度
@property (nonatomic) NSData* content;    //内容JSON格式
@property (nonatomic) char   contentType;
@property (nonatomic) long long new_chat_id;

@end
