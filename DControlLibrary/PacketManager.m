//
//  PacketManager.m
//  D-Controls Plus
//
//  Created by Liu Tao on 12-11-16.
//  Copyright (c) 2012年 D-Haus Technology Co.,Ltd. All rights reserved.
//

#import "PacketManager.h"
#import "GlobalDef.h"
#import "UdpManager.h"
#import "QuickData.h"
#import "FrameNumManager.h"
#import "AuthorizeManager.h"
#import "CtrlStateManager.h"
#import "PlistManager.h"
#import "BHSocketSendChatMsg.h"
#import "BHSocketEngine.h"
#import "NSTimer+BlocksKit.h"
#import "BHSocketConnectInfo.h"
#import "DCManager.h"

@interface PacketManager ()
@property (strong, nonatomic) NSMutableArray *queueArray;
@property (strong, nonatomic) NSTimer        *heartTimer;
@end

@implementation PacketManager


- (NSMutableArray *)queueArray {
    
    if (_queueArray == nil) {
        NSLog(@"queueArray");
        _queueArray = [NSMutableArray array];
        int cnt_max = [PACKET_QUE_MAX_NUM intValue];
        for (int i=0; i<cnt_max; i++) {
            [_queueArray addObject:[NSMutableArray array]];
        }
    }
    
    NSLog(@"_queueArray:%@",_queueArray);
    
    return _queueArray;
}

- (id)init {
    self = [super init];
    if (self != nil) {
        //[self load];
    }
    return self;
}

- (void)clear {
    [self.queueArray removeAllObjects];
    self.queueArray = nil;
    if ([_heartTimer isValid]) {
        [_heartTimer invalidate];
        _heartTimer = nil;
    }
    
}

#pragma mark - fun

- (NSArray *)getWaitingPacket {//获取一个包
    NSArray *resArray = [NSArray array];
    NSInteger cnt_max = [self.queueArray count];
    for (NSInteger i = 0; i<cnt_max; i++) {
        NSMutableArray *xarr = [self.queueArray objectAtIndex:i];
        if ([xarr count]!=0) {
            resArray = [xarr objectAtIndex:0];
            [xarr removeObjectAtIndex:0];
            break;
        }
    }
    return resArray;
}

- (void)addPacketToQueueWithDataArray:(NSArray *)inArray {
    

    NSString *packetType = [inArray objectAtIndex:0];
    NSInteger xpriority;//优先级，决定了数据包被加到哪一个队列中
    if ([packetType isEqualToString:PACKET_TYPE_LOGIN]) {
        xpriority = 0;
    }
    else if ([packetType isEqualToString:PACKET_TYPE_DATA]) {
        xpriority = 1;
    }
    else if ([packetType isEqualToString:PACKET_TYPE_HEARTBEAT]) {
        xpriority = 2;
    }
    else {
        xpriority = 1;
    }
    
    if (xpriority<[self.queueArray count]) {
        
        NSMutableArray *xarr = [self.queueArray objectAtIndex:xpriority];
        [xarr addObject:inArray];
        
    }
    
    //check    
    NSMutableArray *firstArray = [self.queueArray objectAtIndex:0];//login packet array
    while ([firstArray count] > 1) {//登录包的数量应该仅有1个
        [firstArray removeObjectAtIndex:0];
    }
    
    NSMutableArray *lastArray = [self.queueArray objectAtIndex:2];//heart beat array
    while ([lastArray count] > 1) {//若心跳包的数量大于1，说明上一次的心跳还没有发出去
        [lastArray removeObjectAtIndex:0];
    }
    
    if (xpriority == 0) {//登陆报文，清空所有其他数据
        [[self.queueArray objectAtIndex:1] removeAllObjects];
        [[self.queueArray objectAtIndex:2] removeAllObjects];
    }
    

    [[DCManager shareManager].uManager sendData];
}

#pragma mark - interface for packet composer for different entrance

#pragma mark - heart beat and answer

- (void)getHeartbeatAnswer:(NSNotification *)ntf {
   // [[DCManager shareManager] dispatchMessage:MESSAGE_HEARTBEAT_RESPONSE];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)sendHeartbeatData {
    
    NSMutableData *packet = [[NSMutableData alloc] init];
    [packet appendData:[QuickData dataHeader]];
    //控制域，即传输方向和帧序列号
    NSInteger prm = 1;//启动站
    NSInteger pfc = [[DCManager shareManager].fManager getFrameNum];//帧序号
    
    NSString *messageName = [NSString stringWithFormat:@"Frm%d",(int)pfc];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getHeartbeatAnswer:) name:messageName object:nil];//注册通知，当收到返回报文时会发送通知到此处
    
    if (prm) {
        pfc+=128;
    }
    
    NSString *frameNumStr = [[NSString stringWithFormat:@"%02x",(int)pfc] uppercaseString];
    [packet appendData:[QuickData dataFromHexString:frameNumStr]];
    
    [packet appendData:[QuickData dataFromHexString:@"00"]];//数据长度
    [packet appendData:[QuickData dataFromHexString:@"03"]];//功能码
    
    [packet appendData:[QuickData dataSumVerify:packet]];
    [packet appendData:[QuickData dataTail]];
    
    NSMutableArray *xarr = [NSMutableArray array];
    [xarr addObject:PACKET_TYPE_HEARTBEAT];
    [xarr addObject:packet];
    [xarr addObject:[NSNumber numberWithInt:0]];
    
    [self addPacketToQueueWithDataArray:xarr];
}

#pragma mark - login and answer

- (void)getLoginSuc:(NSNotification *)ntf {
   
    NSLog(@"udp登录成功");
    
   // [BHConnectManager shareConnectManager].connectState = BH_ConnectState_LogSuccess;
   /*
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:CONNECT_TYPE_UDP] forKey:Socket_LastConnectType];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:k_Notification_ConnectUDP_Login_Success object:nil];
    [[DCManager shareManager].aManager saveTemporaryToAvailable];
    [[DCManager shareManager] dispatchMessage:MESSAGE_LOGIN_SUC_RESPONSE];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[DCManager shareManager].pkManager sendTimeSynchronizationDataCopy];
    */
    
    
    [_heartTimer invalidate];
    _heartTimer = nil;
    _heartTimer = [NSTimer scheduledTimerWithTimeInterval:[PACKET_HEART_BEAT_INTERVAL doubleValue] target:self selector:@selector(sendHeartbeatData) userInfo:nil repeats:YES];
    
    
   // if (R.connectType != CONNECT_TYPE_TCP) {
   //     R.connectType = CONNECT_TYPE_UDP;
   // }
  
}




- (void)sendQuery0EData{
    
    NSMutableData *packet = [[NSMutableData alloc] init];
    
    [packet appendData:[QuickData dataHeader]];

    NSLog(@"发送查询包");
    
    //控制域，即传输方向和帧序列号
    NSInteger prm = 1;//启动站
    NSInteger pfc = [[DCManager shareManager].fManager getFrameNum];//帧序号
    if (prm) {
        pfc+=128;
    }
    
    
    NSString *frameNumStr = [[NSString stringWithFormat:@"%02x",(int)pfc] uppercaseString];
    [packet appendData:[QuickData dataFromHexString:frameNumStr]];

    [packet appendData:[QuickData dataLength:1]];//数据长度
    [packet appendData:[QuickData dataFromHexString:@"0E"]];//功能码
    
    [packet appendData:[QuickData dataLength:0]];
    [packet appendData:[QuickData dataSumVerify:packet]];
    [packet appendData:[QuickData dataTail]];
    
    NSLog(@"查询包:%@",packet);
    
    NSMutableArray *xarr = [NSMutableArray array];
    [xarr addObject:PACKET_TYPE_DATA];
    [xarr addObject:packet];
    [xarr addObject:[NSNumber numberWithInt:0]];
    /*
    if (R.connectType == CONNECT_TYPE_TCP) {
        [self sendSocketTcpData:packet];
    }else if (R.connectType == CONNECT_TYPE_UDP){
        [self addPacketToQueueWithDataArray:xarr];
    }else{
        NSLog(@"离线");
    }
    */
}

- (void)sendLoginData {
    
     
    
  //  [BHConnectManager shareConnectManager].connectState = BH_ConnectState_Loging;
    
    [self clear];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
     NSMutableData *packet = [NSMutableData data];
    [packet appendData:[QuickData dataHeader]];
    
   // R.connectType = CONNECT_TYPE_OFFLINE;
    
    NSInteger prm = 1;//启动站
    NSInteger pfc = [[DCManager shareManager].fManager getFrameNum];//帧序号
    NSString *messageName = [NSString stringWithFormat:@"Frm%d",(int)pfc];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getLoginSuc:) name:messageName object:nil];
    
    if (prm) {
        pfc+=128;
    }
    NSString *frameNumStr = [[NSString stringWithFormat:@"%02x",(int)pfc] uppercaseString];
    [packet appendData:[QuickData dataFromHexString:frameNumStr]];
    //TODO
    [packet appendData:[QuickData dataFromHexString:@"08"]];//数据长度
    [packet appendData:[QuickData dataFromHexString:@"02"]];//功能码
    
    NSString *pwd = [[DCManager shareManager].pManager getServerMac];//登录操作发生时，pwd已经经过检查，必然合法
    
    NSLog(@"name:%@__send login data udp:%@",[[[DCManager shareManager].pManager getHome] objectForKey:PLIST_KEY_NAME],pwd);
  
   
    if (![LAUCHING_REAL_COMMUNICATION boolValue]) {
          pwd = @"001EC00E20D9";
    }
    
    
    if (pwd.length != [SN_LENGTH intValue]) {
          return;
    }
   
    
    for (NSInteger i=0; i<[pwd length]; i+=2) {
        NSString *xbyte = [pwd substringWithRange:NSMakeRange(i,2)];
        [packet appendData:[QuickData dataFromHexString:xbyte]];
    }
    
    [packet appendData:[QuickData dataSumVerify:packet]];
    [packet appendData:[QuickData dataTail]];
    
    NSMutableArray *xarr = [NSMutableArray array];
    [xarr addObject:PACKET_TYPE_LOGIN];
    [xarr addObject:packet];
    [xarr addObject:[NSNumber numberWithInt:0]];
    [self addPacketToQueueWithDataArray:xarr];
}

#pragma mark - else

- (BOOL)send_OF_RequestData{
    
    NSMutableData *packet = [NSMutableData data];
    
    [packet appendData:[QuickData dataHeader]];
    [packet appendData:[QuickData data_0F]];
    [packet appendData:[QuickData dataTail]];
 return   [[DCManager shareManager].uManager sendBroadcasting:packet];


}

- (void)sendEmptyData {
    
    NSMutableData *packet = [NSMutableData data];
    
    [packet appendData:[QuickData dataHeader]];
    [packet appendData:[QuickData dataTest]];
    [packet appendData:[QuickData dataTail]];
    
    [[DCManager shareManager].uManager sendEmptyPacket:packet];
}

- (void)sendReadAcStateWithAddresses:(NSArray *)addressArray {
    
    if ([addressArray count]<=0) {
        return;
    }
    
    
    NSMutableData *packet = [[NSMutableData alloc] init];
    [packet appendData:[QuickData dataHeader]];
    
    //控制域，即传输方向和帧序列号
    NSInteger prm = 1;//启动站
    NSInteger pfc = [[DCManager shareManager].fManager getFrameNum];//帧序号
    
    if (prm) {
        pfc+=128;
    }
    
    NSString *frameNumStr = [[NSString stringWithFormat:@"%02x",(int)pfc] uppercaseString];
    [packet appendData:[QuickData dataFromHexString:frameNumStr]];
    
    int cnt = (int)[addressArray count];
    
    [packet appendData:[QuickData dataLength:cnt+1]];//数据长度
    [packet appendData:[QuickData dataFromHexString:@"05"]];//功能码
    
    [packet appendData:[QuickData dataLength:cnt]];//空调数量
    
    for (int i = 0; i < cnt; i++) {
        
      [packet appendData:[QuickData dataLength:[[[DCManager shareManager].pManager getDeviceIndoorAddressWithIndex:[[addressArray objectAtIndex:i] intValue]] intValue]]];
        
    }
    
    [packet appendData:[QuickData dataSumVerify:packet]];
    [packet appendData:[QuickData dataTail]];
    
    NSMutableArray *xarr = [NSMutableArray array];
    [xarr addObject:PACKET_TYPE_DATA];
    [xarr addObject:packet];
    [xarr addObject:[NSNumber numberWithInt:0]];
    
    
   /*
    if (R.connectType == CONNECT_TYPE_TCP) {
        NSLog(@"发送tcp");
        [self sendSocketTcpData:packet];
    }else if (R.connectType == CONNECT_TYPE_UDP){
          NSLog(@"发送udp");
        [self addPacketToQueueWithDataArray:xarr];
    }else{
        NSLog(@"离线");
    }
    */
}

- (void)controlSuccess:(NSNotification*)not{
    
   // [[LoadingViewManager sharedInstance] showHUDWithText:@"控制成功！" inView:[DCManager shareManager].window duration:k_timeinterval_3Secods];
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}

- (void)controlFail:(NSNotification*)not{

   // [[LoadingViewManager sharedInstance] showHUDWithText:@"控制失败！" inView:[DCManager shareManager].window duration:k_timeinterval_3Secods];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}


- (void)sendCommandsWithOnoff:(BOOL)onoff mode:(int)mode fan:(int)fan temperature:(int)temperature forAddressArray:(NSArray *)addresses {
    
    int cnt = (int)[addresses count];
    if (cnt <= 0)
        return;
    
    NSMutableData *packet = [[NSMutableData alloc] init];
    [packet appendData:[QuickData dataHeader]];
    //控制域，即传输方向和帧序列号
    NSInteger prm = 1;//启动站
    NSInteger pfc = [[DCManager shareManager].fManager getFrameNum];//帧序号
    
    if (prm) {
        pfc+=128;
    }
    
    NSString *messageSuccessName = [NSString stringWithFormat:@"Frm%d",(int)pfc];
    NSString *messageFailName    = [NSString stringWithFormat:@"Deny%d",(int)pfc];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(controlSuccess:) name:messageSuccessName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(controlFail:) name:messageFailName object:nil];
    
    NSString *frameNumStr = [[NSString stringWithFormat:@"%02x",(int)pfc] uppercaseString];
    [packet appendData:[QuickData dataFromHexString:frameNumStr]];
    [packet appendData:[QuickData dataLength:4 + 1 + cnt]];//数据长度
    [packet appendData:[QuickData dataFromHexString:@"04"]];//功能码
    [packet appendData:[QuickData dataLength:cnt]];//空调数量
   
    for (int i = 0; i < cnt; i++) {
       [packet appendData:[QuickData dataLength:[[addresses objectAtIndex:i] intValue]]];
    }

    //开关模式
    int itemPartOne = 0, itemPartTwo = 0;
    itemPartOne = mode;
    itemPartTwo = (int)(onoff);
    int item = (itemPartOne&0x0F)|((itemPartTwo&0x0F)<<4);
    [packet appendData:[QuickData dataLength:item]];

    //风速
    item = fan&0x0F;
    [packet appendData:[QuickData dataLength:item]];
    //风向
    [packet appendData:[QuickData dataFromHexString:@"FF"]];
    //设定温度
    [packet appendData:[QuickData dataLength:temperature]];
    [packet appendData:[QuickData dataSumVerify:packet]];
    [packet appendData:[QuickData dataTail]];
    
    NSMutableArray *xarr = [NSMutableArray array];
    [xarr addObject:PACKET_TYPE_DATA];
    [xarr addObject:packet];
    [xarr addObject:[NSNumber numberWithInt:0]];
    
     NSLog(@"sendCommandsWithOnoff:%@",packet);
    
    
    /*
    if (R.connectType == CONNECT_TYPE_TCP) {
        [self sendSocketTcpData:packet];
    }else if (R.connectType == CONNECT_TYPE_UDP){
        
        if (R.waitSceneFeedDic) {
            [R.waitSceneFeedDic setObject:BoolToNumber(NO) forKey:UShortToNumber(pfc)];
        }
        
        [self addPacketToQueueWithDataArray:xarr];
    }else{
        NSLog(@"离线");
    }
     */
    

#ifdef BH_TEST
    
     __block int i = 0;
    
    [NSTimer bk_scheduledTimerWithTimeInterval:0.2 block:^(NSTimer *timer) {
       
        if (i>32) {
            [timer isValid];
            [timer invalidate];
            timer = nil;
        }
        i++;
        
        if (R.connectType == CONNECT_TYPE_TCP) {
            [self sendSocketTcpData:packet];
        }else if (R.connectType == CONNECT_TYPE_UDP){
            [self addPacketToQueueWithDataArray:xarr];
        }else{
            NSLog(@"离线");
        }
        
    } repeats:YES];
#endif
   

}

- (void)sendTestSocketTcpData:(NSData*)tcpData{
    
    
    BHSocketSendChatMsg *sendMsg = [BHSocketSendChatMsg new];
    
    sendMsg.start           = talkStart;//1位
    sendMsg.end             = talkEnd;
    sendMsg.login_type      = talkAppLogin;
    sendMsg.msg_expire_time = talkExpireTime;
    sendMsg.version         = talkVersion;
    sendMsg.msg_time        = (unsigned long long)[[NSDate date] timeIntervalSince1970];
    sendMsg.msg_no          = [[NSString stringWithFormat:@"%llu",(unsigned long long)([[NSDate date] timeIntervalSince1970]*1000)] longLongValue];
    sendMsg.msg_type        = MSG_SENDS;
    sendMsg.login_auth      = [BHSocketEngine sharedInstance].connectInfo.socketAuth;
    sendMsg.from_cust_id    = (unsigned long long)[DCManager shareManager].managerInfo.custId;
    
    //TODO
    sendMsg.chat_id     = 0;//[[[DCManager shareManager].pManager getServerSN] longLongValue];
    sendMsg.chat_type   = 1;
    sendMsg.to_cust_id  = 10260;
    sendMsg.content     = tcpData;
    sendMsg.contentType = 1;
    sendMsg.content_len = (unsigned int)tcpData.length;
    [[BHSocketEngine sharedInstance] sendMessage:sendMsg];
    
}

- (void)sendSocketTcpData:(NSData*)tcpData{
    
    
    BHSocketSendChatMsg *sendMsg = [BHSocketSendChatMsg new];
    
    sendMsg.start           = talkStart;//1位
    sendMsg.end             = talkEnd;
    sendMsg.login_type      = talkAppLogin;
    sendMsg.msg_expire_time = talkExpireTime;
    sendMsg.version         = talkVersion;
    sendMsg.msg_time        = (unsigned long long)[[NSDate date] timeIntervalSince1970];
    sendMsg.msg_no          = (unsigned short)[[NSString stringWithFormat:@"%llu",(unsigned long long)([[NSDate date] timeIntervalSince1970]*1000)] longLongValue];
    /*
    if (R.waitSceneFeedDic) {
        [R.waitSceneFeedDic setObject:BoolToNumber(NO) forKey:UShortToNumber(sendMsg.msg_no)];
    }
     */
    
  //  NSLog(@"添加元素:%@",R.waitSceneFeedDic);
    
    sendMsg.msg_type        = MSG_SENDS;
    sendMsg.login_auth      = [BHSocketEngine sharedInstance].connectInfo.socketAuth;
    sendMsg.from_cust_id    = (unsigned long long)[DCManager shareManager].managerInfo.custId;
    //TODO
    sendMsg.chat_id         = [[[DCManager shareManager].pManager getServerSN] longLongValue];
    sendMsg.chat_type       = 2;
    sendMsg.to_cust_id      = 0;
    sendMsg.content         = tcpData;
    sendMsg.contentType     = 1;
    sendMsg.content_len     = (unsigned int)tcpData.length;
    
   // [R.sendBuffMsgDic setObject:sendMsg forKey:UShortToNumber(sendMsg.msg_no)];
    [[BHSocketEngine sharedInstance] sendMessage:sendMsg];

}

- (void)sendDevicesData {
    
    NSMutableData *packet = [[NSMutableData alloc] init];
    
    [packet appendData:[QuickData dataHeader]];
    
    //控制域，即传输方向和帧序列号
    NSInteger prm = 1;//启动站
    NSInteger pfc = [[DCManager shareManager].fManager getFrameNum];//帧序号
    if (prm) {
        pfc+=128;
    }
    NSString *frameNumStr = [[NSString stringWithFormat:@"%02x",(int)pfc] uppercaseString];
    [packet appendData:[QuickData dataFromHexString:frameNumStr]];
    
    int cnt = [[DCManager shareManager].pManager getDeviceCount];
    
    [packet appendData:[QuickData dataLength:cnt + 1]];//数据长度
    [packet appendData:[QuickData dataFromHexString:@"0C"]];//功能码
    
    [packet appendData:[QuickData dataLength:cnt]];
    
    for (int i = 0; i < cnt; i++) {
        NSNumber *xaddr = [[DCManager shareManager].pManager getDeviceAddressWithIndex:i];
        [packet appendData:[QuickData dataLength:[xaddr intValue]]];
    }
    
    [packet appendData:[QuickData dataSumVerify:packet]];
    [packet appendData:[QuickData dataTail]];
    
    NSMutableArray *xarr = [NSMutableArray array];
    [xarr addObject:PACKET_TYPE_DATA];
    [xarr addObject:packet];
    [xarr addObject:[NSNumber numberWithInt:0]];
    
    /*
    if (R.connectType == CONNECT_TYPE_TCP) {
        [self sendSocketTcpData:packet];
    }else if (R.connectType == CONNECT_TYPE_UDP){
        [self addPacketToQueueWithDataArray:xarr];
    }else{
        NSLog(@"离线");
    }
    */

}

#pragma mark - time sync

- (void)getTimeSyncSuc:(NSNotification *)ntf {
    NSLog(@"时间同步成功");
   // [[DCManager shareManager] dispatchMessage:MESSAGE_TIME_SYNCHRONIZATION_SUC];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //[[DCManager shareManager].pkManager sendTimerDeleteAll];
}

- (void)sendTimeSynchronizationDataCopy {
    
    NSMutableData *packet = [NSMutableData data];
    [packet appendData:[QuickData dataHeader]];
    
    NSInteger prm = 1;//启动站
    NSInteger pfc = [[DCManager shareManager].fManager getFrameNum];//帧序号
    
    if (prm) {
        pfc+=128;
    }
    NSString *frameNumStr = [[NSString stringWithFormat:@"%02x",(int)pfc] uppercaseString];
    [packet appendData:[QuickData dataFromHexString:frameNumStr]];
    
    [packet appendData:[QuickData dataFromHexString:@"07"]];//
    [packet appendData:[QuickData dataFromHexString:@"07"]];//功能码
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit |
	NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
	NSDateComponents *comps  = [calendar components:unitFlags fromDate:[NSDate date]];

    NSLog(@"%@", [NSDate date]);
	int year = (int)[comps year];
	int month = (int)[comps month];
	int day = (int)[comps day];
	int hour = (int)[comps hour];
	int min = (int)[comps minute];
    int sec = (int)[comps second];
    int week = (int)[comps weekday];
    week --;
    week = week == 0 ? 7 : week;
    
    [packet appendData:[QuickData dataBCDFromInt:year]];
    [packet appendData:[QuickData dataBCDFromInt:month]];
    [packet appendData:[QuickData dataBCDFromInt:day]];
    [packet appendData:[QuickData dataBCDFromInt:hour]];
    [packet appendData:[QuickData dataBCDFromInt:min]];
    [packet appendData:[QuickData dataBCDFromInt:sec]];
    [packet appendData:[QuickData dataBCDFromInt:week]];
    [packet appendData:[QuickData dataSumVerify:packet]];
    [packet appendData:[QuickData dataTail]];
    
    NSMutableArray *xarr = [NSMutableArray array];
    [xarr addObject:PACKET_TYPE_DATA];
    [xarr addObject:packet];
    [xarr addObject:[NSNumber numberWithInt:0]];
    
    [self addPacketToQueueWithDataArray:xarr];

}


- (void)sendTimeSynchronizationData {
    NSMutableData *packet = [NSMutableData data];
    
    [packet appendData:[QuickData dataHeader]];
    
    NSInteger prm = 1;//启动站
    NSInteger pfc = [[DCManager shareManager].fManager getFrameNum];//帧序号
    
    NSString *messageName = [NSString stringWithFormat:@"Frm%d",(int)pfc];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getTimeSyncSuc:) name:messageName object:nil];//注册通知，当收到返回报文时会发送通知到此处
    
    if (prm) {
        pfc+=128;
    }
    NSString *frameNumStr = [[NSString stringWithFormat:@"%02x",(int)pfc] uppercaseString];
    [packet appendData:[QuickData dataFromHexString:frameNumStr]];
    
    [packet appendData:[QuickData dataFromHexString:@"07"]];//
    [packet appendData:[QuickData dataFromHexString:@"07"]];//功能码
    
    //NSDate *localeDate = [[NSDate date] dateByAddingTimeInterval: [[NSTimeZone systemTimeZone] secondsFromGMTForDate:[NSDate date]]];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSInteger unitFlags  = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit |
	NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
	NSDateComponents *comps  = [calendar components:unitFlags fromDate:[NSDate date]];

    NSLog(@"%@", [NSDate date]);
	int year  = (int)[comps year];
	int month = (int)[comps month];
	int day   = (int)[comps day];
	int hour  = (int)[comps hour];
    //NSLog(@"%d", hour);
	int min   = (int)[comps minute];
    int sec   = (int)[comps second];
    int week  = (int)[comps weekday];
    week --;
    week = week == 0 ? 7 : week;
    
    [packet appendData:[QuickData dataBCDFromInt:year]];
    [packet appendData:[QuickData dataBCDFromInt:month]];
    [packet appendData:[QuickData dataBCDFromInt:day]];
    [packet appendData:[QuickData dataBCDFromInt:hour]];
    [packet appendData:[QuickData dataBCDFromInt:min]];
    [packet appendData:[QuickData dataBCDFromInt:sec]];
    [packet appendData:[QuickData dataBCDFromInt:week]];
    
    [packet appendData:[QuickData dataSumVerify:packet]];
    [packet appendData:[QuickData dataTail]];
    
    NSMutableArray *xarr = [NSMutableArray array];
    [xarr addObject:PACKET_TYPE_DATA];
    [xarr addObject:packet];
    [xarr addObject:[NSNumber numberWithInt:0]];
    
    [self addPacketToQueueWithDataArray:xarr];
}

#pragma mark - timer

- (void)sendTimerQueryWithTimerID:(int)timerID {
    
    
    NSMutableData *packet = [[NSMutableData alloc] init];
    
    [packet appendData:[QuickData dataHeader]];
    
    //控制域，即传输方向和帧序列号
    NSInteger prm = 1;//启动站
    NSInteger pfc = [[DCManager shareManager].fManager getFrameNum];//帧序号
    if (prm) {
        pfc+=128;
    }
    NSString *frameNumStr = [[NSString stringWithFormat:@"%02x",(int)pfc] uppercaseString];
    [packet appendData:[QuickData dataFromHexString:frameNumStr]];
    
    [packet appendData:[QuickData dataFromHexString:@"02"]];//数据长度
    [packet appendData:[QuickData dataFromHexString:@"0A"]];//功能码
    
    //NSLog(@"%d", timerID);
    int shang = timerID / 256;
    int yushu = timerID % 256;
    [packet appendData:[QuickData dataLength:shang]];
    [packet appendData:[QuickData dataLength:yushu]];
    [packet appendData:[QuickData dataSumVerify:packet]];
    [packet appendData:[QuickData dataTail]];
    
    NSMutableArray *xarr = [NSMutableArray array];
    [xarr addObject:PACKET_TYPE_DATA];
    [xarr addObject:packet];
    [xarr addObject:[NSNumber numberWithInt:0]];
    
    
    /*
    if (R.connectType == CONNECT_TYPE_TCP) {
        [self sendSocketTcpData:packet];
    }else if (R.connectType == CONNECT_TYPE_UDP){
        [self addPacketToQueueWithDataArray:xarr];
    }else{
        NSLog(@"离线");
    }
     */
}

- (void)sendTimerQueryAll {
    [self sendTimerQueryWithTimerID:0xFFFF];
}


- (void)sendTimerDeleteWithTimerID:(int)timerID {    
    NSMutableData *packet = [[NSMutableData alloc] init];
    
    [packet appendData:[QuickData dataHeader]];
    
    //控制域，即传输方向和帧序列号
    NSInteger prm = 1;//启动站
    NSInteger pfc = [[DCManager shareManager].fManager getFrameNum];//帧序号
    if (prm) {
        pfc+=128;
    }
    NSString *frameNumStr = [[NSString stringWithFormat:@"%02x",(int)pfc] uppercaseString];
    [packet appendData:[QuickData dataFromHexString:frameNumStr]];
    
    [packet appendData:[QuickData dataFromHexString:@"02"]];//数据长度
    [packet appendData:[QuickData dataFromHexString:@"09"]];//功能码
    
    int shang = timerID / 256;
    int yushu = timerID % 256;
    [packet appendData:[QuickData dataLength:shang]];
    [packet appendData:[QuickData dataLength:yushu]];
    
    [packet appendData:[QuickData dataSumVerify:packet]];
    [packet appendData:[QuickData dataTail]];
    
    NSMutableArray *xarr = [NSMutableArray array];
    [xarr addObject:PACKET_TYPE_DATA];
    [xarr addObject:packet];
    [xarr addObject:[NSNumber numberWithInt:0]];
    
    /*
    if (R.connectType == CONNECT_TYPE_TCP) {
        [self sendSocketTcpData:packet];
    }else if (R.connectType == CONNECT_TYPE_UDP){
        [self addPacketToQueueWithDataArray:xarr];
    }else{
        NSLog(@"离线");
    }
    */
}

- (void)sendTimerDeleteAll {    
    [self sendTimerDeleteWithTimerID:0xFFFF];
}

- (void)sendTimerQueryCount {
    NSMutableData *packet = [[NSMutableData alloc] init];
    [packet appendData:[QuickData dataHeader]];
    
    //控制域，即传输方向和帧序列号
    NSInteger prm = 1;//启动站
    NSInteger pfc = [[DCManager shareManager].fManager getFrameNum];//帧序号
    if (prm) {
        pfc+=128;
    }
    NSString *frameNumStr = [[NSString stringWithFormat:@"%02x",(int)pfc] uppercaseString];
    [packet appendData:[QuickData dataFromHexString:frameNumStr]];
    
    [packet appendData:[QuickData dataFromHexString:@"00"]];//数据长度
    [packet appendData:[QuickData dataFromHexString:@"0D"]];//功能码    

    [packet appendData:[QuickData dataSumVerify:packet]];
    [packet appendData:[QuickData dataTail]];
    
    NSMutableArray *xarr = [NSMutableArray array];
    [xarr addObject:PACKET_TYPE_DATA];
    [xarr addObject:packet];
    [xarr addObject:[NSNumber numberWithInt:0]];
    
    /*
    if (R.connectType == CONNECT_TYPE_TCP) {
        [self sendSocketTcpData:packet];
    }else if (R.connectType == CONNECT_TYPE_UDP){
        [self addPacketToQueueWithDataArray:xarr];
    }else{
        NSLog(@"离线");
    }
     */
}

- (void)sendTimerWithDic:(NSDictionary*)dic{

    int timerId        = [[dic objectForKey:PLIST_KEY_TIMER_ID] intValue];
    BOOL timerEnabled  = [[dic objectForKey:PLIST_KEY_TIMER_ENABLED] boolValue];
    int hour           = [[dic objectForKey:PLIST_KEY_HOUR] intValue];
    int minute         = [[dic objectForKey:PLIST_KEY_MINUTE] intValue];
    NSArray *weekArray = [dic objectForKey:PLIST_KEY_WEEK];
    BOOL repeatEnabled = [[dic objectForKey:PLIST_KEY_REPEAT] boolValue];
    NSArray *addrArray = [dic objectForKey:PLIST_KEY_ADDRESS];
    BOOL onoff         = [[dic objectForKey:PLIST_AC_ENABLED] boolValue];
    int mode           = [[dic objectForKey:PLIST_AC_MODE] intValue];
    int fan            = [[dic objectForKey:PLIST_AC_FAN] intValue];
    int temperature    = [[dic objectForKey:PLIST_AC_TEMPERATURE] intValue];
    NSString *name     = [dic objectForKey:PLIST_KEY_NAME];
    
    [self sendTimerEditWithTimerID:timerId enabled:timerEnabled hour:hour minute:minute week:weekArray repeat:repeatEnabled addresses:addrArray onoff:onoff mode:mode fan:fan temperature:temperature name:name];
    
}
- (void)sendAddTimerWithDic:(NSDictionary*)dic{
    
 
    BOOL timerEnabled  = [[dic objectForKey:PLIST_KEY_TIMER_ENABLED] boolValue];
    int hour           = [[dic objectForKey:PLIST_KEY_HOUR] intValue];
    int minute         = [[dic objectForKey:PLIST_KEY_MINUTE] intValue];
    NSArray *weekArray = [dic objectForKey:PLIST_KEY_WEEK];
    BOOL repeatEnabled = [[dic objectForKey:PLIST_KEY_REPEAT] boolValue];
    NSArray *addrArray = [dic objectForKey:PLIST_KEY_ADDRESS];
    

    BOOL onoff         = [[dic objectForKey:PLIST_AC_ENABLED] boolValue];
    int mode           = [[dic objectForKey:PLIST_AC_MODE] intValue];
    int fan            = [[dic objectForKey:PLIST_AC_FAN] intValue];
    int temperature    = [[dic objectForKey:PLIST_AC_TEMPERATURE] intValue];
    NSString *name     = [dic objectForKey:PLIST_KEY_NAME];
    
    [self sendTimerAddWithTimerEnabled:timerEnabled hour:hour minute:minute week:weekArray repeat:repeatEnabled addresses:addrArray onoff:onoff mode:mode fan:fan temperature:temperature name:name];


}

- (void)sendTimerEditWithTimerID:(int)timerID enabled:(BOOL)timerEnabled hour:(int)hour minute:(int)minute week:(NSArray *)weekArray repeat:(BOOL)repeatEnabled addresses:(NSArray *)addrArray onoff:(BOOL)onoff mode:(int)mode fan:(int)fan temperature:(int)temperature name:(NSString *)timerName {

  
    
    NSMutableData *packet = [[NSMutableData alloc] init];
    
    [packet appendData:[QuickData dataHeader]];
    
    //控制域，即传输方向和帧序列号
    NSInteger prm = 1;//启动站
    NSInteger pfc = [[DCManager shareManager].fManager getFrameNum];//帧序号
    
    //取消假反馈，所有反馈均由服务器的返回数据，直接对原始数据和临时数据进行设置，原始数据的detailEnabled和name从临时数据中获取
    
    if (prm) {
        pfc+=128;
    }
    
    NSString *frameNumStr = [[NSString stringWithFormat:@"%02x",(int)pfc] uppercaseString];
    [packet appendData:[QuickData dataFromHexString:frameNumStr]];
    
    int cnt = (int)[addrArray count];
    [packet appendData:[QuickData dataLength:9 + 8 + [MAX_NAME_LENGTH intValue]]];//数据长度
    [packet appendData:[QuickData dataFromHexString:@"08"]];//功能码
    
    //定时器使能和编号
    int shang = timerID / 256;
    int yushu = timerID % 256;
    if (timerEnabled) {
        shang += 128;
    }
    [packet appendData:[QuickData dataLength:shang]];
    [packet appendData:[QuickData dataLength:yushu]];

    //[packet appendData:[QuickData dataLength:timerID]];
    
    [packet appendData:[QuickData dataBCDFromInt:hour]];//小时
    [packet appendData:[QuickData dataBCDFromInt:minute]];//分钟
    
    int week = 0;
    for (int i = 0; i < [weekArray count]; i++) {//0-6表示
        int offset = [[weekArray objectAtIndex:i] intValue];
        offset ++;
        week = week | (0x01<<offset);
    }
    if (repeatEnabled) {
        week = week | 0x01;
    }
    [packet appendData:[QuickData dataLength:week]];//星期和重复
    
    //TODO:根据场景就行修改 BOYCE
    int8_t addrPart[8] = {0};
    for (int i = 0; i < cnt; i++) {
        NSNumber *addrNum = [addrArray objectAtIndex:i];
        int pos = [addrNum intValue];//[[[DCManager shareManager] pManager] getPositionWithIndexAddress:addrNum];
        int yushu = pos % 8;
        int shang = pos / 8;
        addrPart[shang] = addrPart[shang] | (0x01<<yushu);
    }
    
    for (int i = 0; i < 8; i++) {
        [packet appendData:[QuickData dataLength:(int)addrPart[i]]];
    }
    
    //开关模式
    int itemPartOne = 0, itemPartTwo = 0;
    itemPartOne = mode;
    itemPartTwo = (int)(onoff);
    int item = (itemPartOne&0x0F)|((itemPartTwo&0x0F)<<4);
    [packet appendData:[QuickData dataLength:item]];
    
    //风速
    item = fan&0x0F;
    [packet appendData:[QuickData dataLength:item]];
    //风向
    [packet appendData:[QuickData dataFromHexString:@"FF"]];
    //设定温度
    [packet appendData:[QuickData dataLength:temperature]];
    
    NSData *nameData = [timerName dataUsingEncoding:NSUTF8StringEncoding];

    int nameLength = (int)nameData.length;

    if (nameLength > [MAX_NAME_LENGTH intValue]) {
        return;
    }
    
    [packet appendData:nameData];
    for (int i = 0; i < [MAX_NAME_LENGTH intValue] - nameLength; i++) {
        NSString *blank = @" ";
        [packet appendData:[blank dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [packet appendData:[QuickData dataSumVerify:packet]];
    [packet appendData:[QuickData dataTail]];
    
    NSMutableArray *xarr = [NSMutableArray array];
    [xarr addObject:PACKET_TYPE_DATA];
    [xarr addObject:packet];
    [xarr addObject:[NSNumber numberWithInt:0]];
    
    /*
    if (R.connectType == CONNECT_TYPE_TCP) {
        [self sendSocketTcpData:packet];
    }else if (R.connectType == CONNECT_TYPE_UDP){
        [self addPacketToQueueWithDataArray:xarr];
    }else{
        NSLog(@"离线");
    }
     */
    
}

- (void)sendTimerAddWithTimerEnabled:(BOOL)timerEnabled hour:(int)hour minute:(int)minute week:(NSArray *)weekArray repeat:(BOOL)repeatEnabled addresses:(NSArray *)addrArray onoff:(BOOL)onoff mode:(int)mode fan:(int)fan temperature:(int)temperature name:(NSString *)timerName{
    [self sendTimerEditWithTimerID:0x7FFF enabled:timerEnabled hour:hour minute:minute week:weekArray repeat:repeatEnabled addresses:addrArray onoff:onoff mode:mode fan:fan temperature:temperature name:timerName];
}

@end
