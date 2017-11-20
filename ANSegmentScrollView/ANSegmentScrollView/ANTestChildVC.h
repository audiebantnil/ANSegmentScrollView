//
//  ANTestChildVC.h
//  ANSegmentScrollView
//
//  Created by AudiebantNil on 2017/11/16.
//  Copyright © 2017年 AudiebantNil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ANSegmentScrollViewDelegate.h"

@interface ANTestChildVC : UIViewController <ANSSChildVCsDelegate>

@property (nonatomic, assign) NSInteger index;

@end
