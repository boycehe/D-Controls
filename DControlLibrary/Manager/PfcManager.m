//
//  PfcManager.m
//  BHAirConditionControls
//
//  Created by heboyce on 7/3/15.
//  Copyright (c) 2015 boyce. All rights reserved.
//

#import "PfcManager.h"

@implementation PfcCmd

@end

@interface PfcManager ()
@property (nonatomic,strong) NSMutableArray *container;

@end

@implementation PfcManager


- (void)setPfcCmd:(PfcCmd*)cmd{
    if (self.container == nil) {
        self.container = [NSMutableArray new];
    }
    
    [self.container addObject:cmd];

    
}
- (PfcCmd*)getPfcCmd:(NSInteger)pfcFrame{
    
    PfcCmd *___cmd = nil;

    for (NSInteger i = [self.container count]-1; i >=0; i--) {
        
        PfcCmd *cc = [self.container objectAtIndex:i];
        
        if (cc.pfcFrame == pfcFrame) {
            ___cmd = cc;
            [self.container removeObject:cc];
            break;
        }
        
    }
    
    [self removePfcCmd:pfcFrame];

    return ___cmd;
}

- (void)removePfcCmd:(NSInteger)pfcFrame{

    PfcCmd *___cmd = nil;

    for (NSInteger i = 0; i < [self.container count];i++){
        
        PfcCmd *cc = [self.container objectAtIndex:i];
        
        if (cc.pfcFrame == pfcFrame) {
           
            ___cmd = cc;
            [self.container removeObject:cc];
           
            
            break;
        }
        
    }
    
    if (___cmd != nil) {
        [self removePfcCmd:pfcFrame];
    }

}



@end
