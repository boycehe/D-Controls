//
//  BHMsgInfo.m
//  BHJingYingHui
//
//  Created by hepeilin on 14-8-7.
//  Copyright (c) 2014年 boyce. All rights reserved.
//

#import "BHMsgInfo.h"

@implementation BHMsgInfo

-(BHMsgInfo*)mutableCopy{

    BHMsgInfo *msgInfo = [BHMsgInfo new];
    
    msgInfo.message_no=self.message_no;
    msgInfo.talkId=self.talkId;
    msgInfo.type=self.type;
    msgInfo.chatType=self.chatType;
    msgInfo.sendStatus=self.sendStatus;
    msgInfo.creatorUserId=self.creatorUserId;
    msgInfo.custName=self.custName;
    msgInfo.text=self.text;
    msgInfo.attachmentsJson=self.attachmentsJson;
    msgInfo.createdDate=self.createdDate;
    msgInfo.adminId=self.adminId;
    /*
     新闻，活动的内容也存在这里
     */
    msgInfo.attachContent=self.attachContent;
    msgInfo.isRead=self.isRead;
    msgInfo.fromCustId=self.fromCustId;
    msgInfo.toCustId=self.toCustId;
    msgInfo.fromCustName=self.fromCustName;
    msgInfo.toCustName=self.toCustName;
    
    msgInfo.isShowMessageDate=self.isShowMessageDate;
 
    
    return msgInfo;
    
    
    


}

@end
