//
//  QGroupBuyDetailPage.m
//  HRClient
//
//  Created by chenyf on 14/12/10.
//  Copyright (c) 2014年 panyj. All rights reserved.
//  团购详情

#import "QGroupBuyDetailPage.h"
#import "QViewController.h"
#import "ALScrollViewPaging.h"
#import "QGroupBuyDetailVIPPriceCell.h"
#import "QVIPCardRechargeCell.h"
#import "QHttpMessageManager.h"
#import "UIImageView+WebCache.h"
#import "QCommentsCell.h"
#import "QTools.h"
#import "QAppraisalPage.h"
#import "ASStarRating.h"
#import "QCardDetailModel.h"

#define Cell_Height_Image 190
#define Cell_Height_Buy 63
#define Cell_Height_BusinessName 46
#define Cell_Height_SalesService 73
#define Cell_Height_Appraisal 45
#define Cell_Height_UserAppraisal 53 // UserAppraisal数据loadComplete后，动态计算该值
#define Cell_Height_BusinessInfo 70
#define Cell_Height_VIPPrice 230
#define Cell_Height_Combo 34
#define Cell_Height_LookOther 142

@interface QGroupBuyDetailPage () <QGroupBuyDetailVIPPriceCellDelegate,
                                    QCommentsCellDelegate>
{
    NSTimer *timer;
    NSInteger pageSize;
    int productID;
    BOOL _isProductIDChanged;
}

@property (nonatomic) UITableView *groupBuyDetailTableView;;
@property (nonatomic) UICollectionView *lookOtherCollection;
@property (nonatomic) UIView *floatingView;
@property (nonatomic) UIView *floatingSuperView;
@property (nonatomic) ALScrollViewPaging *imageScrollView;

@end

@implementation QGroupBuyDetailPage

#pragma mark - view


- (void)setActiveWithParams:(NSDictionary *)params
{
    int ID = [[params objectForKey:@"ProductID"] intValue];
    if (!productID || (productID != ID))
    {
        productID = ID;
        _isProductIDChanged = YES;
    }
}

//立即购买的返回
- (void)successGetListDetail:(NSNotification *)noti
{
    QMyListDetailModel *detailModel = noti.object;
    [ASRequestHUD dismiss];
    
//    [QViewController gotoPage:@"QConfirmOrderPageEx" withParam:[[NSDictionary alloc]
//                                                 initWithObjectsAndKeys:detailModel, @"QMyListDetailModel",self.productDetail, @"productDetail",nil]];
    
    [QViewController gotoPage:@"QConfirmOrderPage" withParam:[[NSDictionary alloc]
                                                              initWithObjectsAndKeys:detailModel, @"QMyListDetailModel",nil]];
}


- (void)successAddList:(NSNotification*)noti
{
    QMyListModel *model = noti.object;
    
    if (model.status.integerValue == 1) //未付款
    {
        [[QHttpMessageManager sharedHttpMessageManager] accessMyListDetail:model.orderListId.stringValue andStatus:@"1"];
    }
}

- (void)pageEvent:(QPageEventType)eventType
{
    if (eventType == kPageEventWillShow)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(successAddList:) name:kAddList object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addMyFavoritySuccess:) name:kAddMyFavority object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(successGetListDetail:) name:kGetMyListDetail object:nil];
        
        if (_isProductIDChanged)
        {
            [[QHttpMessageManager sharedHttpMessageManager] accessProductDetail:[NSString stringWithFormat:@"%d", productID]];
            [ASRequestHUD show];
            
            _isProductIDChanged = NO;
        }
    }
    else if (eventType == kPageEventWillHide)
    {
        [ASRequestHUD dismiss];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kAddList object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kAddMyFavority object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kGetMyListDetail object:nil];
    }
    else if (eventType == kPageEventViewCreate)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getProductDetail:) name:kProductDetail object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getProductCompany:) name:kProductDetailCompany object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getProductComment:) name:kProductDetailComment object:nil];

        _isProductIDChanged = YES;
    }
    else if (eventType == kPageEventViewDispose)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (void)getProductDetail:(NSNotification*)notify
{
    self.productDetail = notify.object;
    
    [ASRequestHUD dismiss];
    [_groupBuyDetailTableView reloadData];
}

- (void)getProductCompany:(NSNotification*)notify
{
    self.productCompany = notify.object;
    
    [ASRequestHUD dismiss];
    [_groupBuyDetailTableView reloadData];
}

- (void)getProductComment:(NSNotification*)notify
{
/*
    NSMutableArray *arrs = [[NSMutableArray alloc] initWithArray:notify.object];
    [arrs addObjectsFromArray:notify.object];
    self.commentList = arrs;
*/
    self.commentList = notify.object;
    
    [ASRequestHUD dismiss];
    [_groupBuyDetailTableView reloadData];
}

- (void)addMyFavoritySuccess:(NSNotification*)notify
{
    [ASRequestHUD dismissWithSuccess:@"收藏成功"];
}

- (UIView *)viewWithFrame:(CGRect)frame
{
    if ([super viewWithFrame:frame]) {
        
        pageSize = 0;
        
        // 商家详情
        _groupBuyDetailTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)
                                                                style:UITableViewStylePlain];
        _groupBuyDetailTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _groupBuyDetailTableView.delegate = self;
        _groupBuyDetailTableView.dataSource = self;
        _groupBuyDetailTableView.backgroundColor = [QTools colorWithRGB:240 :239 :237];
        [_view addSubview:_groupBuyDetailTableView];
    }
    
    return _view;
}

- (NSArray*)pageRightMenus
{
    _view.backgroundColor = [QTools colorWithRGB:240 :239 :237];
    
    UIButton *editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [editBtn setImage:[UIImage imageNamed:@"collect_detail.png"] forState:UIControlStateNormal];
    [editBtn addTarget:self action:@selector(setCollect) forControlEvents:UIControlEventTouchUpInside];
    [editBtn sizeToFit];
    UIBarButtonItem *editItem = [[UIBarButtonItem alloc] initWithCustomView:editBtn];
    
    UIButton *editBtn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    //[editBtn2 setImage:[UIImage imageNamed:@"share_detail.png"] forState:UIControlStateNormal];
    [editBtn2 addTarget:self action:@selector(setShare) forControlEvents:UIControlEventTouchUpInside];
    [editBtn2 sizeToFit];
    UIBarButtonItem *editItem2 = [[UIBarButtonItem alloc] initWithCustomView:editBtn2];
    
    return [NSArray arrayWithObjects:editItem,editItem2, nil];
}

- (NSString *)title
{
    return @"商品详情";
}

#pragma mark - Private

#pragma mark == height for cell

- (CGFloat)heightForRateCellWithComment:(NSString *)comment andReply:(NSString *)reply andImageCount:(int)imageCount
{
    // 计算评价Cell高度
    CGFloat padding = 12.f;
    CGFloat basicHeight = 37;
    CGFloat commentHeight = 0;
    CGFloat replyBackgroundHeightWithoutLabel = 30;
    CGFloat replyHeight = 0;
    CGFloat imageHeight = 0;
    
    CGSize commentLabelSize = [comment sizeWithFont:[UIFont systemFontOfSize:13] forWidth:_groupBuyDetailTableView.deFrameWidth - 35 lineBreakMode:NSLineBreakByWordWrapping];
    commentHeight = commentLabelSize.height + padding;
    
    CGSize replyLabelSize = [reply sizeWithFont:[UIFont systemFontOfSize:13] forWidth:_groupBuyDetailTableView.deFrameWidth - 60 lineBreakMode:NSLineBreakByWordWrapping];
    replyHeight = replyBackgroundHeightWithoutLabel +replyLabelSize.height + padding;
    
    // TODO:images view height
    imageHeight = 0;
    
    return basicHeight + commentHeight + replyHeight + imageHeight;
}

- (CGFloat)heightForAboutRecommentCellWithAddress:(NSString *)address
{
    // 计算相关团购推荐Cell高度
    CGSize aboutRecommentLabelSize = [address sizeWithFont:[UIFont systemFontOfSize:12] forWidth:_groupBuyDetailTableView.deFrameWidth - 14 - 50 lineBreakMode:NSLineBreakByWordWrapping];
    CGFloat kAboutRecommentHeightWithoutLabel = 60;
    
    return kAboutRecommentHeightWithoutLabel + aboutRecommentLabelSize.height;
}

#pragma mark == Tapped

- (void)buyButtonTapped:(id)sender
{
    [QViewController gotoPage:@"QSubmitOrderPage" withParam:[[NSDictionary alloc] initWithObjectsAndKeys:self.productDetail, @"ProductDetail", nil]];
}

- (void)rechargeButtonTapped:(id)sender
{
    if ([QUser sharedQUser].isVIP)
    {
        //[QViewController gotoPage:@"QMyVIPCard" withParam:nil];
        
        //活动价购买
        NSString *strBidType = [self.productDetail.productBid objectForKey:@"bidType"];
        [[QHttpMessageManager sharedHttpMessageManager] accessAddList:[self.productDetail.productId stringValue]
                                                          andQuantity:@"1" andBidType:strBidType];
        [ASRequestHUD show];
        
    }
    else
    {
        [QViewController gotoPage:@"QNoVipChong" withParam:nil];
    }
}

- (void)phoneIconImageViewTapped:(id)sender
{
    if (self.productCompany.companyTel && ![self.productCompany.companyTel isEqualToString:@""])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:[NSString stringWithFormat:@"是否呼叫%@", self.productCompany.companyTel]
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"呼叫", nil];
        [alertView show];
    }
    else
    {
        [ASRequestHUD showErrorWithStatus:@"商家电话为空"];
    }
}

- (void)onTimer:(NSTimer *)theTimer
{
    CGPoint newOffset = self.imageScrollView.contentOffset;
    newOffset.x += SCREEN_SIZE_WIDTH;
    if (newOffset.x == SCREEN_SIZE_WIDTH * pageSize) {
        newOffset.x = 0;
    }
    
    [self.imageScrollView setContentOffset:newOffset animated:YES];
}

- (void)setCollect
{
    if (self.productDetail) {
        [[QHttpMessageManager sharedHttpMessageManager] accessAddMyFavorite:[self.productDetail.companyId stringValue]
                                                               andProductId:[self.productDetail.productId stringValue]
                                                              andCategoryId:[self.productDetail.categoryId stringValue]];
        [ASRequestHUD show];
    }
}

- (void)setShare
{

}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // 基本信息、评价、商家信息、会员价格、套餐、购买须知、评价、相关团购推荐 /*看了本团购的用户还看了 暂时屏蔽 第二版*/
    return self.productDetail ? 5 : 0; // 9
}

- (BOOL)bShowTheNormalPrice
{
    return (![[QUser sharedQUser] isVIP] && [self.productDetail.or_member boolValue]) || ([[self.productDetail.usrMbrPrice objectForKey:@"memberUnitPrice"] doubleValue] > [[QUser sharedQUser].vipAccount.balance doubleValue]);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0: // 基本信息
            return 5;
        case 1: // 商家信息
            return 1;
        case 2: // 会员价格
            return [self bShowTheNormalPrice] ? 1 : 0;
        case 3: // 购买须知（加1条更多项）
            return 1;
        case 4: // 评价 默认显示两条（加1条更多项）
            return 1;
        default:
            return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 0.1;
        case 2:
            return (![[QUser sharedQUser] isVIP] && [self.productDetail.or_member boolValue]) ? 36 : 0;
        default:
            return 36;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0: // 基本信息
            switch (indexPath.row)
        {
                case 0:
                    /*展示图片*/
                    return Cell_Height_Image;
                case 1:
                    /* 非vip用户 && 会员商品*/
                    return [self bShowTheNormalPrice] ? Cell_Height_Buy*2 : Cell_Height_Buy;
                case 2:
            {
                CGFloat height = 50;
                    /* 团购简介 动态取 */
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _groupBuyDetailTableView.deFrameWidth - 2*15, CGFLOAT_MAX)];
                label.text = self.productDetail.serviceDesc;
                label.backgroundColor = [UIColor clearColor];
                label.font = [UIFont systemFontOfSize:12];
                label.numberOfLines = 0;
                [label sizeToFit];
                
                height += label.deFrameHeight - 14;
                
                label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _groupBuyDetailTableView.deFrameWidth - 2*15, CGFLOAT_MAX)];
                label.text = self.productDetail.subject;
                label.font = [UIFont systemFontOfSize:14];
                label.backgroundColor = [UIColor clearColor];
                label.numberOfLines = 0;
                [label sizeToFit];
                
                height += label.deFrameHeight;
                
                return height;
            }
                case 3:
                    /* 售后服务 */
                    return Cell_Height_SalesService;
                default:
                    return 0;
            }
        case 1:
            /* 商家信息 */
            return Cell_Height_BusinessInfo;
        case 2:
            /* 会员价格 */
        {
            NSArray *array = [QCardDetailModel defaultCardDetailsModel];
            return [self bShowTheNormalPrice] ? QVIPCardRechargeCellHeight*(array.count+1): 0;
        }
        case 3:
        {
            /* 购买须知 */
            CGFloat marginLeft = 12;
            CGFloat marginTop = 15;
            
            NSString *note = NSString_No_Nil(self.productDetail.purchaseNote);
            CGSize size = [note sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(tableView.deFrameWidth - 2*marginLeft, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
            return size.height + 2*marginTop;
            
        }
            break;
        case 4:
            /* 评价*/
            return [QCommentsCell heightofCell:_commentList isExpand:NO];
         default:
            return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    switch (section)
    {
        case 2:
            return [self bShowTheNormalPrice] ? 11 : 0;
        default:
            return 11;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.deFrameWidth, [self tableView:tableView heightForHeaderInSection:section])];
    headerView.backgroundColor = [UIColor whiteColor];

    // 图标
    CGFloat marginLeft = 9;
    UIImageView *iconImageView = [[UIImageView alloc] initWithImage:IMAGEOF(@"business_icon")];
    iconImageView.center = headerView.center;
    iconImageView.deFrameLeft = marginLeft;
    [headerView addSubview:iconImageView];

    // 分割线
    UIView *separatorLineView = [[UIView alloc] initWithFrame: CGRectMake(10,
                                                                          headerView.deFrameHeight - 0.5,
                                                                          headerView.deFrameWidth - 10 * 2,
                                                                          0.5)];
    separatorLineView.backgroundColor = ColorLine;
    [headerView addSubview:separatorLineView];
    
    // 名称
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.textColor = ColorDarkGray;
    switch (section) {
        case 1: // 商家信息
            titleLabel.text = @"商家信息";
            [iconImageView setImage:IMAGEOF(@"business_icon")];
            break;
        case 2: // 会员价格
            titleLabel.text = @"会员洗车价格";
            [iconImageView setImage:IMAGEOF(@"vipPrice_icon")];
            separatorLineView.hidden = YES;
            break;
        case 3: // 购买须知
            titleLabel.text = @"购买须知";
            [iconImageView setImage:IMAGEOF(@"buyNotes_icon")];
            break;
        case 4: // 评价
        {
            titleLabel.text = @"评价";
            [iconImageView setImage:IMAGEOF(@"rate_icon")];
            // 星级
            ASStarRating *rateView = [[ASStarRating alloc] initWithFrame:CGRectMake(0, 0, 80, 13)];
            [rateView setScore:[self.productDetail.sumPoints doubleValue]];
            rateView.center = headerView.center;
            rateView.deFrameRight = tableView.deFrameWidth - 35;
            [headerView addSubview:rateView];
            rateView.hidden = (0 == self.commentList.count)? YES : NO;
            // 评分
            UILabel *scoreLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            scoreLabel.backgroundColor = [UIColor clearColor];
            scoreLabel.text = [self.productDetail.sumPoints stringValue];
            scoreLabel.font = [UIFont systemFontOfSize:13];
            scoreLabel.textColor = [QTools colorWithRGB:246 :172 :75];
            [scoreLabel sizeToFit];
            scoreLabel.center = headerView.center;
            scoreLabel.deFrameLeft = rateView.deFrameRight + 5;
            [headerView addSubview:scoreLabel];
            scoreLabel.hidden = (0 == self.commentList.count)? YES : NO;
        }
            break;
        default:
            return nil;
    }
    [titleLabel sizeToFit];
    titleLabel.center = headerView.center;
    titleLabel.deFrameLeft = iconImageView.deFrameRight + 5
    ;
    [headerView addSubview:titleLabel];
    
    //
    if (![tableView numberOfRowsInSection:section]) {
        return nil;
    }
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        // 基本信息
        if (indexPath.row == 0)
        {
            #pragma mark -- 展示图片cellView
            static NSString *CellIdentifierImage = @"Cell_Identifier_GroupBuy_Image";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierImage];
            if (nil == cell)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierImage];
            }
            
            [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.contentView.backgroundColor = [UIColor whiteColor];
            
            //数据源对接
            NSMutableArray *imageArray = [NSMutableArray arrayWithCapacity:0];
            pageSize = 0;
            for (int i = 0; i < self.productDetail.photoPaths.count; i++) {
                
                NSString *str = PICTUREHTTP(self.productDetail.photoPaths[i]);

                UIImageView *imageView = [[UIImageView alloc] init];
                [imageView sd_setImageWithURL:[NSURL URLWithString:str]
                         placeholderImage:[UIImage imageNamed:@"default_image"]
                                  options:SDWebImageRefreshCached];
                imageView.contentMode = UIViewContentModeScaleAspectFill;
                imageView.clipsToBounds = YES;
                [imageArray addObject:imageView];
                pageSize++;
            }
        
            ALScrollViewPaging *imageScrollView = [[ALScrollViewPaging alloc] initWithFrame:CGRectMake(0, 0, tableView.deFrameWidth, Cell_Height_Image)];
            self.imageScrollView = imageScrollView;
            [cell.contentView addSubview:imageScrollView];
            imageScrollView.pageControlOffsetTop = -20;
            imageScrollView.pageControlCurrentPageColor = UIColorFromRGB(0xc40000);
            imageScrollView.pageControlOtherPagesColor = UIColorFromRGB(0xffffff);
            [imageScrollView addPages:imageArray];
            [imageScrollView setHasPageControl:YES];
            if (!timer){
                timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self
                                                       selector:@selector(onTimer:) userInfo:nil repeats:YES];
            } else{
                // 开启定时器
                [timer setFireDate:[NSDate distantPast]];
            }
            
            return cell;
        }
        else if (indexPath.row == 1)
        {
            #pragma mark -- 购买cellView
            static NSString *CellIdentifierBuy = @"Cell_Identifier_GroupBuy_Buy";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierBuy];
            cell.contentView.backgroundColor = [UIColor whiteColor];
            
            if (nil == cell)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierBuy];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            
            UIView *floadtingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.deFrameWidth, [self tableView:tableView heightForRowAtIndexPath:indexPath])];
            floadtingView.backgroundColor = [UIColor whiteColor];
            //暂时注释,浮动形式后面再加上去
            [self.floatingView removeFromSuperview];
            self.floatingView = nil;
            self.floatingView = floadtingView;
            
#pragma mark -- 购买UIView
            UIView *buyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.deFrameWidth, Cell_Height_Buy)];
            buyView.backgroundColor = [UIColor whiteColor];
            UILabel *buyLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 20, 0, 0)];
            buyLabel.backgroundColor = [UIColor clearColor];
            
            NSString *price = @"0";
            
            if([QUser sharedQUser].isVIP && self.productDetail.usrMbrPrice != nil)
            {
                price = [[self.productDetail.usrMbrPrice objectForKey:@"memberUnitPrice"] stringValue];
            }
            else
            {
                price = [[self.productDetail.productBid objectForKey:@"bidPrice"] stringValue];
            }
            
            if (!price || [price isEqualToString:@""]) price = @"0";
            
            NSString *unit = @"元   ";
            NSString *retailPrice = [NSString stringWithFormat:@"%@",NSString_No_Nil([self.productDetail.price stringValue])];
            NSString *text = [NSString stringWithFormat:@"%@%@%@", price, unit, retailPrice];
            NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text
                                                 attributes:@{NSStrikethroughStyleAttributeName: @(NSUnderlineStyleNone)}];
            [string addAttributes:@{NSForegroundColorAttributeName: ColorTheme,
                                    NSFontAttributeName: [UIFont systemFontOfSize:20]} range:[text rangeOfString:price]];
            [string addAttributes:@{NSForegroundColorAttributeName: ColorTheme,
                                    NSFontAttributeName: [UIFont systemFontOfSize:14]} range:[text rangeOfString:unit]];
            [string addAttributes:@{NSStrikethroughStyleAttributeName:@(NSUnderlineStyleSingle),
                                    NSForegroundColorAttributeName: [QTools colorWithRGB:157 :157 :157],
                                    NSFontAttributeName: [UIFont systemFontOfSize:14]} range:[text rangeOfString:retailPrice]];
            buyLabel.textColor = [QTools colorWithRGB:105 :105 :105];
            buyLabel.font = [UIFont systemFontOfSize:15];
            buyLabel.attributedText = string;
            [buyLabel sizeToFit];
            [buyView addSubview:buyLabel];
            
            UIButton *buyButton = [[UIButton alloc] init];
            buyButton.deFrameSize = CGSizeMake(122, 39);
            buyButton.center = buyLabel.center;
            buyButton.deFrameRight = tableView.deFrameWidth - 12;
            
            buyButton.titleLabel.font = [UIFont systemFontOfSize:16];
            [buyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [buyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
            [buyButton setTitle:@"立即购买" forState:UIControlStateNormal];
            [buyButton setBackgroundImage:[QTools createImageWithColor:ColorTheme] forState:UIControlStateNormal];
            buyButton.layer.cornerRadius = 5;
            buyButton.layer.masksToBounds = YES;
            [buyButton addTarget:self action:@selector(buyButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [buyView addSubview:buyButton];
            UIView *separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(0, buyView.deFrameHeight - .5, buyView.deFrameWidth, 0.5)];
            separatorLineView.backgroundColor = [QTools colorWithRGB:221 :221 :221];
            [buyView addSubview:separatorLineView];
            [floadtingView addSubview:buyView];
            
#pragma mark -- 充值 UIView
            UIView *rechargeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.deFrameWidth, Cell_Height_Buy)];
            rechargeView.backgroundColor = [UIColor whiteColor];
            UILabel *lowPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 20, 0, 0)];
            lowPriceLabel.backgroundColor = [UIColor clearColor];
            lowPriceLabel.font = [UIFont systemFontOfSize:16];
            lowPriceLabel.textColor = [QTools colorWithRGB:255 :102 :0];
            lowPriceLabel.text = self.productDetail.minMemberPrice;
            [lowPriceLabel sizeToFit];
            [rechargeView addSubview:lowPriceLabel];
/*
            UILabel *rechargeLabel = [[UILabel alloc] initWithFrame:CGRectMake(lowPriceLabel.deFrameRight + 10, 25, 0, 0)];
            rechargeLabel.lineBreakMode = NSLineBreakByWordWrapping;
            rechargeLabel.numberOfLines = 0;
            rechargeLabel.text = @"会员洗车价";
            rechargeLabel.font = [UIFont systemFontOfSize:16];
            rechargeLabel.clipsToBounds = YES;
            rechargeLabel.layer.cornerRadius = 3;
            rechargeLabel.textColor = [QTools colorWithRGB:196 :0 :0];
            [rechargeLabel sizeToFit];
            [rechargeView addSubview:rechargeLabel];
*/
            if ([QUser sharedQUser].isVIP)
            {
                UILabel *lbPrice = [[UILabel alloc]initWithFrame:CGRectMake(15, 5, 160, 30)];
                lbPrice.text = [NSString stringWithFormat:@"活动价：%.2f元",[[_productDetail.productBid objectForKey:@"bidPrice"] floatValue] ];
                lbPrice.font = [UIFont systemFontOfSize:15.f];
                lbPrice.textAlignment = NSTextAlignmentLeft;
                lbPrice.backgroundColor = [UIColor clearColor];
                lbPrice.textColor = [UIColor grayColor];
                [rechargeView addSubview:lbPrice];
            }

            UIButton *rechargeButton = [[UIButton alloc] init];
            rechargeButton.deFrameSize = CGSizeMake(122, 39);
            rechargeButton.center = lowPriceLabel.center;
            rechargeButton.deFrameRight = tableView.deFrameWidth - 12;
            
            rechargeButton.titleLabel.font = [UIFont systemFontOfSize:15];
            [rechargeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [rechargeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
            
            if ([QUser sharedQUser].isVIP)
            {
                [rechargeButton setTitle:@"活动价购买" forState:UIControlStateNormal];
            }
            else
            {
                [rechargeButton setTitle:@"购买洗车卡" forState:UIControlStateNormal];
            }
            [rechargeButton setBackgroundImage:[QTools createImageWithColor:UIColorFromRGB(0xff6600)] forState:UIControlStateNormal];
            [rechargeButton addTarget:self action:@selector(rechargeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            rechargeButton.layer.cornerRadius = 5;
            rechargeButton.layer.masksToBounds = YES;
            [rechargeView addSubview:rechargeButton];
            
            if ([self bShowTheNormalPrice]) {
                [floadtingView addSubview:rechargeView];
                rechargeView.deFrameTop = buyView.deFrameBottom;
                separatorLineView.deFrameTop = rechargeView.deFrameHeight - .5;
                [rechargeView addSubview:separatorLineView];
            }
            
            [cell.contentView addSubview:floadtingView];
            return cell;
        }
        else if (indexPath.row == 2)
        {
            #pragma mark -- 团购简介cellView
            static NSString *CellIdentifierIntroduction = @"Cell_Identifier_GroupBuy_Introduction";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierIntroduction];
            if (nil == cell)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifierIntroduction];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            cell.contentView.backgroundColor = [UIColor whiteColor];
            [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            
            cell.textLabel.text = self.productDetail.subject;
            cell.textLabel.backgroundColor = [UIColor clearColor];
            cell.textLabel.font = [UIFont systemFontOfSize:16];
            cell.textLabel.textColor = ColorDarkGray;
            cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
            cell.textLabel.numberOfLines = 0;
            
            cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
            cell.detailTextLabel.backgroundColor = [UIColor clearColor];
            cell.detailTextLabel.textColor = [QTools colorWithRGB:156 :156 :156];
            cell.detailTextLabel.text = self.productDetail.serviceDesc;
            cell.detailTextLabel.numberOfLines = 0;
            
            UIView *separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(10, [self tableView:tableView heightForRowAtIndexPath:indexPath] - 0.5, tableView.deFrameWidth - 10 * 2, 0.5)];
            separatorLineView.backgroundColor = ColorLine;
            [cell.contentView addSubview:separatorLineView];
            
            
            return cell;
        }
        else if (indexPath.row == 3) {
            #pragma mark -- 售后服务&销售情况cellView
            static NSString *CellIdentifierSalesService = @"Cell_Identifier_GroupBuy_SalesService";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierSalesService];
            if (nil == cell)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierSalesService];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.contentView.backgroundColor = [UIColor whiteColor];
            }
            [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            
            CGFloat originX = 20;
            CGFloat originY = 15;
            NSString *imageName;
            
            //未消费随时退款
            BOOL isRefundEnable = (1 == [self.productDetail.returnNotSpending intValue]);
            imageName = isRefundEnable ? @"icon_refund" : @"icon_refund_n";
            UIImageView *imageView = [[UIImageView alloc] initWithImage:IMAGEOF(imageName)];
            imageView.deFrameLeft = originX;
            imageView.deFrameTop = originY;
            [cell.contentView addSubview:imageView];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(imageView.deFrameRight + 10, originY, 100, 15)];
            label.backgroundColor = [UIColor clearColor];
            label.font = [UIFont systemFontOfSize:11];
            label.textColor = isRefundEnable ? [QTools colorWithRGB:144 :185 :81] : [QTools colorWithRGB:156 :156 :156];
            label.text = isRefundEnable ? @"支持随时退" : @"不支持过期退";
            [cell.contentView addSubview:label];
            
            originY = imageView.deFrameBottom + 10;
            //未消费随时退款
            isRefundEnable = (1 == [self.productDetail.returnOverdue intValue]);
            imageName = isRefundEnable ? @"icon_refund" : @"icon_refund_n";
            imageView = [[UIImageView alloc] initWithImage:IMAGEOF(imageName)];
            imageView.deFrameLeft = originX;
            imageView.deFrameTop = originY;
            [cell.contentView addSubview:imageView];
            label = [[UILabel alloc] initWithFrame:CGRectMake(imageView.deFrameRight + 10, originY, 100, 15)];
            label.backgroundColor = [UIColor clearColor];
            label.font = [UIFont systemFontOfSize:11];
            label.textColor = isRefundEnable ? [QTools colorWithRGB:144 :185 :81] : [QTools colorWithRGB:156 :156 :156];
            label.text = isRefundEnable ? @"支持过期退" : @"不支持过期退";
            [cell.contentView addSubview:label];
            
            originX = (SCREEN_SIZE_WIDTH - 2*15)/2;
            originY = 15;
            //销售件数
            imageName = @"icon_sold_num";
            imageView = [[UIImageView alloc] initWithImage:IMAGEOF(imageName)];
            imageView.deFrameLeft = originX;
            imageView.deFrameTop = originY;
            [cell.contentView addSubview:imageView];
            label = [[UILabel alloc] initWithFrame:CGRectMake(imageView.deFrameRight + 10, originY, 100, 15)];
            label.backgroundColor = [UIColor clearColor];
            label.font = [UIFont systemFontOfSize:11];
            label.textColor = [QTools colorWithRGB:156 :156 :156];
            label.text = [NSString stringWithFormat:@"销售%d", [self.productDetail.salesVolume intValue]];
            [cell.contentView addSubview:label];
 
            originY = imageView.deFrameBottom + 10;
            //有效期
            imageName = @"icon_sale_date";
            imageView = [[UIImageView alloc] initWithImage:IMAGEOF(imageName)];
            imageView.deFrameLeft = originX;
            imageView.deFrameTop = originY;
            [cell.contentView addSubview:imageView];
            label = [[UILabel alloc] initWithFrame:CGRectMake(imageView.deFrameRight + 10, originY, 100, 15)];
            label.backgroundColor = [UIColor clearColor];
            label.font = [UIFont systemFontOfSize:11];
            label.textColor = [QTools colorWithRGB:156 :156 :156];
            [cell.contentView addSubview:label];
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSTimeInterval dateOutTime = [NSDate dateWithTimeIntervalSince1970:([self.productDetail.endDate unsignedLongLongValue]/1000)].timeIntervalSinceNow;
            int day = dateOutTime/(3600*24);
            int hour = (dateOutTime - day*3600*24)/3600;
            int mint = (dateOutTime - day*3600*24 - hour*3600)/60;
            if (day >= 0 && hour >= 0 && mint >= 0) {
                label.text = [NSString stringWithFormat:@"%d天%d小时%d分", day, hour, mint];
            }
            else {
                label.text = @"已过期";
            }

            return cell;
        }
    }

    else if (indexPath.section == 1)
    {
        #pragma mark -- 商家信息 cellView
        static NSString *CellIdentifierBusinessInfo = @"Cell_Identifier_GroupBuy_BusinessInfo";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierBusinessInfo];
        if (nil == cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierBusinessInfo];
        }
        cell.contentView.backgroundColor = [UIColor whiteColor];
        
        if (nil != cell)
        {
            [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            CGFloat marginLeft = 12;
            UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(marginLeft, 12, tableView.deFrameWidth - marginLeft - 75, 20)]; // 距右75
            nameLabel.backgroundColor = [UIColor clearColor];
            nameLabel.text = self.productCompany.companyName;
            nameLabel.font = [UIFont systemFontOfSize:15];
            nameLabel.textColor = [QTools colorWithRGB:51 :51 :51];
            [cell.contentView addSubview:nameLabel];
            
            UIImageView *locationIconImageView = [[UIImageView alloc] initWithImage:IMAGEOF(@"location_cell")];
            locationIconImageView.deFrameOrigin = CGPointMake(marginLeft, 43);
            [cell.contentView addSubview:locationIconImageView];
            
            UILabel *addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(locationIconImageView.deFrameRight + 5, 40, tableView.deFrameWidth - marginLeft - 75, 20)]; // 距右75
            addressLabel.backgroundColor = [UIColor clearColor];
            addressLabel.text = self.productCompany.detailAddress;;
            addressLabel.font = [UIFont systemFontOfSize:12];
            addressLabel.textColor = [QTools colorWithRGB:153 :153 :153];
            [cell.contentView addSubview:addressLabel];
            
            UIView *verticalLineView = [[UIView alloc] initWithFrame:CGRectZero];
            verticalLineView.deFrameRight = tableView.deFrameWidth - 62;
            verticalLineView.deFrameTop = 15;
            verticalLineView.deFrameSize = CGSizeMake(1, Cell_Height_BusinessInfo - 2*15);
            verticalLineView.backgroundColor = ColorLine;
            [cell.contentView addSubview:verticalLineView];
            
            UIImageView *phoneIconImageView = [[UIImageView alloc] initWithImage:IMAGEOF(@"phone_businessInfo_cell")];
            phoneIconImageView.deFrameRight = tableView.deFrameWidth - 20;
            phoneIconImageView.deFrameTop = (Cell_Height_BusinessInfo - phoneIconImageView.deFrameHeight)/2;
            UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(phoneIconImageViewTapped:)];
            phoneIconImageView.userInteractionEnabled = YES;
            [phoneIconImageView addGestureRecognizer:gesture];
            [cell.contentView addSubview:phoneIconImageView];
        }
        return cell;
    }
    else if (indexPath.section == 2)
    {
        #pragma mark -- 会员价格 cellView
        static NSString *CellIdentifierVIPPrice = @"Cell_Identifier_GroupBuy_VIPPrice";
        
        QGroupBuyDetailVIPPriceCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierVIPPrice];
        if (nil == cell) {
            cell = [[QGroupBuyDetailVIPPriceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierVIPPrice];
            cell.delegate = self;
        }
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.listTableView.deFrameHeight = [self tableView:tableView heightForRowAtIndexPath:indexPath];
        [cell.listTableView reloadData];
        return cell;
    }
    else if (indexPath.section == 3)
    {
        #pragma mark -- 购买须知
        static NSString *CellIdentifierBuyNotes = @"Cell_Identifier_GroupBuy_BuyNotes";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierBuyNotes];
        if (nil == cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierBuyNotes];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.contentView.backgroundColor = [UIColor whiteColor];
        }
        
        [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        CGFloat marginLeft = 12;
        CGFloat marginTop = 15;
        
        UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(marginLeft, marginTop, tableView.deFrameWidth - marginLeft * 2, 0)];
        contentLabel.backgroundColor = [UIColor clearColor];
        contentLabel.text = NSString_No_Nil(self.productDetail.purchaseNote);
        contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
        contentLabel.numberOfLines = 0;
        contentLabel.font = [UIFont systemFontOfSize:12];
        contentLabel.textColor = [QTools colorWithRGB:78 :78 :78];
        [contentLabel sizeToFit];
        [cell.contentView addSubview:contentLabel];
        
        return cell;
    }
    else if (indexPath.section == 4)
    {
        #pragma mark -- 评价 cellView
        static NSString *CellIdentifierPhone = @"Comments";
        QCommentsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierPhone];
        if (nil == cell)
        {
            cell = [[QCommentsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierPhone];
            cell.delegate = self;
            cell.contentView.backgroundColor = [UIColor clearColor];
        }
        
        cell.commentsArr = _commentList;
        return cell;
    }
    
    static NSString *CellIdentifier = @"Cell_Identifier_BusinessDetail";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
        cell.contentView.backgroundColor = [UIColor clearColor];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 1: // 商家详情
            [QViewController gotoPage:@"QBusinessDetailPage"
                            withParam:[NSDictionary dictionaryWithObjectsAndKeys:self.productDetail.companyId, @"companyID", nil]];
            break;
        case 2: //会员价格
            ;
            break;
        case 4: // 套餐图文详情
            if (indexPath.row == 1) {
                [QViewController gotoPage:@"QComboDetail" withParam:nil];
            }
            break;
        default:
            break;
    }
}

#pragma mark - QCommentsCellDelegate
- (void)onMoreComment
{
    [QViewController gotoPage:@"QAppraisalPage" withParam:[NSDictionary dictionaryWithObjectsAndKeys:
                                                           [NSNumber numberWithInt:kProductCommentType], @"commentType",
                                                           self.productDetail.companyId, @"companyId",
                                                           self.productDetail.productId, @"productId", nil]];
}

#pragma mark - QGroupBuyDetailVIPPriceCellDelegate

- (void)QGroupBuyDetailVIPPriceCell:(QGroupBuyDetailVIPPriceCell *)categoryView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [QViewController gotoPage:@"QNoVipChong" withParam:nil];
}

- (void)reloadVIPPriceCell
{
    [_groupBuyDetailTableView reloadData];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y > Cell_Height_Image) {
        if (self.floatingView.superview != self.view) {
            self.floatingSuperView = self.floatingView.superview;
            [self.view addSubview:self.floatingView];
            self.floatingView.alpha = .95;
        }
        [[self.floatingView superview] bringSubviewToFront:self.floatingView];
    } else {
        if (self.floatingView.superview == self.view) {
            [self.floatingSuperView addSubview:self.floatingView];
            self.floatingView.alpha = 1;
        }
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        NSString *num = [[NSString alloc] initWithFormat:@"tel://%@", self.productCompany.companyTel];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:num]];
    }
}

@end
