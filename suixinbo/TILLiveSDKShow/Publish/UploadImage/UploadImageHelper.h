//
//  UploadImageHelper.h
//  PLUShow
//
//  Created by AlexiChen on 15/11/28.
//  Copyright © 2015年 AlexiChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UploadImageHelper : NSObject

+ (instancetype)shareInstance;

- (void)upload:(UIImage *)image completion:(void (^)(NSString *imageSaveUrl))completion failed:(void (^)(NSString *failTip))failure;

@end
