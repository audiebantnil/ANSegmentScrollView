//
//  ANSegmentScrollView.h
//  ANSegmentScrollView
//
//  Created by AudiebantNil on 2017/11/16.
//  Copyright © 2017年 AudiebantNil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ANSegmentScrollStyle.h"
#import "ANSegmentScrollViewDelegate.h"

@interface ANSegmentScrollView : UIView

/**
 初始化方法
 @param frame frame
 @param style 可创建自定义的 ANSegmentScrollStyle
 @param segmentTitles 横向滑动菜单栏标题数组
 @param headerView 顶部视图
 @param headerHeight 顶部视图高度
 @param parentVC 父控制器 (重写其 shouldAutomaticallyForwardAppearanceMethods 方法返回 NO 可正常调用子控制器的生命周期系统方法, 否则除了"viewDidLoad"外其他方法不会被正常调用, 请实现子控制器代理 ANSSChildVCsDelegate 方法来代替系统方法)
 @param delegate 视图代理
 @return ANSegmentScrollView
 */
- (instancetype)initWithFrame:(CGRect)frame
           segmentScrollStyle:(ANSegmentScrollStyle *)style
                segmentTitles:(NSArray <NSString *>*)segmentTitles
                   headerView:(UIView *)headerView
                 headerHeight:(CGFloat)headerHeight
                     parentVC:(UIViewController *)parentVC
                     delegate:(id <ANSegmentScrollViewDelegate>)delegate;

/** 可以设置下拉刷新的 Table View -> e.g: segmentScrollView.pullToRefreshTableView.mj_header = ... */
@property (nonatomic, weak) UITableView *pullToRefreshTableView;

/** 当前子控制器 */
- (UIViewController<ANSSChildVCsDelegate> *)currentChildViewController;

/** 当前子控制器序号 */
- (NSInteger)currentViewControllerIndex;

@end
