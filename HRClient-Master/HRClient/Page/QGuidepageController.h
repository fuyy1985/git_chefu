//
//  QGuidepageController.h
//  DSSClient
//
//  Created by panyj on 14-5-26.
//  Copyright (c) 2014年 SDK. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GuideViewDelegate <NSObject>

- (void)closeGuideView;

@end

@interface QGuidepageController : UIViewController<UIScrollViewDelegate>
@property(nonatomic, weak) id<GuideViewDelegate> delegate;

@end


