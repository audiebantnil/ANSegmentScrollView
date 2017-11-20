//
//  ViewController.m
//  ANSegmentScrollView
//
//  Created by AudiebantNil on 2017/11/15.
//  Copyright © 2017年 AudiebantNil. All rights reserved.
//

#import "ViewController.h"
#import "ANTestViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    NSLog(@"%@", [NSValue valueWithCGRect:[UIApplication sharedApplication].statusBarFrame]);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)firstStyleView:(UIButton *)sender {
    
}

- (IBAction)secondStyleView:(UIButton *)sender {
    
}

- (IBAction)thirdStyleView:(UIButton *)sender {
    
}

- (IBAction)testSegmentScrollView:(UIButton *)sender {
    ANTestViewController *vc = [[ANTestViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
