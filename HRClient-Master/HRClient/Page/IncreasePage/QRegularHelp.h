//
//  QRegularHelp.h
//  HRClient
//
//  Created by ekoo on 15/1/9.
//  Copyright (c) 2015年 panyj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QRegularHelp : NSObject

+ (BOOL) validateUserPhone:(NSString *)str;
+ (NSString*)blurMobile:(NSString*)str;
+ (NSString*)distanceToNSString:(NSNumber*)distance;
+ (NSAttributedString*)guaranteeStringbyPeriod:(NSInteger)period;

@end
