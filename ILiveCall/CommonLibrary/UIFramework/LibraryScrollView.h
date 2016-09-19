//
//  LibraryScrollView.h
//  
//
//  Created by Alexi on 3/12/14.
//  Copyright (c) 2014 Harman. All rights reserved.
//
#if kSupportLibraryPage
#import "PageScrollView.h"


@interface LibraryScrollView : PageScrollView

@property (nonatomic, weak) UIViewController *ownController;
@end
#endif