//
//  QCountDown.m
//  HRClient
//
//  Created by ekoo on 15/1/6.
//  Copyright (c) 2015年 panyj. All rights reserved.
//

#import "QCountDown.h"

@implementation QCountDown

+ (void)startTime:(UIButton *)l_timeButton{
    __block int timeout = 59; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout<=0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                l_timeButton.backgroundColor = UIColorFromRGB(0xc40000);
                [l_timeButton setTitle:@"发送验证码" forState:UIControlStateNormal];
                l_timeButton.userInteractionEnabled = YES;
            });
        }else{

            int seconds = timeout % 60;
            NSString *strTime = [NSString stringWithFormat:@"%.2d", seconds];
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                l_timeButton.backgroundColor = [QTools colorWithRGB:86 :86 :86];
                [l_timeButton setTitle:[NSString stringWithFormat:@"%@秒后重新发送",strTime] forState:UIControlStateNormal];
                l_timeButton.userInteractionEnabled = NO;
                
            });
            timeout--;
            
        }
    });
    dispatch_resume(_timer);

}

@end
