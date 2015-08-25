//
//  PacketManager.h
//  D-Controls Plus
//
//  Created by Liu Tao on 12-11-16.
//  Copyright (c) 2012年 D-Haus Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AppDelegate;

@interface PacketManager : NSObject 

- (NSArray *)getWaitingPacket;

- (void)sendEmptyData;
- (void)sendQuery0EData;
- (void)sendLoginData;
- (void)sendHeartbeatData;
- (void)sendReadAcStateWithAddresses:(NSArray *)addressArray;
- (void)sendCommandsWithOnoff:(BOOL)onoff mode:(int)mode fan:(int)fan temperature:(int)temperature forAddressArray:(NSArray *)addresses;
- (void)sendDevicesData;
- (void)sendTimeSynchronizationData;

- (void)sendTimerQueryWithTimerID:(int)timerID;
- (void)sendTimerQueryAll;
- (void)sendTimerQueryCount;
//- (void)sendTimerQueryList;
- (void)sendTimerDeleteWithTimerID:(int)timerID;
- (void)sendTimerDeleteAll;
- (void)sendTimerWithDic:(NSDictionary*)dic;
- (void)sendAddTimerWithDic:(NSDictionary*)dic;
- (void)sendTimerEditWithTimerID:(int)timerID enabled:(BOOL)timerEnabled hour:(int)hour minute:(int)minute week:(NSArray *)weekArray repeat:(BOOL)repeatEnabled addresses:(NSArray *)addrArray onoff:(BOOL)onoff mode:(int)mode fan:(int)fan temperature:(int)temperature name:(NSString *)timerName;
- (void)sendTimerAddWithTimerEnabled:(BOOL)timerEnabled hour:(int)hour minute:(int)minute week:(NSArray *)weekArray repeat:(BOOL)repeatEnabled addresses:(NSArray *)addrArray onoff:(BOOL)onoff mode:(int)mode fan:(int)fan temperature:(int)temperature name:(NSString *)timerName;

//- (void)sendReplyPacketWithPfc:(int)pfc;

- (BOOL)send_OF_RequestData;

- (void)sendTestSocketTcpData:(NSData*)tcpData;

- (void)clear;

@end
