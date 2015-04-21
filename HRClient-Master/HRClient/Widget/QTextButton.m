//
//  QTextButton.m
//  DSSClient
//
//  Created by panyj on 14-6-9.
//  Copyright (c) 2014年 SDK. All rights reserved.
//

#import "QTextButton.h"

@interface QTextButton()
@property (nonatomic,assign)BOOL touchDown;
@end

@implementation QTextButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _textColor = [UIColor blackColor];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{  
    UIColor * drawColor = _textColor;
    if (self.highlighted) {
        if (_hilightColor) {
            drawColor = _hilightColor;
        }
        else
        {
            drawColor = [_textColor colorWithAlphaComponent:0.5];
        }
    }  
    
    [drawColor setFill];
    
    UIFont * font = [UIFont systemFontOfSize:14];
    
    CGSize   szText = [_text sizeWithFont:font];
    [_text drawAtPoint:CGPointMake((rect.size.width-szText.width)/2, (rect.size.height-szText.height)/2) withFont:font];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self setNeedsDisplay];
    self.highlighted = YES;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [self setNeedsDisplay];
    
    [self sendActionsForControlEvents:UIControlEventTouchUpInside];
    self.highlighted = NO;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    [self setNeedsDisplay];
    self.highlighted = NO;
    
}

@end
