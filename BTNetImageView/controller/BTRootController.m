//
//  BTRootController.m
//  BTNetImageView
//
//  Created by 王 浩宇 on 13-6-26.
//  Copyright (c) 2013年 王 浩宇. All rights reserved.
//

#import "BTRootController.h"
#import "BTOperationViewController.h"

@interface BTRootController ()

@end

@implementation BTRootController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title = @"Root";
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(100, 100, 100, 50);
    [btn setTitle:@"点击" forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(test) forControlEvents:UIControlEventTouchUpInside];
}

- (void)test{
    BTOperationViewController *con = [[[BTOperationViewController alloc] init] autorelease];
    [self.navigationController pushViewController:con animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
