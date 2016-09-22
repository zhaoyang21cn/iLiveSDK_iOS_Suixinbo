//
//  TCAdapterHeader.h
//  TCShow
//
//  Created by AlexiChen on 16/4/12.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#ifndef TCAdapterHeader_h
#define TCAdapterHeader_h

// 导入TCAdapter宏配置文件
#import "TCAdapterConfig.h"

#import "TCAVTipTag.h"
// 导入索引头文件

#import "AVIMAble.h"

#import "TCAVIMMIManager.h"

#if kSupportCallScene
#import "TCAVCallManager.h"
#endif

#import "TIMAdapter.h"

#import "TCAVIMAdapter.h"

#if kTCAVLogSwitch
#import "TCAVLogManager.h"
#endif


#if kSupportILiveSDK
#import "TCILiveHeader.h"
#endif

#endif /* TCAdapterHeader_h */
