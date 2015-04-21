//
//  QDefine.h
//  DSSClient
//
//  Created by pany on 14-4-18.
//  Copyright (c) 2014年 SDK. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
    BuyType_directly = 0,
    BuyType_vipCard = 1,
    BuyType_vipCardCharge = 2,
    BuyType_normalCharge = 3,
    BuyType_product = 4,
}BuyType;

#define SCREEN_SIZE_WIDTH     ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_SIZE_HEIGHT    ([[UIScreen mainScreen] bounds].size.height)
#define MAINMENU_SIZE_WIDTH   230.0
#define SYS_STATUSBAR_HEIGHT  20.0
#define VIEW_NAVBAR_HEIGHT    44.0
#define FOURINCHOFFSET        44      //4英寸垂直偏移

#define EXTRA_HEADER_HEIGHT   (VIEW_NAVBAR_HEIGHT + SYS_STATUSBAR_HEIGHT)
#define PAGE_CONTENT_HEIGHT   (SCREEN_SIZE_HEIGHT - EXTRA_HEADER_HEIGHT)

#define TABLE_CELL_HEIGHT     44.0
#define CTRL_INTERVAL         15.0
#define BUTTON_HEIGHT         34.0

#define IOSVERSION            ([[[UIDevice currentDevice] systemVersion] floatValue])
#define IMAGEOF(x)            ([UIImage imageNamed:x])
#define PICTUREHTTP(x)        ([@"http://121.41.116.252/" stringByAppendingString:x])///121.41.116.252/
#define IS4INCHSCREEN         (SCREEN_SIZE_HEIGHT >= 640 ? YES : NO)
#define iPhone5               ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? (CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size)) : NO)

#if !(TARGET_OS_IPHONE)
#define TESTMODE
#endif

#define MAKELONG(h,l)      ((NSUInteger)(((unsigned long)(0xFFFF&h))<<16)|((unsigned long)(0xFFFF&l)))
#define LO_WORD(d)         ((unsigned short)(((unsigned long)d)&0xFFFF))
#define HI_WORD(d)         ((unsigned short) ((((unsigned long)d)>>16)&0xFFFF))
#define RunOnMainThread(code)   {dispatch_async(dispatch_get_main_queue(), ^{code;});}
#define RunInBackground(SEL,PARAMS) \
                                {[self performSelectorInBackground:@selector(SEL) withObject:PARAMS];}
#define RunAsync(code)      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{code;});
#define Sleep(second)       usleep(second*1000*1000);

//#define colors
#define COLOR_SCREEN_NORMAL         [UIColor colorWithRed:181/255.0 green:188/255.0 blue:198/255.0 alpha:1.00f]
#define COLOR_SCREEN_HILIGHT        [UIColor colorWithRed:117/255.0 green:145/255.0 blue:183/255.0 alpha:1.00f]
#define COLOR_SCREEN_BACK           [UIColor colorWithRed:56/255.0 green:56/255.0 blue:56/255.0 alpha:1.00f]
#define COLOR_TOOLBAR_NORMAL        [UIColor colorWithRed:117/255.0 green:126/255.0 blue:142/255.0 alpha:1.00f]
#define COLOR_TOOLBAR_HILIGHT       [UIColor colorWithRed:19/255.0 green:117/255.0 blue:217/255.0 alpha:1.00f]
#define COLOR_TIMESCROOL_BACK       [UIColor colorWithRed:25/255.0 green:33/255.0 blue:42/255.0 alpha:1.00f]
#define COLOR_TIMESCROOL_HILIGHT    [UIColor colorWithRed:38/255.0 green:100/255.0 blue:47/255.0 alpha:1.00f]

#define _T(str)             NSLocalizedString(str,nil)
#define KEYWINDOW           [[UIApplication sharedApplication]keyWindow]
#define PAGEVIEW            [QViewController shareController].view

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]



