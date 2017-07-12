//
//  ILiveHeader.h
//  ILiveSDK
//
//  Created by AlexiChen on 2016/10/24.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#ifndef ILiveHeader_h
#define ILiveHeader_h

#import "ILiveCommon.h"

#import "ILiveSDK.h"

#import "ILiveRoomOption.h"

#import "ILiveLoginManager.h"

#import "ILiveRoomManager.h"

#import "ILivePushOption.h"

#import "ILiveRecordOption.h"

#if TARGET_OS_IOS
#import "ILiveRenderView.h"
#else
#import "ILiveRenderViewForMac.h"
#endif

#import "ILiveFrameDispatcher.h"

#endif /* ILiveHeader_h */
