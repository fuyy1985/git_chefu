//
//  QAgreementPage.m
//  HRClient
//
//  Created by panyj on 15/3/23.
//  Copyright (c) 2015年 panyj. All rights reserved.
//

#import "QAgreementPage.h"
#import "QHttpMessageManager.h"
#import "QAgreementModel.h"

@interface QAgreementPage ()
{
    int _agreementType;
    UITextView *_contentTextView;
}

@end

@implementation QAgreementPage

- (NSString*)title
{
    NSString *title = @"";
    
    if (1 == _agreementType) {
        title = @"用户使用协议";
    }
    else if (2 == _agreementType) {
        title = @"洗车会员卡充值协议";
    }
    else if (3 == _agreementType) {
        title = @"洗车会员卡使用规则";
    }
    else if (6 == _agreementType){
        title = @"使用帮助";
    }
    else if (8 == _agreementType){
        title = @"会员中心";
    }
    return title;
}

- (void)setActiveWithParams:(NSDictionary *)params
{
    _agreementType = [[params objectForKey:@"agreementType"] intValue];
}

- (UIView *)viewWithFrame:(CGRect)frame
{
    if ([super viewWithFrame:frame]) {
        _view.backgroundColor = [QTools colorWithRGB:240 :239 :237];
        
        _contentTextView = [[UITextView alloc] initWithFrame:CGRectMake(15, 15, frame.size.width - 2*15, frame.size.height - 2*15)];
        _contentTextView.font = [UIFont systemFontOfSize:14];
        _contentTextView.textColor = ColorDarkGray;
        _contentTextView.editable = NO;
        _contentTextView.backgroundColor = [UIColor clearColor];
        _contentTextView.showsVerticalScrollIndicator = NO;
        _contentTextView.clipsToBounds = NO;
        [_view addSubview:_contentTextView];
        
        _view.clipsToBounds = YES;
    }
    
    return _view;
}

- (void)pageEvent:(QPageEventType)eventType
{
    if (eventType == kPageEventViewCreate)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(successGetAgreement:) name:kGetAgreement object:nil];
        
        [[QHttpMessageManager sharedHttpMessageManager] accessGetAgreement:_agreementType];
        [ASRequestHUD show];
    }
    else if (eventType == kPageEventViewDispose)
    {
        [ASRequestHUD dismiss];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kGetAgreement object:nil];
    }
}

#pragma mark - Notification

- (void)successGetAgreement:(NSNotification*)noti
{
    [ASRequestHUD dismiss];
    
    NSArray *array = noti.object;
    if (array.count > 0) {
        QAgreementModel *model = [array objectAtIndex:0];
        _contentTextView.text = model.content;
    }
}
@end
