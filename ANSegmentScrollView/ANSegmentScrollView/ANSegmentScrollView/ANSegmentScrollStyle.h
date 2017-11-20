//
//  ANSegmentScrollStyle.h
//  ANSegmentScrollView
//
//  Created by AudiebantNil on 2017/11/15.
//  Copyright © 2017年 AudiebantNil. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 Segment Menu 菜单栏标题图片位置 (相对于标题 如需要设置在菜单栏最底部 请设置下划线图片属性 scrollLineImageName)
 - TitleImagePositionLeft: 左侧
 - TitleImagePositionRight: 右侧
 - TitleImagePositionTop: 上部
 - TitleImagePositionCenter: 中心
 */
typedef NS_ENUM(NSInteger, TitleImagePosition) {
    TitleImagePositionLeft,
    TitleImagePositionRight,
    TitleImagePositionTop,
    TitleImagePositionCenter
};

/**
 下拉刷新控件位置
 - PullToRefreshPositionNone: 不展示
 - PullToRefreshPositionSuperTop: 父视图顶部 (位于 Segment Menu 上部)
 - PullToRefreshPositionChildTop: 子视图顶部 (位于 Segment Menu 下部)
 */
typedef NS_ENUM(NSInteger, PullToRefreshPosition) {
    PullToRefreshPositionNone,
    PullToRefreshPositionParentTop,
    PullToRefreshPositionChildTop,
};

/**
 附件按钮点击事件block
 @param extraButton 附加按钮
 */
typedef void(^ExtraButtonClickBlock)(UIButton *extraButton);



@interface ANSegmentScrollStyle : NSObject

/** 内容view是否能滑动 默认为YES */
@property (assign, nonatomic, getter=isScrollContentView) BOOL scrollContentView;

/** 点击标题切换的时候 内容view是否会有动画 即使是设置为YES当跳过两页以上的时候都没有动画 默认为YES */
@property (assign, nonatomic, getter=isAnimatedContentViewWhenTitleClicked) BOOL animatedContentViewWhenTitleClicked;

/** segmentView是否有弹性 默认为YES */
@property (assign, nonatomic, getter=isSegmentViewBounces) BOOL segmentViewBounces;

/** contentView是否有弹性 默认为YES */
@property (assign, nonatomic, getter=isContentViewBounces) BOOL contentViewBounces;

/** 是否颜色渐变 默认为NO */
@property (assign, nonatomic, getter=isGradualChangeTitleColor) BOOL gradualChangeTitleColor;

/** 当设置scrollTitle=NO时, 设置此属性为YES会适应文字宽度而不是同TitleView的宽度一样 默认为NO */
@property (assign, nonatomic, getter=isAdjustCoverOrLineWidth) BOOL adjustCoverOrLineWidth;

/** 是否自动调整标题的宽度, 当设置为YES的时候 如果所有的标题的宽度之和小于segmentView的宽度的时候, 会自动调整title的位置, 达到类似"平分"的效果 默认为NO */
@property (assign, nonatomic, getter=isAutoAdjustTitlesWidth) BOOL autoAdjustTitlesWidth;

/** 是否在开始滚动的时候就调整标题栏 默认为NO */
@property (assign, nonatomic, getter=isAdjustTitleWhenBeginDrag) BOOL adjustTitleWhenBeginDrag;

/** ANSegmentMenu的高度 */
@property (assign, nonatomic) CGFloat segmentHeight;



#pragma mark - Setup Titles
/** 是否缩放标题 不能滚动的时候就不要把缩放和遮盖或者滚动条同时使用, 否则显示效果不好 默认为NO */
@property (assign, nonatomic, getter=isScaleTitle) BOOL scaleTitle;

/** 是否滚动标题 默认为YES 设置为NO的时候所有的标题将不会滚动, 并且宽度 titleWidth 未设置时会平分 和系统的segment效果相似 */
@property (assign, nonatomic, getter=isScrollTitle) BOOL scrollTitle;

/** 标题宽度 */
@property (nonatomic, assign) CGFloat titleWidth;

/** 标题之间的间隙 默认为15.0 */
@property (assign, nonatomic) CGFloat titleMargin;

/** 标题的字体 默认为14 */
@property (strong, nonatomic) UIFont *titleFont;

/** 标题缩放倍数, 默认1.3 */
@property (assign, nonatomic) CGFloat titleBigScale;

/** 标题一般状态的颜色 */
@property (strong, nonatomic) UIColor *normalTitleColor;

/** 标题选中状态的颜色 */
@property (strong, nonatomic) UIColor *selectedTitleColor;



#pragma mark - Setup Cover Style
/** 是否显示遮盖 默认为NO */
@property (assign, nonatomic, getter=isShowCover) BOOL showCover;

/** 遮盖宽度 */
@property (nonatomic, assign) CGFloat scrollCoverWidth;

/** 遮盖的高度 默认为28 */
@property (assign, nonatomic) CGFloat coverHeight;

/** 遮盖的圆角 默认为14 */
@property (assign, nonatomic) CGFloat coverCornerRadius;

/** 遮盖的颜色 */
@property (strong, nonatomic) UIColor *coverBackgroundColor;

/** 遮盖边框宽度 */
@property (nonatomic, assign) CGFloat coverBorderWidth;

/** 遮盖边框颜色 */
@property (nonatomic, strong) UIColor *coverBorderColor;



#pragma mark - Setup Line Style
/** 是否显示滚动条 默认为NO */
@property (assign, nonatomic, getter=isShowLine) BOOL showLine;

/** 下划线宽度 */
@property (nonatomic, assign) CGFloat scrollLineWidth;

/** 下划线高度 默认为2 */
@property (assign, nonatomic) CGFloat scrollLineHeight;

/** 下划线距离底部的距离 默认为0 即紧贴菜单栏底部 */
@property (nonatomic, assign) CGFloat scrollLineDistanceTopBottom;

/** 下划线颜色 */
@property (strong, nonatomic) UIColor *scrollLineColor;

/** 下划线图片名称 如果不为nil则会使用图片 如果为nil则会使用纯色 */
@property (nonatomic, copy) NSString *scrollLineImageName;



#pragma mark - Setup Image
/** 是否显示图片 默认为NO */
@property (assign, nonatomic, getter=isShowImage) BOOL showImage;

/** 标题中图片的位置 */
@property (assign, nonatomic) TitleImagePosition imagePosition;



#pragma mark - Setup Extra Button
/** 是否显示附加的按钮 默认为NO */
@property (assign, nonatomic, getter=isShowExtraButton) BOOL showExtraButton;

/** 附加按钮Y值(离菜单栏顶部距离) */
@property (nonatomic, assign) CGFloat extraButtonY;

/** 附加按钮宽度 */
@property (nonatomic, assign) CGFloat extraButtonWidth;

/** 设置附加按钮的背景图片 默认为nil */
@property (strong, nonatomic) NSString *extraBtnBackgroundImageName;

/** 附加按钮点击事件block */
@property (nonatomic, copy) ExtraButtonClickBlock extraButtonClickBlock;


#pragma mark - Setup Pull To Refresh Position
/** 下拉刷新控件位置 */
@property (nonatomic, assign) PullToRefreshPosition refreshPosition;



@end
