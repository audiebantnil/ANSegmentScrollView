//
//  ANSegmentScrollViewDelegate.h
//  ANSegmentScrollView
//
//  Created by AudiebantNil on 2017/11/16.
//  Copyright © 2017年 AudiebantNil. All rights reserved.
//

#ifndef ANSegmentScrollViewDelegate_h
#define ANSegmentScrollViewDelegate_h

#import <UIKit/UIKit.h>
@class ANMenuTitleView;

@protocol ANSSChildVCsDelegate <NSObject>

@required
/**
 创建子控制器的主滑动视图(可以为空)
 @return UIScrollView或其子类, 没有则 return nil
 */
- (UIScrollView *)an_scrollViewInSegmentChildViewController;

@optional
- (void)an_viewWillAppearAtIndex:(NSInteger)index;
- (void)an_viewDidAppearAtIndex:(NSInteger)index;
- (void)an_viewWillDisappearAtIndex:(NSInteger)index;
- (void)an_viewDidDisappearAtIndex:(NSInteger)index;

@end



@protocol ANSegmentScrollViewDelegate <NSObject>

@required
/**
 创建子控制器主方法 (如果子控制器内部需要使用"UITableView"请继承"ANSegmentChildTableView",同理"UICollectionView"请继承"ANSegmentChildCollectionView")
 @param reusableVC 复用的子控制器 (可能为nil)
 @param index 子控制器序号 (和标题序号对应)
 @return 对应序号需要展示的子控制器
 */
- (UIViewController<ANSSChildVCsDelegate> *)an_childVCFromReusableVC:(UIViewController<ANSSChildVCsDelegate> *)reusableVC forIndex:(NSInteger)index;

@optional

/**
 自定义标题
 @param titleView 可自定义的ANMenuTitleView
 @param index 标题序号(和子控制器序号对应)
 */
- (void)an_setupTitleView:(ANMenuTitleView *)titleView atIndex:(NSInteger)index;

/**
 点击同一标题事件(用于点击同一标题改变排序等操作)
 @param titleView 点击的ANMenuTitleView
 @param index 标题序号(和子控制器序号对应)
 */
- (void)an_tappedSameTitleView:(ANMenuTitleView *)titleView atIndex:(NSInteger)index;

/**
 子控制器即将出现
 @param parentVC 父控制器
 @param childVC 即将出现的子控制器
 @param index 子控制器序号
 */
- (void)parentVC:(UIViewController *)parentVC childVC:(UIViewController<ANSSChildVCsDelegate> *)childVC willAppearAtIndex:(NSInteger)index;

/**
 子控制器已经出现
 @param parentVC 父控制器
 @param childVC 已经出现的子控制器
 @param index 子控制器序号
 */
- (void)parentVC:(UIViewController *)parentVC childVC:(UIViewController<ANSSChildVCsDelegate> *)childVC didAppearAtIndex:(NSInteger)index;

/**
 子控制器即将消失
 @param parentVC 父控制器
 @param childVC 即将消失的子控制器
 @param index 子控制器序号
 */
- (void)parentVC:(UIViewController *)parentVC childVC:(UIViewController<ANSSChildVCsDelegate> *)childVC willDisappearAtIndex:(NSInteger)index;

/**
 子控制器已经消失
 @param parentVC 父控制器
 @param childVC 已经消失的子控制器
 @param index 子控制器序号
 */
- (void)parentVC:(UIViewController *)parentVC childVC:(UIViewController<ANSSChildVCsDelegate> *)childVC didDisappearAtIndex:(NSInteger)index;

@end


#endif /* ANSegmentScrollViewDelegate_h */
