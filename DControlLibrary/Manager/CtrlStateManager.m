//
//  CtrlStateManager.m
//  D-Controls Plus
//
//  Created by Liu Tao on 12-11-16.
//  Copyright (c) 2012年 D-Haus Technology Co.,Ltd. All rights reserved.
//

#import "CtrlStateManager.h"
#import "GlobalDef.h"
#import "PlistManager.h"
#import "QuickPath.h"
#import "BHBase64EncoderDecoder.h"

#define TimeInterval   3

@interface CtrlStateManager () {
    
}

@property (strong, nonatomic) NSMutableDictionary *ctrlStateDic;
@property (nonatomic,assign) NSTimeInterval        performanceTime;
@property (nonatomic,assign) BOOL                   isRuning;

@end

@implementation CtrlStateManager

#pragma mark - getter

- (id)init {
    self = [super init];
    if (self!=nil) {
        [self load];
    }
    return self;
}

- (void)load {
    
    if (self.ctrlStateDic != nil) {
        [self.ctrlStateDic removeAllObjects];
         self.ctrlStateDic = nil;
    }
    
    self.isRuning = NO;
    
    //第一个位置，库目录
    NSString *filePath = [QuickPath getLibraryFilePathWithName:PLIST_AC_STATE_FILENAME];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {//文件存在
        NSData *fileData = [[NSFileManager defaultManager] contentsAtPath:filePath];
        self.ctrlStateDic = (NSMutableDictionary *)[NSPropertyListSerialization propertyListFromData:[BHBase64EncoderDecoder customDecode:fileData] mutabilityOption:NSPropertyListMutableContainersAndLeaves format:nil errorDescription:nil];
        if (self.ctrlStateDic!=nil) {
            return;//文件存在且有效，则结束
        }
        else {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];//文件存在但无效，则删除之
        }
    }
    
    //创建一个新的空dictionary
    self.ctrlStateDic = [NSMutableDictionary dictionary];

    [self save];
}

- (void)save {
    
    BOOL suc = NO;
    NSData *xdata = [NSPropertyListSerialization dataFromPropertyList:self.ctrlStateDic format:NSPropertyListBinaryFormat_v1_0 errorDescription:nil];
    
    if (xdata!=nil && xdata.length!=0) {
        
        if ([PLAIN_TEXT_ENABLED boolValue]) {//非加密存储，调试时使用
            NSString *plistPath = [QuickPath getLibraryFilePathWithName:@"temp.plist"];
            [xdata writeToFile:plistPath atomically:YES];
        }
        
        NSString *encodedString = [BHBase64EncoderDecoder customEncode:xdata];
        NSData *encodedData = [encodedString dataUsingEncoding:NSUTF8StringEncoding];
        
        NSString *dcPath = [QuickPath getLibraryFilePathWithName:PLIST_AC_STATE_FILENAME];
        suc = [encodedData writeToFile:dcPath atomically:YES];
    }
    
    if (!suc) {
        NSLog(@"(not expected)%@", TEXT_SETTING_WRITE_FAIL);
    }
}

- (void)restore {
    NSString *plistPath = [QuickPath getLibraryFilePathWithName:PLIST_AC_STATE_FILENAME];
    if ([[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:plistPath error:nil];
    }
    [self load];
}

#pragma mark - func

- (void)setOnOff:(int)onoff mode:(int)mode fan:(int)fan temperature:(int)temperature forAddress:(int)addr warning:(int)warning {
    
    if (addr >= 0 && addr < 256) {
        
         NSNumber *addressKey = [NSNumber numberWithInt:addr];
         NSMutableDictionary *valueDic = [NSMutableDictionary dictionary];
        [valueDic setObject:[NSNumber numberWithBool:onoff] forKey:PLIST_AC_ENABLED];
        [valueDic setObject:[NSNumber numberWithInt:mode] forKey:PLIST_AC_MODE];
        [valueDic setObject:[NSNumber numberWithInt:fan] forKey:PLIST_AC_FAN];
        [valueDic setObject:[NSNumber numberWithInt:temperature] forKey:PLIST_AC_TEMPERATURE];
        [valueDic setObject:[NSNumber numberWithInt:warning] forKey:PLIST_AC_WARNING];
        [valueDic setObject:[NSDate date] forKey:PLIST_AC_RECORDING_TIME];
        
        NSLog(@"addressKey:%@ stateDic:%@",[addressKey stringValue],valueDic);
        
        /*
        if ([R.waitFeedDic objectForKey:addressKey]) {
            [R.waitFeedDic setObject:[NSNumber numberWithBool:YES] forKey:addressKey];
        }
         */
       
        
        [self.ctrlStateDic setObject:valueDic forKey:[addressKey stringValue]];
        [self save];
        
        [self updateController];
        
      //[self.app dispatchMessage:MESSAGE_INTERFACE_UPDATE_AC_STATE_CHANGED];//更新界面
        
    }
}

-(void)updateController{

    NSTimeInterval  interval = [[NSDate date] timeIntervalSince1970];
    
    if (interval - self.performanceTime >= TimeInterval) {
        //立即执行
          NSLog(@"updateMenu");
        self.performanceTime = interval;
       //  [self.app dispatchMessage:MESSAGE_INTERFACE_UPDATE_AC_STATE_CHANGED];//更新界面
    }else{
        //延后执行
        
        if (self.isRuning) {
            return;
        }
         self.isRuning = YES;
        [self performSelector:@selector(updateMenu) withObject:nil afterDelay:TimeInterval];
        
    }
    


}

- (void)updateMenu{
    
    NSLog(@"updateMenu");

     self.performanceTime = [[NSDate date] timeIntervalSince1970];
      self.isRuning = NO;
    // [self.app dispatchMessage:MESSAGE_INTERFACE_UPDATE_AC_STATE_CHANGED];//更新界面
}


- (NSDictionary *)getAcStateForAddress:(NSNumber *)addr {
    NSDictionary *res;
    if (addr) {
        res = [self.ctrlStateDic objectForKey:[addr stringValue]];
    }
    
    if (res == nil) {        
        res = [NSDictionary dictionaryWithDictionary:[GlobalDef acInitialStateDictionary]];
    }
    
    return res;
}

- (NSDictionary *)getAcStateForAcMenuForAddress:(NSNumber *)addr {
    NSDictionary *res;
    if (addr) {
        res = [self.ctrlStateDic objectForKey:[addr stringValue]];
    }
    
    return res;
}

@end
