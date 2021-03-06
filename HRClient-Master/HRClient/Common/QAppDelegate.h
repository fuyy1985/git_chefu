//
//  QAppDelegate.h
//  DSSClient
//
//  Created by pany on 14-4-18.
//  Copyright (c) 2014年 SDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMapKit.h"
#import "ASIHTTPRequest.h"
#import "ASIDownloadCache.h"
#import "WXApi.h"
#import "payRequsestHandler.h"

@interface QAppDelegate : UIResponder <UIApplicationDelegate, WXApiDelegate>{
    BMKMapManager *_mapManager;
}

@property (strong, nonatomic) UIWindow *window;
+ (QAppDelegate*)appDelegate;
@property (assign, nonatomic) UIBackgroundTaskIdentifier bgTask;
@property (nonatomic,strong)  ASIDownloadCache *myCache;

@property (nonatomic,strong)NSString *partner;
@property (nonatomic,strong)NSString *seller;
@property (nonatomic,strong)NSString *privateKey;
/*微信支付*/
- (void)sendWXPay:(NSString*)orderId name:(NSString*)orderName price:(double)price url:(NSString*)notifyUrl;

@end


//appid  

/*
用户性质                     用户名                  用户登录密码
会员（余额充足）               z s l                   123456
会员 (余额不足)                 YQ1                   123456
会员年卡                       YQ2                    123456
普通用户                       z s j                  123456*/
