//
//  DCManager.m
//  D-Controls
//
//  Created by heboyce on 8/25/15.
//  Copyright © 2015 boycehe. All rights reserved.
//

#import "DCManager.h"
#import "PlistManager.h"
#import "PacketManager.h"
#import "UdpManager.h"
#import "FrameNumManager.h"
#import "AuthorizeManager.h"
#import "CtrlStateManager.h"

@implementation DCManager

+ (DCManager*)shareManager{
    
    static DCManager *sharedAccountManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedAccountManagerInstance = [[self alloc] init];
    });
    return sharedAccountManagerInstance;
    
}

- (void)startConnect{


}


- (void)disConnect{


}


@end
