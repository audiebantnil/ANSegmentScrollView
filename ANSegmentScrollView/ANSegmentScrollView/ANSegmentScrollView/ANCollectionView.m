//
//  ANCollectionView.m
//  ANSegmentScrollView
//
//  Created by AudiebantNil on 2017/11/15.
//  Copyright © 2017年 AudiebantNil. All rights reserved.
//

#import "ANCollectionView.h"

@interface ANCollectionView ()

@property (nonatomic, copy) AN_BeginPanGestureHandler beginPanHandler;

@end

@implementation ANCollectionView

// 设置Block
- (void)an_shouldBeginPanGestureHandler:(AN_BeginPanGestureHandler)beginPanHandler {
    _beginPanHandler = beginPanHandler;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (_beginPanHandler && gestureRecognizer == self.panGestureRecognizer) {
        return _beginPanHandler(self, (UIPanGestureRecognizer *)gestureRecognizer);
    } else {
        return [super gestureRecognizerShouldBegin:gestureRecognizer];
    }
}

// 兼容全屏返回手势
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] == NO) return NO;
    UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)otherGestureRecognizer;
    CGPoint translationPoint = [pan translationInView:self];
    if (translationPoint.y == 0 && translationPoint.x != 0 && self.contentOffset.x <= 0) return YES;
    return NO;
}

@end
