//
//  FontHelper.h
//  CommonLibrary
//
//  Created by Alexi on 13-10-22.
//  Copyright (c) 2013年 ywchen. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface FontHelper : NSObject

// 标题字体
@property (nonatomic, readonly) UIFont *titleFont;

// 子标题字体
@property (nonatomic, readonly) UIFont *subTitleFont;

// 文本字体
@property (nonatomic, readonly) UIFont *textFont;

// 子文本字体
@property (nonatomic, readonly) UIFont *subTextFont;

// 提示语字体
@property (nonatomic, readonly) UIFont *tipFont;

// 超大号字体
@property (nonatomic, readonly) UIFont *superLargeFont;

// 大号字体
@property (nonatomic, readonly) UIFont *largeFont;

// 中号字体
@property (nonatomic, readonly) UIFont *mediumFont;

// 小号字体
@property (nonatomic, readonly) UIFont *smallFont;

+ (instancetype)shareHelper;

+ (UIFont *)fontWithName:(NSString *)name size:(CGFloat)size;

+ (UIFont *)fontWithSize:(CGFloat)size;

+ (UIFont *)boldFontWithSize:(CGFloat)size;

@end


