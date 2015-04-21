//
//  QCommentsCell.h
//  HRClient
//
//  Created by fyy6682 on 15-3-9.
//  Copyright (c) 2015年 panyj. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol QCommentsCellDelegate <NSObject>
@optional
/* 点击更多评论 */
- (void)onMoreComment;

@end

@interface QCommentsCell : UITableViewCell
@property (nonatomic, weak) id<QCommentsCellDelegate> delegate;
@property (nonatomic, assign) BOOL isExpanding;
@property (nonatomic, strong) NSArray *commentsArr;

+ (CGFloat)heightofCell:(NSArray*)comments isExpand:(BOOL)isExpand;

@end
