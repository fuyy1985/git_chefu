//
//  QApplicationDrawback.m
//  HRClient
//
//  Created by ekoo on 14/12/9.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QApplicationDrawback.h"
#import "QOrderKeyCell.h"
#import "QCarryImageCell.h"
#import "QMyListDetailModel.h"
#import "QHttpMessageManager.h"
#import "QHttpManager.h"
#import "QViewController.h"

@interface QApplicationDrawback ()
{
    CGFloat cellH;
    NSMutableArray *contacts;
    NSMutableArray *backs;
    NSMutableArray *array1;
    NSArray *arr;
    NSArray *arrBack;
    UIImageView *temImageView;
    
    QMyListDetailModel *orderDetail;
    NSInteger curIndex;
    
    UIButton *_drawbackBtn;
}

@property (nonatomic,strong)UITableView *applicationDrawbackTableView;

@end

@implementation QApplicationDrawback

- (QCacheType)pageCacheType
{
    return kCacheTypeNone;
}

- (void)setActiveWithParams:(NSDictionary*)params
{
    orderDetail = [params objectForKey:@"QMyListDetailModel"];
}

- (NSString *)title
{
    return @"申请退款";
}

- (void)pageEvent:(QPageEventType)eventType
{
    if (eventType == kPageEventWillShow)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(retDrawback:) name:kDrawback object:nil];
    }
    else if (eventType == kPageEventWillHide)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kDrawback object:nil];
    }
}

- (void)drawBackOrder:(id)sender
{
    //退款操作
    [[QHttpMessageManager sharedHttpMessageManager] drawBack:orderDetail.payId.stringValue andReson:arr[curIndex]];
    [ASRequestHUD showWithMaskType:ASRequestHUDMaskTypeClear];
}


#pragma mark - Notification

- (void)retDrawback:(NSNotification*)notify
{
    NSNumber *num = notify.object;
    
    UIAlertView *alertView = nil;
    
    if ([num integerValue])
    {
        alertView = [[UIAlertView alloc] initWithTitle:nil
                                               message:@"您的退款申请已成功提交，车夫网将在3-10个工作日内将退款原路退至您的支付账户！"
                                              delegate:self
                                     cancelButtonTitle:@"返回商品详情"
                                     otherButtonTitles:@"查看我的退款详情",nil];
        alertView.tag = 10000;
    }
    else
    {
        alertView = [[UIAlertView alloc] initWithTitle:nil
                                               message:@"您的退款申请提交失败，请稍后再试！"
                                              delegate:self
                                     cancelButtonTitle:@"确定"
                                     otherButtonTitles:nil];
         alertView.tag = 10001;
    }
    [alertView show];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 10000)
    {
        //作用在于，跳过车夫券详情页面
        [QViewController gotoPage:@"QMyNoWarry" withParam:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], @"isNeedRefresh", nil]];
        
        if (buttonIndex == 0)
        {
        [QViewController gotoPage:@"QGroupBuyDetailPage" withParam:
                    [NSDictionary dictionaryWithObjectsAndKeys:orderDetail.productId, @"ProductID", nil]];

        }
        else
        {
            [QViewController gotoPage:@"QListDetail" withParam:[[NSDictionary alloc] initWithObjectsAndKeys:orderDetail.orderListId, @"orderListId", /*orderDetail.status*/[NSNumber numberWithInt:4], @"status", nil]];
        }
    }
}


- (UIView *)viewWithFrame:(CGRect)frame
{
    if ([super viewWithFrame:frame]) {
        _view.backgroundColor = [QTools colorWithRGB:238 :238 :238];
        array1=[[NSMutableArray alloc]initWithCapacity:0];
        curIndex = -1;
        
        arr = @[@"预约不上",@"去过了，不太满意",@"朋友/网上评价不好",@"买多了/买错了",@"计划有变，没有时间消费",@"后悔了，不想要了",@"商家说可以直接以团购价到店消费",@"其他"];

        contacts = [NSMutableArray array];
        for (int i = 0; i <8; i++) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            if (i == 0) {
                [dic setValue:@"YES" forKey:@"checked"];
            }else{
                [dic setValue:@"NO" forKey:@"checked"];
            }
            [contacts addObject:dic];
        }
        
        backs = [NSMutableArray array];
        for (int i = 0; i <3; i++) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            if (i == 0) {
                [dic setValue:@"icon_yellow_check" forKey:@"checked"];
            }else{
                [dic setValue:@"icon_yellow_uncheck" forKey:@"checked"];
            }
            [backs addObject:dic];
        }
        
        cellH = 35;
        
        _applicationDrawbackTableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 0, frame.size.width-20, frame.size.height - 80) style:UITableViewStylePlain];
        _applicationDrawbackTableView.dataSource = self;
        _applicationDrawbackTableView.delegate = self;
        _applicationDrawbackTableView.backgroundColor = [UIColor clearColor];
        _applicationDrawbackTableView.tableFooterView = [UIView new];
        [_view addSubview:_applicationDrawbackTableView];
        
        UIButton *drawbackBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, _view.frame.size.height - 80, _view.frame.size.width - 40, 35)];
        [drawbackBtn setTitle:@"申请退款" forState:UIControlStateNormal];
        [drawbackBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        drawbackBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [drawbackBtn setBackgroundImage:[QTools createImageWithColor:ColorTheme] forState:UIControlStateNormal];
        [drawbackBtn addTarget:self action:@selector(drawBackOrder:) forControlEvents:UIControlEventTouchUpInside];
        [_view addSubview:drawbackBtn];
        _drawbackBtn = drawbackBtn;
        
        _drawbackBtn.enabled = NO;
    }
    return _view;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger nCount = 0;
    switch (section)
    {
        case 0://订单密码
            nCount = 1;
            break;
        case 1://退还内容
            nCount = 1;
            break;
        case 2://退还原因
            nCount = arr.count + 1;
            break;
        default:
            nCount = 0;
            break;
    }
    
    return nCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        static NSString *applicationDrawback_one = @"applicationDrawback_one";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:applicationDrawback_one];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:applicationDrawback_one];
        }
        
        [cell.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        UILabel *listLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 90, cellH)];
        listLabel.backgroundColor = [UIColor clearColor];
        listLabel.font = [UIFont systemFontOfSize:14];
        listLabel.textColor = ColorDarkGray;
        listLabel.text = @"退款商品：";
        [cell addSubview:listLabel];
        
        [listLabel sizeToFit];
        listLabel.deFrameHeight = cellH;
        
        UILabel *keyLabel = [[UILabel alloc] initWithFrame:CGRectMake(listLabel.deFrameRight , 0, cell.frame.size.width - listLabel.deFrameRight , cellH)];
        keyLabel.backgroundColor = [UIColor clearColor];
        keyLabel.font = [UIFont systemFontOfSize:13];
        keyLabel.textColor = [UIColor grayColor];
        keyLabel.text = orderDetail.subject;
        CGSize size = [orderDetail.subject sizeWithFont:[UIFont systemFontOfSize:15.f]
                                       constrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
        if (size.width > 260)
        {
            keyLabel.text = [[orderDetail.subject substringToIndex:14] stringByAppendingString:@"..."];
        }
        else
        {
            keyLabel.text = orderDetail.subject;
        }
        [cell addSubview:keyLabel];
        
        return cell;
    }
    else if(indexPath.section == 1)
    {
        //退还内容
        static NSString *applicationDrawback_two = @"applicationDrawback_two";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:applicationDrawback_two];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:applicationDrawback_two];
        }
        [cell.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        UILabel *listLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 90, cellH)];
        listLabel.backgroundColor =[UIColor clearColor];
        listLabel.font = [UIFont systemFontOfSize:14];
        listLabel.textColor = ColorDarkGray;
        listLabel.text = @"退款金融：";
        [cell addSubview:listLabel];
        
        [listLabel sizeToFit];
        listLabel.deFrameHeight = cellH;
        
        UILabel *keyLabel = [[UILabel alloc] initWithFrame:CGRectMake(listLabel.deFrameRight , 0, cell.frame.size.width - listLabel.deFrameRight , cellH)];
        keyLabel.backgroundColor = [UIColor clearColor];
        keyLabel.font = [UIFont systemFontOfSize:13];
        keyLabel.textColor = [UIColor grayColor];
        keyLabel.text = [NSString stringWithFormat:@"现金  %.2f", [orderDetail.total doubleValue]];
        [cell addSubview:keyLabel];
        
        return cell;
    }
    else if (indexPath.section == 2)//退还原因
    {
        if (indexPath.row == 0) {
            static NSString *applicationDrawback_five = @"applicationDrawback_five";
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:applicationDrawback_five];
            if (cell == nil)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:applicationDrawback_five];
            }
            
            [cell.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            
            UILabel *listLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 90, cellH)];
            listLabel.backgroundColor = [UIColor clearColor];
            listLabel.font = [UIFont systemFontOfSize:14];
            listLabel.textColor = ColorDarkGray;
            listLabel.text = @"退还原因：";
            [cell addSubview:listLabel];
            
            [listLabel sizeToFit];
            listLabel.deFrameHeight = cellH;
            
            UILabel *keyLabel = [[UILabel alloc] initWithFrame:CGRectMake(listLabel.deFrameRight, 0, cell.frame.size.width - listLabel.deFrameRight, cellH)];
            keyLabel.backgroundColor = [UIColor clearColor];
            keyLabel.text = @"";
            keyLabel.font = [UIFont systemFontOfSize:13];
            keyLabel.textColor = [UIColor grayColor];
            [cell addSubview:keyLabel];
            
            return cell;
        }
        else
        {
            static NSString *applicationDrawback_six = @"applicationDrawback_six";
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:applicationDrawback_six];
            
            if (cell == nil)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:applicationDrawback_six];
            }
            
            UIButton *checkBtn = (UIButton*)[cell.contentView viewWithTag:98765];
            if (checkBtn == nil)
            {
                checkBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_SIZE_WIDTH - 60, 5, 15, 15)];
                checkBtn.tag = 98765;
                [cell.contentView addSubview:checkBtn];
            }
            if (indexPath.row == curIndex)
            {
                [checkBtn setImage:[UIImage imageNamed:@"check001.png"] forState:UIControlStateNormal];
            }
            else
            {
                [checkBtn setImage:[UIImage imageNamed:@"check002.png"] forState:UIControlStateNormal];
            }
            
            cell.textLabel.text = arr[indexPath.row - 1];
            cell.textLabel.textColor = ColorDarkGray;
            cell.textLabel.font = [UIFont systemFontOfSize:13];
            
            return cell;
        }
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5.0;
}

-(CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section
{
    return 5.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return cellH;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2)
    {
        curIndex = indexPath.row;
        
        _drawbackBtn.enabled = YES;
    }
    
    [tableView reloadData];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end