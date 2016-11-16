//
//  ViewController.m
//  KYAlertWebView
//
//  Created by 易之盛 on 16/11/16.
//  Copyright © 2016年 康义. All rights reserved.
//

#import "ViewController.h"
#import "KYAlertWebView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    KYAlertWebView * webView = [[KYAlertWebView alloc]init];
    [webView show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
