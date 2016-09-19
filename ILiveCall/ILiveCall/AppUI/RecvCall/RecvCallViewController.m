//
//  RecvCallViewController.m
//  ILiveCall
//
//  Created by tomzhu on 16/9/14.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "RecvCallViewController.h"

@implementation RecvCallViewController
{
    RecvCallView * _recvView;
    id<RecvCallAble> _recvCallModel;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configLiveView];
}

- (void)configLiveView
{
    [_recvCallModel createAVGLViewIn:self];
    
    _recvView = [[RecvCallView alloc] init];
    [_recvView setBounds:self.view.bounds];
    [_recvView setRecvCallModel:_recvCallModel andDelegate:self];
    [self.view addSubview:_recvView];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [_recvView setFrame:self.view.bounds];
}

- (void)setRecvCallModel:(id<RecvCallAble>)viewModel
{
    _recvCallModel = viewModel;
}

- (void)onExitCall:(NSString*)tips
{
    [[AppDelegate sharedInstance] dismissViewController:self animated:YES completion:^{
        [[HUDHelper sharedInstance] tipMessage:tips delay:1.0];
    }];
}

@end
