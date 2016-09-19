//
//  NSObject+loadClass.h
//  CommonLibrary
//
//  Created by Alexi Chen on 2/28/13.
//  Copyright (c) 2013 AlexiChen. All rights reserved.
//

#import <Foundation/Foundation.h>


// 声明：
// 为了区分设备:(iphone ipad)上同一逻辑界面，不同的展现，以及不同的业务处理所封装
// 因为优先完成iphone相关逻辑，对于ipad上不同的处理，作选择性继承
// 命名规则：
// AClassName: iphone处理下相关的类名
// 如果判断当前是ipad时，那么使用以下方法时，发果发现本地有AClassName_Pad这个类，则创建AClassName_Pad相应的实例
// 否则则走iphone相关的逻辑

// 注意以下代码最好只在区分（iphone 与 ipad）上使用


@interface NSObject (loadClass)

- (void)configParams:(id)params;

+ (Class)getPadClass:(Class)phone;

// 等效于使用 [[newClass alloc] init]
+ (id)loadClass:(Class)newClass;
// 等效于使用 [[newClass alloc] initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil]
+ (id)loadClassFromNib:(Class)newClass;

// 等效于使用
// newClassInstance = [[newClass alloc] init]
// [newClassInstance configParams:params]

+ (id)loadClass:(Class)newClass withParams:(id)params;

// 等效于使用
// newClassInstance = [[newClass alloc] init]
// [newClassInstance configParams:params]

+ (id)loadClass:(Class)newClass withParams:(id)params withConfigSelector:(SEL)selector;


@end
