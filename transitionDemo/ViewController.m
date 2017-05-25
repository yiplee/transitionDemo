//
//  ViewController.m
//  transitionDemo
//
//  Created by Guoyin Lee on 24/05/2017.
//  Copyright © 2017 yiplee. All rights reserved.
//

#import "ViewController.h"
#import "YPPresentaionDemoController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) testPresentation:(id)sender
{
    YPPresentaionDemoController *demo = [YPPresentaionDemoController new];
    [self presentViewController:demo animated:YES completion:nil];
}

@end
