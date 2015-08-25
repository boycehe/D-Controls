//
//  DCManager.h
//  D-Controls
//
//  Created by heboyce on 8/25/15.
//  Copyright © 2015 boycehe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCManagerInfo.h"
@class PlistManager,PacketManager,UdpManager,FrameNumManager,AuthorizeManager,CtrlStateManager;

@interface DCManager : NSObject
@property (strong, nonatomic) PlistManager       *pManager;
@property (strong, nonatomic) PacketManager      *pkManager;
@property (strong, nonatomic) UdpManager         *uManager;
@property (strong, nonatomic) FrameNumManager    *fManager;
@property (strong, nonatomic) AuthorizeManager   *aManager;
@property (strong, nonatomic) CtrlStateManager   *csManager;
@property (nonatomic,strong,readonly) DCManagerInfo    *managerInfo;

+ (DCManager*)shareManager;
- (void)startConnect;

@end
