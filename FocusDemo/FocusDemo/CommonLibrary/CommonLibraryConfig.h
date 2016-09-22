//
//  CommonLibraryConfig.h
//  CommonLibrary
//
//  Created by AlexiChen on 16/1/29.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#ifndef CommonLibraryConfig_h
#define CommonLibraryConfig_h

// CommonLibrary中的样式配置

#ifndef kAppBakgroundColor
// 背景色
#define kAppBakgroundColor          kWhiteColor
#endif

#ifndef kAppModalBackgroundColor
// 模态框内容背景色
#define kAppModalBackgroundColor    [kBlackColor colorWithAlphaComponent:0.6]
#endif

#ifndef kAppModalDimbackgroundColor
// 模态框dim的背景色
#define kAppModalDimbackgroundColor [RGB(16, 16, 16) colorWithAlphaComponent:0.3]
#endif

// 导航主色调
#ifndef kNavBarThemeColor
#define kNavBarThemeColor             nil
#endif

#ifndef kDefaultCellHeight
// 默认TableViewCell高度
#define kDefaultCellHeight 50
#endif

#ifndef kDefaultMargin
// 默认界面之间的间距
#define kDefaultMargin     8
#endif

#ifndef kMainTextColor
// 默认的字体颜色
#define kMainTextColor                kBlackColor
#endif

#ifndef kDetailTextColor
#define kDetailTextColor              RGB(145, 145, 145)
#endif

#ifndef kDownRefreshLoadOver
#define kDownRefreshLoadOver    @"没有更多了"
#endif

#ifndef kDownReleaseToRefresh
#define kDownReleaseToRefresh   @"松开即可更新..."
#endif

#ifndef kDownDragUpToRefresh
#define kDownDragUpToRefresh    @"上拉即可更新..."
#endif

#ifndef kDownRefreshLoading
#define kDownRefreshLoading     @"加载中..."
#endif


#ifndef kCommonLargeTextFont
// CommonLibrary中常用的字体
#define kCommonLargeTextFont       [UIFont systemFontOfSize:16]
#endif

#ifndef kCommonMiddleTextFont
#define kCommonMiddleTextFont      [UIFont systemFontOfSize:14]
#endif

#ifndef kCommonSmallTextFont
#define kCommonSmallTextFont       [UIFont systemFontOfSize:12]
#endif

#endif /* CommonLibraryConfig_h */
