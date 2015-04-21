//
//  DHTwoTabControl.m
//  iDSSClient
//
//  Created by panyj on 14-9-15.
//  Copyright (c) 2014年 mobile. All rights reserved.
//

#import "DHTwoTabControl.h"

@interface DHTwoTabControl ()

- (void)btnClinkeLeft;
- (void)btnClinkeRight;

@end

@implementation DHTwoTabControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        btnLeft_ = [UIButton buttonWithType:UIButtonTypeCustom];
        btnright_ = [UIButton buttonWithType:UIButtonTypeCustom];
        btnLeft_.adjustsImageWhenHighlighted  = NO;
        btnright_.adjustsImageWhenHighlighted = NO;
        
        btnLeft_.frame = CGRectMake(0, 0, frame.size.width/2, frame.size.height);
        btnright_.frame = CGRectMake(frame.size.width/2, 0,
                                    frame.size.width/2, frame.size.height);
        
        btnLeft_.titleLabel.font = [UIFont systemFontOfSize:15];
        btnright_.titleLabel.font = [UIFont systemFontOfSize:15];
        
        [self addSubview:btnLeft_];
        [self addSubview:btnright_];
        
        self.strLeftImage_n = @"common_title_lefttab_n.png";
        self.strLeftImage_h = @"common_title_lefttab_h.png";
        self.strRightImage_n = @"common_title_righttab_n.png";
        self.strRightImage_h = @"common_title_righttab_h.png";
        
        [btnLeft_ setBackgroundImage:[UIImage imageNamed:self.strLeftImage_h] forState:UIControlStateNormal];
        [btnright_ setBackgroundImage:[UIImage imageNamed:self.strRightImage_n] forState:UIControlStateNormal];
        [btnLeft_ setTitleColor:_hColor forState:UIControlStateNormal];
        [btnright_ setTitleColor:_nColor forState:UIControlStateNormal];
        
        self.hColor = [QTools colorWithRGB:29 :117 :217];
        self.nColor = [UIColor whiteColor];
        
        [btnLeft_ addTarget:self action:@selector(btnClinkeLeft) forControlEvents:UIControlEventTouchDown];
        [btnright_ addTarget:self action:@selector(btnClinkeRight) forControlEvents:UIControlEventTouchDown];
    }
    
    return self;
}

- (void)SetLeftTitle:(NSString*)_lTitle andRightTitle:(NSString*)_rTitle
{
    [btnLeft_ setTitle:_lTitle forState:UIControlStateNormal];
    [btnLeft_ setTitleColor:_hColor forState:UIControlStateNormal];
    [btnright_ setTitle:_rTitle forState:UIControlStateNormal];
    [btnright_ setTitleColor:_nColor forState:UIControlStateNormal];
}

- (void)btnClinkeLeft
{
    [btnLeft_ setBackgroundImage:[UIImage imageNamed:self.strLeftImage_h]
                       forState:UIControlStateNormal];
    [btnright_ setBackgroundImage:[UIImage imageNamed:self.strRightImage_n]
                        forState:UIControlStateNormal];
    [btnLeft_ setTitleColor:_hColor forState:UIControlStateNormal];
    [btnright_ setTitleColor:_nColor forState:UIControlStateNormal];
    
    if (_delegate && [_delegate respondsToSelector:@selector(onClinkAtTabIndex:)])
    {
        [_delegate onClinkAtTabIndex:0];
    }
}

- (void)btnClinkeRight
{
    [btnLeft_ setBackgroundImage:[UIImage imageNamed:self.strLeftImage_n]
                        forState:UIControlStateNormal];
    [btnright_ setBackgroundImage:[UIImage imageNamed:self.strRightImage_h]
                         forState:UIControlStateNormal];
    [btnLeft_ setTitleColor:_nColor forState:UIControlStateNormal];
    [btnright_ setTitleColor:_hColor forState:UIControlStateNormal];
    
    if (_delegate && [_delegate respondsToSelector:@selector(onClinkAtTabIndex:)])
    {
        [_delegate onClinkAtTabIndex:1];
    }
}

- (void)setStrBackImage:(NSString *)strBackImage
{
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:self.bounds];
    imageView.image = [UIImage imageNamed:strBackImage];
    [self addSubview:imageView];
}

//set index
- (void)setNCurIndex:(int)nCurIndex
{
    _nCurIndex = nCurIndex;
    if (_nCurIndex == 0)
    {
        [btnLeft_ setBackgroundImage:[UIImage imageNamed:self.strLeftImage_h]
                            forState:UIControlStateNormal];
        [btnright_ setBackgroundImage:[UIImage imageNamed:self.strRightImage_n]
                             forState:UIControlStateNormal];
        [btnLeft_ setTitleColor:_hColor forState:UIControlStateNormal];
        [btnright_ setTitleColor:_nColor forState:UIControlStateNormal];
    }
    else
    {
        [btnLeft_ setBackgroundImage:[UIImage imageNamed:self.strLeftImage_n]
                            forState:UIControlStateNormal];
        [btnright_ setBackgroundImage:[UIImage imageNamed:self.strRightImage_h]
                             forState:UIControlStateNormal];
        [btnLeft_ setTitleColor:_nColor forState:UIControlStateNormal];
        [btnright_ setTitleColor:_hColor forState:UIControlStateNormal];
    }
}

@end
