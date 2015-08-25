//
//  UdpManager.m
//  D-Controls Plus
//
//  Created by Liu Tao on 12-11-17.
//  Copyright (c) 2012年 D-Haus Technology Co.,Ltd. All rights reserved.
//

#import "UdpManager.h"
#import "AsyncUdpSocket.h"
#import "PacketManager.h"
#import "PlistManager.h"
#import "GlobalDef.h"
#import "QuickData.h"
#import "CtrlStateManager.h"
#import "AuthorizeManager.h"
#import "BHSocketEngine.h"
#import "IPAdress.h"
#import "DCManager.h"
#import "DCManagerTool.h"



@implementation RecModel



@end


@interface UdpManager () {
    
    BOOL     isSendingData;
    BOOL     isReceivingData;//未来应多线程
    NSTimer *retryTimer;//retry timer
    int      cnt_retry;
    
    NSTimer *replytimer;
}

@property (strong, nonatomic) AsyncUdpSocket *udpSocket;
@property (strong, nonatomic) NSArray        *packetSending;
@property (strong, nonatomic) NSMutableArray *receivingPacketArray;
@property (strong, nonatomic) NSString       *ipAddress;

@end

@implementation UdpManager

#pragma mark - getter

- (AsyncUdpSocket *)udpSocket {
    if (_udpSocket == nil) {
        _udpSocket = [[AsyncUdpSocket alloc] initWithDelegate:self];
    }
    return _udpSocket;
}



- (NSArray *)packetSending {
    if (_packetSending == nil) {
        _packetSending = [NSArray arrayWithArray:[[DCManager shareManager].pkManager getWaitingPacket]];
    }
    return _packetSending;
}

- (NSMutableArray *)receivingPacketArray {
    if (_receivingPacketArray == nil) {
        _receivingPacketArray = [NSMutableArray array];
    }
    return _receivingPacketArray;
}

- (id)init {
    self = [super init];
    if (self!=nil) {
        [self load];
        InitAddresses();
        GetIPAddresses();
        GetHWAddresses();
        self.ipAddress = [NSString stringWithFormat:@"%s", ip_names[1]];
    }
    return self;
}

#pragma mark - fun

- (void)load {
    
    @try {
        
#ifdef BH_TEST
         [self.udpSocket bindToPort:9000 error:nil];
#else
        [self.udpSocket bindToPort:[PACKET_SEND_PORT intValue] error:nil];
#endif
    }
    @catch (NSException *exception) {
        NSLog(@"bindToPort error");
    }
    @finally {
        
    }
   
    [self.udpSocket receiveWithTimeout:-1 tag:0];
    
    isSendingData = NO;
    isReceivingData = NO;
    [self resetRetryTimer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivePacket:) name:MESSAGE_RECEIVE_UDP_PACKET object:[DCManager shareManager]];
}

- (void)creatUDPSocket{

     NSError *error  = nil;
    [self closeConnection];
    _udpSocket = [[AsyncUdpSocket alloc] initWithDelegate:self];
    [self.udpSocket bindToPort:[PACKET_SEND_PORT intValue] error:nil];
    [self.udpSocket enableBroadcast:YES error:&error];
    [self.udpSocket receiveWithTimeout:-1 tag:0];

}

- (void)sendTestData:(NSData*)packet{

    NSString *xip = @"192.168.1.120";
    int  xport = 9000;
    [self.udpSocket sendData:packet toHost:xip port:xport withTimeout:-1 tag:0];


}

- (void)sendData {
    
    if (isSendingData) return;
    isSendingData = YES;
    
    if ([self.packetSending count] == 3) {
        [self sendPacket];
    }
    else {
        [self sendAllPacketsFinished];
    }
}

#pragma mark - packet

- (BOOL)sendBroadcasting:(NSData *)emptyPacket {

    NSString *xip   = @"255.255.255.255";
    NSInteger xport = [PACKET_SEND_PORT intValue];
    NSLog(@"发送%@:%zd - %@", xip, xport, [QuickData stringFromHexData:emptyPacket]);
    
    NSError *error  = nil;
    
  // [self.udpSocket bindToPort:xport error:nil];
    BOOL canBroadcast = [self.udpSocket enableBroadcast:YES error:&error];
    
   BOOL isSuccess     =  [self.udpSocket sendData:emptyPacket toHost:xip port:xport withTimeout:-1 tag:0];
    
    if (!canBroadcast || !isSuccess) {
        //TODO:
    //    [DCManagerTool showAlert:[NSString stringWithFormat:@"无法搜索，请稍后尝试(%@)",error.domain]];
       
    }

    return canBroadcast && isSuccess;
    

}

- (void)sendEmptyPacket:(NSData *)emptyPacket {
    
    NSString *xip = @"255.255.255.255";
    
    if ([[[DCManager shareManager].pManager getCSSIpAddress] length]>0){
        xip = [[DCManager shareManager].pManager getCSSIpAddress];
    }
    
    NSInteger xport = [PACKET_SEND_PORT intValue];
    NSLog(@"发送%@:%d - %@", xip, (int)xport, [QuickData stringFromHexData:emptyPacket]);
    
    [self.udpSocket enableBroadcast:YES error:nil];
    
    [self.udpSocket sendData:emptyPacket toHost:xip port:xport withTimeout:-1 tag:0];
    
}

- (void)sendPacket {
    
    NSLog(@"sendPacket");
    

    if ([self.packetSending count] == 3) {
        
       NSData   *xdata = [self.packetSending objectAtIndex:1];
       NSString *xip = @"255.255.255.255";

        if ([[[DCManager shareManager].pManager getCSSIpAddress] length]>0) {
            xip = [[DCManager shareManager].pManager getCSSIpAddress];
        }
        
        NSInteger xport = [PACKET_SEND_PORT intValue];
        
         NSLog(@"发送______");
        
        if (xip.length != 0) {
         
            NSLog(@"发送______%@:%d - %@", xip, (int)xport, [QuickData stringFromHexData:xdata]);
         
            BOOL isSucc =  [self.udpSocket sendData:xdata toHost:xip port:xport withTimeout:-1 tag:0];
         
            if (isSucc) {
                NSLog(@"send success");
            }else{
                NSLog(@"send fail");
            }
           
            [retryTimer invalidate];
             retryTimer = nil;
             retryTimer = [NSTimer scheduledTimerWithTimeInterval:[PACKET_RESEND_INTERVAL doubleValue] target:self selector:@selector(resendPacket) userInfo:nil repeats:NO];
            NSLog(@"begin send timer");
            
          
        }
        
    }
    else {
        [self sendNextPacket];
    }
}

- (void)resendPacket {
    
    cnt_retry ++;
    
    if (cnt_retry > [PACKET_RESEND_MAX_NUM intValue]) {
        
         NSLog(@"重试%d次未收到确认，准备重新登陆", [PACKET_RESEND_MAX_NUM intValue]);
        [[DCManager shareManager].pManager clearTimer];
       // [[DCManager shareManager] dispatchMessage:MESSAGE_INTERFACE_UPDATE_TIMER_STATE_CHANGED];
        [[DCManager shareManager].aManager setLoginStatus:NO];
        [self relogin];
       // [[NSNotificationCenter defaultCenter] postNotificationName:k_Notification_ConnectUDP_Fail object:nil];
        return;
        
    }
    
    [self sendPacket];
}

- (void)sendNextPacket {
    isSendingData = NO;
    self.packetSending = nil;
    [self resetRetryTimer];
    [self sendData];
}

- (void)sendAllPacketsFinished {
    isSendingData = NO;
    self.packetSending = nil;
    [self resetRetryTimer];
}

- (void)clear{

     isSendingData      = NO;
     self.packetSending = nil;
   // [self.udpSocket close];
 //   self.udpSocket = nil;
    [self resetRetryTimer];

}

//发送回执

- (void)sendReplyPacketWithPfc:(NSTimer *)timer {
    
    //TODO::
  //  return;
    
    NSLog(@"sendReplyPacketWithPfc");
    NSMutableData *packet = [[NSMutableData alloc] init];
    
    [packet appendData:[QuickData dataHeader]];
    
    int pfc = [[[timer userInfo] objectForKey:@"pfc"] intValue];
    //NSLog(@"%d", pfc);
    //控制域，即传输方向和帧序列号
    NSInteger prm = 0;//从动站
    if (prm) {
        pfc+=128;
    }
    NSString *frameNumStr = [[NSString stringWithFormat:@"%02x",pfc] uppercaseString];
    [packet appendData:[QuickData dataFromHexString:frameNumStr]];
    
    [packet appendData:[QuickData dataFromHexString:@"00"]];//数据长度
    [packet appendData:[QuickData dataFromHexString:@"00"]];//功能码
    
    [packet appendData:[QuickData dataSumVerify:packet]];
    [packet appendData:[QuickData dataTail]];
    
    NSString *xip = [[DCManager shareManager].pManager getServerAddress];
    NSInteger xport = [PACKET_SEND_PORT intValue];
    NSLog(@"发送%@:%d - %@", xip, (int)xport, [QuickData stringFromHexData:packet]);
    [self.udpSocket sendData:packet toHost:xip port:xport withTimeout:-1 tag:0];
    
}

- (void)relogin {
    
    [self sendAllPacketsFinished];//恢复初始状态
    

}

- (BOOL)isValidData:(RecModel*)model{

    BOOL isValid = YES;
    
    NSData *inData = model.data;
    
    int min_length = 6;//数据内容为空时，最小长度是6
    int data_base  = 4;
    
    uint8_t oneByte;
    int cnt = (int)[inData length];
    if (cnt < min_length) {
        isValid = NO;
    }
    
    //检查开始标记
    [inData getBytes:(void*)&oneByte range:NSMakeRange(0, 1)];
    if (oneByte != 0x68) {
          isValid = NO;
    }
    
    //检查末尾结束标记
    [inData getBytes:(void*)&oneByte range:NSMakeRange(cnt-1, 1)];
    if (oneByte != 0x16) {
          isValid = NO;
    }
    
    //检查和校验值
    NSInteger sum = 0;
    for (int i = 0; i<cnt-2; i++) {
        uint8_t t;
        [inData getBytes:(void *)(&t) range:NSMakeRange(i, 1)];
        sum += t;
        if (sum>255) {
            sum -= 256;
        }
    }
    
    [inData getBytes:(void*)&oneByte range:NSMakeRange(cnt-2, 1)];
    
    if (oneByte != sum) {
         isValid = NO;
    }
    
    //帧序列号
    [inData getBytes:(void*)&oneByte range:NSMakeRange(1, 1)];
    int prm = oneByte & 0x80;
    prm     = prm ? 1 : 0;//启动站or从动站
    
    int pfc = oneByte & 0x7F;//帧序列号
    
    if (prm) {
        //[];//send reply
        NSMutableDictionary *timerDic = [NSMutableDictionary dictionary];
        [timerDic setObject:[NSNumber numberWithInt:pfc] forKey:@"pfc"];
        replytimer = [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(sendReplyPacketWithPfc:) userInfo:timerDic repeats:NO];
    }
    
    //数据长度
    [inData getBytes:(void*)&oneByte range:NSMakeRange(2, 1)];
    int len = oneByte;
    //检查数据长度是否正确，等于总长度减去最小长度（数据内空为空时的长度）
    if (len != (cnt - min_length) )
            isValid = NO;
    
    //功能码
    [inData getBytes:(void*)&oneByte range:NSMakeRange(3, 1)];
    int afn = oneByte;
    if (afn < 0 && afn > 15)//检查功能码是否合法
        isValid = NO;
    
    return isValid;


}

- (void)analyzePacketSwitchRecModel:(RecModel*)model{

     NSLog(@"analyzePacketSwitchRecModel");
    
    //只要收到相关的指令就认为硬件已经在线了
   // [[DCManager shareManager].pManager setConnectState:ConnectionState_Living];
    
    NSData *inData = model.data;
    int min_length = 6;//数据内容为空时，最小长度是6
    int data_base  = 4;
    
    uint8_t oneByte;
    int cnt = (int)[inData length];
    if (cnt < min_length)
        return;

    //检查开始标记
    [inData getBytes:(void*)&oneByte range:NSMakeRange(0, 1)];
    if (oneByte != 0x68) {
        return;
    }
    
    //检查末尾结束标记
    [inData getBytes:(void*)&oneByte range:NSMakeRange(cnt-1, 1)];
    if (oneByte != 0x16) {
        return;
    }
    
    //检查和校验值
    NSInteger sum = 0;
    for (int i = 0; i<cnt-2; i++) {
        uint8_t t;
        [inData getBytes:(void *)(&t) range:NSMakeRange(i, 1)];
        sum += t;
        if (sum>255) {
            sum -= 256;
        }
    }
    
    [inData getBytes:(void*)&oneByte range:NSMakeRange(cnt-2, 1)];
    
    if (oneByte != sum) {
        return;
    }
    
    //帧序列号
    [inData getBytes:(void*)&oneByte range:NSMakeRange(1, 1)];
    int prm = oneByte & 0x80;
    prm = prm ? 1 : 0;//启动站or从动站
    
    int pfc = oneByte & 0x7F;//帧序列号
    
    if (prm) {
        //[];//send reply
        NSMutableDictionary *timerDic = [NSMutableDictionary dictionary];
        [timerDic setObject:[NSNumber numberWithInt:pfc] forKey:@"pfc"];
        replytimer = [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(sendReplyPacketWithPfc:) userInfo:timerDic repeats:NO];
    }
    
    //数据长度
    [inData getBytes:(void*)&oneByte range:NSMakeRange(2, 1)];
    int len = oneByte;
    //检查数据长度是否正确，等于总长度减去最小长度（数据内空为空时的长度）
    if (len != (cnt - min_length) )
        return;
    
    //功能码
    [inData getBytes:(void*)&oneByte range:NSMakeRange(3, 1)];
    int afn = oneByte;
    if (afn < 0 && afn > 15)//检查功能码是否合法
        return;

    UDP_TYPE  type = [DCManagerTool getUdpTypeWithModel:model];
    
    switch (type) {
        case UDP_TYPE_OK:
        {
            NSLog(@"确认报文");
        
            if (prm)//若是确认报文，必是来自从动站，否则是错误
                return;
    
            [[DCManager shareManager].aManager setLoginStatus:YES];
            
            //set login status yes
            NSString *messageName = [NSString stringWithFormat:@"Frm%d", pfc];
            //[[DCManager shareManager] dispatchMessage:messageName];
            [self sendNextPacket];
        }
            break;
        case UDP_TYPE_DENY:
        {
            NSLog(@"收到否认报文");
            
            NSMutableString *errInfo = [NSMutableString string];
            
            NSString *messageName = [NSString stringWithFormat:@"Deny%d",pfc];
            // [[DCManager shareManager] dispatchMessage:messageName];
            
            for (int i = 0; i < len; i++) {
                [inData getBytes:(void*)&oneByte range:NSMakeRange(data_base + i, 1)];
                [errInfo appendString:[NSString stringWithFormat:@"%c",(int)oneByte]];
            }
            
            if ([errInfo isEqualToString:ERR_KEY_1010]) {//定时器数量超限
                //清除无效定时器，并提示
                [[DCManager shareManager].pManager clearInvalidNewTimerWithReason:ERR_TEXT_1010];
                [self sendNextPacket];
            }
            else if ([errInfo isEqualToString:ERR_KEY_1001]) {//终端未登录
                [[DCManager shareManager].aManager resetLoginRetryTime];
                //FIXME :是否要登录
              //  if (R.connectType == CONNECT_TYPE_UDP) {
              //     [[DCManager shareManager].pkManager sendLoginData];
              // }
            }
            else if ([errInfo isEqualToString:ERR_KEY_2000]){
                
                
                [[DCManager shareManager].aManager showErrorInfo:errInfo];
                
               
            }else if ([errInfo isEqualToString:ERR_KEY_2001]){
                [[DCManager shareManager].aManager showErrorInfo:errInfo];
            
            }else{
                
                [[DCManager shareManager].aManager showErrorInfo:errInfo];
                [self relogin];
            
            }
            break;
        }
        case UDP_TYPE_FEEDBACK:
        {
            NSLog(@"AFN:6  反馈状态");
            //反馈状态
            [inData getBytes:(void*)&oneByte range:NSMakeRange(data_base, 1)];
            int addr = oneByte;//空调地址
            data_base ++;
            
            //开关模式
            [inData getBytes:(void*)&oneByte range:NSMakeRange(data_base, 1)];//数据内容中，前8个字节是地址，此处应偏移8个字节
            int mode = oneByte&0x0F;//0, 制冷；1, 送风；2, 除湿；3, 制热
            if (mode > 3) {
                return;
            }
            int onoff = oneByte>>4&0x01;//开关
            
            //风速
            [inData getBytes:(void*)&oneByte range:NSMakeRange(data_base + 1, 1)];
            int fan = oneByte&0x0F;//1, 低风; 2, 中风; 3, 高风
            if (fan > 3) {
                return;
            }
            
            //报警代码
            uint8_t warningByte;
            [inData getBytes:(void*)&warningByte range:NSMakeRange(data_base + 5, 1)];
            int warning = warningByte;
            
            //设定温度
            [inData getBytes:(void*)&oneByte range:NSMakeRange(data_base + 3, 1)];
            int temperature = oneByte;
            
            if (mode == ModeType_Heat) {
                if (warning != 0xfe) {
                if (temperature < BH_Min_Heat_Temperature || temperature > BH_Max_Temperature)
                    return;
                }
            }
            else {
                if (warning != 0xfe) {
                    if (temperature < BH_Min_Heat_Temperature || temperature > BH_Max_Temperature)
                        return;
                }
            }
           
            [[DCManager shareManager].csManager setOnOff:onoff mode:mode fan:fan temperature:temperature forAddress:addr warning:warning];
         //   [[NSNotificationCenter defaultCenter] postNotificationName:BH_Notification_AirState object:[NSNumber numberWithInt:addr]];
            
    
        }
            break;
        case UDP_TYPE_AddOrModify_TIMER:
        {
            NSLog(@"AFN:8");
            //定时器使能和编号
            [inData getBytes:(void*)&oneByte range:NSMakeRange(data_base, 1)];
            BOOL timerEnabled = (BOOL)((oneByte&0x80)>>7);
            int timerID = oneByte&0x7F;//timer id应为0－31
            data_base ++;
            [inData getBytes:(void*)&oneByte range:NSMakeRange(data_base, 1)];
            timerID = oneByte + timerID * 256;
            
            if (timerID < BH_MIN_TIMERID && timerID> BH_MAX_TIMERID) {
                return;
            }
            
            //hour, BCD
            [inData getBytes:(void*)&oneByte range:NSMakeRange(data_base + 1, 1)];
            int hour = ((oneByte&0xF0)>>4) * 10 + (oneByte&0x0F);
            
            //minute, BCD
            [inData getBytes:(void*)&oneByte range:NSMakeRange(data_base + 2, 1)];
            int minute = ((oneByte&0xF0)>>4) * 10 + (oneByte&0x0F);
            
            //week
            [inData getBytes:(void*)&oneByte range:NSMakeRange(data_base + 3, 1)];
            BOOL repeatEnabled = (BOOL)(oneByte&0x01);
            NSMutableArray *weekArray = [NSMutableArray array];
            for (int i = 1; i <= 7; i++) {
                BOOL dayEnabled = (BOOL)((oneByte>>i)&0x01);
                if (dayEnabled) {
                    [weekArray addObject:[NSNumber numberWithInt:i-1]];
                }
            }
            
            data_base += 4;
            
            //ac addresses, 8个字节
            NSMutableArray *addressArray = [NSMutableArray array];
            
            for (int i = 0; i < 8; i++) {
                [inData getBytes:(void*)&oneByte range:NSMakeRange(data_base + i, 1)];
                for (int j = 0; j < 8; j++) {
                    if ((oneByte>>j)&0x01) {
                        int addr = i * 8 + j;
                        
                        NSNumber *addNum = [NSNumber numberWithInt:addr];//[[[DCManager shareManager] pManager] getDeviceAddressWithIndex:addr];
                        if ([addNum intValue] == -1) {
                            //return;
                        }
                        else {
                            [addressArray addObject:addNum];
                        }
                    }
                }
            }
            
            addressArray = [NSMutableArray arrayWithArray:[DCManagerTool SortArray:addressArray]];
            
            data_base += 8;
            
            //开关模式
            [inData getBytes:(void*)&oneByte range:NSMakeRange(data_base , 1)];
            int mode = oneByte&0x0F;//0, 制冷；1, 送风；2, 除湿；3, 制热
            if (mode > 3) {
                return;
            }
            int onoff = oneByte>>4&0x01;//开关
            
            //风速
            [inData getBytes:(void*)&oneByte range:NSMakeRange(data_base + 1, 1)];
            int fan = oneByte&0x0F;//1, 低风; 2, 中风; 3, 高风
            if (fan > 3) {
                return;
            }
            
            //设定温度
            [inData getBytes:(void*)&oneByte range:NSMakeRange(data_base + 3, 1)];
            int temperature = oneByte;
            if (mode == 3) {
                if (temperature >= 17 && temperature <= 30) {
                }
                else {
                    return;
                }
            }
            else {
                if (temperature >= 19 && temperature <= 30) {
                }
                else {
                    return;
                }
            }
            
            data_base += 4;
            
            NSString *name;
            if (inData.length - data_base - 2 == [MAX_NAME_LENGTH intValue]) {
                NSData *nameData = [inData subdataWithRange:NSMakeRange(data_base, [MAX_NAME_LENGTH intValue])];
                NSString *nameStr = [[NSString alloc] initWithData:nameData encoding:NSUTF8StringEncoding];
                int pos = (int)nameStr.length - 1;
                while (pos >= 0 && [[nameStr substringWithRange:NSMakeRange(pos, 1)] isEqualToString:@" "]) {
                    pos --;
                }
                if (pos == -1) {
                    //空字符串，无效
                    return;
                }
                
                name = [nameStr substringToIndex:pos+1];
            }
            
            
            [[DCManager shareManager].pManager setTimerWithTimerID:timerID enabled:timerEnabled hour:hour minute:minute week:weekArray repeat:repeatEnabled addresses:addressArray onoff:onoff mode:mode fan:fan temperature:temperature name:name];
            NSLog(@"timer__Name:%@,onOff:%@",name,[NSNumber numberWithInt:onoff]);
        }
            break;
        case UDP_TYPE_DELETE_TIMER:
        {
            [inData getBytes:(void*)&oneByte range:NSMakeRange(data_base, 1)];
            int timerID = oneByte&0x7F;//timer id应为0－31
            data_base ++;
            [inData getBytes:(void*)&oneByte range:NSMakeRange(data_base, 1)];
            timerID = oneByte + timerID * 256;
            if (timerID >= 0 && timerID < 32760) {
            }
            else {
                return;
            }
            NSLog(@"DELETE %d", timerID);
            [[DCManager shareManager].pManager deleteTimerWithID:timerID];
        }
            break;
        case UDP_TYPE_RUNTIMER:
        {
            [inData getBytes:(void*)&oneByte range:NSMakeRange(data_base, 1)];
            int timerID = oneByte&0x7F;//timer id应为0－31
            data_base ++;
            [inData getBytes:(void*)&oneByte range:NSMakeRange(data_base, 1)];
            timerID = oneByte + timerID * 256;
            if (timerID >= 0 && timerID < 32760) {
            }
            else {
                return;
            }
            NSLog(@"定时器%d触发", timerID);
            [[DCManager shareManager].pManager timerTriggerWithTimerID:timerID];
 
        }
            break;
        case UDP_TYPE_AC_COUNT:
        {
            
            [inData getBytes:(void*)&oneByte range:NSMakeRange(data_base, 1)];
            int count = oneByte;
            NSLog(@"定时器数量:%d", count);
            [[DCManager shareManager].pManager timerReceiveNum:count];
        }
            break;
        case UDP_TYPE_AC_ALL_ADDRESSA:
        {
            NSLog(@"AFN::14");
            
            /*
             最多支持64台空调，空调地址包括系统地址（0~15）、内机地址（0~15），用1个字节表示空调地址(外机地址x16 + 内机地址)，iPad控制的时候通过空调编号进行控制和反馈（64bit对应）。
             */
            
            NSData *lenData =[[NSData alloc]initWithData:[inData subdataWithRange:NSMakeRange(2, 1)]];
            int len  = 0;
            numberHNMemcpy(&len, [lenData bytes], 2);
            NSData *airData     = [[NSData alloc]initWithData:[inData subdataWithRange:NSMakeRange(5, len-1)]];
            NSString *airString = @"";
            airString = [QuickData stringNoSpaceFromHexData:airData];
            
            NSMutableDictionary *dic = nil;
            
            NSMutableArray   *deviceArr = [NSMutableArray new];
            
            for (int i = 0; i < (len-1); i++) {
                
                NSData *airData =[[NSData alloc]initWithData:[inData subdataWithRange:NSMakeRange(5+i, 1)]];
                long num = 0;
                numberHNMemcpy(&num, [airData bytes], 1);
                 dic = [NSMutableDictionary dictionary];
                [dic setObject:[NSNumber numberWithLong:num] forKey:PLIST_KEY_INDOOR_ADDRESS];
                [dic setObject:[DCManagerTool generateDeviceName:num] forKey:PLIST_KEY_NAME];
                [dic setObject:[NSNumber numberWithInt:i] forKey:PLIST_KEY_INDOOR_INDEX];
                [deviceArr addObject:dic];
                
            }
            
            //TODO
          //  R.scanDeviceArray = [NSMutableArray arrayWithArray:[DCManagerTool SortDicArray:deviceArr]];
            
            
            NSLog(@"deviceArr::%@",deviceArr);
            
            //TODO:需测试
            [[DCManager shareManager].pManager addOrReplaceDeviceArr:[DCManagerTool SortDicArray:deviceArr]];
         
        }
            break;
        case UDP_TYPE_AC_SN:
        {
            NSLog(@"AFN:15");
            //终端发送广播包，查询设备序列号，无数据。本命令只支持本地局域网。
            NSData* custData =[[NSData alloc]initWithData:[inData subdataWithRange:NSMakeRange(4, 2)]];
            long long cust_id = 0;
            numberHNMemcpy(&cust_id, [custData bytes], 2);
            NSData* cssMacData =[[NSData alloc]initWithData:[inData subdataWithRange:NSMakeRange(6, 6)]];
            NSString *cssMac = 0;
            cssMac = [QuickData stringNoSpaceFromHexData:cssMacData];
            //79
            NSData *deviceIdData = [[NSData alloc]initWithData:[inData subdataWithRange:NSMakeRange(6, 8)]];
            long long cssId = 0;
            numberHNMemcpy(&cssId, [deviceIdData bytes], 8);
            NSMutableDictionary *dic = [NSMutableDictionary new];
            [dic setObject:[NSString stringWithFormat:@"%lld+%lld",cust_id,cssId] forKey:PLIST_KEY_NAME];
            [dic setObject:[NSNumber numberWithLongLong:cust_id] forKey:PLIST_KEY_CUSTID];
            [dic setObject:model.sourceIp forKey:PLIST_KEY_ADDRESS];
            [dic setObject:cssMac forKey:PLIST_KEY_INDOOR_CSSMAC];
            [dic setObject:[NSNumber numberWithLongLong:cssId] forKey:PLIST_KEY_INDOOR_SN];
            [dic setObject:[NSNumber numberWithInt:1] forKey:PLIST_KEY_STATE];
            //TODO
          //  [R.currentScanArr addObject:dic];
        }
            break;
        default:
            break;
    }
    
}

- (void)receivePacket:(NSNotification *)ntf {
    
    if (!isReceivingData) {
        isReceivingData = YES;
        if ([self.receivingPacketArray count]>0) {
            
            RecModel *model = [self.receivingPacketArray objectAtIndex:0];
            [self analyzePacketSwitchRecModel:model];
            [self.receivingPacketArray removeObjectAtIndex:0];
            isReceivingData = NO;
            //TOD
           // [[DCManager shareManager] dispatchMessage:MESSAGE_RECEIVE_UDP_PACKET];
        }
        else {
            isReceivingData = NO;
        }
    }
    
}

- (void)onUdpSocketDidClose:(AsyncUdpSocket *)sock{

    NSLog(@"onUdpSocketDidClose");
    /*
    if (R.connectType != CONNECT_TYPE_TCP) {
        R.connectType = CONNECT_TYPE_OFFLINE;
    }
     */
    
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error{
  
    /*
      NSLog(@"didNotSendDataWithTag:%@",error);
    if (R.connectType != CONNECT_TYPE_TCP) {
        R.connectType = CONNECT_TYPE_OFFLINE;
    }
     */
    
  //  [[NSNotificationCenter defaultCenter] postNotificationName:k_Notification_ConnectUDP_Fail object:nil];
    
  

}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error{

    NSLog(@"didNotReceiveDataWithTag");
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didSendDataWithTag:(long)tag {
    NSLog(@"发送成功");
}

- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port {
    
    NSLog(@"接收------%@:%d - %@", host, port, [QuickData stringFromHexData:data]);
    NSLog(@"Ip_Address::%@",self.ipAddress);

    if ([host containsString:self.ipAddress]) {
         [self.udpSocket receiveWithTimeout:-1 tag:0];
         return  YES;
    }
    
     RecModel *model = [RecModel new];
     model.sourceIp  = host;
     model.data      = data;
     model.port      = port;

    [self.receivingPacketArray addObject:model];
  //[[DCManager shareManager] dispatchMessage:MESSAGE_RECEIVE_UDP_PACKET];
    [self.udpSocket receiveWithTimeout:-1 tag:0];
    
    return YES;
}


- (void)handleData:(NSData*)recData{
    
/*
    域	说明              长度(字节)
    F0	起始字符(68H)            1
    F1 	控制域C                  1
    F2	数据长度L                1
    F3	数据域	功能码AFN        1
        数据      Data           N
    F4	校验码CS                 1
    F5	结束码(16H)              1
*/
    
    //控制域C
    NSData  *controlData = [recData subdataWithRange:NSMakeRange(1, 1)];
    short controlCode = 0;
    numberHNMemcpy(&controlCode, [controlData bytes], 1);
    
    //数据长度L
    NSData  *lenData  =[recData subdataWithRange:NSMakeRange(2, 1)];
    short len = 0;
    numberHNMemcpy(&len, [lenData bytes], 1);
    
    //数据域	功能码AFN
    NSData *AFNData = [recData subdataWithRange:NSMakeRange(3, 1)];
    short AFN = 0;
    numberHNMemcpy(&AFN, [AFNData bytes], 1);
    
    // 数据      Data
    NSData *appData = [recData subdataWithRange:NSMakeRange(4, AFN)];
    long long appDataCode = 0;
    numberHNMemcpy(&appDataCode, [appData bytes], AFN);
    
    //校验码CS                 1
    NSData *csData = [recData subdataWithRange:NSMakeRange(4+AFN, 1)];
    short  csCode = 0;
    numberHNMemcpy(&csCode, [csData bytes], 1);

}

- (void)closeConnection {
    [self.udpSocket close];
    self.udpSocket = nil;
}

- (void)resetRetryTimer {
    [retryTimer invalidate];
    retryTimer = nil;
    cnt_retry = 0;
}

@end
