//
//  QZoomScrollView.m
//  DSSClient
//
//  Created by panyj on 14-5-9.
//  Copyright (c) 2014年 SDK. All rights reserved.
//

#import "QZoomScrollView.h"
#import "QViewController.h"

@interface QZoomScrollView ()<UIScrollViewDelegate>
{
    CGFloat  zoomRatio;//原始放大倍数
    BOOL     needLayout;//
}
@property(nonatomic,strong)UIImageView * imageView;
@end

@implementation QZoomScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        needLayout = YES;
        
        self.backgroundColor = [UIColor blackColor];
        
        _imageView = [[UIImageView alloc]init];
        [self addSubview:_imageView];
        
        UITapGestureRecognizer  *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                               action:@selector(handleOneTap:)];
        [_imageView addGestureRecognizer:tap];
        
        _imageView.userInteractionEnabled = YES;
        
        self.maximumZoomScale = 2;
        self.minimumZoomScale = 0.5;
        self.scrollEnabled = YES;
        self.delegate = self;
    }
    return self;
}


- (void)setImage:(UIImage*)image{
    if (image == nil) {
        return;
    }
    _imageView.image = image;    
}

- (void)setFrame:(CGRect)frame
{
    if (CGRectIsEmpty(frame) || _imageView == nil) {
        return;
    }
    [super setFrame:frame];
    
    if(needLayout)
    {
        [self setNeedLayoutImageView];
    }
    else
    {
        [self centerImageView];
    }
}

- (void)setNeedLayoutImageView
{
    CGSize szImage = _imageView.image.size;
    CGSize szFrm   = self.bounds.size;
    
    if (szImage.width == 0 || szFrm.width == 0) {
        return;
    }
    
    //adjust the zoom ratio for origin
    CGFloat f1 = (szFrm.width/szImage.width);
    CGFloat f2 = (szFrm.height/szImage.height);
    
    zoomRatio = MIN(f1, f2);
    
    if (zoomRatio>=1) {
        self.minimumZoomScale = 1;
        self.maximumZoomScale = 3;
    }
    else
    {
        self.minimumZoomScale = zoomRatio;
        self.maximumZoomScale = 2;
    }
    
    CGFloat x = szImage.width*zoomRatio;
    CGFloat y = szImage.height*zoomRatio;
    
    CGFloat left = (szFrm.width-x)/2;
    CGFloat top  = (szFrm.height-y)/2;
    
    [self setZoomScale:zoomRatio animated:NO];
    
    _imageView.frame = CGRectMake(left, top, x,y);
    
    self.contentSize = CGSizeMake(x, y);
    
    needLayout = NO;
}


- (void)centerImageView
{
    CGFloat boundWidth  = self.bounds.size.width;
    CGFloat boundHeight = self.bounds.size.height;
    CGFloat contentWidth  = self.contentSize.width;
    CGFloat contentHeight = self.contentSize.height;
    
    CGFloat offsetX = (boundWidth>contentWidth)?(boundWidth-contentWidth):0.0;
    CGFloat offsetY = (boundHeight>contentHeight)?(boundHeight-contentHeight):0.0;
    
    _imageView.frame = CGRectMake(offsetX*0.5, offsetY*0.5, contentWidth, contentHeight);
}

#pragma mark - Zoom methods

- (void)handleOneTap:(UIGestureRecognizer *)gesture
{
    if ([_tapDelegate respondsToSelector:@selector(dealOneTapEvent)]) {
        [_tapDelegate dealOneTapEvent];
    }
}


#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    [self centerImageView];
}

@end
