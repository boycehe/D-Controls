//
//  DCManagerTool.m
//  D-Controls
//
//  Created by heboyce on 8/25/15.
//  Copyright © 2015 boycehe. All rights reserved.
//

#import "DCManagerTool.h"
#import "UdpManager.h"

@implementation DCManagerTool


+ (UDP_TYPE)getUdpTypeWithModel:(RecModel*)model{
    
    UDP_TYPE type = UDP_TYPE_UNKNOWN;
    
    NSData  *inData = model.data;
    uint8_t oneByte;
    [inData getBytes:(void*)&oneByte range:NSMakeRange(2, 1)];
    int len = oneByte;
    [inData getBytes:(void*)&oneByte range:NSMakeRange(3, 1)];
    int afn = oneByte;
    if (afn < 0 && afn > 15) {//检查功能码是否合法
        return  type;
    }
    
    if (afn == 0 && len == 0) {//确认报文
        type = UDP_TYPE_OK;
    }else if (afn == 1 && len == 4) {//否认报文，不抛出消息，直接重新登录
        type = UDP_TYPE_DENY;
    }else if (afn == 6) {
        type = UDP_TYPE_FEEDBACK;
    }else if (afn == 8 && len == 32) {//查询定时信息后，定时信息反馈
        type = UDP_TYPE_AddOrModify_TIMER;
    }else if (afn == 9 && len == 2) {//删除定时器
        type = UDP_TYPE_DELETE_TIMER;
    }else if (afn == 11 && len == 2) {//定时器触发
        type = UDP_TYPE_RUNTIMER;
    }else if (afn == 0x0D && len == 1) {//定时器数量
        type = UDP_TYPE_AC_COUNT;
    }else if (afn == 14){
        type = UDP_TYPE_AC_ALL_ADDRESSA;
    }else if (afn == 15){
        type = UDP_TYPE_AC_SN;
    }
    
    
    return  type;
}

+ (NSString*)randomString{
    
    int NUMBER_OF_CHARS = 20;
    char data[NUMBER_OF_CHARS];
    
    for (int x =0;x < NUMBER_OF_CHARS;x++)
    {
        data[x] = ('A' + arc4random_uniform(26));
    }
    
    NSString *dataPoint = [[NSString alloc] initWithBytes:data length:NUMBER_OF_CHARS encoding:NSUTF8StringEncoding];
    
    return dataPoint;
    
}

+ (NSArray*)SortArray:(NSArray*)array{
    
    
    NSArray *sortedArray = [array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        if ([obj1 intValue]>[obj2 intValue]) {
            return NSOrderedDescending;
        }else if ([obj1 intValue] == [obj2 intValue]){
            return NSOrderedSame;
        }else{
            return NSOrderedAscending;
        }
        
        
    }];
    
    return sortedArray;
    
}

+ (NSString*)generateDeviceName:(long)deviceSN{
    
    long m = deviceSN;
    long a = m/BH_NO_NUM;
    long b = m%BH_NO_NUM;
    
    NSString *badge = @"";
    if (b < 10) {
        badge = [NSString stringWithFormat:@"%ld-0%ld",a,b];
    }else{
        badge = [NSString stringWithFormat:@"%ld-%ld",a,b];
    }
    
    return badge;
    
}

+ (NSArray*)SortDicArray:(NSArray*)array{
    
    
    NSArray *sortedArray = [array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        if ([[obj1 objectForKey:PLIST_KEY_INDOOR_ADDRESS] intValue]>[[obj2 objectForKey:PLIST_KEY_INDOOR_ADDRESS] intValue]) {
            return NSOrderedDescending;
        }else if ([[obj1 objectForKey:PLIST_KEY_INDOOR_ADDRESS] intValue] == [[obj2 objectForKey:PLIST_KEY_INDOOR_ADDRESS] intValue]){
            return NSOrderedSame;
        }else{
            return NSOrderedAscending;
        }
        
        
    }];
    
    return sortedArray;
    
}




@end
