//
//  BHConnectManager.m
//  BHAirConditionControls
//
//  Created by heboyce on 7/12/15.
//  Copyright © 2015 boyce. All rights reserved.
//

#import "BHConnectManager.h"
#import "BHSocketEngine.h"
#import "PlistManager.h"
#import "PacketManager.h"
#import "UdpManager.h"
#import "DCManager.h"

@implementation BHConnectManager

+ (BHConnectManager*)shareConnectManager{
    
    static BHConnectManager *sharedAccountManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedAccountManagerInstance = [[self alloc] init];
    });
    return sharedAccountManagerInstance;
}

- (id)init{

    self = [super init];
    /*
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tcpConnectFail:) name:k_Notification_ConnectTCP_Fail object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tcpLoginFail:) name:k_Notification_ConnectTCP_Login_Fail object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tcpLoginSuccess:) name:k_Notification_ConnectTCP_Login_Success object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(udpConnectFail:) name:k_Notification_ConnectUDP_Fail object:nil];
  
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(udpLoginSuccess:) name:k_Notification_ConnectUDP_Login_Success object:nil];
*/
    return self;
}

- (void)dealloc{

    [[NSNotificationCenter defaultCenter] removeObserver:self];

}


- (void)tcpConnectFail:(NSNotification*)not{
    
    if (self.connectStatus != BH_ConnectStatus_LoginFail) {
       // [[LoadingViewManager sharedInstance] showHUDWithText:@"连接远程服务器失败,尝试切换至本地连接，请稍等..." inView:[DCManager shareManager].window duration:3];
    }
    
    [self startConnectUDPServer];
    
}

- (void)tcpLoginFail:(NSNotification*)not{
    
    
    
     if (self.connectStatus != BH_ConnectStatus_LoginFail) {
       //  [[LoadingViewManager sharedInstance] showHUDWithText:@"登录远程服务器失败,尝试切换至本地连接，请稍等..." inView:[DCManager shareManager].window duration:3];
     }
    
    [self startConnectUDPServer];
    
}

- (void)tcpLoginSuccess:(NSNotification*)not{
    
    if (self.connectStatus != BH_ConnectStatus_TCP_LoginSuccess) {
     //    [[LoadingViewManager sharedInstance] showHUDWithText:@"成功登录远程服务器！" inView:[DCManager shareManager].window duration:3];
    }
   
    self.connectStatus = BH_ConnectStatus_TCP_LoginSuccess;

}

- (void)udpConnectFail:(NSNotification*)not{
 
    if (self.connectStatus != BH_ConnectStatus_LoginFail) {
      //  [[LoadingViewManager sharedInstance] showHUDWithText:@"连接失败,请检查手机是否与i-EZ控制器在同一局域网内！" inView:[DCManager shareManager].window duration:3];
    }
    
    self.connectStatus = BH_ConnectStatus_LoginFail;
  //  R.connectType      = CONNECT_TYPE_OFFLINE;
    [[DCManager shareManager].pkManager clear];
    NSLog(@"将在15s后重连");
 
    [self performSelector:@selector(startConnectTCPServer) withObject:nil afterDelay:15];
  
}

- (void)udpLoginSuccess:(NSNotification*)not{
    
    if (self.connectStatus == BH_ConnectStatus_LoginFail) {
       //[[LoadingViewManager sharedInstance] showHUDWithText:@"本地i-EZ登录成功！" inView:[DCManager shareManager].window duration:3];
    }
    self.connectStatus = BH_ConnectStatus_UDP_LoginSuccess;
}

- (void)startConnect{
    
    
    self.connectState = BH_ConnectState_Disconnect;
    /*
    if ([R isWiFi]) {
        NSLog(@"WiFi环境");
    }else{
        NSLog(@"非WiFi环境");
    }

    ///只有当前家有硬件的时候才会去连接tcp 或者udp
    if([[DCManager shareManager].pManager getConnectionCount]>0 && R.connectType == CONNECT_TYPE_OFFLINE){
    
        ConnectType type = [[[NSUserDefaults standardUserDefaults] objectForKey:Socket_LastConnectType] intValue];
        ///如果上次连接的udp那么这次也要直接通过udp
        
        NSLog(@"homename:%@___startConnect__Type:%u",[[[DCManager shareManager].pManager getHome] objectForKey:PLIST_KEY_NAME],type);
        
        if (type == CONNECT_TYPE_UDP && [R isWiFi]) {
            [self startConnectUDPServer];
        }else{
              [self startConnectTCPServer];
        }
        
    }
     */
    
}

- (void)startConnectTCPServer{

    [[DCManager shareManager].pkManager clear];
    
    if([[DCManager shareManager].pManager getConnectionCount]>0){
        self.connectWay = ConnectWay_TCP;
      [[BHSocketEngine sharedInstance] createSocket];
    }
    
}

- (void)startConnectUDPServer{
    
    /*
    if([[DCManager shareManager].pManager getConnectionCount]>0 && [R isWiFi]){
        
        NSLog(@"startConnectUDPServer");
         self.connectWay = ConnectWay_UDP;
       
        [[BHSocketEngine sharedInstance] closeSocket];
       
        [[DCManager shareManager].pkManager sendLoginData];
        
    }else{
         NSLog(@"startConnectUDPServer————10");
        [self performSelector:@selector(startConnectTCPServer) withObject:nil afterDelay:10];
    }
     */

}

- (void)start{
    
    
    switch (self.connectState) {
        case BH_ConnectState_Disconnect:
        {
            [self startConnect];
        }
            break;
        case BH_ConnectState_Connecting:
        {
            //doNoting
        }
            break;
        case BH_ConnectState_ConnectSuccess:
        {
            //登录
        }
            break;
        case BH_ConnectState_ConnectFail:
        {
            [self startConnect];
        }
            break;
        case BH_ConnectState_LogSuccess:
        {
            //do Noting
        }
            break;
        case BH_ConnectState_LogFail:
        {
            [self startConnect];
        }
            break;
        case BH_ConnectState_Communicating:
        {
          //doNoting
        }
            break;
        case BH_ConnectState_Close:
        {
            
        }
            break;
        default:
            break;
    }


    
    

}

@end
