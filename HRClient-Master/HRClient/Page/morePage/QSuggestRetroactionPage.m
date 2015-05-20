//
//  QSuggestRetroactionPage.m
//  HRClient
//
//  Created by amy.fu on 15/3/29.
//  Copyright (c) 2015年 panyj. All rights reserved.
//

#import "QSuggestRetroactionPage.h"
#import "QHttpMessageManager.h"
#import "QViewController.h"

@interface QSuggestRetroactionPage ()

@property (nonatomic,strong)UITextView *myTextView;
@property (nonatomic,assign)BOOL bEditting;

@end

@implementation QSuggestRetroactionPage


- (void)pageEvent:(QPageEventType)eventType
{
    if (eventType == kPageEventViewCreate)
    {
        //NOTE:页面的消息接口 同普通controller的 隐藏消失回调
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(successToAcceive:) name:kSuggestRetroaction object:nil];
        
    }else if (eventType == kPageEventWillHide){
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kSuggestRetroaction object:nil];
    }
}


-(void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length == 0 && !self.bEditting) {
        self.myTextView.text = @"请在此输入您要反馈的信息。您的反馈对我们很重要，谢谢。";
        self.myTextView.textColor = [UIColor lightGrayColor];
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    self.myTextView.textColor = [UIColor blackColor];
    self.myTextView.text = @"";
    self.bEditting = YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""])
    {
        self.myTextView.text = @"请在此输入您要反馈的信息。您的反馈对我们很重要，谢谢。";
        self.myTextView.textColor = [UIColor lightGrayColor];
    }
    self.bEditting = NO;
}

- (UIView *)viewWithFrame:(CGRect)frame
{
    if ([super viewWithFrame:frame])
    {
        self.myTextView  =[[UITextView alloc] initWithFrame:CGRectMake(10, 10, SCREEN_SIZE_WIDTH - 2 * 10, (600.0/960.0) * SCREEN_SIZE_HEIGHT)];
        self.myTextView.delegate = self;
        self.myTextView.text = @"请在此输入您要反馈的信息。您的反馈对我们很重要，谢谢。";
        self.myTextView.textColor = [UIColor lightGrayColor];
        self.myTextView.font = [UIFont systemFontOfSize:15.f];
        self.myTextView.backgroundColor = [UIColor whiteColor];
        [_view addSubview:self.myTextView];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(self.myTextView.deFrameLeft, self.myTextView.deFrameBottom + (35.0/960.0) * SCREEN_SIZE_HEIGHT, self.myTextView.deFrameWidth, 40);
        [btn setBackgroundImage:[QTools createImageWithColor:ColorTheme] forState:UIControlStateNormal];
        btn.layer.masksToBounds = YES;
        btn.layer.cornerRadius = 4.0;
        [btn setTitle:@"发送" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(clickToSend) forControlEvents:UIControlEventTouchUpInside];
        [_view addSubview:btn];
        
        self.bEditting = NO;
    }
    return _view;
}

- (NSString*)title //NOTE:页面标题
{
    return _T(@"用户反馈");
}

- (QNavigationType)navigationType //NOTE:导航栏是否存在
{
    return kNavigationTypeNormal;
}

- (void)successToAcceive:(NSNotification *)noti
{
    [ASRequestHUD dismissWithSuccess:@"内容提交成功，谢谢您的宝贵建议"];
    [QViewController backPageWithParam:nil];
}

- (void)clickToSend{
    if (self.myTextView.text.length != 0) {
        [[QHttpMessageManager sharedHttpMessageManager] accessSuggestRetroaction:self.myTextView.text];
        [ASRequestHUD show];
    }else{
        UIAlertView *alert= [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"您还未填写内容噢" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
    }
}

@end
