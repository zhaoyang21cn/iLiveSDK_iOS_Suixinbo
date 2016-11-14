//
//  LiveStartRequest.h
//  TCShow
//
//  Created by AlexiChen on 16/4/27.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "BaseRequest.h"

@interface LiveStartRequest : BaseRequest

@property (nonatomic, strong) TCShowLiveListItem *liveItem;

@end
