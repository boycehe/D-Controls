//
//  BHMsgInfo.h
//  BHJingYingHui
//
//  Created by hepeilin on 14-8-7.
//  Copyright (c) 2014年 boyce. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface BHMsgInfo : NSObject
@property (nonatomic, strong) NSString                *message_no;
@property (nonatomic, strong) NSString                *talkId;
@property (nonatomic, assign) int          type;
@property (nonatomic, assign) int       chatType;
@property (nonatomic, assign) int sendStatus;
@property (nonatomic, strong) NSString                *creatorUserId;
@property (nonatomic, strong) NSString                *custName;
@property (nonatomic, strong) NSString                *text;
@property (nonatomic, strong) NSString                *attachmentsJson;
@property (nonatomic, strong) NSDate                  *createdDate;
@property (nonatomic, strong) NSString                *adminId;
/*
   新闻，活动的内容也存在这里
 */
@property (nonatomic, strong) NSString                *attachContent;
@property (nonatomic, assign) BOOL                    isRead;
@property (nonatomic,assign ) long long                    fromCustId;
@property (nonatomic,assign ) long long                    toCustId;
@property (nonatomic,strong ) NSString                *fromCustName;
@property (nonatomic,strong ) NSString                *toCustName;

/*
 extended property
*/
@property (nonatomic, assign) BOOL                    isShowMessageDate;

@property (nonatomic,assign) BOOL                      hadCalculate;


-(BHMsgInfo*)mutableCopy;


@end
