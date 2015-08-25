//
//  AuthorizeManager.h
//  D-Controls Plus
//
//  Created by Liu Tao on 12-11-9.
//  Copyright (c) 2012年 D-Haus Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AppDelegate;

@interface AuthorizeManager : NSObject

- (NSString *)getAuthcode;
- (void)setTemporaryAuthcode:(NSString *)inAuthcode;
- (void)saveTemporaryToAvailable;

- (void)setLoginStatus:(BOOL)inBool;
- (BOOL)getLoginStatus;
- (void)resetLoginRetryTime;
- (void)loginToServer;

- (void)showErrorInfo:(NSString *)errKey;
- (NSString *)getErrStr;
- (void)clearErrStr;
- (BOOL)autoScanCSS;

@end
