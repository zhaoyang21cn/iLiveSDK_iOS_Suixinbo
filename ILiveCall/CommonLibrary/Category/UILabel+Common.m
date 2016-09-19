//
//  UILabel+UILabel_Common.m
//  CommonLibrary
//
//  Created by AlexiChen on 14-1-18.
//  Copyright (c) 2014年 CommonLibrary. All rights reserved.
//

#import "UILabel+Common.h"

@implementation UILabel (Common)

+ (instancetype)label
{
    UILabel *label = [[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentLeft;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor blackColor];
    return label;
}

+ (instancetype)labelWithTitle:(NSString *)title
{
    UILabel *label = [UILabel label];
    
    label.text = title;
    return label;
}

- (CGSize)contentSize
{
    return [self textSizeIn:self.bounds.size];
}

- (CGSize)textSizeIn:(CGSize)size
{
    NSLineBreakMode breakMode = self.lineBreakMode;
    UIFont *font = self.font;
    
    CGSize contentSize = CGSizeZero;
//    if ([IOSDeviceConfig sharedConfig].isIOS7)
//    {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = breakMode;
        paragraphStyle.alignment = self.textAlignment;
        
        NSDictionary* attributes = @{NSFontAttributeName:font,
                                     NSParagraphStyleAttributeName:paragraphStyle};
        contentSize = [self.text boundingRectWithSize:size options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:attributes context:nil].size;
//    }
//    else
//    {
//        contentSize = [self.text sizeWithFont:font constrainedToSize:size lineBreakMode:breakMode];
//    }
    
    
    contentSize = CGSizeMake((int)contentSize.width + 1, (int)contentSize.height + 1);
    return contentSize;
}

//- (void)layoutInContent
//{
//    CGSize size = [self contentSize];
//    CGRect rect = self.frame;
//    rect.size = size;
//    self.frame = rect;
//}
//


@end


@implementation InsetLabel


- (void)drawTextInRect:(CGRect)rect
{
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, _contentInset)];
}


- (CGSize)contentSize
{
    CGRect rect = UIEdgeInsetsInsetRect(self.bounds, _contentInset);
    CGSize size = [super textSizeIn:rect.size];
    return CGSizeMake(size.width + _contentInset.left + _contentInset.right, size.height + _contentInset.top + _contentInset.bottom);
}

- (CGSize)textSizeIn:(CGSize)size
{
    size.width -= _contentInset.left + _contentInset.right;
    size.height -= _contentInset.top + _contentInset.bottom;
    CGSize textSize = [super textSizeIn:size];
    return CGSizeMake(textSize.width + _contentInset.left + _contentInset.right, textSize.height + _contentInset.top + _contentInset.bottom);
}

@end
