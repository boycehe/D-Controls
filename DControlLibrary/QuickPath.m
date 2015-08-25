//
//  QuickPath.m
//  BHBase64EncoderDecoder
//
//  Created by Liu Tao on 12-11-6.
//  Copyright (c) 2012年 D-Haus Technology Co.,Ltd. All rights reserved.
//

#import "QuickPath.h"

@implementation QuickPath

+ (NSString *)getLibraryFilePathWithName:(NSString *)filename {
    if (filename==nil) return nil;
    NSString *libPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//TODO:
   // filename = [NSString stringWithFormat:@"%zd%@",[DCManager shareManager].managerInfo.custId,filename];
    
    return [libPath stringByAppendingPathComponent:filename];
}

+ (NSString *)getDocumentFilePathWithName:(NSString *)filename {
    if (filename==nil) return nil;
    
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //TODO:
    NSString *userPath = docPath;//[docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%lld",[DCManager shareManager].managerInfo.custId]];
    
    if (![fileManager fileExistsAtPath:userPath]) {
         [fileManager createDirectoryAtPath:userPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return [userPath stringByAppendingPathComponent:filename];
}

+ (NSString *)getMainBundleFilePathWithName:(NSString *)filename {
    if (filename==nil) return nil;
    NSArray *xarr = [filename componentsSeparatedByString:@"."];
    if (xarr == nil ) return nil;
    NSInteger cnt = [xarr count];
    if (cnt < 2) return nil;
    NSString *namePart = [xarr objectAtIndex:cnt-2];
    if (namePart == nil || [namePart isEqualToString:@""]) return nil;
    NSString *typePart = [xarr objectAtIndex:cnt-1];
    if (typePart == nil || [typePart isEqualToString:@""]) return nil;
    return [[NSBundle mainBundle] pathForResource:namePart ofType:typePart];
}

+ (NSString *)getLibraryFilePathWithName:(NSString *)filename InFolder:(NSString *)foldername{
    if (filename==nil || foldername==nil) return nil;
    NSString *libPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [[libPath stringByAppendingPathComponent:foldername] stringByAppendingPathComponent:filename];
}

+ (NSString *)getDocumentFilePathWithName:(NSString *)filename InFolder:(NSString *)foldername{
    if (filename==nil || foldername==nil) return nil;
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [[docPath stringByAppendingPathComponent:foldername] stringByAppendingPathComponent:filename];
}

@end
