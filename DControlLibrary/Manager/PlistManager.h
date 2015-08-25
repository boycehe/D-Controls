//
//  PlistManager.h
//  Hitachi
//
//  Created by Liu Tao on 12-12-24.
//  Copyright (c) 2012年 D-Haus Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface PlistManager : NSObject



- (void)check;
- (void)load;

//楼层及房间

- (NSString*)getFloorNameWithIndex:(int)inIndex;
- (int)getRoomCountWithFloorIndex:(int)inIndex;
- (NSString *)getRoomNameAtIndex:(int)roomIndex withFloorIndex:(int)floorIndex;
- (NSDictionary *)getRoomStateForAcMenuAtIndex:(int)roomIndex withFloorIndex:(int)floorIndex;
- (NSArray *)getRoomAcArrayAtIndex:(int)roomIndex withFloorIndex:(int)floorIndex;
- (void)readStateForAllRoom;


//设置
- (NSString *)getServerAddress;
- (BOOL)getSoundEnabled;
- (NSString *)getAuthcode;
- (void)setAuthocodeString:(NSString *)authcode;


//场景
- (int)getSceneCount;
- (NSString *)getSceneNameWithIndex:(int)inIndex;
- (void)setSceneName:(NSString *)inString withIndex:(int)inIndex;

- (void)deleteSceneAtIndex:(int)inIndex;
- (void)clearTemporarySceneArray;
- (NSInteger)sendCommandWithIndex:(int)inIndex;
- (NSDictionary*)getCommandWithSceneIndex:(int)inIndex andRoomIndex:(int)roomIndex andFloorIndex:(int)floorIndex;

//定时
- (int)getTimerCount;
- (void)setTimerEnabeld:(BOOL)inBool withIndex:(int)inIndex;
- (void)setTimerDetailEnabeld:(BOOL)inBool withIndex:(int)inIndex;
- (void)setTimerStateDictionary:(NSMutableDictionary *)stateDic withIndex:(int)inIndex;

- (void)clearTimer;
- (void)deleteTimerAtIndex:(int)inIndex;
- (void)setTimerWithTimerID:(int)timerID enabled:(BOOL)timerEnabled hour:(int)hour minute:(int)minute week:(NSArray *)weekArray repeat:(BOOL)repeatEnabled addresses:(NSArray *)addrArray onoff:(BOOL)onoff mode:(int)mode fan:(int)fan temperature:(int)temperature name:(NSString *)name;
- (void)deleteTimerWithID:(int)timerID;
- (void)clearInvalidNewTimerWithReason:(NSString *)promptString;
- (void)readTimerStateAll;
- (void)timerTriggerWithTimerID:(int)timerID;
- (void)resetTimerNum;
- (void)timerReceiveNum:(int)count;

//空调地址配置
- (NSString *)getAcNameWithAddress:(NSNumber *)inNum;
- (int)getDeviceCount;
- (NSString *)getDeviceNameWithIndex:(int)inIndex;
- (int)getPositionWithIndexAddress:(NSNumber *)inNum;
- (NSNumber *)getDeviceAddressWithIndex:(int)inIndex;
- (NSNumber *)getDeviceIndoorAddressWithIndex:(int)inIndex;
- (NSMutableArray *)getDeviceArray;
- (void)setDeviceArray:(NSArray *)inArr;
- (void)logAllDeviceAddress;

//楼层及房间编辑
- (void)clearEditSection;

- (void)saveEditSection;

- (void)addNewFloor;

- (void)addNewFloorWithName:(NSString*)floorName;

- (void)deleteFloorAtIndex:(int)floorIndex;

- (void)addNewRoomForFloorWithIndex:(int)floorIndex;
- (void)addNewRoomForFloorWithIndex:(int)floorIndex andName:(NSString*)roomName;
- (NSMutableDictionary*)generateNewRoom:(int)floorIndex andDeviceIndex:(int)deviceIndex;



- (void)deleteRoomAtIndex:(int)roomIndex withFloorIndex:(int)floorIndex;


- (void)setName:(NSString *)nameStr withRoomIndex:(int)roomIndex withFloorIndex:(int)floorIndex;

- (void)setElementsArray:(NSArray *)elementArray withRoomIndex:(int)roomIndex withFloorIndex:(int)floorIndex;

- (void)playButtonSound;
- (NSArray*)getCommandArrWithSceneIndex:(int)inIndex;
#pragma mark ---hepeilin 增加


//家的设置



- (int)getDeviceStateWithIndex:(int)index;
//楼层
- (void)setAllFloor:(NSArray*)floorArr;
- (NSArray*)getAllFloor;
- (NSNumber*)getPlusRoomId;
- (NSMutableDictionary*)addNewRoomWithFloor:(int)floorIndex andDeviceIndex:(int)deviceIndex;
- (NSMutableArray*)getAllRoomWithFloorIndex:(int)floorIndex;

- (NSString*)getCSSIpAddress;
- (NSString*)getServerMac;
- (NSString*)getServerSN;

- (NSDictionary*)readRoomSettingStateWithRoomIndex:(int)roomIndex andFloorIndex:(int)floorIndex;

- (void)addNewTimerStateDic:(NSDictionary*)dic;
- (NSDictionary*)getTimerDicWithIndex:(int)index;
- (void)addNewSceneWithDic:(NSDictionary*)dic;
- (BOOL)replaceSceneWithDic:(NSDictionary*)dic withIndex:(int)index;
- (void)logShowAll;
- (void)addOrReplaceConnectionWithDic:(NSDictionary*)dic;
- (NSDictionary*)getConnectionWithIndex:(int)index;
- (NSInteger)getConnectionCount;
- (NSString*)getConnectionNameWithIndex:(int)index;
- (NSString*)getServerAddressWithIndex:(int)index;
- (int)getIndoorAddressWithIndex:(int)inIndex;
- (BOOL)setDeviceNameWithIndex:(int)inIndex andName:(NSString*)name;

- (NSDictionary*)getConnectionDic:(long long)connectionSN;

- (CLLocationCoordinate2D)getLocationWithIndex:(int)index;
- (void)setConnectionLocationWithLocation:(CLLocationCoordinate2D)location andIndex:(int)index;

- (NSDictionary*)getCurrentHome;
- (void)addHomeWithHomeName:(NSString*)homeName;
- (void)editHomeName:(NSString*)homeName;
- (NSDictionary*)getHome;
- (NSMutableArray*)getHomeArr;
- (void)switchHomeWithIndex:(int)index;
- (BOOL)setConnectionName:(NSString*)name andIndex:(int)deviceIndex;
- (BOOL)deleteteConnectionIndex:(int)deviceIndex;
-(NSString*)getConnectionSNIndex:(int)index;
-(void)removeCurrentHome;
- (void)editFloorName:(NSString*)floorName Index:(int)index;
- (long long)getCreateCustIdDeviceIndex:(int)deviceIndex;
- (void)addHomeWithDic:(NSDictionary*)dic;
- (NSDictionary*)getSceneWithSceneIndex:(int)inIndex;
- (int)getRoomWaringAtIndex:(int)roomIndex withFloorIndex:(int)floorIndex;
- (NSArray*)getAllWarningInRoomAtIndex:(int)roomIndex withFloorIndex:(int)floorIndex;
- (NSDictionary *)getRoomFirstDeviceStateForAcMenuAtIndex:(int)roomIndex withFloorIndex:(int)floorIndex ;
- (void)setCreateCustId:(int)createCustId andCreateCustName:(NSString*)custName;

- (void)addHomeWithConnection:(NSDictionary*)conDic;

- (void)addHomeWithDic:(NSDictionary*)dic MustSave:(BOOL)isSave;
- (NSDictionary*)getDeviceDic:(int)index;
- (void)addOrReplaceDeviceArr:(NSArray*)nArr;
- (int)getIndoorIndexWithIndex:(int)inIndex;
- (BOOL)hasSameNameHome:(NSString*)homeName;
- (BOOL)hasSameNameScene:(NSString *)sceneName;
- (NSString*)getServerAddress2WithIndex:(int)index;
- (void)clear;

- (void)deleteConnectWithId:(NSString*)connectId;
-(NSString*)checkNameExistInRoomOrFloor:(NSString*)name;
- (BOOL)isExistSameDeviceName:(NSString*)name;


- (NSString*)getTimerNameWithTimeId:(int)timerID;
- (NSDictionary*)getDeviceDicWithIndoorAddress:(int)indoorAddress;
- (BOOL)hasSameNameScene:(NSString *)sceneName exceptIndex:(int)exceptIndex;



@end
