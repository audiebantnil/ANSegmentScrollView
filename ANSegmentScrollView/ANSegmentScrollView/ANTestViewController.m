//
//  ANTestViewController.m
//  ANSegmentScrollView
//
//  Created by AudiebantNil on 2017/11/16.
//  Copyright © 2017年 AudiebantNil. All rights reserved.
//

#import "ANTestViewController.h"
#import "ANSegmentScrollView.h"
#import "ANTestChildVC.h"
#import <MJRefresh/MJRefresh.h>

#define SCREEN_WIDTH        [UIScreen mainScreen].bounds.size.width             // screen.width
#define SCREEN_HEIGHT       [UIScreen mainScreen].bounds.size.height            // screen.height
#define IS_IPHONE_X         (SCREEN_WIDTH == 375 && SCREEN_HEIGHT == 812)       // 判断是否为IPhone X
#define NAVIGATION_HEIGHT   (IS_IPHONE_X ? 88 : 64)                             // 竖屏状态下顶部导航栏高度
#define SAFE_BOTTOM_MARGIN  (IS_IPHONE_X ? 34 : 0)                              // 竖屏状态下底部安全间距

@interface ANTestViewController ()
<
ANSegmentScrollViewDelegate
>

@end

@implementation ANTestViewController

- (BOOL)shouldAutomaticallyForwardAppearanceMethods {
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"ANSegmentScrollView";
    self.view.backgroundColor = [UIColor whiteColor];
    ANSegmentScrollStyle *style = [[ANSegmentScrollStyle alloc] init];
    style.showLine = NO;
    style.showCover = NO;
    style.scaleTitle = YES;
    style.scrollTitle = NO;
    style.adjustCoverOrLineWidth = YES;
    style.refreshPosition = PullToRefreshPositionParentTop;
    UIView *header = [[UIView alloc] init];
    header.backgroundColor = [UIColor purpleColor];
    ANSegmentScrollView *scrollView = [[ANSegmentScrollView alloc]
                                       initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - NAVIGATION_HEIGHT - SAFE_BOTTOM_MARGIN)
                                       segmentScrollStyle:style
                                       segmentTitles:@[@"标题1", @"标题2", @"标题3"]
                                       headerView:header
                                       headerHeight:150
                                       parentVC:self
                                       delegate:self];
    __weak __typeof(scrollView) weakScrollView = scrollView;
    scrollView.pullToRefreshTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        __strong __typeof(weakScrollView) strongScrollView = weakScrollView;
        NSLog(@"%@ - %ld", [strongScrollView currentChildViewController], (long)[strongScrollView currentViewControllerIndex]);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [strongScrollView.pullToRefreshTableView.mj_header endRefreshing];
        });
    }];
    [self.view addSubview:scrollView];
}

- (UIViewController<ANSSChildVCsDelegate> *)an_childVCFromReusableVC:(UIViewController<ANSSChildVCsDelegate> *)reusableVC forIndex:(NSInteger)index {
    if (reusableVC) {
        return reusableVC;
    } else {
        ANTestChildVC *vc = [[ANTestChildVC alloc] init];
        vc.index = index;
        return vc;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"内存警告 -> %@", [self class]);
}

@end
