//
//  BHConnectManager.h
//  BHAirConditionControls
//
//  Created by heboyce on 7/12/15.
//  Copyright © 2015 boyce. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 1.第一步连接socket
 2.连接socket失败 切换到udp
 3.连接udp失败切换 从1开始
 
 
 1.登录成功时,连接tcp，登录失败连接udp
 2.切换家的时候
 3.添加新的硬件或者切换新的硬件的时候
 这三种需要重新走这连接流程
 */

typedef enum {

    BH_ConnectStatus_TCP_LoginSuccess = 1,
    BH_ConnectStatus_LoginFail        =2,
    BH_ConnectStatus_UDP_LoginSuccess = 3,
    


}ConnectStatus;


typedef enum {
    
    BH_ConnectState_Disconnect = 0,
    BH_ConnectState_Connecting = 1,
    BH_ConnectState_ConnectSuccess = 2,
    BH_ConnectState_ConnectFail = 3,
    BH_ConnectState_Loging = 4,
    BH_ConnectState_LogSuccess = 5,
    BH_ConnectState_LogFail = 6,
    BH_ConnectState_Communicating = 7,
    BH_ConnectState_Close = 8,
    BH_ConnectState_IEZOffline = 9,
    

}ConnectState;

typedef enum {

    ConnectWay_TCP = 0,
    ConnectWay_UDP = 1,
    
}ConnectWay;




@interface BHConnectManager : NSObject

+ (BHConnectManager*)shareConnectManager;
@property (nonatomic,assign) ConnectStatus  connectStatus;


- (void)startConnect;/**< 自动判断是通过TCP 还是UDP连接*/

- (void)startConnectTCPServer;
- (void)startConnectUDPServer;

#pragma mark NewPropertyAndMethod

@property (nonatomic,assign) ConnectState   connectState;
@property (nonatomic,assign) ConnectWay         connectWay;
-(void)start;

@end
