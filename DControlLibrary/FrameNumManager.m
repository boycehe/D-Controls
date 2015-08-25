//
//  FrameNumManager.m
//  D-Controls Plus
//
//  Created by Liu Tao on 12-11-16.
//  Copyright (c) 2012年 D-Haus Technology Co.,Ltd. All rights reserved.
//

#import "FrameNumManager.h"

@interface FrameNumManager () {
    NSInteger currentIndex;
}

@end

@implementation FrameNumManager

- (id)init {
    self = [super init];
    if (self!=nil) {
        [self load];
    }
    return self;
}

- (void)load {
    currentIndex = 0;
}

- (NSInteger)getFrameNum {
    
    NSInteger res = currentIndex;
    currentIndex ++;
    currentIndex = currentIndex > 127 ? 0 : currentIndex;
    return res;
}

- (NSInteger)getNextFrameNum{
    
    NSInteger res = currentIndex;
    res = res+1;
    res = res > 127 ? 0 : res;
    return res;
}

@end
