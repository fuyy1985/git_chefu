//
//  QGuidepageController.m
//  DSSClient
//
//  Created by panyj on 14-5-26.
//  Copyright (c) 2014年 SDK. All rights reserved.
//

#import "QGuidepageController.h"
#import "UIDevice+Resolutions.h"
#import "QViewController.h"

@interface QGuidepageController ()
@property (nonatomic, strong) UIScrollView      *scrollView;
@property (nonatomic, strong) UIPageControl     *pageControl;
@property (nonatomic, assign) NSInteger         nCurrentPage;
@end

@implementation QGuidepageController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _nCurrentPage = 0;
    NSUInteger numberofPages = 3;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        height -= 20;
    }
    //big scrollView
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, width, height)];
    _scrollView.pagingEnabled = YES;
    _scrollView.contentSize = CGSizeMake(width * (numberofPages+1), height);
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.scrollsToTop = NO;
    _scrollView.delegate = self;
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    for (int i = 0; i < 3; i++)
    {
        CGRect rect = CGRectMake(width * i,0,width,height);
        UIView *bgView = [[UIView alloc] initWithFrame:rect];
        UIImageView *imageView ;
        switch (i) {
            case 0:
                bgView.backgroundColor = [QTools colorWithRGB:145 :111 :171];
                imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pic_yindao1"]];
                break;
                
            case 1:
                bgView.backgroundColor = [QTools colorWithRGB:255 :116 :55];
                imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pic_yindao2"]];
                break;
                
            case 2:
                bgView.backgroundColor = [QTools colorWithRGB:248 :89 :89];
                imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pic_yindao3"]];
                break;
                
            default:
                break;
        }
        
        [_scrollView addSubview:bgView];
        CGFloat rate = width/320;
        imageView.frame = CGRectMake(0, (height - CGRectGetHeight(imageView.frame)*rate - 57)/2, width, CGRectGetHeight(imageView.frame)*rate);
        [bgView addSubview:imageView];

        if (numberofPages == (i+1))
        {
            
            CGFloat marginY = 0;
            if (([UIDevice currentScreenSize] == UIDevice_3_5_Inch)) {
                if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
                    marginY = 10;
                }
            }
            else {
                marginY = 30;
            }

            UIButton *btnStart = [UIButton buttonWithType:UIButtonTypeCustom];
            btnStart.frame = CGRectMake((width -140)/2, CGRectGetMaxY(imageView.frame)+marginY, 140, 40);
            [btnStart setImage:IMAGEOF(@"btn_start") forState:UIControlStateNormal];
            [btnStart addTarget:self action:@selector(enter) forControlEvents:UIControlEventTouchUpInside];
            [bgView addSubview:btnStart];
            
            bgView.userInteractionEnabled = YES;
        }
    }
    
    [self.view addSubview:_scrollView];
    
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, height - 37 - 5, width, 37)];
    _pageControl.numberOfPages = numberofPages;
    _pageControl.currentPage = _nCurrentPage;
    _pageControl.backgroundColor = [UIColor clearColor];
    _pageControl.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_pageControl];
}

- (void)enter
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(closeGuideView)]) {
        [self.delegate closeGuideView];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    if (offset.x > SCREEN_SIZE_WIDTH*2) {
        //close GuideView
        if (self.delegate && [self.delegate respondsToSelector:@selector(closeGuideView)]) {
            [self.delegate closeGuideView];
        }
    }
    else {
        _pageControl.currentPage = round(offset.x/scrollView.bounds.size.width);
    }
}

#pragma mark StatusBar

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark -
#pragma mark rotate

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait|UIDeviceOrientationPortraitUpsideDown;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait|UIInterfaceOrientationMaskPortraitUpsideDown;
}

@end
