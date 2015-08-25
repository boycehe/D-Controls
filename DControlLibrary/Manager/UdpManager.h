//
//  UdpManager.h
//  D-Controls Plus
//
//  Created by Liu Tao on 12-11-17.
//  Copyright (c) 2012年 D-Haus Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AsyncUdpSocket.h"

@interface RecModel : NSObject
@property (nonatomic,strong) NSString *sourceIp;
@property (nonatomic,strong) NSData   *data;
@property (nonatomic,assign) UInt16   port;
@end

@interface UdpManager : NSObject <AsyncUdpSocketDelegate>

- (void)sendEmptyPacket:(NSData *)emptyPacket;
- (BOOL)sendBroadcasting:(NSData *)emptyPacket;
- (void)sendData;
- (void)closeConnection;
- (void)creatUDPSocket;
- (void)load;
- (void)analyzePacketSwitchRecModel:(RecModel*)model;
- (void)sendTestData:(NSData*)packet;
- (void)clear;


@end
