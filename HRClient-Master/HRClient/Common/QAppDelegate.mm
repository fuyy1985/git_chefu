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
    
    [UMSocialData setAppKey:@"5517b26dfd98c56f5300030f"];
    //urlType也需要改，是appid，我写的是appkey
    [UMSocialWechatHandler setWXAppId:@"wx31854588ad20fae4" appSecret:@"cc3b153f8f1b1a03e9bfc0182f2cbf93"
                                  url:@"http://www.umeng.com/social"];
    
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
    return  [UMSocialSnsService handleOpenURL:url];
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

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    return  [UMSocialSnsService handleOpenURL:url];
    if ([url.host isEqualToString:@"safepay"]) {
        
        [[AlipaySDK defaultService] processAuth_V2Result:url
                                         standbyCallback:^(NSDictionary *resultDic) {
                                             NSLog(@"result = %@",resultDic);
                                             NSString *resultStr = resultDic[@"result"];
                                             NSLog(@"result = %@",resultStr);
                                         }];
        
    }
    
    return YES;
}

@end

int main(int argc, char * argv[])
{
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([QAppDelegate class]));
    }
}