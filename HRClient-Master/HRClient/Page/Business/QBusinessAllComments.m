//
//  QBusinessAllComments.m
//  HRClient
//
//  Created by chenyf on 14/12/5.
//  Copyright (c) 2014年 panyj. All rights reserved.
//  商家详情

#import "QBusinessAllComments.h"
#import "QViewController.h"
#import "QBussinessCell.h"
#import "QGroupBuyCell.h"
#import "QHttpMessageManager.h"

@interface QBusinessAllComments ()
{
    NSInteger companyID;
    QBusinessDetailModel *dataModel;
    NSMutableArray *commentsArr;
    NSMutableArray *productsArr;
}

@property (nonatomic) UITableView *commentsTableView;

@end

@implementation QBusinessAllComments

#pragma mark - view

- (void)setActiveWithParams:(NSDictionary*)params
{
    companyID = [[params objectForKey:@"companyID"] integerValue];
}

- (void)pageEvent:(QPageEventType)eventType
{
    if (eventType == kPageEventWillShow)
    {
    }
    else if (eventType == kPageEventWillHide)
    {
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
        
        [[QHttpMessageManager sharedHttpMessageManager] accessBusinessDetail:@"3"];//[NSString stringWithFormat:@"%d",companyID]
        [QTools startShortWaittingInView:_view];
    }
}

//商家详情
- (void)didGetBusinessDetail:(NSNotification*)notify
{
    dataModel = notify.object;
    [_commentsTableView reloadData];
}

//商家详情评论
- (void)didGetBusinessDetailComment:(NSNotification*)notify
{
    commentsArr = notify.object;
    [_commentsTableView reloadData];
}

//商品列表
- (void)didGetBusinessDetailProductList:(NSNotification*)notify
{
    productsArr = notify.object;
    [_commentsTableView reloadData];
    
    [QTools endWaittingInView:_view];
}

- (UIView *)viewWithFrame:(CGRect)frame
{
    if ([super viewWithFrame:frame]) {
        
        // 商家详情
        _commentsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) style:UITableViewStyleGrouped];
        _commentsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _commentsTableView.delegate = self;
        _commentsTableView.dataSource = self;
        _commentsTableView.backgroundColor = [QTools colorWithRGB:240 :239 :237];
        [_view addSubview:_commentsTableView];
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
    CGSize addressLabelSize = [address sizeWithFont:[UIFont systemFontOfSize:15] forWidth:_commentsTableView.deFrameWidth - 90 lineBreakMode:NSLineBreakByWordWrapping];
    CGFloat kAddressCellHeightWithoutLabel = 30;
    
    return kAddressCellHeightWithoutLabel + addressLabelSize.height;
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
    
    CGSize commentLabelSize = [comment sizeWithFont:[UIFont systemFontOfSize:13] forWidth:_commentsTableView.deFrameWidth - 35 lineBreakMode:NSLineBreakByWordWrapping];
    commentHeight = commentLabelSize.height + padding;
    
    CGSize replyLabelSize = [reply sizeWithFont:[UIFont systemFontOfSize:13] forWidth:_commentsTableView.deFrameWidth - 60 lineBreakMode:NSLineBreakByWordWrapping];
    replyHeight = replyBackgroundHeightWithoutLabel +replyLabelSize.height + padding;
    
    // TODO:images view height
    imageHeight = 0;
    
    return basicHeight + commentHeight + replyHeight + imageHeight;
}

#pragma mark - Action
- (void)setCollect
{
    //
}

- (void)setShare
{
    //后续版本添加
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // 基本信息、本店团购、评价、//附近团购
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0: // 基本信息
            return 3;
        case 1: // 本店团购 动态取
            return productsArr.count + 1;//查看全部服务
        case 2: // 评价 默认显示两条（加1条更多项）
            return commentsArr.count + 1;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0: // 基本信息
            switch (indexPath.row) {
                case 1: // 联系电话
                {
                    //call
                }break;
                    
                case 2: // 详细地址
                {
                    //location
                }break;
                    
                default:
                    return;
            }
        case 1: // 本店服务
        {
            //商品详情页面
            if (productsArr && productsArr.count > indexPath.row)
            {
                QBusinessDetailResult *model = productsArr[indexPath.row];
                [QViewController gotoPage:@"QGroupBuyDetailPage" withParam:[NSDictionary dictionaryWithObjectsAndKeys:model.productId, @"ProductID", nil]];
            }
        }
        case 2: // 评价
            if (indexPath.row == 2) {
                
                
            }
        default:
            return;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0: // 基本信息
            switch (indexPath.row) {
                case 0: // 图片 & 商家名称 & 评分
                    return 89; // 120
                case 1: // 联系电话
                    return 30;
                case 2: // 详细地址 动态计算Cell高度
                    if (dataModel.detailAddress)
                        return [self heightForAddressCellWithAddress:dataModel.detailAddress];
                    else
                        return 30;
                default:
                    return 0;
            }
        case 1: // 本店团购
            if (indexPath.row == 2)
                return 30;
            return [QGroupBuyCell GetQGroupBuyCellHeight];
        case 3: // 附近团购
            if (indexPath.row == 4)
                return 30;
            return [QGroupBuyCell GetQGroupBuyCellHeight];
        case 2: // 评价
            if (indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1) {
                // 最后一项（查看更多）
                return 30;
            }
            else
            {
                QBusinessDetailComment *comment = commentsArr[indexPath.row];
                NSString *strInfo = (comment.content || [comment.content isEqualToString:@""]) ? @"这家伙很懒，什么都没留下" : comment.content;
                return [self heightForRateCellWithComment:strInfo andReply:@"" andImageCount:0];
            }
            
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
    UITableViewHeaderFooterView *headerView = [[UITableViewHeaderFooterView alloc] initWithFrame:CGRectMake(0, 0, tableView.deFrameWidth, [self tableView:tableView heightForHeaderInSection:section])];
    headerView.textLabel.font = [UIFont systemFontOfSize:15];
    headerView.contentView.backgroundColor = [UIColor whiteColor];
    if (section == 2) {
        // 评价
        // 图标
        CGFloat marginLeft = 11;
        UIImageView *iconImageView = [[UIImageView alloc] initWithImage:IMAGEOF(@"rate_icon")];
        iconImageView.center = headerView.center;
        iconImageView.deFrameLeft = marginLeft;
        [headerView addSubview:iconImageView];
        // 星级
        UIImageView *starImageView = [[UIImageView alloc] initWithImage:IMAGEOF(@"tmp_star")];
        starImageView.center = headerView.center;
        starImageView.deFrameRight = tableView.deFrameWidth - 35;
        [headerView addSubview:starImageView];
        // 评分
        UILabel *scoreLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        scoreLabel.text = @"4.5";
        scoreLabel.font = [UIFont systemFontOfSize:13];
        scoreLabel.textColor = [QTools colorWithRGB:246 :172 :75];
        [scoreLabel sizeToFit];
        scoreLabel.center = headerView.center;
        scoreLabel.deFrameLeft = starImageView.deFrameRight + 6;
        [headerView addSubview:scoreLabel];
    }
    // 分割线
    UIView *separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(0, [self tableView:tableView heightForHeaderInSection:section] - 0.5, tableView.deFrameWidth, 0.5)];
    separatorLineView.backgroundColor = [QTools colorWithRGB:236 :236 :236];
    [headerView addSubview:separatorLineView];
    switch (section) {
        case 1: // 本店团购
            headerView.textLabel.text = @"本店服务";
            break;
        case 2: // 评价
            headerView.textLabel.text = @"      评价";
            break;
        case 3: // 附近团购
            headerView.textLabel.text = @"附近服务";
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
            #pragma mark -- 联系电话 cellView
            static NSString *CellIdentifierPhone = @"Cell_Identifier_BusinessDetail_Phone";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierPhone];
            if (nil == cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierPhone];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            [cell.imageView setImage:IMAGEOF(@"phone_cell")];
            cell.textLabel.text = @"暂无电话";
            if (dataModel.companyTel) cell.textLabel.text = dataModel.companyTel;
            cell.textLabel.font = [UIFont systemFontOfSize:14];
            cell.textLabel.textColor = [QTools colorWithRGB:105 :105 :105];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        } else if (indexPath.row == 2) {
            #pragma mark -- 详细地址 cellView
            static NSString *CellIdentifierAddress = @"Cell_Identifier_BusinessDetail_Address";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierAddress];
            if (nil == cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierAddress];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            [cell.imageView setImage:IMAGEOF(@"location_cell")];
            cell.textLabel.text = @"未知地址";
            if (dataModel.detailAddress) cell.textLabel.text = dataModel.detailAddress;
            cell.textLabel.font = [UIFont systemFontOfSize:14];
            cell.textLabel.textColor = [QTools colorWithRGB:105 :105 :105];
            cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
            cell.textLabel.numberOfLines = 0;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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
        // 评价
        if (commentsArr && indexPath.row < commentsArr.count)
        {
#pragma mark -- 评价 cellView
            QBusinessDetailComment *comment = commentsArr[indexPath.row];
            
            static NSString *CellIdentifierRate = @"Cell_Identifier_BusinessDetail_Rate";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierRate];
            if (nil == cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierRate];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            CGFloat marginLeft = 18;
            CGFloat marginTop = 12;
            //CGFloat padding = 12.f;
            
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
            [cell addSubview:nameAndDateLabel];
            
            // 星级图标
            marginTop = 10;
            UIImageView *starImageView = [[UIImageView alloc] initWithImage:IMAGEOF(@"tmp_star")];
            starImageView.deFrameTop = marginTop;
            starImageView.deFrameRight = tableView.deFrameWidth - marginLeft;
            [cell addSubview:starImageView];
            
            // 评价内容
            marginTop = 35;
            UILabel *commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(marginLeft, marginTop, tableView.deFrameWidth - 35, 0)];
            commentLabel.text = (!comment.content || [comment.content isEqualToString:@""]) ? @"这家伙很懒，什么都没留下" : comment.content;
            commentLabel.font = [UIFont systemFontOfSize:13];
            commentLabel.textColor = [QTools colorWithRGB:155 :155 :155];
            commentLabel.lineBreakMode = NSLineBreakByWordWrapping;
            commentLabel.numberOfLines = 0;
            [commentLabel sizeToFit];
            [cell addSubview:commentLabel];
            
            /* 商家回复
            UIView *replyBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(marginLeft, commentLabel.deFrameBottom + padding, tableView.deFrameWidth - marginLeft * 2, 0)];
            replyBackgroundView.backgroundColor = [QTools colorWithRGB:239 :239 :239];*/
            
            // 分割线
            UIView *separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(0, [self tableView:tableView heightForRowAtIndexPath:indexPath] - 0.5, cell.deFrameWidth, 0.5)];
            separatorLineView.backgroundColor = [QTools colorWithRGB:236 :236 :236];
            [cell addSubview:separatorLineView];
            
            return cell;
        }
        else
        {
#pragma mark -- 最后一项（查看更多）cellView
            static NSString *CellIdentifierRateMore = @"Cell_Identifier_BusinessDetail_Rate_More";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierRateMore];
            if (nil == cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierRateMore];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            cell.textLabel.text = (!commentsArr || commentsArr.count == 0) ? @"暂无其他服务" :@"查看全部评论";
            cell.textLabel.font = [UIFont systemFontOfSize:12];
            cell.textLabel.textColor = [QTools colorWithRGB:196 :0 :0];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
    }

    static NSString *CellIdentifier = @"Cell_Identifier_BusinessDetail";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
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

@end
