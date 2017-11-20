//
//  ANSegmentSuperTableView.m
//  ANSegmentScrollView
//
//  Created by AudiebantNil on 2017/11/15.
//  Copyright © 2017年 AudiebantNil. All rights reserved.
//

#import "ANSegmentSuperTableView.h"

@implementation ANSegmentSuperTableView

// 滑动子控制器ScrollView时,此视图也接收滑动事件
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]];
}

@end
