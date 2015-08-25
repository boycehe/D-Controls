//
//  PfcManager.h
//  BHAirConditionControls
//
//  Created by heboyce on 7/3/15.
//  Copyright (c) 2015 boyce. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PfcCmd : NSObject
@property (nonatomic,assign) NSInteger  pfcFrame;
@property (nonatomic,assign) NSInteger  actionType;

@end

@interface PfcManager : NSObject

- (void)setPfcCmd:(PfcCmd*)cmd;
- (PfcCmd*)getPfcCmd:(NSInteger)pfcFrame;

@end
