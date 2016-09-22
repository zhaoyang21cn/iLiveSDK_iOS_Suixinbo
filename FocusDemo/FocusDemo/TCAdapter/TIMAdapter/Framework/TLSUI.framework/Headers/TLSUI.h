//
//  TLSUI.h
//  TLSUI
//
//  Created by okhowang on 15/7/20.
//  Copyright (c) 2015年 tencent. All rights reserved.
//
#ifndef TLSUI_TLSUI_h
#define TLSUI_TLSUI_h
#import <UIKit/UIKit.h>
//! Project version number for TLSUI.
FOUNDATION_EXPORT double TLSUIVersionNumber;

//! Project version string for TLSUI.
FOUNDATION_EXPORT const unsigned char TLSUIVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <TLSUI/PublicHeader.h>
@class TLSUserInfo;
@class TLSTokenInfo;
@class SendAuthResp;
@class TencentOAuth;
@class WBAuthorizeResponse;

@protocol TLSUILoginListener
/**
 *  用户点击返回放弃登录
 */
-(void)TLSUILoginCancel;
/**
 *  TLS帐号登录成功
 *
 *  @param userinfo 登录成功的用户
 */
-(void)TLSUILoginOK:(TLSUserInfo*)userinfo;
/**
 *  QQ登录成功 票据在QQ API对象中
 */
-(void)TLSUILoginQQOK;
/**
 *  微信登录成功
 *
 *  @param resp 微信登录返回信息
 */
-(void)TLSUILoginWXOK:(SendAuthResp*)resp;
/**
 *  微信登录成功，后台自动换取access token成功时调用该接口
 *
 *  @param tokenInfo code换取到的信息，包括access token、openid
 */
-(void)TLSUILoginWXOK2:(TLSTokenInfo*)tokenInfo;
/**
 *  微博登录成功
 *
 *  @param resp 微博登录返回信息
 */
-(void)TLSUILoginWBOK:(WBAuthorizeResponse*)resp;

@end

@interface TLSUILoginSetting: NSObject
/**
 *  qqsdk 对象 要启用qq登录必须设置该对象并保证链接qqsdk
 */
@property (strong) TencentOAuth *openQQ;
/**
 *  qq登录需要的权限
 */
@property (strong) NSArray *qqScope;
/**
 *  微信登录需要的权限 要启用微信登录必须设置该对象并保证链接wxsdk
 */
@property (strong) NSString *wxScope;
/**
 *  后台配置了微信的app secret的时候设置为YES可以自动换取微信的AccessToken
 *  回调变为TLSUILoginWXOK2
 */
@property (nonatomic) BOOL enableWXExchange;
/**
 *  微博登录需要的权限
 */
@property (strong) NSString *wbScope;
/**
 *  微博登录的回调uri 要启用微博登录必须设置该对象并保证链接wbsdk
 */
@property (strong) NSString *wbRedirectURI;
/**
 *  是否支持游客登录
 */
@property BOOL enableGuest;
/**
 *  是否添加返回按钮
 */
@property BOOL needBack;
@end
/*! @brief 拉起TLSUI登录框
 *
 * @param vc 当前view controller 需要实现TLSUILoginListener接口
 * @param setting 登录框设置
 * @return 回调对象，目前用于微信、微博登录回调
 */
FOUNDATION_EXPORT id TLSUILogin(UIViewController<TLSUILoginListener> *vc, TLSUILoginSetting *setting);
/**
 *  退出登录框。请勿直接调用
 */
void TLSUIExit(void);
#endif
