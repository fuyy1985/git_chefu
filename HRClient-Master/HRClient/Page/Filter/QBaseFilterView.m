//
//  QBaseFilterView.m
//  HRClient
//
//  Created by chenyf on 14/12/28.
//  Copyright (c) 2014年 panyj. All rights reserved.
//  filterView 基类

#import "QBaseFilterView.h"

@interface QBaseFilterView ()
@property (nonatomic) CGRect viewFrame;
@property (nonatomic) CGRect viewHideFrame;
@end

@implementation QBaseFilterView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // backgroundView
        UIView *backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        backgroundView.backgroundColor = [UIColor blackColor];
        backgroundView.alpha = .5;
        [self addSubview:backgroundView];
        
        _viewFrame = frame;
        _viewHideFrame = CGRectMake(frame.origin.x, frame.origin.y, 0, 0);
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(displayGestureForTapRecognizer:)];
//        gesture.delegate = self;
        gesture.cancelsTouchesInView = NO;
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:gesture];
        
        self.frame = _viewHideFrame;
        self.alpha = 0;
        self.hidden = YES;
    }
    return self;
}

- (void)toggleMenu {
    if(self.hidden) {
        [self showMenu];
    } else {
        [self hideMenu];
    }
}

- (void)showMenu
{
    self.hidden = NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.frame = _viewFrame;
        self.alpha = 1;
    }];
    /*
    [UIView animateWithDuration:0.8
                          delay:0.0
         usingSpringWithDamping:1.0
          initialSpringVelocity:4.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.frame = _viewFrame;
                         self.alpha = 1;
                     }
                     completion:^(BOOL finished){
                     }];
    [UIView commitAnimations];
    */
}

- (void)hideMenu
{
/*
    [UIView animateWithDuration:0.3f
                          delay:0.05f
         usingSpringWithDamping:1.0
          initialSpringVelocity:4.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.frame = _viewHideFrame;
                         self.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         self.hidden = YES;
                     }];
    [UIView commitAnimations];
*/
    [UIView animateWithDuration:0.2 animations:^{
        self.frame = _viewHideFrame;
        self.alpha = 0;
        self.hidden = YES;
    }];
}

- (void)displayGestureForTapRecognizer:(UITapGestureRecognizer *)recognizer {
    CGPoint tapLocation = [recognizer locationInView:self];
//    NSLog(@"响应2");
    if (!CGRectContainsPoint(self.menuView.frame, tapLocation) && !self.menuView.hidden) {
        [self hideMenu];
    }
}

@end
