//
//  QConfigration.h
//  DSSClient
//
//  Created by panyj on 14-9-15.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QDefine.h"


/*最后一次刷新的经纬度*/
#define LocationPoint           @"LocationPoint"
/*首页商品*/
#define  HomeProducts           @"HomeProducts"
/*全部分类*/
#define CategoryService         @"AllCategoryDetail"

@interface QConfigration : NSObject
{
}

@property (nonatomic,assign) BOOL  fileConfigModified;//文件配置是否修改
+ (QConfigration *) sharedInstance;

+ (id)readConfigForKey:(NSString*)key;
+ (id)readConfigForKeyAndRemove:(NSString*)key;
+ (void)writeFileConfig:(id)value forKey:(NSString*)key;
+ (void)writeRuntimeConfig:(id)value forKey:(NSString*)key;

// 配置文件
+ (void)saveFile;
- (void)loadFile;

+ (UIColor*)baseColor;

@end


@interface NSObject (ARCHelp)
- (NSString*)retainLog;
@end