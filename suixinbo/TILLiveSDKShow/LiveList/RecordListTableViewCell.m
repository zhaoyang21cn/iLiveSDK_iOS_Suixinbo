//
//  RecordListTableViewCell.m
//  TILLiveSDKShow
//
//  Created by wilderliao on 2017/5/18.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "RecordListTableViewCell.h"

@implementation RecordListTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [self addOwnViews];
        self.contentView.backgroundColor = kColorWhite;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)addOwnViews
{
    _recordCover = [[UIImageView alloc] init];
//    _recordCover.contentMode = UIViewContentModeScaleAspectFill;
    _recordCover.contentMode =  UIViewContentModeCenter;
    _recordCover.clipsToBounds  = YES;
    [self.contentView addSubview:_recordCover];
    
    _recordTitle = [[UILabel alloc] init];
    _recordTitle.font = kAppMiddleTextFont;
    [self.contentView addSubview:_recordTitle];
    
    _recordUser = [[UILabel alloc] init];
    _recordUser.font = kAppMiddleTextFont;
    [self.contentView addSubview:_recordUser];
    
    _recordTime = [[UILabel alloc] init];
    _recordTime.font = kAppMiddleTextFont;
    [self.contentView addSubview:_recordTime];
}

- (void)configWith:(RecordVideoItem *)item;
{
    if (!item)
    {
        return;
    }
    _item = item;
    
    //懒加载封面
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *path = [self downAndSaveToLocal];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (path)
            {
                UIImage *image = [UIImage imageWithContentsOfFile:path];
                [_recordCover setImage:image];
            }
        });
    });
    [_recordCover setImage:[UIImage imageNamed:@"defaul_publishcover"]];
    
    NSArray *array = [item.name componentsSeparatedByString:@"_"];
    if (array.count > 1)//录制用户
    {
        NSString *identifier = array[1];
        [_recordUser setText:[NSString stringWithFormat:@"录制用户:%@",identifier]];
    }
    if (array.count > 2)//录制文件名
    {
        NSString *fileName = array[2];
        [_recordTitle setText:[NSString stringWithFormat:@"录制文件名:%@",fileName]];
    }
    if (array.count > 3)//录制时间
    {
        NSString *recStartTime = array[3];
        [_recordTime setText:[NSString stringWithFormat:@"录制时间:%@",recStartTime]];
    }
}

- (NSString *)isExitsFile:(NSString *)videoId
{
    NSString *tempDir = NSTemporaryDirectory();
    NSString *snapshotPath = [NSString stringWithFormat:@"%@%@", tempDir, videoId];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:snapshotPath])
    {
        return snapshotPath;
    }
    return nil;
}

- (NSString *)downAndSaveToLocal
{
//    (NSString *)urlStr videoId:(NSString *)videoId
    if (!_item)
    {
        return nil;
    }
    if (_item.playurl.count <= 0)
    {
        return nil;
    }
    NSString *urlStr = _item.playurl[0];
    if (!(urlStr && urlStr.length > 0))
    {
        return nil;
    }
    NSString *videoId = _item.videoId;
    //判断截图文件是否存在
    NSString *path = [self isExitsFile:videoId];
    if (path)
    {
        return path;
    }
    NSString *tempDir = NSTemporaryDirectory();
    path = [NSString stringWithFormat:@"%@%@", tempDir, videoId];
    //视频截图
    AVURLAsset *urlAsset = [[AVURLAsset alloc] initWithURL:[NSURL URLWithString:urlStr] options:nil];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:urlAsset];
    imageGenerator.appliesPreferredTrackTransform = YES;   // 截图的时候调整到正确的方向
    CMTime time = CMTimeMakeWithSeconds(1.0, 30);          // 1.0为截取视频1.0秒处的图片，30为每秒30帧
    CGImageRef cgImage = [imageGenerator copyCGImageAtTime:time actualTime:nil error:nil];
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    //            CGRect rect = self.contentView.bounds;
    //            CGSize size = CGSizeMake(rect.size.width, rect.size.width*0.618);
    //            UIGraphicsBeginImageContext(size);
    //            // 绘制改变大小的图片
    //            [image drawInRect:CGRectMake(0,0, size.width,size.height)];
    //            // 从当前context中创建一个改变大小后的图片
    //            UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    NSData *snapshotData = UIImageJPEGRepresentation(image, 0.75);
    if (![[NSFileManager defaultManager] createFileAtPath:path contents:snapshotData attributes:nil])
    {
        return nil;
    }
    return path;
}

- (void)setCoverImage:(NSString *)path
{
    if (path && path.length > 0)
    {
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        if (image)
        {
            [_recordCover setImage:image];
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self relayoutFrameOfSubViews];
}

- (void)relayoutFrameOfSubViews
{
    CGRect rect = self.contentView.bounds;
    
    CGRect coverRect = rect;
    coverRect.size.height = (NSInteger)(rect.size.width * 0.618);
    _recordCover.frame = coverRect;
    
    CGFloat labelH = (NSInteger)(rect.size.height - coverRect.size.height) / 3;
    
    [_recordTitle sizeWith:CGSizeMake(rect.size.width, labelH)];
    [_recordTitle layoutBelow:_recordCover];
    
    [_recordUser sizeWith:CGSizeMake(rect.size.width, labelH)];
    [_recordUser layoutBelow:_recordTitle];
    
    [_recordTime sizeWith:CGSizeMake(rect.size.width, labelH)];
    [_recordTime layoutBelow:_recordUser];
}


@end
