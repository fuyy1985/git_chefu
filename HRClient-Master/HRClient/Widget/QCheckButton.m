//
//  QCheckButton.m
//  DSSClient
//
//  Created by pany on 14-4-21.
//  Copyright (c) 2014年 SDK. All rights reserved.
//

#import "QCheckButton.h"
#import "QDefine.h"

@implementation QCheckButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}



// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [[UIColor clearColor] setFill];
    
    CGContextFillRect(context, rect);
    
    UIImage * checkImage = IMAGEOF(_checked?@"login_body_check_h.png":@"login_body_check_n.png");
    [checkImage drawAtPoint:CGPointMake(0, 2)];
    
    [[UIColor blackColor] setFill];
    [_text drawAtPoint:CGPointMake(28, 5) withFont:[UIFont systemFontOfSize:14]];
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    _checked = !_checked;
    [self setNeedsDisplay];
    
    [self sendActionsForControlEvents:UIControlEventTouchUpInside|UIControlEventValueChanged];
}

@end
