//
//  QALJsonRequest.h
//  QALHttpSDK
//
//  Created by christbao on 16/3/1.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import "QALHttpRequest.h"

@interface QALJsonRequest : QALHttpRequest

-(NSMutableDictionary*)getJsonObject;

@end
