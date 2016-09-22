//
//  PopupView.h
//  HudDemo
//
//  Created by Alexi on 13-12-3.
//  Copyright (c) 2013年 Matej Bukovinski. All rights reserved.
//
#if kSupportPopupView
#import <UIKit/UIKit.h>



@class PopupView;



@protocol PopupContentViewDelegate <NSObject>

// 在Window中时显示的大小
//- (CGSize)contentSize;

@required

- (void)setPopupParent:(PopupView *)popup;

- (CGRect)showRect;

- (void)closePopup;

// YES：击返回空的区域
- (BOOL)isAlert;

// 点击空白区域
- (void)onTouchBlank;

@optional

- (void)adjustShowRectOnRorate;

@end


@class PopupContentView;

typedef void (^PopupContentViewAnimationBlock)(PopupContentView *popup);

@interface PopupContentView : UIView<PopupContentViewDelegate>
{
@protected
   __unsafe_unretained PopupView *_popupParent;
    CGRect _showRect;
    CGSize _showSize;
    BOOL _isAlert;
}

@property (nonatomic, assign) PopupView *popupParent;
@property (nonatomic, assign) CGRect showRect;
@property (nonatomic, assign) CGSize showSize;
@property (nonatomic, assign) BOOL isAlert;

@property (nonatomic, copy) PopupContentViewAnimationBlock outAnimation;


@end



typedef enum
{
	/** Opacity animation */
	EPopupViewAnimationFade,
	/** Opacity + scale animation */
	EPopupViewAnimationZoom,
	EPopupViewAnimationZoomOut = EPopupViewAnimationZoom,
	EPopupViewAnimationZoomIn
}PopupViewAnimation;

@interface PopupView : UIView<UIGestureRecognizerDelegate>

@property (assign) BOOL dimBackground;
@property (assign) PopupViewAnimation animationType;
@property (nonatomic, readonly) UIView<PopupContentViewDelegate> *contentView;
@property (nonatomic, assign) CGFloat animationDuration;

+ (PopupView *)alertInWindow:(PopupContentView *)contentView;

+ (PopupView *)alertInWindow:(PopupContentView *)contentView withAnimation:(void (^)(void))animation;

+ (PopupView *)alert:(PopupContentView *)contentView inView:(UIView *)view;

+ (PopupView *)alert:(PopupContentView *)contentView inView:(UIView *)view withAnimation:(void (^)(void))animation;


+ (PopupView *)tipInWindow:(PopupContentView *)contentView;

+ (PopupView *)tipInWindow:(PopupContentView *)contentView withAnimation:(void (^)(void))animation;

+ (PopupView *)tip:(PopupContentView *)contentView inView:(UIView *)view;

+ (PopupView *)tip:(PopupContentView *)contentView inView:(UIView *)view withAnimation:(void (^)(void))animation;

- (void)show:(BOOL)animated;

- (void)hide:(BOOL)animated;



@end

#endif






