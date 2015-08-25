//
//  BHSocketEngine.m
//  BHJingYingHui
//
//  Created by hepeilin on 14-8-6.
//  Copyright (c) 2014年 boyce. All rights reserved.
//
#import "BHSocketEngine.h"
#import "BHSocketConnectInfo.h"
#import "BHSocketBaseMsg.h"
#import "BHSocketLoginStatusMsg.h"
#import "BHSocketSendLoginMsg.h"
#import "BHSocketRecMsgStatusMsg.h"
#import "BHSocketChatRecMsg.h"
#import "UdpManager.h"
#import "PlistManager.h"
#import "UIAlertView+BlocksKit.h"
#import "PacketManager.h"
#import "UIAlertView+BlocksKit.h"
#import "DCManager.h"
#import "GlobalDef.h"
#import "JSONKit.h"

#define elite_char              (1)
#define elite_int               (4)
#define elite_unsigned_char     (1)
#define elite_short             (2)
#define elite_string_auth       (32)
#define elite_unsigned_int      (8)
#define elite_long_long         (8)

#define isBigEndian()           ( (*(char*) &endian) == 0 )
#define isLittlEndbian()        ( (*(char*) &endian) == 1 )

#define defaultIP               172.172.172.202
#define defaultPort             9876
#define defaultAuth             @"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

#define TimeOutSeconds    3



static BHSocketEngine* socketEngine = nil;

//获取校验码
unsigned short getMsgCheckCode(const char* buffer,unsigned int buffer_len)
{
    const int endian = 1;
	unsigned char tmp[2]={0,0},dest_tmp[2]={0,0};
	unsigned short dest=0;
	unsigned int len = 0;
	unsigned int offset = 0;
	unsigned int i;
    
	while(len < buffer_len)
	{
		if(len + 2 > buffer_len)
		{
			offset = buffer_len - len;
		}
		else
		{
			offset = 2;
		}
        
		
		for(i=0;i<offset;i++)
		{
            //NSLog(@"buffer is %02x",buffer[len + i]);
			tmp[i] ^= buffer[len + i];
            //NSLog(@"tmp is %02x",tmp[i]);
		}
        
        len += 2;
	}
    
	if(!isLittlEndbian())
	{
        for (i=0;i<2;i++) {
            //NSLog(@"tmp in endbian is %2x",tmp[i]);
        }
        
		for(i=0;i<2;i++)
		{
			dest_tmp[i] = tmp[1-i];
		}
		memcpy(&dest,dest_tmp,2);
	}
	else
	{
		memcpy(&dest,tmp,2);
	}
    
	return dest;
}



unsigned long long elite_bswap_64(unsigned long long inval)
{
    unsigned long long outval = 0;
    int i=0;
    for(i=0;i<8; i++)
        outval=(outval<<8)+ ((inval >> (i *8))&255);
    return   outval;
}
//进行大小端转化copy
void numberHNMemcpy(void *dest, const void *src, unsigned int count)
{
    //判断大小端
    const int endian = 1;
	if(!isLittlEndbian())
	{
		if(count == 8)
		{
			unsigned long long ll;
            memcpy(&ll,src,count);
            ll = elite_bswap_64(ll);
            memcpy(dest,&ll,count);
		}
		else if(count == 4)
		{
            unsigned int i;
			memcpy(&i,src,count);
			i = htonl(i);
			memcpy(dest,&i,count);
		}
		else if(count == 2)
		{
			unsigned short s;
			memcpy(&s,src,count);
			s = htons(s);
            memcpy(dest,&s,count);
		}
		else
		{
       		memcpy(dest,src,count);
		}
	}
	else
	{
        memcpy(dest,src,count);
	}
}

@interface BHSocketEngine()
@property (nonatomic,strong) NSData  *tempBufferData;
@property (nonatomic,strong) NSMutableDictionary *recTimeoutDic;
@end


@implementation BHSocketEngine

#pragma mark - Socket Action
+ (BHSocketEngine*)sharedInstance
{
    if (socketEngine == nil) {
        socketEngine = [[BHSocketEngine alloc] init];
    }
    
    return socketEngine;
}

#pragma mark SocketTool-----

- (NSData*)shortToByte:(short)intStr Length:(int)length
{
    NSData *testData = [NSData dataWithBytes:&intStr length:length];
    return testData;
    NSMutableData *tempData = [NSMutableData data];
    
    /*
     for (int i=length-1; i>=0; i--) {
     [tempData appendData:[testData subdataWithRange:NSMakeRange(i, 1)]];
     }
     */
    
    for (int i=0; i<length; i++) {
        [tempData appendData:[testData subdataWithRange:NSMakeRange(i, 1)]];
    }
    return tempData;
}

//将int改称固定长度data




- (NSData*)intToByte:(int)intStr Length:(int)length
{
    NSData *testData = [NSData dataWithBytes:&intStr length:length];
    return testData;
    NSMutableData *tempData = [NSMutableData data];
    
    /*
    for (int i=length-1; i>=0; i--) {
        [tempData appendData:[testData subdataWithRange:NSMakeRange(i, 1)]];
    }
    */
    
    for (int i=0; i<length; i++) {
        [tempData appendData:[testData subdataWithRange:NSMakeRange(i, 1)]];
    }
    return tempData;
}

//将data改成固定长度data
- (NSData*)dataToLengthData:(NSData*)data Length:(int)length
{
    NSMutableData *tempData = [NSMutableData data];
    unsigned long long a = 0;
    
    
    for (int i=0; i<(int)((length-data.length)/sizeof(a)); i++) {
        [tempData appendBytes:&a length:sizeof(a)];
    }
    
    [tempData appendBytes:&a length:(length-data.length)%sizeof(a)];
    [tempData appendData:data];
    return tempData;
    
    
}


//将long int改称固定长度data
- (NSData*)longIntToByte:(unsigned long long)intStr Length:(int)length
{
    NSData *testData = [NSData dataWithBytes:&intStr length:length];
    
    return testData;
    
    /*
     Don't Remove
    NSMutableData *tempData = [NSMutableData data];
    
    for (int i=0; i < length; i++) {
        [tempData appendData:[testData subdataWithRange:NSMakeRange(i, 1)]];
    }
    return tempData;
     */
}

//将返回消息解析成data
- (void)sendReturnMsg:(BHSocketChatRecMsg*)msg
{
    NSMutableData* bufferData = [[NSMutableData alloc]init];
    //组成头部
    NSData *start = [self intToByte:msg.start Length:1];
    [bufferData appendData:start];
    int length = elite_long_long+elite_long_long+elite_short+elite_char;
    msg.len = length;
    //组成长度
    NSData *len = [self intToByte:msg.len Length:2];
    [bufferData appendData:len];
  
    //组成编号
    NSData *msgNo = [self longIntToByte:msg.msg_no Length:2];
    [bufferData appendData:msgNo];
    //组成消息类型
    msg.msg_type = 8;
    NSData *msgType = [self intToByte:msg.msg_type Length:1];
    [bufferData appendData:msgType];
    //组成用户id
    NSData *custId = [self longIntToByte:[DCManager shareManager].managerInfo.custId Length:8];
    [bufferData appendData:custId];
    //消息ID
    NSData *msgId = [self longIntToByte:msg.msg_id Length:8];
    [bufferData appendData:msgId];
    
    //校验码
    NSData* checkCodeTmpData = [[NSData alloc]initWithData:[bufferData subdataWithRange:NSMakeRange(6, length-3)]];
    const char* tmpCheck = [checkCodeTmpData bytes];
    unsigned short check_code = getMsgCheckCode(tmpCheck,checkCodeTmpData.length);
    NSData* checkCodeData = [self intToByte:check_code Length:2];
    [bufferData appendData:checkCodeData];
    //终结符
    NSData *end = [self intToByte:msg.end Length:1];
    [bufferData appendData:end];
    
    NSData* msgData = [[NSData alloc]initWithData:bufferData];
    NSLog(@"sendReturnMsg is %@",msgData);
    [_bhSocket writeData:msgData withTimeout:-1 tag:0];
}


- (NSData*)parseHeartMsgToNSData:(BHSocketSendLoginMsg*)msg{

    NSMutableData* bufferData = [[NSMutableData alloc]init];
    
    //组成头部
    NSData *start = [self intToByte:msg.start Length:1];
    [bufferData appendData:start];
    int length = elite_char+elite_unsigned_int+elite_short+elite_char;
    msg.len = length;
    //组成长度
    NSData *len = [self intToByte:length Length:2];
    [bufferData appendData:len];
    //组成编号
    NSData *msgNo   = [self longIntToByte:msg.msg_no Length:2];
    [bufferData appendData:msgNo];
    //组成消息类型
    //TODO
    NSData *msgType = [self intToByte:msg.msg_type Length:1];
    [bufferData appendData:msgType];
    //组成登录来源
    NSData *type    =  [self intToByte:msg.login_type Length:1];
    [bufferData appendData:type];
    //组成用户id
    NSData *custId  = [self longIntToByte:msg.from_cust_id Length:8];
    [bufferData appendData:custId];
    //校验码
    NSData* checkCodeTmpData = [[NSData alloc]initWithData:[bufferData subdataWithRange:NSMakeRange(6, bufferData.length-6)]];
    const char* tmpCheck     = [checkCodeTmpData bytes];
    unsigned int check_code  = getMsgCheckCode(tmpCheck,checkCodeTmpData.length);
    NSData* checkCodeData    = [self intToByte:check_code Length:2];
    
    NSLog(@"parseLoginMsgToNSData__check_code:%d",check_code);
    
    [bufferData appendData:checkCodeData];
    //终结符
    NSData *end = [self intToByte:msg.end Length:1];
    [bufferData appendData:end];
    return bufferData;


}

//将登录消息解析成data
- (NSData*)parseLoginMsgToNSData:(BHSocketSendLoginMsg*)msg
{
    NSMutableData* bufferData = [[NSMutableData alloc]init];
    
    //组成头部
    NSData *start = [self intToByte:msg.start Length:1];
    [bufferData appendData:start];
    int length = elite_char+elite_unsigned_int+32+elite_short+elite_char;
    msg.len = length;
    //组成长度
    NSData *len = [self intToByte:msg.len Length:2];
    [bufferData appendData:len];
    //组成编号
    NSData *msgNo = [self longIntToByte:msg.msg_no Length:2];
    
    if (self.recTimeoutDic) {
        NSLog(@"添加前:%@",self.recTimeoutDic);
        [self.recTimeoutDic setObject:[NSNumber numberWithInt:NO] forKey:UShortToNumber(msg.msg_no)];
         NSLog(@"添加后:%@",self.recTimeoutDic);
    }
    
    [bufferData appendData:msgNo];
    //组成消息类型
    //TODO
    
    NSData *msgType = [self intToByte:msg.msg_type Length:1];
    [bufferData appendData:msgType];
    //组成登录来源
    NSData *type =   [self intToByte:msg.login_type Length:1];
    [bufferData appendData:type];
    //组成用户id
    NSData *custId = [self longIntToByte:msg.from_cust_id Length:8];
    [bufferData appendData:custId];
    //登录验证key
    NSData *loginAuth = [self dataToLengthData:[msg.login_auth dataUsingEncoding:NSUTF8StringEncoding] Length:32];
    [bufferData appendData:loginAuth];
    //校验码
    NSData* checkCodeTmpData = [[NSData alloc]initWithData:[bufferData subdataWithRange:NSMakeRange(6, bufferData.length-6)]];
    const char* tmpCheck = [checkCodeTmpData bytes];
    unsigned int check_code = getMsgCheckCode(tmpCheck,checkCodeTmpData.length);
    NSData* checkCodeData = [self intToByte:check_code Length:2];
 
    NSLog(@"parseLoginMsgToNSData__check_code:%d",check_code);
    
    [bufferData appendData:checkCodeData];
    //终结符
    NSData *end = [self intToByte:msg.end Length:1];
    [bufferData appendData:end];
    return bufferData;
}

- (int)cutDataByStart:(NSData*)data
{
    const char* cutStart = [data bytes];
    int cut = 0;
    for (int i=1; i<data.length; i++) {
        ++cut;
        if (*(++cutStart) == 2) {
            break;
        }
    }
    return cut;
}

//将发送消息解析成data
- (NSData*)parseSendMsgToNSData:(BHSocketSendChatMsg*)msg
{
    NSMutableData* bufferData = [[NSMutableData alloc]init];
    //组成头部
    //开始符号
    NSData *start = [self intToByte:msg.start Length:1];
    [bufferData appendData:start];
   
   int length = elite_char+elite_char+elite_long_long+elite_long_long+elite_long_long+elite_short+elite_char+elite_short+msg.content_len+elite_char;
    NSLog(@"length is %d,msg.content_len is %d,msg.content is %ld",length,msg.content_len,(unsigned long)msg.content.length);
    msg.len = length;
    //组成长度
    NSData *len = [self intToByte:length Length:2];
    [bufferData appendData:len];
 
    //组成编号
    NSData *msgNo = [self shortToByte:msg.msg_no Length:2];
    [bufferData appendData:msgNo];
    
    //组成消息类型
    NSData *msgType = [self intToByte:msg.msg_type Length:1];
    [bufferData appendData:msgType];
    
    //数据包类型
    NSData *chatType = [self intToByte:msg.chat_type Length:1];
    [bufferData appendData:chatType];
    
    //组成登录来源
    NSData *type = [self intToByte:msg.login_type Length:1];
    [bufferData appendData:type];

    //聊天id
    NSData *chatId = [self longIntToByte:msg.chat_id Length:8];
    [bufferData appendData:chatId];
    
    //发送者id
    NSData *fromCustId = [self longIntToByte:msg.from_cust_id Length:8];
    [bufferData appendData:fromCustId];
    //接受者id
    NSData *toCustId = [self longIntToByte:msg.to_cust_id Length:8];
    [bufferData appendData:toCustId];
    //内容长度
    NSData *contentLen = [self longIntToByte:msg.content_len Length:2];
    [bufferData appendData:contentLen];
    
    //内容数据格式 0:JSON 1:二进制格式
    NSData *contentType = [self intToByte:msg.contentType Length:1];
    [bufferData appendData:contentType];
    
    //内容
    [bufferData appendData:msg.content];
    //校验码
    NSData* checkCodeTmpData = [[NSData alloc]initWithData:[bufferData subdataWithRange:NSMakeRange(6, length-3)]];
    const char* tmpCheck = [checkCodeTmpData bytes];
    unsigned int check_code = getMsgCheckCode(tmpCheck,checkCodeTmpData.length);
    NSData* checkCodeData = [self intToByte:check_code Length:2];
    
    [bufferData appendData:checkCodeData];
    //终结符
    NSData *end = [self intToByte:msg.end Length:1];
    [bufferData appendData:end];
    return bufferData;
}

#pragma mark -----sendMethod

- (void)sendMessage:(BHSocketSendChatMsg*)msg{
    
    NSData* msgData = [[NSData alloc]initWithData:[self parseSendMsgToNSData:msg]];
    
    NSLog(@"sendMessage:::%@",msgData);
    
    if ([_bhSocket isConnected]) {
        [self performSelector:@selector(msgTimeOut:) withObject:msg afterDelay:5];
        NSLog(@"sendMessage:连接");
        [_bhSocket writeData:msgData withTimeout:-1 tag:0];
        
    }else{
        [self performSelector:@selector(msgTimeOut:) withObject:msg afterDelay:0];
         NSLog(@"sendMessage:未连接");
        [self reconnectSocket];
    }

}
- (void)sendHeartMsg{

    NSLog(@"发送心跳消息");
    
    NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
    
    if (self.connectTime) {
        if (nowTime - self.connectTime > 16*60) {
            [self socketFail];
            return;
        }
    }
    
    //拼心跳消息
    BHSocketSendLoginMsg* loginMsg = [[BHSocketSendLoginMsg alloc]init];
    loginMsg.login_type = talkAppLogin;
    loginMsg.from_cust_id = [DCManager shareManager].managerInfo.custId;
    NSLog(@"heartMsg.from_cust_id is %llu,userDataModel is %@",loginMsg.from_cust_id,[DCManager shareManager].managerInfo);
    //loginMsg.login_auth = self.connectInfo.socketAuth;
    loginMsg.start = talkStart;
    loginMsg.end   = talkEnd;
    loginMsg.msg_type = MSG_HEART;
    loginMsg.msg_no =(unsigned short)([[NSDate date] timeIntervalSince1970]*1000);
    
    if (self.recTimeoutDic) {
        NSLog(@"添加前:%@",self.recTimeoutDic);
        [self.recTimeoutDic setObject:[NSNumber numberWithInt:NO] forKey:UShortToNumber(loginMsg.msg_no)];
        NSLog(@"添加后:%@",self.recTimeoutDic);
    }
    
    loginMsg.version = talkVersion;
    NSData* msgData = [[NSData alloc]initWithData:[self parseHeartMsgToNSData:loginMsg]];
    [_bhSocket writeData:msgData withTimeout:-1 tag:0];

}

- (void)sendLoginMsg{
    
    const int endian = 1;
    if (isLittlEndbian()) {
        NSLog(@"小端");
    }else{
        NSLog(@"大端");
    }
    
   // [BHConnectManager shareConnectManager].connectState = BH_ConnectState_Loging;
    
    //拼登录消息
    BHSocketSendLoginMsg* loginMsg = [[BHSocketSendLoginMsg alloc]init];

    loginMsg.login_type   = talkAppLogin;
    loginMsg.from_cust_id = [DCManager shareManager].managerInfo.custId;
    NSLog(@"loginMsg.from_cust_id is %llu,userDataModel is %@",loginMsg.from_cust_id,[DCManager shareManager].managerInfo);
    loginMsg.login_auth   = self.connectInfo.socketAuth;
    loginMsg.start        = talkStart;
    loginMsg.end          = talkEnd;
    loginMsg.msg_type     = MSG_LOGIN;
    loginMsg.msg_no       = (unsigned short)([[NSDate date] timeIntervalSince1970]*1000);
    loginMsg.version      = talkVersion;
    
    NSData* msgData = [[NSData alloc]initWithData:[self parseLoginMsgToNSData:loginMsg]];

    [_bhSocket writeData:msgData withTimeout:-1 tag:0];
}


- (void)createSocket{

    if ([DCManager shareManager].managerInfo == nil ) {
        return;
    }
    
    [self closeSocket];
    /*
    if ( !R.canConnectTCP) {
        return;
    }
     */
    
     NSLog(@"createSocket");
    
   
    [[DCManager shareManager].uManager clear];
    
    self.socketStatus = BH_Socket_Connecting;
  //  R.recStatus       = BH_Socket_Connecting;
    
    
    NSDictionary *chatServerDic = @{@"ip":@"114.215.83.189",
                                    @"port":@"7000",
                                    @"auth":[DCManager shareManager].managerInfo.auth};
    
//    NSLog(@"Create Socket:%@",[DCManager shareManager].managerInfo.auth);
   
    BHSocketConnectInfo *info = [BHSocketConnectInfo dicToConntectInfo:chatServerDic];
     self.connectInfo = info;
    [self initSocketWithSocketInfo:info];
    
     self.recTimeoutDic = [NSMutableDictionary new];
    
 
    
}

- (void)checkTimeOut{
    
    NSLog(@"checkTimeOut");
    
    NSTimeInterval  currentTimeInterval  = [[NSDate date] timeIntervalSince1970];
    
    if ([self.recTimeoutDic count] > 1) {
        
        NSLog(@"checkTimeOut::%@",self.recTimeoutDic);
        
        NSArray *keyArr = [self.recTimeoutDic allKeys];
        
        for (int i = 0; i < [keyArr count]; i++) {
            
         NSTimeInterval timInter = [[self.recTimeoutDic objectForKey:[keyArr objectAtIndex:i]] doubleValue];
          
            if (currentTimeInterval - timInter > TimeOutSeconds) {
                
               // [[NSNotificationCenter defaultCenter] postNotificationName:k_Notification_ConnectTCP_Fail object:nil];
                [self closeSocket];
            }
            
        }
        
    }
    
    /*
    
    if ([R.sendBuffMsgDic count]>0) {
        
        NSArray *keyArr = [R.sendBuffMsgDic allKeys];
        
        for (int i = 0; i < [keyArr count]; i++) {
            
            BHSocketSendChatMsg *sendMsg = [R.sendBuffMsgDic objectForKey:[keyArr objectAtIndex:i]];
            
            if (currentTimeInterval - sendMsg.msg_time >= TimeOutSeconds) {
                [self performSelector:@selector(sendMessage:) withObject:sendMsg afterDelay:0.5];
            }
            
        }
        
    }
     */

}

- (void)initSocketWithSocketInfo:(BHSocketConnectInfo*)info{

    if ([info isValidSocketInfo]) {
        
        _bhSocket = [[AsyncSocket alloc]initWithDelegate:self];
        
        NSError *error = nil;
        
        BOOL suc = [_bhSocket connectToHost:info.socketIP onPort:info.socketPort error:&error];
        
        if (!suc) {
            
            [self socketFail];
            
        }else{
            
            [self performSelector:@selector(loginTimeOut) withObject:nil afterDelay:15];
        }
        
        
   }

}

- (void)heartMsgCtrl
{
    if (!self.heartTimer) {
        
        self.heartTimer = [NSTimer scheduledTimerWithTimeInterval:60
                                                           target:self
                                                         selector:@selector(sendHeartMsg)
                                                         userInfo:nil
                                                          repeats:YES];
        
    }
}


- (void)sendFailMsg{


    

}

- (void)socketSucc{

     self.socketStatus = BH_Socket_ConnectSucc;
    // R.recStatus       = BH_Msg_Done;
     [[DCManager shareManager].pkManager sendTimerQueryCount];
    
}

- (void)socketFail{

    self.socketStatus = BH_Socket_ConnectFail;
   // R.recStatus       = BH_Msg_Disconnect;
    [self closeSocket];
 //     [[NSNotificationCenter defaultCenter] postNotificationName:k_Notification_ConnectTCP_Fail object:nil];
   // [self reconnectSocket];

}

- (void)loginTimeOut{
/*
    if (R.recStatus == BH_Msg_Connecting) {
         R.recStatus        =  BH_Msg_Disconnect;
         self.socketStatus  =  BH_Socket_ConnectFail;
    }
 */
    
}

- (void)closeSocket
{
    
   
    NSLog(@"closeSocket");
    
    if (self.heartTimer) {
        [self.heartTimer invalidate];
         self.heartTimer = nil;
    }
    
  //  [R.sendBuffMsgDic removeAllObjects];
    
    if (_bhSocket != nil) {
       
      
         _bhSocket.delegate = nil;
        [_bhSocket disconnect];
       NSLog(@"_bhSocket:%@",_bhSocket);
    
      //   _bhSocket = nil;
    }
    
    
    
    if (_checkTimeOutTimer) {
        [_checkTimeOutTimer invalidate];
        _checkTimeOutTimer = nil;
    }
    
    if (_recTimeoutDic) {
        _recTimeoutDic = nil;
    }

    // R.recStatus = BH_Msg_Disconnect;
    // R.connectType = CONNECT_TYPE_OFFLINE;
}


- (void)reconnectSocket
{
    NSLog(@"reconnectSocket");
    
    [self closeSocket];
    [self createSocket];
}

- (void)msgTimeOut:(id)sendMsg
{
    
    
}

- (void)playMsgAudio:(NSArray*)recMsgArr{

   

}

#pragma mark ---  AsyncSocketDelegate

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port{
    NSLog(@"onsocket:%p didConnectToHost:%@ port:%hu",sock,host,port);
    
   // [BHConnectManager shareConnectManager].connectState = BH_ConnectState_ConnectSuccess;
    [self sendLoginMsg];
    [sock readDataWithTimeout:-1 tag:0];
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag{
    NSLog(@"didWriteDataWithTag");
    [sock readDataWithTimeout:-1 tag:0];
    
}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err{
    
      NSLog(@"willDisconnectWithError:%@",err);
   //  [BHConnectManager shareConnectManager].connectState = BH_ConnectState_ConnectFail;
  
   // [[NSNotificationCenter defaultCenter] postNotificationName:k_Notification_ConnectTCP_Fail object:err];
    
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    NSLog(@"onSocketDidDisconnect");
    [self closeSocket];
 //   [BHConnectManager shareConnectManager].connectState = BH_ConnectState_Disconnect;
 //   [[BHConnectManager shareConnectManager] startConnectUDPServer];

}

//socket接受消息
- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    
    self.connectTime = [[NSDate date] timeIntervalSince1970];
    
    NSLog(@"didReadData:::%@",data);
    
    if ([self.tempBufferData length]>0)
    {
         NSMutableData *muData = [[NSMutableData alloc] initWithData:self.tempBufferData];
         [muData appendData:data];
         [self handleStickOrIncomPackage:muData];
          self.tempBufferData = nil;
    }
    else{
        [self handleStickOrIncomPackage:data];
    }
    
}

#pragma mark handle ----SendMsg----

- (void)handleStickOrIncomPackage:(NSData*)readData{

    const int headerLen = 6;
    //验证长度
    if (readData.length <= 16) {
        return;
    }
    
    //验证首字节
    NSData* startData =[[NSData alloc]initWithData:[readData subdataWithRange:NSMakeRange(0, 1)]];
    int start = 0;
    numberHNMemcpy(&start, [startData bytes], 1);
    
    if (start != 2) {
        NSLog(@"msg is not start 0x02");
        int cut = [self cutDataByStart:readData];
        readData = [readData subdataWithRange:NSMakeRange(cut, readData.length-cut)];
        [self handleStickOrIncomPackage:readData];
        return;
    }
    
    
    //验证包内容的长度
    NSData* bufLen =[[NSData alloc]initWithData:[readData subdataWithRange:NSMakeRange(1, 2)]];
    unsigned int len = 0;
    numberHNMemcpy(&len, [bufLen bytes], 2);
    int maxLen = headerLen + len;
    
    if (maxLen > readData.length) {
        NSLog(@"少内容，缓存。self.tmpdata.length is %ld",(unsigned long)readData.length);
        NSData *typeData = [[NSData alloc]initWithData:[readData subdataWithRange:NSMakeRange(5, 1)]];
        int type = 0;
        numberHNMemcpy(&type, [typeData bytes], 1);
        self.tempBufferData = readData;
        return;
    }
    
    if (maxLen <= headerLen) {
        NSLog(@"msg maxLen %d is error",maxLen);
        int cut = [self cutDataByStart:readData];
        readData = [readData subdataWithRange:NSMakeRange(cut, readData.length-cut)];
        [self handleStickOrIncomPackage:readData];
        return;
    }
    
    //验证末尾字节
    NSData* endData =[[NSData alloc]initWithData:[readData subdataWithRange:NSMakeRange(headerLen-1+len, 1)]];
    int end = 0;
    numberHNMemcpy(&end, [endData bytes], 1);
    
    if (end != 3) {
        NSLog(@"msg is not end 0x03");
        int cut = [self cutDataByStart:readData];
        readData = [readData subdataWithRange:NSMakeRange(cut, readData.length-cut)];
        [self handleStickOrIncomPackage:readData];
        return;
    }
    
    //验证校验码
    NSData* checkCodeData = [[NSData alloc]initWithData:[readData subdataWithRange:NSMakeRange(headerLen, len-3)]];
    const char* tmpCheck = [checkCodeData bytes];
    
    unsigned int check_code = getMsgCheckCode(tmpCheck,len-3);
    
    NSData* checkData =[[NSData alloc]initWithData:[readData subdataWithRange:NSMakeRange(maxLen - 3, 2)]];
    unsigned short msg_check_code;
    numberHNMemcpy(&msg_check_code, [checkData bytes], 2);
    NSLog(@"msg_check_code is %u,check code is %u",msg_check_code,check_code);
    if(check_code != msg_check_code)
    {
        NSLog(@"check code is error");
        int cut = [self cutDataByStart:readData];
        readData = [readData subdataWithRange:NSMakeRange(cut, readData.length-cut)];
        [self handleStickOrIncomPackage:readData];
        return;
    }
    
    //验证消息类型
    NSData *typeData = [[NSData alloc]initWithData:[readData subdataWithRange:NSMakeRange(5, 1)]];
    int type = 0;
    numberHNMemcpy(&type, [typeData bytes], 1);
    
    BHSocketBaseMsg *msg = [[BHSocketBaseMsg alloc]init];
    msg.msg_type = type;
    msg.start = start;
    msg.end = end;
    msg.len = len;
    msg.check_code = check_code;
    
    NSData* msgNoData =[[NSData alloc]initWithData:[readData subdataWithRange:NSMakeRange(3, 2)]];
    unsigned short msg_no = 0;
    numberHNMemcpy(&msg_no, [msgNoData bytes], 2);
    [self handleValidDataWithType:type andData:readData baseMsg:msg];
    
    readData = [readData subdataWithRange:NSMakeRange(maxLen, readData.length-maxLen)];
    
   
    

    if (self.recTimeoutDic) {
        
        NSLog(@"移除前:%@",self.recTimeoutDic);
        [self.recTimeoutDic removeObjectForKey:UShortToNumber(msg_no)];
        NSLog(@"移除后:%@",self.recTimeoutDic);
    }
    
    if (readData != nil && [readData length]>0) {
        [self handleStickOrIncomPackage:readData];
    }
    
}

- (void)handleValidDataWithType:(BHSocketMsgType)msgType andData:(NSData*)data baseMsg:(BHSocketBaseMsg*)baseMsg{

   // R.recStatus = BH_Msg_Done;
    switch (msgType) {
        case BH_Socket_Type_HeartMsg:
            break;
        case BH_Socket_Type_LoginCallBack:
            [self handleLoginCallBackMsgWithBaseMsg:baseMsg andData:data];
            break;
        case BH_Socket_Type_SendMsgCallBack:
            [self handleSendMsgCallBackMsgWithBaseMsg:baseMsg andData:data];
            break;
        case BH_Socket_Type_RecChatMsg:
            [self handleRecChatMsgWithBaseMsg:baseMsg andData:data];
            break;
        case BH_Socket_Type_KicMsg:
            [self handleKickMsgWithBaseMsg:baseMsg andData:data];
            break;
        default:
            break;
    }
    
    /*
    if (msgType != BH_Socket_Type_LoginCallBack) {
        [BHConnectManager shareConnectManager].connectState = BH_ConnectState_Communicating;
    }
     */
    
    
    

}


/**
 *  各种类型处理方法
 *  @param data
 */

- (void)handleKickMsgWithBaseMsg:(BHSocketBaseMsg*)baseMsg andData:(NSData*)readData{

    NSLog(@"被踢下线");
    BHSocketLogoutMsg *msg = [[BHSocketLogoutMsg alloc]init];
    msg.msg_type           = baseMsg.msg_type;
    msg.start              = baseMsg.start;
    msg.end                = baseMsg.end;
    msg.len                = baseMsg.len;
    msg.check_code         = baseMsg.check_code;
    //解析出消息编号
    NSData* msgNoData =[[NSData alloc]initWithData:[readData subdataWithRange:NSMakeRange(3, 2)]];
    unsigned int msg_no = 0;
    numberHNMemcpy(&msg_no, [msgNoData bytes], 2);
    msg.msg_no = msg_no;
    //解析出消息来源
    NSData* loginTypeNoData =[[NSData alloc]initWithData:[readData subdataWithRange:NSMakeRange(6, 1)]];
    unsigned int login_type = 0;
    numberHNMemcpy(&login_type, [loginTypeNoData bytes], 1);
    msg.login_type = login_type;
    //解析出发送者id
    NSData* fromCustIdData =[[NSData alloc]initWithData:[readData subdataWithRange:NSMakeRange(7, 8)]];
    unsigned int from_cust_id = 0;
    numberHNMemcpy(&from_cust_id, [fromCustIdData bytes], 8);
    msg.from_cust_id = from_cust_id;
    //解析出返回状态
    NSData* statusData =[[NSData alloc]initWithData:[readData subdataWithRange:NSMakeRange(15, 2)]];
    unsigned int status_code = 0;
    numberHNMemcpy(&status_code, [statusData bytes], 2);
    msg.status_code = status_code;
    
    if (status_code == 700) {
        
        NSLog(@"被踢下线");
    
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [UIAlertView bk_showAlertViewWithTitle:@"" message:@"您已经在其他地方登录，请重新登录" cancelButtonTitle:@"确定" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
              //  [[NSNotificationCenter defaultCenter] postNotificationName:Socket_UserAction_KickLogout object:msg userInfo:nil];
                [self closeSocket];
               // [[DCManager shareManager] loginOut];
            }];
            
        });
       
    }else{
        NSLog(@"踢人失败");
    }
    
}

- (void)handleRecChatMsgWithBaseMsg:(BHSocketBaseMsg*)baseMsg andData:(NSData*)readData{
    
    NSLog(@"接受消息");
    BHSocketChatRecMsg *msg = [[BHSocketChatRecMsg alloc]init];
    msg.msg_type            = baseMsg.msg_type;
    msg.start               = baseMsg.start;
    msg.end                 = baseMsg.end;
    msg.len                 = baseMsg.len;
    msg.check_code          = baseMsg.check_code;
    //解析出消息编号
    NSData* msgNoData   = [[NSData alloc]initWithData:[readData subdataWithRange:NSMakeRange(3, 2)]];
    unsigned int msg_no = 0;
    numberHNMemcpy(&msg_no, [msgNoData bytes], 2);
    msg.msg_no = msg_no;
    //数据包类型
    NSData* chatTypeData = [[NSData alloc]initWithData:[readData subdataWithRange:NSMakeRange(6, 1)]];
    int chat_type  = 0;
    numberHNMemcpy(&chat_type, [chatTypeData bytes], 1);
    msg.chat_type  = chat_type;
    //消息时间
    //聊天id
    NSData* chatIdData =[[NSData alloc]initWithData:[readData subdataWithRange:NSMakeRange(7, 8)]];
    long long chat_id  = 0;
    numberHNMemcpy(&chat_id, [chatIdData bytes], 8);
    msg.chat_id = chat_id;
    
    //TODO:暂时不支持接受多硬件
    NSLog(@"RecMsg______chat_is is %lld local:%lld",chat_id,[[[DCManager shareManager].pManager getServerSN] longLongValue]);
 
    
    
    
    //发送者id
    NSData* fromCustIdData =[[NSData alloc]initWithData:[readData subdataWithRange:NSMakeRange(15, 8)]];
    long long from_cust_id = 0;
    numberHNMemcpy(&from_cust_id, [fromCustIdData bytes], 8);
    msg.from_cust_id = from_cust_id;
    //接收者id
    NSData* toCustIdData =[[NSData alloc]initWithData:[readData subdataWithRange:NSMakeRange(23, 8)]];
    long long to_cust_id = 0;
    numberHNMemcpy(&to_cust_id, [toCustIdData bytes], 8);
    msg.to_cust_id = to_cust_id;
    //消息id
    NSData* msgIdData = [[NSData alloc]initWithData:[readData subdataWithRange:NSMakeRange(31, 8)]];
    unsigned long long msg_id = 0;
    numberHNMemcpy(&msg_id, [msgIdData bytes], 8);
    msg.msg_id = msg_id;
    //内容长度
    NSData* contentLenData   = [[NSData alloc]initWithData:[readData subdataWithRange:NSMakeRange(39, 2)]];
    unsigned int content_len = 0;
    numberHNMemcpy(&content_len, [contentLenData bytes], 2);
    msg.content_len = content_len;
    
    NSData *contentTypeData = [[NSData alloc]initWithData:[readData subdataWithRange:NSMakeRange(41, 1)]];
    unsigned int content_type = 0;
    numberHNMemcpy(&content_type, [contentTypeData bytes], 1);
    msg.contentType = content_type;
    //内容
    NSData* contentData = [[NSData alloc]initWithData:[readData subdataWithRange:NSMakeRange(42, content_len)]];
    msg.content  = contentData;
    
    if ([[[DCManager shareManager].pManager getServerSN] longLongValue] == chat_id) {
        

        if (msg.contentType == 0) {
        //    NSLog(@"msgContent Json:%@",[msg.content objectFromJSONData]);
            
            [self handleSocketSycRequestMsgWithBaseMsg:msg];
            
        }else{
            
            RecModel *model = [RecModel new];
            model.sourceIp = @"114.215.83.189";
            model.data = msg.content;
            model.port = 7000;
            [[DCManager shareManager].uManager analyzePacketSwitchRecModel:model];
            
        }

        
    }else if(chat_id == 0){
        
        
        //要处理用户被移除的信息
        NSDictionary *dic = [msg.content objectFromJSONData];
        
        
        if (dic == nil) {
            RecModel *model = [RecModel new];
            model.sourceIp = @"114.215.83.189";
            model.data = msg.content;
            model.port = 7000;
            [[DCManager shareManager].uManager analyzePacketSwitchRecModel:model];
        }else{
        
        
            
            int type = [[dic objectForKey:@"type"] intValue];
            
            switch (type) {
                case 20:
                {
                    /*
                    if ([[[dic objectForKey:@"data"] objectForKey:@"cust_id"] longLongValue] == [DCManager shareManager].managerInfo.custId) {
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            [UIAlertView bk_showAlertViewWithTitle:@"" message:[dic objectForKey:@"content"] cancelButtonTitle:@"确定" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                [[DCManager shareManager].pManager deleteConnectWithId:[NSString stringWithFormat:@"%@",[dic objectForKey:@"chat_id"]]];
                                [[NSNotificationCenter defaultCenter] postNotificationName:k_Notification_ChangeRoomName object:nil];
                                [[NSNotificationCenter defaultCenter] postNotificationName:BH_Notification_DeviceRefrsh  object:nil];
                                
                            }];
                            
                        });
                        
                        
                    }
                     */

                }
                    break;
                case 101:
                {
                    
                    [self handleNotificationMsg:dic];
                    //控制成功
                }
                    break;
                case 102:
                {
                    //控制失败
                    [self handleNotificationMsg:dic];
                }
                    break;
                case 103:
                {
                    //定时器
                    [self handleNotificationMsg:dic];
                }
                    break;
                default:
                    break;
            }
    
        }
        
        NSLog(@"___dic___%@",dic);
        
    }else{
    
        NSLog(@"msgContent Json:%@",[msg.content objectFromJSONData]);
        NSLog(@"非当前硬件抛弃掉改指令");
    
    }

    NSLog(@" msg.content:%@", msg.content);
    
    [self sendReturnMsg:msg];
    
}


- (void)handleSendMsgCallBackMsgWithBaseMsg:(BHSocketBaseMsg*)baseMsg andData:(NSData*)readData{

    NSLog(@"发送消息状态通知");
    BHSocketRecMsgStatusMsg *msg = [[BHSocketRecMsgStatusMsg alloc]init];
    msg.msg_type                 = baseMsg.msg_type;
    msg.start                    = baseMsg.start;
    msg.end                      = baseMsg.end;
    msg.len                      = baseMsg.len;
    msg.check_code               = baseMsg.check_code;
    //解析出消息编号
    NSData* msgNoData =[[NSData alloc]initWithData:[readData subdataWithRange:NSMakeRange(3, 2)]];
    unsigned short msg_no = 0;
    numberHNMemcpy(&msg_no, [msgNoData bytes], 2);
    msg.msg_no = msg_no;
    //数据包类型
    NSData* chatTypeData = [[NSData alloc]initWithData:[readData subdataWithRange:NSMakeRange(6, 1)]];
    int chat_type        = 0;
    numberHNMemcpy(&chat_type, [chatTypeData bytes], 1);
    msg.chat_type        = chat_type;
    //登录来源
    NSData* loginTypeData =[[NSData alloc]initWithData:[readData subdataWithRange:NSMakeRange(7, 1)]];
    int login_type = 0;
    numberHNMemcpy(&login_type, [loginTypeData bytes], 1);
    msg.login_type = login_type;
    //聊天id
    NSData* chatIdData =[[NSData alloc]initWithData:[readData subdataWithRange:NSMakeRange(8, 8)]];
    long long chat_id = 0;
    numberHNMemcpy(&chat_id, [chatIdData bytes], 8);
    msg.chat_id = chat_id;
    NSLog(@"chat_is is %lld local:%lld",chat_id,[[[DCManager shareManager].pManager getServerSN] longLongValue]);
    //发送者id
    NSData* fromCustIdData =[[NSData alloc]initWithData:[readData subdataWithRange:NSMakeRange(16, 8)]];
    long long from_cust_id = 0;
    numberHNMemcpy(&from_cust_id, [fromCustIdData bytes], 8);
    msg.from_cust_id = from_cust_id;
    //接收者id
    NSData* toCustIdData =[[NSData alloc]initWithData:[readData subdataWithRange:NSMakeRange(24, 8)]];
    long long to_cust_id = 0;
    numberHNMemcpy(&to_cust_id, [toCustIdData bytes], 8);
    msg.to_cust_id = to_cust_id;
    //返回码
    NSData* statusCodeData =[[NSData alloc]initWithData:[readData subdataWithRange:NSMakeRange(32, 2)]];
    unsigned int status_code = 0;
    numberHNMemcpy(&status_code, [statusCodeData bytes], 2);
    msg.status_code = status_code;
    //消息时间
    BHMsgInfo   *entity    = [[BHMsgInfo alloc]init];
    entity.message_no      = [NSString stringWithFormat:@"%d",msg.msg_no];
 
   // NSLog(@"移除前元素:%@",R.waitSceneFeedDic );
    
   // [R.sendBuffMsgDic removeObjectForKey:UShortToNumber(msg_no)];
    
    /*
    if (R.waitSceneFeedDic) {
        
        if ([R.waitSceneFeedDic objectForKey:UShortToNumber(msg_no)]) {
            [R.waitSceneFeedDic removeObjectForKey:UShortToNumber(msg_no)];
            if ([R.waitSceneFeedDic count] == 0) {
                R.waitSceneFeedDic = nil;
                [[NSNotificationCenter defaultCenter] postNotificationName:BH_Notification_SceneDone object:nil];
            }
        }
        
    }
     */
    
   // NSLog(@"移除元素:%@",R.waitSceneFeedDic);
 
    //200
    if (status_code == 200) {
        
        NSLog(@"发送消息成功");
      //  entity.sendStatus = Elite_MessageSendStatus_Sent;
    
    }else{
        
        NSLog(@"发送消息失败,error code is %d",status_code);
      /*
        if (status_code == 405) {
        
            if (R.sendReadTimer) {
              //  [DCManagerTool showAlert:[NSString stringWithFormat:@"i-EZ控制器%@处于离线状态",[[[DCManager shareManager].pManager getConnectionDic:chat_id] objectForKey:PLIST_KEY_NAME]]];
                R.sendReadTimer = NO;
            }
            
            [BHConnectManager shareConnectManager].connectStatus = BH_ConnectStatus_LoginFail;
            R.connectType = CONNECT_TYPE_OFFLINE;
            [BHConnectManager shareConnectManager].connectState = BH_ConnectState_IEZOffline;
            [[DCManager shareManager].pManager setConnectState:ConnectionState_Offline];
            [[NSNotificationCenter defaultCenter] postNotificationName:k_Notification_ConnectTCP_Login_Fail object:nil];
        }
        entity.sendStatus = Elite_MessageSendStatus_SendFailed;
     */
   
    }
    
}

//登录小心返回
- (void)handleLoginCallBackMsgWithBaseMsg:(BHSocketBaseMsg*)baseMsg andData:(NSData*)readData{


    NSLog(@"登录返回消息");

    BHSocketLoginStatusMsg *msg = [[BHSocketLoginStatusMsg alloc]init];
    msg.msg_type = baseMsg.msg_type;
    msg.start = baseMsg.start;
    msg.end = baseMsg.end;
    msg.len = baseMsg.len;
    msg.check_code = baseMsg.check_code;
    //解析出消息编号
    NSData* msgNoData =[[NSData alloc]initWithData:[readData subdataWithRange:NSMakeRange(3, 2)]];
    unsigned short msg_no = 0;
    numberHNMemcpy(&msg_no, [msgNoData bytes], 2);
    msg.msg_no = msg_no;
    //解析出消息来源
    NSData* loginTypeNoData =[[NSData alloc]initWithData:[readData subdataWithRange:NSMakeRange(6, 1)]];
    unsigned int login_type = 0;
    numberHNMemcpy(&login_type, [loginTypeNoData bytes], 1);
    msg.login_type = login_type;
    //解析出发送者id
    NSData* fromCustIdData =[[NSData alloc]initWithData:[readData subdataWithRange:NSMakeRange(7, 8)]];
    unsigned int from_cust_id = 0;
    numberHNMemcpy(&from_cust_id, [fromCustIdData bytes], 8);
    msg.from_cust_id = from_cust_id;
    //解析出返回状态
    NSData* statusData       = [[NSData alloc]initWithData:[readData subdataWithRange:NSMakeRange(15, 2)]];
    unsigned int status_code = 0;
    numberHNMemcpy(&status_code, [statusData bytes], 2);
    msg.status_code = status_code;
    
    
    if (status_code == 200) {
        
        if ([self.checkTimeOutTimer isValid]) {
            [self.checkTimeOutTimer invalidate];
            self.checkTimeOutTimer = nil;
        }
        
        self.checkTimeOutTimer = [NSTimer scheduledTimerWithTimeInterval:TimeOutSeconds target:self selector:@selector(checkTimeOut) userInfo:nil repeats:YES];
        /*
         [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:CONNECT_TYPE_TCP] forKey:Socket_LastConnectType];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSLog(@"登录成功");
        R.connectType = CONNECT_TYPE_TCP;
        [BHConnectManager shareConnectManager].connectState = BH_ConnectState_LogSuccess;
        */
        [self socketSucc];
        [self heartMsgCtrl];
     
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:Socket_LoginSuccess_Time];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
       // [[NSNotificationCenter defaultCenter] postNotificationName:k_Notification_ConnectTCP_Login_Success object:nil];
        
    }else{
        
        // [BHConnectManager shareConnectManager].connectState = BH_ConnectState_LogFail;
        if (status_code == 401) {
            NSLog(@"auth验证失败，请重新登录");
            [UIAlertView bk_showAlertViewWithTitle:@"" message:@"登录验证失败，请重新登录" cancelButtonTitle:@"确定" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                
              //  [[DCManager shareManager] loginOut];
                
            }];
            
         
            
        }else{
            
         //   [[NSNotificationCenter defaultCenter] postNotificationName:k_Notification_ConnectTCP_Login_Fail object:nil];
             NSLog(@"验证登录失败,error code is %d",status_code);
         
        }
    
    }
    
}

- (void)handleSocketSycRequestMsgWithBaseMsg:(BHSocketChatRecMsg*)msg{

    /*

    if (msg.msg_type == 5) {
        
       NSDictionary *msgDic  = [msg.content objectFromJSONData];
        
        
        int type = [[msgDic objectForKey:@"type"] intValue];
        
        switch (type) {
            case 20:
            {
                
                [[DCManager shareManager].pManager setCreateCustId:[[msgDic objectForKey:@"creator_cust_id"] intValue] andCreateCustName:[msgDic objectForKey:@"cust_name"]];
                
                if ([[[msgDic objectForKey:@"data"] objectForKey:@"cust_id"] longLongValue] == [DCManager shareManager].managerInfo.custId) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [UIAlertView bk_showAlertViewWithTitle:@"" message:[msgDic objectForKey:@"content"] cancelButtonTitle:@"确定" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                            [[DCManager shareManager].pManager deleteConnectWithId:[NSString stringWithFormat:@"%@",[msgDic objectForKey:@"chat_id"]]];
                            [[NSNotificationCenter defaultCenter] postNotificationName:k_Notification_ChangeRoomName object:nil];
                            [[NSNotificationCenter defaultCenter] postNotificationName:BH_Notification_DeviceRefrsh  object:nil];
                            
                        }];
                        
                    });
                    
                }
                
                
            }
                break;
            case BHNotification_Type_ControlSuccess:{
                  [self handleNotificationMsg:msgDic];
            }
                break;
            case BHNotification_Type_ControlFail:{
                [self handleNotificationMsg:msgDic];
            }
                break;
            case BHNotification_Type_RunTimer:{
                [self handleNotificationMsg:msgDic];
            }
                break;
                
            default:
                break;
        }

    }
     */

}

- (void)handleNotificationMsg:(NSDictionary*)dic{


    // [[SQLiteManager shareManager] insertMsgDicArr:[NSArray arrayWithObject:dic]];
    
    // [[NSNotificationCenter defaultCenter] postNotificationName:BH_Notification_NotficationMsgRefresh object:nil];

}


@end
