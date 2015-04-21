//
//  QTools.h
//  pany
//  公用非业务接口
//  Created by panyj on 14-4-21.
//  Copyright (c) 2013年 pany. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QConfigration.h"

@interface QTools : NSObject
{
}

#define STRNCPY(destion, source, size) { strncpy(destion, source, size-1); destion[size-1] = 0;}

+ (QTools *) sharedQTools;

// util
// 格式如: #RRGGBBAA
+ (UIColor*)colorOfString16:(NSString*)color;

+ (UIColor *) colorWithHexString: (NSString *) stringToConvert;

// 格式如: r,g,b,a 10进制数,a是可选项
+ (UIColor*)colorOfString10:(NSString*)color;

+ (UIColor*)colorWithRGB:(int)r :(int)g :(int)b;

+ (BOOL)illegalCharacterInString:(NSString*)cString;

+ (BOOL)AllNumerics:(NSString*)cString;

+ (NSString*) documentFolder;

+ (NSString*) deleteStrinngNoUseSpace:(NSString*)StrInput;

//创建按钮
+ (UIButton*)createBtnByImage:(NSString*)imageName action:(SEL)sel target:(id)tar;

+ (void)setBtnStyle:(UIButton*)btn
       cornerRadius:(CGFloat)radius
        borderWidth:(CGFloat)width
        bordercolor:(UIColor*)colorValue;


+ (NSDateFormatter*)dateFormatter;
//参数如yyyyMMdd,则只返回当天的起始时间(0点)
+ (NSDate*)dateOfDate:(NSDate*)date fmt:(NSString*)fmtStr;

//当天晚上24点
+ (NSDate*)dateOfDateEnd:(NSDate*)date;

/** 转化为以时钟开始的字符串 */
+ (NSString *)stringBeginWithHourOfTime:(NSTimeInterval)time;

//从通道ID获取设备ID
+ (NSString*)deviceIDOfChannelID:(NSString*)channelID;

/**获取设备剩余空间容量 */
+ (double)freeDiskSpaceInMBytes;

//等待框
+ (void)startWaittingInView:(UIView*)view alert:(NSString *)labelText frame:(CGRect)frame backgroundColor:(UIColor*)color;
+ (void)startWaittingInView:(UIView*)view alert:(NSString *)labelText frame:(CGRect)frame;
+ (void)startWaittingInViewCenter:(UIView*)view alert:(NSString *)labelText frame:(CGRect)frame;
+ (void)startWaittingInView:(UIView*)view alert:(NSString*)labelText;
+ (void)startShortWaittingInView:(UIView*)view;
+ (void)startShortWaittingInViewForStartRunPage:(UIView*)view;
+ (void)endWaittingInView:(UIView*)view;

//宽字节转换成单字节
+ (int)wideBytes:(const wchar_t*)szWideChar toMultiBytes:(char *)szDest length:(int)strLen;

//在程序document文件夹中创建文件夹,并返回文件路径
+ (NSString *)createFolderInDocuments:(NSString *)folderName;

+ (UIImage*)scaleToSize:(UIImage*)img size:(CGSize)size;
+ (UIImage*)createImageWithColor:(UIColor *)color;
+ (UIImage*)getImageFromView:(UIView*)view;

@end
