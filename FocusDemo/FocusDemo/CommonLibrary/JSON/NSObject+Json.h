//
//  NSObject+Json.h
//  Json反序列化代码
//
//  Created by Alexi on 12-11-15.
//  Copyright (c) 2012年. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 * 说明:
 * 使用该代码的前提: 因需要通过json中返回的key值，查找相应的数据类型，然后再进行赋
 * 所以在客户端在拿到服务端返回的json字符串后，客户端进行数据Modal定义时，Modal的属性名与json中的一致。
 * 举例如下:
 * 服务端返回的一个User对像的json串
 * {"name":"Alexi","age":26}
 * 那么本地定义如下:
 * @interface User : NSObject
 * {
 *      NSString *_name;
 *      NSInteger _age;
 * }
 *
 *  @property (nonatomic, copy) NSString *name;
 *  @property (nonatomic, assign) NSInteger age;
 *
 *  @end
 */



@interface NSObject (Json)


// 因Server端经常使用id作表字段，而objc中id是关键字，不能作为属性
// 所以解析前，先检查有不有id字段
// 如果有，则对属性进行赋值
// 具体由子类进行重写
- (void)setIdPropertyValue:(id)idkeyValue;

// 设置复杂对象
- (void)setValueForPropertyValue:(id)idkeyValue forKey:(NSString *)key propertyClass:(Class)cls tagretClass:(Class)targetCls;

// 将json数据反序列化成一个对象
// Json格式如下：
/*
    {"name":"Alexi","age":26,"studentId":"06061096","QQ":"403725592"}
 */
+ (id)parse:(Class)aClass jsonString:(NSString *)json;
+ (id)parse:(Class)aClass dictionary:(NSDictionary *)dict;


// 对于格式如下的方法，使用以下接口进行反序化
/*
 * [{itemClass对应的json串},{itemClass对应的json串}...]
 */

+ (NSMutableArray *)loadItem:(Class)itemClass fromDictionary:(NSArray *)arraydict;
+ (NSMutableArray *)loadItem:(Class)itemClass fromJsonString:(NSString *)json;
+ (NSMutableArray *)loadItem:(Class)itemClass fromArrayDictionary:(NSArray *)arraydict;


// 将json数据反序列化成一个对象
// 缺点 ： 不能解格嵌套的数组
// Json格式如下：
/*
 {"name":"Alexi","age":26,"studentId":"06061096","QQ":"403725592",bookItems:[{bookItemClass对应的json串},{bookItemClass对应的json串}...]}
 */
+ (id)parse:(Class)aClass dictionary:(NSDictionary *)dict itemClass:(Class)itemClass;
+ (id)parse:(Class)aClass jsonString:(NSString *)json itemClass:(Class)itemClass;

// 目前代码中存在以下问题，后期再进行更新
// 对于Json格式如下的数据不能直接反序列化成对象：
/*
    {"name":"Alexi","age":26,"studentId":"06061096","QQ":"403725592",bookItems:[{bookItemClass对应的json串},{bookItemClass对应的json串}...],friends:[{friendClass对应的json串},{friendClass对应的json串}...]}
 
 * 可先调用
 * [NSObject parse:[User class] dictionary:dict]; 将一些普通的属性进行设置
 * 然后再获取到
 * bookItems对应的Json列表: NSArray *bookItemJsonArray = [dict objectForKey:@"bookItems"];
 * self.bookItems = [self loadItem:[BookItem class] fromDictionary:bookItemJsonArray];
 * 同理可对friends进行设置
 */


- (void)propertyListOfClass:(Class)aclass propertyList:(NSMutableDictionary *)propertyDic;
// 把对象的属性(会将其至基类NSObject的所有属性)序列化成Json字典, 以属性名作为键值
- (id)serializeToJsonObject;

// 把对象自身的属性序列化成Json字典, 以属性名作为键值
- (id)serializeSelfPropertyToJsonObject;

+ (id)loadInfo:(Class)aclass withKey:(NSString *)key;

+ (void)saveInfo:(NSObject *)obj withKey:(NSString *)key;
@end


@interface NSArray (serializeToJsonObject)

- (id)serializeToJsonObject;

@end

@interface NSDictionary (serializeToJsonObject)

- (id)serializeToJsonObject;

@end
