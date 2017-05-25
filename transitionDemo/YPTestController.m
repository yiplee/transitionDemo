//
//  YPTestController.m
//  transitionDemo
//
//  Created by Guoyin Lee on 24/05/2017.
//  Copyright © 2017 yiplee. All rights reserved.
//

#import "YPTestController.h"

@interface YPTestController ()

@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIView *bottomIndicator;

@end

@implementation YPTestController
{
    CGFloat _layoutHeight;
}

- (instancetype) initWithLayoutHeight:(CGFloat)height
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _layoutHeight = height;
        self.title = @"Test";
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _detailLabel = [UILabel new];
    _detailLabel.numberOfLines = 0;
    _detailLabel.textAlignment = NSTextAlignmentCenter;
    _detailLabel.font = [UIFont systemFontOfSize:18];
    _detailLabel.textColor = [UIColor blackColor];
    [self.view addSubview:_detailLabel];
    
    self.view.backgroundColor = [UIColor colorWithRed:arc4random_uniform(255) / 256.0
                                                green:arc4random_uniform(255) / 256.0
                                                 blue:arc4random_uniform(255) / 256.0
                                                alpha:1];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGRect bounds = self.view.bounds;
    
    NSString *text = [NSString stringWithFormat:@"navigation : %@\nview : %@",NSStringFromCGRect(self.navigationController.view.bounds),NSStringFromCGRect(self.view.frame)];
    self.detailLabel.text = text;
    
    [_detailLabel sizeToFit];
    _detailLabel.center = CGPointMake(bounds.size.width / 2, 200);
}

- (CGSize) preferredContentSize
{
    CGSize size = [super preferredContentSize];
    size.height = _layoutHeight;
    return size;
}

@end
