//
//  QRemarkTextView.m
//  HRClient
//
//  Created by ekoo on 14/12/23.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QRemarkTextView.h"

@implementation QRemarkTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:)
                                                     name:UITextViewTextDidChangeNotification
                                                   object:nil];
        
        self.autoresizesSubviews = NO;
        self.placeholder         = @"评价留言";
        self.placeholderColor    = [UIColor lightGrayColor];
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    //内容为空时才绘制placeholder
    if ([self.text isEqualToString:@""]) {
        CGRect placeholderRect;
        placeholderRect.origin.y = 8;
        placeholderRect.size.height = CGRectGetHeight(self.frame)-8;
        if (IOSVERSION >= 7) {
            placeholderRect.origin.x = 5;
            placeholderRect.size.width = CGRectGetWidth(self.frame)-5;
        } else {
            placeholderRect.origin.x = 10;
            placeholderRect.size.width = CGRectGetWidth(self.frame)-10;
        }
        [self.placeholderColor set];
        [self.placeholder drawInRect:placeholderRect
                            withFont:self.font
                       lineBreakMode:NSLineBreakByWordWrapping
                           alignment:NSTextAlignmentLeft];
    }
}

- (void)textChanged:(NSNotification *)not
{
    [self setNeedsDisplay];
}

- (void)setText:(NSString *)text
{
    [super setText:text];
    [self setNeedsDisplay];
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
