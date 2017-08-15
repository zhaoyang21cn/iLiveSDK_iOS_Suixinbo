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
        self.dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
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
    
    _recordDuration = [[UILabel alloc] init];
    _recordDuration.textAlignment = NSTextAlignmentCenter;
    _recordDuration.font = kAppSmallTextFont;
    _recordDuration.textColor = kColorBlack60;
    [self.contentView addSubview:_recordDuration];
    
    _recordFileSize = [[UILabel alloc] init];
    _recordFileSize.textAlignment = NSTextAlignmentCenter;
    _recordFileSize.font = kAppSmallTextFont;
    _recordFileSize.textColor = kColorBlack60;
    [self.contentView addSubview:_recordFileSize];
}

- (void)configWith:(RecordVideoItem *)item;
{
    if (!item)
    {
        return;
    }
    _item = item;
    __weak typeof(self)ws = self;
    
    //封面
    [_recordCover setImage:[UIImage imageNamed:@"defaul_publishcover"]];
    if (_item.cover && _item.cover.length > 0) {
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:_item.cover]];
        UIImage *image = [[UIImage alloc] initWithData:data];
        [_recordCover setImage:image];
    }
    
    //设置用户头像
    [_recordUserHead setBackgroundImage:[UIImage imageNamed:@"default_head"] forState:UIControlStateNormal];
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

    //录制文件名 和 录制用户
    if (_item.name && _item.uid) {
        NSMutableString *recordInfo = [NSMutableString string];
        [recordInfo appendString:_item.name];
        
        [recordInfo appendFormat:@"      @%@",item.uid];
        
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:recordInfo];
        [attrStr addAttribute:NSForegroundColorAttributeName value:kColorBlack range:NSMakeRange(0, _item.name.length)];
        [attrStr addAttribute:NSFontAttributeName value:kAppMiddleTextFont range:NSMakeRange(0, _item.name.length)];
        [attrStr addAttribute:NSForegroundColorAttributeName value:kColorBlack60 range:NSMakeRange(_item.name.length, recordInfo.length-_item.name.length)];
        [attrStr addAttribute:NSFontAttributeName value:kAppSmallTextFont range:NSMakeRange(_item.name.length, recordInfo.length-_item.name.length)];
        
        [_recordTitle setAttributedText:attrStr];
        
    }
    //录制时间
    if (_item.createTime)
    {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[_item.createTime integerValue]];
        NSString *timeStr = [self.dateFormatter stringFromDate:date];
        [_recordTime setText:[NSString stringWithFormat:@"%@",timeStr]];
    }
    
    //录制时长
    if (_item.duration) {
        NSInteger duration = [_item.duration integerValue];
        NSInteger sec = duration % 60;
        NSInteger minu = (duration/60) % 60;
        NSInteger hour = duration/3600;
        if (hour>0)
        {
            NSString *showTime = [NSString stringWithFormat:@"%2ld小时%2ld分%2ld秒",hour,minu,sec];
            [_recordDuration setText:showTime];
        }
        else
        {
            if (minu>0)
            {
                NSString *showTime = [NSString stringWithFormat:@"%2ld分%2ld秒",minu,sec];
                [_recordDuration setText:showTime];
            }
            else
            {
                NSString *showTime = [NSString stringWithFormat:@"%2ld秒",sec];
                [_recordDuration setText:showTime];
            }
        }
    }

    //录制文件大小
    if (_item.fileSize) {
        NSString *size = [self convertFileSize:[_item.fileSize integerValue]];
        [_recordFileSize setText:size];
    }
}

- (NSString *)convertFileSize:(long long)size
{
    long kb = 1024;
    long mb = kb * 1024;
    long gb = mb * 1024;
    
    if (size >= gb) {
        return [NSString stringWithFormat:@"%.1fGB", (float) size / gb];
    } else if (size >= mb) {
        float f = (float) size / mb;
        if (f > 100) {
            return [NSString stringWithFormat:@"%.0fMB", f];
        }else{
            return [NSString stringWithFormat:@"%.1fMB", f];
        }
    } else if (size >= kb) {
        float f = (float) size / kb;
        if (f > 100) {
            return [NSString stringWithFormat:@"%.0fKB", f];
        }else{
            return [NSString stringWithFormat:@"%.1fKB", f];
        }
    } else
        return [NSString stringWithFormat:@"%lldB", size];
}

//手动录制时用下面的逻辑（目前随心播中已经改成自动录制）
//- (void)configWith:(RecordVideoItem *)item;
//{
//    if (!item)
//    {
//        return;
//    }
//    _item = item;
//    
//    //懒加载封面
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        NSString *path = [self downAndSaveToLocal];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (path)
//            {
//                UIImage *image = [UIImage imageWithContentsOfFile:path];
//                [_recordCover setImage:image];
//            }
//        });
//    });
//    [_recordCover setImage:[UIImage imageNamed:@"defaul_publishcover"]];
//    
//    __weak typeof(self)ws = self;
//    //设置用户头像
//    [[TIMFriendshipManager sharedInstance] GetUsersProfile:@[item.uid] succ:^(NSArray *friends) {
//        if (friends.count <= 0)
//        {
//            return ;
//        }
//        TIMUserProfile *profile = friends[0];
//        if (profile.faceURL && profile.faceURL.length > 0)
//        {
//            NSURL *avatarUrl = [NSURL URLWithString:profile.faceURL];
//            NSData *avatarData = [NSData dataWithContentsOfURL:avatarUrl];
//            UIImage *image = [UIImage imageWithData:avatarData];
//            if ([NSThread isMainThread])
//            {
//                [ws.recordUserHead setBackgroundImage:image forState:UIControlStateNormal];
//            }
//            else
//            {
//                dispatch_sync(dispatch_get_main_queue(), ^{
//                    [ws.recordUserHead setBackgroundImage:image forState:UIControlStateNormal];
//                });
//            }
//        }
//    } fail:nil];
//    [_recordUserHead setBackgroundImage:[UIImage imageNamed:@"default_head"] forState:UIControlStateNormal];
//    
//    NSArray *array = [item.name componentsSeparatedByString:@"_"];
//    NSMutableString *recordInfo = [NSMutableString string];
//    if (array.count > 2)//录制文件名
//    {
//        NSString *fileName = array[2];
//        [recordInfo appendString:fileName];
//        
//        NSString *identifier = array[1];
//        [recordInfo appendFormat:@"      @%@",identifier];
//        
//        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:recordInfo];
//        [attrStr addAttribute:NSForegroundColorAttributeName value:kColorBlack range:NSMakeRange(0, fileName.length)];
//        [attrStr addAttribute:NSFontAttributeName value:kAppMiddleTextFont range:NSMakeRange(0, fileName.length)];
//        [attrStr addAttribute:NSForegroundColorAttributeName value:kColorBlack60 range:NSMakeRange(fileName.length, recordInfo.length-fileName.length)];
//        [attrStr addAttribute:NSFontAttributeName value:kAppSmallTextFont range:NSMakeRange(fileName.length, recordInfo.length-fileName.length)];
//        
//        [_recordTitle setAttributedText:attrStr];
//    }
//    if (array.count > 3)//录制时间
//    {
//        NSString *recStartTime = array[array.count-2];//倒数第二个是开始时间
//        NSArray *recStartTimeArray = [recStartTime componentsSeparatedByString:@"-"];
//        NSMutableString *dateString = [NSMutableString string];
//        NSMutableString *timeString = [NSMutableString string];
//        if (recStartTimeArray.count >= 6)
//        {
//            for (int index = 0; index < 3; index++)
//            {
//                [dateString appendFormat:@"%@-",recStartTimeArray[index]];
//            }
//            for (int index = 3; index < 6; index++)
//            {
//                [timeString appendFormat:@"%@:",recStartTimeArray[index]];
//            }
//            NSString *resultDate = [dateString substringToIndex:dateString.length-1];
//            NSString *resultTime = [timeString substringToIndex:timeString.length-1];
//            NSString *showInfo = [NSString stringWithFormat:@"%@  %@",resultDate,resultTime];
//            [_recordTime setText:[NSString stringWithFormat:@"%@",showInfo]];
//        }
//        
//    }
//}
//
//- (NSString *)isExitsFile:(NSString *)videoId
//{
//    NSString *tempDir = NSTemporaryDirectory();
//    NSString *snapshotPath = [NSString stringWithFormat:@"%@%@", tempDir, videoId];
//    
//    if ([[NSFileManager defaultManager] fileExistsAtPath:snapshotPath])
//    {
//        return snapshotPath;
//    }
//    return nil;
//}
//
//- (NSString *)downAndSaveToLocal
//{
////    (NSString *)urlStr videoId:(NSString *)videoId
//    if (!_item)
//    {
//        return nil;
//    }
//    if (_item.playurl.count <= 0)
//    {
//        return nil;
//    }
//    NSString *urlStr = _item.playurl[0];
//    if (!(urlStr && urlStr.length > 0))
//    {
//        return nil;
//    }
//    NSString *videoId = _item.videoId;
//    //判断截图文件是否存在
//    NSString *path = [self isExitsFile:videoId];
//    if (path)
//    {
//        return path;
//    }
//    NSString *tempDir = NSTemporaryDirectory();
//    path = [NSString stringWithFormat:@"%@%@", tempDir, videoId];
//    //视频截图
//    AVURLAsset *urlAsset = [[AVURLAsset alloc] initWithURL:[NSURL URLWithString:urlStr] options:nil];
//    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:urlAsset];
//    imageGenerator.appliesPreferredTrackTransform = YES;   // 截图的时候调整到正确的方向
//    CMTime time = CMTimeMakeWithSeconds(1.0, 30);          // 1.0为截取视频1.0秒处的图片，30为每秒30帧
//    CGImageRef cgImage = [imageGenerator copyCGImageAtTime:time actualTime:nil error:nil];
//    UIImage *image = [UIImage imageWithCGImage:cgImage];
//    //            CGRect rect = self.contentView.bounds;
//    //            CGSize size = CGSizeMake(rect.size.width, rect.size.width*0.618);
//    //            UIGraphicsBeginImageContext(size);
//    //            // 绘制改变大小的图片
//    //            [image drawInRect:CGRectMake(0,0, size.width,size.height)];
//    //            // 从当前context中创建一个改变大小后的图片
//    //            UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
//    CGImageRelease(cgImage);
//    NSData *snapshotData = UIImageJPEGRepresentation(image, 0.75);
//    if (![[NSFileManager defaultManager] createFileAtPath:path contents:snapshotData attributes:nil])
//    {
//        return nil;
//    }
//    return path;
//}
//
//- (void)setCoverImage:(NSString *)path
//{
//    if (path && path.length > 0)
//    {
//        UIImage *image = [UIImage imageWithContentsOfFile:path];
//        if (image)
//        {
//            [_recordCover setImage:image];
//        }
//    }
//}

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
    
    [_recordTime sizeWith:CGSizeMake(rect.size.width/2-25, labelH)];
    [_recordTime layoutToRightOf:_recordUserHead margin:kDefaultMargin];
    [_recordTime layoutBelow:_recordTitle];
    
    [_recordDuration sizeWith:CGSizeMake(rect.size.width/5, labelH)];
    [_recordDuration layoutToRightOf:_recordTime];
    [_recordDuration layoutBelow:_recordTitle];
    
    [_recordFileSize sizeWith:CGSizeMake(rect.size.width/5, labelH)];
    [_recordFileSize layoutToRightOf:_recordDuration];
    [_recordFileSize layoutBelow:_recordTitle];
}


@end
