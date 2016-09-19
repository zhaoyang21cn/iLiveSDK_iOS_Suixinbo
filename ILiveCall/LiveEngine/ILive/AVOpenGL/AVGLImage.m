//
//  AVGLImage.m
//  OpenGLRestruct
//
//  Created by vigoss on 14-11-10.
//  Copyright (c) 2014年 vigoss. All rights reserved.
//

#import "AVGLImage.h"

@implementation AVGLImage

@synthesize width = _imageWidth,height = _imageHeight, data = _imageData,angle = _angle,isFullScreenShow = _isFullScreenShow,viewStatus = _viewStatus,dataFormat = _dataFormat;
-(void)dealloc{
    [super dealloc];
}
@end
