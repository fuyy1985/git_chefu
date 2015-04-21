//
//  QUser.h
//  HRClient
//
//  Created by chenyf on 14/12/28.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMyAccountMoel.h"

@interface QUser : NSObject

+ (QUser *)sharedQUser;

-(void)clearInfo;      //清除用户信息，在登出操作时调用
-(void)updateUserInfo; //更新用户账户信息，在做每一笔交易或者充值的时候都要调用这个接口

@property (nonatomic) BOOL isLogin;
@property (nonatomic) BOOL isVIP;
@property (nonatomic) BOOL isCategoryCar;

@property (nonatomic,strong)  QMyAccountMoel *normalAccount;
@property (nonatomic,strong)  QMyAccountMoel *vipAccount;

@end
