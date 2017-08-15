//
//  LiveImageSignRequest.h
//  TCShow
//
//  Created by AlexiChen on 16/5/3.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "BaseRequest.h"

@interface LiveImageSignRequest : BaseRequest

@end

@interface LiveImageSignResponseData : BaseResponseData

@property (nonatomic, copy) NSString *sign;

@end
