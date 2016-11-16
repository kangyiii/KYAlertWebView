//
//  KYAlertWebView.m
//  test
//
//  Created by 易之盛 on 16/11/16.
//  Copyright © 2016年 康义. All rights reserved.
//

#import "KYAlertWebView.h"
#import <WebKit/WebKit.h>

@interface KYAlertWebView ()<WKNavigationDelegate,WKUIDelegate>

/**
 需要渲染的View
 */
@property (nonatomic, strong)UIView * alertView;

/**
 关闭按钮
 */
@property (nonatomic, strong) UIButton *closeBtn;

/**
 显示窗口
 */
@property (nonatomic, strong) UIWindow *showWindow;

/**
 webView
 */
@property (nonatomic, strong)WKWebView * webView;

/**
 webView
 */
@property (nonatomic, strong)UIWebView * webView1;

/**
 进度条
 */
@property (strong, nonatomic) UIProgressView *progressView;
@end

@implementation KYAlertWebView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.view.frame = [UIScreen mainScreen].bounds;
        self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.3f];
        
        [self setupView];
    }
    return self;
}
- (void)setupView{
     if (!self.alertView) {
         CGFloat width = [UIScreen mainScreen].bounds.size.width;
         CGFloat height = [UIScreen mainScreen].bounds.size.height;
         self.alertView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width-(50*width/height), height-50)];
         self.alertView.backgroundColor = [UIColor colorWithWhite:1. alpha:.95];
         self.alertView.center = CGPointMake(width/2, height/2);
         self.alertView.layer.cornerRadius = 5.f;
         self.alertView.layer.masksToBounds = YES;
         [self.view addSubview:self.alertView];
         
//       //添加webView(<iOS8.0)
//         self.webView1 = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, width-(100*width/height), height-150)];
//         [self.webView1 loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]]];
//         self.webView1.scalesPageToFit = YES;
//         [self.alertView addSubview:self.webView1];
         
         //添加WKWebView(>iOS8.0)
         self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, width-(50*width/height), height-50)];
         self.webView.navigationDelegate = self;
         self.webView.UIDelegate = self;
         [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://github.com/"]]];
         //给_webView添加监听
         [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
         [self.alertView addSubview:self.webView];
         //添加进度条
         self.progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame),2)];
         [self.alertView addSubview:self.progressView];
         
         self.closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
         [self.closeBtn setFrame:CGRectMake(0, 0, 50, 50)];
         [self.closeBtn setTitle:@"╳" forState:UIControlStateNormal];
         [self.closeBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
         [self.closeBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
         self.closeBtn.titleLabel.font = [UIFont systemFontOfSize:15];
         [self.alertView addSubview:_closeBtn];
     }
}

/**
 显示window
 */
- (void)show {
    UIWindow *newWindow = [[UIWindow alloc]initWithFrame:self.view.bounds];
    newWindow.rootViewController = self;
    [newWindow makeKeyAndVisible];
    self.showWindow = newWindow;
    
    //简单弹簧效果
    self.alertView.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
    self.alertView.alpha = 0;
    
    [UIView animateWithDuration:.7f delay:0.f usingSpringWithDamping:.7f initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alertView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        self.alertView.alpha = 1.0;
    } completion:nil];
}

/**
 移除window
 */
- (void)dismiss {
    [UIView animateWithDuration:0.3f animations:^{
        self.alertView.transform = CGAffineTransformMakeScale(1.21f, 1.21f);
        self.alertView.alpha = 0;
        self.showWindow.alpha = 0;
    } completion:^(BOOL finished) {
        //            [self removeFromSuperview];
        [self.showWindow removeFromSuperview];
        [self.showWindow resignKeyWindow];
        self.showWindow = nil;
    }];
}

#pragma mark - WebView相关操作
//进度条
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (object == _webView && [keyPath isEqualToString:@"estimatedProgress"] ) {
        [self.progressView setAlpha:1.0f];
        [self.progressView setProgress:_webView.estimatedProgress animated:YES];
        if(_webView.estimatedProgress >= 1.0f)
        {
            [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.progressView setAlpha:0.0f];
            } completion:^(BOOL finished) {
                [self.progressView setProgress:0.0f animated:NO];
            }];
        }
    }else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

// API是根据WebView对于即将跳转的HTTP请求头信息和相关信息来决定是否跳转
-(void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSURLRequest * request = navigationAction.request;
    NSLog(@"%@",request.URL.absoluteString);
    WKNavigationActionPolicy  actionPolicy = WKNavigationActionPolicyAllow;
    decisionHandler(actionPolicy);
}

//  页面加载失败
-(void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    NSLog(@"%@",error);
}

- (void)dealloc {
    [_webView removeObserver:self forKeyPath:@"estimatedProgress"];
    
    // if you have set either WKWebView delegate also set these to nil here
    [_webView setNavigationDelegate:nil];
    [_webView setUIDelegate:nil];
}
@end
