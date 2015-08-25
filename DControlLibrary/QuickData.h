//
//  QuickData.h
//  D-Controls Plus
//
//  Created by Liu Tao on 12-11-16.
//  Copyright (c) 2012年 D-Haus Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QuickData : NSObject

+ (NSData*)dataTest;

+ (NSData *)dataHeader;
+ (NSData *)dataTail;
+ (NSData *)dataFrameNum;
+ (NSData*)data_0F;
//+ (NSData *)dataAddress:(NSString *)inAddr;
+ (NSData *)dataLength:(NSInteger)inLen;
//+ (NSData *)dataValue:(NSNumber *)inValue withType:(NSString *)inType;
+ (NSData *)dataSumVerify:(NSData *)inPacket;

+ (NSData *)dataFromHexString:(NSString *)hexStr;
//+ (NSData *)dataFromFloatNumber:(NSNumber *)floatNum;
//+ (BOOL)mValueIsAvailable:(int)vv;


//+ (NSNumber *)numberProcessed:(NSNumber *)inValue withType:(NSString *)inType;
//+ (NSInteger)lengthOfType:(NSString *)inType;
+ (NSInteger)sumOfNsData:(NSData *)data;

+ (NSString*)stringFromHexData:(NSData*)data;

+ (NSData *)dataBCDFromInt:(int)bcd;

+ (NSString *)ToHex:(long long int)tmpid;

+ (NSString*)stringNoSpaceFromHexData:(NSData*)data;

@end
