//
//  ANTestChildVC.m
//  ANSegmentScrollView
//
//  Created by AudiebantNil on 2017/11/16.
//  Copyright © 2017年 AudiebantNil. All rights reserved.
//

#import "ANTestChildVC.h"

@interface ANTestChildVC ()
<
UITableViewDataSource,
UITableViewDelegate
>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ANTestChildVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    NSLog(@"%s -> %ld", __FUNCTION__, (long)self.index);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"%s -> %ld", __FUNCTION__, (long)self.index);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"%s -> %ld", __FUNCTION__, (long)self.index);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSLog(@"%s -> %ld", __FUNCTION__, (long)self.index);
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    NSLog(@"%s -> %ld", __FUNCTION__, (long)self.index);
}

//- (void)an_viewWillAppearAtIndex:(NSInteger)index {
//    NSLog(@"%s -> %ld - %ld", __FUNCTION__, (long)self.index, (long)index);
//}
//
//- (void)an_viewDidAppearAtIndex:(NSInteger)index {
//    NSLog(@"%s -> %ld - %ld", __FUNCTION__, (long)self.index, (long)index);
//}
//
//- (void)an_viewWillDisappearAtIndex:(NSInteger)index {
//    NSLog(@"%s -> %ld - %ld", __FUNCTION__, (long)self.index, (long)index);
//}
//
//- (void)an_viewDidDisappearAtIndex:(NSInteger)index {
//    NSLog(@"%s -> %ld - %ld", __FUNCTION__, (long)self.index, (long)index);
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UIScrollView *)an_scrollViewInSegmentChildViewController {
    return self.tableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"cell_1";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"第%ld页, 第%ld行", (long)self.index, (long)indexPath.row];
    return cell;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.showsVerticalScrollIndicator = NO;
    }
    return _tableView;
}

@end
