//
//  BHSocketBaseMsg.h
//  BHJingYingHui
//
//  Created by hepeilin on 14-8-7.
//  Copyright (c) 2014年 boyce. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MSG_START 0x02
#define MSG_END 0x03

enum MSG_TYPE {
    MSG_NULL = 0,               //错误类型
    MSG_LOGIN = 1,                  //登录消息
    MSG_LOGIN_STATUS,           //登录状态消息
    MSG_SENDS,                  //发送消息
    MSG_SEND_STATUS,            //发送状态消息
    MSG_RECV,                   //接收消息
    MSG_HEART = 6                    //心跳消息
};

@interface BHSocketBaseMsg : NSObject



@property (nonatomic) int start;                        //开始符号  char
@property (nonatomic) unsigned int len;                 //消息长度
@property (nonatomic) int version;                      //协议版本号
@property (nonatomic) unsigned short msg_no;        //消息编号   unsigned char
@property (nonatomic) short msg_type;                   //消息类型
@property (nonatomic) unsigned int check_code;          //校验码
@property (nonatomic) unsigned long long msg_id;        //消息ID
@property (nonatomic) int end;                          //结束符号 char
@end
