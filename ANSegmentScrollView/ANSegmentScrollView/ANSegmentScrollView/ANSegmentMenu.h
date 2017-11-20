//
//  ANSegmentMenu.h
//  ANSegmentScrollView
//
//  Created by AudiebantNil on 2017/11/15.
//  Copyright © 2017年 AudiebantNil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ANSegmentScrollViewDelegate.h"
@class ANSegmentScrollStyle;
@class ANMenuTitleView;

/**
 标题点击事件block
 @param titleView 单个标题视图 ANMenuTitleView
 @param titleIndex 标题序号
 */
typedef void(^TitleClickBlock)(ANMenuTitleView *titleView, NSInteger titleIndex);

@interface ANSegmentMenu : UIView

@property (nonatomic, copy) NSArray <NSString *>*segmentTitles;

/**
 初始化主方法
 @param frame frame
 @param style 可创建自定义的 ANSegmentScrollStyle
 @param titles 横向滑动菜单栏标题数组
 @param delegate 视图代理
 @param titleClickBlock 标题点击事件block
 @return ANSegmentMenu
 */
- (instancetype)initWithFrame:(CGRect)frame
                        style:(ANSegmentScrollStyle *)style
                       titles:(NSArray <NSString *>*)titles
                     delegate:(id<ANSegmentScrollViewDelegate>)delegate
              titleClickBlock:(TitleClickBlock)titleClickBlock;

/**
 滑动过程中渐变量设置
 @param progress 进度
 @param oldIndex 上一次序号
 @param currentIndex 当前序号
 */
- (void)adjustUIWithProgress:(CGFloat)progress
                   fromIndex:(NSInteger)oldIndex
                     toIndex:(NSInteger)currentIndex;

/**
 选中标题设置居中
 @param currentIndex 当前序号
 */
- (void)adjustTitleOffsetAtIndex:(NSInteger)currentIndex;

@end
