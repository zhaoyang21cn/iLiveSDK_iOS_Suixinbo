//
//  MakeCallViewController.m
//  ILiveCall
//
//  Created by tomzhu on 16/9/13.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "MakeCallViewController.h"

@implementation MakeCallViewController
{
    MakeCallView * _callView;
    id<MakeCallAble> _makeCallModel;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configLiveView];
}

- (void)configLiveView
{
    [_makeCallModel createAVGLViewIn:self];
    
    _callView = [[MakeCallView alloc] init];
    [_callView setBounds:self.view.bounds];
    [_callView setMakeCallModel:_makeCallModel andDelegate:self];
    [self.view addSubview:_callView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self makeCall];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [_callView setFrame:self.view.bounds];
}

- (void)makeCall
{
    if (_callType == CALL_TYPE_AUDIO) {
        [_makeCallModel dialUserWithAudio:_peerId];
    }
    else {
        [_makeCallModel dialUserWithVideo:_peerId];
    }
}

- (void)setMakeCallModel:(id<MakeCallAble>)viewModel
{
    _makeCallModel = viewModel;
}

- (void)onExitCall:(NSString *)tips
{
    [[AppDelegate sharedInstance] dismissViewController:self animated:YES completion:^{
        [[HUDHelper sharedInstance] tipMessage:tips delay:1.0];
    }];
}

@end
