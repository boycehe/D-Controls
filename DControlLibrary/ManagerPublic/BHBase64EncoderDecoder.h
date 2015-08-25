//
//  BHBase64EncoderDecoder.h
//  BHBase64EncoderDecoder
//
//  Created by Liu Tao on 12-11-6.
//  Copyright (c) 2012年 D-Haus Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BHBase64EncoderDecoder : NSObject

+ (NSString*) customEncode:(NSData *)inData;
+ (NSData*) customDecode:(NSData *)inData;

+ (NSString *)base64Encode:(NSData *)inData;
+ (NSData*) base64Decode:(NSString *)inString;

@end
