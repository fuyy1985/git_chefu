//
//  CustomWindow.m
//  
//
//  Created by fyy6682 on 14-6-30.
//  Copyright (c) 2014年 szcai. All rights reserved.
//

#import "CustomWindow.h"

@interface CustomWindow ()

@property (nonatomic,retain) UIWindow* parentWindow;
@end

@implementation  CustomWindow
@synthesize parentWindow;

- (void)makeKeyAndVisible
{
	self.parentWindow = [[UIApplication sharedApplication] keyWindow];
	self.windowLevel = UIWindowLevelAlert;
	[super makeKeyAndVisible];
}

- (void)resignKeyWindow
{
	[super resignKeyWindow];
	[self.parentWindow makeKeyWindow];
}

- (void)dealloc
{
	self.parentWindow = nil;
}
@end
