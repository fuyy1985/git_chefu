//
//  ASStarRating.m
//  BossAssistant
//
//  Created by zll on 6/3/14.
//  Copyright (c) 2014 Arcsoft. All rights reserved.
//

#import "ASStarRating.h"

@interface ASStarRating ()

@property (nonatomic, strong) UIView *starBackgroundView;
@property (nonatomic, strong) UIView *starForegroundView;

@end

@implementation ASStarRating

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame numberOfStar:5];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
   	if ((self = [super initWithCoder:aDecoder]))
    {
        _numberOfStar = 5;
        self.starBackgroundView = [self buidlStarViewWithImageName:@"icon_star_unselected"];
        self.starForegroundView = [self buidlStarViewWithImageName:@"icon_star_selected"];
        [self addSubview:self.starBackgroundView];
        [self addSubview:self.starForegroundView];
        [self setScore:0];
	}
    
    return self;
}

- (id)initWithFrame:(CGRect)frame numberOfStar:(int)number
{
    self = [super initWithFrame:frame];
    if (self) {
        _enableRate = NO;
        self.userInteractionEnabled = _enableRate;
        
        _numberOfStar = number;
        self.starBackgroundView = [self buidlStarViewWithImageName:@"icon_star_unselected"];
        self.starForegroundView = [self buidlStarViewWithImageName:@"icon_star_selected"];
        [self addSubview:self.starBackgroundView];
        [self addSubview:self.starForegroundView];
        [self setScore:0];
    }
    return self;
}

- (void)setEnableRate:(BOOL)enableRate
{
    _enableRate = enableRate;
    self.userInteractionEnabled = _enableRate;
}

- (void)setScore:(float)score
{
    if (score < 0)
    {
        score = 0;
    }
    else if (score > self.numberOfStar)
    {
        score = self.numberOfStar;
    }
    self.starForegroundView.frame = CGRectMake(0, 0, score * (self.frame.size.width / self.numberOfStar), self.frame.size.height);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    __weak ASStarRating * weekSelf = self;
    
    [UIView transitionWithView:self.starForegroundView
                      duration:0.2
                       options:UIViewAnimationOptionCurveEaseInOut
                    animations:^
     {
         [weekSelf changeStarForegroundViewWithPoint:point];
     }
                    completion:^(BOOL finished)
     {
         
     }];
}

- (UIView *)buidlStarViewWithImageName:(NSString *)imageName
{
    CGRect frame = self.bounds;
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.clipsToBounds = YES;
    for (int i = 0; i < self.numberOfStar; i ++)
    {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
        imageView.frame = CGRectMake(i * frame.size.width / self.numberOfStar, 0, frame.size.width / self.numberOfStar, frame.size.height);
        [view addSubview:imageView];
    }
    return view;
}

- (void)changeStarForegroundViewWithPoint:(CGPoint)point
{
    CGPoint p = point;
    
    if (p.x < 0)
    {
        p.x = 0;
    }
    else if (p.x > self.frame.size.width)
    {
        p.x = self.frame.size.width;
    }
    float per = self.frame.size.width / self.numberOfStar;
    float lastX = self.starForegroundView.frame.size.width;
    double lastCount = ceil(lastX / per);
    double nowCount = ceil(p.x / per);
    if (lastCount == nowCount)
    {
        if ((int)(ceil(lastX / (per / 2.0))) % 2 == 0)
        {
            nowCount -= 0.5;
        }
        else
        {
            nowCount -= 1;
        }
    }
    
    /*
    NSString * str = [NSString stringWithFormat:@"%0.2f",p.x / self.frame.size.width];
    float score = [str floatValue];
    p.x = score * self.frame.size.width;
     */
    self.starForegroundView.frame = CGRectMake(0, 0, nowCount * per, self.frame.size.height);
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(starRatingView: score:)])
    {
        [self.delegate starRatingView:self score:nowCount];
    }
}

@end
