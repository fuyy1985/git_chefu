//
//  QVIPCardRecharge.m
//  HRClient
//
//  Created by ekoo on 14/12/15.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QVIPCardRecharge.h"
#import "QVIPCardRechargeCell.h"
#import "QViewController.h"

static BOOL isAgree;
static BOOL isSee;
@interface QVIPCardRecharge ()
{
    UIButton *selectBtn;
    UIImageView *sureImageView;
    UIButton *rechargeBtn;
    UIScrollView *scrollView;
    UIScrollView *scrollView1;
    UIImageView *temImageView;
}

@end
@implementation QVIPCardRecharge

- (NSString *)title{
    return @"会员洗车卡充值";
}

- (UIView *)viewWithFrame:(CGRect)frame{
    if ([super viewWithFrame:frame]) {
        _view.backgroundColor = [QTools colorWithRGB:240 :239 :237];
        isAgree = NO;
        isSee = NO;
        CGFloat cardBeforeW = 15;
        CGFloat cardTopH = 15;
        CGFloat cardW = frame.size.width - 2 * cardBeforeW;
        CGFloat cardH = 20;
        
        scrollView1 = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        scrollView1.backgroundColor =[QTools colorWithRGB:240 :239 :237];
        [_view addSubview:scrollView1];
        
        UILabel *cardStyleLabel = [[UILabel alloc] initWithFrame:CGRectMake(cardBeforeW, cardTopH, cardW, cardH)];
        cardStyleLabel.text = @"会员洗车卡类型：经典卡";
        cardStyleLabel.textColor = UIColorFromRGB(0xc40000);
        cardStyleLabel.font = [UIFont boldSystemFontOfSize:18];
        [scrollView1 addSubview:cardStyleLabel];
        
        CGFloat balanceBeforeW = cardBeforeW;
        CGFloat balanceTopH = cardStyleLabel.deFrameBottom + 10;
        CGFloat balanceW = frame.size.width - 2 * balanceBeforeW;
        CGFloat balanceH = 20;
        UILabel *balanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(balanceBeforeW, balanceTopH, balanceW, balanceH)];
        balanceLabel.text = @"您的会员洗车卡余额：￥50";
        balanceLabel.textColor = [QTools colorWithRGB:85 :85 :85];
        balanceLabel.font = [UIFont systemFontOfSize:18];
        [scrollView1 addSubview:balanceLabel];
        
//        表
        CGFloat disBeforeW = cardBeforeW;
        CGFloat disTopH = balanceLabel.deFrameBottom + 15;
        CGFloat disW = frame.size.width - 2 * disBeforeW;
        CGFloat disH = 215;
        UIView *displayView = [[UIView alloc] initWithFrame:CGRectMake(disBeforeW, disTopH, disW, disH)];
//        displayView.backgroundColor = [UIColor cyanColor];
        [scrollView1 addSubview:displayView];
        
        UITableView *listTableView = [[UITableView alloc] initWithFrame:displayView.bounds style:UITableViewStylePlain];
        listTableView.dataSource = self;
        listTableView.delegate = self;
        listTableView.scrollEnabled = NO;
//        listTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [displayView addSubview:listTableView];
        
        //对号的一行往下
        CGFloat agreeBeforeW = 10.f;
        CGFloat agreeTopH = displayView.deFrameBottom + 15;
        CGFloat agreeW = 35;
        CGFloat agreeH = 35;
        
        selectBtn = [[UIButton alloc] initWithFrame:CGRectMake(agreeBeforeW, agreeTopH, agreeW, agreeH)];
        [selectBtn setImage:[UIImage imageNamed:@"icon_agree_unselected"] forState:UIControlStateNormal];
        [selectBtn setImage:[UIImage imageNamed:@"icon_agree_selected"] forState:UIControlStateSelected];
        [selectBtn addTarget:self action:@selector(sureToAgree:) forControlEvents:UIControlEventTouchUpInside];
        selectBtn.selected = YES;
        [scrollView1 addSubview:selectBtn];
        
        CGFloat explainBeforeW = selectBtn.deFrameRight;
        CGFloat explainTopH = agreeTopH;
        CGFloat explainW = scrollView1.deFrameWidth - 2*explainBeforeW;
        CGFloat explainH = agreeH;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(explainBeforeW, explainTopH, explainW+20, explainH)];
        label.textColor = [QTools colorWithRGB:80 :80 :80];
        label.font = [UIFont systemFontOfSize:12];
        //属性文字
        NSString *text = @"我已阅读并同意会员洗车卡充值协议";
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSStrikethroughStyleAttributeName: @(NSUnderlineStyleNone)}];
        [string addAttributes:@{NSUnderlineStyleAttributeName:@(NSLineBreakByClipping)} range:[text rangeOfString:@"会员洗车充值协议"]];
        [string addAttribute:NSForegroundColorAttributeName value:ColorTheme range:[text rangeOfString:@"会员洗车充值协议"]];
        label.attributedText = string;
        
        label.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(agreeVipDelegate:)];
        [label addGestureRecognizer:tap1];
        [scrollView1 addSubview:label];
        
        CGFloat rechargeW = scrollView1.deFrameWidth - 2*15;
        CGFloat rechargeH = 35;
        CGFloat rechargeBeforeW = 15.f;
        CGFloat rechargeTopH = selectBtn.deFrameBottom + 10;
        rechargeBtn = [[UIButton alloc] initWithFrame:CGRectMake(rechargeBeforeW, rechargeTopH, rechargeW, rechargeH)];
        [rechargeBtn setTitle:@"充值成为洗车会员" forState:UIControlStateNormal];
        [rechargeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [rechargeBtn setBackgroundImage:[QTools createImageWithColor:ColorTheme] forState:UIControlStateNormal];
        rechargeBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        rechargeBtn.layer.masksToBounds = YES;
        rechargeBtn.layer.cornerRadius = 4.f;
        [rechargeBtn addTarget:self action:@selector(gotoRechargeVip) forControlEvents:UIControlEventTouchUpInside];
        [scrollView1 addSubview:rechargeBtn];
    }
    return _view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 9;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 35.8;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *listID = @"list_ID";
    QVIPCardRechargeCell * cell = [tableView dequeueReusableCellWithIdentifier:listID];
    if (cell == nil) {
        cell = [[QVIPCardRechargeCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:listID];
        
    }
    cell.agreeImageView.image = [UIImage imageNamed:@"choiceno02.png"];
    if (indexPath.row == 0) {
        cell.agreeImageView.image = nil;
        cell.userInteractionEnabled = NO;
    }else if(indexPath.row == 1){
        cell.agreeImageView.image = [UIImage imageNamed:@"choiceyes01.png"];
        temImageView = cell.agreeImageView;
    }
    NSArray *arr = @[@{@"icon":@"choiceno02.png",@"style":@"体验卡",@"card":@"10/次",@"suv":@"10/次",@"price":@"￥100"},
                     @{@"icon":@"choiceno02.png",@"style":@"经典卡",@"card":@"10/次",@"suv":@"10/次",@"price":@"￥100"},
                     @{@"icon":@"choiceno02.png",@"style":@"金卡",@"card":@"10/次",@"suv":@"10/次",@"price":@"￥100"},
                     @{@"icon":@"choiceno02.png",@"style":@"白金卡",@"card":@"10/次",@"suv":@"10/次",@"price":@"￥100"},
                     @{@"icon":@"choiceno02.png",@"style":@"钻石年卡",@"card":@"10/次",@"suv":@"10/次",@"price":@"￥100"},
                     @{@"icon":@"choiceno02.png",@"style":@"钻石年卡",@"card":@"10/次",@"suv":@"10/次",@"price":@"￥100"},
                     @{@"icon":@"choiceno02.png",@"style":@"钻石年卡",@"card":@"10/次",@"suv":@"10/次",@"price":@"￥100"},
                     @{@"icon":@"choiceno02.png",@"style":@"钻石年卡",@"card":@"10/次",@"suv":@"10/次",@"price":@"￥100"}];
    [cell configureModelForCell:arr andIndexPath:indexPath];
    return cell;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    temImageView.image = [UIImage imageNamed:@"choiceno02.png"];
    QVIPCardRechargeCell *cell = (QVIPCardRechargeCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.agreeImageView.image = IMAGEOF(@"choiceyes01.png");
    temImageView = cell.agreeImageView;
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    QVIPCardRechargeCell *deSelectCell = (QVIPCardRechargeCell*)[tableView cellForRowAtIndexPath:indexPath];
    deSelectCell.sureImageView.image = nil;
}

- (void)gotoRechargeVip{
    [QViewController gotoPage:@"QConfirmOrderPage" withParam:nil];
}

- (void)sureToAgree:(UIGestureRecognizer *)sender{
    selectBtn.selected = !selectBtn.selected;
    rechargeBtn.enabled = selectBtn.selected;
}

- (void)agreeVipDelegate:(UIGestureRecognizer *)sender
{
    [QViewController gotoPage:@"QAgreementPage" withParam:[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:2], @"agreementType", nil]];
}




@end
