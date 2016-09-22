//
//  TCILiveHeader.h
//  TCShow
//
//  Created by AlexiChen on 16/8/17.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//
#if kSupportILiveSDK
#ifndef TCILiveHeader_h
#define TCILiveHeader_h

// 因部份用户使用TCAdapter里面的引擎，以及界面时，如果要定制，则需要重写相关的方法
// 考虑到这块对一些刚入门的用户可能不太好理解，故增加该目录
// 用户只需要通过配置好直播时的参数，即可快速的进行直播，不需要再进行重写方法的方式实现
// 此部分的配置，也展出用户可以自定义的部分 

#import "TCILiveBaseConfig.h"
#import "TCILiveLiveConfig.h"
#import "TCILiveMultiLiveConfig.h"
#import "TCILiveCallConfig.h"

#import "TCILiveManagerStartLiveListener.h"
#import "TCILiveManager.h"


#endif /* TCILiveHeader_h */
#endif