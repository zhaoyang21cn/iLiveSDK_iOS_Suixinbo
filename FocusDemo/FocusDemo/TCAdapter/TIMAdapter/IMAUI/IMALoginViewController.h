//
//  IMALoginViewController.h
//  TIMChat
//
//  Created by AlexiChen on 16/2/26.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <TencentOpenAPI/TencentOAuth.h>
#import "WXApi.h"

#import "TLSUI/TLSUI.h"
#import "TLSSDK/TLSRefreshTicketListener.h"
#import "TLSSDK/TLSOpenLoginListener.h"

@interface IMALoginViewController : UIViewController<TencentSessionDelegate, WXApiDelegate, TLSUILoginListener,TLSRefreshTicketListener,TLSOpenLoginListener>

@end
