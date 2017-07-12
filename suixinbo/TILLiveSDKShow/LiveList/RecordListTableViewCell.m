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
    _recordCover.contentMode =  UIViewContentModeCenter;
    _recordCover.clipsToBounds  = YES;
    [self.contentView addSubview:_recordCover];
    
    _recordUserHead = [[UIButton alloc] init];
    _recordUserHead.layer.cornerRadius = 22;
    _recordUserHead.layer.masksToBounds = YES;
    [self.contentView addSubview:_recordUserHead];
    
    _recordTitle = [[UILabel alloc] init];
    [self.contentView addSubview:_recordTitle];
    
    _recordTime = [[UILabel alloc] init];
    _recordTime.font = kAppSmallTextFont;
    _recordTime.textColor = kColorBlack60;
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
    
    __weak typeof(self)ws = self;
    //设置用户头像
    [[TIMFriendshipManager sharedInstance] GetUsersProfile:@[item.uid] succ:^(NSArray *friends) {
        if (friends.count <= 0)
        {
            return ;
        }
        TIMUserProfile *profile = friends[0];
        if (profile.faceURL && profile.faceURL.length > 0)
        {
            NSURL *avatarUrl = [NSURL URLWithString:profile.faceURL];
            NSData *avatarData = [NSData dataWithContentsOfURL:avatarUrl];
            UIImage *image = [UIImage imageWithData:avatarData];
            if ([NSThread isMainThread])
            {
                [ws.recordUserHead setBackgroundImage:image forState:UIControlStateNormal];
            }
            else
            {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [ws.recordUserHead setBackgroundImage:image forState:UIControlStateNormal];
                });
            }
        }
    } fail:nil];
    [_recordUserHead setBackgroundImage:[UIImage imageNamed:@"default_head"] forState:UIControlStateNormal];
    
    NSArray *array = [item.name componentsSeparatedByString:@"_"];
    NSMutableString *recordInfo = [NSMutableString string];
    if (array.count > 2)//录制文件名
    {
        NSString *fileName = array[2];
        [recordInfo appendString:fileName];
        
        NSString *identifier = array[1];
        [recordInfo appendFormat:@"      @%@",identifier];
        
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:recordInfo];
        [attrStr addAttribute:NSForegroundColorAttributeName value:kColorBlack range:NSMakeRange(0, fileName.length)];
        [attrStr addAttribute:NSFontAttributeName value:kAppMiddleTextFont range:NSMakeRange(0, fileName.length)];
        [attrStr addAttribute:NSForegroundColorAttributeName value:kColorBlack60 range:NSMakeRange(fileName.length, recordInfo.length-fileName.length)];
        [attrStr addAttribute:NSFontAttributeName value:kAppSmallTextFont range:NSMakeRange(fileName.length, recordInfo.length-fileName.length)];
        
        [_recordTitle setAttributedText:attrStr];
    }
    if (array.count > 3)//录制时间
    {
        NSString *recStartTime = array[array.count-2];//倒数第二个是开始时间
        NSArray *recStartTimeArray = [recStartTime componentsSeparatedByString:@"-"];
        NSMutableString *dateString = [NSMutableString string];
        NSMutableString *timeString = [NSMutableString string];
        if (recStartTimeArray.count >= 6)
        {
            for (int index = 0; index < 3; index++)
            {
                [dateString appendFormat:@"%@-",recStartTimeArray[index]];
            }
            for (int index = 3; index < 6; index++)
            {
                [timeString appendFormat:@"%@:",recStartTimeArray[index]];
            }
            NSString *resultDate = [dateString substringToIndex:dateString.length-1];
            NSString *resultTime = [timeString substringToIndex:timeString.length-1];
            NSString *showInfo = [NSString stringWithFormat:@"%@  %@",resultDate,resultTime];
            [_recordTime setText:[NSString stringWithFormat:@"%@",showInfo]];
        }
        
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
    CGImageRelease(cgImage);
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
    
    CGFloat labelH = (NSInteger)(rect.size.height - coverRect.size.height - kDefaultMargin * 2) / 2;
    
    [_recordUserHead sizeWith:CGSizeMake(44, 44)];
    [_recordUserHead layoutBelow:_recordCover margin:kDefaultMargin];
    [_recordUserHead alignParentLeftWithMargin:kDefaultMargin];
    
    [_recordTitle sizeWith:CGSizeMake(rect.size.width, labelH)];
    [_recordTitle layoutToRightOf:_recordUserHead margin:kDefaultMargin];
    [_recordTitle layoutBelow:_recordCover margin:kDefaultMargin];
    
    [_recordTime sizeWith:CGSizeMake(rect.size.width, labelH)];
    [_recordTime layoutToRightOf:_recordUserHead margin:kDefaultMargin];
    [_recordTime layoutBelow:_recordTitle];
}


@end
