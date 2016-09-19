//
//  LiveCallLoginViewController.h
//  ILiveCall
//
//  Created by tomzhu on 16/9/12.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <TLSUI/TLSUI.h>
#import <TLSSDK/TLSRefreshTicketListener.h>
#import <TLSSDK/TLSOpenLoginListener.h>

@interface LiveCallLoginViewController : UIViewController<TLSUILoginListener,TLSRefreshTicketListener>

@end
