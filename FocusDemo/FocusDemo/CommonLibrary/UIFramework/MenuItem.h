//
//  MenuItem.h
//  CommonLibrary
//
//  Created by Alexi on 14-1-16.
//  Copyright (c) 2014年 CommonLibrary. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MenuAbleItem.h"

@interface MenuItem : NSObject<MenuAbleItem>
{
@protected
    NSString    *_title;
    UIImage     *_icon;
}


@property (nonatomic, copy) NSString *title;
//@property (nonatomic, copy) MenuAction action;
@property (nonatomic, strong) UIImage *icon;

@property (nonatomic, copy) MenuAction action;


@end

