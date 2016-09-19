//
//  DialUserModel.h
//  ILiveCall
//
//  Created by tomzhu on 16/9/13.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViewModelAble.h"

@interface DialUserViewModel : NSObject<DialUserCellAble>

- (void)onDialUserChanged:(NSString *)userId path:(NSIndexPath *)path;

- (NSString*)getDialUser;

@end
