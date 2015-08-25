//
//  GlobalDef.m
//  Hitachi
//
//  Created by Liu Tao on 12-12-24.
//  Copyright (c) 2012年 D-Haus Technology Co.,Ltd. All rights reserved.
//

#import "GlobalDef.h"

NSString *MAX_NAME_LENGTH = @"15";
NSString *SN_LENGTH = @"12";
NSString *MAX_TIMER_NUM = @"16";
NSString *MAX_SCENE_NUM = @"16";


//variables
NSString *const PLAIN_TEXT_ENABLED = @"0";
NSString *LAUCHING_PAGE_ENABLED = @"1";//如果否，不要求用户登录
NSString *LAUCHING_REAL_COMMUNICATION = @"1";//如果否，则模拟登录失败或成功。如果否，登录时将使用默认密码
NSString *const FAIL_PATH_WHEN_LAUCHING = @"0";//如果否，模拟登录时进入成功页面； 如果是，进入失败页面
NSString *const PASTERBOARD_KEY_AC_STATE = @"pasterboardacstate";

NSString *const CELSIUS_DEGREE = @"℃";

//keywords used in plist file
NSString *const PLIST_FILENAME = @"hitachi.dc";
NSString *const PLIST_AC_STATE_FILENAME = @"temp.dc";
//家配置相关
NSString *const PLIST_HOMEPATH = @"homeInfo.dc";
NSString *const PLIST_HOME_KEY  = @"home";
NSString *const PLIST_HOME_STATUS_KEY = @"status";
NSString *const PLIST_ROOM_ID_KEY    = @"roomid";
NSString *const PLIST_ROOM_ELEMENTS_KEY    = @"elements";


NSString *const PLIST_CONNECTION = @"connection";
NSString *const PLIST_DEVICES = @"devices";
NSString *const PLIST_SECTIONS = @"sections";
NSString *const PLIST_PAGES = @"pages";
NSString *const PLIST_ELEMENTS = @"elements";
NSString *const PLIST_SETTINGS = @"settings";
NSString *const PLIST_SCENES = @"scenes";
NSString *const PLIST_SCENE_COMMANDS = @"commands";
NSString *const PLIST_TIMERS = @"timers";

NSString *const PLIST_AC_ENABLED = @"onoff";
NSString *const PLIST_AC_TEMPERATURE = @"temperature";
NSString *const PLIST_AC_MODE = @"mode";
NSString *const PLIST_AC_FAN = @"fan";
NSString *const PLIST_AC_RECORDING_TIME = @"recordingtime";
NSString *const PLIST_AC_WARNING = @"warning";

NSString *const PLIST_KEY_NAME = @"name";
NSString *const PLIST_KEY_ADDRESS = @"address";
NSString *const PLIST_KEY_INDOOR_ADDRESS = @"indooraddress";
NSString *const PLIST_KEY_INDOOR_INDEX = @"indoorindex";
NSString *const PLIST_KEY_OUTDOOR_ADDRESS = @"outdooraddress";
NSString *const PLIST_KEY_PORT = @"port";
NSString *const PLIST_KEY_SOUND_ENABLED = @"sound";
NSString *const PLIST_KEY_PASSWORD_ENABLED = @"password";
NSString *const PLIST_KEY_PASSWORD_STRING = @"pwstring";
NSString *const PLIST_KEY_AUTHCODE_STRING = @"authcode";
NSString *const PLIST_KEY_AUTHCODE_HISTORY = @"authcodehistory";
NSString *const PLIST_KEY_TIMER_ENABLED = @"timerenabled";
NSString *const PLIST_KEY_DETAIL_ENABLED = @"detailenabled";
NSString *const PLIST_KEY_HOUR = @"hour";
NSString *const PLIST_KEY_MINUTE = @"minute";
NSString *const PLIST_KEY_WEEK = @"week";
NSString *const PLIST_KEY_REPEAT = @"repeat";
NSString *const PLIST_KEY_TIMER_ID = @"timerid";
NSString *const PLIST_KEY_STATE    = @"state";

//all text used

//button
NSString *const TEXT_IN_EDIT = @"编辑";
NSString *const TEXT_DONE    = @"确定";
NSString *const TEXT_CANCEL  = @"取消";
NSString *const TEXT_SAVE    = @"存储";
NSString *const TEXT_LOGIN   = @"登录";
NSString *const TEXT_RE_LOGIN = @"重新登录";
NSString *const TEXT_HELP = @"帮助";
NSString *const TEXT_CLICK_TO_SET_AC_MDOE = @"点击设置";

//info
NSString *const TEXT_SETTING_WRITE_FAIL = @"配置设置无法保存";
NSString *const TEXT_SETTING_NAME_ADDRESS_INVALID = @"名称或地址无效";
NSString *const TEXT_SETTING_PASSWORD_WRONG = @"密码错误";
NSString *const TEXT_SETTING_PASSWORD_NOT_MATCH = @"两次输入密码不一致";
NSString *const TEXT_NAME_ADDRESS_INVALID = @"名称或地址无效";
NSString *const TEXT_LINE = @"行";
NSString *const TEXT_DUAL_ADDRESS = @"地址重复";
NSString *const TEXT_CUSTOM_SCENE = @"";
NSString *const TEXT_SCENE_NAME_NULL = @"场景名称不能为空";
NSString *const TEXT_INVALID_SN = @"无效的序列号";

//user interface
NSString *const TEXT_MY_AC = @"我的空调";
NSString *const TEXT_MY_SCENE = @"场景模式";
NSString *const TEXT_MY_TIME = @"智能定时";
NSString *const TEXT_MY_SETTING = @"配置设置";
NSString *const TEXT_WELCOM = @"欢迎您的登录";
NSString *const TEXT_INPUT_SN = @"请输入序列号";
NSString *const TEXT_INPUT_PIN = @"请输入登录密码";
NSString *const TEXT_INDOOR_TEMPERATURE = @"室内温度";
NSString *const TEXT_MODE = @"模式";
NSString *const TEXT_FAN = @"风量";
NSString *const TEXT_POWER = @"开关";
NSString *const TEXT_TEMPERATURE = @"温度";
NSString *const TEXT_SHORT_TEMP = @"温度缩写";
NSString *const TEXT_ON = @"开";
NSString *const TEXT_OFF = @"关";

NSString *const TEXT_TIMER_ON = @"定时开";
NSString *const TEXT_TIMER_OFF = @"定时关";
NSString *const TEXT_TIMER_REPEAT = @"重复";

NSString *const TEXT_SETTING_ADDRESS_CONFIGURATION = @"空调地址配置";
NSString *const TEXT_SETTING_FLOOR_AND_ROOM = @"楼层及房间";
NSString *const TEXT_SETTING_BUTTON_SOUND = @"按键音";
NSString *const TEXT_SETTING_PASSWORD_LOCK = @"密码锁定";
NSString *const TEXT_SETTING_FEEDBACK = @"意见反馈";
NSString *const TEXT_SETTING_ABOUT = @"关于";
NSString *const TEXT_SETTING_OPENED = @"打开";
NSString *const TEXT_SETTING_CLOSED = @"关闭";
NSString *const TEXT_SETTING_SERVER = @"服务器";
NSString *const TEXT_SETTING_NAME = @"名称";
NSString *const TEXT_SETTING_ENTER_NAME = @"请输入空调名称";
NSString *const TEXT_SETTING_ADDRESS = @"地址";
NSString *const TEXT_SETTING_ENTER_ADDRESS = @"空调地址";
NSString *const TEXT_SETTING_SET_PASSWORD = @"密码设定";
NSString *const TEXT_SETTING_DELETE_PASSWORD = @"密码关闭";
NSString *const TEXT_SETTING_INPUT_PASSWORD_ONE = @"请输入密码";
NSString *const TEXT_SETTING_INPUT_PASSWORD_AGAIN = @"请再次输入密码";

NSString *const TEXT_INPUT_FLOOR_NAME = @"给新楼层命名";
NSString *const TEXT_INPUT_ROOM_NAME = @"给新房间命名";
NSString *const TEXT_INPUT_SCENE_NAME = @"给新建场景命名";
NSString *const TEXT_ADD_NEW_ROOM = @"添加新房间";
NSString *const TEXT_ADD_NEW_FLOOR = @"添加新楼层";
NSString *const TEXT_DELETE_CURRENT_FLOOR = @"删除此楼层";
NSString *const TEXT_DELETE_REORDER = @"删除和排序";
NSString *const TEXT_CUSTOM_ROOM_NAME = @"";
NSString *const TEXT_CUSTOM_FLOOR_NAME = @"";
NSString *const TEXT_ADD_NEW_AC = @"请添加新的受控空调";
NSString *const TEXT_CUSTOM_TIMER = @"";
NSString *const TEXT_SCENE_DID_INFO = @"将对空调组执行一键式集中控制";
NSString *const TEXT_SCENE_DID_DO = @"是否要执行?";

NSString *const TEXT_NAME_ADDRES_AC_NOT_EMPTY = @"楼层名称、房间名称、受控空调不能为空";
NSString *const TEXT_SCENE_NAME_AC_NOT_EMPTY = @"场景名称、受控空调不能为空";
NSString *const TEXT_INPUT_TIMER_NAME = @"请输入定时名称";
NSString *const TEXT_TIME = @"时间";
NSString *const TEXT_AC_UNIT_UNDER_CONTROLL = @"受控空调";
NSString *const TEXT_AC_STATE_SET = @"空调模式设置";
NSString *const TEXT_REPEATE_TIME = @"重复周期";
NSString *const TEXT_UP_WEEK_ONE = @"星期一";
NSString *const TEXT_UP_WEEK_TWO = @"星期二";
NSString *const TEXT_UP_WEEK_THREE = @"星期三";
NSString *const TEXT_UP_WEEK_FOUR = @"星期四";
NSString *const TEXT_UP_WEEK_FIVE = @"星期五";
NSString *const TEXT_UP_WEEK_SIX = @"星期六";
NSString *const TEXT_UP_WEEK_SEVEN = @"星期日";
NSString *const TEXT_TIMER_NAME_NOT_EMPTY = @"定时名称、受控空调不能为空";
NSString *const TEXT_TEST = @"测试";
NSString *const TEXT_PROMPT_WHEN_SET_NEW_PASSWORD = @"忘记密码要删除软件";
NSString *const TEXT_PROMPT_WHEN_AC_OK_BUTTON_PRESSED = @"控制命令已发送";
NSString *const TEXT_PROMPT_WHEN_EDIT_BUTTON_PRESSED = @"慎重修改";
NSString *const TEXT_PROMPT_WHEN_LGOIN_FAIL = @"失败请登录";
NSString *const TEXT_PROMPT_WHEN_FAIL_ADD_TIMER = @"未能成功添加定时";
NSString *const TEXT_PROMPT_TIMER_OPERATED = @"定时器已运行";
NSString *const TEXT_TIME_SYNCHRO = @"时间同步";

//#define HISENSE_MODE

#ifdef HISENSE_MODE
NSString *PACKET_SEND_PORT       = @"9012";
#else
NSString *PACKET_SEND_PORT       = @"9002";
#endif
NSString *PACKET_QUE_MAX_NUM         = @"3";
NSString *PACKET_TYPE_DATA           = @"dataPacket";
NSString *PACKET_TYPE_LOGIN          = @"loginPacket";
NSString *PACKET_TYPE_HEARTBEAT      = @"heartbeatPacket";
NSString *PACKET_RESEND_MAX_NUM      = @"5";
NSString *PACKET_RESEND_INTERVAL     = @"2";
NSString *PACKET_HEART_BEAT_INTERVAL = @"10";

NSString *TIME_LOGIN_WAITING_MAX = @"6";//最坏情况下，收到登录失败通知的时间＝重试次数＊6
NSString *TIME_LOGIN_RETRY       = @"1";
NSString *NUMBER_LOGIN_RETRY     = @"1";
NSString *MAX_DEVICE_NUM         = @"16";

NSString *MESSAGE_RECEIVE_UDP_PACKET = @"messagenameforpacketreceived";
NSString *MESSAGE_HEARTBEAT_RESPONSE = @"messagenameforheartresponse";
NSString *MESSAGE_LOGIN_SUC_RESPONSE = @"messagenameforloginsuc";
NSString *MESSAGE_INTERFACE_UPDATE_LOGIN_SUC = @"messagenameforupdateloginsuc";
NSString *MESSAGE_INTERFACE_UPDATE_LOGIN_FAIL = @"messagenameforupdateloginfail";
NSString *MESSAGE_INTERFACE_UPDATE_LOGIN_HAPPENING = @"messagenameforupdateloginhappening";
NSString *MESSAGE_INTERFACE_UPDATE_ERROR_OCCURED = @"messagenameforupdateerroroccured";
NSString *MESSAGE_INTERFACE_UPDATE_AC_STATE_CHANGED = @"messagenameforupdateacstatechanged";
NSString *MESSAGE_INTERFACE_UPDATE_TIMER_STATE_CHANGED = @"messagenameforupdatetimerstatechanged";

NSString *ERR_KEY_DEFAULT = @"default";
NSString *ERR_KEY_1001 = @"1001";
NSString *ERR_KEY_1002 = @"1002";
NSString *ERR_KEY_1003 = @"1003";
NSString *ERR_KEY_1004 = @"1004";
NSString *ERR_KEY_1005 = @"1005";
NSString *ERR_KEY_1006 = @"1006";
NSString *ERR_KEY_1007 = @"1007";
NSString *ERR_KEY_1008 = @"1008";
NSString *ERR_KEY_1009 = @"1009";
NSString *ERR_KEY_1010 = @"1010";
NSString *ERR_KEY_1099 = @"1099";
NSString *ERR_KEY_2000 = @"2000";
NSString *ERR_KEY_2001 = @"2001";

NSString *ERR_TEXT_DEFAULT = @"未知错误";
NSString *ERR_TEXT_1001    = @"终端未登陆";
NSString *ERR_TEXT_1002 = @"终端数量超限制";
NSString *ERR_TEXT_1003 = @"认证码错误";
NSString *ERR_TEXT_1004 = @"校验码错误";
NSString *ERR_TEXT_1005 = @"功能代码错误";
NSString *ERR_TEXT_1006 = @"获取i-EZ控制器序列号失败";
NSString *ERR_TEXT_1007 = @"网络故障";
NSString *ERR_TEXT_1008 = @"空调系统初始化未完成，请稍等";
NSString *ERR_TEXT_1009 = @"系统繁忙";
NSString *ERR_TEXT_1010 = @"定时器数量超限";
NSString *ERR_TEXT_1099 = @"系统故障";
NSString *ERR_TEXT_2000 = @"控制成功";
NSString *ERR_TEXT_2001 = @"控制失败";

NSString *SCENE_NUM_MAX_LIMITED = @"场景数量超限";


//hepeilin 增加
NSString *FLOOR_ID_DEF  = @"Floor_ID_DEF";
NSString *ROOM_ID_DEF   = @"Floor_ID_DEF";
int      FloorBaseId    = 1000;
int      RoomBaseId           = 2000;
NSString *ROOM_ID_KEY         = @"roomidkey";
NSString *FLOOR_ID_KEY        = @"flooridkey";
NSString *PLIST_HOME_INDEX    = @"homeindex";
NSString *PLIST_STATUS        = @"status";
NSString *const PLIST_KEY_INDOOR_INTRODUCE          = @"introduce";
NSString *const PLIST_KEY_INDOOR_CSSMAC             = @"mac";
NSString *const PLIST_KEY_INDOOR_SN                 = @"chat_id";
NSString *const PLIST_KEY_INDOOR_MANUFACTURERID     = @"cssmanufacturerid";
NSString *const PLIST_KEY_INDOOR_FROMSCAN           = @"CSSSCAN";
NSString *const PLIST_KEY_CUSTID                    = @"cust_id";
NSString *const PLIST_KEY_INDEX                     = @"index";
NSString *const PLIST_KEY_CreatorCustId             = @"creator_cust_id";
NSString *const PLIST_KEY_CreatorCustName           = @"creator_cust_name";
NSString *const PLIST_KEY_CustTotalCount            = @"cust_total_count";
NSString *const PLIST_KEY_MaxCustCount              = @"max_cust_count";
NSString *const PLIST_KEY_Latitude                  = @"latitude";
NSString *const PLIST_KEY_Longitude                 = @"longitude";
NSString *const PLIST_KEY_FileName                  = @"filename";


@interface GlobalDef()

@end

@implementation GlobalDef


+ (NSString *)modeStringWithIndex:(int)inIndex {
    NSString *res;
    switch (inIndex) {
        case 0:
            res = NSLocalizedString(@"制冷", @"") ;
            break;
        case 1:
            res = NSLocalizedString(@"制热", @"") ;
            break;
        case 2:
            res = NSLocalizedString(@"除湿", @"") ;
            break;
        case 3:
            res = NSLocalizedString(@"送风", @"") ;
            break;
            
        default:
            break;
    }
    return res?res:@"";
}

+ (NSString *)fanStringWithIndex:(int)inIndex {
    NSString *res;
    switch (inIndex) {
        case 0:
            res = NSLocalizedString(@"低风", @"") ;
            break;
        case 1:
            res = NSLocalizedString(@"中风", @"") ;
            break;
        case 2:
            res = NSLocalizedString(@"高风", @"") ;
            break;
        case 3:
            res = NSLocalizedString(@"自动", @"") ;
            break;
            
        default:
            break;
    }
    return res?res:@"";
}

+ (NSString *)weekStringWithIndex:(int)inIndex {
    NSString *res;
    switch (inIndex) {
        case 0:
            res = NSLocalizedString(@"周一", @"") ;
            break;
        case 1:
            res = NSLocalizedString(@"周二", @"") ;
            break;
        case 2:
            res = NSLocalizedString(@"周三", @"") ;
            break;
        case 3:
            res = NSLocalizedString(@"周四", @"") ;
            break;
        case 4:
            res = NSLocalizedString(@"周五", @"") ;
            break;
        case 5:
            res = NSLocalizedString(@"周六", @"") ;
            break;
        case 6:
            res = NSLocalizedString(@"周日", @"") ;
            break;
            
        default:
            break;
    }
    return res?res:@"";
}

+ (NSString *)modeImageNameWithIndex:(int)inIndex {
    NSString *res;
    switch (inIndex) {
        case 0:
            res = @"Icon_Cool";
            break;
        case 1:
            res = @"Icon_Heat";
            break;
        case 2:
            res = @"Icon_Dry";
            break;
        case 3:
            res = @"Icon_Fan";
            break;
            
        default:
            break;
    }
    return res?res:@"";
}

+ (NSString *)fanImageNameWithIndex:(int)inIndex {
    NSString *res;
    switch (inIndex) {
        case 0:
            res = @"Icon_Low";
            break;
        case 1:
            res = @"Icon_Middle";
            break;
        case 2:
            res = @"Icon_High";
            break;
        case 3:
            res = @"Icon_Auto";
            break;
            
        default:
            break;
    }
    return res?res:@"";
}

+ (NSString *)onoffImageNameWithState:(BOOL)inBool {
    NSString *res;
    if (inBool) {
        res = @"Icon_On";
    }
    else {
        res = @"Icon_OnOff";
    }
    return res;
}

+ (NSString *)pageStateStringInSceneWithIndex:(int)index {
    NSString *res;
    if (index == 0) {
        res = NSLocalizedString(@"删除和排序", @"");
    }
    else if (index == 1) {
        res = NSLocalizedString(@"编辑", @"");
    }
    else if (index == 2){
        res = NSLocalizedString(@"添加", @"");
    }
    else {
        res = @"";
    }
    return res;
}

+ (NSString *)pageStateStringInTimerWithIndex:(int)index {
    NSString *res;
    if (index == 0) {
        res = NSLocalizedString(@"删除", @"");
    }
    else if (index == 1) {
        res = NSLocalizedString(@"编辑", @"");
    }
    else if (index == 2){
        res = NSLocalizedString(@"添加", @"");
    }
    else {
        res = @"";
    }
    return res;
}

+ (NSString *)moduleNameWithIndex:(int)moduleIndex {
    NSString *res;
    switch (moduleIndex) {
        case 0:
            res = NSLocalizedString(TEXT_MY_AC, @"");
            break;
        case 1:
            res = NSLocalizedString(TEXT_MY_SCENE, @"");
            break;
        case 2:
            res = NSLocalizedString(TEXT_MY_TIME, @"");
            break;
        case 3:
            res = NSLocalizedString(TEXT_MY_SETTING, @"");
            break;
            
        default:
            break;
    }
    return res?res:@"";
}

+ (NSDictionary *)acInitialStateDictionary {
    NSMutableDictionary *xdic = [NSMutableDictionary dictionary];
    [xdic setObject:[NSNumber numberWithBool:NO] forKey:PLIST_AC_ENABLED];
    [xdic setObject:[NSNumber numberWithInt:0] forKey:PLIST_AC_MODE];
    [xdic setObject:[NSNumber numberWithInt:0] forKey:PLIST_AC_FAN];
    [xdic setObject:[NSNumber numberWithInt:20] forKey:PLIST_AC_TEMPERATURE];
    
    return xdic;
}

+ (NSDictionary *)acInvalidStateDictionary {
    NSMutableDictionary *xdic = [NSMutableDictionary dictionary];
    [xdic setObject:[NSNumber numberWithBool:NO] forKey:PLIST_AC_ENABLED];
    [xdic setObject:[NSNumber numberWithInt:ModeType_Unknow] forKey:PLIST_AC_MODE];
    [xdic setObject:[NSNumber numberWithInt:WindType_Unkonw] forKey:PLIST_AC_FAN];
    [xdic setObject:[NSNumber numberWithInt:BH_Unknow_Temperature] forKey:PLIST_AC_TEMPERATURE];
    
    return xdic;
}


+ (NSDictionary*)transferStateDic:(NSDictionary*)dic{
    
    NSMutableDictionary *xdic = [NSMutableDictionary dictionary];
    xdic = [NSMutableDictionary dictionaryWithDictionary:dic];
    
    if ([[dic objectForKey:PLIST_AC_MODE] intValue] == ModeType_Unknow) {
        [xdic setObject:[NSNumber numberWithInt:ModeType_Cold] forKey:PLIST_AC_MODE];
    }
    
    if ([[dic objectForKey:PLIST_AC_FAN] intValue] == WindType_Unkonw) {
        [xdic setObject:[NSNumber numberWithInt:WindType_Low] forKey:PLIST_AC_FAN];
    }
    
    if ([[dic objectForKey:PLIST_AC_TEMPERATURE] intValue] == BH_Unknow_Temperature) {
        [xdic setObject:[NSNumber numberWithInt:30] forKey:PLIST_AC_TEMPERATURE];
    }
    /*
    [xdic setObject:[NSNumber numberWithBool:NO] forKey:PLIST_AC_ENABLED];
    [xdic setObject:[NSNumber numberWithInt:ModeType_Unknow] forKey:PLIST_AC_MODE];
    [xdic setObject:[NSNumber numberWithInt:WindType_Unkonw] forKey:PLIST_AC_FAN];
    [xdic setObject:[NSNumber numberWithInt:BH_Unknow_Temperature] forKey:PLIST_AC_TEMPERATURE];
    */
    return xdic;



}



+ (int)getModeFromCommunicationToInterface:(int)mode {
    
    
    int res = mode;
    if (mode == 1) {
        res = 3;
    }
    else if (mode == 3) {
        res = 1;
    }
    return res;
}
+ (int)getFanFromCommunicationToInterface:(int)fan {
    int res = fan - 1;
    res = res < 0 ? 3 : res;
    return res;
}
+ (int)getModeFromInterfaceToCommunication:(int)mode {
    int res = mode;
    if (mode == 1) {
        res = 3;
    }
    else if (mode == 3) {
        res = 1;
    }
    return res;
}
+ (int)getFanFromInterfaceToCommunication:(int)fan {
    int res = fan + 1;
    res = res >3 ? 0 : res;
    return res;
}


+ (NSDictionary *)acInitialTimerDictionary{

    NSMutableDictionary *dic = [NSMutableDictionary new];
    
    [dic setObject:[NSArray array] forKey:PLIST_KEY_ADDRESS];
    [dic setObject:[NSNumber numberWithBool:NO] forKey:PLIST_KEY_DETAIL_ENABLED];
    [dic setObject:[NSNumber numberWithInt:0] forKey:PLIST_AC_FAN];
    [dic setObject:[NSNumber numberWithInt:0] forKey:PLIST_KEY_HOUR];
    [dic setObject:[NSNumber numberWithInt:0] forKey:PLIST_KEY_MINUTE];
    [dic setObject:[NSNumber numberWithInt:0] forKey:PLIST_AC_MODE];
    [dic setObject:@"" forKey:PLIST_KEY_NAME];
    [dic setObject:[NSNumber numberWithBool:NO] forKey:PLIST_AC_ENABLED];
    [dic setObject:[NSNumber numberWithBool:NO] forKey:PLIST_KEY_REPEAT];
    [dic setObject:[NSNumber numberWithInt:20] forKey:PLIST_AC_TEMPERATURE];
    [dic setObject:[NSNumber numberWithBool:NO] forKey:PLIST_KEY_TIMER_ENABLED];
    [dic setObject:[NSNumber numberWithInt:0] forKey:PLIST_KEY_TIMER_ID];
    [dic setObject:[NSArray array] forKey:PLIST_KEY_WEEK];
    

    
    return dic;
}

@end
