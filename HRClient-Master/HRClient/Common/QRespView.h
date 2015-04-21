//
//  QRespView.h
//  DSSClient
//
//  Created by panyj on 14-7-3.
//  Copyright (c) 2014年 SDK. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, QRespTouchEvent) {
    QRespTouchBegan,
    QRespTouchMoved,
    QRespTouchEnded,
    QRespTouchCancelled,
};

@interface QRespView : UIView
@property (nonatomic,strong) void (^eventBlock)(QRespTouchEvent);
@end
