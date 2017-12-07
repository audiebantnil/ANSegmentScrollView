//
//  ANSegmentScrollView.m
//  ANSegmentScrollView
//
//  Created by AudiebantNil on 2017/11/16.
//  Copyright © 2017年 AudiebantNil. All rights reserved.
//

#import "ANSegmentScrollView.h"
#import "ANSegmentSuperTableView.h"
#import "ANSegmentMenu.h"
#import "ANCollectionView.h"

#define ANSSCollectionViewCellIdentifier                @"ANSSCollectionViewCellIdentifier"
#define ANSSTableViewCellIdentifier                     @"ANSSTableViewCellIdentifier"

@interface ANSegmentScrollView ()
<
UITableViewDataSource,
UITableViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegate,
UIScrollViewDelegate
>

@property (nonatomic, strong) ANSegmentSuperTableView *tableView;       // 整体滑动视图 (框架主体)

@property (nonatomic, strong) ANSegmentScrollStyle *style;              // 滑动视图样式 (由 传参 确定)
@property (nonatomic, strong) ANSegmentMenu *segmentMenu;               // 中间菜单栏 (由 ANSegmentScrollStyle 确定)
@property (nonatomic, strong) ANCollectionView *collectionView;         // 底部横向滑动视图 (由 ANSegmentScrollStyle 确定)

@property (nonatomic, strong) UIView *headerView;                       // 顶部视图 (由 传参 确定)
@property (nonatomic, assign) CGFloat headerHeight;                     // 顶部视图高度 (由 传参 确定)

@property (nonatomic, weak) UIViewController *parentVC;                 // 父控制器 (由 传参 确定)
@property (nonatomic, weak) id <ANSegmentScrollViewDelegate>delegate;   // 视图代理 (由 传参 确定)
@property (nonatomic, assign) NSInteger itemsCount;                     // 子控制器个数 (由 传参 确定)

/** 所有子控制器字典 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, UIViewController<ANSSChildVCsDelegate> *>*childVCsDict;
/** 当前子控制器 */
@property (nonatomic, strong) UIViewController <ANSSChildVCsDelegate>*currentChildVC;
/** 当前子控制器滑动视图(可能为nil) */
@property (nonatomic, strong) UIScrollView *currentChildScrollView;
/** 当前子控制器索引 */
@property (nonatomic, assign) NSInteger currentIndex;
/** 上一次子控制器索引 */
@property (nonatomic, assign) NSInteger oldIndex;
/** 上一次偏移量X值(用于实时判断滑动方向) */
@property (nonatomic, assign) CGFloat oldOffsetX;

/** 当这个属性设置为YES的时候 不用处理 scrollView 滚动的计算 */
@property (nonatomic, assign) BOOL forbidTouchToAdjustPosition;
/** 滑动动画 */
@property (nonatomic, assign) BOOL changeAnimated;
/** 手动管理子控制器生命周期 */
@property (nonatomic, assign) BOOL needManageLifeCycle;

@end

@implementation ANSegmentScrollView

- (instancetype)initWithFrame:(CGRect)frame
           segmentScrollStyle:(ANSegmentScrollStyle *)style
                segmentTitles:(NSArray <NSString *>*)segmentTitles
                   headerView:(UIView *)headerView
                 headerHeight:(CGFloat)headerHeight
                     parentVC:(UIViewController *)parentVC
                     delegate:(id <ANSegmentScrollViewDelegate>)delegate {
    if (self = [super initWithFrame:frame]) {
        if (style) _style = style;
        if (segmentTitles && segmentTitles.count > 0) {
            __weak __typeof(self) weakSelf = self;
            _segmentMenu = [[ANSegmentMenu alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, self.style.segmentHeight)
                                                          style:self.style
                                                         titles:segmentTitles
                                                       delegate:delegate
                                                titleClickBlock:^(ANMenuTitleView *titleView, NSInteger titleIndex) {
                __strong __typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf setCollectionViewOffSet:CGPointMake(frame.size.width * titleIndex, 0.0)
                                         animated:strongSelf.style.isAnimatedContentViewWhenTitleClicked];
            }];
            _itemsCount = segmentTitles.count;
        }
        if (headerView) _headerView = headerView;
        if (headerHeight > 0) _headerHeight = headerHeight;
        _parentVC = parentVC;
        _delegate = delegate;
        _oldIndex = -1;
        _currentIndex = 0;
        _oldOffsetX = 0.0f;
        _forbidTouchToAdjustPosition = NO;
        if (_parentVC) _needManageLifeCycle = ![_parentVC shouldAutomaticallyForwardAppearanceMethods];
        [self addSubview:self.tableView];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveMemoryWarningHander:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

- (void)receiveMemoryWarningHander:(NSNotificationCenter *)noti {
    __weak __typeof(self) weakSelf = self;
    [self.childVCsDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, UIViewController<ANSSChildVCsDelegate> * _Nonnull childVC, BOOL * _Nonnull stop) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (childVC != strongSelf.currentChildVC) {
            [strongSelf vc_removeChildVC:childVC withKey:key];
        }
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.currentChildScrollView) {
        @try {
            [self.currentChildScrollView removeObserver:self forKeyPath:@"contentOffset"];
        } @catch (NSException * __unused exception) {}
    }
#ifdef DEBUG
    NSLog(@"%@ dealloc", [self class]);
#endif
}



#pragma mark - Setup Sync Scroll
/** 纵向同步 -> KVO监听子控制器的ScrollView滑动 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (object == self.currentChildScrollView) {
        CGPoint oldOffset = [change[@"old"] CGPointValue];
        CGPoint newOffset = [change[@"new"] CGPointValue];
        if (oldOffset.y == newOffset.y) return; // 纵向未改变则返回
        [self setupChildScrollViewContentOffset];
    }
}

/** 横向同步 -> 点击菜单栏 手动设置 CollectionView Offset 的方法 */
- (void)setCollectionViewOffSet:(CGPoint)offset animated:(BOOL)animated {
    self.forbidTouchToAdjustPosition = YES;
    self.changeAnimated = YES;
    self.oldIndex = self.currentIndex;
    NSInteger currentIndex = offset.x / self.collectionView.bounds.size.width;
    self.currentIndex = currentIndex;
    self.currentChildVC = [self vc_childVCAtIndex:currentIndex];
    self.currentChildScrollView = [self.currentChildVC an_scrollViewInSegmentChildViewController];
    [self setupChildScrollViewContentOffset];
    if (animated) {
        NSInteger page = fabs(offset.x - self.collectionView.contentOffset.x) / self.collectionView.bounds.size.width;
        if (page >= 2) { // 需要滚动两页以上的时候, 跳过中间页的动画
            self.changeAnimated = NO;
            __weak __typeof(self) weakself = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong __typeof(weakself) strongSelf = weakself;
                if (strongSelf) {
                    [strongSelf.collectionView setContentOffset:offset animated:NO];
                }
            });
        } else {
            [self.collectionView setContentOffset:offset animated:animated];
        }
    } else {
        [self.collectionView setContentOffset:offset animated:animated];
    }
}

/** 根据父控制器滑动偏移调整子控制器滑动偏移 */
- (void)setupChildScrollViewContentOffset {
    if (self.currentChildScrollView == nil) return;
    if (self.tableView.contentOffset.y <= 0 && self.style.refreshPosition == PullToRefreshPositionChildTop) return;
    if (self.tableView.contentOffset.y < self.headerHeight) {
        self.currentChildScrollView.contentOffset = CGPointZero;
        self.currentChildScrollView.showsVerticalScrollIndicator = NO;
        if (self.style.refreshPosition == PullToRefreshPositionParentTop) self.tableView.bounces = YES;
    } else {
        self.currentChildScrollView.showsVerticalScrollIndicator = YES;
        self.tableView.bounces = NO;
    }
}

/** 根据子控制器滑动偏移调整父控制器滑动偏移 */
- (void)setupSuperTableViewContentOffset {
    if (self.currentChildScrollView == nil) return;
    if (self.currentChildScrollView.contentOffset.y > 0) {
        self.tableView.contentOffset = CGPointMake(0, self.headerHeight);
    }
}



#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.forbidTouchToAdjustPosition = NO;
}

/** 纵向同步/横向同步 -> ScrollView滑动监听 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.tableView) { // 纵向滑动处理
        [self setupSuperTableViewContentOffset];
    } else if (scrollView == self.collectionView) { // 横向滑动处理
        if (self.forbidTouchToAdjustPosition || // 点击标题滚动
            scrollView.contentOffset.x <= 0 || // 滑动到第一个或最后一个
            scrollView.contentOffset.x >= scrollView.contentSize.width - scrollView.bounds.size.width) {
            return;
        }
        CGFloat tempProgress = scrollView.contentOffset.x / scrollView.bounds.size.width;
        NSInteger tempIndex = tempProgress;
        CGFloat progress = tempProgress - floor(tempProgress); // 如果参数是小数，则求最大的整数但不大于本身
        CGFloat distanceX = scrollView.contentOffset.x - self.oldOffsetX; // 判断滑动方向
        if (distanceX > 0) { // 向右滑动
            if (progress == 0.0) return;
            self.currentIndex = tempIndex + 1;
            self.oldIndex = tempIndex;
        } else if (distanceX < 0) { // 向左滑动
            progress = 1.0 - progress;
            self.oldIndex = tempIndex + 1;
            self.currentIndex = tempIndex;
        } else { // 不动
            return;
        }
        self.oldOffsetX = scrollView.contentOffset.x;
        self.currentChildVC = [self vc_childVCAtIndex:self.currentIndex];
        self.currentChildScrollView = [self.currentChildVC an_scrollViewInSegmentChildViewController];
        [self setupChildScrollViewContentOffset];
        if (self.segmentMenu) { // 根据进度调整
            [self.segmentMenu adjustUIWithProgress:progress fromIndex:self.oldIndex toIndex:self.currentIndex];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView != self.collectionView) return; // 不是横向滑动则返回
    if (self.parentVC && [self.parentVC.parentViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navi = (UINavigationController *)self.parentVC.parentViewController;
        if (navi.interactivePopGestureRecognizer) navi.interactivePopGestureRecognizer.enabled = YES;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView != self.collectionView) return; // 不是横向滑动则返回
    if (self.segmentMenu) {
        NSInteger currentIndex = (scrollView.contentOffset.x / self.bounds.size.width);
        [self.segmentMenu adjustUIWithProgress:1.0 fromIndex:currentIndex toIndex:currentIndex];
        [self.segmentMenu adjustTitleOffsetAtIndex:currentIndex];
    }
}



#pragma mark - UICollectionViewDataSource / UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.itemsCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ANSSCollectionViewCellIdentifier forIndexPath:indexPath];
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.parentVC == nil) return; // 父控制器为nil
    // 取子控制器
    self.currentIndex = indexPath.row;
    self.currentChildVC = [self vc_childVCAtIndex:self.currentIndex];
    BOOL isFirstLoaded = self.currentChildVC == nil;
    if (self.delegate && [self.delegate respondsToSelector:@selector(an_childVCFromReusableVC:forIndex:)]) {
        if (isFirstLoaded) {
            self.currentChildVC = [self.delegate an_childVCFromReusableVC:nil forIndex:indexPath.row];
            if ([self.currentChildVC conformsToProtocol:@protocol(ANSSChildVCsDelegate)] == NO) {
                NSAssert(NO, @"子控制器必须遵守 ANSSChildVCsDelegate 协议");
            } else if ([self.currentChildVC respondsToSelector:@selector(an_scrollViewInSegmentChildViewController)] == NO) {
                NSAssert(NO, @"子控制器必须实现必要的代理方法");
            }
            [self vc_addChildVC:self.currentChildVC atIndex:self.currentIndex];
        } else {
            [self.delegate an_childVCFromReusableVC:self.currentChildVC forIndex:indexPath.row];
        }
    } else {
        NSAssert(NO, @"必须实现必要的代理方法");
    }
    // 建立子控制器和父控制器的关系
    if ([self.currentChildVC isKindOfClass:[UINavigationController class]]) {
        NSAssert(NO, @"不要添加 UINavigationController 包装后的子控制器");
    }
    for (UIView *subView in self.currentChildVC.view.subviews) {
        subView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    self.currentChildVC.view.frame = cell.contentView.bounds;
    [cell.contentView addSubview:self.currentChildVC.view];
    [self.currentChildVC didMoveToParentViewController:self.parentVC];
    self.currentChildScrollView = [self.currentChildVC an_scrollViewInSegmentChildViewController];
    // 调用 currentIndex 控制器生命周期方法
    [self _childViewWillAppearAtIndex:self.currentIndex];
    [self _childViewDidAppearAtIndex:self.currentIndex];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.oldIndex != indexPath.item) { // 滑动切换了页面但并未松手 (在 willDisplayCell 调用的Appear方法现在需要Disappear)
        [self _childViewWillDisappearAtIndex:self.currentIndex];
        [self _childViewDidDisappearAtIndex:self.currentIndex];
        return;
    }
    // 调用 oldIndex 控制器生命周期方法 (向左滑动完成/向右滑动完成/点击菜单栏切换时 self.oldIndex == indexPath.item)
    [self _childViewWillDisappearAtIndex:self.oldIndex];
    [self _childViewDidDisappearAtIndex:self.oldIndex];
}



#pragma mark - UITableViewDataSource / UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ANSSTableViewCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ANSSTableViewCellIdentifier];
        cell.backgroundColor = [UIColor whiteColor];
        if (self.segmentMenu) [cell.contentView addSubview:self.segmentMenu];
        [cell.contentView addSubview:self.collectionView];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.bounds.size.height;
}



#pragma mark - Life Circle
- (void)_childViewWillAppearAtIndex:(NSInteger)index {
    NSString *key = [NSString stringWithFormat:@"%ld", (long)index];
    UIViewController<ANSSChildVCsDelegate> *controller = nil;
    if ([self.childVCsDict valueForKey:key]) {
        controller = [self.childVCsDict valueForKey:key];
    }
    if (controller == nil) return;
    // 子控制器系统生命周期方法调用
    if (self.needManageLifeCycle) {
        [controller beginAppearanceTransition:YES animated:NO];
    } else if ([controller respondsToSelector:@selector(an_viewWillAppearAtIndex:)]) {
        [controller an_viewWillAppearAtIndex:index];
    }
    // 本视图代理的代理方法调用
    if (self.delegate && [self.delegate respondsToSelector:@selector(parentVC:childVC:willAppearAtIndex:)]) {
        [self.delegate parentVC:self.parentVC childVC:controller willAppearAtIndex:index];
    }
}

- (void)_childViewDidAppearAtIndex:(NSInteger)index {
    NSString *key = [NSString stringWithFormat:@"%ld", (long)index];
    UIViewController<ANSSChildVCsDelegate> *controller = nil;
    if ([self.childVCsDict valueForKey:key]) {
        controller = [self.childVCsDict valueForKey:key];
    }
    if (controller == nil) return;
    // 子控制器系统生命周期方法调用
    if (self.needManageLifeCycle) {
        [controller endAppearanceTransition];
    } else if ([controller respondsToSelector:@selector(an_viewDidAppearAtIndex:)]) {
        [controller an_viewDidAppearAtIndex:index];
    }
    // 本视图代理的代理方法调用
    if (self.delegate && [self.delegate respondsToSelector:@selector(parentVC:childVC:didAppearAtIndex:)]) {
        [self.delegate parentVC:self.parentVC childVC:controller didAppearAtIndex:index];
    }
    // 添加观察者
    UIScrollView *scrollView = [controller an_scrollViewInSegmentChildViewController];
    if (scrollView) {
        [scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    }
}

- (void)_childViewWillDisappearAtIndex:(NSInteger)index {
    NSString *key = [NSString stringWithFormat:@"%ld", (long)index];
    UIViewController<ANSSChildVCsDelegate> *controller = nil;
    if ([self.childVCsDict valueForKey:key]) {
        controller = [self.childVCsDict valueForKey:key];
    }
    if (controller == nil) return;
    // 子控制器系统生命周期方法调用
    if (self.needManageLifeCycle) {
        [controller beginAppearanceTransition:NO animated:NO];
    } else if ([controller respondsToSelector:@selector(an_viewWillDisappearAtIndex:)]) {
        [controller an_viewWillDisappearAtIndex:index];
    }
    // 本视图代理的代理方法调用
    if (self.delegate && [self.delegate respondsToSelector:@selector(parentVC:childVC:willDisappearAtIndex:)]) {
        [self.delegate parentVC:self.parentVC childVC:controller willDisappearAtIndex:index];
    }
}

- (void)_childViewDidDisappearAtIndex:(NSInteger)index {
    NSString *key = [NSString stringWithFormat:@"%ld", (long)index];
    UIViewController<ANSSChildVCsDelegate> *controller = nil;
    if ([self.childVCsDict valueForKey:key]) {
        controller = [self.childVCsDict valueForKey:key];
    }
    if (controller == nil) return;
    // 子控制器系统生命周期方法调用
    if (self.needManageLifeCycle) {
        [controller endAppearanceTransition];
    } else if ([controller respondsToSelector:@selector(an_viewDidDisappearAtIndex:)]) {
        [controller an_viewDidDisappearAtIndex:index];
    }
    // 本视图代理的代理方法调用
    if (self.delegate && [self.delegate respondsToSelector:@selector(parentVC:childVC:didDisappearAtIndex:)]) {
        [self.delegate parentVC:self.parentVC childVC:controller didDisappearAtIndex:index];
    }
    // 移除观察者
    UIScrollView *scrollView = [controller an_scrollViewInSegmentChildViewController];
    if (scrollView) {
        @try {
            [scrollView removeObserver:self forKeyPath:@"contentOffset"];
        } @catch (NSException * __unused exception) {}
    }
}



#pragma mark - Setup Child VCs Dictionary
/** 获取子控制器 */
- (UIViewController <ANSSChildVCsDelegate>*)vc_childVCAtIndex:(NSInteger)index {
    NSString *key = [NSString stringWithFormat:@"%ld", (long)self.currentIndex];
    if ([self.childVCsDict valueForKey:key]) {
        return [self.childVCsDict valueForKey:key];
    } else {
        return nil;
    }
}

/** 添加子控制器 */
- (void)vc_addChildVC:(UIViewController <ANSSChildVCsDelegate>*)childVC atIndex:(NSInteger)index {
    NSString *key = [NSString stringWithFormat:@"%ld", (long)self.currentIndex];
    [self.childVCsDict setValue:childVC forKey:key];
    if (self.parentVC) [self.parentVC addChildViewController:childVC];
}

/** 移除子控制器 */
- (void)vc_removeChildVC:(UIViewController <ANSSChildVCsDelegate>*)childVC withKey:(NSString *)key {
    if ([self.childVCsDict valueForKey:key]) {
        [self.childVCsDict removeObjectForKey:key];
        [childVC willMoveToParentViewController:nil];
        [childVC.view removeFromSuperview];
        [childVC removeFromParentViewController];
    }
}



#pragma mark - Getters
/** 整体风格 */
- (ANSegmentScrollStyle *)style {
    if (_style) return _style;
    _style = [[ANSegmentScrollStyle alloc] init];
    return _style;
}

/** 纵向滑动父视图 */
- (ANSegmentSuperTableView *)tableView {
    if (_tableView) return _tableView;
    _tableView = [[ANSegmentSuperTableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    if (self.headerView) {
        self.headerView.frame = CGRectMake(0, 0, self.bounds.size.width, self.headerHeight);
        _tableView.tableHeaderView = self.headerView;
    }
    if (self.style.refreshPosition != PullToRefreshPositionParentTop) {
        _tableView.bounces = NO;
    }
    return _tableView;
}

/** 横向滑动视图 */
- (ANCollectionView *)collectionView {
    if (_collectionView) return _collectionView;
    // 设置frame
    CGFloat scrollY = 0;
    CGFloat scrollH = self.bounds.size.height;
    if (scrollH == 812) { // 适配 IPhone X
        scrollH = scrollH - 84 - 34;
    }
    if (self.style.segmentHeight > 0) { // 判断菜单栏高度
        scrollY = self.style.segmentHeight;
        scrollH = scrollH - self.style.segmentHeight;
    }
    // 设置layout
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(self.bounds.size.width, scrollH);
    layout.minimumLineSpacing = 0.0;
    layout.minimumInteritemSpacing = 0.0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    // 初始化
    _collectionView = [[ANCollectionView alloc] initWithFrame:CGRectMake(0, scrollY, self.bounds.size.width, scrollH)
                                         collectionViewLayout:layout];
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.pagingEnabled = YES;
    _collectionView.scrollsToTop = NO;
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.bounces = self.style.isContentViewBounces;
    _collectionView.scrollEnabled = self.style.isScrollContentView;
    [_collectionView setBackgroundColor:[UIColor whiteColor]];
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:ANSSCollectionViewCellIdentifier];
    return _collectionView;
}

/** 存储子控制器字典 */
- (NSMutableDictionary<NSString *, UIViewController<ANSSChildVCsDelegate> *>*)childVCsDict {
    if (_childVCsDict) return _childVCsDict;
    _childVCsDict = [NSMutableDictionary dictionaryWithCapacity:self.itemsCount];
    return _childVCsDict;
}

/** 设置顶部下拉刷新的tableView */
- (UITableView *)pullToRefreshTableView {
    if (self.style.refreshPosition == PullToRefreshPositionParentTop) return self.tableView;
    return nil;
}

/** 当前子控制器 */
- (UIViewController<ANSSChildVCsDelegate> *)currentChildViewController {
    return self.currentChildVC;
}

/** 当前子控制器序号 */
- (NSInteger)currentViewControllerIndex {
    return self.currentIndex;
}



@end
