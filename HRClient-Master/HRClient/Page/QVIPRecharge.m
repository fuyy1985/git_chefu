//
//  QVIPRecharge.m
//  HRClient
//
//  Created by ekoo on 14/12/8.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QVIPRecharge.h"
#import "QViewController.h"
#import "QVIPRechargeCell.h"
#import "QCardDetailModel.h"

#define IS_ENOUGH  YES


static NSIndexPath *lastIndexPath;
static BOOL isClick;
@interface QVIPRecharge ()
{
    CGFloat blank;
    NSMutableArray *array1;
    NSMutableArray *array;
    NSArray *arr;
    CGFloat cellH;
    UIView *view3;
    UIScrollView *scrollView;
    UIImageView *selectImageView;
    UIImageView *imageLabel;
    UIView *view5;
    UIView *view2;
    UIImageView *temImageView;
    
    QCardDetailModel *_cardModel;
}
@property (nonatomic)UITableView *VIPTableView;
@end

@implementation QVIPRecharge


- (NSString*)title //NOTE:页面标题
{
    return @"洗车会员卡充值";
}

- (void)setActiveWithParams:(NSDictionary *)params
{
    _cardModel = [params objectForKey:@"QCardDetailModel"];
}

- (UIView *)viewWithFrame:(CGRect)frame{
    if ([super viewWithFrame:frame]) {
        blank = 10;
        cellH = 50;
        isClick = NO;
        array1 = [NSMutableArray arrayWithCapacity:0];
        array=[[NSMutableArray alloc]initWithObjects:@"yuan01.gif",@"yuan02.gif",@"yuan02.gif",@"yuan02.gif", nil];
        arr = @[@{@"icon":@"pic01.png",@"title":@"银行卡支付",@"detail":@"支持储蓄卡信用卡，无需开通网银"},
                         @{@"icon":@"pic02.png",@"title":@"支付宝支付",@"detail":@"推荐安装支付宝客户端的用户"},
                         @{@"icon":@"pic03.png",@"title":@"微信支付",@"detail":@"推荐安装微信5.0及以上版本的用户"},
                         @{@"icon":@"pic04.png",@"title":@"财付通支付",@"detail":@"支持银行卡和财付通账户支付"}];
        _view.backgroundColor = [QTools colorWithRGB:240 :239 :237];
        
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0, frame.size.width, frame.size.height)];
        [_view addSubview:scrollView];
        CGFloat h = 40;
        UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_SIZE_WIDTH, h)];
        UILabel *rechargeLabel = [[UILabel alloc] initWithFrame:CGRectMake(blank, 0, 160, view1.frame.size.height)];
        rechargeLabel.text = [NSString stringWithFormat:@"充值金额:%d元",[_cardModel.amount intValue]];
        rechargeLabel.font = [UIFont systemFontOfSize:15];
        rechargeLabel.textColor = [QTools colorWithRGB:86 :86 :86];
        
        if ([QUser sharedQUser].isVIP) {
        UILabel *balanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(rechargeLabel.deFrameRight, 0, frame.size.width - rechargeLabel.deFrameRight - blank, rechargeLabel.frame.size.height)];
        balanceLabel.text = @"账户余额:10元"; //TODO
        balanceLabel.textAlignment = NSTextAlignmentRight;
        balanceLabel.textColor = [QTools colorWithRGB:86 :86 :86];
        [view1 addSubview:balanceLabel];
        }
        [view1 addSubview:rechargeLabel];
        [scrollView addSubview:view1];
        
        UILabel *lineLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(0, view1.deFrameBottom + 0.5, SCREEN_SIZE_WIDTH, 0.5)];
        lineLabel1.backgroundColor = [QTools colorWithRGB:212 :212 :212];
        [scrollView addSubview:lineLabel1];
        
        UILabel *styLable = [[UILabel alloc] initWithFrame:CGRectMake(0, lineLabel1.deFrameBottom, SCREEN_SIZE_WIDTH, h)];
        styLable.text = [NSString stringWithFormat:@"会员洗车类型     %@",_cardModel.memberTypeName];
        styLable.textColor = UIColorFromRGB(0xc40000);
        styLable.textAlignment = NSTextAlignmentCenter;
        styLable.backgroundColor = [QTools colorWithRGB:255 :255 :255];
        [scrollView addSubview:styLable];
        
        UILabel *lineLable2 = [[UILabel alloc] initWithFrame:CGRectMake(0, styLable.deFrameBottom + 0.5, SCREEN_SIZE_WIDTH, 0.5)];
        lineLable2.backgroundColor = [QTools colorWithRGB:212 :212 :212];
        [scrollView addSubview:lineLable2];
        
        view2 = [[UIView alloc] initWithFrame:CGRectMake(0, lineLable2.deFrameBottom + 20, SCREEN_SIZE_WIDTH, 80)];
        view2.backgroundColor = [QTools colorWithRGB:255 :255 :255];
        [scrollView addSubview:view2];
        
        UILabel *balanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,0, 120, h)];
        balanceLabel.text = @"车夫账户余额：";
        balanceLabel.textColor = [QTools colorWithRGB:86 :86 :86];
        view2.userInteractionEnabled = YES;
        [view2 addSubview:balanceLabel];
        
        CGFloat imageW = 20;
        CGFloat imageH = 20;
        imageLabel = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width - imageW - blank, 10, imageW, imageH)];
        imageLabel.image = [UIImage imageNamed:@"形状 3.png"];
        imageLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(swicthTheState:)];
        [view2 addGestureRecognizer:tap];
        [view2 addSubview:imageLabel];
        
        selectImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 10, 10)];
        selectImageView.image = [UIImage imageNamed:@"形状 4.png"];
        [imageLabel addSubview:selectImageView];
        
        CGFloat moneyW = 60;
        UILabel *moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width - blank - imageW - moneyW, 0, moneyW, h)];
        moneyLabel.text = @"0.00元";
        moneyLabel.textColor = UIColorFromRGB(0xc40000);
        [view2 addSubview:moneyLabel];
        
        UILabel *lineLabel3 =[[UILabel alloc] initWithFrame:CGRectMake(0, balanceLabel.deFrameBottom + 0.5, frame.size.width, 0.5)];
        lineLabel3.backgroundColor = [QTools colorWithRGB:212 :212 :212];
        [view2 addSubview:lineLabel3];
        
        UILabel *needLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, lineLabel3.deFrameBottom, 100, h)];
        needLabel.text = @"还需支付";
        needLabel.textColor = [QTools colorWithRGB:86 :86 :86];
        [view2 addSubview:needLabel];
        
        UILabel *nmLabel = [[UILabel alloc] initWithFrame:CGRectMake(needLabel.deFrameRight + blank, lineLabel3.deFrameBottom, frame.size.width - 2 * blank - needLabel.deFrameRight, h)];
        nmLabel.text = @"多少元";
        nmLabel.textAlignment = NSTextAlignmentRight;
        nmLabel.textColor = [QTools colorWithRGB:86 :86 :86];
        [view2 addSubview:nmLabel];
        
//       用账户余额
        
        view3 = [[UIView alloc] initWithFrame:CGRectMake(0, view2.deFrameBottom + 10, frame.size.width, arr.count*cellH + 30 + 40 + blank)];
        view3.backgroundColor = [QTools colorWithRGB:240 :239 :237];
        [scrollView addSubview:view3];
        UILabel *keyLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 80, h)];
        keyLabel.text = @"支付密码";
            keyLabel.textColor = [QTools colorWithRGB:86 :86 :86];
        [view3 addSubview:keyLabel];
        
        UITextField *keyTextField = [[UITextField alloc] initWithFrame:CGRectMake(keyLabel.deFrameRight + 10, 0, frame.size.width - keyLabel.deFrameRight - 2 * blank, h)];
        keyTextField.placeholder = @"请输入支付密码";
        keyTextField.borderStyle = UITextBorderStyleRoundedRect;
        [view3 addSubview:keyTextField];
        
        CGFloat keyBtnW = 70;
        UIButton *keyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        keyBtn.frame = CGRectMake(keyTextField.deFrameRight - keyBtnW, keyTextField.deFrameBottom + 10, keyBtnW, 30);
        keyBtn.backgroundColor = UIColorFromRGB(0xc40000);
        [keyBtn setTitle:@"忘记密码?" forState:UIControlStateNormal];
        keyBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        keyBtn.layer.masksToBounds = YES;
        keyBtn.layer.cornerRadius  = 2.0;
        [keyBtn addTarget:self action:@selector(forgetKey) forControlEvents:UIControlEventTouchUpInside];
        [view3 addSubview:keyBtn];
        
        UIButton *sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        sureBtn.frame = CGRectMake(10, keyBtn.deFrameBottom + 10, frame.size.width - 2 * blank, h);
        [sureBtn setTitle:@"确认支付" forState:UIControlStateNormal];
        sureBtn.backgroundColor = UIColorFromRGB(0xc40000);
        sureBtn.layer.masksToBounds = YES;
        sureBtn.layer.cornerRadius = 4.0;
        [sureBtn addTarget:self action:@selector(sureToUseAccount) forControlEvents:UIControlEventTouchUpInside];
        [view3 addSubview:sureBtn];
//            用第三方
        view5 = [[UIView alloc] initWithFrame:CGRectMake(0, view2.deFrameBottom + 10, frame.size.width, arr.count*cellH + 30 + 40 + blank)];
        view5.backgroundColor = [QTools colorWithRGB:240 :239 :237];
        [scrollView addSubview:view5];
        _VIPTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, arr.count*cellH + 30) style:UITableViewStylePlain];
        _VIPTableView.dataSource = self;
        _VIPTableView.delegate = self;
        [view5 addSubview:_VIPTableView];
            
        UIButton *sureBtn1 = [UIButton buttonWithType:UIButtonTypeCustom];
        sureBtn1.frame = CGRectMake(blank, _VIPTableView.deFrameBottom + blank, frame.size.width - 2 * blank, 40);
        [sureBtn1 setTitle:@"确认支付" forState:UIControlStateNormal];
        sureBtn1.backgroundColor = UIColorFromRGB(0xc40000);
        [sureBtn1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        sureBtn1.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        sureBtn1.layer.masksToBounds = YES;
        sureBtn1.layer.cornerRadius = 2.0;
        [sureBtn1 addTarget:self action:@selector(sureToRecharge) forControlEvents:UIControlEventTouchUpInside];
        [view5 addSubview:sureBtn1];
        }
    scrollView.contentSize = CGSizeMake(frame.size.width,view3.deFrameBottom + 40);
    if (IS_ENOUGH) {
        [scrollView bringSubviewToFront:view3];
    }else{
        [scrollView sendSubviewToBack:view3];
    }
    return _view;
}


#pragma mark --dataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return arr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return cellH;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"请选择支付方式";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
        static NSString *cellID = @"cellIDD";
        QVIPRechargeCell *VIPRechargeCell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (VIPRechargeCell==nil) {
            VIPRechargeCell = [[QVIPRechargeCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
            VIPRechargeCell.selectImageView.image = [UIImage imageNamed:@"yuan02.gif"];
        }
    if (indexPath.row == 0) {
        VIPRechargeCell.selectImageView.image = [UIImage imageNamed:@"yuan01.gif"];
        temImageView = VIPRechargeCell.selectImageView;
    }
    [VIPRechargeCell cofigureModelToCell:arr andIndexPath:indexPath];
    return VIPRechargeCell;
    }

- (void)sureToRecharge{
    
    [QViewController gotoPage:@"QSelectBank" withParam:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    temImageView.image = [UIImage imageNamed:@"yuan02.gif"];
    QVIPRechargeCell *cell = (QVIPRechargeCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.selectImageView.image = [UIImage imageNamed:@"yuan01.gif"];
    temImageView = cell.selectImageView;
    //    if (indexPath.section == 1) {
//        if (indexPath.row==0) {
//            array=[[NSMutableArray alloc]initWithObjects:@"yuan01.gif",@"yuan02.gif",@"yuan02.gif",@"yuan02.gif",nil];
//            [array1[0] sendModelToImage1:array andRow:0];
//            [array1[1] sendModelToImage1:array andRow:1];
//            [array1[2] sendModelToImage1:array andRow:2];
//            [array1[3] sendModelToImage1:array andRow:3];
//            return;
//        }
//        if (indexPath.row==1) {
//            array=[[NSMutableArray alloc]initWithObjects:@"yuan02.gif",@"yuan01.gif",@"yuan02.gif",@"yuan02.gif", nil];
//            [array1[0] sendModelToImage1:array andRow:0];
//            [array1[1] sendModelToImage1:array andRow:1];
//            [array1[2] sendModelToImage1:array andRow:2];
//            [array1[3] sendModelToImage1:array andRow:3];
//            return;
//        }
//        if (indexPath.row==2) {
//            array=[[NSMutableArray alloc]initWithObjects:@"yuan02.gif",@"yuan02.gif",@"yuan01.gif",@"yuan02.gif", nil];
//            [array1[0] sendModelToImage1:array andRow:0];
//            [array1[1] sendModelToImage1:array andRow:1];
//            [array1[2] sendModelToImage1:array andRow:2];
//            [array1[3] sendModelToImage1:array andRow:3];
//            return;
//        }
//        if (indexPath.row==3) {
//            array=[[NSMutableArray alloc]initWithObjects:@"yuan02.gif",@"yuan02.gif",@"yuan02.gif",@"yuan01.gif", nil];
//            [array1[0] sendModelToImage1:array andRow:0];
//            [array1[1] sendModelToImage1:array andRow:1];
//            [array1[2] sendModelToImage1:array andRow:2];
//            [array1[3] sendModelToImage1:array andRow:3];
//            return;
//        }
//    }
}

- (void)swicthTheState:(UIGestureRecognizer *)sender{
    if (isClick == NO && IS_ENOUGH) {
        selectImageView.image = nil;
        [scrollView bringSubviewToFront:view5];
        isClick = YES;
    }else if (isClick == YES && IS_ENOUGH){
        selectImageView.image = [UIImage imageNamed:@"形状 4.png"];
        [scrollView sendSubviewToBack:view5];
        isClick = NO;
    }
    if (isClick == NO && IS_ENOUGH == NO) {
        selectImageView.image = nil;
        isClick = YES;
    }else if (isClick == YES && IS_ENOUGH == NO){
        selectImageView.image = [UIImage imageNamed:@"形状 4.png"];
        isClick = NO;
    }
    
}

- (void)forgetKey{
    [QViewController gotoPage:@"QFindPayKey" withParam:nil];
}

- (void)sureToUseAccount{
    [QViewController gotoPage:@"QSureUseAccount" withParam:nil];
}

@end
