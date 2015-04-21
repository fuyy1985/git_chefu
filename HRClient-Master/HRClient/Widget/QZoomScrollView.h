//
//  QZoomScrollView.h
//  DSSClient
//
//  Created by panyj on 14-5-9.
//  Copyright (c) 2014年 SDK. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QZoomScrollViewDelegate <NSObject>
- (void)dealOneTapEvent;
@end

@interface QZoomScrollView : UIScrollView
@property (nonatomic, assign) id<QZoomScrollViewDelegate> tapDelegate;

- (void)setImage:(UIImage*)image;
- (void)setNeedLayoutImageView;
@end
