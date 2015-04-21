//
//  QFootPrintFilterView.m
//  HRClient
//
//  Created by chenyf on 14/12/29.
//  Copyright (c) 2014年 panyj. All rights reserved.
//  第四个下拉选择（洗车） 足迹

#import "QFootPrintFilterView.h"
#import "QViewController.h"
#import "QGroupBuyCell.h"

@interface QFootPrintFilterView ()
@property (nonatomic) UITableView *filterTableView;
//@property (nonatomic) NSArray *filterList;
@end

@implementation QFootPrintFilterView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        CGFloat menuHeight = 86 * 4;
        
        self.menuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, menuHeight)];
        [self addSubview:self.menuView];
        
        _filterTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width , menuHeight) style:UITableViewStylePlain];
        _filterTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _filterTableView.delegate = self;
        _filterTableView.dataSource = self;
        //        _filterTableView.backgroundColor = [QTools colorWithRGB:238 :238 :238];
        [self.menuView addSubview:_filterTableView];
        
    }
    return self;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 86;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell_Identifier_Recomment";
    QGroupBuyCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell) {
        cell = [[QGroupBuyCell alloc] initWithStyle:UITableViewCellStyleDefault
                                    reuseIdentifier:CellIdentifier];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.contentView.backgroundColor = [QTools colorWithRGB:238 :238 :238];
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor whiteColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [QViewController gotoPage:@"QGroupBuyDetailPage" withParam:nil];
}

@end
