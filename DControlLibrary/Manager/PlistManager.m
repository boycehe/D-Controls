//
//  PlistManager.m
//  Hitachi
//
//  Created by Liu Tao on 12-12-24.
//  Copyright (c) 2012年 D-Haus Technology Co.,Ltd. All rights reserved.
//

#import "PlistManager.h"
#import "QuickPath.h"
#import "GlobalDef.h"
#import "BHBase64EncoderDecoder.h"
#import "CtrlStateManager.h"
#import "PacketManager.h"
#import "DCManager.h"
#import "DCManagerTool.H"

@interface PlistManager () {
    int numOfTimer;
    BOOL countingTimer;
}

@property (strong, nonatomic) NSMutableDictionary   *hitachiDictionary;
@property (strong, nonatomic) NSMutableDictionary   *acMapFromAddressToName;
@property (strong, nonatomic) NSMutableDictionary   *acMapFromAddressToPosition;
@property (strong, nonatomic) NSMutableArray        *temporarySceneArray;
@property (strong, nonatomic) NSMutableArray        *temporarySectionArray;
@property (strong, atomic   ) NSMutableDictionary   *updateAcS;
@property (strong, nonatomic) NSTimer               *updateTimer;
@property (strong, nonatomic) NSMutableArray        *temporaryTimerArray;
@property (strong, nonatomic) NSMutableDictionary   *homeDic;
@property (strong,nonatomic ) NSMutableArray        *homeArr;
@property (assign,nonatomic ) int                   currentHomeIndex;



- (void)load;
- (void)save;
- (void)restore;

@end

@implementation PlistManager

@synthesize hitachiDictionary          = _hitachiDictionary;

@synthesize acMapFromAddressToName     = _acMapFromAddressToName;
@synthesize acMapFromAddressToPosition = _acMapFromAddressToPosition;
@synthesize temporarySceneArray        = _temporarySceneArray;

#pragma mark - setter & getter


- (void)sendUpdateCommand {
    
    
    NSMutableArray *addressArray = [NSMutableArray array];
    
    for (int i = 0 ; i < [[self.updateAcS allKeys] count]; i++) {
        //NSLog(@"ac index: %d", [[[self.updateAcS allKeys] objectAtIndex:i] intValue]);
        [addressArray addObject:[[self.updateAcS allKeys] objectAtIndex:i]];
    }
    NSLog(@"update ac state:%lu", (unsigned long)[addressArray count]);
    [[DCManager shareManager].pkManager sendReadAcStateWithAddresses:addressArray];
}



- (NSMutableDictionary *)acMapFromAddressToName {
    if (_acMapFromAddressToName == nil) {
        _acMapFromAddressToName = [NSMutableDictionary dictionary];
        int cnt = [self getDeviceCount];
        for (int i=0; i<cnt; i++) {
            NSNumber *addr = [self getDeviceAddressWithIndex:i];
            NSString *name = [self getDeviceNameWithIndex:i];
            [_acMapFromAddressToName setObject:name forKey:addr];
        }
    }
    return _acMapFromAddressToName;
}

- (NSMutableDictionary *)acMapFromAddressToPosition {
    if (_acMapFromAddressToPosition == nil) {
        _acMapFromAddressToPosition = [NSMutableDictionary dictionary];
        int cnt = [self getDeviceCount];
        for (int i=0; i<cnt; i++) {
            NSNumber *addr = [self getDeviceAddressWithIndex:i];
            [_acMapFromAddressToPosition setObject:[NSNumber numberWithInt:i] forKey:addr];
        }
    }
    return _acMapFromAddressToPosition;
}

- (NSMutableArray *)arrayDeepCopy:(NSMutableArray *)inArray {
    NSMutableArray *outArray;
    NSData *xdata = [NSPropertyListSerialization dataFromPropertyList:inArray format:NSPropertyListBinaryFormat_v1_0 errorDescription:nil];
    outArray = (NSMutableArray *)[NSPropertyListSerialization propertyListFromData:xdata mutabilityOption:NSPropertyListMutableContainersAndLeaves format:nil errorDescription:nil];
    return outArray;
}

- (NSMutableDictionary *)dictionaryDeepCopy:(NSMutableDictionary *)inDic {
    NSMutableDictionary *outDic;
    NSData *xdata = [NSPropertyListSerialization dataFromPropertyList:inDic format:NSPropertyListBinaryFormat_v1_0 errorDescription:nil];
    outDic = (NSMutableDictionary *)[NSPropertyListSerialization propertyListFromData:xdata mutabilityOption:NSPropertyListMutableContainersAndLeaves format:nil errorDescription:nil];
    return outDic;
}

- (NSMutableArray *)temporarySceneArray {
    if (_temporarySceneArray == nil) {
        _temporarySceneArray = [self arrayDeepCopy:[self.hitachiDictionary objectForKey:PLIST_SCENES]];
        //[NSMutableArray arrayWithArray:[self.hitachiDictionary objectForKey:PLIST_SCENES]];
    }
    return _temporarySceneArray;
}

- (NSMutableArray *)temporarySectionArray {
    if (_temporarySectionArray == nil) {
        _temporarySectionArray = [self arrayDeepCopy:[self.hitachiDictionary objectForKey:PLIST_SECTIONS]];
        //[NSMutableArray arrayWithArray:[self.hitachiDictionary objectForKey:PLIST_SECTIONS]];
    }
    return _temporarySectionArray;
}

- (NSMutableArray*)homeArr{

    if (_homeArr == nil) {
        _homeArr = [self arrayDeepCopy:[self.hitachiDictionary objectForKey:PLIST_HOME_KEY]];
    }
    return _homeArr;

}

- (NSMutableArray *)temporaryTimerArray {
    if (_temporaryTimerArray == nil) {
        _temporaryTimerArray = [self arrayDeepCopy:[self.hitachiDictionary objectForKey:PLIST_TIMERS]];
        //[NSMutableArray arrayWithArray:[self.hitachiDictionary objectForKey:PLIST_TIMERS]];
    }
    return _temporaryTimerArray;
}


#pragma mark - private function

- (id)init {
    self = [super init];
    if (self) {
        [self load];
    }
    return self;
}

- (void)check{

    if (self.hitachiDictionary == nil) {
        [self load];
    }

}

- (void)load {
    
    if (self.hitachiDictionary != nil) {
        [self.hitachiDictionary removeAllObjects];
         self.hitachiDictionary = nil;
    }
    
    if (self.updateAcS != nil) {
        [self.updateAcS removeAllObjects];
    }else{
         self.updateAcS = [NSMutableDictionary dictionary];
    }
    _currentHomeIndex = -1;
    self.temporarySceneArray = nil;
    //第一个位置，库目录
    
    if ([DCManager shareManager].managerInfo.custId <=0) {
        return;
    }
    
    NSDictionary *homeDic = [self getHome];
    NSString     *fileName    = [homeDic objectForKey:PLIST_KEY_FileName];
    NSString     *filePath    = [QuickPath getDocumentFilePathWithName:fileName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {//文件存在
        
        NSData *fileData = [[NSFileManager defaultManager] contentsAtPath:filePath];
        self.hitachiDictionary = (NSMutableDictionary *)[NSPropertyListSerialization propertyListFromData:[BHBase64EncoderDecoder customDecode:fileData] mutabilityOption:NSPropertyListMutableContainersAndLeaves format:nil errorDescription:nil];
    
        NSLog(@"LoadManager:%@",self.hitachiDictionary);
        if (self.hitachiDictionary!=nil) {
            [self.hitachiDictionary writeToFile:[QuickPath getDocumentFilePathWithName:@"1.plist"] atomically:YES];
            return;//文件存在且有效，则结束
        }else{
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];//文件存在但无效，则删除之
        }
    }
    
    //库目录的配置文件，不存在 或 存在但无效
    //第二个位置，main bundle
    
    filePath = [QuickPath getMainBundleFilePathWithName:PLIST_FILENAME];
    
    assert(filePath!=nil);
    
    NSData *fileData = [[NSFileManager defaultManager] contentsAtPath:filePath];
    self.hitachiDictionary = (NSMutableDictionary *)[NSPropertyListSerialization propertyListFromData:[BHBase64EncoderDecoder customDecode:fileData] mutabilityOption:NSPropertyListMutableContainersAndLeaves format:nil errorDescription:nil];
    [[self.hitachiDictionary objectForKey:PLIST_HOME_KEY] setObject:fileName forKey:PLIST_KEY_FileName];
  
    NSLog(@"InitLoad:%@",self.hitachiDictionary);
    
    [self save];
}

- (void)save {

    BOOL suc = NO;
    
    
    NSData *xdata = [NSPropertyListSerialization dataFromPropertyList:self.hitachiDictionary format:NSPropertyListBinaryFormat_v1_0 errorDescription:nil];
    
    if (xdata!=nil && xdata.length!=0) {
        
        if ([PLAIN_TEXT_ENABLED boolValue]) {//非加密存储，调试时使用
            NSString *plistPath = [QuickPath getLibraryFilePathWithName:@"hitachi.plist"];
            [xdata writeToFile:plistPath atomically:YES];
        }
        
        NSString *encodedString = [BHBase64EncoderDecoder customEncode:xdata];
        NSData   *encodedData   = [encodedString dataUsingEncoding:NSUTF8StringEncoding];
        NSString *fileName      = [[self getHome] objectForKey:PLIST_KEY_FileName];
        
        NSString *dcPath = [QuickPath getDocumentFilePathWithName:fileName];
        suc = [encodedData writeToFile:dcPath atomically:YES];
    }else{
        
       // [[DCManager shareManager] uploadPlist];
    }
    
    
  
    
    if (!suc) {
     //   [QuickAlert showTitle:NSLocalizedString(TEXT_SETTING_WRITE_FAIL, @"")];
        NSLog(@"(not expected)%@", TEXT_SETTING_WRITE_FAIL);
    }
    
    
}

- (void)restore {
    
    NSString *fileName = [[self getHome] objectForKey:PLIST_KEY_FileName];

  
    NSString *plistPath = [QuickPath getDocumentFilePathWithName:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:plistPath error:nil];
    }
    [self load];
}

#pragma mark - 楼层及房间



- (int)getFloorCount {
    int res = 0;
    NSArray *sectionArr = [self.hitachiDictionary objectForKey:PLIST_SECTIONS];
    res = (int)[sectionArr count];
    return res;
}

- (NSString *)getFloorNameWithIndex:(int)inIndex {
    NSString *res;
    NSArray *sectionArr = [self.hitachiDictionary objectForKey:PLIST_SECTIONS];
    if (inIndex>=0 && inIndex<[sectionArr count]) {
        NSDictionary *sectionDic = [sectionArr objectAtIndex:inIndex];
        res = [sectionDic objectForKey:PLIST_KEY_NAME];
    }
    return res ? res : @"";
}

- (int)getRoomCountWithFloorIndex:(int)inIndex {
    int res = 0;
    NSArray *sectionArr = [self.hitachiDictionary objectForKey:PLIST_SECTIONS];
    if (inIndex>=0 && inIndex<[sectionArr count]) {
        NSDictionary *sectionDic = [sectionArr objectAtIndex:inIndex];
        NSArray *pageArr = [sectionDic objectForKey:PLIST_PAGES];
        res = (int)[pageArr count];
    }
    return res;
}

- (NSString *)getRoomNameAtIndex:(int)roomIndex withFloorIndex:(int)floorIndex {
    NSString *res;
    NSArray *sectionArr = [self.hitachiDictionary objectForKey:PLIST_SECTIONS];
    if (floorIndex>=0 && floorIndex<[sectionArr count]) {
        NSDictionary *sectionDic = [sectionArr objectAtIndex:floorIndex];
        NSArray *pageArr = [sectionDic objectForKey:PLIST_PAGES];
        if (roomIndex>=0 && roomIndex<[pageArr count]) {
            NSDictionary *pageDic = [pageArr objectAtIndex:roomIndex];
            res = [pageDic objectForKey:PLIST_KEY_NAME];
        }
    }
    return res ? res : @"";
}


- (NSDictionary *)getRoomFirstDeviceStateForAcMenuAtIndex:(int)roomIndex withFloorIndex:(int)floorIndex {
    
    NSMutableDictionary *res;//从所有空调的状态中，按照既定规则选取
    //楼层
    NSArray *sectionArr = [self.hitachiDictionary objectForKey:PLIST_SECTIONS];
    
    if (floorIndex>=0 && floorIndex<[sectionArr count]) {
        
        //特定楼层
        NSDictionary *sectionDic = [sectionArr objectAtIndex:floorIndex];
        NSArray *pageArr = [sectionDic objectForKey:PLIST_PAGES];
        
        //特定房间
        if (roomIndex>=0 && roomIndex<[pageArr count]) {
            
            NSDictionary *pageDic        = [pageArr objectAtIndex:roomIndex];
            
            NSArray *sortB = [NSMutableArray arrayWithArray:[pageDic objectForKey:PLIST_ELEMENTS]];
            
            /**
             排序
             */
            
            NSArray *sortedArray = [sortB sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                
                NSComparisonResult result = [obj1 compare:obj2];
                
                if ([obj1 intValue] > [obj2 intValue])
                    result = NSOrderedDescending;
                else if([obj1 intValue] < [obj2 intValue])
                    result = NSOrderedAscending;
                else
                    result = NSOrderedSame;
                
                //NSOrderedAscending = -1L, NSOrderedSame, NSOrderedDescending
                
              //  NSLog(@"NSComparisonResult:%zd",result);
                return result;
            }];
            
          //  NSLog(@"排序后:%@",sortedArray);
            
            NSMutableArray *addressArr   = [NSMutableArray arrayWithArray:sortedArray];
            NSMutableDictionary *showDic = nil;
            
            if ([addressArr count]>0) {
                
                NSDictionary *addrDic           = [[[DCManager shareManager].pManager getDeviceArray] objectAtIndex:[[addressArr objectAtIndex:0] intValue]];
                NSDictionary *currentDic        = [[DCManager shareManager].csManager getAcStateForAcMenuForAddress:[addrDic objectForKey:PLIST_KEY_INDOOR_ADDRESS]];
                
                if (currentDic == nil) {
                    currentDic = [NSMutableDictionary dictionaryWithDictionary:[GlobalDef acInvalidStateDictionary]];
                }
                
                if (showDic == nil) {
                    showDic = [NSMutableDictionary dictionaryWithDictionary:currentDic];
                }
                
            }
            
            
            res = showDic;
            
        }
        
    }
    
    if (res == nil) {
        res = [NSMutableDictionary dictionaryWithDictionary:[GlobalDef acInvalidStateDictionary]];
    }
    return res;
    
    
}


- (NSDictionary *)getRoomStateForAcMenuAtIndex:(int)roomIndex withFloorIndex:(int)floorIndex {
    
    NSMutableDictionary *res;//从所有空调的状态中，按照既定规则选取
    //楼层
    NSArray *sectionArr = [self.hitachiDictionary objectForKey:PLIST_SECTIONS];
    
    if (floorIndex>=0 && floorIndex<[sectionArr count]) {
        
        //特定楼层
        NSDictionary *sectionDic = [sectionArr objectAtIndex:floorIndex];
        NSArray *pageArr = [sectionDic objectForKey:PLIST_PAGES];
        
        //特定房间
        if (roomIndex>=0 && roomIndex<[pageArr count]) {
            
            NSDictionary *pageDic        = [pageArr objectAtIndex:roomIndex];
            
            NSArray *sortB = [NSMutableArray arrayWithArray:[pageDic objectForKey:PLIST_ELEMENTS]];
            
            /**
             排序
             */
            
            NSArray *sortedArray = [sortB sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                
                NSComparisonResult result = [obj1 compare:obj2];
                
                if ([obj1 intValue] > [obj2 intValue])
                    result = NSOrderedDescending;
                else if([obj1 intValue] < [obj2 intValue])
                    result = NSOrderedAscending;
                else
                    result = NSOrderedSame;
                return result;
            }];
        
            NSMutableArray *addressArr   = [NSMutableArray arrayWithArray:sortedArray];

            NSMutableDictionary *showDic = nil;
            NSMutableDictionary *lastDic = nil;
            
            for (int i = 0; i < [addressArr count]; i++) {
                
                NSDictionary *addrDic           = [[[DCManager shareManager].pManager getDeviceArray] objectAtIndex:[[addressArr objectAtIndex:i] intValue]];
                NSDictionary *currentDic        = [[DCManager shareManager].csManager getAcStateForAcMenuForAddress:[addrDic objectForKey:PLIST_KEY_INDOOR_ADDRESS]];
              
                if (currentDic == nil) {
                    currentDic = [NSMutableDictionary dictionaryWithDictionary:[GlobalDef acInvalidStateDictionary]];
                }
                
                if (lastDic == nil) {
                    lastDic = [NSMutableDictionary dictionaryWithDictionary:currentDic];
                    showDic = [NSMutableDictionary dictionaryWithDictionary:lastDic];
                    continue;
                }
                
                BOOL     LastOnOff          = [[lastDic objectForKey:PLIST_AC_ENABLED] boolValue];
                ModeType LastModeType       = [[lastDic objectForKey:PLIST_AC_MODE] intValue];
                WindType LastWindType       = [[lastDic objectForKey:PLIST_AC_FAN] intValue];
                int      LastTemperature    = [[lastDic objectForKey:PLIST_AC_TEMPERATURE] intValue];
                
                BOOL     CurrentOnOff       = [[currentDic objectForKey:PLIST_AC_ENABLED] boolValue];
                ModeType CurrentModeType    = [[currentDic objectForKey:PLIST_AC_MODE] intValue];
                WindType CurrentWindType    = [[currentDic objectForKey:PLIST_AC_FAN] intValue];
                int      CurrentTemperature = [[currentDic objectForKey:PLIST_AC_TEMPERATURE] intValue];
                
                if (LastOnOff || CurrentOnOff) {
                    [lastDic setObject:[NSNumber numberWithBool:YES] forKey:PLIST_AC_ENABLED];
                }
                
                if (LastModeType != CurrentModeType) {
                    [lastDic setObject:[NSNumber numberWithInt:ModeType_Unknow] forKey:PLIST_AC_MODE];
                }
                
                if (LastWindType != CurrentWindType) {
                    [lastDic setObject:[NSNumber numberWithInt:WindType_Unkonw] forKey:PLIST_AC_FAN];
                }
                
                if (LastTemperature != CurrentTemperature) {
                    [lastDic setObject:[NSNumber numberWithInt:BH_Unknow_Temperature] forKey:PLIST_AC_TEMPERATURE];
                }
                
                showDic = [NSMutableDictionary dictionaryWithDictionary:lastDic];
                
            }
            
            res = showDic;
        
        }

    }
    
    if (res == nil) {
        res = [NSMutableDictionary dictionaryWithDictionary:[GlobalDef acInvalidStateDictionary]];
    }
    return res;
}

- (NSArray *)getRoomAcArrayAtIndex:(int)roomIndex withFloorIndex:(int)floorIndex {
    
    NSArray *res; //从所有空调的状态中，选取一个最近更新的
    NSArray *sectionArr = [self.hitachiDictionary objectForKey:PLIST_SECTIONS];
    
    if (floorIndex>=0 && floorIndex<[sectionArr count]) {
        
        NSDictionary *sectionDic = [sectionArr objectAtIndex:floorIndex];
        NSArray *pageArr         = [sectionDic objectForKey:PLIST_PAGES];
        if (roomIndex>=0 && roomIndex<[pageArr count]) {
            NSDictionary *pageDic = [pageArr objectAtIndex:roomIndex];
            res = [pageDic objectForKey:PLIST_ELEMENTS];
       }
    }
    
    
    
    if (res == nil) {
        res = [NSArray array];
    }
    return res;
    
}
- (void)readStateForAllRoom{
    
    NSMutableArray *addressArray = [NSMutableArray array];
    
    for (int i = 0; i < [self getFloorCount]; i++) {
        for (int j = 0; j < [self getRoomCountWithFloorIndex:i]; j++) {
            NSArray *addr = [self getRoomAcArrayAtIndex:j withFloorIndex:i];
            for (int i = 0; i < [addr count]; i++) {
                
                if ([addressArray containsObject:[addr objectAtIndex:i]]) {
                    continue;
                }
                [addressArray addObject:[addr objectAtIndex:i]];
            }
        }
    }
    
    NSLog(@"readStateForAllRoom");
  
    
    [[DCManager shareManager].pkManager sendReadAcStateWithAddresses:addressArray];
    [self addStateRefreshPlanForArray:addressArray];
    
}


- (void)addStateRefreshPlanForArray:(NSMutableArray *)addressArray {
    for (int i = 0; i < [addressArray count]; i++) {
        [self.updateAcS setObject:@"1" forKey:[addressArray objectAtIndex:i]];
    }
}
#pragma mark - 设置

- (int)getDeviceStateWithIndex:(int)index{

    int  state = -1;
    
    NSArray *arr = [self.hitachiDictionary objectForKey:PLIST_CONNECTION];
    
    if (index >=0 && index <[arr count]) {
        NSDictionary *dic = [arr objectAtIndex:index];
        state = [[dic objectForKey:PLIST_KEY_STATE] intValue];
        
    }
    
    return state;

}

- (NSDictionary*)getConnectionDic:(long long)connectionSN{
    
    NSArray *arr = [self.hitachiDictionary objectForKey:PLIST_CONNECTION];

    NSDictionary *tDic = nil;
    
    for (int i = 0; i < [arr count]; i++) {
        NSDictionary *dic          = [arr objectAtIndex:i];
        if ([[dic objectForKey:PLIST_KEY_INDOOR_SN] longLongValue] == connectionSN )
            tDic = dic;
    }
    
    return tDic;
}




- (NSDictionary*)getConnectionWithIndex:(int)index{

    NSMutableDictionary *dic = nil;
    NSArray *arr = [self.hitachiDictionary objectForKey:PLIST_CONNECTION];
    
    if (index >=0 && index < [arr count]) {
        
        dic = [arr objectAtIndex:index];
    }
    
    return dic;
}

- (void)setConnectionLocationWithLocation:(CLLocationCoordinate2D)location andIndex:(int)index{

    NSArray *arr = [self.hitachiDictionary objectForKey:PLIST_CONNECTION];
    
    NSMutableArray *inArr = [NSMutableArray array];
    
    if (index >=0 && index <[arr count]) {
        NSDictionary *dic = [arr objectAtIndex:index];
        
        NSMutableDictionary *inDic = [NSMutableDictionary dictionaryWithDictionary:dic];
        
        [inDic setObject:[NSNumber numberWithDouble:location.latitude] forKey:PLIST_KEY_Latitude];
        [inDic setObject:[NSNumber numberWithDouble:location.longitude] forKey:PLIST_KEY_Longitude];
        
        [inArr addObjectsFromArray:arr];
        [inArr replaceObjectAtIndex:index withObject:inDic];
    }
    
    [self.hitachiDictionary setObject:inArr forKey:PLIST_CONNECTION];
    [self save];

}

- (CLLocationCoordinate2D)getLocationWithIndex:(int)index{

    NSArray *arr = [self.hitachiDictionary objectForKey:PLIST_CONNECTION];
    
 
    CLLocationCoordinate2D  location;
    location.longitude = 0.0f;
    location.latitude = 0.0f;
    
    if (index >=0 && index <[arr count]) {
        
        NSDictionary *dic = [arr objectAtIndex:index];
        location.longitude = [[dic objectForKey:PLIST_KEY_Longitude] doubleValue];
        location.latitude = [[dic objectForKey:PLIST_KEY_Latitude] doubleValue];
        
    }
    
    
    return location;
    
}


- (NSString*)getConnectionNameWithIndex:(int)index{
    
    NSString *res = @"";

    NSArray *arr = [self.hitachiDictionary objectForKey:PLIST_CONNECTION];
    
    if (![arr isKindOfClass:[NSArray class]]) {
        return @"";
    }
    
    if (index >=0 && index <[arr count]) {
        NSDictionary *dic = [arr objectAtIndex:index];
        res = [dic objectForKey:PLIST_KEY_NAME];
    
    }

    return res;
}


- (NSString*)getServerAddressWithIndex:(int)index{

    NSString *res = @"";
    
    NSArray *arr = [self.hitachiDictionary objectForKey:PLIST_CONNECTION];
    
    if (index >=0 && index <[arr count]) {
        NSDictionary *dic = [arr objectAtIndex:index];
        res = [dic objectForKey:PLIST_KEY_ADDRESS];
        
    }
    
    
    
    return res;

}

- (NSString*)getServerAddress2WithIndex:(int)index{
    
    NSString *res = @"";
    
    NSArray *arr = [self.hitachiDictionary objectForKey:PLIST_CONNECTION];
    
    if (index >=0 && index <[arr count]) {
        NSDictionary *dic = [arr objectAtIndex:index];
        res = [dic objectForKey:@"ip"];
        
    }
    
    
    
    return res;
    
}

- (NSString *)getServerAddress {
    
    NSString *res = @"";
    
    NSArray *arr = [self.hitachiDictionary objectForKey:PLIST_CONNECTION];
    
    for (int i = 0; i < [arr count]; i++) {
        NSDictionary *dic = [arr objectAtIndex:i];
    //    if ([[dic objectForKey:PLIST_KEY_STATE] intValue] == 1) {
            
            res = [dic objectForKey:PLIST_KEY_ADDRESS];
    //         break;
            
     //   }
    }
    
    return res;
    
}

- (NSInteger)getConnectionCount{

     NSArray *arr = [self.hitachiDictionary objectForKey:PLIST_CONNECTION];
    return [arr count];

}

-(NSString*)getServerMac{
    
    NSString *res = @"";
    
    NSArray *arr = [self.hitachiDictionary objectForKey:PLIST_CONNECTION];
    
    for (int i = 0; i < [arr count]; i++) {
        NSDictionary *dic = [arr objectAtIndex:i];
      //  if ([[dic objectForKey:PLIST_KEY_STATE] intValue] == 1) {
            res = [dic objectForKey:PLIST_KEY_INDOOR_CSSMAC];
            break;
       // }
    }
    
    return res;


}

-(NSString*)getServerSN{
    
    NSString *res = @"";
    
    NSArray *arr = [self.hitachiDictionary objectForKey:PLIST_CONNECTION];
    
    if (![arr isKindOfClass:[NSArray class]]) {
        return @"";
    }
    
    for (int i = 0; i < [arr count]; i++) {
        NSDictionary *dic = [arr objectAtIndex:i];
        res = [dic objectForKey:PLIST_KEY_INDOOR_SN];
        break;
    }
    
    return res;
    
}

-(NSString*)getConnectionSNIndex:(int)index{
    
    NSString *res = @"";
    
    NSArray *arr = [self.hitachiDictionary objectForKey:PLIST_CONNECTION];
    
    if (index < [arr count]) {
        res = [[arr objectAtIndex:index] objectForKey:PLIST_KEY_INDOOR_SN];
    }
    
    return res;
    
}


- (void)addOrReplaceConnectionWithDic:(NSDictionary*)dic{
    
    NSArray *arr           = [self.hitachiDictionary objectForKey:PLIST_CONNECTION];
    NSDictionary *existDic = [NSMutableDictionary dictionary];
    int index              = -1;

    for (int i = 0; i < [arr count]; i++) {
        
     NSDictionary *tempDic = [arr objectAtIndex:i];
        
        if ([[dic objectForKey:PLIST_KEY_INDOOR_SN] longLongValue] == [[tempDic objectForKey:PLIST_KEY_INDOOR_SN] longLongValue]) {
            existDic = [NSMutableDictionary dictionaryWithDictionary:tempDic];
            index = i;
            break;
        }
        
    
    }
    
    

//    if ([dic objectForKey:PLIST_KEY_STATE] != nil) {
//        
//        [existDic setValue:[dic objectForKey:PLIST_KEY_STATE] forKey:PLIST_KEY_STATE];
//    }
   
    
    if ([dic objectForKey:PLIST_KEY_CUSTID] != nil) {
        // NSLog(@"Not Exist");
        [existDic setValue:[dic objectForKey:PLIST_KEY_CUSTID] forKey:PLIST_KEY_CUSTID];
    }
    
    
    
    if ([dic objectForKey:PLIST_KEY_INDOOR_SN] != nil) {
        [existDic setValue:[dic objectForKey:PLIST_KEY_INDOOR_SN] forKey:PLIST_KEY_INDOOR_SN];
    }
    
    if ([dic objectForKey:PLIST_KEY_INDOOR_CSSMAC] != nil) {
        [existDic setValue:[dic objectForKey:PLIST_KEY_INDOOR_CSSMAC] forKey:PLIST_KEY_INDOOR_CSSMAC];
    }
    
    if ([dic objectForKey:PLIST_KEY_NAME] != nil) {
        [existDic setValue:[dic objectForKey:PLIST_KEY_NAME] forKey:PLIST_KEY_NAME];
    }
    
    if ([dic objectForKey:PLIST_KEY_ADDRESS] != nil) {
        [existDic setValue:[dic objectForKey:PLIST_KEY_ADDRESS] forKey:PLIST_KEY_ADDRESS];
    }
    
    
    if ([dic objectForKey:PLIST_KEY_CreatorCustId] != nil) {
        [existDic setValue:[dic objectForKey:PLIST_KEY_CreatorCustId] forKey:PLIST_KEY_CreatorCustId];
    }
    
    if ([dic objectForKey:PLIST_KEY_CreatorCustName] != nil) {
        [existDic setValue:[dic objectForKey:PLIST_KEY_CreatorCustName] forKey:PLIST_KEY_CreatorCustName];
    }
    
    if ([dic objectForKey:PLIST_KEY_CustTotalCount] != nil) {
        [existDic setValue:[dic objectForKey:PLIST_KEY_CustTotalCount] forKey:PLIST_KEY_CustTotalCount];
    }
    
    if ([dic objectForKey:PLIST_KEY_MaxCustCount] != nil) {
        [existDic setValue:[dic objectForKey:PLIST_KEY_MaxCustCount] forKey:PLIST_KEY_MaxCustCount];
    }
    
    NSMutableArray *inArr = [NSMutableArray arrayWithArray:arr];
    
    if (index <0) {
        NSLog(@"Not Exist");
        [inArr addObject:existDic];
    }else{
        NSLog(@"Exist");
        [inArr replaceObjectAtIndex:index withObject:existDic];
    }
    
    [self.hitachiDictionary setObject:inArr forKey:PLIST_CONNECTION];
    
    [self save];
    
    
    
}




- (BOOL)getSoundEnabled{
    BOOL res = 0;
    NSDictionary *dic = [self.hitachiDictionary objectForKey:PLIST_SETTINGS];
    res = [[dic objectForKey:PLIST_KEY_SOUND_ENABLED] boolValue];
    return res;
}




- (NSString *)getAuthcode {
    //    NSString *res = [[self.hitachiDictionary objectForKey:PLIST_SETTINGS] objectForKey:PLIST_KEY_AUTHCODE_STRING];
    //    return res ? res : @"";
    NSMutableArray *xarr = [[self.hitachiDictionary objectForKey:PLIST_SETTINGS] objectForKey:PLIST_KEY_AUTHCODE_HISTORY];
    NSString *res;
    if ([xarr count] > 0) {
        res = [xarr objectAtIndex:0];
    }
    return res ? res : @"";
}

- (void)setAuthocodeString:(NSString *)authcode {
    if (authcode == nil) {
        return;
    }
    NSMutableArray *xarr = [[self.hitachiDictionary objectForKey:PLIST_SETTINGS] objectForKey:PLIST_KEY_AUTHCODE_HISTORY];
    if (xarr == nil) {
        xarr = [NSMutableArray array];
    }
    int cnt = (int)[xarr count];
    int i;
    for (i = 0; i < cnt; i++) {
        if ([authcode isEqualToString:[xarr objectAtIndex:i]]) {
            if (i != 0) {
                [xarr exchangeObjectAtIndex:i withObjectAtIndex:0];
            }
            break;
        }
    }
    if (i == cnt) {
        if (authcode != nil) {
            [xarr insertObject:authcode atIndex:0];
        }
        if ([xarr count] > 3) {
            [xarr removeObjectAtIndex:3];
        }
    }
    [[self.hitachiDictionary objectForKey:PLIST_SETTINGS] setObject:xarr forKey:PLIST_KEY_AUTHCODE_HISTORY];
    //[[self.hitachiDictionary objectForKey:PLIST_SETTINGS] setObject:authcode forKey:PLIST_KEY_AUTHCODE_STRING];
    [self save];
}
#pragma mark - 场景
- (int)getSceneCount {
    int res = 0;
    res = (int)[self.temporarySceneArray count];
    return res;
}
- (NSString *)getSceneNameWithIndex:(int)inIndex {
    NSString *res;
    if (inIndex>=0 && inIndex<[self.temporarySceneArray count]) {
        NSDictionary *dic = [self.temporarySceneArray objectAtIndex:inIndex];
        res = [dic objectForKey:PLIST_KEY_NAME];
    }
    return res ? res : @"";
}

- (BOOL)hasSameNameScene:(NSString *)sceneName exceptIndex:(int)exceptIndex{
    
    NSArray *sceneArr = self.temporarySceneArray;
    
    BOOL hasSame = NO;
    
    for (int i =0; i < [sceneArr count]; i++) {
        
        if (i == exceptIndex) {
            continue;
        }
        
        NSDictionary *dic = [self.temporarySceneArray objectAtIndex:i];
        NSString *name = [dic objectForKey:PLIST_KEY_NAME];
        if ([name isEqualToString:sceneName]) {
            hasSame = YES;
            break;
        }
        
        
    }
    
    return hasSame;
    
}

- (BOOL)hasSameNameScene:(NSString *)sceneName{

    NSArray *sceneArr = self.temporarySceneArray;
    
    BOOL hasSame = NO;
    
    for (int i =0; i < [sceneArr count]; i++) {
        NSDictionary *dic = [self.temporarySceneArray objectAtIndex:i];
        NSString *name = [dic objectForKey:PLIST_KEY_NAME];
        if ([name isEqualToString:sceneName]) {
            hasSame = YES;
            break;
        }
        
        
    }
    
    return hasSame;

}

- (void)addNewSceneWithDic:(NSDictionary*)dic{

    [self.temporarySceneArray addObject:dic];

}



- (BOOL)replaceSceneWithDic:(NSDictionary*)dic withIndex:(int)index{

    if (index >=0 && index < [self.temporarySceneArray count]) {
        [self.temporarySceneArray replaceObjectAtIndex:index withObject:dic];
        return YES;
    }
    
    return NO;

}

- (void)setSceneName:(NSString *)inString withIndex:(int)inIndex {
    if (inIndex>=0 && inIndex<[self.temporarySceneArray count]) {
        [[self.temporarySceneArray objectAtIndex:inIndex] setObject:inString forKey:PLIST_KEY_NAME];
    }
}



- (BOOL)checkTemporarySceneIndex:(int)inIndex {
    BOOL suc = NO;
    if (inIndex >= 0 && inIndex < [self.temporarySceneArray count]) {
        suc = YES;
    }
    return suc;
}

- (void)deleteSceneAtIndex:(int)inIndex {
    if ([self checkTemporarySceneIndex:inIndex]) {
    }
    else return;
    [self.temporarySceneArray removeObjectAtIndex:inIndex];
    [[self.hitachiDictionary objectForKey:PLIST_SCENES] removeObjectAtIndex:inIndex];
    [self save];
}
- (void)clearTemporarySceneArray {
    [self.temporarySceneArray removeAllObjects];
    self.temporarySceneArray = nil;
}

- (NSDictionary*)getSceneWithSceneIndex:(int)inIndex{

    if (inIndex>=0 && inIndex<[self.temporarySceneArray count]) {
        
        NSDictionary *dic1 = [self.temporarySceneArray objectAtIndex:inIndex];
        
        
        
        return dic1;
        
    }
    
    return nil;
    

}

- (NSArray*)getCommandArrWithSceneIndex:(int)inIndex{

    if (inIndex>=0 && inIndex<[self.temporarySceneArray count]) {
        
        NSDictionary *dic1 = [self.temporarySceneArray objectAtIndex:inIndex];
        
        NSArray *cmdArr = [dic1 objectForKey:PLIST_SCENE_COMMANDS];
        
        return cmdArr;

    }
    
    return nil;
    
    
    

}

- (NSDictionary*)getCommandWithSceneIndex:(int)inIndex andRoomIndex:(int)roomIndex andFloorIndex:(int)floorIndex{

    NSDictionary *dic = nil;
    
    if (inIndex>=0 && inIndex<[self.temporarySceneArray count]) {
        
        NSDictionary *dic1 = [self.temporarySceneArray objectAtIndex:inIndex];
        
        NSArray *cmdArr = [dic1 objectForKey:PLIST_SCENE_COMMANDS];
        
        for (int i = 0; i < [cmdArr count]; i++) {
            
            NSDictionary *dic2 = [cmdArr objectAtIndex:i];
            
            NSDictionary *addrDic = [dic2 objectForKey:PLIST_KEY_ADDRESS];
            
            if ([addrDic count]>0&&[[addrDic objectForKey:PLIST_PAGES] intValue] == roomIndex && [[addrDic objectForKey:PLIST_SECTIONS] intValue] == floorIndex) {
                dic = dic2;
                break;
            }
        
        }
    
    }
    

    return dic;
}

- (NSInteger)sendCommandWithIndex:(int)inIndex {
    
    NSInteger count = 0;

    if (inIndex>=0 && inIndex<[self.temporarySceneArray count]) {
        
        NSDictionary *dic = [self.temporarySceneArray objectAtIndex:inIndex];
        NSArray *arr      = [dic objectForKey:PLIST_SCENE_COMMANDS];
        count             = [arr count];
        
     //   R.waitSceneFeedDic = [NSMutableDictionary new];
        
        for (int i=0; i<[arr count]; i++) {
            NSDictionary *currentDic = [arr objectAtIndex:i];
            [self sendCommandWithDic:currentDic];
            //[self performSelector:@selector(sendCommandWithDic:) withObject:currentDic afterDelay:i];
        }
        
    }
    
    return count;

}


- (void)sendCommandWithDic:(NSDictionary*)currentDic{
    
    NSNumber *addressNum = [NSNumber numberWithInt:[self getIndoorAddressWithIndex:[[currentDic objectForKey:PLIST_KEY_ADDRESS] intValue]]];
    NSArray *addresses = [NSArray arrayWithObject:addressNum];
    
    BOOL onoff         = [[currentDic objectForKey:PLIST_AC_ENABLED] boolValue];
    int  mode          = [[currentDic objectForKey:PLIST_AC_MODE] intValue];
    int  fan           = [[currentDic objectForKey:PLIST_AC_FAN] intValue];
    int  temperature   = [[currentDic objectForKey:PLIST_AC_TEMPERATURE] intValue];
    
    [[DCManager shareManager].pkManager sendCommandsWithOnoff:onoff mode:mode fan:fan temperature:temperature forAddressArray:addresses];
    
}


#pragma mark - 定时
- (int)getTimerCount {
    int res = 0;
    res = (int)[self.temporaryTimerArray count];
    return res;
}



- (BOOL)checkTimerIndex:(int)inIndex {
    BOOL suc = NO;
    if (inIndex >= 0 && inIndex < [self.temporaryTimerArray count] /*&& inIndex < [[self.hitachiDictionary objectForKey:PLIST_TIMERS] count]*/) {
        suc = YES;
    }
    return suc;
}
- (void)setTimerEnabeld:(BOOL)inBool withIndex:(int)inIndex {
    
    if (![self checkTimerIndex:inIndex])
        return;

    [[self.temporaryTimerArray objectAtIndex:inIndex] setObject:[NSNumber numberWithBool:inBool] forKey:PLIST_KEY_TIMER_ENABLED];
    
    if (inIndex >= [[self.hitachiDictionary objectForKey:PLIST_TIMERS] count])
        return;
    
    [[[self.hitachiDictionary objectForKey: PLIST_TIMERS] objectAtIndex:inIndex] setObject:[NSNumber numberWithBool:inBool] forKey:PLIST_KEY_TIMER_ENABLED];
    
    NSMutableDictionary *timerDic = [self.temporaryTimerArray objectAtIndex:inIndex];
    NSNumber *currentID = [timerDic objectForKey:PLIST_KEY_TIMER_ID];
    if (currentID) {
        
        int timerID        = [currentID intValue];
        BOOL timerenabled  = [[timerDic objectForKey:PLIST_KEY_TIMER_ENABLED] boolValue];
        int hour           = [[timerDic objectForKey:PLIST_KEY_HOUR] intValue];
        int minute         = [[timerDic objectForKey:PLIST_KEY_MINUTE] intValue];
        BOOL repeatenabled = [[timerDic objectForKey:PLIST_KEY_REPEAT] boolValue];
        BOOL onoff         = [[timerDic objectForKey:PLIST_AC_ENABLED] boolValue];
        int mode           = [[timerDic objectForKey:PLIST_AC_MODE] intValue];
        int fan            = [[timerDic objectForKey:PLIST_AC_FAN] intValue];
        int temperature    = [[timerDic objectForKey:PLIST_AC_TEMPERATURE] intValue];
        NSString *name     = [timerDic objectForKey:PLIST_KEY_NAME];
        
        
        NSMutableArray *addressArr = [NSMutableArray arrayWithArray:[timerDic objectForKey:PLIST_KEY_ADDRESS]];
        /*
        NSArray *arr               = [timerDic objectForKey:PLIST_KEY_ADDRESS];
        
        for (int i = 0; i < [arr count]; i++) {
            
            NSDictionary *dic = [arr objectAtIndex:i];
            int  roomIndex = [[dic objectForKey:PLIST_PAGES] intValue];
            int  floorIndex = [[dic objectForKey:PLIST_SECTIONS] intValue];
            [addressArr addObjectsFromArray:[self getRoomAcArrayAtIndex:roomIndex withFloorIndex:floorIndex]];
            
        }
        */
        [[DCManager shareManager].pkManager sendTimerEditWithTimerID:timerID enabled:timerenabled hour:hour minute:minute week:[timerDic objectForKey:PLIST_KEY_WEEK] repeat:repeatenabled addresses:addressArr onoff:onoff mode:mode fan:fan temperature:temperature name:name];
    }
    
    [self save];

}


- (void)setTimerDetailEnabeld:(BOOL)inBool withIndex:(int)inIndex {
    if ([self checkTimerIndex:inIndex]) {
    }
    else return;
    [[self.temporaryTimerArray objectAtIndex:inIndex] setObject:[NSNumber numberWithBool:inBool] forKey:PLIST_KEY_DETAIL_ENABLED];
}

- (void)setTimerStateDictionary:(NSMutableDictionary *)stateDic withIndex:(int)inIndex {
    if (inIndex>=0 && inIndex<[self.temporaryTimerArray count]) {
        NSMutableDictionary *dic = [self.temporaryTimerArray objectAtIndex:inIndex];
        [dic setObject:[stateDic objectForKey:PLIST_AC_ENABLED] forKey:PLIST_AC_ENABLED];
        [dic setObject:[stateDic objectForKey:PLIST_AC_MODE] forKey:PLIST_AC_MODE];
        [dic setObject:[stateDic objectForKey:PLIST_AC_FAN] forKey:PLIST_AC_FAN];
        [dic setObject:[stateDic objectForKey:PLIST_AC_TEMPERATURE] forKey:PLIST_AC_TEMPERATURE];
        [dic setObject:[stateDic objectForKey:PLIST_KEY_ADDRESS] forKey:PLIST_KEY_ADDRESS];
    }
}

- (NSDictionary*)getTimerDicWithIndex:(int)index{

    NSMutableDictionary *dic = nil;
    if (index>=0 && index<[self.temporaryTimerArray count]) {
       dic = [self.temporaryTimerArray objectAtIndex:index];
       
    }
    
    return dic;

}

- (void)addNewTimerStateDic:(NSDictionary*)dic{

    if (dic != nil) {
        [self.temporaryTimerArray addObject:dic];
    }

}


- (void)clearTimer {
    //NSLog(@"clear");
    [self.temporaryTimerArray removeAllObjects];
     self.temporaryTimerArray = nil;
}



- (BOOL)isChangedTempTimer:(NSDictionary *)tempTimerDic withOriginalTimer:(NSDictionary *)timerDic {
    BOOL changed = [[timerDic objectForKey:PLIST_KEY_HOUR] intValue] == [[tempTimerDic objectForKey:PLIST_KEY_HOUR] intValue] ? NO : YES;
    if (!changed) {
        changed = [[timerDic objectForKey:PLIST_KEY_MINUTE] intValue] == [[tempTimerDic objectForKey:PLIST_KEY_MINUTE] intValue] ? NO : YES;
    }
    if (!changed) {
        NSString *name1 = [timerDic objectForKey:PLIST_KEY_NAME];
        NSString *name2 = [tempTimerDic objectForKey:PLIST_KEY_NAME];
        changed = [name1 isEqualToString:name2] ? NO : YES;
    }
    if (!changed) {
        changed = [[timerDic objectForKey:PLIST_KEY_TIMER_ENABLED] intValue] == [[tempTimerDic objectForKey:PLIST_KEY_TIMER_ENABLED] intValue] ? NO : YES;
    }
    if (!changed) {
        changed = [[timerDic objectForKey:PLIST_KEY_REPEAT] intValue] == [[tempTimerDic objectForKey:PLIST_KEY_REPEAT] intValue] ? NO : YES;
    }
    if (!changed) {
        changed = [[timerDic objectForKey:PLIST_AC_ENABLED] intValue] == [[tempTimerDic objectForKey:PLIST_AC_ENABLED] intValue] ? NO : YES;
    }
    if (!changed) {
        changed = [[timerDic objectForKey:PLIST_AC_MODE] intValue] == [[tempTimerDic objectForKey:PLIST_AC_MODE] intValue] ? NO : YES;
    }
    if (!changed) {
        changed = [[timerDic objectForKey:PLIST_AC_FAN] intValue] == [[tempTimerDic objectForKey:PLIST_AC_FAN] intValue] ? NO : YES;
    }
    if (!changed) {
        changed = [[timerDic objectForKey:PLIST_AC_TEMPERATURE] intValue] == [[tempTimerDic objectForKey:PLIST_AC_TEMPERATURE] intValue] ? NO : YES;
    }
    if (!changed) {//星期的个数
        changed = [[timerDic objectForKey:PLIST_KEY_WEEK] count] == [[tempTimerDic objectForKey:PLIST_KEY_WEEK] count] ? NO : YES;
    }
    if (!changed) {//受控空调的个数
        changed = [[timerDic objectForKey:PLIST_KEY_ADDRESS] count] == [[tempTimerDic objectForKey:PLIST_KEY_ADDRESS] count] ? NO : YES;
    }
    if (!changed) {
        NSArray *tempWeekArray = [tempTimerDic objectForKey:PLIST_KEY_WEEK];
        NSArray *weekArray = [timerDic objectForKey:PLIST_KEY_WEEK];//一个的每一项，在另一个都存在
        for (int xi = 0; xi < [tempWeekArray count]; xi++) {
            NSNumber *tempWeekNum = [tempWeekArray objectAtIndex:xi];
            BOOL found = NO;
            for (int xj = 0; xj < [weekArray count]; xj++) {
                NSNumber *weekNum = [weekArray objectAtIndex:xj];
                if ([tempWeekNum intValue] == [weekNum intValue]) {
                    found = YES;
                    break;
                }
            }
            if (!found) {
                changed = YES;
                break;
            }
        }
    }
    
    if (!changed) {
        NSArray *tempWeekArray = [tempTimerDic objectForKey:PLIST_KEY_ADDRESS];
        NSArray *weekArray = [timerDic objectForKey:PLIST_KEY_ADDRESS];//一个的每一项，在另一个都存在
        for (int xi = 0; xi < [tempWeekArray count]; xi++) {
            NSNumber *tempWeekNum = [tempWeekArray objectAtIndex:xi];
            BOOL found = NO;
            for (int xj = 0; xj < [weekArray count]; xj++) {
                NSNumber *weekNum = [weekArray objectAtIndex:xj];
                if ([tempWeekNum intValue] == [weekNum intValue]) {
                    found = YES;
                    break;
                }
            }
            if (!found) {
                changed = YES;
                break;
            }
        }
    }
    
    return changed;
}




- (void)deleteTimerAtIndex:(int)inIndex {
    if ([self checkTimerIndex:inIndex]) {
    }
    else return;
    int tid = [[[self.temporaryTimerArray objectAtIndex:inIndex] objectForKey:PLIST_KEY_TIMER_ID] intValue];
    [self.temporaryTimerArray removeObjectAtIndex:inIndex];
    NSMutableArray *timerArray = [self.hitachiDictionary objectForKey:PLIST_TIMERS];
    if (inIndex >= 0 && inIndex < [timerArray count]) {
        
    }
    else return;
    int nid = [[[timerArray objectAtIndex:inIndex] objectForKey:PLIST_KEY_TIMER_ID] intValue];
    if (tid == nid) {
        //[[self.hitachiDictionary objectForKey:PLIST_TIMERS] removeObjectAtIndex:inIndex];
        //[self save];
        //弹出正在同步的窗口
        [[DCManager shareManager].pkManager sendTimerDeleteWithTimerID:nid];
    }
}

- (void)setTimerWithTimerID:(int)timerID enabled:(BOOL)timerEnabled hour:(int)hour minute:(int)minute week:(NSArray *)weekArray repeat:(BOOL)repeatEnabled addresses:(NSArray *)addrArray onoff:(BOOL)onoff mode:(int)mode fan:(int)fan temperature:(int)temperature name:(NSString *)name{
    //已经取消假反馈，此数据必由服务器返回
    //此数据中没有detailEnabled和name信息，需要从temp中读取
    //其他值，无论temp和原始数据，均被重置为服务器数据
    
  //  mode = [GlobalDef getModeFromCommunicationToInterface:mode];
  //  fan = [GlobalDef getFanFromCommunicationToInterface:fan];
    
    NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
    [dataDic setObject:name forKey:PLIST_KEY_NAME];
    [dataDic setObject:[NSNumber numberWithInt:timerID] forKey:PLIST_KEY_TIMER_ID];
    [dataDic setObject:[NSNumber numberWithBool:timerEnabled] forKey:PLIST_KEY_TIMER_ENABLED];
    [dataDic setObject:[NSNumber numberWithInt:hour] forKey:PLIST_KEY_HOUR];
    [dataDic setObject:[NSNumber numberWithInt:minute] forKey:PLIST_KEY_MINUTE];
    [dataDic setObject:weekArray forKey:PLIST_KEY_WEEK];
    [dataDic setObject:[NSNumber numberWithBool:repeatEnabled] forKey:PLIST_KEY_REPEAT];
    [dataDic setObject:addrArray forKey:PLIST_KEY_ADDRESS];
    [dataDic setObject:[NSNumber numberWithBool:onoff] forKey:PLIST_AC_ENABLED];
    [dataDic setObject:[NSNumber numberWithInt:mode] forKey:PLIST_AC_MODE];
    [dataDic setObject:[NSNumber numberWithInt:fan] forKey:PLIST_AC_FAN];
    [dataDic setObject:[NSNumber numberWithInt:temperature] forKey:PLIST_AC_TEMPERATURE];
    
    BOOL found = NO;
    BOOL changed = NO;
    NSMutableArray *timerArray = [self.hitachiDictionary objectForKey:PLIST_TIMERS];
    for (int i = 0; i < [timerArray count]; i++) {
        NSMutableDictionary *timerDic = [timerArray objectAtIndex:i];
        NSNumber *currentID = [timerDic objectForKey:PLIST_KEY_TIMER_ID];
        if (currentID != nil) {
            int tid = [currentID intValue];
            if (tid == timerID) {
                found = YES;
                changed = [self isChangedTempTimer:dataDic withOriginalTimer:timerDic];
                if (changed) {
                    [timerArray replaceObjectAtIndex:i withObject:dataDic];
                }
                break;
            }
            else if (tid > timerID){
                found = YES;
                if (dataDic != nil) {
                    [timerArray insertObject:dataDic atIndex:i];
                }
                
                break;
            }
        }
    }
    if (!found) {
        [timerArray addObject:dataDic];
    }
    
    if (countingTimer) {
        int cnt = (int)[timerArray count];
        NSLog(@"timer count: %d", cnt);
        if (cnt >= numOfTimer) {
            //[self resetTimerNum];
            //发消息
           // [[DCManager shareManager] dispatchMessage:MESSAGE_TIMER_RECEIVED_ALL];
        }
    }
    
    if (found && !changed) {
        return;
    }
    
    [self save];
    [self clearTimer];
  //  [[DCManager shareManager] dispatchMessage:MESSAGE_INTERFACE_UPDATE_TIMER_STATE_CHANGED];
    
    
}

- (void)deleteTimerWithID:(int)timerID {
//    for (int i = 0; i < [self.temporaryTimerArray count]; i++) {
//        NSMutableDictionary *timerDic = [self.temporaryTimerArray objectAtIndex:i];
//        NSNumber *currentID = [timerDic objectForKey:PLIST_KEY_TIMER_ID];
//        if (currentID != nil && [currentID intValue] == timerID) {
//            [self.temporaryTimerArray removeObjectAtIndex:i];
//            break;
//        }
//    }
    
    NSMutableArray *timerArray = [self.hitachiDictionary objectForKey:PLIST_TIMERS];
    for (int i = 0; i < [timerArray count]; i++) {
        NSMutableDictionary *timerDic = [timerArray objectAtIndex:i];
        NSNumber *currentID = [timerDic objectForKey:PLIST_KEY_TIMER_ID];
        if (currentID !=nil && [currentID intValue] == timerID) {
            [timerArray removeObjectAtIndex:i];
            break;
        }
    }
    [self save];
    [self clearTimer];
   // [[DCManager shareManager] dispatchMessage:MESSAGE_INTERFACE_UPDATE_TIMER_STATE_CHANGED];
}
- (void)clearInvalidNewTimerWithReason:(NSString *)promptString {//若定时器数量超限，则更改一定未应用到原始数据
    BOOL found = NO;
    
    for (int i = 0; i < [self.temporaryTimerArray count]; i++) {
        NSMutableDictionary *timerDic = [self.temporaryTimerArray objectAtIndex:i];
        NSNumber *currentID = [timerDic objectForKey:PLIST_KEY_TIMER_ID];
        if (currentID == nil) {
            [self.temporaryTimerArray removeObjectAtIndex:i];
            found = YES;
            break;
        }
    }

    /*
    if (found) {
        [QuickAlert showLocalizedTitle:promptString];
    }

    [[DCManager shareManager] dispatchMessage:MESSAGE_INTERFACE_UPDATE_TIMER_STATE_CHANGED];
     */
}
- (void)readTimerStateAll {
   
    [self resetTimerNum];
    [[DCManager shareManager].pkManager sendTimerQueryCount];
    
}
- (void)timerTriggerWithTimerID:(int)timerID {
    BOOL match = NO;
    NSMutableArray *timerArray = [self.hitachiDictionary objectForKey:PLIST_TIMERS];
    
    
    for (int i = 0; i < [timerArray count]; i++) {
        NSMutableDictionary *timerDic = [timerArray objectAtIndex:i];
        NSNumber *currentID = [timerDic objectForKey:PLIST_KEY_TIMER_ID];
        
        if (currentID != nil && [currentID intValue] == timerID) {
            match = YES;
            NSString *name = [timerDic objectForKey:PLIST_KEY_NAME];
   
          //  [self.myalert showAutoDisappearWithTitle:NSLocalizedString(TEXT_PROMPT_TIMER_OPERATED, @"") message:name cancelButton:NSLocalizedString(TEXT_DONE, @"") withTime:3.0];
            [[DCManager shareManager].pkManager sendTimerQueryWithTimerID:timerID];
            break;
        }
    }
    
    
    if (!match) {
        
       // [self.myalert showAutoDisappearWithTitle:NSLocalizedString(TEXT_PROMPT_TIMER_OPERATED, @"") message:[NSString stringWithFormat:@"%@%02d\n%@%02d", NSLocalizedString(@"室外机地址", @""), timerID/256, NSLocalizedString(@"室内机地址", @""),timerID%256] cancelButton:NSLocalizedString(TEXT_DONE, @"") withTime:3.0];
        [[DCManager shareManager].pkManager sendTimerQueryWithTimerID:timerID];
        
    }
}
- (void)timerReceiveNum:(int)count {
    //NSLog(@"counting: %d", countingTimer);
    if (!countingTimer) {
        numOfTimer = count;
        countingTimer = YES;
        if (numOfTimer == 0) {
           // [[DCManager shareManager].pManager clearTimer];
            [[DCManager shareManager].pManager.temporaryTimerArray removeAllObjects];
            [[DCManager shareManager].pManager saveEditSection];
           // [[DCManager shareManager] dispatchMessage:MESSAGE_TIMER_RECEIVED_ALL];
        }
        else {
            [[DCManager shareManager].pkManager sendTimerQueryAll];
        }
    }
}

- (void)resetTimerNum {
    numOfTimer = -1;
    countingTimer = NO;
    NSLog(@"reset");
}
#pragma mark - 空调地址配置
- (NSString *)getAcNameWithAddress:(NSNumber *)inNum {//there should be a map from address to name, and update when devices changing
    NSString *res;    
    if (inNum) {
        res = [self.acMapFromAddressToName objectForKey:inNum];
    }
    return res ? res : @"";
}

- (int)getPositionWithIndexAddress:(NSNumber *)inNum {
    int res = -1;
    if (inNum && [inNum intValue] >= 0 && [inNum intValue] < 256) {
        res = [[self.acMapFromAddressToPosition objectForKey:inNum] intValue];
    }
    return res;
}


- (int)getDeviceCount {
    int res = 0;
    NSArray *arr = [self.hitachiDictionary objectForKey:PLIST_DEVICES];
    res = (int)[arr count];
    return res;
}
- (NSString *)getDeviceNameWithIndex:(int)inIndex {
    NSString *res;
    NSArray *arr = [self.hitachiDictionary objectForKey:PLIST_DEVICES];
    if (inIndex>=0 && inIndex<[arr count]) {
        NSDictionary *dic = [arr objectAtIndex:inIndex];
        res = [dic objectForKey:PLIST_KEY_NAME];
    }
    return res ? res : @"";
}

- (BOOL)isExistSameDeviceName:(NSString*)name{

    BOOL isSame = NO;
    
    NSArray *arr = [self.hitachiDictionary objectForKey:PLIST_DEVICES];
    
    
    for ( int i =0; i < [arr count]; i++) {
    
        NSDictionary *dic = [arr objectAtIndex:i];
        NSString *existName = [dic objectForKey:PLIST_KEY_NAME];
        if ([existName isEqualToString:name]) {
            isSame = YES;
            break;
        }
        
        
    }
    
    return isSame;

    

}

- (BOOL)setDeviceNameWithIndex:(int)inIndex andName:(NSString*)name{
    
    BOOL isSuccess = NO;

    NSArray *arr = [self.hitachiDictionary objectForKey:PLIST_DEVICES];
    
    NSMutableArray *inArr =[NSMutableArray arrayWithArray:arr];
    
    NSMutableDictionary *rDic = nil;
    
    if (inIndex>=0 && inIndex<[arr count]) {
        
        rDic = [NSMutableDictionary dictionaryWithDictionary:[arr objectAtIndex:inIndex]];
        [rDic setObject:name forKey:PLIST_KEY_NAME];
        [inArr replaceObjectAtIndex:inIndex withObject:rDic];
    
        [self setDeviceArray:inArr];
        
        isSuccess = YES;
        
    }
    return isSuccess;
}

- (NSNumber *)getDeviceAddressWithIndex:(int)inIndex {
    NSNumber *res;
    NSArray *arr = [self.hitachiDictionary objectForKey:PLIST_DEVICES];
    if (inIndex>=0 && inIndex<[arr count]) {
        NSDictionary *dic = [arr objectAtIndex:inIndex];
        int indoor = [[dic objectForKey:PLIST_KEY_INDOOR_ADDRESS] intValue];
        int outdoor = [[dic objectForKey:PLIST_KEY_OUTDOOR_ADDRESS] intValue];
        res = [NSNumber numberWithInt:outdoor*16 + indoor];
    }
    return res ? res : [NSNumber numberWithInt:-1];
}

- (NSDictionary*)getDeviceDicWithIndoorAddress:(int)indoorAddress{

    NSArray *arr = [self.hitachiDictionary objectForKey:PLIST_DEVICES];
    
    for (int i = 0; i < [arr count]; i++) {
        
        NSDictionary *dic = [arr objectAtIndex:i];
        
        if ([[dic objectForKey:PLIST_KEY_INDOOR_ADDRESS] intValue] == indoorAddress) {
            
            return dic;
        }
        
        
    }
    
    return nil;


}


- (int)getIndoorIndexWithIndex:(int)inIndex{
    
    int res = -1;
    NSArray *arr = [self.hitachiDictionary objectForKey:PLIST_DEVICES];
    if (inIndex>=0 && inIndex<[arr count]) {
        NSDictionary *dic = [arr objectAtIndex:inIndex];
        res = [[dic objectForKey:PLIST_KEY_INDOOR_INDEX] intValue];
        
    }
    return res;

}

- (int)getIndoorAddressWithIndex:(int)inIndex{

    int res = -1;
    NSArray *arr = [self.hitachiDictionary objectForKey:PLIST_DEVICES];
    if (inIndex>=0 && inIndex<[arr count]) {
        NSDictionary *dic = [arr objectAtIndex:inIndex];
       res = [[dic objectForKey:PLIST_KEY_INDOOR_ADDRESS] intValue];
         
    }
    return res;
}

- (NSNumber *)getDeviceIndoorAddressWithIndex:(int)inIndex {
    NSNumber *res;
    NSArray *arr = [self.hitachiDictionary objectForKey:PLIST_DEVICES];
    if (inIndex>=0 && inIndex<[arr count]) {
        NSDictionary *dic = [arr objectAtIndex:inIndex];
        res = [dic objectForKey:PLIST_KEY_INDOOR_ADDRESS];
    }
    return res ? res : [NSNumber numberWithInt:-1];
}

- (NSDictionary*)getDeviceDic:(int)index{

    NSArray *arr = [self.hitachiDictionary objectForKey:PLIST_DEVICES];
    
    NSDictionary *dic = nil;
    
    if (index < [arr count]) {
        dic = [[self.hitachiDictionary objectForKey:PLIST_DEVICES] objectAtIndex:index];
    }

    
    return dic;
}

- (NSMutableArray *)getDeviceArray {
    return [self.hitachiDictionary objectForKey:PLIST_DEVICES];
}
- (void)cleanInvalidAddresses {
    //scenes
    NSMutableArray *sceneArray = [self.hitachiDictionary objectForKey:PLIST_SCENES];
    for (int i=0; i<[sceneArray count]; i++) {
        NSMutableDictionary *sceneDic = [sceneArray objectAtIndex:i];
        NSMutableArray *commandArray = [sceneDic objectForKey:PLIST_SCENE_COMMANDS];
        for (int j=0; j<[commandArray count]; j++) {
            NSMutableDictionary *commandDic = [commandArray objectAtIndex:j];
            NSNumber *address = [commandDic objectForKey:PLIST_KEY_ADDRESS];
            if (address) {
                if (![self.acMapFromAddressToName objectForKey:address]) {
                    [commandArray removeObjectAtIndex:j];
                    j--;
                }
            }
            else {
                [commandArray removeObjectAtIndex:j];
                j--;
            }
        }
    }
    //sections
    NSMutableArray *sectionArray = [self.hitachiDictionary objectForKey:PLIST_SECTIONS];
    for (int i=0; i<[sectionArray count]; i++) {
        NSMutableDictionary *sectionDic = [sectionArray objectAtIndex:i];
        NSMutableArray *pageArray = [sectionDic objectForKey:PLIST_PAGES];
        for (int j=0; j<[pageArray count]; j++) {
            NSMutableDictionary *pageDic = [pageArray objectAtIndex:j];
            NSMutableArray *elementArray = [pageDic objectForKey:PLIST_ELEMENTS];
            for (int k=0; k<[elementArray count]; k++) {
                NSNumber *address = [elementArray objectAtIndex:k];
                if (![self.acMapFromAddressToName objectForKey:address]) {
                    [elementArray removeObjectAtIndex:k];
                    k--;
                }
            }
        }
    }
    //timers
    NSMutableArray *timerArray = [self.hitachiDictionary objectForKey:PLIST_TIMERS];
    for (int i=0; i<[timerArray count]; i++) {
        NSMutableDictionary *timerDic = [timerArray objectAtIndex:i];
        NSMutableArray *addressArray = [timerDic objectForKey:PLIST_KEY_ADDRESS];
        for (int j=0; j<[addressArray count]; j++) {
            NSNumber *address = [addressArray objectAtIndex:j];
            if (![self.acMapFromAddressToName objectForKey:address]) {
                [addressArray removeObjectAtIndex:j];
                j--;
            }
        }
    }
    
    [self save];
}

- (void)addOrReplaceDeviceArr:(NSArray*)nArr{
    
    
    NSArray *oArr = [self.hitachiDictionary objectForKey:PLIST_DEVICES];
    
    
    if ([nArr count] != [oArr count]) {
        
        [self.temporarySceneArray removeAllObjects];
        self.temporarySceneArray = nil;
        [self.temporarySectionArray removeAllObjects];
        self.temporarySectionArray = nil;
        [self.temporaryTimerArray removeAllObjects];
        self.temporaryTimerArray = nil;
        [self.hitachiDictionary setObject:[NSArray array] forKey:PLIST_SCENES];
        [self.hitachiDictionary setObject:[NSArray array] forKey:PLIST_TIMERS];
        [self.hitachiDictionary setObject:[NSArray array] forKey:PLIST_SECTIONS];
        [self saveEditSection];
       // [[NSNotificationCenter defaultCenter] postNotificationName:k_Notification_ChangeRoomName object:nil];
       // [[NSNotificationCenter defaultCenter] postNotificationName:BH_Notification_DeviceRefrsh  object:nil];

    }
    
    
    
    NSMutableDictionary *nDic = nil;
    NSMutableDictionary *oDic = nil;
    
    for (int m = 0; m < [nArr count]; m++) {
        
      nDic = [nArr objectAtIndex:m];
        
        for (int n = 0; n < [oArr count]; n++) {
            
            oDic = [oArr objectAtIndex:n];
            
            if ([[oDic objectForKey:PLIST_KEY_INDOOR_ADDRESS] longValue] == [[nDic objectForKey:PLIST_KEY_INDOOR_ADDRESS] longValue] && ![[oDic objectForKey:PLIST_KEY_NAME] isEqualToString:[nDic objectForKey:PLIST_KEY_NAME]]) {
                [nDic setObject:[oDic objectForKey:PLIST_KEY_NAME] forKey:PLIST_KEY_NAME];
            }
        
            
        }
    
    }
    
   
    
    [self setDeviceArray:nArr];
    

}

- (void)setDeviceArray:(NSArray *)inArr {

    [self.hitachiDictionary setObject:inArr forKey:PLIST_DEVICES];
    //up date map to name dictionary
    [self.acMapFromAddressToName removeAllObjects];
    self.acMapFromAddressToName = nil;
    [self.acMapFromAddressToPosition removeAllObjects];
     self.acMapFromAddressToPosition = nil;
    //clean invalid address in all the plist
    //TODO::::下边注释代码
   // [self cleanInvalidAddresses];//to do
    [self save];
   // [[DCManager shareManager].pkManager sendDevicesData];
}
- (void)logAllDeviceAddress {
    int cnt = [self getDeviceCount];
    for (int i = 0; i < cnt; i++) {
        NSLog(@"__device_%d : [%@]", i, [self getDeviceAddressWithIndex:i]);
    }
}

#pragma mark - 楼层及房间编辑
- (void)clearEditSection {
    
    [self.temporarySectionArray removeAllObjects];
     self.temporarySectionArray = nil;
    
}
- (void)saveEditSection {
    [self.hitachiDictionary setObject:[NSMutableArray arrayWithArray:self.temporarySectionArray] forKey:PLIST_SECTIONS];
    [self.hitachiDictionary setObject:[NSMutableArray arrayWithArray:self.temporaryTimerArray] forKey:PLIST_TIMERS];
    [self.hitachiDictionary setObject:[NSMutableArray arrayWithArray:self.temporarySceneArray] forKey:PLIST_SCENES];
    [self clearEditSection];
    [self save];
}

- (NSArray*)getAllWarningInRoomAtIndex:(int)roomIndex withFloorIndex:(int)floorIndex{

    NSMutableArray *warningArr = [NSMutableArray new];
    
   
    NSArray *sectionArr = [self.hitachiDictionary objectForKey:PLIST_SECTIONS];
    
    if (floorIndex>=0 && floorIndex<[sectionArr count]) {
        
        NSDictionary *sectionDic = [sectionArr objectAtIndex:floorIndex];
        
        NSArray *pageArr = [sectionDic objectForKey:PLIST_PAGES];
        
        if (roomIndex>=0 && roomIndex<[pageArr count]) {
            
            NSDictionary *pageDic = [pageArr objectAtIndex:roomIndex];
            NSArray      *addressArr   = [pageDic objectForKey:PLIST_ELEMENTS];
            
            for (int i = 0; i < [addressArr count]; i++) {
                
                NSNumber *addr = [NSNumber numberWithInt:[[DCManager shareManager].pManager getIndoorAddressWithIndex:[[addressArr objectAtIndex:i] intValue]]];
                NSDictionary *currentDic = [[DCManager shareManager].csManager getAcStateForAddress:addr];
                NSNumber *warning = [currentDic objectForKey:PLIST_AC_WARNING];
                if (warning != nil && [warning intValue] > 0) {
                    
                    NSDictionary *dd =@{PLIST_AC_WARNING:warning,PLIST_KEY_INDOOR_INDEX:[addressArr objectAtIndex:i]};
                   
                    [warningArr addObject:dd];
                }
            }
        }
        
        
    }

    
    
    
    return warningArr;


}

- (int)getRoomWaringAtIndex:(int)roomIndex withFloorIndex:(int)floorIndex {
    int res = 0;
    NSArray *sectionArr = [self.hitachiDictionary objectForKey:PLIST_SECTIONS];
    
    if (floorIndex>=0 && floorIndex<[sectionArr count]) {
        
        NSDictionary *sectionDic = [sectionArr objectAtIndex:floorIndex];
        
        NSArray *pageArr = [sectionDic objectForKey:PLIST_PAGES];
        
        if (roomIndex>=0 && roomIndex<[pageArr count]) {
            
            NSDictionary *pageDic = [pageArr objectAtIndex:roomIndex];
            NSArray *addressArr = [pageDic objectForKey:PLIST_ELEMENTS];
            
            for (int i = 0; i < [addressArr count]; i++) {
                
                NSNumber *addr = [NSNumber numberWithInt:[[DCManager shareManager].pManager getIndoorAddressWithIndex:[[addressArr objectAtIndex:i] intValue]]];
                NSDictionary *currentDic = [[DCManager shareManager].csManager getAcStateForAddress:addr];
                NSNumber *warning = [currentDic objectForKey:PLIST_AC_WARNING];
                if (warning != nil && [warning intValue] > 0) {
                    res = [warning intValue];
                    break;
                }
            }
        }
        
        
    }
    
    
    return res;
}


- (void)editFloorName:(NSString*)floorName Index:(int)index{

    NSMutableDictionary *newSectionDic = [NSMutableDictionary dictionary];
    NSDictionary *dic                  = nil;
    
    if (index >=0 && index < [self.temporarySectionArray count]) {
        dic = [self.temporarySectionArray objectAtIndex:index];
    }
    
    if (dic == nil)
        return;
    
    [newSectionDic addEntriesFromDictionary:dic];
    [newSectionDic setObject:floorName forKey:PLIST_KEY_NAME];
   // [newSectionDic setObject:[NSMutableArray array] forKey:PLIST_PAGES];

    [self.temporarySectionArray replaceObjectAtIndex:index withObject:newSectionDic];
    
    [self saveEditSection];
    
}

- (void)addNewFloor {
    NSMutableDictionary *newSectionDic = [NSMutableDictionary dictionary];
    [newSectionDic setObject:NSLocalizedString(TEXT_CUSTOM_FLOOR_NAME, @"") forKey:PLIST_KEY_NAME];    
    [newSectionDic setObject:[NSMutableArray array] forKey:PLIST_PAGES];
    [self.temporarySectionArray addObject:newSectionDic];
}

- (void)addNewFloorWithName:(NSString*)floorName{

    NSMutableDictionary *newSectionDic = [NSMutableDictionary dictionary];
    [newSectionDic setObject:floorName forKey:PLIST_KEY_NAME];
    [newSectionDic setObject:[NSMutableArray array] forKey:PLIST_PAGES];
    [self.temporarySectionArray addObject:newSectionDic];
    [self saveEditSection];

}

- (void)deleteFloorAtIndex:(int)floorIndex {
    if (floorIndex>=0 && floorIndex<[self.temporarySectionArray count]) {
        [self.temporarySectionArray removeObjectAtIndex:floorIndex];
    }
}

- (void)addNewRoomForFloorWithIndex:(int)floorIndex andName:(NSString*)roomName {
    if (floorIndex>=0 && floorIndex<[self.temporarySectionArray count]) {
        NSMutableDictionary *sectionDic = [self.temporarySectionArray objectAtIndex:floorIndex];
        NSMutableArray *pageArr = [sectionDic objectForKey:PLIST_PAGES];
        NSMutableDictionary *newPageDic = [NSMutableDictionary dictionary];
        [newPageDic setObject:NSLocalizedString(TEXT_CUSTOM_ROOM_NAME, roomName) forKey:PLIST_KEY_NAME];
        [newPageDic setObject:[NSMutableArray array] forKey:PLIST_ELEMENTS];
        [pageArr addObject:newPageDic];
    }
}


- (void)addNewRoomForFloorWithIndex:(int)floorIndex {
    if (floorIndex>=0 && floorIndex<[self.temporarySectionArray count]) {
        NSMutableDictionary *sectionDic = [self.temporarySectionArray objectAtIndex:floorIndex];
        NSMutableArray *pageArr = [sectionDic objectForKey:PLIST_PAGES];
        NSMutableDictionary *newPageDic = [NSMutableDictionary dictionary];
        [newPageDic setObject:NSLocalizedString(TEXT_CUSTOM_ROOM_NAME, @"") forKey:PLIST_KEY_NAME];
        [newPageDic setObject:[NSMutableArray array] forKey:PLIST_ELEMENTS];
        [pageArr addObject:newPageDic];
    }
}
- (void)deleteRoomAtIndex:(int)roomIndex withFloorIndex:(int)floorIndex {
    if (floorIndex>=0&&floorIndex < [self.temporarySectionArray count]) {
        NSMutableDictionary *sectionDic = [self.temporarySectionArray objectAtIndex:floorIndex];
        NSMutableArray *pageArr = [sectionDic objectForKey:PLIST_PAGES];
        if (roomIndex>=0 && roomIndex<[pageArr count]) {
            [pageArr removeObjectAtIndex:roomIndex];
        }
    }
    
    
}
- (NSDictionary *)getRoomDicAtIndex:(int)roomIndex withFloorIndex:(int)floorIndex {
    NSDictionary *res;
    if (floorIndex>=0&&floorIndex < [self.temporarySectionArray count]) {
        NSMutableDictionary *sectionDic = [self.temporarySectionArray objectAtIndex:floorIndex];
        NSMutableArray *pageArr = [sectionDic objectForKey:PLIST_PAGES];
        if (roomIndex>=0 && roomIndex<[pageArr count]) {
            res = [pageArr objectAtIndex:roomIndex];
        }
    }
    return res;
}
- (void)insertRoomDic:(NSDictionary *)roomDic atIndex:(int)roomIndex withFloorIndex:(int)floorIndex {
    if (roomDic) {
        if (floorIndex>=0&&floorIndex < [self.temporarySectionArray count]) {
            NSMutableDictionary *sectionDic = [self.temporarySectionArray objectAtIndex:floorIndex];
            NSMutableArray *pageArr = [sectionDic objectForKey:PLIST_PAGES];
            if (roomDic != nil) {
                 [pageArr insertObject:roomDic atIndex:roomIndex];
            }
           
        }
    }
}


- (void)setName:(NSString *)nameStr withRoomIndex:(int)roomIndex withFloorIndex:(int)floorIndex {
    if (floorIndex>=0&&floorIndex < [self.temporarySectionArray count]) {
        NSMutableDictionary *sectionDic = [self.temporarySectionArray objectAtIndex:floorIndex];
        NSMutableArray *pageArr = [sectionDic objectForKey:PLIST_PAGES];
        if (roomIndex>=0 && roomIndex<[pageArr count]) {
            NSMutableDictionary *pageDic = [pageArr objectAtIndex:roomIndex];
            [pageDic setObject:nameStr forKey:PLIST_KEY_NAME];
        }
    }
}

- (void)setElementsArray:(NSArray *)elementArray withRoomIndex:(int)roomIndex withFloorIndex:(int)floorIndex {
    if (floorIndex>=0&&floorIndex < [self.temporarySectionArray count]) {
        NSMutableDictionary *sectionDic = [self.temporarySectionArray objectAtIndex:floorIndex];
        NSMutableArray *pageArr = [sectionDic objectForKey:PLIST_PAGES];
        if (roomIndex>=0 && roomIndex<[pageArr count]) {
            NSMutableDictionary *pageDic = [pageArr objectAtIndex:roomIndex];
            [pageDic setObject:[NSArray arrayWithArray:elementArray] forKey:PLIST_ELEMENTS];
        }
    }
}


- (void)playButtonSound {
    if ([self getSoundEnabled]) {
       // [self.playSound playClickSound];
    }
}


#pragma mark --- Boyce New Method

- (void)loadHomeInfo {

    if (_homeDic != nil)
        return;

    //第一个位置，库目录
    NSString *filePath = [QuickPath getDocumentFilePathWithName:PLIST_HOMEPATH];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        //文件存在
        NSData *fileData = [[NSFileManager defaultManager] contentsAtPath:filePath];
        self.homeDic = (NSMutableDictionary *)[NSPropertyListSerialization propertyListFromData:[BHBase64EncoderDecoder customDecode:fileData] mutabilityOption:NSPropertyListMutableContainersAndLeaves format:nil errorDescription:nil];
        if (self.homeDic!=nil) {
            return;//文件存在且有效，则结束
        }else{
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];//文件存在但无效，则删除之
        }
    }
    
    //库目录的配置文件，不存在 或 存在但无效
    //第二个位置，main bundle
    filePath = [QuickPath getMainBundleFilePathWithName:PLIST_HOMEPATH];
    NSLog(@"____HomePath:%@",filePath);
    assert(filePath!=nil);
    NSData *fileData = [[NSFileManager defaultManager] contentsAtPath:filePath];
    self.homeDic = (NSMutableDictionary *)[NSPropertyListSerialization propertyListFromData:[BHBase64EncoderDecoder customDecode:fileData] mutabilityOption:NSPropertyListMutableContainersAndLeaves format:nil errorDescription:nil];
    [self saveHomeInfo];
}

- (void)saveHomeInfo {
    
    BOOL suc = NO;
    NSData *xdata = [NSPropertyListSerialization dataFromPropertyList:self.homeDic format:NSPropertyListBinaryFormat_v1_0 errorDescription:nil];
    
    if (xdata!=nil && xdata.length!=0) {
        
        if ([PLAIN_TEXT_ENABLED boolValue]) {//非加密存储，调试时使用
            NSString *plistPath = [QuickPath getLibraryFilePathWithName:@"homeInfo.plist"];
            [xdata writeToFile:plistPath atomically:YES];
        }
        
        NSString *encodedString = [BHBase64EncoderDecoder customEncode:xdata];
        NSData *encodedData = [encodedString dataUsingEncoding:NSUTF8StringEncoding];
        
      
        NSString *dcPath = [QuickPath getDocumentFilePathWithName:PLIST_HOMEPATH];
        suc = [encodedData writeToFile:dcPath atomically:YES];
    }
    
    if (!suc) {
      //  [QuickAlert showTitle:NSLocalizedString(TEXT_SETTING_WRITE_FAIL, @"")];
        NSLog(@"(not expected)%@", TEXT_SETTING_WRITE_FAIL);
    }
    
    
}


////楼层


- (NSArray*)getAllFloor{

    NSArray *sectionArr = [self.hitachiDictionary objectForKey:PLIST_SECTIONS];
    return sectionArr;

    
}


- (void)setAllFloor:(NSArray*)floorArr{

    [self.hitachiDictionary setObject:floorArr forKey:PLIST_SECTIONS];
    [self saveEditSection];

}

/*
 根据楼层号，添加
 */

- (NSMutableDictionary*)generateNewRoom:(int)floorIndex andDeviceIndex:(int)deviceIndex{

    
    NSMutableDictionary *newPageDic = [NSMutableDictionary dictionary];
    
    NSNumber *roomId = [self getPlusRoomId];
    [newPageDic setObject:roomId forKey:ROOM_ID_KEY];
    [newPageDic setObject:[NSString stringWithFormat:@"新建房间%@",roomId] forKey:PLIST_KEY_NAME];
    [newPageDic setObject:[NSArray arrayWithObject:[NSNumber numberWithInt:deviceIndex]] forKey:PLIST_ELEMENTS];
    
    return newPageDic;

    
    
}

- (NSMutableDictionary*)addNewRoomWithFloor:(int)floorIndex andDeviceIndex:(int)deviceIndex{

    NSMutableDictionary *newPageDic = nil;
    
    if (floorIndex>=0 && floorIndex<[self.temporarySectionArray count]) {
        
        NSMutableDictionary *sectionDic = [self.temporarySectionArray objectAtIndex:floorIndex];
        NSMutableArray *pageArr = [sectionDic objectForKey:PLIST_PAGES];
        
        [pageArr addObject:[self generateNewRoom:floorIndex andDeviceIndex:deviceIndex]];
        
    }

    return newPageDic;
}

- (NSNumber*)getPlusRoomId{

    NSNumber *roomId = [[NSUserDefaults standardUserDefaults] objectForKey:ROOM_ID_DEF];
    
    if (roomId == nil) {
        
        roomId = [NSNumber numberWithInt:RoomBaseId];
        
    }else{
        
        int mm = [roomId intValue];
        mm++;
        roomId = [NSNumber numberWithInt:mm];
        
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:roomId forKey:ROOM_ID_DEF];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return roomId;

}

- (NSMutableArray*)getAllRoomWithFloorIndex:(int)floorIndex{

    NSMutableArray *pageArr = nil;
    NSArray *sectionArr = [self.hitachiDictionary objectForKey:PLIST_SECTIONS];
    
    if (floorIndex>=0 && floorIndex<[sectionArr count]) {
        NSDictionary *sectionDic = [sectionArr objectAtIndex:floorIndex];
        
        if ([sectionDic objectForKey:PLIST_PAGES] != nil) {
            pageArr = [NSMutableArray arrayWithArray:[sectionDic objectForKey:PLIST_PAGES]];
        }
       
    }
   
    
    return pageArr;
}




- (long long)getCreateCustIdDeviceIndex:(int)deviceIndex{
    
    NSArray *arr = [self.hitachiDictionary objectForKey:PLIST_CONNECTION];
    
    if ([arr count] <= deviceIndex)
        return NO;
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[arr objectAtIndex:deviceIndex]];
    
    return [[dic objectForKey:PLIST_KEY_CreatorCustId] longLongValue];

}


- (void)setCreateCustId:(int)createCustId andCreateCustName:(NSString*)custName{

    NSArray *arr = [self.hitachiDictionary objectForKey:PLIST_CONNECTION];
    
    if ([arr count]>0) {
    
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[arr objectAtIndex:0]];
        
        [dic setObject:IntToNumber(createCustId) forKey:PLIST_KEY_CreatorCustId];
        if (custName != nil) {
            [dic setObject:custName forKey:PLIST_KEY_CreatorCustName];
        }
        
        
        NSMutableArray *inArr = [NSMutableArray arrayWithArray:arr];
        [inArr replaceObjectAtIndex:0 withObject:dic];
        
        [self.hitachiDictionary setObject:inArr forKey:PLIST_CONNECTION];
        
      //  [[DCManager shareManager] dispatchMessage:BH_Notification_ChangeConnectNmae];
        
        [self save];
        
    }
    
    
    



}

- (BOOL)setConnectionName:(NSString*)name andIndex:(int)deviceIndex{

    NSArray *arr = [self.hitachiDictionary objectForKey:PLIST_CONNECTION];
    
     if ([arr count] <= deviceIndex)
         return NO;
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[arr objectAtIndex:deviceIndex]];
    
    [dic setObject:name forKey:PLIST_KEY_NAME];
    
    NSMutableArray *inArr = [NSMutableArray arrayWithArray:arr];
    [inArr replaceObjectAtIndex:deviceIndex withObject:dic];
    
    [self.hitachiDictionary setObject:inArr forKey:PLIST_CONNECTION];
    
   // [[DCManager shareManager] dispatchMessage:BH_Notification_ChangeConnectNmae];
    
    [self save];
    
    return YES;
}

- (BOOL)deleteteConnectionIndex:(int)deviceIndex{

    NSArray *arr = [self.hitachiDictionary objectForKey:PLIST_CONNECTION];
    
    if ([arr count] <= deviceIndex)
        return NO;
    
    NSMutableArray *inArr = [NSMutableArray arrayWithArray:arr];
    [inArr removeObjectAtIndex:deviceIndex];
    
    [self.hitachiDictionary setObject:inArr forKey:PLIST_CONNECTION];
    
   // [[DCManager shareManager] dispatchMessage:BH_Notification_DeleteConnectionNmae];
    
    [self.temporarySectionArray removeAllObjects];
    [self.temporaryTimerArray removeAllObjects];
    [self.temporarySceneArray removeAllObjects];
    [self.hitachiDictionary setObject:[NSArray array] forKey:PLIST_DEVICES];
    [self saveEditSection];
    
    return YES;


}

- (NSString*)getCSSIpAddress{

    NSString *res = @"";
    
    NSArray *arr = [self.hitachiDictionary objectForKey:PLIST_CONNECTION];
    
    if (![arr isKindOfClass:[NSArray class]]) {
        return nil;
    }
    
    for (int i = 0; i < [arr count]; i++) {
        NSDictionary *dic = [arr objectAtIndex:i];
     //   if ([[dic objectForKey:PLIST_KEY_STATE] intValue] == 1) {
            
            res = [dic objectForKey:PLIST_KEY_ADDRESS];
     //       break;
            
     //   }
    }


    return res;
}


//- (void)setStateDic:(NSDictionary*)dic withRoomIndex:(int)roomIndex andFloorIndex:(int)floorIndex{
//
//    if (floorIndex>=0&&floorIndex < [self.temporarySectionArray count]) {
//        
//        NSMutableDictionary *sectionDic = [self.temporarySectionArray objectAtIndex:floorIndex];
//        NSMutableArray *pageArr = [sectionDic objectForKey:PLIST_PAGES];
//        if (roomIndex>=0 && roomIndex<[pageArr count]) {
//            NSMutableDictionary *pageDic = [pageArr objectAtIndex:roomIndex];
//            [pageDic setObject:dic forKey:PLIST_KEY_STATE];
//        }
//        
//    }
//
//
//}


- (NSDictionary*)readRoomSettingStateWithRoomIndex:(int)roomIndex andFloorIndex:(int)floorIndex{

    if (floorIndex>=0&&floorIndex < [self.temporarySectionArray count]) {
        NSMutableDictionary *sectionDic = [self.temporarySectionArray objectAtIndex:floorIndex];
        NSMutableArray *pageArr = [sectionDic objectForKey:PLIST_PAGES];
        if (roomIndex>=0 && roomIndex<[pageArr count]) {
            NSMutableDictionary *pageDic = [pageArr objectAtIndex:roomIndex];
           
            return [pageDic objectForKey:PLIST_KEY_STATE];
            
        }
    }

    return nil;

}

- (void)addHomeWithDic:(NSDictionary*)dic MustSave:(BOOL)mustSave{
    
    NSString *addName       = [dic objectForKey:PLIST_KEY_NAME];
    NSMutableArray *homeArr = [NSMutableArray arrayWithArray:[self getHomeArr]];
    
    BOOL isExist = NO;
    
    for (int i = 0; i < [homeArr count]; i++) {
        
        NSDictionary *dic1 = [homeArr objectAtIndex:i];
        NSString *homeName = [dic1 objectForKey:PLIST_KEY_NAME];
        
        if ([addName isEqualToString:homeName]) {
            isExist = YES;
            if (!mustSave) {
                [homeArr replaceObjectAtIndex:i withObject:dic];
            }

            break;
        }
        
    }
    
    if (!isExist) {
        [homeArr addObject:dic];
    }else if(mustSave){
        
        NSString *homeName = [dic objectForKey:PLIST_KEY_NAME];
        NSMutableDictionary *homeDic = [NSMutableDictionary dictionaryWithDictionary:dic];
        [homeDic setObject:[homeName stringByAppendingString:@"1"] forKey:PLIST_KEY_NAME];
        [homeArr addObject:homeDic];
    }
    
    
    
  //  [[NSUserDefaults standardUserDefaults] setObject:homeArr forKey:[NSString stringWithFormat:@"%zd%@",[DCManager shareManager].managerInfo.custId,BH_SaveData_HomeDicArr]];
   // [[NSUserDefaults standardUserDefaults] synchronize];
    
}


- (void)addHomeWithDic:(NSDictionary*)dic{
    
    NSString *addName = [dic objectForKey:PLIST_KEY_NAME];

    NSMutableArray *homeArr = [NSMutableArray arrayWithArray:[self getHomeArr]];
   
    BOOL isExist = NO;
    
    for (int i = 0; i < [homeArr count]; i++) {
        
        NSDictionary *dic1 = [homeArr objectAtIndex:i];
        NSString *homeName = [dic1 objectForKey:PLIST_KEY_NAME];
        
        if ([addName isEqualToString:homeName]) {
            [homeArr replaceObjectAtIndex:i withObject:dic];
            isExist = YES;
            break;
        }
        
    }
    
    if (!isExist) {
        [homeArr addObject:dic];
    }
    
   // [[NSUserDefaults standardUserDefaults] setObject:homeArr forKey:[NSString stringWithFormat:@"%zd%@",[DCManager shareManager].managerInfo.custId,BH_SaveData_HomeDicArr]];
  //  [[NSUserDefaults standardUserDefaults] synchronize];

}

- (void)addHomeWithConnection:(NSDictionary*)conDic{

    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:[conDic objectForKey:PLIST_KEY_NAME] forKey:PLIST_KEY_NAME];
     NSString *fileName = [[DCManagerTool randomString] stringByAppendingString:@".dc"];
    [dic setObject:fileName forKey:PLIST_KEY_FileName];
    
    NSMutableArray *homeArr = [NSMutableArray arrayWithArray:[self getHomeArr]];
    [homeArr addObject:dic];
    
  //  [[NSUserDefaults standardUserDefaults] setObject:homeArr forKey:[NSString stringWithFormat:@"%zd%@",[DCManager shareManager].managerInfo.custId,BH_SaveData_HomeDicArr]];
  //  [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self generateFileWithHomeDic:dic andConDic:conDic];

}



- (void)generateFileWithHomeDic:(NSDictionary*)homeDic andConDic:(NSDictionary*)conDic{
    
    NSString *filePath = [QuickPath getMainBundleFilePathWithName:PLIST_FILENAME];
    
    assert(filePath!=nil);
    
    NSData *fileData = [[NSFileManager defaultManager] contentsAtPath:filePath];
    NSMutableDictionary  *iDic = (NSMutableDictionary *)[NSPropertyListSerialization propertyListFromData:[BHBase64EncoderDecoder customDecode:fileData] mutabilityOption:NSPropertyListMutableContainersAndLeaves format:nil errorDescription:nil];
    [iDic setObject:homeDic forKey:PLIST_HOME_KEY];
    [iDic setObject:conDic forKey:PLIST_CONNECTION];
    
    BOOL suc = NO;
    
    NSData *xdata = [NSPropertyListSerialization dataFromPropertyList:iDic format:NSPropertyListBinaryFormat_v1_0 errorDescription:nil];
    
    if (xdata!=nil && xdata.length!=0) {
        
        if ([PLAIN_TEXT_ENABLED boolValue]) {//非加密存储，调试时使用
            NSString *plistPath = [QuickPath getLibraryFilePathWithName:[homeDic objectForKey:PLIST_KEY_FileName]];
            [xdata writeToFile:plistPath atomically:YES];
        }
        
        NSString *encodedString = [BHBase64EncoderDecoder customEncode:xdata];
        NSData   *encodedData   = [encodedString dataUsingEncoding:NSUTF8StringEncoding];
        
        NSString *dcPath = [QuickPath getDocumentFilePathWithName:[homeDic objectForKey:PLIST_KEY_FileName]];
        suc = [encodedData writeToFile:dcPath atomically:YES];
    }
    
    if (!suc) {
      //  [QuickAlert showTitle:NSLocalizedString(TEXT_SETTING_WRITE_FAIL, @"")];
        NSLog(@"(not expected)%@", TEXT_SETTING_WRITE_FAIL);
    }
    
}

- (BOOL)hasSameNameHome:(NSString*)homeName{
    
    NSArray *arr = [self getHomeArr];
    
    BOOL hasSame = NO;
    
    for (int i = 0; i < [arr count]; i++) {
    
        NSDictionary *dic = [arr objectAtIndex:i];
        
        NSString *name = [dic objectForKey:PLIST_KEY_NAME];
        if ([name isEqualToString:homeName]) {
            hasSame = YES;
            break;
        }

    }


    return hasSame;

}

- (void)addHomeWithHomeName:(NSString*)homeName{
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:homeName forKey:PLIST_KEY_NAME];
    NSString *fileName       = [[DCManagerTool randomString] stringByAppendingString:@".dc"];
    [dic setObject:fileName forKey:PLIST_KEY_FileName];
    NSMutableArray *homeArr  = [NSMutableArray arrayWithArray:[self getHomeArr]];
    [homeArr addObject:dic];
    
   // [[NSUserDefaults standardUserDefaults] setObject:homeArr forKey:[NSString stringWithFormat:@"%zd%@",[DCManager shareManager].managerInfo.custId,BH_SaveData_HomeDicArr]];
   // [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self generateFileWithFileName:fileName andHomeDic:dic];
    
}

- (void)generateFileWithFileName:(NSString*)fileName andHomeDic:(NSDictionary*)homeDic{

    NSString *filePath = [QuickPath getMainBundleFilePathWithName:PLIST_FILENAME];
    
    assert(filePath!=nil);
    
    NSData *fileData = [[NSFileManager defaultManager] contentsAtPath:filePath];
    NSMutableDictionary  *iDic = (NSMutableDictionary *)[NSPropertyListSerialization propertyListFromData:[BHBase64EncoderDecoder customDecode:fileData] mutabilityOption:NSPropertyListMutableContainersAndLeaves format:nil errorDescription:nil];
    [iDic setObject:homeDic forKey:PLIST_HOME_KEY];

    BOOL suc = NO;
    
    NSData *xdata = [NSPropertyListSerialization dataFromPropertyList:iDic format:NSPropertyListBinaryFormat_v1_0 errorDescription:nil];
    
    if (xdata!=nil && xdata.length!=0) {
        
        if ([PLAIN_TEXT_ENABLED boolValue]) {//非加密存储，调试时使用
            NSString *plistPath = [QuickPath getLibraryFilePathWithName:fileName];
            [xdata writeToFile:plistPath atomically:YES];
        }
        
        NSString *encodedString = [BHBase64EncoderDecoder customEncode:xdata];
        NSData   *encodedData   = [encodedString dataUsingEncoding:NSUTF8StringEncoding];
        
        NSString *dcPath = [QuickPath getDocumentFilePathWithName:fileName];
        suc = [encodedData writeToFile:dcPath atomically:YES];
    }
    
    if (!suc) {
      //  [QuickAlert showTitle:NSLocalizedString(TEXT_SETTING_WRITE_FAIL, @"")];
         NSLog(@"(not expected)%@", TEXT_SETTING_WRITE_FAIL);
    }

}
- (void)editHomeName:(NSString*)homeName{
    
    [[self.hitachiDictionary objectForKey:PLIST_HOME_KEY] setObject:homeName forKey:PLIST_KEY_NAME];
    
    NSMutableArray *arr  = [NSMutableArray arrayWithArray:[self getHomeArr]];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[arr objectAtIndex:0]];
    
    [dic setObject:homeName forKey:PLIST_KEY_NAME];

    [arr replaceObjectAtIndex:0 withObject:dic];
    
    [self save];
    [self saveHomeArr:arr];

}


- (void)saveHomeArr:(NSMutableArray*)homeArr{

  //  [[NSUserDefaults standardUserDefaults] setObject:homeArr forKey:[NSString stringWithFormat:@"%zd%@",[DCManager shareManager].managerInfo.custId,BH_SaveData_HomeDicArr]];
  //  [[NSUserDefaults standardUserDefaults] synchronize];

}

- (NSDictionary*)getHome{
    
    NSMutableArray *homeArr = nil;//  [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%zd%@",[DCManager shareManager].managerInfo.custId,BH_SaveData_HomeDicArr]];
    
    NSMutableDictionary *dic = nil;
    
    if (homeArr == nil || [homeArr count] <= 0) {
        
         homeArr = [NSMutableArray new];
         dic = [NSMutableDictionary dictionary];
        [dic setObject:@"家" forKey:PLIST_KEY_NAME];
         NSString *fileName = [[DCManagerTool randomString] stringByAppendingString:@".dc"];
        [dic setObject:fileName forKey:PLIST_KEY_FileName];
        [homeArr addObject:dic];
        
        [self saveHomeArr:homeArr];
        
    }
    
    dic = [homeArr objectAtIndex:0];
    

    return dic;
    
}



- (NSMutableArray*)getHomeArr{
    
    NSMutableArray *homeArr = nil; //[NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%zd%@",[DCManager shareManager].managerInfo.custId,BH_SaveData_HomeDicArr]]];
    
    if (homeArr == nil || [homeArr count] <= 0) {
        
        homeArr = [NSMutableArray new];
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setObject:@"家" forKey:PLIST_KEY_NAME];
        NSString *fileName = [[DCManagerTool randomString] stringByAppendingString:@".dc"];
        [dic setObject:fileName forKey:PLIST_KEY_FileName];
        
        [homeArr addObject:dic];
        
    }
    
    return homeArr;
    
}



-(void)removeCurrentHome{
    
    NSArray *arr = nil; //[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%zd%@",[DCManager shareManager].managerInfo.custId,BH_SaveData_HomeDicArr]];
    NSMutableArray *homeArr =  [NSMutableArray arrayWithArray:arr];
    
    if ([homeArr count]>1) {
        
        NSDictionary *homeDic      = [homeArr objectAtIndex:0];
        NSString     *fileName     = [homeDic objectForKey:PLIST_KEY_FileName];
        NSString     *filePath     = [QuickPath getDocumentFilePathWithName:fileName];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:filePath error:nil];
        [homeArr removeObjectAtIndex:0];
        
    }
    
    [self saveHomeArr:homeArr];
    [self load];

}


- (void)switchHomeWithIndex:(int)index{

    ///重新排序
    NSArray *arr = nil;//[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%zd%@",[DCManager shareManager].managerInfo.custId,BH_SaveData_HomeDicArr]];
    NSMutableArray *homeArr =  [NSMutableArray arrayWithArray:arr];
    
    if ([homeArr count] >index) {
        [homeArr exchangeObjectAtIndex:0 withObjectAtIndex:index];
    }
    
    [self saveHomeArr:homeArr];
     self.acMapFromAddressToName     = nil;
     self.acMapFromAddressToPosition = nil;
    
    [self.temporarySceneArray removeAllObjects];
     _temporarySceneArray        = nil;
    [self.temporarySectionArray removeAllObjects];
     _temporarySectionArray      = nil;
    [self.temporaryTimerArray removeAllObjects];
     _temporaryTimerArray       = nil;
    [self.hitachiDictionary removeAllObjects];
    self.hitachiDictionary = nil;
    [self load];
    
    
  //  [[BHConnectManager shareConnectManager] startConnect];
    
}


- (void)clear{
    
    self.acMapFromAddressToName     = nil;
    self.acMapFromAddressToPosition = nil;
    
    [self.temporarySceneArray removeAllObjects];
    _temporarySceneArray        = nil;
    [self.temporarySectionArray removeAllObjects];
    _temporarySectionArray      = nil;
    [self.temporaryTimerArray removeAllObjects];
    _temporaryTimerArray       = nil;
    self.hitachiDictionary = nil;
    [self load];


}



- (void)deleteConnectWithId:(NSString*)connectId{
    
    NSArray *arr = [self getHomeArr];
    
    NSMutableArray *homeArr = [NSMutableArray arrayWithArray:arr];
    
    if ([connectId longLongValue] == [[self getServerSN] longLongValue]) {
        [self deleteteConnectionIndex:0];
        return;
    }
    
    for (NSInteger i = 0; i < [homeArr count]; i++) {
        
        NSDictionary *homeDic = [homeArr objectAtIndex:i];
        NSDictionary *conDic = [self getConnectionDicWithHomeDic:homeDic];
        
        NSArray *arr1 = [conDic objectForKey:PLIST_CONNECTION];
        
        for (int i = 0; i < [arr1 count]; i++) {
    
            NSDictionary *dic1          = [arr1 objectAtIndex:i];
          
            if ([[dic1 objectForKey:PLIST_KEY_INDOOR_SN] longLongValue] == [connectId longLongValue]) {
                NSString     *fileName    = [homeDic objectForKey:PLIST_KEY_FileName];
                NSString     *filePath    = [QuickPath getDocumentFilePathWithName:fileName];
                
                if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {//文件存在
                    
                    NSError *error = nil;
                    [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
                    NSLog(@"deleteConnectWithId:%@",error);
                    
                }
                
            }
            
        }
    
    }
    
 
    
}


- (NSDictionary*)getConnectionDicWithHomeDic:(NSDictionary*)homeDic{

   
    NSString     *fileName    = [homeDic objectForKey:PLIST_KEY_FileName];
    NSString     *filePath    = [QuickPath getDocumentFilePathWithName:fileName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {//文件存在
        
      NSData *fileData = [[NSFileManager defaultManager] contentsAtPath:filePath];
      NSDictionary *hitachiDictionary = (NSMutableDictionary *)[NSPropertyListSerialization propertyListFromData:[BHBase64EncoderDecoder customDecode:fileData] mutabilityOption:NSPropertyListMutableContainersAndLeaves format:nil errorDescription:nil];
        
        return hitachiDictionary;
    }else{
        return nil;
    }
    
}



-(NSString*)checkNameExistInRoomOrFloor:(NSString*)name{

    NSString *tipStr = @"";
    //楼层
    
    NSString *existName = @"";
    NSArray *floorArr = [self getAllFloor];
    
    for ( int i =0; i < [floorArr count]; i++) {
        
        NSDictionary *floorDic = [floorArr objectAtIndex:i];
        existName = [floorDic objectForKey:PLIST_KEY_NAME];
        
        if ([existName isEqualToString:name]) {
            tipStr = [NSString stringWithFormat:@"存在“%@”的楼层，请输入其他名称",existName];
            return tipStr ;
            
        }
        
        
        NSArray *roomArr = [floorDic objectForKey:PLIST_PAGES];
        
        for (int m = 0; m < [roomArr count]; m++) {
            
            NSDictionary *roomDic = [roomArr objectAtIndex:m];
            existName = [roomDic objectForKey:PLIST_KEY_NAME];
            if ([existName isEqualToString:name]) {
                tipStr = [NSString stringWithFormat:@"存在“%@”的房间，请输入其他名称",existName];
                return tipStr ;
                
            }
        }
        
    }

    return tipStr;

}


- (NSString*)getTimerNameWithTimeId:(int)timerID{

    NSString *name = @"";
    NSMutableArray *timerArray = [self.hitachiDictionary objectForKey:PLIST_TIMERS];

    for (int i = 0; i < [timerArray count]; i++) {
        NSMutableDictionary *timerDic = [timerArray objectAtIndex:i];
        NSNumber *currentID = [timerDic objectForKey:PLIST_KEY_TIMER_ID];
        
        if (currentID != nil && [currentID intValue] == timerID) {
            name = [timerDic objectForKey:PLIST_KEY_NAME];
        }
    }
    
    return name;
}


#pragma mark  --      TestMethod

- (void)logShowAll{

    

    NSLog(@"ALL__INFO:%@",self.hitachiDictionary);

}

@end
