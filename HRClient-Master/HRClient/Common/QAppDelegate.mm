//
//  QAppDelegate.m
//  DSSClient
//
//  Created by pany on 14-4-18.
//  Copyright (c) 2014年 SDK. All rights reserved.
//

#import "QAppDelegate.h"
#import "QConfigration.h"
#import "QViewController.h"
#import "QDataCenter.h"
#import "QGuidepageController.h"
#import "SDImageCache.h"
#import <AlipaySDK/AlipaySDK.h>
#import "UMSocial.h"
#import "UMSocialWechatHandler.h"
#import "payRequsestHandler.h"
#import "QHttpMessageManager.h"

void handler(int n)
{
    //nothing
}

@implementation QAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    struct sigaction sa;
    sa.__sigaction_u.__sa_handler = handler;
    sigaction(SIGPIPE, &sa, 0);
    
    [UMSocialData setAppKey:UMSocalAppKey];
    //urlType也需要改，是appid，我写的是appkey
    [UMSocialWechatHandler setWXAppId:@"wx491220a1f4d6bbc8" appSecret:@"85d650d43e0459a3848b12da3da796f5"
                                  url:@"http://www.wanliwuyou.com/downloadiPhone.html"];
    
    self.partner = @"2088711426105023";
    self.seller = @"286601644@qq.com";
    self.privateKey = @"MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBAMhjLAz9lGOhnCWdBgEnGsXCdAo2/7S9KiUbdHoCJUbbW6juS8oRZKgIkzrdApZGP4TMLK2VwdiHkAKDIAVerx6hywByUYUhFg1aTa9VMqdFXNoOQJFcEgpmRjgH+e83i9SxtklAVaUFk/WoQdceya7AztIw5jSv+BpCO9dyG/vjAgMBAAECgYBsVzoU1/EnoNPUfj4l12ehLk4gy7WamX+0ylBCOvC+i5DWF+iAGsFKHEDF3YItj1N+UAmD3GkO0dRpl01zucqBlwrohcHCXMLOwqfMaYJvvp+/z5rSyKSAackNWJB7xAFLxhc+daQ0+f+6MOpbE7RBJ4Ixa8DeeoC8PWDfmJgroQJBAO5Ujwhn4XxfYy7JP3gJOtv8CSKiTfKlORjMOQ6hCWlrJbGpjybVxAA932nFrJkDwpMRT5i/9EfLLyqabJBwL9ECQQDXPne1gxLaQ2bug3B/WtF80vWOKNWL7AL4xpCHmYAYwNUYJQcNiZln9y+4v4RG742xbuzlDJgi4T8d+vwc97FzAkBuEmes/i1J/9QS+6dwjPK+Pv0JHeTaOCzSox+G/iEWqwHRt/oBeaD4a5sPgthgIzhuLASTC7SKo/C4wHF7lBTBAkEAkjYGzy/YUJdUhlSWyIwCnY4X65dlaATMB/2qE9J7p1Tl697LKbD8mhjZO+AslJsJXywAk564gYkMfOsO8wZ2bQJAVLx+heas+W2H5klGZiVltymmp+XggvbUfmYef5vH2bZ4gEyHQZCXoU3vim4UMKMpl35Upq4AHEAL1/IgZNqOCg==";
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [[QConfigration sharedInstance] loadFile];
    
    //start
    self.window.rootViewController = [QViewController shareController];
    
    NSString *bundledPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"CustomPathImages"];
    [[SDImageCache sharedImageCache] addReadOnlyCachePath:bundledPath];
    
    _mapManager = [[BMKMapManager alloc] init];
    BOOL ret = [_mapManager start:@"4DIiEFcgCohaQI00qFxglt8D" generalDelegate:nil];
    if (!ret) {
        [QViewController showMessage:@"地图启动失败"];
    }
    
    [self installDownloadCache];
    return YES;
}


- (void)installDownloadCache
{
    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:4 * 1024 * 1024 diskCapacity:20 * 1024 * 1024 diskPath:nil];
    [NSURLCache setSharedURLCache:URLCache];
    ASIDownloadCache *cache = [[ASIDownloadCache alloc] init];
    self.myCache = cache;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    [self.myCache setStoragePath:[documentDirectory stringByAppendingPathComponent:@"resource"]];
    [self.myCache setDefaultCachePolicy:ASIOnlyLoadIfNotCachedCachePolicy];
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    [BMKMapView willBackGround];//当应用即将后台时调用，停止一切调用opengl相关的操作
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [QConfigration saveFile];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [UMSocialSnsService handleOpenURL:url];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [BMKMapView didForeGround];//当应用恢复前台状态时调用，回复地图的渲染和opengl相关的操作
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    //保存文件
    [QConfigration saveFile];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    if ([url.host isEqualToString:@"safepay"]) {
        
        [[AlipaySDK defaultService] processAuth_V2Result:url
                                         standbyCallback:^(NSDictionary *resultDic) {
                                             NSLog(@"result = %@",resultDic);
                                             NSString *resultStr = resultDic[@"result"];
                                             NSLog(@"result = %@",resultStr);
                                         }];
        
    }
    else if ([url.host isEqualToString:@"pay"])
    {
        //微信支付
        [WXApi handleOpenURL:url delegate:self];
    }
    else
    {
        return  [UMSocialSnsService handleOpenURL:url];
    }
    
    return YES;
}

#pragma mark - 
+ (QAppDelegate*)appDelegate
{
    return (QAppDelegate*)[UIApplication sharedApplication].delegate;
}

#pragma mark - WXPay
- (void)sendWXPay:(NSString*)orderId name:(NSString*)orderName price:(double)price
{
    //{{{
    //本实例只是演示签名过程， 请将该过程在商户服务器上实现
    
    //创建支付签名对象
    payRequsestHandler *req = [payRequsestHandler alloc];
    //初始化支付签名对象
    [req init:APP_ID mch_id:MCH_ID];
    //设置密钥
    [req setKey:PARTNER_ID];
    
    //}}}
    
    //获取到实际调起微信支付的参数后，在app端调起支付
    NSMutableDictionary *dict = [req sendPay:orderId name:orderName price:[NSString stringWithFormat:@"%d", (int)(price*100)]];
    
    if(dict == nil)
    {
        //错误提示
        /*
        NSString *debug = [req getDebugifo];
        [self alert:@"提示信息" msg:debug];
        NSLog(@"%@\n\n",debug);
        */
    }
    else
    {
        /*
        NSLog(@"%@\n\n",[req getDebugifo]);
        
        [self alert:@"确认" msg:@"下单成功，点击OK后调起支付！"];
        */
        NSMutableString *stamp  = [dict objectForKey:@"timestamp"];
        
        //调起微信支付
        PayReq* req             = [[PayReq alloc] init];
        req.openID              = [dict objectForKey:@"appid"];
        req.partnerId           = [dict objectForKey:@"partnerid"];
        req.prepayId            = [dict objectForKey:@"prepayid"];
        req.nonceStr            = [dict objectForKey:@"noncestr"];
        req.timeStamp           = stamp.intValue;
        req.package             = [dict objectForKey:@"package"];
        req.sign                = [dict objectForKey:@"sign"];
        
        [WXApi sendReq:req];
    }
}

#pragma mark - WXApiDelegate
-(void) onReq:(BaseReq*)req
{

}

-(void) onResp:(BaseResp*)resp
{
    if([resp isKindOfClass:[PayResp class]])
    {
        //支付返回结果，实际支付结果需要去微信服务器端查询
        [[NSNotificationCenter defaultCenter] postNotificationName:kWXPayResult object:[NSNumber numberWithInt:resp.errCode]];
        switch (resp.errCode)
        {
            case WXSuccess:
                break;
            default:
                break;
        }
    }
}

@end

int main(int argc, char * argv[])
{
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([QAppDelegate class]));
    }
}