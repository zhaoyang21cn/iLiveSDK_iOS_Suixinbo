//
//  ImageTitleButton.m
//  CommonLibrary
//
//  Created by Alexi on 3/21/14.
//  Copyright (c) 2014 Alexi. All rights reserved.
//

#import "ImageTitleButton.h"

#import "UILabel+Common.h"
#import "UIImage+TintColor.h"

@implementation ImageTitleButton

- (instancetype)init
{
    return [self initWithStyle:EImageLeftTitleRight];
}

- (instancetype)initWithStyle:(ImageTitleButtonStyle)style
{
    return [self initWithStyle:style maggin:UIEdgeInsetsMake(0, 0, 0, 0)];
}

- (instancetype)initWithStyle:(ImageTitleButtonStyle)style maggin:(UIEdgeInsets)margin
{
    return [self initWithStyle:style maggin:margin padding:CGSizeMake(2, 2)];
}

- (instancetype)initWithStyle:(ImageTitleButtonStyle)style maggin:(UIEdgeInsets)margin padding:(CGSize)padding
{
    if (self = [super initWithFrame:CGRectZero])
    {
        _style = style;
        _margin = margin;
        _padding = padding;
    }
    return self;
}

- (void)setImage:(nullable UIImage *)image forState:(UIControlState)state
{
    [super setImage:image forState:state];
    if (image && CGSizeEqualToSize(_imageSize, CGSizeZero))
    {
        _imageSize = image.size;
    }
}


- (void)setMargin:(UIEdgeInsets)margin
{
    _margin = margin;
    [self setNeedsDisplay];
}

- (void)setPadding:(CGSize)padding
{
    _padding = padding;
    [self setNeedsDisplay];
}

- (void)relayoutFrameOfSubViews
{
    CGRect rect = self.bounds;
    
    rect.origin.x += _margin.left;
    rect.size.width -= _margin.left + _margin.right;
    rect.origin.y += _margin.top;
    rect.size.height -= _margin.top + _margin.bottom;
    
    UIImage *img = [self imageForState:UIControlStateNormal];
    CGFloat scale = [[UIScreen mainScreen] scale];

    CGSize size = CGSizeZero;
    
    if (CGSizeEqualToSize(self.imageSize, CGSizeZero))
    {
        size = CGSizeMake(img.size.width/scale, img.size.height/scale);
    }
    else
    {
        size = self.imageSize;
    }
    
    switch (_style)
    {
        case EImageTopTitleBottom:
        {
            CGRect imgRect = rect;
            imgRect.size.height = size.height;
            imgRect.origin.x += (imgRect.size.width - size.width)/2;
            imgRect.size.width = size.width;
            self.imageView.frame = imgRect;
            
            CGRect titleRect = rect;
            titleRect.origin.y += imgRect.size.height + _padding.height;
            titleRect.size.height -= imgRect.size.height + _padding.height;
            self.titleLabel.frame = titleRect;
        }
            break;
        case ETitleTopImageBottom:
        {
            CGRect imgRect = rect;
            imgRect.origin.x += (imgRect.size.width - size.width)/2;
            imgRect.size.width = size.width;
            imgRect.size.height = size.height;
            imgRect.origin.y += rect.size.height - imgRect.size.height;
            self.imageView.frame = imgRect;
            
            CGRect titleRect = rect;
            titleRect.size.height -= imgRect.size.height + _padding.height;
            self.titleLabel.frame = titleRect;
        }
            break;
        case EImageLeftTitleRight:
        {
            CGRect imgRect = rect;
            imgRect.size.width = size.width;
            imgRect.size.height = size.height;
            imgRect.origin.y += (rect.size.height - size.height)/2;
            self.imageView.frame = imgRect;
            
            CGRect titleRect = rect;
            titleRect.origin.x += imgRect.size.width + _padding.width;
            titleRect.size.width -= imgRect.size.width + _padding.width;
            self.titleLabel.frame = titleRect;
        }
            break;
        case ETitleLeftImageRight:
        {
            CGRect imgRect = rect;
            imgRect.size.width = size.width;
            imgRect.origin.x += rect.size.width - imgRect.size.width;
            imgRect.size.height = size.height;
            imgRect.origin.y += (rect.size.height - size.height)/2;
            self.imageView.frame = imgRect;
            
            CGRect titleRect = rect;
            titleRect.size.width -= imgRect.size.width + _padding.width;
            self.titleLabel.frame = titleRect;
        }
            break;
        case EImageLeftTitleRightLeft:
        {
            CGRect imgRect = rect;
            imgRect.size = self.imageSize;
            imgRect.origin.y += (rect.size.height - imgRect.size.height)/2;
            self.imageView.frame = imgRect;
            
            rect.origin.x += imgRect.size.width + self.padding.width;
            rect.size.width -= imgRect.size.width + self.padding.width;
            self.titleLabel.textAlignment = NSTextAlignmentLeft;
            self.titleLabel.frame = rect;
        }
            break;
            
        case ETitleLeftImageRightLeft:
        {
            CGRect imgRect = rect;
            imgRect.size = self.imageSize;
            imgRect.origin.y += (rect.size.height - imgRect.size.height)/2;
            imgRect.origin.x += rect.size.width - (imgRect.size.width + self.padding.width);
            self.imageView.frame = imgRect;
            
            rect.size.width -= imgRect.size.width + self.padding.width;
            
            self.titleLabel.frame = rect;
        }
            break;
            
        case EImageLeftTitleRightCenter:
        {
            
            CGSize titleSize = [self.titleLabel textSizeIn:rect.size];
            
            CGRect middleRect = CGRectInset(rect, (rect.size.width - (titleSize.width + self.imageSize.width + self.padding.width))/2, 0);
            
            CGRect imgRect = middleRect;
            
            imgRect.size = self.imageSize;
            imgRect.origin.y += (middleRect.size.height - imgRect.size.height)/2;
            self.imageView.frame = imgRect;
            
            middleRect.origin.x += imgRect.size.width + self.padding.width;
            middleRect.size.width -= imgRect.size.width + self.padding.width;
            
            self.titleLabel.frame = middleRect;
    
            
        }
            break;
            
        case ETitleLeftImageRightCenter:
        {
            CGSize titleSize = [self.titleLabel textSizeIn:rect.size];
            
            CGRect middleRect = CGRectInset(rect, (rect.size.width - (titleSize.width + self.imageSize.width + self.padding.width))/2, 0);
            
            CGRect titlerect = middleRect;
            titlerect.size.width = titleSize.width;
            self.titleLabel.frame = titlerect;
            
            middleRect.origin.x += titlerect.size.width + self.padding.width;
            middleRect.size.width -= titlerect.size.width + self.padding.width;
            
            middleRect.origin.y += (middleRect.size.height - self.imageSize.height)/2;
            middleRect.size = self.imageSize;
            self.imageView.frame = middleRect;
        }
            break;
        case EFitTitleLeftImageRight:
        {
            CGSize titleSize = [self.titleLabel textSizeIn:rect.size];
            CGRect titleRect = rect;

            titleRect.origin.y = rect.origin.y + (rect.size.height - titleSize.height)/2;
            titleRect.size = titleSize;
            self.titleLabel.frame = titleRect;
            
            titleRect.origin.x += titleRect.size.width + self.padding.width;
            titleRect.size = self.imageSize;
            titleRect.origin.y = rect.origin.y + (rect.size.height - self.imageSize.height)/2;
            self.imageView.frame = titleRect;
            
            break;
        }
            break;
            
        default:
            break;
    }
}

- (void)layoutSubviews
{
    if (CGRectEqualToRect(self.bounds, CGRectZero))
    {
        return;
    }
    [super layoutSubviews];
    
//    // 单独设置title或image的时候只用
//    NSString *title = [self titleForState:UIControlStateNormal];
//    UIImage *image = [self imageForState:UIControlStateNormal];
//    if ([NSString isEmpty:title] && image)
//    {
        [self relayoutFrameOfSubViews];
//    }
}

- (void)setTintColor:(UIColor *)color
{
    if (color)
    {
        UIImage *img = [self imageForState:UIControlStateNormal];
        img = [img imageWithTintColor:color];
        [self setImage:img  forState:UIControlStateNormal];
        [self setTitleColor:color forState:UIControlStateNormal];
    }
}

@end
