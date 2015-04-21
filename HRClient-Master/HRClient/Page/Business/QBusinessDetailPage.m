//
//  QBusinessDetailPage.m
//  HRClient
//
//  Created by chenyf on 14/12/5.
//  Copyright (c) 2014年 panyj. All rights reserved.
//  商家详情

#import "QBusinessDetailPage.h"
#import "QViewController.h"
#import "QBussinessCell.h"
#import "QGroupBuyCell.h"
#import "QHttpMessageManager.h"
#import "ASStarRating.h"
#import "QCommentsCell.h"
#import "QAppraisalPage.h"

#define MaxDisplayProductsCount         (2)

@interface QBusinessDetailPage ()<QCommentsCellDelegate>
{
    NSString *companyId;
    QBusinessDetailModel *dataModel;
    NSMutableArray *commentsArr;
    NSMutableArray *productsArr;
}

@property (nonatomic) UITableView *businessDetailTableView;

@end

@implementation QBusinessDetailPage

#pragma mark - view

- (void)setActiveWithParams:(NSDictionary*)params
{
    companyId = [params objectForKey:@"companyID"];
}

- (void)pageEvent:(QPageEventType)eventType
{
    if (eventType == kPageEventWillShow)
    {
    }
    else if (eventType == kPageEventWillHide)
    {
        [ASRequestHUD dismiss];
    }
    else if (eventType == kPageEventViewDispose)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [QTools endWaittingInView:_view];
    }
    else if (eventType == kPageEventViewCreate)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetBusinessDetail:)
                                                     name:kBusinessDetail object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetBusinessDetailComment:)
                                                     name:kBusinessDetailComment object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetBusinessDetailProductList:)
                                                     name:kBusinessDetailProduct object:nil];
        
        [[QHttpMessageManager sharedHttpMessageManager] accessBusinessDetail:companyId];
        [ASRequestHUD show];;
    }
}

//商家详情
- (void)didGetBusinessDetail:(NSNotification*)notify
{
    [ASRequestHUD dismiss];
    
    dataModel = notify.object;
    [_businessDetailTableView reloadData];
}

//商家详情评论
- (void)didGetBusinessDetailComment:(NSNotification*)notify
{
    [ASRequestHUD dismiss];
    
    commentsArr = notify.object;
    [_businessDetailTableView reloadData];
}

//商品列表
- (void)didGetBusinessDetailProductList:(NSNotification*)notify
{
    [ASRequestHUD dismiss];
    
    productsArr = notify.object;
    [_businessDetailTableView reloadData];
}

- (UIView *)viewWithFrame:(CGRect)frame
{
    if ([super viewWithFrame:frame]) {
        
        // 商家详情
        _businessDetailTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) style:UITableViewStyleGrouped];
        _businessDetailTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _businessDetailTableView.delegate = self;
        _businessDetailTableView.dataSource = self;
        _businessDetailTableView.backgroundColor = [QTools colorWithRGB:240 :239 :237];
        [_view addSubview:_businessDetailTableView];
    }
    
    return _view;
}

/*
- (NSArray*)pageRightMenus
{
    _view.backgroundColor = [QTools colorWithRGB:240 :239 :237];
    
    UIButton *editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [editBtn setImage:[UIImage imageNamed:@"collect_detail.png"] forState:UIControlStateNormal];
    [editBtn addTarget:self action:@selector(setCollect) forControlEvents:UIControlEventTouchUpInside];
    [editBtn sizeToFit];
    UIBarButtonItem *editItem = [[UIBarButtonItem alloc] initWithCustomView:editBtn];
    
    UIButton *editBtn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [editBtn2 setImage:[UIImage imageNamed:@"share_detail.png"] forState:UIControlStateNormal];
    [editBtn2 addTarget:self action:@selector(setShare) forControlEvents:UIControlEventTouchUpInside];
    [editBtn2 sizeToFit];
    UIBarButtonItem *editItem2 = [[UIBarButtonItem alloc] initWithCustomView:editBtn2];
    
    return [NSArray arrayWithObjects:editItem,editItem2, nil];
}*/

- (NSString *)title
{
    return @"商家详情";
}

#pragma mark - Private

#pragma mark == height for cell

- (CGFloat)heightForAddressCellWithAddress:(NSString *)address
{
    // 计算详细地址Cell高度
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _businessDetailTableView.deFrameWidth - 80, 30)];
    label.font = [UIFont systemFontOfSize:14];
    label.numberOfLines = 0;
    label.text = address;
    [label sizeToFit];
    
    return 30 + label.deFrameHeight;
}

- (CGFloat)heightForRateCellWithComment:(NSString *)comment andReply:(NSString *)reply andImageCount:(int)imageCount
{
    // 计算评价Cell高度
    CGFloat padding = 12.f;
    CGFloat basicHeight = 37;
    CGFloat commentHeight = 0;
    CGFloat replyBackgroundHeightWithoutLabel = 30;
    CGFloat replyHeight = 0;
    CGFloat imageHeight = 0;
    
    CGSize commentLabelSize = [comment sizeWithFont:[UIFont systemFontOfSize:13] forWidth:_businessDetailTableView.deFrameWidth - 35 lineBreakMode:NSLineBreakByWordWrapping];
    commentHeight = commentLabelSize.height + padding;
    
    CGSize replyLabelSize = [reply sizeWithFont:[UIFont systemFontOfSize:13] forWidth:_businessDetailTableView.deFrameWidth - 60 lineBreakMode:NSLineBreakByWordWrapping];
    replyHeight = replyBackgroundHeightWithoutLabel +replyLabelSize.height + padding;
    
    // TODO:images view height
    imageHeight = 0;
    
    return basicHeight + commentHeight + replyHeight + imageHeight;
}

#pragma mark - Action
/*
- (void)setCollect
{
    //
}

- (void)setShare
{
    //
}
*/

- (void)onCallPhone:(id)sender
{
    if (!dataModel.telphone || [dataModel.telphone isEqualToString:@""])
    {
        [ASRequestHUD showErrorWithStatus:@"商家电话为空"];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:[NSString stringWithFormat:@"是否呼叫%@", dataModel.telphone]
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"呼叫", nil];
        [alertView show];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        NSString *num = [[NSString alloc] initWithFormat:@"tel://%@", dataModel.telphone];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:num]];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // 基本信息、本店团购、评价、//附近团购
    return dataModel ? 3 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0: // 基本信息
            return 2;
        case 1: // 本店团购 动态取
            if (productsArr.count >= MaxDisplayProductsCount) {
                return productsArr.count + 1;
            }
            else {
             return productsArr.count;//查看全部服务
            }
        case 2: // 评价 默认显示两条（加1条更多项）
            return 1;
        case 3: // 附近团购 动态取
            return 4 + 1; //查看全部
        default:
            return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 1: // 本店团购
        case 3: // 附近团购
            return 36;
        case 2: // 评价
            return 36;
        default:
            return 0.1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0: // 基本信息
            switch (indexPath.row) {
                case 0: // 图片 & 商家名称 & 评分
                    return 89; // 120
                case 1: // 详细地址 & 联系电话
                    //动态计算Cell高度
                    return [self heightForAddressCellWithAddress:dataModel.detailAddress];
                default:
                    return 0;
            }
        case 1: // 本店团购
            if ((dataModel.productListResult.count >= MaxDisplayProductsCount)
                && (indexPath.row == MaxDisplayProductsCount))
            {
                return 30;
            }
            else
            {
                return [QGroupBuyCell GetQGroupBuyCellHeight];
            }
        case 3: // 附近团购
            if (indexPath.row == 4)
                return 30;
            return [QGroupBuyCell GetQGroupBuyCellHeight];
        case 2: // 评价
            return [QCommentsCell heightofCell:commentsArr isExpand:NO];
            
        default:
            return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 11;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGFloat height = [self tableView:tableView heightForHeaderInSection:section];
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.deFrameWidth, height)];
    headerView.backgroundColor = [UIColor whiteColor];
    
    // 评价
    if (section == 2) {
        // 图标
        UIImageView *iconImageView = [[UIImageView alloc] initWithImage:IMAGEOF(@"rate_icon")];
        iconImageView.center = headerView.center;
        iconImageView.deFrameLeft = 10;
        [headerView addSubview:iconImageView];
        // 星级
        ASStarRating *rateView = [[ASStarRating alloc] initWithFrame:CGRectMake(0, 0, 80, 13)];
        [rateView setScore:[dataModel.grade doubleValue]];
        rateView.center = headerView.center;
        rateView.deFrameRight = tableView.deFrameWidth - 35;
        [headerView addSubview:rateView];
        rateView.hidden = (0 == commentsArr.count) ? YES : NO;
        
        // 评分
        UILabel *scoreLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        scoreLabel.text = [dataModel.grade stringValue];
        scoreLabel.font = [UIFont systemFontOfSize:12];
        scoreLabel.textColor = [QTools colorWithRGB:246 :172 :75];
        [scoreLabel sizeToFit];
        scoreLabel.center = headerView.center;
        scoreLabel.deFrameLeft = rateView.deFrameRight + 5;
        [headerView addSubview:scoreLabel];
        scoreLabel.hidden = (0 == commentsArr.count) ? YES : NO;
    }
    // 分割线
    UIView *separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(0, [self tableView:tableView heightForHeaderInSection:section] - 0.5f, tableView.deFrameWidth, 0.5f)];
    separatorLineView.backgroundColor = ColorLine;
    [headerView addSubview:separatorLineView];
    
    // 名称
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, height)];
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = ColorDarkGray;
    [headerView addSubview:titleLabel];
    switch (section) {
        case 1: // 本店团购
        {
            titleLabel.text = @"本店服务";
            titleLabel.deFrameLeft = 10;
        }
            break;
        case 2: // 评价
        {
            titleLabel.text = @"评价";
            titleLabel.deFrameLeft = 35;
        }
            break;
        case 3: // 附近团购
        {
            titleLabel.text = @"附近服务";
            titleLabel.deFrameLeft = 10;
        }
            break;
        default:
            break;
    }
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        // 基本信息
        if (indexPath.row == 0) {
            #pragma mark -- 图片 & 商家名称 & 评分 cellView
            static NSString *CellIdentifierBusiness = @"Cell_Identifier_BusinessDetail_BasicInfo";
            QBussinessCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierBusiness];
            if (nil == cell) {
                cell = [[QBussinessCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierBusiness];
            }
            
            [cell configureCellForBusinDetail:dataModel];
            return cell;
        }
        else if (indexPath.row == 1) {
            #pragma mark -- 详细地址 & 联系电话 cellView
            static NSString *CellIdentifierPhone = @"Cell_Identifier_BusinessDetail_Phone";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierPhone];
            if (nil == cell)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierPhone];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            
            [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            
            CGFloat cellHeight = [self heightForAddressCellWithAddress:dataModel.detailAddress];
            
            cell.imageView.image = IMAGEOF(@"location_cell");
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(35, 0, SCREEN_SIZE_WIDTH - 2*40, cellHeight)];
            label.font = [UIFont systemFontOfSize:14];
            label.textColor = [QTools colorWithRGB:105 :105 :105];
            label.lineBreakMode = NSLineBreakByWordWrapping;
            label.text = NSString_No_Nil(dataModel.detailAddress);
            label.numberOfLines = 0;
            [cell.contentView addSubview:label];
            
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(label.deFrameRight + 5, 5, 0.5f, cellHeight - 2*5)];
            lineView.backgroundColor = ColorLine;
            [cell.contentView addSubview:lineView];
            
            UIButton *btnCall = [[UIButton alloc] initWithFrame:CGRectMake(lineView.deFrameRight, 0, 35, cellHeight)];
            [btnCall setImage:IMAGEOF(@"phone_cell") forState:UIControlStateNormal];
            [btnCall addTarget:self action:@selector(onCallPhone:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:btnCall];
            
            return cell;
        }
    }
    else if (indexPath.section == 1/* || indexPath.section == 3*/)
    {
        #pragma mark -- 本店团购 & 附近团购 cellView
        if (productsArr && indexPath.row < productsArr.count)
        {
            static NSString *CellIdentifierGroupBuy = @"Cell_Identifier_BusinessDetail_GroupBuy";
            QGroupBuyCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierGroupBuy];
            if (nil == cell) {
                cell = [[QGroupBuyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierGroupBuy];
            }
            
            [cell configureCellForBusinPage:productsArr andIndexPath:indexPath];
            return cell;
        }
        else
        {
            static NSString *CellIdentifierRateMore = @"Cell_Identifier_BusinessDetail_Rate_More";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierRateMore];
            if (nil == cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierRateMore];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            cell.textLabel.text = (!productsArr || productsArr.count == 0) ? @"暂无其他服务" : @"查看全部服务";
            cell.textLabel.font = [UIFont systemFontOfSize:12];
            cell.textLabel.textColor = [QTools colorWithRGB:196 :0 :0];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
    }
    else if (indexPath.section == 2)
    {
        #pragma mark -- 评价 cellView
        static NSString *CellIdentifierPhone = @"Comments";
        QCommentsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierPhone];
        if (nil == cell)
        {
            cell = [[QCommentsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierPhone];
            cell.delegate = self;
        }

        cell.commentsArr = commentsArr;
        return cell;
    }

    static NSString *CellIdentifier = @"Cell_Identifier_BusinessDetail";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                     reuseIdentifier:CellIdentifier];
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
    switch (indexPath.section) {
        case 0: // 基本信息
        {
            switch (indexPath.row)
            {
                case 1: // 联系电话
                {
                    //call
                }break;
                default:
                    return;
            }
        }
            break;
        case 1: // 本店服务
        {
            if (productsArr && productsArr.count > indexPath.row)
            {
                /* 商品详情页面 */
                QBusinessDetailResult *model = productsArr[indexPath.row];
                [QViewController gotoPage:@"QGroupBuyDetailPage" withParam:[NSDictionary dictionaryWithObjectsAndKeys:model.productId, @"ProductID", nil]];
            }
            else
            {
                /* 更多商品页面 */
                [QViewController gotoPage:@"QBusinessAllServices" withParam:[NSDictionary dictionaryWithObjectsAndKeys:companyId, @"companyID", dataModel.companyName, @"companyName", nil]];
            }
        }
        case 2: // 评价
            if (indexPath.row == 2) {
                
                
            }
        default:
            return;
    }
}


#pragma mark - QCommentsCellDelegate
- (void)onMoreComment
{
    [QViewController gotoPage:@"QAppraisalPage" withParam:[NSDictionary dictionaryWithObjectsAndKeys:
                                                           [NSNumber numberWithInt:kBusinessCommentType], @"commentType",
                                                           companyId, @"companyId",nil]];
}
@end
