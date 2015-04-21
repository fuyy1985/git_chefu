//
//  ASStarRating.h
//  BossAssistant
//
//  Created by zll on 6/3/14.
//  Copyright (c) 2014 Arcsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ASStarRating;

@protocol StarRatingViewDelegate <NSObject>

@optional
-(void)starRatingView:(ASStarRating *)view score:(float)score;

@end

@interface ASStarRating : UIView

@property (nonatomic, readonly) int numberOfStar;
@property (nonatomic, weak) id <StarRatingViewDelegate> delegate;
@property (nonatomic, assign) BOOL enableRate;

- (id)initWithFrame:(CGRect)frame numberOfStar:(int)number;
- (void)setScore:(float)score;

@end
