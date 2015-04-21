//
//  QCommentsCell.m
//  HRClient
//
//  Created by fyy6682 on 15-3-9.
//  Copyright (c) 2015年 panyj. All rights reserved.
//

#import "QCommentsCell.h"
#import "QBusinessDetailComment.h"
#import "ASStarRating.h"

#define MaxCommentCount                 (2)
#define DefaultCommentContent           @"这家伙很懒，什么都没留下"

@interface QCommentsCell () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *subTableView;

@end

@implementation QCommentsCell

- (void)awakeFromNib {
    // Initialization code
    _isExpanding = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (UITableView*)subTableView
{
    if (!_subTableView) {
        _subTableView = [[UITableView alloc] initWithFrame:self.bounds];
        _subTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _subTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _subTableView.scrollEnabled = NO;
        _subTableView.delegate = self;
        _subTableView.dataSource = self;
        [self addSubview:_subTableView];
    }
    return _subTableView;
}

+ (CGSize)contentSize:(NSString*)content
{
    if (!content || [content isEqualToString:@""]) {
        content = DefaultCommentContent;
    }
    return [content sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(SCREEN_SIZE_WIDTH - 2*30, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
}

+ (CGFloat)heightofCell:(NSArray*)comments isExpand:(BOOL)isExpand
{
    
    CGFloat height = 0;
    NSInteger count = [comments count];
    if (!isExpand && (count >= MaxCommentCount)) {
        count = MaxCommentCount;
        height += 30;
    }
    else if (count == 0) {
        height += 30;
    }
    for (int i = 0; i < count; i++)
    {
        QDetailComment *comment = comments[i];
        CGSize size = [QCommentsCell contentSize:comment.content];
        height += 35 + size.height + 5;
    }

    return ceilf(height);
}

- (void)setCommentsArr:(NSArray *)commentsArr
{
    if ([self.subTableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [self.subTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    _commentsArr = commentsArr;
    
    [self.subTableView reloadData];
}

#pragma mark - UITableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = [_commentsArr count];
    NSInteger rows = 0;
    if (count == 0) { //暂无评论
        rows = 1;
    }
    else if (count < MaxCommentCount) //评论小于MaxCommentCount条
    {
        rows = count;
    }
    else if (_isExpanding) //评论展开
    {
        rows = count;
    }
    else                //评论不展开,评论数大于2条
    {
        rows = 3;
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifierCell = @"cell";
    static NSString *identifierMoreCell = @"more";
    static NSString *identifierNoneCell = @"None";
    UITableViewCell *cell;
    
    NSInteger count = [_commentsArr count];
    
    if (count >= MaxCommentCount && !_isExpanding && (indexPath.row == MaxCommentCount))
    {
        /* 查看全部评论 */
        cell = [tableView dequeueReusableCellWithIdentifier:identifierMoreCell];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifierMoreCell];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }

        cell.textLabel.text = @"查看全部评论";
        cell.textLabel.font = [UIFont systemFontOfSize:12];
        cell.textLabel.textColor = [QTools colorWithRGB:196 :0 :0];
    }
    else if (1 == [tableView numberOfRowsInSection:0] && (count == 0))
    {
        /* 暂无评论 */
        cell = [tableView dequeueReusableCellWithIdentifier:identifierNoneCell];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifierNoneCell];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        cell.textLabel.text = @"暂无评论";
        cell.textLabel.font = [UIFont systemFontOfSize:12];
        cell.textLabel.textColor = [QTools colorWithRGB:196 :0 :0];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    else
    {
        QDetailComment *comment = _commentsArr[indexPath.row];
        /* 评论详情 */
        cell = [tableView dequeueReusableCellWithIdentifier:identifierCell];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifierCell];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        CGFloat marginLeft = 15;
        CGFloat marginTop = 12;
        
        // 昵称 & 日期
        NSString *strInfo = @"匿名用户";
        if (comment.nick)
        {
            strInfo = comment.nick;
            if (comment.createDate)
            {
                strInfo = [[strInfo stringByAppendingString:@"  "]stringByAppendingString:comment.createDate];
            }
        }
        
        UILabel *nameAndDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(marginLeft, marginTop, 0, 0)];
        nameAndDateLabel.text = strInfo;
        nameAndDateLabel.font = [UIFont systemFontOfSize:13];
        nameAndDateLabel.textColor = [QTools colorWithRGB:155 :155 :155];
        [nameAndDateLabel sizeToFit];
        [cell.contentView addSubview:nameAndDateLabel];
        
        // 星级图标
        marginTop = 10;
        ASStarRating *rateView = [[ASStarRating alloc] initWithFrame:CGRectMake(SCREEN_SIZE_WIDTH - 80 - 15, marginTop, 80, 13)];
        [rateView setScore:[comment.totalPoints doubleValue]];
        [cell.contentView addSubview:rateView];
        
        // 评价内容
        marginTop = 35;
        UILabel *commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(marginLeft, marginTop, tableView.deFrameWidth - 35, 0)];
        commentLabel.text = (!comment.content || [comment.content isEqualToString:@""]) ? @"这家伙很懒，什么都没留下" : comment.content;
        commentLabel.font = [UIFont systemFontOfSize:12];
        commentLabel.textColor = [QTools colorWithRGB:155 :155 :155];
        commentLabel.lineBreakMode = NSLineBreakByWordWrapping;
        commentLabel.numberOfLines = 0;
        [commentLabel sizeToFit];
        [cell.contentView addSubview:commentLabel];
        
        // 分割线
        UIView *separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(0, [self tableView:tableView heightForRowAtIndexPath:indexPath] - 0.5, cell.deFrameWidth, 0.5)];
        separatorLineView.backgroundColor = [QTools colorWithRGB:236 :236 :236];
        [cell.contentView addSubview:separatorLineView];
    }
    
    return cell;
}

#pragma mark- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger count = [_commentsArr count];
    if (count == 0)
    {
        return 30;
    }
    if (count >= MaxCommentCount && !_isExpanding && (indexPath.row == MaxCommentCount))
    {
        return 30;
    }
    else
    {
        CGFloat height = 0;
        if ([_commentsArr count] <= indexPath.row) {
            height = 0;
        }
        else {
            QDetailComment *comment = _commentsArr[indexPath.row];
            height = 35 + [QCommentsCell contentSize:comment.content].height + 5;
        }
        return height;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor whiteColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger count = [_commentsArr count];
    if (count >= MaxCommentCount && !_isExpanding && (indexPath.row == MaxCommentCount))
    {
        //更多评论
        if (self.delegate &&[self.delegate respondsToSelector:@selector(onMoreComment)]) {
            [self.delegate onMoreComment];
        }
    }
}

@end
