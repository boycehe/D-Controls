//
//  AuthorizeManager.m
//  D-Controls Plus
//
//  Created by Liu Tao on 12-11-9.
//  Copyright (c) 2012年 D-Haus Technology Co.,Ltd. All rights reserved.
//

#import "AuthorizeManager.h"
#import "PacketManager.h"

#import "GlobalDef.h"
#import "QuickPath.h"
#import "BHBase64EncoderDecoder.h"
#import "QuickData.h"
#import "PacketManager.h"
#import "PlistManager.h"
#import "DCManager.h"

#define ShowTimeInterval  10.0f

@interface AuthorizeManager () {
    BOOL loginStatus;
    int loginRetryTime;
    NSTimer *heartBeatTimer;
    
    NSString *authcodeInputByUser;
    NSString *errStr;
    BOOL errExist;
}


@property (strong, nonatomic) NSMutableDictionary        *errInfoDic;
@property (nonatomic,strong) NSMutableDictionary         *regulationDic;

@end

@implementation AuthorizeManager

#pragma mark - getter & init


- (NSMutableDictionary*)regulationDic{

    if (!_regulationDic) {
        _regulationDic = [NSMutableDictionary new];
    }
    
    return _regulationDic;
    
    
}

- (NSMutableDictionary *)errInfoDic {
    if (_errInfoDic == nil) {
        
         _errInfoDic = [NSMutableDictionary dictionary];
        
        [_errInfoDic setObject:NSLocalizedString(ERR_TEXT_DEFAULT,@"") forKey:ERR_KEY_DEFAULT];
        [_errInfoDic setObject:NSLocalizedString(ERR_TEXT_1001,@"") forKey:ERR_KEY_1001];
        [_errInfoDic setObject:NSLocalizedString(ERR_TEXT_1002,@"") forKey:ERR_KEY_1002];
        [_errInfoDic setObject:NSLocalizedString(ERR_TEXT_1003,@"") forKey:ERR_KEY_1003];
        [_errInfoDic setObject:NSLocalizedString(ERR_TEXT_1004,@"") forKey:ERR_KEY_1004];
        [_errInfoDic setObject:NSLocalizedString(ERR_TEXT_1005,@"") forKey:ERR_KEY_1005];
        [_errInfoDic setObject:NSLocalizedString(ERR_TEXT_1006,@"") forKey:ERR_KEY_1006];
        [_errInfoDic setObject:NSLocalizedString(ERR_TEXT_1007,@"") forKey:ERR_KEY_1007];
        [_errInfoDic setObject:NSLocalizedString(ERR_TEXT_1008,@"") forKey:ERR_KEY_1008];
        [_errInfoDic setObject:NSLocalizedString(ERR_TEXT_1009,@"") forKey:ERR_KEY_1009];
        [_errInfoDic setObject:NSLocalizedString(ERR_TEXT_1010,@"") forKey:ERR_KEY_1010];
        [_errInfoDic setObject:NSLocalizedString(ERR_TEXT_1099,@"") forKey:ERR_KEY_1099];
        [_errInfoDic setObject:NSLocalizedString(ERR_TEXT_2000,@"") forKey:ERR_KEY_2000];
        [_errInfoDic setObject:NSLocalizedString(ERR_TEXT_2001,@"") forKey:ERR_KEY_2001];
        
        
    }
    return _errInfoDic;
}

- (id)init {
    self = [super init];
    if (self != nil) {
        [self load];
    }
    return self;
}

#pragma mark - fun
- (void)load {
    loginStatus = NO;
    loginRetryTime = 0;
    [heartBeatTimer invalidate];
    heartBeatTimer = nil;
    
    authcodeInputByUser = nil;
    errStr = nil;
}

- (NSString *)getAuthcode {
    NSString *res = authcodeInputByUser;
  //  [DCManager shareManager].pkManager
    res = res ? res : [[DCManager shareManager].pManager getAuthcode];
    return res;
}
- (void)setTemporaryAuthcode:(NSString *)inAuthcode {
    authcodeInputByUser = inAuthcode;
}
- (void)saveTemporaryToAvailable {
    if (authcodeInputByUser.length == [SN_LENGTH intValue]) {
        [[DCManager shareManager].pManager setAuthocodeString:authcodeInputByUser];
    }
}

- (void)setLoginStatus:(BOOL)inBool {
    loginStatus = inBool;
    loginRetryTime = loginStatus ? 0 : loginRetryTime;
    NSString *messagename = loginStatus ? MESSAGE_INTERFACE_UPDATE_LOGIN_SUC : MESSAGE_INTERFACE_UPDATE_LOGIN_FAIL;
  //  [[DCManager shareManager] dispatchMessage:messagename];
}

- (void)resetLoginRetryTime {
    loginRetryTime = 0;
}

- (BOOL)getLoginStatus {
    return loginStatus;
}

- (void)showErrorInfo:(NSString *)errKey {
    
    if (errKey&&errKey.length!=0) {
        errStr = [self.errInfoDic objectForKey:errKey];
        if (errStr == nil) {
            errStr = [self.errInfoDic objectForKey:ERR_KEY_DEFAULT];
        }
        errExist = YES;
    }
    
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval lastShowTime = [[self.regulationDic objectForKey:errKey] doubleValue];
    
    if (interval - lastShowTime > ShowTimeInterval) {
      //  [[LoadingViewManager sharedInstance] showHUDWithText:errStr inView:[DCManager shareManager].window duration:k_timeinterval_3Secods];
    }
    
    [self.regulationDic setObject:DoubleToNumber(interval) forKey:errKey];
    

   // [[DCManager shareManager] dispatchMessage:MESSAGE_INTERFACE_UPDATE_ERROR_OCCURED];
}

- (NSString *)getErrStr {
    NSString *res;
    if (errExist) {
        errExist = NO;
        res = errStr;
    }
    else {
        res = loginStatus ? @"" : TEXT_PROMPT_WHEN_LGOIN_FAIL;
    }
    return res;
}

- (void)clearErrStr {
    errStr = nil;
}

- (void)getHeartBeatAnswer:(NSNotification *)ntf {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self startHeartBeater];
}

- (void)sendHeartBeatPacket {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getHeartBeatAnswer:) name:MESSAGE_HEARTBEAT_RESPONSE object:nil];
    [[DCManager shareManager].pkManager sendHeartbeatData];
}

- (void)startHeartBeater {
    [heartBeatTimer invalidate];
    heartBeatTimer = nil;
    heartBeatTimer = [NSTimer scheduledTimerWithTimeInterval:[PACKET_HEART_BEAT_INTERVAL doubleValue] target:self selector:@selector(sendHeartBeatPacket) userInfo:nil repeats:NO];
}

- (void)loginSuc:(NSNotification *)ntf {
    NSLog(@"log suc in am");
    [self setLoginStatus:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
  //  [[DCManager shareManager] dispatchMessage:MESSAGE_INTERFACE_UPDATE_LOGIN_SUC];
    [self startHeartBeater];
}


- (void)loginToServer {

        
    return;

    if (!loginStatus) {
        
//        if (loginRetryTime == 0) {//发送10个空包，以激活i-EZ控制器
//            int cnt = 10;
//            while(cnt--) {
//                [[DCManager shareManager].pkManager sendEmptyData];
//            }
//        }
        
        loginRetryTime++;
        NSLog(@"登录次数: %d", loginRetryTime);
        if (loginRetryTime > [NUMBER_LOGIN_RETRY intValue]) {
            NSLog(@"已尝试%d次登录未能成功，登录失败", [NUMBER_LOGIN_RETRY intValue]);
            [self setLoginStatus:NO];
            loginRetryTime = 0;
          //  [[DCManager shareManager] dispatchMessage:MESSAGE_INTERFACE_UPDATE_LOGIN_FAIL];
            return;
        }
       // [[DCManager shareManager] dispatchMessage:MESSAGE_INTERFACE_UPDATE_LOGIN_HAPPENING];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuc:) name:MESSAGE_LOGIN_SUC_RESPONSE object:nil];
        [[DCManager shareManager].pkManager sendLoginData];
    }
}


#pragma mark ----NewMethod

- (BOOL)autoScanCSS{
    
 return   [[DCManager shareManager].pkManager send_OF_RequestData];
}

@end
