//
//  QUser.m
//  HRClient
//
//  Created by chenyf on 14/12/28.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QUser.h"
#import "QHttpMessageManager.h"

@implementation QUser

+ (QUser *)sharedQUser
{
    static QUser *_client;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _client = [[QUser alloc] init];
        
        _client.isVIP = NO;
        _client.isLogin = NO;
        _client.isCategoryCar = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:_client selector:@selector(updateInfo:) name:kGetMyAccountInfro object:nil];
    });
    return _client;
}

- (void)updateUserInfo
{
    [[QHttpMessageManager sharedHttpMessageManager] accessMyAccount];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kGetMyAccountInfro object:nil];
}

-(void)updateInfo:(NSNotification*)noti
{
    NSArray *myAccountData = noti.object;
    if (myAccountData.count > 0)
    {
        self.normalAccount = myAccountData[0];
    }
    if (myAccountData.count > 1)
    {
        self.vipAccount = myAccountData[1];
        self.isVIP = YES;
    }
}

-(void)clearInfo
{
    self.normalAccount = nil;
    self.vipAccount = nil;
    self.isVIP = NO;
}

@end
