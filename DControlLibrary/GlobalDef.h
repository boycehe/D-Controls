//
//  GlobalDef.h
//  Hitachi
//
//  Created by Liu Tao on 12-12-24.
//  Copyright (c) 2012年 D-Haus Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *MAX_NAME_LENGTH;
extern NSString *SN_LENGTH;
extern NSString *MAX_TIMER_NUM;
extern NSString *MAX_SCENE_NUM;
extern NSString *SCENE_NUM_MAX_LIMITED;

#define TEXT_SETTING_HELP @"软件配置说明"
#define TEXT_USER_MANUAL  @"软件使用说明"

#define MESSAGE_TIMER_RECEIVED_ALL        @"MessageTimerReceivedAll"
#define MESSAGE_TIME_SYNCHRONIZATION_SUC  @"MessageTimeSyncSuc"
#define MESSAGE_AC_OK_BUTTON_PRESSED      @"messageacokbuttonpressed"
#define MESSAGE_TIME_SAVE_BUTTON_PRESSED  @"messagetimesavebuttonpressed"
#define PROMPT_TIME_SAVING_DATA           @"正在保存..."
#define PROMPT_TIME_REFRESHING_DATA       @"正在刷新..."
#define PROMPT_SETING_SYNCHRONIZING_TIME  @"正在同步..."
#define TEXT_WARNING                      @"警告"


#define BH_Max_Temperature   30
#define BH_Min_Temperature   18
#define BH_Illegality_Num   93821
#define BH_Min_Heat_Temperature     17
#define BH_Min_Other_Temperature    19
#define BH_MAX_TIMERID   32760
#define BH_MIN_TIMERID    0
#define BH_Unknow_Temperature  -1

#define BH_NO_NUM     16
#define BH_Max_FloorNum 16
#define BH_TAP_HEIGHT 22
#define BH_MAX_HomeNum   4
#define BH_MAX_RoomNum   9
#define BH_Hor_DeviceNum 4

#define IntToNumber(a)                    [NSNumber numberWithInt:a]
#define BoolToNumber(a)                   [NSNumber numberWithBool:a]
#define CharToNumber(a)                   [NSNumber numberWithChar:a]
#define DoubleToNumber(a)                 [NSNumber numberWithDouble:a]
#define FloatToNumber(a)                  [NSNumber numberWithFloat:a]
#define IntegerToNumber(a)                [NSNumber numberWithInteger:a]
#define LongToNumber(a)                   [NSNumber numberWithLong:a]
#define LongLongToNumber(a)               [NSNumber numberWithLongLong:a]
#define ShortToNumber(a)                  [NSNumber numberWithShort:a]
#define UCharToNumber(a)                  [NSNumber numberWithUnsignedChar:a]
#define UIntToNumber(a)                   [NSNumber numberWithUnsignedInt:a]
#define UIntegerToNumber(a)               [NSNumber numberWithUnsignedInteger:a]
#define ULongToNumber(a)                  [NSNumber numberWithUnsignedLong:a]
#define ULongLongToNumber(a)              [NSNumber numberWithUnsignedLongLong:a]
#define UShortToNumber(a)                 [NSNumber numberWithUnsignedShort:a]


//variables
extern NSString *const PLAIN_TEXT_ENABLED;//是否将配置文件明文存储(调试时设为1)
extern NSString *LAUCHING_PAGE_ENABLED;//是否加载登录页面
extern NSString *LAUCHING_REAL_COMMUNICATION;//是否真正通信，如果否，则模拟登录失败或成功。如果否，登录时将使用密码1A2B3C4D5E6F7G8H
extern NSString *const FAIL_PATH_WHEN_LAUCHING;//加载时选择成功还是失败
extern NSString *const PASTERBOARD_KEY_AC_STATE;

extern NSString *const CELSIUS_DEGREE;

//keywords used in plist file
extern NSString *const PLIST_FILENAME;
extern NSString *const PLIST_AC_STATE_FILENAME;

extern NSString *const PLIST_CONNECTION;
extern NSString *const PLIST_DEVICES;
extern NSString *const PLIST_SECTIONS;
extern NSString *const PLIST_PAGES;
extern NSString *const PLIST_ELEMENTS;
extern NSString *const PLIST_SETTINGS;
extern NSString *const PLIST_SCENES;
extern NSString *const PLIST_SCENE_COMMANDS;
extern NSString *const PLIST_TIMERS;

extern NSString *const PLIST_AC_ENABLED;
extern NSString *const PLIST_AC_TEMPERATURE;
extern NSString *const PLIST_AC_MODE;
extern NSString *const PLIST_AC_FAN;
extern NSString *const PLIST_AC_RECORDING_TIME;
extern NSString *const PLIST_AC_WARNING;

extern NSString *const PLIST_KEY_NAME;
extern NSString *const PLIST_KEY_ADDRESS;
extern NSString *const PLIST_KEY_INDOOR_ADDRESS;
extern NSString *const PLIST_KEY_INDOOR_INDEX;
extern NSString *const PLIST_KEY_OUTDOOR_ADDRESS;
extern NSString *const PLIST_KEY_PORT;
extern NSString *const PLIST_KEY_SOUND_ENABLED;
extern NSString *const PLIST_KEY_PASSWORD_ENABLED;
extern NSString *const PLIST_KEY_PASSWORD_STRING;
extern NSString *const PLIST_KEY_AUTHCODE_STRING;
extern NSString *const PLIST_KEY_AUTHCODE_HISTORY;
extern NSString *const PLIST_KEY_TIMER_ENABLED;
extern NSString *const PLIST_KEY_DETAIL_ENABLED;
extern NSString *const PLIST_KEY_HOUR;
extern NSString *const PLIST_KEY_MINUTE;
extern NSString *const PLIST_KEY_WEEK;
extern NSString *const PLIST_KEY_REPEAT;
extern NSString *const PLIST_KEY_TIMER_ID;

//all text used

//button
extern NSString *const TEXT_IN_EDIT;
extern NSString *const TEXT_DONE;
extern NSString *const TEXT_CANCEL;
extern NSString *const TEXT_SAVE;
extern NSString *const TEXT_LOGIN;
extern NSString *const TEXT_RE_LOGIN;
extern NSString *const TEXT_HELP;
extern NSString *const TEXT_CLICK_TO_SET_AC_MDOE;

//info
extern NSString *const TEXT_SETTING_WRITE_FAIL;
extern NSString *const TEXT_SETTING_NAME_ADDRESS_INVALID;
extern NSString *const TEXT_SETTING_PASSWORD_WRONG;
extern NSString *const TEXT_SETTING_PASSWORD_NOT_MATCH;
extern NSString *const TEXT_NAME_ADDRESS_INVALID;
extern NSString *const TEXT_LINE;
extern NSString *const TEXT_DUAL_ADDRESS;
extern NSString *const TEXT_CUSTOM_SCENE;
extern NSString *const TEXT_SCENE_NAME_NULL;
extern NSString *const TEXT_INVALID_SN;

//user interface
extern NSString *const TEXT_MY_AC;
extern NSString *const TEXT_MY_SCENE;
extern NSString *const TEXT_MY_TIME;
extern NSString *const TEXT_MY_SETTING;
extern NSString *const TEXT_WELCOM;
extern NSString *const TEXT_INPUT_SN;
extern NSString *const TEXT_INPUT_PIN;
extern NSString *const TEXT_INDOOR_TEMPERATURE;
extern NSString *const TEXT_MODE;
extern NSString *const TEXT_FAN;
extern NSString *const TEXT_POWER;
extern NSString *const TEXT_TEMPERATURE;
extern NSString *const TEXT_SHORT_TEMP;
extern NSString *const TEXT_ON;
extern NSString *const TEXT_OFF;

extern NSString *const TEXT_TIMER_ON;
extern NSString *const TEXT_TIMER_OFF;
extern NSString *const TEXT_TIMER_REPEAT;

extern NSString *const TEXT_SETTING_ADDRESS_CONFIGURATION;
extern NSString *const TEXT_SETTING_FLOOR_AND_ROOM;
extern NSString *const TEXT_SETTING_BUTTON_SOUND;
extern NSString *const TEXT_SETTING_PASSWORD_LOCK;
extern NSString *const TEXT_SETTING_FEEDBACK;
extern NSString *const TEXT_SETTING_ABOUT;
extern NSString *const TEXT_SETTING_OPENED;
extern NSString *const TEXT_SETTING_CLOSED;
extern NSString *const TEXT_SETTING_SERVER;
extern NSString *const TEXT_SETTING_NAME;
extern NSString *const TEXT_SETTING_ENTER_NAME;
extern NSString *const TEXT_SETTING_ADDRESS;
extern NSString *const TEXT_SETTING_ENTER_ADDRESS;
extern NSString *const TEXT_SETTING_SET_PASSWORD;
extern NSString *const TEXT_SETTING_DELETE_PASSWORD;
extern NSString *const TEXT_SETTING_INPUT_PASSWORD_ONE;
extern NSString *const TEXT_SETTING_INPUT_PASSWORD_AGAIN;

extern NSString *const TEXT_INPUT_FLOOR_NAME;
extern NSString *const TEXT_INPUT_ROOM_NAME;
extern NSString *const TEXT_INPUT_SCENE_NAME;
extern NSString *const TEXT_ADD_NEW_ROOM;
extern NSString *const TEXT_ADD_NEW_FLOOR;
extern NSString *const TEXT_DELETE_CURRENT_FLOOR;
extern NSString *const TEXT_DELETE_REORDER;
extern NSString *const TEXT_CUSTOM_ROOM_NAME;
extern NSString *const TEXT_CUSTOM_FLOOR_NAME;
extern NSString *const TEXT_ADD_NEW_AC;
extern NSString *const TEXT_CUSTOM_TIMER;
extern NSString *const TEXT_SCENE_DID_INFO;
extern NSString *const TEXT_SCENE_DID_DO;

extern NSString *const TEXT_NAME_ADDRES_AC_NOT_EMPTY;
extern NSString *const TEXT_SCENE_NAME_AC_NOT_EMPTY;
extern NSString *const TEXT_INPUT_TIMER_NAME;

extern NSString *const TEXT_TIME;
extern NSString *const TEXT_AC_UNIT_UNDER_CONTROLL;
extern NSString *const TEXT_AC_STATE_SET;
extern NSString *const TEXT_REPEATE_TIME;
extern NSString *const TEXT_UP_WEEK_ONE;
extern NSString *const TEXT_UP_WEEK_TWO;
extern NSString *const TEXT_UP_WEEK_THREE;
extern NSString *const TEXT_UP_WEEK_FOUR;
extern NSString *const TEXT_UP_WEEK_FIVE;
extern NSString *const TEXT_UP_WEEK_SIX;
extern NSString *const TEXT_UP_WEEK_SEVEN;
extern NSString *const TEXT_TIMER_NAME_NOT_EMPTY;
extern NSString *const TEXT_TEST;
extern NSString *const TEXT_PROMPT_WHEN_SET_NEW_PASSWORD;
extern NSString *const TEXT_PROMPT_WHEN_AC_OK_BUTTON_PRESSED;
extern NSString *const TEXT_PROMPT_WHEN_EDIT_BUTTON_PRESSED;
extern NSString *const TEXT_PROMPT_WHEN_LGOIN_FAIL;
extern NSString *const TEXT_PROMPT_TIMER_OPERATED;
extern NSString *const TEXT_PROMPT_WHEN_FAIL_ADD_TIMER;
extern NSString *const TEXT_TIME_SYNCHRO;

extern NSString *PACKET_SEND_PORT;
extern NSString *PACKET_QUE_MAX_NUM;
extern NSString *PACKET_TYPE_DATA;
extern NSString *PACKET_TYPE_LOGIN;
extern NSString *PACKET_TYPE_HEARTBEAT;
extern NSString *PACKET_RESEND_MAX_NUM;
extern NSString *PACKET_RESEND_INTERVAL;
extern NSString *PACKET_HEART_BEAT_INTERVAL;

extern NSString *TIME_LOGIN_WAITING_MAX;
extern NSString *TIME_LOGIN_RETRY;
extern NSString *NUMBER_LOGIN_RETRY;
extern NSString *MAX_DEVICE_NUM;

extern NSString *MESSAGE_RECEIVE_UDP_PACKET;
extern NSString *MESSAGE_HEARTBEAT_RESPONSE;
extern NSString *MESSAGE_LOGIN_SUC_RESPONSE;
extern NSString *MESSAGE_INTERFACE_UPDATE_LOGIN_SUC;
extern NSString *MESSAGE_INTERFACE_UPDATE_LOGIN_FAIL;
extern NSString *MESSAGE_INTERFACE_UPDATE_LOGIN_HAPPENING;
extern NSString *MESSAGE_INTERFACE_UPDATE_ERROR_OCCURED;
extern NSString *MESSAGE_INTERFACE_UPDATE_AC_STATE_CHANGED;
extern NSString *MESSAGE_INTERFACE_UPDATE_TIMER_STATE_CHANGED;

extern NSString *ERR_KEY_DEFAULT;
extern NSString *ERR_KEY_1001;
extern NSString *ERR_KEY_1002;
extern NSString *ERR_KEY_1003;
extern NSString *ERR_KEY_1004;
extern NSString *ERR_KEY_1005;
extern NSString *ERR_KEY_1006;
extern NSString *ERR_KEY_1007;
extern NSString *ERR_KEY_1008;
extern NSString *ERR_KEY_1009;
extern NSString *ERR_KEY_1010;
extern NSString *ERR_KEY_1099;
extern NSString *ERR_KEY_2000;
extern NSString *ERR_KEY_2001;

extern NSString *ERR_TEXT_DEFAULT;
extern NSString *ERR_TEXT_1001;
extern NSString *ERR_TEXT_1002;
extern NSString *ERR_TEXT_1003;
extern NSString *ERR_TEXT_1004;
extern NSString *ERR_TEXT_1005;
extern NSString *ERR_TEXT_1006;
extern NSString *ERR_TEXT_1007;
extern NSString *ERR_TEXT_1008;
extern NSString *ERR_TEXT_1009;
extern NSString *ERR_TEXT_1010;
extern NSString *ERR_TEXT_1099;
extern NSString *ERR_TEXT_2000;
extern NSString *ERR_TEXT_2001;


//hepeilin 增加
extern NSString  *const PLIST_HOMEPATH;
extern NSString  *const PLIST_HOME_KEY;
extern NSString  *const PLIST_KEY_NAME;
extern NSString  *const PLIST_HOME_STATUS_KEY;
extern NSString  *const PLIST_ROOM_ID_KEY;
extern NSString  *const PLIST_ROOM_ELEMENTS_KEY;
extern NSString  *FLOOR_ID_DEF;
extern NSString  *ROOM_ID_DEF;
extern int        FloorBaseId;
extern int        RoomBaseId;
extern NSString  *ROOM_ID_KEY;
extern NSString  *FLOOR_ID_KEY;
extern NSString  *PLIST_HOME_INDEX;
extern NSString  *PLIST_STATUS;
extern NSString  *const PLIST_KEY_INDOOR_INTRODUCE;
extern NSString  *const PLIST_KEY_INDOOR_CSSMAC;
extern NSString  *const PLIST_KEY_INDOOR_MANUFACTURERID;
extern NSString  *const PLIST_KEY_INDOOR_FROMSCAN;
extern NSString  *const PLIST_KEY_INDOOR_SN;
extern NSString  *const PLIST_KEY_CUSTID;
extern NSString  *const PLIST_KEY_INDEX;
extern NSString  *const PLIST_KEY_STATE;

extern NSString  *const PLIST_KEY_CreatorCustId;
extern NSString  *const PLIST_KEY_CreatorCustName;
extern NSString  *const PLIST_KEY_CustTotalCount;
extern NSString  *const PLIST_KEY_MaxCustCount;
extern NSString  *const PLIST_KEY_Latitude ;
extern NSString  *const PLIST_KEY_Longitude ;
extern NSString  *const PLIST_KEY_FileName;

typedef enum {
    //制冷
    ModeType_Cold   = 0,
    ModeType_Heat   = 3,
    ModeType_Dry    = 2,
    ModeType_Fan    = 1,
    ModeType_Unknow = -1,
    
}ModeType;

typedef enum {
    
    WindType_Hight  = 3,
    WindType_Mid    = 2,
    WindType_Low    = 1,
    WindType_Unkonw = -1,
    
}WindType;

typedef enum {
    NETWORK_TYPE_NONE= 0,
    NETWORK_TYPE_2G= 1,
    NETWORK_TYPE_3G= 2,
    NETWORK_TYPE_4G= 3,
    NETWORK_TYPE_5G= 4,//  5G目前为猜测结果
    NETWORK_TYPE_WIFI= 5,
}NETWORK_TYPE;

typedef enum {
    
    UDP_TYPE_OK                = 0,
    UDP_TYPE_DENY              = 1,
    UDP_TYPE_LOGIN             = 2,
    UDP_TYPE_HEART             = 3,
    UDP_TYPE_CONTROL           = 4,
    UDP_TYPE_QUERY             = 5,
    UDP_TYPE_FEEDBACK          = 6,
    UDP_TYPE_TIMESYNC          = 7,
    UDP_TYPE_AddOrModify_TIMER = 8,
    UDP_TYPE_DELETE_TIMER      = 9,
    UDP_TYPE_QUERY_TIMER       = 10,
    UDP_TYPE_RUNTIMER          = 11,
    UDP_TYPE_AC_ADDRESS        = 12,
    UDP_TYPE_AC_COUNT          = 13,
    UDP_TYPE_AC_ALL_ADDRESSA   = 14,
    UDP_TYPE_AC_SN             = 15,
    UDP_TYPE_UNKNOWN           = 123,
    
}UDP_TYPE;



@interface GlobalDef : NSObject

+ (NSString *)modeStringWithIndex:(int)inIndex;
+ (NSString *)fanStringWithIndex:(int)inIndex;
+ (NSString *)weekStringWithIndex:(int)inIndex;
+ (NSString *)modeImageNameWithIndex:(int)inIndex;
+ (NSString *)fanImageNameWithIndex:(int)inIndex;
+ (NSString *)onoffImageNameWithState:(BOOL)inBool;
+ (NSString *)pageStateStringInSceneWithIndex:(int)index;
+ (NSString *)pageStateStringInTimerWithIndex:(int)index;

+ (NSString *)moduleNameWithIndex:(int)moduleIndex;

+ (NSDictionary *)acInitialStateDictionary;
+ (NSDictionary *)acInvalidStateDictionary;
+ (NSDictionary *)acInitialTimerDictionary;

+ (int)getModeFromCommunicationToInterface:(int)mode;
+ (int)getFanFromCommunicationToInterface:(int)fan;
+ (int)getModeFromInterfaceToCommunication:(int)mode;
+ (int)getFanFromInterfaceToCommunication:(int)fan;
+ (NSDictionary*)transferStateDic:(NSDictionary*)dic;


@end
