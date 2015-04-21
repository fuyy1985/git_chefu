//
//  QComboDetail.m
//  HRClient
//
//  Created by ekoo on 14/12/28.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QComboDetail.h"
#import "QViewController.h"

@interface QComboDetail (){
    NSArray *notesArr;
    NSArray *comboArr;
    NSDictionary *introDic;
}

@end

@implementation QComboDetail

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
}

- (NSString *)title{
    return @"套餐详情";
}

- (UIView *)viewWithFrame:(CGRect)frame{
    if ([super viewWithFrame:frame]) {
        notesArr = @[@"有效期：2014.1.10至2015.1.4",@"有效期内周末，法定节假日通用",@"车夫使用时间：8：00-22：00",@"无需预约。消费高峰可能需要等位",@"凭万里无忧券到店消费不可同时享受店内其他优惠",@"不限制万里无忧券使用数量"];
        comboArr = @[@"洗车套餐服务",@"1次",@"10元"];
        introDic  = @{@"product":@[@"登录_02.png",@"登录_02.png"],@"seller":@[@"登录_02.png"],@"content":@"商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商家介绍商",@"bottom":@[@"登录_02.png"]};
        CGFloat beforeW = 10;
        UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 60)];
        topView.backgroundColor = [QTools colorWithRGB:250 :250 :250];
        [_view addSubview:topView];
        
        CGFloat nowH = 40;
        UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(beforeW, 10, 160, nowH)];
        NSString *price = @"10.0";
        NSString *retailPrice = @"25元";
        NSString *text = [NSString stringWithFormat:@"%@元   %@",price,retailPrice];
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSStrikethroughStyleAttributeName:@(NSUnderlineStyleNone)}];
        [string addAttributes:@{NSStrikethroughStyleAttributeName:@(NSUnderlineStyleSingle)} range:[text rangeOfString:retailPrice]];
        [string addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:20] range:[text rangeOfString:price]];
        [string addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0xc40000) range:[text rangeOfString:price]];
        priceLabel.textColor = [QTools colorWithRGB:149 :149 :149];
        priceLabel.font = [UIFont systemFontOfSize:13];
        priceLabel.attributedText = string;
        [topView addSubview:priceLabel];
        
        CGFloat buyW = 120;
        CGFloat buyH = nowH;
        UIButton *buyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        buyBtn.frame = CGRectMake(topView.deFrameRight - 10 - buyW, 10, buyW, buyH);
        buyBtn.backgroundColor = UIColorFromRGB(0xc40000);
        [buyBtn setTitle:@"立即抢购" forState:UIControlStateNormal];
        [buyBtn setTitleColor:[QTools colorWithRGB:255 :255 :255] forState:UIControlStateNormal];
        buyBtn.layer.masksToBounds = YES;
        buyBtn.layer.cornerRadius  = 3.0;
        [buyBtn addTarget:self action:@selector(gotoBuy) forControlEvents:UIControlEventTouchUpInside];
        [topView addSubview:buyBtn];
        
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, topView.deFrameBottom - 0.5, frame.size.width, 0.5)];
        lineLabel.backgroundColor = [QTools colorWithRGB:225 :225 :225];
        [topView addSubview:lineLabel];
        
//        下面的
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, topView.deFrameBottom, frame.size.width, frame.size.height - topView.deFrameHeight)];
        scrollView.backgroundColor = [QTools colorWithRGB:255 :255 :255];
        [_view addSubview:scrollView];
        
        UILabel *knowLabel = [[UILabel alloc] initWithFrame:CGRectMake(beforeW, 0, 100, 30)];
        knowLabel.text = @"购买须知";
//        knowLabel.backgroundColor = [UIColor redColor];
        [scrollView addSubview:knowLabel];
        
        UIView *notesView = [[UIView alloc] initWithFrame:CGRectMake(beforeW, knowLabel.deFrameBottom, frame.size.width, (20 + 5)*notesArr.count)];
        notesView.backgroundColor = [QTools colorWithRGB:255 :255 :255];
        [scrollView addSubview:notesView];
        for (int i = 0; i < notesArr.count; i ++) {
            UIImageView *notesImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 5 + (20 - 7)/2.0 + (7 + 20 - 7 + 5) * i, 7, 7)];
            notesImageView.image = IMAGEOF(@"red_sign@2x.png");
            [notesView addSubview:notesImageView];
            
            UILabel *notesLabel = [[UILabel alloc] initWithFrame:CGRectMake(notesImageView.deFrameRight + 5,5 + (5 + 20) * i, notesView.deFrameRight - notesImageView.deFrameRight -5, 20)];
            notesLabel.text = notesArr[i];
            notesLabel.font = [UIFont systemFontOfSize:13];
            [notesView addSubview:notesLabel];
        }
        UILabel *cutLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, notesView.deFrameBottom + 10, frame.size.width, 2)];
        cutLabel.backgroundColor = [QTools colorWithRGB:224 :119 :119];
        [scrollView addSubview:cutLabel];
        
        UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(beforeW, cutLabel.deFrameBottom + 10, frame.size.width, 30)];
        detailLabel.text  =@"本单详情";
        [scrollView addSubview:detailLabel];
        
        UIView *serviceView = [[UIView alloc] initWithFrame:CGRectMake(beforeW, detailLabel.deFrameBottom + 10, frame.size.width - 2 * beforeW, 40)];
        serviceView.backgroundColor = [QTools colorWithRGB:250 :250 :250];
        serviceView.layer.borderColor = [QTools colorWithRGB:224 :224 :224].CGColor;
        serviceView.layer.borderWidth = 1.0f;
        [scrollView addSubview:serviceView];
//        服务
        UILabel *serLabel = [[UILabel alloc] initWithFrame:CGRectMake(beforeW, 0, 120, serviceView.deFrameHeight)];
        serLabel.text = comboArr[0];
        serLabel.textColor = [QTools colorWithRGB:85 :85 :85];
        [serviceView addSubview:serLabel];
//        价格
        CGFloat moneyW = 100;
        UILabel *moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(serviceView.deFrameRight - beforeW - moneyW, 0, moneyW, serviceView.deFrameHeight)];
        moneyLabel.textAlignment = NSTextAlignmentCenter;
        moneyLabel.text = comboArr[2];
        moneyLabel.textColor = [QTools colorWithRGB:85 :85 :85];
        [serviceView addSubview:moneyLabel];
//        次数
        UILabel *qtyLabel = [[UILabel alloc] initWithFrame:CGRectMake(moneyLabel.deFrameLeft - 85, 0, 85, serviceView.deFrameHeight)];
        qtyLabel.text  = comboArr[1];
        qtyLabel.textColor = [QTools colorWithRGB:85 :85 :85];
        qtyLabel.textAlignment = NSTextAlignmentCenter;
        [serviceView addSubview:qtyLabel];
        
//        产品介绍
        UILabel *introLabel = [[UILabel alloc] initWithFrame:CGRectMake(beforeW, serviceView.deFrameBottom + 10, frame.size.width - 2 * beforeW, 30)];
        introLabel.text  =@"产品介绍";
        introLabel.textColor  = UIColorFromRGB(0xc40000);
        introLabel.backgroundColor = [QTools colorWithRGB:222 :222 :222];
        [scrollView addSubview:introLabel];
        
        NSInteger count = [[introDic objectForKey:@"product"] count];
        NSArray *arr = [introDic objectForKey:@"product"];
        
        UIView *proView = [[UIView alloc] initWithFrame:CGRectMake(0, introLabel.deFrameBottom + 10, frame.size.width, (100 + 10)*count)];
        [scrollView addSubview:proView];
        for (NSInteger i = 0; i < count; i ++) {
            UIImageView *productImageView = [[UIImageView alloc] initWithFrame:CGRectMake(beforeW,(100 + 10) * i, frame.size.width - 2 * beforeW, 100)];
            productImageView.image = IMAGEOF(arr[i]) ;
            [proView addSubview:productImageView];
        }
//        商家介绍
        UILabel *sellerLabel = [[UILabel alloc] initWithFrame:CGRectMake(beforeW, proView.deFrameBottom , frame.size.width - 2 * beforeW, 30)];
        sellerLabel.text  =@"商家介绍";
        sellerLabel.textColor  = UIColorFromRGB(0xc40000);
        sellerLabel.backgroundColor = [QTools colorWithRGB:222 :222 :222];
        [scrollView addSubview:sellerLabel];
        
        NSInteger count1 = [[introDic objectForKey:@"seller"] count];
        NSArray *arr1 = [introDic objectForKey:@"seller"];
        UIView *sellerView = [[UIView alloc] initWithFrame:CGRectMake(0, sellerLabel.deFrameBottom + 10, frame.size.width, (100 + 10)*count1)];
        [scrollView addSubview:sellerView];
        for (NSInteger i = 0; i < count1; i ++) {
            UIImageView *sellerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(beforeW,(100 + 10) * i, frame.size.width - 2 * beforeW, 100)];
            sellerImageView.image = IMAGEOF(arr1[i]) ;
            [sellerView addSubview:sellerImageView];
        }
        
//        商家名称
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, sellerView.deFrameBottom, frame.size.width, 30)];
        nameLabel.text = @"商家名称";
        nameLabel.textAlignment  =NSTextAlignmentCenter;
        [scrollView addSubview:nameLabel];
//        商家介绍
        NSString *contentStr = [introDic objectForKey:@"content"];
        float height = 0;
        height = [contentStr sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(frame.size.width - 2 * beforeW, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping].height;
        UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(beforeW, nameLabel.deFrameBottom, frame.size.width - 2 * beforeW, height + 20)];
        contentLabel.text = contentStr;
        contentLabel.numberOfLines = 0;
        contentLabel.font = [UIFont systemFontOfSize:16];
        [scrollView addSubview:contentLabel];
        
        NSInteger count2 = [[introDic objectForKey:@"bottom"] count];
        NSArray *arr2 = [introDic objectForKey:@"bottom"];
        UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, contentLabel.deFrameBottom + 10, frame.size.width, (100 + 10)*count2)];
        [scrollView addSubview:bottomView];
        for (NSInteger i = 0; i < count1; i ++) {
            UIImageView *bottomImageView = [[UIImageView alloc] initWithFrame:CGRectMake(beforeW,(100 + 10) * i, frame.size.width - 2 * beforeW, 100)];
            bottomImageView.image = IMAGEOF(arr2[i]) ;
            [bottomView addSubview:bottomImageView];
        }
        
        scrollView.contentSize  =CGSizeMake(frame.size.width, bottomView.deFrameBottom + 10);
        
        
    }
    return _view;
}

- (void)gotoBuy{
    [QViewController gotoPage:@"1234567890" withParam:nil];
}

- (void)setCollect{
    [QViewController gotoPage:@"1234567890" withParam:nil];
}

- (void)setShare{
    [QViewController gotoPage:@"1234567890" withParam:nil];
}

@end
