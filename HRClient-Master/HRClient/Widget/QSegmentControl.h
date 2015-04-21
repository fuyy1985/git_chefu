//
//  QSegmentControl.h
//  Z35465
//
//  Created by panyj on 14-5-17.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QSegmentControl : UIControl
{
    NSInteger       _selectedSegment;
    NSInteger       _highlightedSegment;
}

@property(nonatomic) NSInteger selectedSegmentIndex;

- (id)initWithItems:(NSArray *)items;
@property(nonatomic,readonly) NSUInteger numberOfSegments;
@property(nonatomic,strong)   NSArray   * items;
- (void)setTitle:(NSString *)title forSegmentAtIndex:(NSUInteger)segment;
- (void)setImage:(UIImage *)image forSegmentAtIndex:(NSUInteger)segment;
@end
