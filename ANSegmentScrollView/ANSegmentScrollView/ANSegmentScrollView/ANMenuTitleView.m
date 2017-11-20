//
//  ANMenuTitleView.m
//  ANSegmentScrollView
//
//  Created by AudiebantNil on 2017/11/16.
//  Copyright © 2017年 AudiebantNil. All rights reserved.
//

#import "ANMenuTitleView.h"

@interface ANMenuTitleView ()

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *label;

@property (nonatomic, assign) BOOL showImage;
@property (nonatomic, assign) CGSize textSize;
@property (nonatomic, assign) CGSize imageSize;

@end

@implementation ANMenuTitleView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
        _scale = 1.0;
        _showImage = NO;
        [self addSubview:self.label];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.showImage == NO) {
        self.label.frame = self.bounds;
    }
}

- (void)setScale:(CGFloat)scale {
    _scale = scale;
    self.transform = CGAffineTransformMakeScale(scale, scale);
}

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    if (_showImage) self.imageView.highlighted = selected;
}


#pragma mark - Public Methods
- (CGFloat)titleViewWidth {
    if (self.showImage == NO && self.textWidth > 0) {
        return self.textWidth;
    }
    CGFloat width = 0.0f;
    switch (self.imagePosition) {
        case TitleImagePositionLeft:
            width = _imageSize.width + _textSize.width;
            break;
        case TitleImagePositionRight:
            width = _imageSize.width + _textSize.width;
            break;
        case TitleImagePositionCenter:
            width = _imageSize.width;
            break;
        default:
            width = MAX(_imageSize.width, _textSize.width);
            break;
    }
    return width;
}

- (void)adjustTitleAndImageFrame {
    if (self.showImage == NO) {
        self.label.frame = self.bounds;
        return;
    }
    [self.label removeFromSuperview];
    CGRect contentViewFrame = self.bounds;
    contentViewFrame.size.width = [self titleViewWidth];
    contentViewFrame.origin.x = (self.bounds.size.width - contentViewFrame.size.width) / 2;
    self.contentView.frame = contentViewFrame;
    [self addSubview:self.contentView];
    self.label.frame = self.contentView.bounds;
    [self.contentView addSubview:self.label];
    [self.contentView addSubview:self.imageView];
    switch (self.imagePosition) {
        case TitleImagePositionTop: {
            CGRect contentViewFrame = self.contentView.frame;
            contentViewFrame.size.height = _imageSize.height + _textSize.height;
            contentViewFrame.origin.y = (self.frame.size.height - contentViewFrame.size.height)*0.5;
            self.contentView.frame = contentViewFrame;
            self.imageView.frame = CGRectMake(0, 0, _imageSize.width, _imageSize.height);
            CGPoint center = self.imageView.center;
            center.x = self.label.center.x;
            self.imageView.center = center;
            CGFloat labelHeight = self.contentView.frame.size.height - _imageSize.height;
            CGRect labelFrame = self.label.frame;
            labelFrame.origin.y = _imageSize.height;
            labelFrame.size.height = labelHeight;
            self.label.frame = labelFrame;
            break;
        }
        case TitleImagePositionLeft: {
            CGRect labelFrame = self.label.frame;
            labelFrame.origin.x = _imageSize.width;
            labelFrame.size.width = self.contentView.frame.size.width - _imageSize.width;
            self.label.frame = labelFrame;
            CGRect imageFrame = CGRectZero;
            imageFrame.size.height = _imageSize.height;
            imageFrame.size.width = _imageSize.width;
            imageFrame.origin.y = (self.contentView.frame.size.height - imageFrame.size.height)/2;
            self.imageView.frame = imageFrame;
            break;
        }
        case TitleImagePositionRight: {
            CGRect labelFrame = self.label.frame;
            labelFrame.size.width = self.contentView.frame.size.width - _imageSize.width;
            self.label.frame = labelFrame;
            CGRect imageFrame = CGRectZero;
            imageFrame.origin.x = CGRectGetMaxX(self.label.frame);
            imageFrame.size.height = _imageSize.height;
            imageFrame.size.width = _imageSize.width;
            imageFrame.origin.y = (self.contentView.frame.size.height - imageFrame.size.height)/2;
            self.imageView.frame = imageFrame;
            break;
        }
        case TitleImagePositionCenter: {
            [self.label removeFromSuperview];
            self.imageView.frame = self.contentView.bounds;
            break;
        }
        default:
            break;
    }
}


#pragma mark - Setup Label
- (void)setText:(NSString *)text {
    _text = text;
    self.label.text = text;
    CGRect bounds = [text boundingRectWithSize:CGSizeMake(MAXFLOAT, 0.0)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{NSFontAttributeName:self.label.font}
                                       context:nil];
    _textSize = bounds.size;
}

- (void)setFont:(UIFont *)font {
    _font = font;
    self.label.font = font;
    if (self.text) {
        CGRect bounds = [self.text boundingRectWithSize:CGSizeMake(MAXFLOAT, 0.0)
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                             attributes:@{NSFontAttributeName:self.label.font}
                                                context:nil];
        _textSize = bounds.size;
    }
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    self.label.textColor = textColor;
}


#pragma mark - Setup Image
- (void)setNormalImage:(UIImage *)normalImage {
    _normalImage = normalImage;
    _imageSize = CGSizeMake(normalImage.size.width, normalImage.size.height);
    self.imageView.image = normalImage;
    self.showImage = YES;
}

- (void)setSelectedImage:(UIImage *)selectedImage {
    _selectedImage = selectedImage;
    self.imageView.highlightedImage = selectedImage;
    self.showImage = YES;
    if (self.imageSize.width == 0) {
        _imageSize = CGSizeMake(selectedImage.size.width, selectedImage.size.height);
    }
}


#pragma mark - Getters
- (UIView *)contentView {
    if (_contentView) return _contentView;
    _contentView = [[UIView alloc] init];
    return _contentView;
}

- (UIImageView *)imageView {
    if (_imageView) return _imageView;
    _imageView = [[UIImageView alloc] init];
    _imageView.contentMode = UIViewContentModeCenter;
    return _imageView;
}

- (UILabel *)label {
    if (_label) return _label;
    _label = [[UILabel alloc] init];
    _label.textAlignment = NSTextAlignmentCenter;
    return _label;
}


@end
