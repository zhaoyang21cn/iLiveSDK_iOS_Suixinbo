//
//  WebModels.h
//  TCShow
//
//  Created by AlexiChen on 15/11/12.
//  Copyright © 2015年 AlexiChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShowRoomInfo : NSObject

@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) NSString * type;
@property (nonatomic, assign) NSInteger roomnum;
@property (nonatomic, copy) NSString * groupid;
@property (nonatomic, copy) NSString * cover;
@property (nonatomic, copy) NSString * host;
@property (nonatomic, assign) NSInteger appid;
@property (nonatomic, assign) int thumbup;//点赞数
@property (nonatomic, assign) int memsize;//观看人数
@property (nonatomic, assign) NSInteger device;
@property (nonatomic, assign) NSInteger videotype;

- (NSDictionary *)toRoomDic;

@end

//@interface HostLBS : NSObject
//
//@property (nonatomic, assign) float latitude;
//@property (nonatomic, assign) float longitude;
//@property (nonatomic, copy) NSString *address;
//
//- (NSDictionary *)toLBSDic;
//
//@end

@interface TCShowLiveListItem : NSObject

@property (nonatomic, copy) NSString *uid;
@property (nonatomic, strong) ShowRoomInfo *info;

//@property (nonatomic, strong) HostLBS *lbs;

+ (instancetype)loadFromToLocal;

- (void)saveToLocal;
- (void)cleanLocalData;

- (NSDictionary *)toLiveStartJson;
- (NSDictionary *)toHeartBeatJson;

@end

@interface RecordVideoItem : NSObject

@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *cover;
@property (nonatomic, copy) NSString *videoId;
@property (nonatomic, strong) NSMutableArray *playurl;

@end

@interface MemberListItem : NSObject

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, assign) int role;

@end

@interface LiveStreamListItem : NSObject

@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *cover;
@property (nonatomic, copy) NSString *address;//拼接地址
@property (nonatomic, copy) NSString *address2;//拼接地址
@property (nonatomic, copy) NSString *address3;//拼接地址

@end
