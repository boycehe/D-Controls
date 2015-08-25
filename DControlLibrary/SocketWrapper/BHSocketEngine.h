//
//  BHSocketEngine.h
//  BHJingYingHui
//
//  Created by hepeilin on 14-8-6.
//  Copyright (c) 2014年 boyce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncSocket.h"
#import "BHMsgInfo.h"
#import "BHSocketLogoutMsg.h"
#import "BHSocketSendChatMsg.h"

@class BHSocketChatRecMsg;
@class BHSocketConnectInfo;
typedef enum{

    BH_Socket_Connecting = 12,
    BH_Socket_ConnectSucc = 13,
    BH_Socket_ConnectFail = 14,

    
}BHSocketStatus;

typedef enum {

    BH_Socket_Type_HeartMsg  = 6,
    BH_Socket_Type_LoginCallBack = 2,
    BH_Socket_Type_SendMsgCallBack = 4,
    BH_Socket_Type_RecChatMsg  = 5,
    BH_Socket_Type_KicMsg = 7,
    
    
}BHSocketMsgType;

typedef enum {
    
    BH_Socket_JsonCnt_News = 11,
    BH_Socket_JsonCnt_Activity = 12,
    BH_Socket_JsonCnt_Bussiness = 13,
    BH_Socket_JsonCnt_JoinGroup = 19,
    BH_Socket_JsonCnt_ExitGroup = 20,
    BH_Socket_JsonCnt_AmendGroupName = 21,
    BH_Socket_JsonCnt_ApplyJoinGroup = 25,
    BH_Socket_JsonCnt_RegSuccWithInviteCode = 18,
    BH_Socket_JsonCnt_InviteReg = 7,
    BH_Socket_JsonCnt_FirendInvite = 8,
    BH_Socket_JsonCnt_FriendViaVerify = 10,
    BH_Socket_JsonCnt_UserAvatarUpdate   = 14,
    BH_Socket_JsonCnt_GroupAvatarUpdate  = 26,
    BH_Socket_JsonCnt_DissolveGroup  = 27,
    BH_Socket_JsonCnt_MayKnowPerson  = 28,
    BH_Socket_JsonCnt_HotTopic  = 29,
    


}BHSocketJsonType;

#define Socket_LoginSuccess_Time  @"Socket_LoginSuccess_Time"


//Elite Talk Buffer
#define     talkStart             2
#define     talkEnd               3
#define     talkExpireTime        (-1)
//app 登录
#define     talkAppLogin          1
#define     talkVersion           1
#define     talkHeartTime         30


/*
 2 图片
 16 动态表情
 4 音频
 17 位置
 1 文字
 14 26 27
[typeStr isEqualToString:@"18"] || [typeStr isEqualToString:@"7"] || [typeStr isEqualToString:@"8"] || [typeStr isEqualToString:@"10"])
 */

void numberHNMemcpy(void *dest, const void *src, unsigned int count);

@interface BHSocketEngine : NSObject<AsyncSocketDelegate>
{
    AsyncSocket *_bhSocket;
}
@property (nonatomic,assign) BHSocketStatus      socketStatus;
@property (nonatomic,strong) BHSocketConnectInfo *connectInfo;
@property (nonatomic,strong) NSTimer             *heartTimer;
@property (nonatomic,strong) NSTimer             *checkTimeOutTimer;
@property (nonatomic       ) float               connectTime;//最后一次从服务器返回消息得时间戳

+ (BHSocketEngine*)sharedInstance;

/**
 *  创建socket
 */
- (void)createSocket;
/**
 *  关闭socket
 */
- (void)closeSocket;

/**
 *  发送消息
 *
 *  @param msg 消息
 */
- (void)sendMessage:(BHSocketSendChatMsg*)msg;
/**
 *  处理消息
 *
 *  @param recMsgArr 消息数组
 */
- (void)handleMsgListInfoWithRecMsgArr:(NSArray*)recMsgArr;
/**
 *  处理消息
 *
 *  @param msg  BHSocketChatRecMsg类型西欧阿西
 *
 *  @return BHMsgInfo类型消息
 */
- (BHMsgInfo*)handleMsgListInfoWithRecMsg:(BHSocketChatRecMsg*)msg;

/**
 *  用户请求
 *
 *  @param msg BHSocketChatRecMsg类型消息
 */
- (void)handleSocketSycRequestMsgWithBaseMsg:(BHSocketChatRecMsg*)msg;
- (NSData*)shortToByte:(short)intStr Length:(int)length;

@end
