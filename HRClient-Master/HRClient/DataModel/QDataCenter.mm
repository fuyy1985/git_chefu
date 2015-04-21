////
//  QDataCenter.m
//  DahuaVision
//  全局数据存取（组织结构管理）
//  Created by nobuts on on 14-4-21.
//  Copyright (c) 2013年 Dahuatech. All rights reserved.
//

#import "QDataCenter.h"
#import "QViewController.h"

static QDataCenter* __shareDataCenter = nil;

@implementation QDataCenter

- (id) init
{
    self = [super init];
    if (self)
    {
    }
    
    return self;
}

+ (QDataCenter *) sharedDataCenter
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __shareDataCenter = [[self alloc] init];
    });   
    return __shareDataCenter;
}

@end
