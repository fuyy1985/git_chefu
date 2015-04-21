//
//  ASUserDefaults.h
//  HRClient
//
//  Created by fyy6682 on 15-3-8.
//  Copyright (c) 2015年 panyj. All rights reserved.
//

#import <Foundation/Foundation.h>

#define GuideViewVersion            @"GuideViewVersion"

//login
#define LoginIsAutoLogin            @"AutoIsLogin"
#define LoginUserPhone              @"UserPhone"
#define LoginUserPassCode           @"UserPassCode"

//account
#define AccountUserID               @"AccountUserID"
#define AccountNick                 @"AccountNick"
#define AccountTicket               @"AccountTicket"
#define AccountPayPasswd            @"AccountPayPasswd"
#define AccountBalance              @"AccountBalance"
#define AccountIsMember             @"AccountIsMember"

//最近访问城市
#define CityRecentVisit             @"CityRecentVisit"

//区域ID
#define CurrentRegionID             @"CurrentReginID"
#define CurrentRegionName           @"CurrentRegionName"

@interface ASUserDefaults : NSObject
+ (id)objectForKey:(NSString*)akey;
+ (NSString *)stringForKey:(NSString*)akey;
+ (BOOL)boolForKey:(NSString*)akey defaultValue:(BOOL)defaultValue;
+ (int)intForKey:(NSString*)akey defaultValue:(int)defaultValue;
+ (BOOL)synchronize;
+ (void)setObject:(id)anObject forKey:(id)akey;
+ (void)setBool:(BOOL)value forKey:(NSString *)aKey;
+ (void)setInt:(int)value forKey:(NSString *)aKey;
@end
