//
//  RefreshAbleView.h
//  CommonLibrary
//
//  Created by Alexi on 15-2-4.
//  Copyright (c) 2015年 Alexi Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RefreshAbleView <NSObject>

@property (nonatomic, assign) NSInteger refreshHeight;

- (void)willLoading;
- (void)releaseLoading;
- (void)loading;
- (void)loadingOver;

@end
