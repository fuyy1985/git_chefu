//
//  QRespView.m
//  DSSClient
//
//  Created by panyj on 14-7-3.
//  Copyright (c) 2014年 SDK. All rights reserved.
//

#import "QRespView.h"

@implementation QRespView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_eventBlock) {
        _eventBlock(QRespTouchBegan);
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_eventBlock) {
        _eventBlock(QRespTouchMoved);
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_eventBlock) {
        _eventBlock(QRespTouchEnded);
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_eventBlock) {
        _eventBlock(QRespTouchCancelled);
    }
}

@end
