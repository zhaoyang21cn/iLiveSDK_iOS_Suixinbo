//
//  CommonCatetory.h
//  CommonLibrary
//
//  Created by Alexi on 13-11-6.
//  Copyright (c) 2013年 ywchen. All rights reserved.
//

#ifndef CommonLibrary_CommonCatetory_h
#define CommonLibrary_CommonCatetory_h




#import "UIImage+TintColor.h"
#import "UIImage+Alpha.h"


#import "UIImage+Common.h"


#import "NSDate+Common.h"

#if kSupportNSDataCommon
#import "NSData+Common.h"
#import "NSData+CRC.h"
#endif
#import "NSString+Common.h"



#if kSupportGTM64

#import "GTMDefines.h"
#import "GTMBase64.h"

#endif

#import "UILabel+Common.h"
#import "UIView+CustomAutoLayout.h"

#if kSupportModifyFrame
#import "UIView+ModifyFrame.h"
#endif

#import "NSString+RegexCheck.h"

#if kSupportKeyChainHelper
#import "KeyChainHelper.h"
#endif

#import "UIViewController+ChildViewController.h"


#import "NSObject+CommonBlock.h"

#if kSupportNSObjectKVOCategory
#import "NSObject+KVOCategory.h"
#endif

#import "UIView+RelativeCoordinate.h"

#if kSupportMKMapViewZoomLevel
#import "MKMapView+ZoomLevel.h"
#endif

#import "UITextField+UITextField_Tip.h"


#import "CLSafeMutableArray.h"

#import "UIView+Glow.h"

#if kSupportUIViewEffect
#import "UIView+Effect.h"
#endif

#endif
