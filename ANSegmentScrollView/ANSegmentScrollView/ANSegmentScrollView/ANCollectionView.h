//
//  ANCollectionView.h
//  ANSegmentScrollView
//
//  Created by AudiebantNil on 2017/11/15.
//  Copyright © 2017年 AudiebantNil. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ANCollectionView;

typedef BOOL(^AN_BeginPanGestureHandler)(ANCollectionView *collectionView, UIPanGestureRecognizer *panGesture);

@interface ANCollectionView : UICollectionView

- (void)an_shouldBeginPanGestureHandler:(AN_BeginPanGestureHandler)beginPanHandler;

@end
