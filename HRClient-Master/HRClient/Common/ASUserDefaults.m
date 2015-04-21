//
//  ASUserDefaults.m
//  HRClient
//
//  Created by fyy6682 on 15-3-8.
//  Copyright (c) 2015年 panyj. All rights reserved.
//

#import "ASUserDefaults.h"

@implementation ASUserDefaults

+ (id)objectForKey:(NSString*)akey
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:akey];
}

+ (void)removeObjectForKey:(NSString*)akey
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:akey];
}

+ (void)setObject:(id)anObject forKey:(id)akey
{
    [[NSUserDefaults standardUserDefaults] setObject:anObject forKey:akey];
}

+ (NSString *)stringForKey:(NSString *)akey
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:akey];
}

+ (BOOL)boolForKey:(NSString*)akey defaultValue:(BOOL)defaultValue
{
    NSNumber *num = [[NSUserDefaults standardUserDefaults] objectForKey:akey];
    if (num) {
        return [num boolValue];
    }
    return defaultValue;
}

+ (void)setBool:(BOOL)value forKey:(NSString *)aKey
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:value] forKey:aKey];
}

+ (int)intForKey:(NSString*)akey defaultValue:(int)defaultValue
{
    NSNumber *num = [[NSUserDefaults standardUserDefaults] objectForKey:akey];
    if (num) {
        return [num intValue];
    }
    return defaultValue;
}

+ (void)setInt:(int)value forKey:(NSString *)aKey
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:value] forKey:aKey];
}

+ (BOOL)synchronize
{
    return [[NSUserDefaults standardUserDefaults] synchronize];
}
@end
