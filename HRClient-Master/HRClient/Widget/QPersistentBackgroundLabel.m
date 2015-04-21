//
//  QPersistentBackgroundLabel.m
//  HRClient
//
//  Created by chenyf on 14/12/27.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QPersistentBackgroundLabel.h"

@implementation QPersistentBackgroundLabel

- (void)setPersistentBackgroundColor:(UIColor*)color {
    super.backgroundColor = color;
}

- (void)setBackgroundColor:(UIColor *)color {
    // do nothing - background color never changes
}

@end
