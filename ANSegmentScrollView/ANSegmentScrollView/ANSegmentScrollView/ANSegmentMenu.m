//
//  ANSegmentMenu.m
//  ANSegmentScrollView
//
//  Created by AudiebantNil on 2017/11/15.
//  Copyright © 2017年 AudiebantNil. All rights reserved.
//

#import "ANSegmentMenu.h"
#import "ANSegmentScrollStyle.h"
#import "ANMenuTitleView.h"

@interface ANSegmentMenu ()
<
UIScrollViewDelegate
>

@property (nonatomic, strong) ANSegmentScrollStyle *style;              // 滑动视图样式 (由 传参 确定)
@property (nonatomic, weak) id<ANSegmentScrollViewDelegate> delegate;   // 代理 (由 传参 确定)
@property (nonatomic, copy) TitleClickBlock titleClickBlock;            // 标题点击事件 (由 传参 确定)

@property (nonatomic, strong) UIScrollView *scrollView;                 // 整体滑动视图
@property (nonatomic, strong) UIView *scrollLine;                       // 下划线
@property (nonatomic, strong) UIView *coverLayer;                       // 遮盖
@property (nonatomic, strong) UIButton *extraBtn;                       // 附加按钮

/** 标题Label数组 */
@property (nonatomic, strong) NSMutableArray *titleViews;
/** 标题宽度缓存数组 */
@property (nonatomic, strong) NSMutableArray *titleWidths;

/** 下划线或遮盖的初始X值(以第一个TitleView为基准记录) */
@property (nonatomic, assign) CGFloat scrollLineOrCoverX;
/** 下划线或遮盖的宽度 */
@property (nonatomic, assign) CGFloat scrollLineOrCoverWidth;

/** 普通状态下标题颜色 */
@property (nonatomic, copy) NSArray *normalTitleRGB;
/** 选中状态下标题颜色 */
@property (nonatomic, copy) NSArray *selectedTitleRGB;

/** 当前选中序号 */
@property (nonatomic, assign) NSInteger currentIndex;
/** 上一次选中序号 */
@property (nonatomic, assign) NSInteger oldIndex;

@end

@implementation ANSegmentMenu


#pragma mark - Setup UI
- (instancetype)initWithFrame:(CGRect)frame
                        style:(ANSegmentScrollStyle *)style
                       titles:(NSArray <NSString *>*)titles
                     delegate:(id<ANSegmentScrollViewDelegate>)delegate
              titleClickBlock:(TitleClickBlock)titleClickBlock {
    if (self = [super initWithFrame:frame]) {
        _style = style;
        _segmentTitles = titles;
        _delegate = delegate;
        _titleClickBlock = titleClickBlock;
        _currentIndex = 0;
        _oldIndex = 0;
        if (self.style.isScrollTitle == NO && self.style.scaleTitle == YES) {
            // 不能滚动的时候就不要把缩放和遮盖或者滚动条同时使用, 否则显示效果不好
            self.style.scaleTitle = !(self.style.isShowCover || self.style.isShowLine);
        }
        if (self.style.isShowImage) { // 有图片则取消以下显示效果
            self.style.scaleTitle = NO;
            self.style.showCover = NO;
            self.style.gradualChangeTitleColor = NO;
        }
        [self addSubviews];
        [self setupUI];
    }
    return self;
}

- (void)addSubviews {
    if (self.segmentTitles.count == 0) return;
    [self addSubview:self.scrollView];
    if (self.style.isShowLine) {
        [self.scrollView addSubview:self.scrollLine];
    }
    if (self.style.isShowCover) {
        [self.scrollView insertSubview:self.coverLayer atIndex:0];
    }
    if (self.style.isShowExtraButton) {
        [self addSubview:self.extraBtn];
    }
    NSInteger index = 0;
    for (NSString *title in self.segmentTitles) {
        ANMenuTitleView *titleView = [[ANMenuTitleView alloc] initWithFrame:CGRectZero];
        titleView.tag = index;
        titleView.text = title;
        titleView.font = self.style.titleFont;
        titleView.textColor = self.style.normalTitleColor;
        titleView.imagePosition = self.style.imagePosition;
        titleView.textWidth = self.style.titleWidth;
        if (self.delegate && [self.delegate respondsToSelector:@selector(an_setupTitleView:atIndex:)]) {
            [self.delegate an_setupTitleView:titleView atIndex:index];
        }
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleViewClickAction:)];
        [titleView addGestureRecognizer:tapGes];
        CGFloat titleViewWidth = [titleView titleViewWidth];
        [self.titleWidths addObject:@(titleViewWidth)];
        [self.titleViews addObject:titleView];
        [self.scrollView addSubview:titleView];
        index = index + 1;
    }
}

- (void)setupUI {
    // 设置滑动视图和附加按钮
    if (self.extraBtn) {
        CGFloat buttonW = self.style.extraButtonWidth > 0 ? self.style.extraButtonWidth : 0;
        CGFloat scrollW = self.bounds.size.width - self.style.extraButtonWidth;
        self.scrollView.frame = CGRectMake(0.0, 0.0, scrollW, self.bounds.size.height);
        self.extraBtn.frame = CGRectMake(scrollW , self.style.extraButtonY, buttonW, self.bounds.size.height - 2 * self.style.extraButtonY);
    } else {
        self.scrollView.frame = self.bounds;
    }
    if (self.titleViews.count == 0) return;
    // 设置菜单标题
    [self setupTitleViewsPosition];
    // 设置下划线和遮盖层
    [self setupScrollLineAndCover];
    // 设置滑动区域
    if (self.style.isScrollTitle) { // 设置滚动区域
        ANMenuTitleView *firstTitleView = (ANMenuTitleView *)self.titleViews.firstObject;
        ANMenuTitleView *lastTitleView = (ANMenuTitleView *)self.titleViews.lastObject;
        self.scrollView.contentSize = CGSizeMake(CGRectGetMaxX(lastTitleView.frame) + firstTitleView.frame.origin.x, 0.0);
    }
}

- (void)setupTitleViewsPosition {
    CGFloat titleX = 0.0;
    CGFloat titleY = 0.0;
    CGFloat titleW = 0.0;
    CGFloat titleH = self.bounds.size.height - self.style.scrollLineHeight;
    if (self.style.isScrollTitle == NO) { // 标题不能滚动
        if (self.style.titleWidth > 0) { // 标题不能滑动, 设置了标题宽度, 则居中显示
            CGFloat titleWidth = self.style.titleWidth;
            CGFloat titleMargin = self.style.titleMargin;
            NSInteger count = self.titleViews.count;
            CGFloat startX = (self.scrollView.bounds.size.width - (count - 1) * titleMargin - count * titleWidth) / 2;
            for (int i = 0; i < count; i++) {
                ANMenuTitleView *titleView = self.titleViews[i];
                titleView.frame = CGRectMake(startX + (titleWidth+titleMargin) * i, titleY, titleWidth, titleH);
                if (self.style.isShowImage) [titleView adjustTitleAndImageFrame];
            }
        } else { // 标题不能滑动, 没有设置标题宽度, 默认平分self的宽度
            titleW = self.scrollView.bounds.size.width / self.segmentTitles.count;
            NSInteger count = self.titleViews.count;
            for (int i = 0; i < count; i++) {
                ANMenuTitleView *titleView = self.titleViews[i];
                titleX = i * titleW;
                titleView.frame = CGRectMake(titleX, titleY, titleW, titleH);
                if (self.style.isShowImage) [titleView adjustTitleAndImageFrame];
            }
        }
    } else { // 标题可以滚动
        NSInteger count = self.titleViews.count;
        CGFloat lastLableMaxX = self.style.titleMargin;
        CGFloat addedMargin = 0.0f;
        if (self.style.isAutoAdjustTitlesWidth) { // 自动调整标题宽度
            CGFloat allTitlesWidth = self.style.titleMargin;
            for (int i = 0; i < count; i++) {
                allTitlesWidth = allTitlesWidth + [self.titleWidths[i] floatValue] + self.style.titleMargin;
            }
            addedMargin = allTitlesWidth < self.scrollView.bounds.size.width ? (self.scrollView.bounds.size.width - allTitlesWidth)/self.titleWidths.count : 0 ;
        }
        for (int i = 0; i < count; i++) {
            ANMenuTitleView *titleView = self.titleViews[i];
            titleW = [self.titleWidths[i] floatValue];
            titleX = lastLableMaxX + addedMargin/2;
            lastLableMaxX += (titleW + addedMargin + self.style.titleMargin);
            titleView.frame = CGRectMake(titleX, titleY, titleW, titleH);
            if (self.style.isShowImage) [titleView adjustTitleAndImageFrame];
        }
        
    }
    // 设置当前选中的TitleView
    ANMenuTitleView *currentTitleView = (ANMenuTitleView *)self.titleViews[_currentIndex];
    if (currentTitleView) {
        currentTitleView.scale = 1.0;
        currentTitleView.textColor = self.style.selectedTitleColor;
        if (self.style.isScaleTitle) currentTitleView.scale = self.style.titleBigScale;
        if (self.style.isShowImage) currentTitleView.selected = YES;
    }
}

- (void)setupScrollLineAndCover {
    ANMenuTitleView *firstLabel = (ANMenuTitleView *)self.titleViews[0];
    CGFloat firstItemX = firstLabel.frame.origin.x;
    CGFloat firstItemW = firstLabel.frame.size.width;
    if (self.scrollLine) { // 设置下划线
        CGFloat lineW = self.style.scrollLineWidth > 0 ? self.style.scrollLineWidth : firstItemW;
        CGFloat lineX = self.style.scrollLineWidth > 0 ? (firstItemX + (firstItemW - lineW) / 2) : firstItemX;
        CGFloat lineY = self.style.scrollLineDistanceTopBottom > 0 ? self.scrollView.bounds.size.height - self.style.scrollLineHeight - self.style.scrollLineDistanceTopBottom : self.scrollView.bounds.size.height - self.style.scrollLineHeight;
        self.scrollLine.layer.cornerRadius = self.style.scrollLineHeight / 2;
        self.scrollLine.layer.masksToBounds = YES;
        if (self.style.isScrollTitle == NO && self.style.isAdjustCoverOrLineWidth == YES) { // 标题不能滑动且宽度随滑动变化
            lineW = [self.titleWidths[0] floatValue];
            if (lineW != firstItemW) { // 初始状态下宽度不等有偏移
                lineX = firstItemX + (firstItemW - lineW) / 2;
            }
        }
        // 存档: 用于下划线短于Label或遮盖长于Label的情况
        self.scrollLineOrCoverX = lineX - firstItemX;
        self.scrollLineOrCoverWidth = lineW;
        // 设置当前选中的TitleView的下划线和遮盖层
        ANMenuTitleView *currentLabel = (ANMenuTitleView *)self.titleViews[_currentIndex];
        self.scrollLine.frame = CGRectMake(currentLabel.frame.origin.x + self.scrollLineOrCoverX, lineY, self.scrollLineOrCoverWidth, self.style.scrollLineHeight);
    }
    if (self.coverLayer) { // 设置遮盖层
        CGFloat coverW = self.style.scrollCoverWidth > 0 ? self.style.scrollCoverWidth : firstItemW;
        CGFloat coverX = self.style.scrollCoverWidth > 0 ? firstItemX + (firstItemW - coverW) / 2 : firstItemX;
        CGFloat coverY = (self.style.segmentHeight - self.style.coverHeight) / 2;
        if (self.style.isScrollTitle == NO && self.style.isAdjustCoverOrLineWidth == YES) { // 标题不能滑动且宽度随滑动变化
            coverW = [self.titleWidths[0] floatValue];
            if (coverW != firstItemW) { // 初始状态下宽度不等有偏移
                coverX = firstItemX + (firstItemW - coverW) / 2;
            }
        }
        // 存档: 用于下划线短于Label或遮盖长于Label的情况
        self.scrollLineOrCoverX = coverX - firstItemX;
        self.scrollLineOrCoverWidth = coverW;
        // 设置当前选中的TitleView的下划线和遮盖层
        ANMenuTitleView *currentLabel = (ANMenuTitleView *)self.titleViews[_currentIndex];
        self.coverLayer.frame = CGRectMake(currentLabel.frame.origin.x + self.scrollLineOrCoverX, coverY, self.scrollLineOrCoverWidth, self.style.coverHeight);
    }
}


#pragma mark - Adjust UI
/** 点击标题事件(包含重复点击相同标题的排序处理) */
- (void)adjustUIWithAnimated:(BOOL)animated tapped:(BOOL)tapped {
    ANMenuTitleView *oldTitleView = (ANMenuTitleView *)self.titleViews[_oldIndex];
    ANMenuTitleView *currentTitleView = (ANMenuTitleView *)self.titleViews[_currentIndex];
    if (_currentIndex == _oldIndex) { // 序号并未改变
        if (tapped && [self.delegate respondsToSelector:@selector(an_tappedSameTitleView:atIndex:)]) {
            [self.delegate an_tappedSameTitleView:currentTitleView atIndex:_currentIndex];
        } else {
            return;
        }
    }
    __weak typeof(self) weakSelf = self;
    CGFloat animatedTime = animated ? 0.25 : 0.0;
    [UIView animateWithDuration:animatedTime animations:^{
        oldTitleView.textColor = weakSelf.style.normalTitleColor;
        currentTitleView.textColor = weakSelf.style.selectedTitleColor;
        oldTitleView.selected = NO;
        currentTitleView.selected = YES;
        if (weakSelf.style.isScaleTitle) { // 缩放标题
            oldTitleView.scale = 1.0;
            currentTitleView.scale = weakSelf.style.titleBigScale;
        }
        if (weakSelf.scrollLine) { // 设置下划线
            CGRect lineFrame = weakSelf.scrollLine.frame;
            if (weakSelf.style.isScrollTitle && weakSelf.style.isAdjustCoverOrLineWidth) { // 标题可滚动 且 滑动过程中下划线宽度有变化
                lineFrame.size.width = [weakSelf.titleWidths[_currentIndex] floatValue];
                lineFrame.origin.x = currentTitleView.frame.origin.x + weakSelf.scrollLineOrCoverX + (currentTitleView.frame.size.width - lineFrame.size.width) * 0.5;
            } else { // 标题不可滑动 或 滚动过程中宽度不变
                lineFrame.size.width = weakSelf.scrollLineOrCoverWidth;
                lineFrame.origin.x = currentTitleView.frame.origin.x + weakSelf.scrollLineOrCoverX;
            }
            weakSelf.scrollLine.frame = lineFrame;
        }
        if (weakSelf.coverLayer) { // 设置遮盖层
            CGRect coverFrame = weakSelf.coverLayer.frame;
            if (weakSelf.style.isScrollTitle && weakSelf.style.isAdjustCoverOrLineWidth) { // 标题可滚动 且 滑动过程中遮盖层宽度有变化
                coverFrame.size.width = [weakSelf.titleWidths[_currentIndex] floatValue];
                coverFrame.origin.x = currentTitleView.frame.origin.x + weakSelf.scrollLineOrCoverX + (currentTitleView.frame.size.width - coverFrame.size.width) * 0.5;
            } else { // 标题不可滑动 或 滚动过程中宽度不变
                coverFrame.size.width = weakSelf.scrollLineOrCoverWidth;
                coverFrame.origin.x = currentTitleView.frame.origin.x + weakSelf.scrollLineOrCoverX;
            }
            weakSelf.coverLayer.frame = coverFrame;
        }
    } completion:^(BOOL finished) {
        [weakSelf adjustTitleOffsetAtIndex:_currentIndex];
    }];
    // 设置序号
    _oldIndex = _currentIndex;
    // 响应点击事件
    if (self.titleClickBlock) {
        self.titleClickBlock(currentTitleView, _currentIndex);
    }
}

/** 选中标题设置居中 */
- (void)adjustTitleOffsetAtIndex:(NSInteger)currentIndex {
    _oldIndex = currentIndex;
    // 重置渐变颜色/缩放效果
    NSInteger count = self.titleViews.count;
    for (int i = 0; i < count; i++) {
        ANMenuTitleView *titleView = self.titleViews[i];
        if (i != currentIndex) {
            titleView.selected = NO;
            titleView.textColor = self.style.normalTitleColor;
            titleView.scale = 1.0;
        } else {
            titleView.selected = YES;
            titleView.textColor = self.style.selectedTitleColor;
            if (self.style.isScaleTitle) {
                titleView.scale = self.style.titleBigScale;
            }
        }
    }
    // 调整标题位置居中
    if (self.scrollView.contentSize.width != self.scrollView.bounds.size.width) {
        ANMenuTitleView *currentTitleView = (ANMenuTitleView *)self.titleViews[currentIndex];
        CGFloat offsetX = currentTitleView.center.x - self.scrollView.bounds.size.width * 0.5;
        if (offsetX < 0) offsetX = 0;
        CGFloat extraBtnW = self.extraBtn ? self.extraBtn.frame.size.width : 0.0;
        CGFloat maxOffsetX = self.scrollView.contentSize.width - (self.scrollView.bounds.size.width - extraBtnW);
        if (maxOffsetX < 0) maxOffsetX = 0;
        if (offsetX > maxOffsetX) offsetX = maxOffsetX;
        [self.scrollView setContentOffset:CGPointMake(offsetX, 0.0) animated:YES];
    }
}

/** 滑动过程中渐变量设置 */
- (void)adjustUIWithProgress:(CGFloat)progress fromIndex:(NSInteger)oldIndex toIndex:(NSInteger)currentIndex {
    if (oldIndex < 0 || oldIndex >= self.segmentTitles.count ||
        currentIndex < 0 || currentIndex >= self.segmentTitles.count) {
        return;
    }
    _oldIndex = currentIndex;
    ANMenuTitleView *oldTitleView = (ANMenuTitleView *)self.titleViews[oldIndex];
    ANMenuTitleView *currentTitleView = (ANMenuTitleView *)self.titleViews[currentIndex];
    CGFloat xDistance = currentTitleView.frame.origin.x - oldTitleView.frame.origin.x;
    CGFloat wDistance = currentTitleView.frame.size.width - oldTitleView.frame.size.width;
    if (self.scrollLine) { // 设置下划线
        CGRect lineFrame = self.scrollLine.frame;
        if (self.style.isScrollTitle && self.style.isAdjustCoverOrLineWidth) { // 标题可滚动 且 滑动过程中下划线宽度有变化
            CGFloat oldScrollLineW = [self.titleWidths[oldIndex] floatValue];
            CGFloat currentScrollLineW = [self.titleWidths[currentIndex] floatValue];
            wDistance = currentScrollLineW - oldScrollLineW;
            CGFloat oldScrollLineX = self.scrollLineOrCoverX + oldTitleView.frame.origin.x + (self.scrollLineOrCoverWidth - oldScrollLineW) * 0.5;
            CGFloat currentScrollLineX = self.scrollLineOrCoverX + currentTitleView.frame.origin.x + (self.scrollLineOrCoverWidth - currentScrollLineW) * 0.5;
            xDistance = currentScrollLineX - oldScrollLineX;
            lineFrame.origin.x = oldScrollLineX + xDistance * progress;
            lineFrame.size.width = oldScrollLineW + wDistance * progress;
        } else { // 标题不可滑动 或 滚动过程中宽度不变
            lineFrame.size.width = self.scrollLineOrCoverWidth + wDistance * progress;
            lineFrame.origin.x = self.scrollLineOrCoverX + oldTitleView.frame.origin.x + xDistance * progress;
        }
        self.scrollLine.frame = lineFrame;
    }
    if (self.coverLayer) { // 设置遮盖层
        CGRect coverFrame = self.coverLayer.frame;
        if (self.style.isScrollTitle && self.style.isAdjustCoverOrLineWidth) { // 标题可滚动 且 滑动过程中遮盖层宽度有变化
            CGFloat oldCoverW = [self.titleWidths[oldIndex] floatValue];
            CGFloat currentCoverW = [self.titleWidths[currentIndex] floatValue];
            wDistance = currentCoverW - oldCoverW;
            CGFloat oldCoverX = self.scrollLineOrCoverX + oldTitleView.frame.origin.x + (self.scrollLineOrCoverWidth - oldCoverW) * 0.5;
            CGFloat currentCoverX = self.scrollLineOrCoverX + currentTitleView.frame.origin.x + (self.scrollLineOrCoverWidth - currentCoverW) * 0.5;
            xDistance = currentCoverX - oldCoverX;
            coverFrame.size.width = oldCoverW + wDistance * progress;
            coverFrame.origin.x = oldCoverX + xDistance * progress;
        } else { // 标题不可滑动 或 滚动过程中宽度不变
            coverFrame.size.width = self.scrollLineOrCoverWidth + wDistance * progress;
            coverFrame.origin.x = self.scrollLineOrCoverX + oldTitleView.frame.origin.x + xDistance * progress;
        }
        self.coverLayer.frame = coverFrame;
    }
    if (self.style.isGradualChangeTitleColor) { // 颜色渐变
        oldTitleView.textColor = [UIColor colorWithRed:[self.selectedTitleRGB[0] floatValue] +
                                  ([self.normalTitleRGB[0] floatValue] - [self.selectedTitleRGB[0] floatValue]) * progress
                                                 green:[self.selectedTitleRGB[1] floatValue] +
                                  ([self.normalTitleRGB[1] floatValue] - [self.selectedTitleRGB[1] floatValue]) * progress
                                                  blue:[self.selectedTitleRGB[2] floatValue] +
                                  ([self.normalTitleRGB[2] floatValue] - [self.selectedTitleRGB[2] floatValue]) * progress
                                                 alpha:1.0];
        currentTitleView.textColor = [UIColor colorWithRed:[self.normalTitleRGB[0] floatValue] -
                                      ([self.normalTitleRGB[0] floatValue] - [self.selectedTitleRGB[0] floatValue]) * progress
                                                     green:[self.normalTitleRGB[1] floatValue] -
                                      ([self.normalTitleRGB[1] floatValue] - [self.selectedTitleRGB[1] floatValue]) * progress
                                                      blue:[self.normalTitleRGB[2] floatValue] -
                                      ([self.normalTitleRGB[2] floatValue] - [self.selectedTitleRGB[2] floatValue]) * progress
                                                     alpha:1.0];
    }
    if (self.style.isScaleTitle) { // 标题缩放
        CGFloat deltaScale = self.style.titleBigScale - 1.0;
        oldTitleView.scale = self.style.titleBigScale - deltaScale * progress;
        currentTitleView.scale = 1.0 + deltaScale * progress;
    }
}


#pragma mark - Button Actions
- (void)titleViewClickAction:(UITapGestureRecognizer *)tap {
    ANMenuTitleView *titleView = (ANMenuTitleView *)tap.view;
    if (titleView == nil) return;
    _currentIndex = titleView.tag;
    [self adjustUIWithAnimated:YES tapped:YES];
}

- (void)extraButtonClickAction:(UIButton *)sender {
    if (self.style.extraButtonClickBlock) {
        self.style.extraButtonClickBlock(sender);
    }
}


#pragma mark - Getters
- (UIScrollView *)scrollView {
    if (_scrollView) return _scrollView;
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.pagingEnabled = NO;
    _scrollView.scrollsToTop = NO;
    _scrollView.bounces = self.style.isSegmentViewBounces;
    _scrollView.delegate = self;
    return _scrollView;
}

- (UIView *)scrollLine {
    if (self.style.isShowLine == NO) return nil;
    if (_scrollLine) return _scrollLine;
    // 下划线图片设置
    if (self.style.scrollLineImageName) {
        _scrollLine = [[UIImageView alloc] initWithImage:[UIImage imageNamed:self.style.scrollLineImageName]];
    } else {
        _scrollLine = [[UIView alloc] init];
        _scrollLine.backgroundColor = self.style.scrollLineColor;
    }
    return _scrollLine;
}

- (UIView *)coverLayer {
    if (self.style.isShowCover == NO) return nil;
    if (_coverLayer) return _coverLayer;
    _coverLayer = [[UIView alloc] init];
    _coverLayer.backgroundColor = self.style.coverBackgroundColor;
    _coverLayer.layer.cornerRadius = self.style.coverCornerRadius;
    _coverLayer.layer.masksToBounds = YES; // 圆角需要
    // 遮盖边框设置
    if (self.style.coverBorderColor) {
        _coverLayer.layer.borderColor = self.style.coverBorderColor.CGColor;
    }
    if (self.style.coverBorderWidth > 0) {
        _coverLayer.layer.borderWidth = self.style.coverBorderWidth;
    }
    return _coverLayer;
}

- (UIButton *)extraBtn {
    if (self.style.showExtraButton == NO) return nil;
    if (_extraBtn) return _extraBtn;
    _extraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_extraBtn addTarget:self action:@selector(extraButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [_extraBtn setBackgroundColor:[UIColor whiteColor]];
    if (self.style.extraBtnBackgroundImageName) {
        [_extraBtn setImage:[UIImage imageNamed:self.style.extraBtnBackgroundImageName] forState:UIControlStateNormal];
    }
    // 设置边缘的阴影效果
    _extraBtn.layer.shadowColor = [UIColor whiteColor].CGColor;
    _extraBtn.layer.shadowOffset = CGSizeMake(-5, 0);
    _extraBtn.layer.shadowOpacity = 1;
    return _extraBtn;
}

- (NSMutableArray *)titleViews {
    if (_titleViews) return _titleViews;
    _titleViews = [NSMutableArray arrayWithCapacity:self.segmentTitles.count];
    return _titleViews;
}

- (NSMutableArray *)titleWidths {
    if (_titleWidths) return _titleWidths;
    _titleWidths = [NSMutableArray arrayWithCapacity:self.segmentTitles.count];
    return _titleWidths;
}

- (NSArray *)normalTitleRGB {
    if (_normalTitleRGB) return _normalTitleRGB;
    _normalTitleRGB = [self rgbArrayFromColor:self.style.normalTitleColor];
    NSAssert(_normalTitleRGB, @"设置普通状态的文字颜色时 请使用RGB空间的颜色值");
    return  _normalTitleRGB;
}

- (NSArray *)selectedTitleRGB {
    if (_selectedTitleRGB) return _selectedTitleRGB;
    _selectedTitleRGB = [self rgbArrayFromColor:self.style.selectedTitleColor];
    NSAssert(_selectedTitleRGB, @"设置选中状态的文字颜色时 请使用RGB空间的颜色值");
    return  _selectedTitleRGB;
}

- (NSArray *)rgbArrayFromColor:(UIColor *)color {
    NSArray *rgbArray = nil;
    if (CGColorGetNumberOfComponents(color.CGColor) == 4) {
        const CGFloat *components = CGColorGetComponents(color.CGColor);
        rgbArray = [NSArray arrayWithObjects:@(components[0]), @(components[1]), @(components[2]), nil];
    }
    return rgbArray;
}


@end
