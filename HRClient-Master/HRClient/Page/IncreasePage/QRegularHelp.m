//
//  QRegularHelp.m
//  HRClient
//
//  Created by ekoo on 15/1/9.
//  Copyright (c) 2015年 panyj. All rights reserved.
//

#import "QRegularHelp.h"

@implementation QRegularHelp

//校验用户手机号码
+ (BOOL) validateUserPhone:(NSString *)str
{
    if (!str || [str isEqualToString:@""])
        return NO;
    
    NSRegularExpression *regularexpression = [[NSRegularExpression alloc]
                                              initWithPattern:@"^1[3|4|5|7|8][0-9][0-9]{8}$"
                                              options:NSRegularExpressionCaseInsensitive
                                              error:nil];
    
    NSUInteger numberofMatch = [regularexpression numberOfMatchesInString:str
                                                                  options:NSMatchingReportProgress
                                                                    range:NSMakeRange(0, str.length)];
    
    if(numberofMatch > 0)
    {
        return YES;
    }
    
    return NO;
}

+ (NSString*)blurMobile:(NSString*)str
{
    if ([QRegularHelp validateUserPhone:str]) {
        return [str stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
    }
    return nil;
}

+ (NSString*)distanceToNSString:(NSNumber*)distance
{
    if (!distance || ![distance intValue]) {
        return @"";
    }
    return [[NSString stringWithFormat:@"%.1f", [distance doubleValue]] stringByAppendingString:@"km"];
}

+ (NSAttributedString*)guaranteeStringbyPeriod:(NSInteger)period
{
    NSString *text;
    if (0 == period)
    {
        text = @"";
    }
    else
    {
        NSString *date;
        if (period == -1)
            date = @"终身";
        else if (period < 12)
            date = [NSString stringWithFormat:@"%d个月", period];
        else if (period < 24)
            date = @"1年";
        else if (period < 36)
           date = @"2年";
        else if (period < 60)
            date = @"3年";
        else
            date = @"5年";
        text = [NSString stringWithFormat:@"质保(%@)", date];
    }
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSStrikethroughStyleAttributeName: @(NSUnderlineStyleNone)}];
    [string addAttribute:NSBackgroundColorAttributeName value:ColorTheme range:[text rangeOfString:@"质保"]];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:[text rangeOfString:@"质保"]];
    
    return string;
}

@end
