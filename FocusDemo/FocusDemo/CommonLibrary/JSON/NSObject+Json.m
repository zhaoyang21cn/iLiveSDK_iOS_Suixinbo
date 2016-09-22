//
//  NSObject+Json.m
//
//
//  Created by Alexi on 12-11-15.
//  Copyright (c) 2012年 . All rights reserved.
//

#import "NSObject+Json.h"
#import <objc/runtime.h>

#import "JSONKit.h"

#import "IOSDeviceConfig.h"

@implementation NSObject (Json)

#define kServiceTag_ID @"id"

- (void)setIdPropertyValue:(id)idkeyValue
{
    // for the subclass to do
}

/*
 * 对于格式如下的方法，使用以下接口进行反序化
 * [{itemClass对应的json串},{itemClass对应的json串}...]
 * 参数说明:
 * itemClass: json列表中单个数据对要反序列化成的对像类型
 * arraydict: json列表
 */
+ (NSMutableArray *)loadItem:(Class)itemClass fromArrayDictionary:(NSArray *)arraydict
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for (NSDictionary *dic in arraydict ) {
        if (dic) {
            id value = [NSObject parse:itemClass dictionary:dic];
            [array addObject:value];
        }
    }
    return CommonReturnAutoReleased(array);
}

/*
 *
 */

- (void)setValueForPropertyValue:(id)idkeyValue forKey:(NSString *)key propertyClass:(Class)cls tagretClass:(Class)targetCls
{
    if ([idkeyValue isKindOfClass:[NSDictionary class]])
    {
        // 说明要赋值的属性是NSObject的子类
        id value = [NSObject parse:targetCls dictionary:idkeyValue itemClass:cls];
        [self setValue:value forKey:key];
    }
    else if ([idkeyValue isKindOfClass:[NSArray class]])
    {
        //        NSMutableArray *array = [[NSMutableArray alloc] init];
        //        for (NSDictionary *dic in idkeyValue ) {
        //            if (dic) {
        //                id value = [NSObject parse:cls dictionary:dic];
        //                [array addObject:value];
        //            }
        //        }
        //
        //        [self setValue:array forKey:key];
        //        [array release];
        // 说明要赋值的属性是一个列表
        NSMutableArray *arrayValue = (NSMutableArray *)[NSObject loadItem:cls fromArrayDictionary:idkeyValue];
        
        [self setValue:arrayValue forKey:key];
    }
}

// 遍历

- (void)enumerateProperty:(NSString *)propertyName value:(id)idvalue propertyDictionary:(NSDictionary *)propertyKeys
{
    if ([idvalue isKindOfClass:[NSNull class]])
    {
        NSString *proClsName = [propertyKeys objectForKey:propertyName];
        if ([proClsName hasPrefix:@"T@"])
        {
            [self setValue:nil forKey:propertyName];
        }
        else
        {
            NSNumber *num = [NSNumber numberWithInteger:0];
            [self setValue:num forKey:propertyName];
        }
    }
    else
    {
        if (idvalue)
        {
            NSString *proClsName = [propertyKeys objectForKey:propertyName];
            
            if ([proClsName hasPrefix:@"T@"])
            {
                NSRange range = [proClsName rangeOfString:@"\""];
                NSString *test = [proClsName substringFromIndex:range.location+1];
                range = [test rangeOfString:@"\""];
                NSString *realClassName = [test substringToIndex:range.location];
                Class proCls = NSClassFromString(realClassName);
                
                if ([idvalue isKindOfClass:proCls] && ![idvalue isKindOfClass:[NSMutableArray class]] && ![idvalue isKindOfClass:[NSMutableDictionary class]])
                {
                    [self setValue:idvalue forKey:propertyName];
                }
                else
                {
                    [self setValueForPropertyValue:idvalue forKey:propertyName propertyClass:proCls tagretClass:proCls];
                }
            }
            else
            {
                if ([idvalue isKindOfClass:[NSDecimalNumber class]]) {
                    NSDecimalNumber *num = (NSDecimalNumber *)idvalue;
                    [self setValue:num forKey:propertyName];
                }
                else
                {
                    NSNumber *num = (NSNumber *)idvalue;
                    [self setValue:num forKey:propertyName];
                    
                }
            }
        }
        
    }
    
}

+ (id)parse:(Class)aClass dictionary:(NSDictionary *)dict
{
    
    id aClassInstance = [[aClass alloc] init];
    CommonAutoRelease(aClassInstance);
    
    // 因JSON返回的字段中有id
    // 所以对此数据作特处理
    id idTagValue = [dict objectForKey:kServiceTag_ID];
    if (idTagValue) {
        [aClassInstance setIdPropertyValue:idTagValue];
    }
    
    // 将返回的Json键与aClassInstance的属性列表进行一次对比，找出要赋值的属性，以减少不必要的运算
    NSDictionary *propertyKeys = [aClassInstance enumerateKeysInDictionary:dict];
    CommonRetain(propertyKeys);
    
    NSArray *propertyKeysArray = [propertyKeys allKeys];
    
    // 逐一对相关的属性进行设置
    for (unsigned int i = 0 ; i < propertyKeysArray.count; i++ )
    {
        NSString *propertyName = [propertyKeysArray objectAtIndex:i];
        id idvalue = [dict objectForKey:propertyName];
        
        // propertyName：要设置的属性名
        // idvalue：对应的值
        [aClassInstance enumerateProperty:propertyName value:idvalue propertyDictionary:propertyKeys];
    }
    
    CommonRelease(propertyKeys);
    return aClassInstance;
}

- (NSMutableDictionary *)propertyListOfClass:(Class)class
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    unsigned int propertyCount = 0;
    objc_property_t *propertyList = class_copyPropertyList(class, &propertyCount);
    for (unsigned int i = 0 ; i < propertyCount; i++ )
    {
        const char *pcName = property_getName(propertyList[i]);
        NSString *propertyName = [NSString stringWithCString:pcName encoding:NSUTF8StringEncoding];
        
        const char *proClsNameCStr = property_getAttributes(propertyList[i]);
        NSString *proClsName = [NSString stringWithCString:proClsNameCStr encoding:NSUTF8StringEncoding];
        [dic setObject:proClsName forKey:propertyName];
        
    }
    free(propertyList);
    
    if (class != [NSObject class])
    {
        // 去掉NSObject里面的属性
        NSMutableDictionary *ObjectClass = [self propertyListOfClass:[NSObject class]];
        
        [dic removeObjectsForKeys:[ObjectClass allKeys]];
        
        // iOS8以前dic会加上这几个不用的键值 @[@"debugDescription", @"description", @"hash", @"superclass"]
        if (![IOSDeviceConfig sharedConfig].isIOS7Later)
        {
            [dic removeObjectsForKeys:@[@"debugDescription", @"description", @"hash", @"superclass"]];
        }
//        {
//            debugDescription = "T@\"NSString\",R,C";
//            description = "T@\"NSString\",R,C";
//            hash = "TQ,R";
//            pageIndex = "Tq,N,V_pageIndex";
//            pageSize = "Tq,N,V_pageSize";
//            superclass = "T#,R";
//        }
    }
    
    
    
    
    return dic;
}

// 返回class的所有属性列表（包括当前类至NSObject类的之间所有继承关系对象的列表）
- (void)propertyListOfClass:(Class)class propertyList:(NSMutableDictionary *)propertyDic
{
    if (class == [NSObject class])
    {
        return;
    }
    else
    {
        // 添加class属性列表到返回结果里面
        NSDictionary *selfDic = [self propertyListOfClass:class];
        [propertyDic addEntriesFromDictionary:selfDic];
        
        // 继续查找class的父类
        Class superClass = class_getSuperclass(class);
        [self propertyListOfClass:superClass propertyList:propertyDic];
    }
    
}


// 通过返回的Json字典valueDict的keys,过滤出需要设置的属性名名称及对应的类型
// 返回：过滤后需要设置的（）

- (NSDictionary *)enumerateKeysInDictionary:(NSDictionary *)valueDict
{
    NSUInteger propertyCount = 0;
    
    NSMutableDictionary *propertyKeys = [[NSMutableDictionary alloc] init];
    CommonAutoRelease(propertyKeys);
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [self propertyListOfClass:[self class] propertyList:dic];
    
    NSArray *dicKeys = [dic allKeys];
    propertyCount = dicKeys.count;
    
    NSArray *valueDictKeys = [valueDict allKeys];
    
    for (int i = 0; i < propertyCount; i++) {
        NSString *propertyName = [dicKeys objectAtIndex:i];
        
        if ([valueDictKeys containsObject:propertyName])
        {
            [propertyKeys setObject:[dic valueForKey:propertyName] forKey:propertyName];
        }
    }
    
    return propertyKeys;
}


- (void)enumerateProperty:(NSString *)propertyName value:(id)idvalue propertyDictionary:(NSDictionary *)propertyKeys itemClass:(Class)itemClass
{
    if ([idvalue isKindOfClass:[NSNull class]])
    {
        [self setValue:nil forKey:propertyName];
    }
    else
    {
        if (idvalue)
        {
            NSString *proClsName = [propertyKeys objectForKey:propertyName];
            
            if ([proClsName hasPrefix:@"T@"])
            {
                NSRange range = [proClsName rangeOfString:@"\""];
                NSString *test = [proClsName substringFromIndex:range.location+1];
                range = [test rangeOfString:@"\""];
                NSString *realClassName = [test substringToIndex:range.location];
                Class proCls = NSClassFromString(realClassName);
                
                if ([idvalue isKindOfClass:proCls] && ![idvalue isKindOfClass:[NSMutableArray class]] && ![idvalue isKindOfClass:[NSMutableDictionary class]])
                {
                    [self setValue:idvalue forKey:propertyName];
                }
                else
                {
                    [self setValueForPropertyValue:idvalue forKey:propertyName propertyClass:itemClass tagretClass:proCls];
                }
            }
            else
            {
                if ([idvalue isKindOfClass:[NSDecimalNumber class]]) {
                    NSDecimalNumber *num = (NSDecimalNumber *)idvalue;
                    [self setValue:num forKey:propertyName];
                }
                else
                {
                    NSNumber *num = (NSNumber *)idvalue;
                    [self setValue:num forKey:propertyName];
                    
                }
                
            }
        }
        
    }
    
}


+ (id)parse:(Class)aClass dictionary:(NSDictionary *)dict itemClass:(Class)itemClass
{
    id aClassInstance = [[aClass alloc] init];
    CommonAutoRelease(aClassInstance);
    
    // 因ＪＳＯＮ返回的字段中有id
    // 所以对此数据作特处理
    id idTagValue = [dict objectForKey:kServiceTag_ID];
    if (idTagValue) {
        [aClassInstance setIdPropertyValue:idTagValue];
    }
    
    NSDictionary *propertyKeys = [aClassInstance enumerateKeysInDictionary:dict];
    CommonRetain(propertyKeys);
    
    NSArray *propertyKeysArray = [propertyKeys allKeys];
    for (unsigned int i = 0 ; i < propertyKeysArray.count; i++ )
    {
        NSString *propertyName = [propertyKeysArray objectAtIndex:i];
        id idvalue = [dict objectForKey:propertyName];
        [aClassInstance enumerateProperty:propertyName value:idvalue propertyDictionary:propertyKeys itemClass:itemClass];
        
    }
    CommonRelease(propertyKeys);
    //    [propertyKeys release];
    
    return aClassInstance;
    
}


+ (id)parse:(Class)aClass jsonString:(NSString *)json
{
    NSDictionary *dic = [json objectFromJSONString];
    return dic ? [NSObject parse:aClass dictionary:dic] : nil;
}

+ (id)parse:(Class)aClass jsonString:(NSString *)json itemClass:(Class)itemClass
{
    NSDictionary *dic = [json objectFromJSONString];
    return dic ? [NSObject parse:aClass dictionary:dic itemClass:itemClass] : nil;
}

+ (NSMutableArray *)loadItem:(Class)itemClass fromDictionary:(NSArray *)arraydict
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for (NSDictionary *dic in arraydict ) {
        if (dic) {
            // 遍历数据中单个字典元素，将期反序列化成itemClass对象实例
            id value = [NSObject parse:itemClass dictionary:dic];
            [array addObject:value];
        }
    }
    return CommonReturnAutoReleased(array);
}
+ (NSMutableArray *)loadItem:(Class)itemClass fromJsonString:(NSString *)json
{
    NSArray *dic = [json objectFromJSONString];
    return dic ? [NSObject loadItem:itemClass fromJsonString:json] : nil;
}

- (id)serializeToJsonObject
{
    if ([NSJSONSerialization isValidJSONObject:self])
    {
        return self;
    }
    
    if ([self isMemberOfClass:[NSObject class]])
    {
        // 解析到此
        return nil;
    }
    
    NSMutableDictionary *jsonDic = [NSMutableDictionary dictionary];
    
    // 将返回的Json键与aClassInstance的属性列表进行一次对比，找出要赋值的属性，以减少不必要的运算
    NSMutableDictionary *propertyKeys = [NSMutableDictionary dictionary];
    
    [self propertyListOfClass:[self class] propertyList:propertyKeys];
    
    NSArray *propertyKeysArray = [propertyKeys allKeys];
    
    // 逐一对相关的属性进行设置
    for (unsigned int i = 0 ; i < propertyKeysArray.count; i++ )
    {
        NSString *propertyName = [propertyKeysArray objectAtIndex:i];
        
        NSString *propertType = [propertyKeys valueForKey:propertyName];
        
        if ([propertType hasPrefix:@"T@"])
        {
            // 对应类
            id idvalue = [self valueForKey:propertyName];
            if (idvalue)
            {
                if ([idvalue isKindOfClass:[NSString class]])
                {
                    [jsonDic setObject:idvalue forKey:propertyName];
                }
                else
                {
                    id idvalueJson = [idvalue serializeToJsonObject];
                    if (idvalueJson)
                    {
                        [jsonDic setObject:idvalueJson forKey:propertyName];
                    }
                }
            }
    
        }
        else
        {
            // 基本数据类型
            id idvalue = [self valueForKey:propertyName];
            [jsonDic setObject:idvalue forKey:propertyName];
        }

    }
    
    return jsonDic;
}


// 把对象自身的属性序列化成Json字典, 以属性名作为键值
- (id)serializeSelfPropertyToJsonObject
{
    if ([NSJSONSerialization isValidJSONObject:self])
    {
        return self;
    }
    
    if ([self isMemberOfClass:[NSObject class]])
    {
        // 解析到此
        return nil;
    }
    
    NSMutableDictionary *jsonDic = [NSMutableDictionary dictionary];
    
    // 将返回的Json键与aClassInstance的属性列表进行一次对比，找出要赋值的属性，以减少不必要的运算
    NSMutableDictionary *propertyKeys = [self propertyListOfClass:[self class]];
    
    NSArray *propertyKeysArray = [propertyKeys allKeys];
    
    // 逐一对相关的属性进行设置
    for (unsigned int i = 0 ; i < propertyKeysArray.count; i++ )
    {
        NSString *propertyName = [propertyKeysArray objectAtIndex:i];
        
        NSString *propertType = [propertyKeys valueForKey:propertyName];
        
        if ([propertType hasPrefix:@"T@"])
        {
            // 对应类
            id idvalue = [self valueForKey:propertyName];
            if (idvalue)
            {
                if ([idvalue isKindOfClass:[NSString class]])
                {
                    NSString *stringValue = (NSString *)idvalue;
                    if (stringValue.length)
                    {
                        [jsonDic setObject:idvalue forKey:propertyName];
                    }
                    else
                    {
                        [jsonDic setObject:@"" forKey:propertyName];
                    }
                }
                else
                {
                    id idvalueJson = [idvalue serializeToJsonObject];
                    if (idvalueJson)
                    {
                        [jsonDic setObject:idvalueJson forKey:propertyName];
                    }
                }
            }
            
        }
        else
        {
            // 基本数据类型
            id idvalue = [self valueForKey:propertyName];
            [jsonDic setObject:idvalue forKey:propertyName];
        }
        
    }
    
    return jsonDic;
}

+ (id)loadInfo:(Class)aclass withKey:(NSString *)key
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *loginInfo = [ud objectForKey:key];
    if (loginInfo)
    {
        id ret = [NSObject parse:[aclass class] jsonString:loginInfo];
        if (ret)
        {
            return ret;
        }
        else
        {
            return loginInfo;
        }
    }
    return nil;
}


+ (void)saveInfo:(NSObject *)obj withKey:(NSString *)key
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if (obj)
    {
        if ([obj isKindOfClass:[NSString class]])
        {
            [ud setObject:obj forKey:key];
        }
        else
        {
            NSDictionary *dic = [obj serializeToJsonObject];
            
            if ([NSJSONSerialization isValidJSONObject:dic])
            {
                NSError *error = nil;
                NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
                if(error)
                {
                    DebugLog(@"存储失败");
                }
                NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                [ud setObject:str forKey:key];
            }
        }
        
        [ud synchronize];
    }
    else
    {
        [ud removeObjectForKey:key];
    }
}


@end


@implementation NSArray (serializeToJsonObject)

- (id)serializeToJsonObject
{
    if ([NSJSONSerialization isValidJSONObject:self])
    {
        return self;
    }
    
    NSMutableArray *array = [NSMutableArray array];
    for (id obj in self)
    {
        id jsonObj = [obj serializeToJsonObject];
        if (jsonObj)
        {
            [array addObject:jsonObj];
        }
    }
    
    if (array.count)
    {
        if ([NSJSONSerialization isValidJSONObject:array])
        {
            return array;
        }
    }
    
    DebugLog(@"[%@] can't convert to vaild Json", self);
    return nil;
}

@end

@implementation NSDictionary (serializeToJsonObject)

- (id)serializeToJsonObject
{
    if ([NSJSONSerialization isValidJSONObject:self])
    {
        return self;
    }
    return nil;
}

@end