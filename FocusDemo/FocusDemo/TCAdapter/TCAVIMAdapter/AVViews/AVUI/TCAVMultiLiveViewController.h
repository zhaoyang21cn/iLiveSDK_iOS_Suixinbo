//
//  TCAVMultiLiveViewController.h
//  TCShow
//
//  Created by AlexiChen on 16/4/12.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "TCAVLiveViewController.h"

@interface TCAVMultiLiveViewController : TCAVLiveViewController<TCAVIMMIManagerDelegate>
{
@protected
    TCAVIMMIManager          *_multiManager;          // 多人互动逻辑处理
}

@property (nonatomic, readonly) TCAVIMMIManager *multiManager;


- (void)addRenderInPreview:(id<AVMultiUserAble>)user;
- (void)switchToMainInPreview:(id<AVMultiUserAble>)user completion:(TCAVCompletion)completion;
- (void)removeRenderInPreview:(id<AVMultiUserAble>)user;

@end


@interface TCAVMultiLiveViewController (ProtectedMethod)


- (void)addMultiManager;

//- (void)assignHostResource;

@end

