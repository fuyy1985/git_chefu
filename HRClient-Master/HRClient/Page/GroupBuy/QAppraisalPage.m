//
//  QAppraisalPage.m
//  HRClient
//
//  Created by chenyf on 14/12/28.
//  Copyright (c) 2014年 panyj. All rights reserved.
//  评价

#import "QAppraisalPage.h"
#import "QHttpMessageManager.h"
#import "QCommentsCell.h"

@interface QAppraisalPage ()<UITableViewDelegate, UITableViewDataSource, QCommentsCellDelegate>

@property(nonatomic, assign)QCommentType commentType;
@property(nonatomic, assign)NSString *companyId;
@property(nonatomic, assign)NSString *productId;
@property(nonatomic, strong)NSMutableArray *commentsList;

@property(nonatomic, strong)UITableView *tableView;

@end

@implementation QAppraisalPage

- (NSString *)title
{
    return @"评价";
}

- (void)setActiveWithParams:(NSDictionary *)params
{
    _commentType = [[params objectForKey:@"commentType"] intValue];
    _companyId = NSString_No_Nil([params objectForKey:@"companyId"]);
    _productId = NSString_No_Nil([params objectForKey:@"productId"]);
}


- (UIView *)viewWithFrame:(CGRect)frame
{
    if ([super viewWithFrame:frame]) {
        
        // 商家详情
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [QTools colorWithRGB:240 :239 :237];
        [_view addSubview:_tableView];
    }
    
    return _view;
}

- (void)pageEvent:(QPageEventType)eventType
{
    if (eventType == kPageEventWillShow)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getCommentSuccess:) name:kBusinessComment object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getCommentSuccess:) name:kProductComment object:nil];
        
        if (kBusinessCommentType == _commentType) {
            [[QHttpMessageManager sharedHttpMessageManager] accessBusinessComment:_companyId andPage:12 andIndex:1];
        }
        else if (kProductCommentType == _commentType) {
            [[QHttpMessageManager sharedHttpMessageManager] accessProductComment:_companyId andProductID:_productId andPage:12 andIndex:1];
        }
        [ASRequestHUD show];
    }
    else if (eventType == kPageEventWillHide)
    {
        [ASRequestHUD dismiss];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kBusinessComment object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kProductComment object:nil];
    }
    else if (eventType == kPageEventViewCreate)
    {
        _commentsList = [[NSMutableArray alloc] initWithCapacity:0];
    }
}

- (void)getCommentSuccess:(NSNotification*)noti
{
    [ASRequestHUD dismiss];
    [_commentsList addObjectsFromArray:noti.object];
    [_tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [QCommentsCell heightofCell:_commentsList isExpand:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifierPhone = @"AllComment";
    QCommentsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierPhone];
    if (nil == cell)
    {
        cell = [[QCommentsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierPhone];
        cell.delegate = self;
        cell.isExpanding = YES;
    }
    
    cell.commentsArr = _commentsList;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

@end
