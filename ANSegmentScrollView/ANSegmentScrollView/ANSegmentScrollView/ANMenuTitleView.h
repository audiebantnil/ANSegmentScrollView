//
//  ANMenuTitleView.h
//  ANSegmentScrollView
//
//  Created by AudiebantNil on 2017/11/16.
//  Copyright © 2017年 AudiebantNil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ANSegmentScrollStyle.h"

@interface ANMenuTitleView : UIView

@property (nonatomic, assign, getter=isSelected) BOOL selected;
@property (nonatomic, assign) CGFloat scale;

#pragma mark - Setup Label
@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, assign) CGFloat textWidth;

#pragma mark - Setup Image
@property (nonatomic, assign) TitleImagePosition imagePosition;
@property (nonatomic, strong) UIImage *normalImage;
@property (nonatomic, strong) UIImage *selectedImage;

#pragma mark - Public Methods

/**
 获取视图宽度
 */
- (CGFloat)titleViewWidth;

/**
 调整文字图片布局
 */
- (void)adjustTitleAndImageFrame;

@end
