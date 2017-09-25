//
//  UploadImageHelper.m
//  PLUShow
//
//  Created by AlexiChen on 15/11/28.
//  Copyright © 2015年 AlexiChen. All rights reserved.
//

#import "UploadImageHelper.h"

#import "COSClient.h"


@interface UploadImageHelper ()
{
    COSClient *_cosClient;
}
@end

@implementation UploadImageHelper

static UploadImageHelper *_shareInstance = nil;

+ (instancetype)shareInstance;
{
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        _shareInstance = [[UploadImageHelper alloc] init];
    });
    return _shareInstance;
}

- (instancetype)init
{
    if (self = [super init])
    {
//        _cosClient = [[COSClient alloc] initWithAppId:@"1251659802" withRegion:@"tj"];
        _cosClient = [[COSClient alloc] initWithAppId:@"1253488539" withRegion:@"gz"];
    }
    return self;
}

- (void)upload:(UIImage *)image completion:(void (^)(NSString *imageSaveUrl))completion failed:(void (^)(NSString *failTip))failure
{
    LiveImageSignRequest *req = [[LiveImageSignRequest alloc] initWithHandler:^(BaseRequest *request) {
        LiveImageSignResponseData *respData = (LiveImageSignResponseData *)request.response.data;
        if (!respData.sign.length)
        {
            if (failure)
            {
                failure(@"上传图片SIG为空，无法上传");
            }
            return;
        }
        if (!image)
        {
            if (failure)
            {
                failure(@"图片为空，不能上传");
            }
            return;
        }
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSData *imageData = UIImageJPEGRepresentation(image, 0.3);
            // 以时间戳为文件名
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            NSString *cacheDirectory = [paths objectAtIndex:0];
            NSString *photoName = [[NSString alloc] initWithFormat:@"%3.f", [NSDate timeIntervalSinceReferenceDate]];
            NSString *pathSave = [cacheDirectory stringByAppendingPathComponent:photoName];
            BOOL succ = [imageData writeToFile:pathSave atomically:YES];
            if (!succ && failure)
            {
                failure(@"图片为空，不能上传");
                return ;
            }
            //1.保存文件成功 构造上传任务,
            COSObjectPutTask *task = [COSObjectPutTask new];
            task.filePath = pathSave;
            task.fileName = photoName;
            task.bucket = @"sxbbucket";
            task.attrs = @".png";
            task.directory = @"/";
            task.insertOnly = YES;
            task.sign = respData.sign;
            _cosClient.completionHandler = ^(COSTaskRsp *resp, NSDictionary *context){
                if (resp.retCode == 0)//sucess
                {
                    if (completion)
                    {
                        COSObjectUploadTaskRsp *uploadResp = (COSObjectUploadTaskRsp*)resp;
                        completion(uploadResp.sourceURL);
                    }
                }
                else
                {
                    if (failure)
                    {
                        failure(@"上传图片失败");
                    }
                }
            };
            _cosClient.progressHandler = ^(int64_t bytesWritten,int64_t totalBytesWritten,int64_t totalBytesExpectedToWrite){
                NSLog(@"Image upload %lld / %lld", totalBytesWritten, totalBytesExpectedToWrite);
            };
            [_cosClient putObject:task];
        });
    } failHandler:^(BaseRequest *request) {
    }];
    [[WebServiceEngine sharedEngine] asyncRequest:req];
}

@end
