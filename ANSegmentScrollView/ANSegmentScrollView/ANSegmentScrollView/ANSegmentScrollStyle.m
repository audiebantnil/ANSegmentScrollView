//
//  ANSegmentScrollStyle.m
//  ANSegmentScrollView
//
//  Created by AudiebantNil on 2017/11/15.
//  Copyright © 2017年 AudiebantNil. All rights reserved.
//

#import "ANSegmentScrollStyle.h"

@implementation ANSegmentScrollStyle

- (instancetype)init {
    if (self = [super init]) {
        _showCover = NO;
        _showLine = NO;
        _scaleTitle = NO;
        _scrollTitle = YES;
        _segmentViewBounces = YES;
        _contentViewBounces = YES;
        _gradualChangeTitleColor = NO;
        _showExtraButton = NO;
        _scrollContentView = YES;
        _adjustCoverOrLineWidth = NO;
        _showImage = NO;
        _autoAdjustTitlesWidth = NO;
        _animatedContentViewWhenTitleClicked = YES;
        _extraBtnBackgroundImageName = nil;
        
        _scrollLineColor = [UIColor blueColor];
        _scrollLineHeight = 2.0;
        
        _coverBackgroundColor = [UIColor yellowColor];
        _coverCornerRadius = 14.0;
        _coverHeight = 28.0;
        
        _titleFont = [UIFont systemFontOfSize:14.0];
        _titleBigScale = 1.3;
        _titleMargin = 15.0;
        _normalTitleColor = [UIColor colorWithRed:arc4random_uniform(256)/255.0 green:arc4random_uniform(256)/255.0 blue:arc4random_uniform(256)/255.0 alpha:1.0];
        _selectedTitleColor = [UIColor colorWithRed:arc4random_uniform(256)/255.0 green:arc4random_uniform(256)/255.0 blue:arc4random_uniform(256)/255.0 alpha:1.0];
        
        _segmentHeight = 44.0;
        
        _extraButtonY = 5.0;
        _extraButtonWidth = 44.0;
    }
    return self;
}

- (void)setTitleWidth:(CGFloat)titleWidth {
    _titleWidth = titleWidth;
    _titleMargin = 0; // 设置标题宽度后默认无间距
}


@end
