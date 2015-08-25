//
//  QuickPath.h
//  BHBase64EncoderDecoder
//
//  Created by Liu Tao on 12-11-6.
//  Copyright (c) 2012年 D-Haus Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QuickPath : NSObject

+ (NSString *)getLibraryFilePathWithName:(NSString *)filename;
+ (NSString *)getDocumentFilePathWithName:(NSString *)filename;
+ (NSString *)getMainBundleFilePathWithName:(NSString *)filename;

+ (NSString *)getLibraryFilePathWithName:(NSString *)filename InFolder:(NSString *)foldername;
+ (NSString *)getDocumentFilePathWithName:(NSString *)filename InFolder:(NSString *)foldername;

@end
