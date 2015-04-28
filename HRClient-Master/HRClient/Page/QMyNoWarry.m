//
//  QMyNoWarry.m
//  HRClient
//
//  Created by ekoo on 14/12/10.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QMyNoWarry.h"
#import "QViewController.h"
#import "QHttpMessageManager.h"
#import "QMyCoupon.h"

@interface QMyNoWarry ()
{
    BOOL _needRefreshList;
    UISegmentedControl *_ctrl;
}

@property (nonatomic,strong)UITableView *myNoWarryTableView;
@property (nonatomic,strong)NSArray *dataArr;

@end

@implementation QMyNoWarry

- (NSString *)title{
    return @"我的车夫券";
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kMyCoupon object:nil];
}

- (void)setActiveWithParams:(NSDictionary *)params
{
    if (params)
    {
        _needRefreshList = [[params objectForKey:@"isNeedRefresh"] boolValue];
    }
}

- (void)pageEvent:(QPageEventType)eventType
{
    if (eventType == kPageEventViewCreate)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acquireMyCoupon:) name:kMyCoupon object:nil];
        
        _needRefreshList = YES;
    }
    else if (eventType == kPageEventWillShow)
    {
        if (_needRefreshList)
        {
            [self gotoSelectIndex:_ctrl];
            
            _needRefreshList = NO;
        }
    }
    else if (eventType == kPageEventWillHide)
    {
        [ASRequestHUD dismiss];
    }
}

- (UIView *)viewWithFrame:(CGRect)frame
{
    if ([super viewWithFrame:frame]) {
        
        _view.backgroundColor = [QTools colorWithRGB:240 :239 :237];
        CGFloat viewBeforeW = 10;
        CGFloat viewTopH = 8;
        CGFloat viewW = frame.size.width - 2 * viewBeforeW;
        CGFloat viewH = 35;
        UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(viewBeforeW, viewTopH, viewW, viewH)];
        topView.backgroundColor = [QTools colorWithRGB:255 :255 :255];
        [_view addSubview:topView];
        
        NSArray *arr = [NSArray arrayWithObjects:@"全部",@"消费券",@"会员洗车券", nil];
        UISegmentedControl *segmentControl = [[UISegmentedControl alloc] initWithItems:arr];
        segmentControl.frame = topView.bounds;
        segmentControl.layer.borderWidth = 0;
        segmentControl.tintColor = ColorTheme;
        segmentControl.selectedSegmentIndex = 0;
        [segmentControl addTarget:self action:@selector(gotoSelectIndex:) forControlEvents:UIControlEventValueChanged];
        [topView addSubview:segmentControl];
        _ctrl = segmentControl;
        
        _myNoWarryTableView = [[UITableView alloc] initWithFrame:CGRectMake(viewBeforeW, topView.deFrameBottom + 10, viewW, frame.size.height - topView.deFrameBottom - 10) style:UITableViewStyleGrouped];
        _myNoWarryTableView.delegate = self;
        _myNoWarryTableView.dataSource = self;
        _myNoWarryTableView.backgroundColor = [UIColor clearColor];
        [_view addSubview:_myNoWarryTableView];
    }
    return _view;
}

#pragma mark - Private
- (void)tryGetWarryList
{
    [[QHttpMessageManager sharedHttpMessageManager] accessMyCoupon:@"0"];
    [ASRequestHUD show];
}

#pragma mark - Notification
- (void)acquireMyCoupon:(NSNotification *)noti{
    
    [ASRequestHUD dismiss];
    
    _dataArr = noti.object;
    [_myNoWarryTableView reloadData];
    
    [ASUserDefaults setObject:[NSNumber numberWithInt:_dataArr.count] forKey:AccountTicket];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _dataArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 5;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_SIZE_WIDTH - 20, 1)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_SIZE_WIDTH - 20, 1)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *myNoWarry = @"myNpoWarry";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myNoWarry];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:myNoWarry];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
        cell.textLabel.textColor = [QTools colorWithRGB:51 :51 :51];
        
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
        cell.detailTextLabel.textColor = [UIColor grayColor];
    }
    
    if (_dataArr.count > indexPath.section) {
        QMyCoupon *coupon = _dataArr[indexPath.section];
        
        cell.imageView.image = [UIImage imageNamed:@"icon_quan"];
        cell.textLabel.text = coupon.subject;
        cell.detailTextLabel.text =[NSString stringWithFormat:@"有效期至：%@",coupon.expireDate];
    }
    else {
        cell.imageView.image = nil;
        cell.textLabel.text = @"";
        cell.detailTextLabel.text = @"";
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
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
    if (_dataArr.count > indexPath.section)
    {
        QMyCoupon *coupon = _dataArr[indexPath.section];
        [QViewController gotoPage:@"QMyCounponPage" withParam:[[NSDictionary alloc] initWithObjectsAndKeys:coupon.orderListId, @"orderListId",nil]];
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UISegmentedControl
- (void)gotoSelectIndex:(UISegmentedControl*)segmentedControl{
    switch (segmentedControl.selectedSegmentIndex) {
        case 0:
        {
            [[QHttpMessageManager sharedHttpMessageManager] accessMyCoupon:@"0"];
            [ASRequestHUD show];
        }
            break;
        case 1:
        {
            [[QHttpMessageManager sharedHttpMessageManager] accessMyCoupon:@"1"];
            [ASRequestHUD show];
        }
            break;
        case 2:
        {
            [[QHttpMessageManager sharedHttpMessageManager] accessMyCoupon:@"2"];
            [ASRequestHUD show];
        }
            break;
        default:
            break;
    }
}

@end
