//
//  BHBufferMsg.h
//  BHAirConditionControls
//
//  Created by heboyce on 8/11/15.
//  Copyright © 2015 boyce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BHSocketSendChatMsg.h"

@interface BHBufferMsg : NSObject
@property (nonatomic,strong) BHSocketSendChatMsg         *msg;
@property (nonatomic,assign) NSTimeInterval               sendTimeFrom1970;
@end
