//
//  QNavigationBar.m
//  DSSClient
//
//  Created by panyj on 14-4-8.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QNavigationBar.h"
#import "QDefine.h"

@implementation QNavigationBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = UIColorFromRGB(0xc40000);
    }
    return self;
}

- (CGRect)titleViewFrame
{
    return CGRectMake(60, 7.5, SCREEN_SIZE_WIDTH-120, 29);
}

- (void)resetContent:(NSArray*)items titleView:(UIView*)titleView ofMenu:(BOOL)inMenu
{
    [_titleView removeFromSuperview];  
    
    _titleView = titleView;
    //_titleView.frame = [self titleViewFrame];
    [self addSubview:_titleView];
    
    //left button
    [_leftButton removeFromSuperview];
    _leftButton = nil;
    
    UINavigationItem * navItem = [items lastObject];
    UIBarButtonItem * barItem = navItem.leftBarButtonItem;
    if (barItem)
    {
        _leftButton = (UIButton*)barItem.customView;
        [self addSubview:_leftButton];
    }
    else
    {
        _leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_leftButton addTarget:self action:@selector(onLeftButtonTapInside:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_leftButton];
        
        if (items.count>1)
        {
            [_leftButton setImage:IMAGEOF(@"common_title_back_n.png") forState:UIControlStateNormal];
            [_leftButton setImage:IMAGEOF(@"common_title_back_h.png") forState:UIControlStateHighlighted];
        }
        else
        {
            _leftButton = nil;
        }
    }
  
    _leftButton.frame = CGRectMake(8.0, 0.0, 44, 44);
    
    //rightButton
    [_rightButton removeFromSuperview];
    _rightButton = nil;
    
    barItem = navItem.rightBarButtonItem;
    if (barItem)
    {//重设右侧按钮
        _rightButton = (UIButton*)barItem.customView;
        if (_rightButton == nil)
        {
            _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [_rightButton setTitle:barItem.title forState:UIControlStateNormal];
            [_rightButton setTitle:barItem.title forState:UIControlStateHighlighted];
            [_rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
            [_rightButton addTarget:barItem.target action:barItem.action forControlEvents:UIControlEventTouchUpInside];
        }
        _rightButton.frame = CGRectMake(SCREEN_SIZE_WIDTH-8-44, 0.0, 44, 44);
        [self addSubview:_rightButton];        
    }
    
    [_rightButtons makeObjectsPerformSelector:@selector(removeFromSuperview)];

    NSArray *rightItems = navItem.rightBarButtonItems;
    if (rightItems.count >= 2)
    {
        UIButton *btn_1 = (UIButton*)((UIBarButtonItem*)rightItems[0]).customView;
        UIButton *btn_2 = (UIButton*)((UIBarButtonItem*)rightItems[1]).customView;
        
        btn_1.frame = CGRectMake(SCREEN_SIZE_WIDTH - 8 - 44, 0.0, 44, 44);
        btn_2.frame = CGRectMake(SCREEN_SIZE_WIDTH - 8 - 44*2, 0.0, 44, 44);
        [self addSubview:btn_1];
        [self addSubview:btn_2];
        
        _rightButtons = [NSArray arrayWithObjects:btn_1,btn_2, nil];
    }
}

- (void)onLeftButtonTapInside:(UIButton*)button
{
    if (_delegate)
    {
        [_delegate QNavigationBarLeftButtonTap:self];
    }
}



@end
