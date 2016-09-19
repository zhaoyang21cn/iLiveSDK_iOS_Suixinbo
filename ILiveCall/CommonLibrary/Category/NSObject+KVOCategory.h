//
//  NSObject+KVOCategory.h
//  CommonLibrary
//
//  Created by Alexi on 5/16/14.
//  Copyright (c) 2014 Alexi. All rights reserved.
//




#if kSupportNSObjectKVOCategory
#import <Foundation/Foundation.h>

@interface NSObject (KVOCategory)


- (void)observedBy:(NSObject *)observer forKeyPaths:(NSArray *)keyPaths;

- (void)observedBy:(NSObject *)observer forKeyPaths:(NSArray *)keyPaths options:(NSKeyValueObservingOptions)options;

- (void)cancelObservedBy:(NSObject *)observer forKeyPaths:(NSArray *)keyPaths;

@end
#endif
