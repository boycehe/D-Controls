//
//  QuickData.m
//  D-Controls Plus
//
//  Created by Liu Tao on 12-11-16.
//  Copyright (c) 2012年 D-Haus Technology Co.,Ltd. All rights reserved.
//

#import "QuickData.h"
#import "FrameNumManager.h"
#import "GlobalDef.h"
#import "DCManager.h"

@implementation QuickData

/*
 TEST
 */

+ (NSData*)data_0F{
    
    NSMutableData *data = [NSMutableData new];
    [data appendData:[self dataFromHexString:@"80"]];
    [data appendData:[self dataFromHexString:@"01"]];
    [data appendData:[self dataFromHexString:@"0F"]];
    [data appendData:[self dataFromHexString:@"00"]];
    
    return data;
    
}

+ (NSData*)dataTest{
    
    NSMutableData *data = [NSMutableData new];
    [data appendData:[self dataFromHexString:@"80"]];
    [data appendData:[self dataFromHexString:@"01"]];
    [data appendData:[self dataFromHexString:@"0F"]];
    [data appendData:[self dataFromHexString:@"00"]];
    
     return data;

}
//68 80010F00
+ (NSData *)dataHeader {
    return [self dataFromHexString:@"68"];
}


+ (NSData *)dataTail {
    return [self dataFromHexString:@"16"];
}

+ (NSData *)dataFrameNum {
   
    FrameNumManager *fmanager = [[DCManager shareManager] fManager];
    
    NSInteger prm = 1;//启动站
    NSInteger pfc = [fmanager getFrameNum];//帧序号
    if (prm) {
        pfc+=128;
    }
    NSString *frameNumStr = [[NSString stringWithFormat:@"%02x",(int)pfc] uppercaseString];
    return [self dataFromHexString:frameNumStr];
}



+ (NSData *)dataBCDFromInt:(int)bcd {
    bcd = bcd % 100;
    int decadeDigit = bcd / 10;
    int unitDigit = bcd % 10;
    NSString *string = [[NSString stringWithFormat:@"%d%d", decadeDigit, unitDigit] uppercaseString];
    return [self dataFromHexString:string];
}

+ (NSData *)dataLength:(NSInteger)inLen {
    NSString *lenStr = [[NSString stringWithFormat:@"%02x", (int)inLen] uppercaseString];
    
    NSLog(@"lenStr:%@",lenStr);
    
    return [self dataFromHexString:lenStr];
}


+ (NSData *)dataSumVerify:(NSData *)inPacket {
    NSMutableData *resData = [NSMutableData data];
    if (inPacket&&inPacket.length!=0) {
        NSInteger len = [self sumOfNsData:inPacket];
        NSString *xstr = [[NSString stringWithFormat:@"%02x", (int)len] uppercaseString];
        [resData appendData:[self dataFromHexString:xstr]];
    }
    return resData;
}



+ (NSData *)dataFromHexString:(NSString *)hexStr {
    NSMutableData *data = [NSMutableData data];
    uint32_t uint32;
    sscanf([hexStr cStringUsingEncoding:NSASCIIStringEncoding], "%x",&uint32);
    uint8_t uint8 = (uint8_t)(uint32&0x000000FF);
    [data appendBytes:(void*)(&uint8) length:1];
    return data;
}

+ (NSString *)ToHex:(long long int)tmpid
{
    
    NSString *nLetterValue;
    
    NSString *str =@"";
    
    long long int ttmpig;
    
    while (YES) {
        
        ttmpig=tmpid%16;
        
        tmpid=tmpid/16;
        switch (ttmpig)
        {
            case 10:
                nLetterValue =@"A";break;
            case 11:
                nLetterValue =@"B";break;
            case 12:
                nLetterValue =@"C";break;
            case 13:
                nLetterValue =@"D";break;
            case 14:
                nLetterValue =@"E";break;
            case 15:
                nLetterValue =@"F";break;
            default:nLetterValue=[[NSString alloc]initWithFormat:@"%i",ttmpig];
                
        }
        str = [nLetterValue stringByAppendingString:str];
        if (tmpid == 0) {
            break;
        }
        
        
        
    }
    
    
    
    
    return str;
}

+ (NSInteger)sumOfNsData:(NSData *)data {
    NSInteger sum = 0;
    int cnt = (int)[data length];
    for (int i = 0; i<cnt; i++) {
        uint8_t t;
        [data getBytes:(void *)(&t) range:NSMakeRange(i, 1)];
        sum += t;
        if (sum>255) {
            sum-=256;
        }
    }
    return sum;
}

+ (NSString*)stringFromHexData:(NSData*)data {
    NSMutableString *zz = [[NSMutableString alloc] initWithString:@""];
    Byte *bytes = (Byte*)[data bytes];
    int cnt = (int)[data length];
    for (int i=0; i<cnt; i++) {
        [zz appendFormat:@"%02x ",*(bytes+i)&0xFF];
    }
    return [zz uppercaseString];
}

+ (NSString*)stringNoSpaceFromHexData:(NSData*)data {
    NSMutableString *zz = [[NSMutableString alloc] initWithString:@""];
    Byte *bytes = (Byte*)[data bytes];
    int cnt = (int)[data length];
    for (int i=0; i<cnt; i++) {
        [zz appendFormat:@"%02x",*(bytes+i)&0xFF];
    }
    return [zz uppercaseString];
}

@end
