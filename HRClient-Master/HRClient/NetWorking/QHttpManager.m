//
//  QHttpManager.m
//  HRClient
//
//  Created by ekoo on 15/1/4.
//  Copyright (c) 2015年 panyj. All rights reserved.
//

#import "QHttpManager.h"
#import "QHotCityModel.h"
#import "QLoginModel.h"
#import "QCommentModel.h"
#import "QRegisterModel.h"
#import "QDifStatusListQtyModel.h"
#import "QMyAccountMoel.h"
#import "QMyListDetailModel.h"
#import "QViewController.h"
#import "QBusinessListModel.h"
#import "QHomePageModel.h"
#import "QProductDetail.h"
#import "QProductDdtailComment.h"
#import "QCarWashModel.h"
#import "QMyFavoritedModel.h"
#import "QMyCoupon.h"
#import "QCardDetailModel.h"
#import "QAgreementModel.h"
#import "QMyListModel.h"

@interface QHttpManager (){
    NSArray *cookie;
    NSString *str1;
}

@end

@implementation QHttpManager

- (id)initWithDelegate:(id<QiaoHttpDelegate>)delegate{
    if (self = [super init]) {
//        开辟空间
        _networkQueue = [[ASINetworkQueue alloc] init];
//        设置代理
        _networkQueue.delegate = self;
//        设置回调方法
//        设置一个线程开始启动时的回调方法
        [_networkQueue setRequestDidStartSelector:@selector(requestDidStart:)];
        //        2)设置一个线程成功结束时的回调方法
        [_networkQueue setRequestDidFinishSelector:@selector(requestDidFinish:)];
        //        3)设置一个线程失败时的回调方法
        [_networkQueue setRequestDidFailSelector:@selector(requestDidFail:)];
        //        4)设置队列里面所有的线程都结束的回调方法
        [_networkQueue setQueueDidFinishSelector:@selector(queueDidFinish:)];
        //
        self.delegate = delegate;
    }
    return self;
}

#pragma mark - Operate queue
//判断self.netWorkQueue是否处于运行状态
- (BOOL)isRunning
{
    return ![self.networkQueue isSuspended];
}
//启动队列
- (void)start
{
    if( [self.networkQueue isSuspended] )
        [self.networkQueue go];
}
//停止
- (void)pause
{
    [self.networkQueue setSuspended:YES];
}
//重新开始
- (void)resume
{
    [self.networkQueue setSuspended:NO];
}
//取消队列里面所有线程
- (void)cancel
{
    [self.networkQueue cancelAllOperations];
}

#pragma mark --代理回调方法
//开始
- (void)requestDidStart:(ASIHTTPRequest*)request{
    
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [QViewController backPageWithParam:nil];
    }
    else if (buttonIndex == 1)
    {
        [QViewController gotoPage:@"QMyNoWarry" withParam:nil];
    }
    else if (buttonIndex == 2)
    {
        [QViewController gotoPage:@"QMyList" withParam:nil];
    }
}

//成功返回
- (void)requestDidFinish:(ASIHTTPRequest*)request
{
    //1.用NSData类型的指针去接收数据
    NSData *dataResult = [request responseData];
    //2.解析数据
    NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:dataResult options:NSJSONReadingMutableContainers error:nil];
    //3.创建一个可变的数组，目的：添加数据模型对象
    NSMutableArray *modeArray = [NSMutableArray array];
    NSNumber *number = [request.userInfo objectForKey:USER_INFO_KEY_TYPE];
    RequestType requestType = [number intValue];
    if ([[resultDic objectForKey:@"status"] intValue] == 0)
    {
        NSString *failure = [resultDic objectForKey:@"message"];
        if (![failure isEqualToString:@""])
        {
            debug_NSLog(@"errcode:%d", requestType);
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(didGetDataFailed:)]) {
                [self.delegate didGetDataFailed:requestType];
            }
            
            if (failure && ![failure isEqualToString:@""]) {
                if ([failure isEqualToString:@"你今天已经使用过会员卡价格"])
                {
                    
                    NSDictionary *infoDic = [resultDic objectForKey:@"result"];
                    if ([self.delegate respondsToSelector:@selector(didAddList:)]) {
                        
                        QMyListModel *model = [QMyListModel getModelFromMyList:[infoDic objectForKey:@"orderList"]];
                        [self.delegate didretList:model];
                    }
                    
                    /*
                    //特殊处理
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                    message:@"今天您已使用洗车卡购买过服务或商品"
                                                                   delegate:self
                                                          cancelButtonTitle:nil
                                                          otherButtonTitles:@"我的订单", @"查看我的洗车劵",nil];
                    [alert show];*/
                }
                else
                {
                    [ASRequestHUD showErrorWithStatus:failure];
                }
            }
            else
            {
                [ASRequestHUD dismiss];
            }
            
            return;
        }
    }
    else if([[resultDic objectForKey:@"status"] intValue] == 1){
        //  状态为1时
        switch (requestType) {
                
            case kDrawback:
            {
                NSNumber *ret = [resultDic objectForKey:@"result"];
                
                if ([self.delegate respondsToSelector:@selector(retDrawback:)]) {
                    [self.delegate retDrawback:ret];
                }
            }
                break;
            case kHotCity://热门城市
            {
                NSArray *resultArray = [resultDic objectForKey:@"result"];
                for (NSDictionary *appDic in resultArray) {
                    QHotCityModel *hotModel = [QHotCityModel getModelFromDic:appDic];
                    [modeArray addObject:hotModel];
                }
                if ([self.delegate respondsToSelector:@selector(didGetHotCity:)]) {
                    [self.delegate didGetHotCity:modeArray];
                }
            }
                break;
            case kRegion:
            {
                NSArray *resultArray= [resultDic objectForKey:@"result"];
                for (NSDictionary *dict in resultArray)
                {
                    QRegionModel *model = [QRegionModel getModelFromDic:dict];
                    [modeArray addObject:model];
                }
                if ([self.delegate respondsToSelector:@selector(didGetRegion:)]) {
                    [self.delegate didGetRegion:modeArray];
                }
            }
                break;
            case kAcquireCode://验证码
            {
                NSString *success = [resultDic objectForKey:@"message"];
                if ([self.delegate respondsToSelector:@selector(didGetAcquireCode:)]) {
                    [self.delegate didGetAcquireCode:success];
                }
            }
                break;
            case kLogin:
            {
                NSDictionary *result1 = [resultDic objectForKey:@"result"];
                if (![[resultDic objectForKey:@"status"] intValue]) {
                    //                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"账户名或密码错误" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    //                [alert show];
                }else{
                    QLoginModel  *loginModel = [QLoginModel getModelFromDic:result1];
                    if ([self.delegate respondsToSelector:@selector(didGetLogin:)]) {
                        [self.delegate didGetLogin:loginModel];
                    }
                    cookie = [request responseCookies];
                    debug_NSLog(@"cookie%@",cookie);
                }
            }
                break;
            case kProductComment:
            {
                NSDictionary *resultDictionary = [resultDic objectForKey:@"result"];
                NSArray *resultArr = [resultDictionary objectForKey:@"commentResultList"];
                for (NSDictionary *appDic in resultArr) {
                    QProductDdtailComment *commentModel = [QProductDdtailComment getModelFromProductDetailComment:appDic];
                    [modeArray addObject:commentModel];
                }
                if ([self.delegate respondsToSelector:@selector(didGetProductComment:)]) {
                    [self.delegate didGetProductComment:modeArray];
                }
            }
                break;
            case kBusinessComment:
            {
                NSDictionary *resultArr = [resultDic objectForKey:@"result"];
                
                for (NSDictionary *appDic in [resultArr objectForKey:@"commentResultList"]) {
                    QBusinessDetailComment *commentModel = [QBusinessDetailComment getModelFromBusinessDetailComment:appDic];
                    [modeArray addObject:commentModel];
                }
                if ([self.delegate respondsToSelector:@selector(didGetBusinessComment:)]) {
                    [self.delegate didGetBusinessComment:modeArray];
                }
            }
                break;
            case kAcommendNick:
            {
                NSString *alertStr = [resultDic objectForKey:@"message"];
                if ([self.delegate respondsToSelector:@selector(didGetNick:)]) {
                    [self.delegate didGetNick:alertStr];
                }
            }
                break;
            case kConfirmBindPhone:
            {
                NSString *alertStr = [resultDic objectForKey:@"message"];
                if ([self.delegate respondsToSelector:@selector(didGetConfirmBindPhone:)]) {
                    [self.delegate didGetConfirmBindPhone:alertStr];
                }
            }
                break;
            case kChangeBindPhone:
            {//更改绑定手机
                NSString *alertStr = [resultDic objectForKey:@"message"];
                if ([self.delegate respondsToSelector:@selector(didGetNewBindPhone:)]) {
                    [self.delegate didGetNewBindPhone:alertStr];
                }
            }
                break;
            case kAcommendPayPwd:
            {//修改支付密码
                NSString *alertStr = [resultDic objectForKey:@"message"];
                if ([self.delegate respondsToSelector:@selector(didGetNewPayPwd:)]) {
                    [self.delegate didGetNewPayPwd:alertStr];
                }
            }
                break;
            case kFindPayPwd:
            {//找回支付密码
                NSString *alertStr = [resultDic objectForKey:@"message"];
                if ([self.delegate respondsToSelector:@selector(didGetPayPwd:)]) {
                    [self.delegate didGetPayPwd:alertStr];
                }
            }
                break;
            case kSetPayPwd:
            {//设置支付密码
                NSString *message = [resultDic objectForKey:@"message"];
                if ([self.delegate respondsToSelector:@selector(didSetPayPwd:)]) {
                    [self.delegate didSetPayPwd:message];
                }
                
            }
                break;
            case kReSetPayPwd:
            {
                NSString *message = [resultDic objectForKey:@"message"];
                if ([self.delegate respondsToSelector:@selector(didReSetPayPwd:)]) {
                    [self.delegate didReSetPayPwd:message];
                }
            }
                break;
            case kRegister:
            {//注册
                NSDictionary *result = [resultDic objectForKey:@"result"];
                QRegisterModel *registerModel = [QRegisterModel getModelFromRegister:result];
                
                if ([self.delegate respondsToSelector:@selector(didGetNewUserInfro:)]) {
                    [self.delegate didGetNewUserInfro:registerModel];
                }
            }
                break;
            case kFindLoginPwd:
            {//找回登录密码
                NSDictionary *result = [resultDic objectForKey:@"result"];
                QLoginModel  *loginModel = [QLoginModel getModelFromDic:result];
                if ([self.delegate respondsToSelector:@selector(didGetLoginPwd:)]) {
                    [self.delegate didGetLoginPwd:loginModel];
                }
            }
                break;
            case kSureFindLoginPwd:
            {//确认找回
                NSString *alertStr = [resultDic objectForKey:@"message"];
                if ([self.delegate respondsToSelector:@selector(didGetSureFindLginPwd:)]) {
                    [self.delegate didGetSureFindLginPwd:alertStr];
                }
            }
                break;
            case kDifStatusListQty:
            {//不同状态的订单数
                NSDictionary *appDic = [resultDic objectForKey:@"result"];
                QDifStatusListQtyModel *statusModel = [QDifStatusListQtyModel backToDifStatusListQty:appDic];
                if ([self.delegate respondsToSelector:@selector(didGetQtyInDifStatus:)]) {
                    [self.delegate didGetQtyInDifStatus:statusModel];
                }
            }
                break;
            case kDifStatusList:
            {//不同状态的订单
                NSArray *resultArray = [resultDic objectForKey:@"result"];
                for (NSDictionary *appDic in resultArray) {
                    QMyListDetailModel *statusListModel = [QMyListDetailModel getModelFromMyListDetail:appDic];
                    [modeArray addObject:statusListModel];
                }
                if ([self.delegate respondsToSelector:@selector(didGetDifStatusList:)]) {
                    [self.delegate didGetDifStatusList:modeArray];
                }
            }
                break;
            case kMyAccount:
            {//我的账户
                NSArray *resultArray = [resultDic objectForKey:@"result"];
                for (NSDictionary *appDic in resultArray) {
                    QMyAccountMoel *myAccountModel = [QMyAccountMoel getModelFromMyAccount:[appDic objectForKey:@"account"]];
                    myAccountModel.expireDate = [appDic objectForKey:@"expireDate"];
                    [modeArray addObject:myAccountModel];
                }
                if ([self.delegate respondsToSelector:@selector(didGetMyAccountInfro:)]) {
                    [self.delegate didGetMyAccountInfro:modeArray];
                }
            }
                break;
            case kMyListDetail:
            {//订单详情
                NSDictionary *resultDic1 = [resultDic objectForKey:@"result"];
                QMyListDetailModel *myMyListDetailModel = [QMyListDetailModel getModelFromMyListDetail:resultDic1];
                if ([self.delegate respondsToSelector:@selector(didGetMyListDetail:)]) {
                    [self.delegate didGetMyListDetail:myMyListDetailModel];
                }
            }
                break;
            case keditDelegate:
            {//编辑删除
                NSString *message = [resultDic objectForKey:@"message"];
                if ([self.delegate respondsToSelector:@selector(didGetEditDelegate:)]) {
                    [self.delegate didGetEditDelegate:message];
                }
            }
                break;
            case kAcommendLoginPwd:
            {//修改登录密码
                NSString *message = [resultDic objectForKey:@"message"];
                if ([self.delegate respondsToSelector:@selector(didGetNewLoginPwd:)]) {
                    [self.delegate didGetNewLoginPwd:message];
                }
            }
                break;
            case kListRemark://订单评价
            {
                NSString *message = [resultDic objectForKey:@"message"];
                if ([self.delegate respondsToSelector:@selector(didGetListRemark:)]) {
                    [self.delegate didGetListRemark:message];
                }
            }
                break;
            case kAddMyFavorite://添加收藏
            {
                NSString *message = [resultDic objectForKey:@"message"];
                if ([self.delegate respondsToSelector:@selector(didAddMyFavority:)]) {
                    [self.delegate didAddMyFavority:message];
                }
            }
                break;
            case kAddList://添加订单
            {
                NSDictionary *infoDic = [resultDic objectForKey:@"result"];
                if ([self.delegate respondsToSelector:@selector(didAddList:)]) {
                    
                    QMyListModel *model = [QMyListModel getModelFromMyList:[infoDic objectForKey:@"orderList"]];
                    [self.delegate didAddList:model];
                }
            }
                break;
            case kBusinessList://商家列表
            {
                NSArray *resultArr = [resultDic objectForKeyedSubscript:@"result"];
                for (NSDictionary *appDic in resultArr) {
                    QBusinessListModel *businessModel = [QBusinessListModel getModelFromBusinessList:appDic];
                    [modeArray addObject:businessModel];
                }
                if ([self.delegate respondsToSelector:@selector(didGetBusinessList:)]) {
                    [self.delegate didGetBusinessList:modeArray];
                }
            }
                break;
            case kBusinessDetail://商家详情
            {
                NSDictionary *appDic = [resultDic objectForKey:@"result"];
                QBusinessDetailModel *businessDetailModel = [QBusinessDetailModel getModelFromBusinessDetail:appDic];
                if ([self.delegate respondsToSelector:@selector(didGetBusinessDetail:)]) {
                    [self.delegate didGetBusinessDetail:businessDetailModel];
                }
                NSArray *commentArr = businessDetailModel.commentResult;
                for (NSDictionary *commentDic in commentArr) {
                    QBusinessDetailComment *commentModel = [QBusinessDetailComment getModelFromBusinessDetailComment:commentDic];
                    [modeArray addObject:commentModel];
                }
                if ([self.delegate respondsToSelector:@selector(didGetBusinessDetailComment:)]) {
                    [self.delegate didGetBusinessDetailComment:modeArray];
                }
                NSMutableArray *proArr = [[NSMutableArray alloc] init];
                for (NSDictionary *detailProduct in businessDetailModel.productListResult) {//商品列表
                    QBusinessDetailResult *detailResultModel = [QBusinessDetailResult getModelFromBusinessDetailResult:detailProduct];
                    [proArr addObject:detailResultModel];
                }
                if ([self.delegate respondsToSelector:@selector(didGetBusinessDetailProductList:)]) {
                    [self.delegate didGetBusinessDetailProductList:proArr];
                }
            }
                break;
            case kHomePageList://首页
            {
                NSArray *resultArr = [resultDic objectForKey:@"result"];
                for (NSDictionary *appDic in resultArr) {
                    QHomePageModel *homeModel = [QHomePageModel getModelFromHomePage:appDic];
                    [modeArray addObject:homeModel];
                }
                if ([self.delegate respondsToSelector:@selector(didGetHomePageList:)]) {
                    [self.delegate didGetHomePageList:modeArray];
                }
                [QConfigration writeFileConfig:resultArr forKey:HomeProducts];
            }
                break;
            case kProductDetail://商品详情
            {
                NSDictionary *appDic = [resultDic objectForKey:@"result"];
                QProductDetail *productModel = [QProductDetail getModelFromProduct:appDic];
                if ([self.delegate respondsToSelector:@selector(didGetProductDetail:)]) {
                    [self.delegate didGetProductDetail:productModel];
                }
                //商家
                QProductDetailCompany *companyModel = [QProductDetailCompany getModelFromProductDetailCompany:[appDic objectForKey:@"company"]];
                if ([self.delegate respondsToSelector:@selector(didGetProductDetailCompany:)]) {
                    [self.delegate didGetProductDetailCompany:companyModel];
                }
                //评论
                NSMutableArray *commentArr = [[NSMutableArray alloc] init];
                for (NSDictionary *commentDic in [appDic objectForKey:@"commentResultList"]) {
                    QProductDdtailComment *commentModel = [QProductDdtailComment getModelFromProductDetailComment:commentDic];
                    [commentArr addObject:commentModel];
                }
                
                if ([self.delegate respondsToSelector:@selector(didGetProductDetailComment:)]) {
                    [self.delegate didGetProductDetailComment:commentArr];
                }
            }
                break;
            case kCarWashList://洗车列表
            {
                NSArray *resultArr = [resultDic objectForKey:@"result"];
                for (NSDictionary *appDic in resultArr) {
                    QProductModel *carWashModel = [QProductModel getModelFromDict:appDic];
                    [modeArray addObject:carWashModel];
                }
                if ([self.delegate respondsToSelector:@selector(didGetCarWashList:)]) {
                    [self.delegate didGetCarWashList:modeArray];
                }
            }
                break;
            case kCarWashOption://洗车选项
            {
                NSArray *resultArr = [[resultDic objectForKey:@"result"] objectForKey:@"categoryone"];
                for (NSDictionary *appDic in resultArr) {
                    QCarWashModel *carWashModel = [QCarWashModel getModelFromCarWash:appDic];
                    [modeArray addObject:carWashModel];
                }
                if ([self.delegate respondsToSelector:@selector(didGetCarWashOption:)]) {
                    [self.delegate didGetCarWashOption:modeArray];
                }
            }
                break;
            case kCategorySubList:
            {
                NSArray *data = [resultDic objectForKey:@"result"];
                NSMutableArray *subListArray = [[NSMutableArray alloc] initWithCapacity:0];
                
                for (NSDictionary *dict in data) {
                    QCategoryModel *model = [QCategoryModel getModelFromCategory:dict];
                    
                    NSMutableArray *subList = [[NSMutableArray alloc] initWithCapacity:0];
                    for (NSDictionary *subDict in [dict objectForKey:@"categoryList"]) {
                        QCategorySubModel *subModel = [QCategorySubModel getModelFromCategorySub:subDict];
                        [subList addObject:subModel];
                        [subListArray addObject:subModel];
                    }
                    model.subList = subList;
                    [modeArray addObject:model];
                }
                if ([self.delegate respondsToSelector:@selector(didGetCategoryList:)]) {
                    [QCategoryModel setCategory:modeArray];
                    [self.delegate didGetCategoryList:modeArray];
                }
                if ([self.delegate respondsToSelector:@selector(didGetCategorySubList:)]) {
                    [self.delegate didGetCategorySubList:subListArray];
                }
            }
                break;
            case kMyFavorite://收藏
            {
                NSArray *resultArr = [resultDic objectForKey:@"result"];
                for (NSDictionary *appDic in resultArr) {
                    QMyFavoritedModel *model = [QMyFavoritedModel getModelFromMyFavorited:[appDic objectForKey:@"productListVO"]];
                    if (!model)
                        continue;
                    
                    NSMutableDictionary *favorityDic = [[NSMutableDictionary alloc] init];
                    [favorityDic setObject:model forKey:@"model"];
                    [favorityDic setObject:[appDic objectForKey:@"favoriteId"] forKey:@"favoriteId"];
                    [modeArray addObject:favorityDic];
                }
                if ([self.delegate respondsToSelector:@selector(didiGetMyFavority:)]) {
                    [self.delegate didiGetMyFavority:modeArray];
                }
            }
                break;
            case kMyCoupon://我的车夫券
            {
                NSArray *resultArr = [resultDic objectForKey:@"result"];
                for (NSDictionary *appDic in resultArr) {
                    QMyCoupon *CouponModel = [QMyCoupon getModelFromMyCoupon:appDic];
                    [modeArray addObject:CouponModel];
                }
                if ([self.delegate respondsToSelector:@selector(didGetMyCoupon:)]) {
                    [self.delegate didGetMyCoupon:modeArray];
                }
            }
                break;
            case kMyCouponDetail://我的车夫券详情
            {
                NSDictionary *modelDic = [resultDic objectForKey:@"result"];
                QMyCouponDetailModel *couDetailModel = [QMyCouponDetailModel getModelFromMyCouponDetail:modelDic];
                if ([self.delegate respondsToSelector:@selector(didGetMyCouponDetail:)]) {
                    [self.delegate didGetMyCouponDetail:couDetailModel];
                }
            }
                break;
            case kPayResult://支付操作
            {
                int retValue = [[resultDic objectForKey:@"status"] integerValue];
                if ([self.delegate respondsToSelector:@selector(didGetPayResult:)]) {
                    [self.delegate didGetPayResult:retValue];
                }
            }
                break;
                
            case kCreatVipPrePayID:
            {
                NSDictionary *modelDic = [resultDic objectForKey:@"result"];
                NSString *strBillID = [((NSNumber*)[modelDic objectForKey:@"prepaidBillId"]).stringValue stringByAppendingString:@"_"];
                NSString *strUserID = [((NSNumber*)[modelDic objectForKey:@"userId"]).stringValue stringByAppendingString:@"_"];
                NSString *strAccountID = [((NSNumber*)[modelDic objectForKey:@"accountId"]).stringValue stringByAppendingString:@"_"];
                
                NSString *strInfo = [[strUserID stringByAppendingString:strAccountID] stringByAppendingString:strBillID];
                
                if (strInfo.length > 0 && [self.delegate respondsToSelector:@selector(didGetVipPayBill:)]) {
                    [self.delegate didGetVipPayBill:strInfo];
                }
            }
                break;
            case kCreatAccPrePayID:
            {
                NSDictionary *modelDic = [resultDic objectForKey:@"result"];
                if (modelDic != nil)
                {
                    //accountId+"_"+prepaidBillId+"_"+amount 例如 1_33_22222
                    NSString *strBillID = [((NSNumber*)[modelDic objectForKey:@"prepaidBillId"]).stringValue stringByAppendingString:@"_"];
                    NSString *strUserID = [((NSNumber*)[modelDic objectForKey:@"userId"]).stringValue stringByAppendingString:@"_"];
                    NSString *strAccountID = [((NSNumber*)[modelDic objectForKey:@"accountId"]).stringValue stringByAppendingString:@"_"];
                    
                    NSString *strInfo = [[strUserID stringByAppendingString:strAccountID] stringByAppendingString:strBillID];
                    
                    if (strInfo.length > 0 && [self.delegate respondsToSelector:@selector(didGetAccPayBill:)]) {
                        [self.delegate didGetAccPayBill:strInfo];
                    }
                }
            }
                break;
            case kDelectMyFavorite://删除我的车夫券
            {
                NSString *infroMessage = [resultDic objectForKey:@"message"];
                if ([self.delegate respondsToSelector:@selector(didDelectMyFavority:)]) {
                    [self.delegate didDelectMyFavority:infroMessage];
                }
            }
                break;
            case kSearch:
                
                break;
            case kCompanyProduct://本商家所有商品列表
            {
                NSArray *resultArr = [resultDic objectForKey:@"result"];
                for (NSDictionary *modelDic in resultArr) {
                    QBusinessDetailResult *model = [QBusinessDetailResult getModelFromBusinessDetailResult:modelDic];
                    [modeArray addObject:model];
                }
                if ([self.delegate respondsToSelector:@selector(didGetCompanyProduct:)]) {
                    [self.delegate didGetCompanyProduct:modeArray];
                }
            }
                break;
            case kHotSearchWord:
            {
                NSArray *resultArr = [resultDic objectForKey:@"result"];
                for (NSDictionary *dict in resultArr) {
                    NSString *word = [dict objectForKey:@"word"];
                    [modeArray addObject:word];
                }
                if (self.delegate && [self.delegate respondsToSelector:@selector(didGetHotSearchWord:)]) {
                    [self.delegate didGetHotSearchWord:modeArray];
                }
            }
                break;
            case kSearchBusiness:
            {
                NSArray *resultArr = [resultDic objectForKey:@"result"];
                for (NSDictionary *dict in resultArr)
                {
                    /*只有companyName,companyId信息*/
                    QBusinessListModel *model = [QBusinessListModel getModelFromBusinessList:dict];
                    [modeArray addObject:model];
                }
                if (self.delegate && [self.delegate respondsToSelector:@selector(didSearchBusiness:)]) {
                    [self.delegate didSearchBusiness:modeArray];
                }
            }
                break;
            case kCardDetails:
            {
                NSDictionary *cardDetailDict = [resultDic objectForKey:@"result"];
                NSComparator cmptr = ^(id obj1, id obj2){
                    if ([obj1 intValue] > [obj2 intValue]) {
                        return (NSComparisonResult)NSOrderedDescending;
                    }
                    
                    if ([obj1 intValue] < [obj2 intValue]) {
                        return (NSComparisonResult)NSOrderedAscending;
                    }
                    return (NSComparisonResult)NSOrderedSame;
                };

                NSArray *array = [[cardDetailDict allKeys] sortedArrayUsingComparator:cmptr];

                for (NSString *key in array) {
                    
                    NSArray *array = [cardDetailDict objectForKey:key];
                    if (array.count < 1)
                        continue;
                    
                    QCardDetailModel *model = [QCardDetailModel getModelFromDic:[array objectAtIndex:0]];
                    NSMutableArray *prices = [[NSMutableArray alloc] initWithCapacity:0];
                    for (NSDictionary *dict in array)
                    {
                        NSDictionary *priceDict = [[NSDictionary alloc] initWithObjectsAndKeys:[dict objectForKey:@"memberUnitPrice"], @"memberUnitPrice", [dict objectForKey:@"memberPriceId"], @"memberPriceId", nil];
                        [prices addObject:priceDict];
                    }
                    model.memberPrices = prices;
                    [modeArray addObject:model];
                }
                if (self.delegate && [self.delegate respondsToSelector:@selector(didGetCardDetails:)]) {
                    [self.delegate didGetCardDetails:modeArray];
                }
            }
                break;
            case kGetAgreement:
            {
                NSDictionary *agreeDict = [resultDic objectForKey:@"result"];
                
                QAgreementModel *model = [QAgreementModel getModelFromDic:agreeDict];
                [modeArray addObject:model];
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(didGetAgreement:)]) {
                    [self.delegate didGetAgreement:modeArray];
                }
            }
                break;
            case kSuggestRetroaction:
            {
                NSString *message = [resultDic objectForKey:@"message"];
                if ([self.delegate respondsToSelector:@selector(didGetSuggestRetroaction:)]) {
                    [self.delegate didGetSuggestRetroaction:message];
                }
            }
                break;
            case kDelayExpire:
            {
                if ([self.delegate respondsToSelector:@selector(didDelayExpire:)]) {
                    [self.delegate didDelayExpire:@""];
                }
            }
                break;
            case kMyMemberCard:
            {
                NSDictionary *cardDict = [resultDic objectForKey:@"result"];
                QMemberCardDetail *model = [QMemberCardDetail getModelFromDict:cardDict];
                if ([self.delegate respondsToSelector:@selector(didGetMyMemberCard:)]) {
                    [self.delegate didGetMyMemberCard:model];
                }
            }
                break;
            default:
                break;
        }
    }
}

//失败
- (void)requestDidFail:(ASIHTTPRequest*)request
{
    [ASRequestHUD showErrorWithStatus:@"网络异常，请稍后尝试"];
    NSError *err = [request error];
    debug_NSLog(@"%@",err);
    
    NSNumber *number = [request.userInfo objectForKey:USER_INFO_KEY_TYPE];
    RequestType requestType = [number intValue];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didGetDataFailed:)]) {
        [self.delegate didGetDataFailed:requestType];
    }
}
//所有线程任务完成
- (void)queueDidFinish:(ASINetworkQueue*)networkQueue{
    
}

#pragma mark -- 设置request的userInfo属性
-(void)setGetMthodWith:(ASIHTTPRequest*)request andRequestType:(RequestType)type{
    NSNumber *number = [NSNumber numberWithInt:type];
    NSDictionary *tempDic = [NSDictionary dictionaryWithObject:number forKey:USER_INFO_KEY_TYPE];
    [request setUserInfo:tempDic];
}

#pragma mark --接口访问的方法
//获取热门城市
- (void)accessHotCity{
    NSString *path = [NSString stringWithFormat:@"%@%@%@",TESTADRESS,DOMAINN,HOT_CITY_MESSAGE];
    NSURL *url = [NSURL URLWithString:path];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [self setGetMthodWith:request andRequestType:kHotCity];
    [_networkQueue addOperation:request];
}

- (void)accessGetRegion:(NSString*)parentId
{
    NSString *path = [NSString stringWithFormat:@"%@%@%@",TESTADRESS,DOMAINN,Q_REGION];
    NSURL *url = [NSURL URLWithString:path];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:parentId forKey:@"parentId"];
    [self setGetMthodWith:request andRequestType:kRegion];
    [_networkQueue addOperation:request];
}

- (void)accessAcquireCode:(NSString *)phone andMessage:(NSString *)message{
    NSString *path = [NSString stringWithFormat:@"%@%@",SERVERADRESS,ACQUIRE_CODE];
    NSURL *url = [NSURL URLWithString:path];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:phone forKey:@"phone"];
    [request setPostValue:message forKey:@"message"];
    [self setGetMthodWith:request andRequestType:kAcquireCode];
    [_networkQueue addOperation:request];
}

//登录
- (void)accessLogin:(NSString *)nick andPassword:(NSString *)password{
    NSString *path = [NSString stringWithFormat:@"%@%@",SERVERADRESS,Q_LOGIN];
    NSURL *url = [NSURL URLWithString:path];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:nick forKey:@"nick"];
    [request setPostValue:password forKey:@"password"];
    [request setUseCookiePersistence:YES];
    [self setGetMthodWith:request andRequestType:kLogin];
    [_networkQueue addOperation:request];
}
//评论
- (void)accessBussinessComment:(NSString*)companyId andPage:(int)pageSize andIndex:(int)index{
    NSString *path = [NSString stringWithFormat:@"%@%@%@",TESTADRESS,DOMAINN,Q_BUSINESS_COMMENT];
    NSURL *url = [NSURL URLWithString:path];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:companyId forKey:@"companyId"];
    [request setPostValue:[NSString stringWithFormat:@"%d",pageSize] forKey:@"pageSize"];
    [request setPostValue:[NSString stringWithFormat:@"%d",index] forKey:@"index"];
    [self setGetMthodWith:request andRequestType:kBusinessComment];
    [_networkQueue addOperation:request];
}
- (void)accessProductComment:(NSString*)companyId andProductID:(NSString*)productId andPage:(int)pageSize andIndex:(int)index{
    NSString *path = [NSString stringWithFormat:@"%@%@%@",TESTADRESS,DOMAINN,Q_PRODUCT_COMMENT];
    NSURL *url = [NSURL URLWithString:path];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:companyId forKey:@"companyId"];
    [request setPostValue:productId forKey:@"productId"];
    [request setPostValue:[NSString stringWithFormat:@"%d",pageSize] forKey:@"pageSize"];
    [request setPostValue:[NSString stringWithFormat:@"%d",index] forKey:@"index"];
    [self setGetMthodWith:request andRequestType:kProductComment];
    [_networkQueue addOperation:request];
}
//修改账户名
- (void)accessAcommendNick:(NSString *)nick{
    NSString *path = [NSString stringWithFormat:@"%@%@",SERVERADRESS,Q_ACOMMEND_NICK];
    NSURL *url = [NSURL URLWithString:path];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:nick forKey:@"nick"];
    [request setUseCookiePersistence:YES];
    [self setGetMthodWith:request andRequestType:kAcommendNick];
    [_networkQueue addOperation:request];
}
//修改登录密码
- (void)accessAcommendLoginPwd:(NSString *)oldPassword andPassword:(NSString *)password andVerifyPassword:(NSString *)verifyPassword{
    NSString *path = [NSString stringWithFormat:@"%@%@",SERVERADRESS,Q_ACOMMEND_LOGIN_KEY];
    NSURL *url = [NSURL URLWithString:path];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:oldPassword forKey:@"oldPassword"];
    [request setPostValue:password forKey:@"password"];
    [request setPostValue:verifyPassword forKey:@"verifyPassword"];
    [request setUseCookiePersistence:YES];
    [self setGetMthodWith:request andRequestType:kSureFindLoginPwd];
    [_networkQueue addOperation:request];
}
//修改绑定手机
- (void)accessChangeBindPhone:(NSString *)phone andVerifyCode:(NSString *)verifyCode{
    NSString *path = [NSString stringWithFormat:@"%@%@",SERVERADRESS,Q_CHANGEBINDPHONE];
    NSURL *url = [NSURL URLWithString:path];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:phone forKey:@"phone"];
    [request setPostValue:verifyCode forKey:@"verifyCode"];
    [request setUseCookiePersistence:YES];
    [self setGetMthodWith:request andRequestType:kChangeBindPhone];
    [_networkQueue addOperation:request];
}

//验证绑定手机
- (void)accessConfirmBindPhone:(NSString *)phone andVerifyCode:(NSString *)verifyCode{
    NSString *path = [NSString stringWithFormat:@"%@%@",SERVERADRESS,Q_CONFIRM_BIND_PHONE];
    NSURL *url = [NSURL URLWithString:path];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:phone forKey:@"phone"];
    [request setPostValue:verifyCode forKey:@"verifyCode"];
    [request setUseCookiePersistence:YES];
    [self setGetMthodWith:request andRequestType:kConfirmBindPhone];
    [_networkQueue addOperation:request];
}
//修改支付密码
- (void)accessAcommendPayPwd:(NSString *)oldPayPasswd andNewPayPasswd:(NSString *)newPayPasswd andVerifyNewPayPasswd:(NSString *)verifyNewPayPasswd{
    NSString *path = [NSString stringWithFormat:@"%@%@",SERVERADRESS,Q_ACOMMENDPAYPWD];
    NSURL *url = [NSURL URLWithString:path];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:oldPayPasswd forKey:@"oldPayPasswd"];
    [request setPostValue:newPayPasswd forKey:@"newPayPasswd"];
    [request setPostValue:verifyNewPayPasswd forKey:@"verifyNewPayPasswd"];
    [request setUseCookiePersistence:YES];
    [self setGetMthodWith:request andRequestType:kAcommendPayPwd];
    [_networkQueue addOperation:request];
}
//找回支付密码
- (void)accessFindePayPwd:(NSString *)phone andVerifyCode:(NSString *)verifyCode{
    NSString *path = [NSString stringWithFormat:@"%@%@",SERVERADRESS,Q_FINDPAYPWD];
    NSURL *url = [NSURL URLWithString:path];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:phone forKey:@"phone"];
    [request setPostValue:verifyCode forKey:@"verifyCode"];
    [request setUseCookiePersistence:YES];
    [self setGetMthodWith:request andRequestType:kFindPayPwd];
    [_networkQueue addOperation:request];
}
//设置支付密码
- (void)accessSetPayPwd:(NSString *)payPasswd andVerifyPayPasswd:(NSString *)verifyPayPasswd andPhone:(NSString *)phone andVerifyCode:(NSString *)verifyCode{
    NSString *path = [NSString stringWithFormat:@"%@%@",SERVERADRESS,Q_SET_PAYPWD];
    NSURL *url = [NSURL URLWithString:path];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:payPasswd forKey:@"payPasswd"];
    [request setPostValue:verifyPayPasswd forKey:@"verifyPayPasswd"];
    [request setPostValue:phone forKey:@"phone"];
    [request setPostValue:verifyCode forKey:@"verifyCode"];
    [request setUseCookiePersistence:YES];
    [self setGetMthodWith:request andRequestType:kSetPayPwd];
    [_networkQueue addOperation:request];
}
//重置支付密码
- (void)accessReSetPayPwd:(NSString *)payPasswd andVerifyPayPasswd:(NSString *)verifyPayPasswd
{
    NSString *path = [NSString stringWithFormat:@"%@%@",SERVERADRESS,Q_RESET_PAYPWD];
    NSURL *url = [NSURL URLWithString:path];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:payPasswd forKey:@"newPayPasswd"];
    [request setPostValue:verifyPayPasswd forKey:@"verifyNewPayPasswd"];
    [request setUseCookiePersistence:YES];
    [self setGetMthodWith:request andRequestType:kReSetPayPwd];
    [_networkQueue addOperation:request];
}

//注册
- (void)accessRegister:(NSString *)phone andVerifyCode:(NSString *)verifyCode andPassword:(NSString *)password andVerifyPassword:(NSString *)verifyPassword{
    NSString *path = [NSString stringWithFormat:@"%@%@",SERVERADRESS,Q_REGISTER];
    NSURL *url = [NSURL URLWithString:path];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:phone forKey:@"phone"];
    [request setPostValue:verifyCode forKey:@"verifyCode"];
    [request setPostValue:password forKey:@"password"];
    [request setPostValue:verifyPassword forKey:@"verifyPassword"];
    [request setUseCookiePersistence:YES];
    [self setGetMthodWith:request andRequestType:kRegister];
    [_networkQueue addOperation:request];
}
//找回登录密码
- (void)accessFindLoginPwd:(NSString *)phone andVerifyCode:(NSString *)verifyCode{
    NSString *path = [NSString stringWithFormat:@"%@%@",SERVERADRESS,Q_FIND_LOGIN_PWD];
    NSURL *url = [NSURL URLWithString:path];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:phone forKey:@"phone"];
    [request setPostValue:verifyCode forKey:@"verifyCode"];
    [request setUseCookiePersistence:YES];
    [self setGetMthodWith:request andRequestType:kFindLoginPwd];
    [_networkQueue addOperation:request];
}
//确认找回登录密码
- (void)accessSureFindLoginPwd:(NSString *)newPassword andVerifyNewPassword:(NSString *)verifyNewPassword{
    NSString *path = [NSString stringWithFormat:@"%@%@",SERVERADRESS,Q_SURE_FIND_LOGIN_PWD];
    NSURL *url = [NSURL URLWithString:path];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:newPassword forKey:@"newPassword"];
    [request setPostValue:verifyNewPassword forKey:@"verifyNewPassword"];
    [request setUseCookiePersistence:YES];
    [self setGetMthodWith:request andRequestType:kSureFindLoginPwd];
    [_networkQueue addOperation:request];
}
//不同状态订单数
- (void)accessGetListQtyAccordingDifStatus:(NSString *)customerId{
    NSString *path = [NSString stringWithFormat:@"%@%@",SERVERADRESS,Q_DIF_STATUS_LIST_QTY];
    NSURL *url = [NSURL URLWithString:path];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:customerId forKey:@"customerId"];
    [request setUseCookiePersistence:YES];
    [self setGetMthodWith:request andRequestType:kDifStatusListQty];
    [_networkQueue addOperation:request];
}
//不同状态订单
- (void)accessGetListAccordStatus:(NSString *)status andcurrentPage:(NSString *)currentPage andPageSize:(NSString *)pageSize{
    NSString *path = [NSString stringWithFormat:@"%@%@",SERVERADRESS,Q_DIF_STATUS_LIST];
    NSURL *url = [NSURL URLWithString:path];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:status forKey:@"status"];
    [request setPostValue:currentPage forKey:@"currentPage"];
    [request setPostValue:pageSize forKey:@"pageSize"];
    [request setUseCookiePersistence:YES];
    [self setGetMthodWith:request andRequestType:kDifStatusList];
    [_networkQueue addOperation:request];
}

//我的账户
- (void)accessMyAccount{
    NSString *path = [NSString stringWithFormat:@"%@%@",SERVERADRESS,Q_MY_ACCOUNT];
    NSURL *url = [NSURL URLWithString:path];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [self setGetMthodWith:request andRequestType:kMyAccount];
    [_networkQueue addOperation:request];
}

//我的订单详情
- (void)accessMyListDetail:(NSString *)orderListId andStatus:(NSString *)status{
    NSString *path = [NSString stringWithFormat:@"%@%@",SERVERADRESS,Q_MY_LIST_DETAIL];
    NSURL *url = [NSURL URLWithString:path];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:orderListId forKey:@"orderListId"];
    [request setPostValue:status forKey:@"status"];
    [request setUseCookiePersistence:YES];
    [self setGetMthodWith:request andRequestType:kMyListDetail];
    [_networkQueue addOperation:request];
}

//编辑删除
- (void)accessEditDelegate:(NSString *)orderIds{
    NSString *path = [NSString stringWithFormat:@"%@%@",SERVERADRESS,Q_DELEGATE_LIST];
    NSURL *url = [NSURL URLWithString:path];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:orderIds forKey:@"orderIdList"];
    [request setUseCookiePersistence:YES];
    [self setGetMthodWith:request andRequestType:keditDelegate];
    [_networkQueue addOperation:request];
}

//订单评价
- (void)accessSetListRemark:(NSString *)content andUserId:(NSString *)userId andProductId:(NSString *)productId andServiceAttitude:(NSString *)serviceAttitude andQuality:(NSString *)quality andEnvironment:(NSString *)environment andDescription:(NSString *)description andCommentType:(NSString *)commentType andCompanyId:(NSString *)companyId andOrderListId:(NSString *)orderListId{
    NSString *path = [NSString stringWithFormat:@"%@%@",SERVERADRESS,Q_LIST_REMARK];
    NSURL *url = [NSURL URLWithString:path];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:content forKey:@"content"];
    [request setPostValue:userId forKey:@"userId"];
    [request setPostValue:productId forKey:@"productId"];
    [request setPostValue:serviceAttitude forKey:@"serviceAttitude"];
    [request setPostValue:quality forKey:@"quality"];
    [request setPostValue:environment forKey:@"environment"];
    [request setPostValue:description forKey:@"description"];
    [request setPostValue:commentType forKey:@"commentType"];
    [request setPostValue:companyId forKey:@"companyId"];
    [request setPostValue:orderListId forKey:@"orderListId"];
    [request setUseCookiePersistence:YES];
    [self setGetMthodWith:request andRequestType:kListRemark];
    [_networkQueue addOperation:request];
}

//收藏
- (void)accessMyfavority:(NSString *)currentPage andPageSize:(NSString *)pageSize
{
    NSString *path = [NSString stringWithFormat:@"%@%@",SERVERADRESS,Q_MY_FAVORITE];
    NSURL *url = [NSURL URLWithString:path];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:currentPage forKey:@"currentPage"];
    [request setPostValue:pageSize forKey:@"pageSize"];
    [self setGetMthodWith:request andRequestType:kMyFavorite];
    [_networkQueue addOperation:request];
}

//添加收藏
- (void)accessAddMyFavorite:(NSString *)companyId andProductId:(NSString *)productId andCategoryId:(NSString *)categoryId{
    NSString *path = [NSString stringWithFormat:@"%@%@",SERVERADRESS,Q_ADD_MYFAVORITE];
    NSURL *url = [NSURL URLWithString:path];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:companyId forKey:@"companyId"];
    [request setPostValue:productId forKey:@"productId"];
    [request setPostValue:categoryId forKey:@"categoryId"];
    [request setUseCookiePersistence:YES];
    [self setGetMthodWith:request andRequestType:kAddMyFavorite];
    [_networkQueue addOperation:request];
}

//添加订单
- (void)accessAddList:(NSString *)productId andQuantity:(NSString *)quantity andBidType:(NSString*)bidType
{
    NSString *path = [NSString stringWithFormat:@"%@%@",SERVERADRESS,Q_ADD_LIST];
    NSURL *url = [NSURL URLWithString:path];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:productId forKey:@"productId"];
    [request setPostValue:quantity forKey:@"quantity"];
    [request setPostValue:bidType forKey:@"bidtype"];
    [request setUseCookiePersistence:YES];
    [self setGetMthodWith:request andRequestType:kAddList];
    [_networkQueue addOperation:request];
}

//商家列表
- (void)accessBusinessListThourghLocation:(NSString *)regionId andCategory:(NSString*)categoryId andLongitude:(NSNumber*)longitude andLatitude:(NSNumber*)latitude andCurrentPage:(NSString *)currentPage andPageSize:(NSString *)pageSize{
    NSString *path = [NSString stringWithFormat:@"%@%@",SERVERADRESS,Q_BUSINESSLIST];
    NSURL *url = [NSURL URLWithString:path];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:regionId forKey:@"regionId"];
    [request setPostValue:categoryId forKey:@"categoryId"];
    [request setPostValue:longitude forKey:@"longitude"];
    [request setPostValue:latitude forKey:@"latitude"];
    [request setPostValue:currentPage forKey:@"currentPage"];
    [request setPostValue:pageSize forKey:@"pageSize"];
    [request setUseCookiePersistence:YES];
    [self setGetMthodWith:request andRequestType:kBusinessList];
    [_networkQueue addOperation:request];
}

//商家详情
- (void)accessBusinessDetail:(NSString *)companyId{
    NSString *path = [NSString stringWithFormat:@"%@%@",SERVERADRESS,Q_BUSINESS_DETAIL];
    NSURL *url = [NSURL URLWithString:path];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:companyId forKey:@"companyId"];
    [request setUseCookiePersistence:YES];
    [self setGetMthodWith:request andRequestType:kBusinessDetail];
    [_networkQueue addOperation:request];
}

//首页列表
- (void)accessHomePageList:(NSString *)regionId andLongitude:(NSString *)longitude andLatitude:(NSString *)latitude andCurrentPage:(NSString *)currentPage
{
    NSString *path = [NSString stringWithFormat:@"%@%@",SERVERADRESS,Q_HOME_PAGE_LIST];
    NSURL *url = [NSURL URLWithString:path];
    
    //获取全局变量
    QAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url usingCache:appDelegate.myCache andCachePolicy:ASIUseDefaultCachePolicy];
    
    //设置缓存方式
    [request setDownloadCache:appDelegate.myCache];
    
    //设置缓存数据存储策略，这里采取的是如果无更新或无法联网就读取缓存数据
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    [request setRequestMethod:@"POST"];
    [request setPostValue:regionId forKey:@"regionId"];
    [request setPostValue:longitude forKey:@"longitude"];
    [request setPostValue:latitude forKey:@"latitude"];
    [request setPostValue:currentPage forKey:@"currentPage"];
    [request setUseCookiePersistence:YES];
    [self setGetMthodWith:request andRequestType:kHomePageList];
    [_networkQueue addOperation:request];
}

//商品详情
- (void)accessProductDetail:(NSString *)productId{
    NSString *path = [NSString stringWithFormat:@"%@%@",SERVERADRESS,Q_PRODUCTDETAIL];
    NSURL *url = [NSURL URLWithString:path];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    NSNumber *proId = [NSNumber numberWithInt:[productId intValue]];
    [request setPostValue:proId forKey:@"productId"];
    [request setUseCookiePersistence:YES];
    [self setGetMthodWith:request andRequestType:kProductDetail];
    [_networkQueue addOperation:request];
}

//洗车列表
- (void)accessCarWashList:(NSString *)regionId andCategoryId:(NSString *)categoryId andLongitude:(NSString *)longitude andLatitude:(NSString *)latitude andKey:(NSString *)key andCurrentPage:(NSString *)currentPage andPageSize:(NSString *)pageSize
{
    NSString *path = [NSString stringWithFormat:@"%@%@",SERVERADRESS,Q_CARWASH_LIST];
    NSURL *url = [NSURL URLWithString:path];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:regionId forKey:@"regionId"];
    [request setPostValue:categoryId forKey:@"categoryId"];
    [request setPostValue:currentPage forKey:@"currentPage"];
    [request setPostValue:pageSize forKey:@"pageSize"];
    [request setPostValue:longitude forKey:@"longitude"];
    [request setPostValue:latitude forKey:@"latitude"];
    [request setPostValue:key forKey:@"key"];
    [request setUseCookiePersistence:YES];
    [self setGetMthodWith:request andRequestType:kCarWashList];
    [_networkQueue addOperation:request];
}

//洗车选项
- (void)accessCarWashOption:(NSString *)companyId{
    NSString *path = [NSString stringWithFormat:@"%@%@",SERVERADRESS,Q_CAR_WASH_OPTION];
    NSURL *url = [NSURL URLWithString:path];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:companyId forKey:@"companyId"];
    [request setUseCookiePersistence:YES];
    [self setGetMthodWith:request andRequestType:kCarWashOption];
    [_networkQueue addOperation:request];
}
//更多分类
- (void)accessCategorySubList
{
    NSString *path = [NSString stringWithFormat:@"%@%@",SERVERADRESS,Q_Category_SubList];
    NSURL *url = [NSURL URLWithString:path];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setUseCookiePersistence:YES];
    [self setGetMthodWith:request andRequestType:kCategorySubList];
    [_networkQueue addOperation:request];
}

//我的车夫券
- (void)accessMyCoupon:(NSString *)bidtype{
    NSString *path = [NSString stringWithFormat:@"%@%@",SERVERADRESS,Q_MY_COUPON];
    NSURL *url = [NSURL URLWithString:path];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:bidtype forKey:@"bidtype"];
    [request setUseCookiePersistence:YES];
    [self setGetMthodWith:request andRequestType:kMyCoupon];
    [_networkQueue addOperation:request];
}
//我的车夫券详情
- (void)accessMyCouponDetail:(NSString *)orderListId{
    NSString *path = [NSString stringWithFormat:@"%@%@",SERVERADRESS,Q_MY_COUPON_DETAIL];
    NSURL *url = [NSURL URLWithString:path];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:orderListId forKey:@"orderListId"];
    [request setUseCookiePersistence:YES];
    [self setGetMthodWith:request andRequestType:kMyCouponDetail];
    [_networkQueue addOperation:request];
}

//支付操作
- (void)payAction:(NSString *)strPwd andOrderListId:(NSString*)strOrder andPayType:(BOOL)isAliPay
{
    NSString *path = [NSString stringWithFormat:@"%@%@",SERVERADRESS,Q_PAY_OPERATION];
    NSURL *url = [NSURL URLWithString:path];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    if (strPwd)
        [request setPostValue:strPwd forKey:@"payPasswd"];
    [request setPostValue:strOrder forKey:@"orderListId"];
    if (isAliPay)
        [request setPostValue:@"y" forKey:@"key"];
    [request setUseCookiePersistence:YES];
    [self setGetMthodWith:request andRequestType:kPayResult];
    [_networkQueue addOperation:request];
}

//创建会员卡充值订单
- (void)createPrePayBillIDByregionId:(NSString *)regionID amount:(NSString *)amount memberTypeId:(NSString *)typeID payMode:(NSString *)pmode
{
    NSString *path = [NSString stringWithFormat:@"%@%@",SERVERADRESS,Q_VIPCARD_BILL];
    NSURL *url = [NSURL URLWithString:path];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    
    [request setPostValue:regionID forKey:@"regionId"];
    [request setPostValue:amount forKey:@"amount"];
    [request setPostValue:typeID forKey:@"memberTypeId"];
    [request setPostValue:pmode forKey:@"payMode"];
    
    [request setUseCookiePersistence:YES];
    [self setGetMthodWith:request andRequestType:kCreatVipPrePayID];
    [_networkQueue addOperation:request];
}

//普通账户充值订单
- (void)createAccPrePayBillIDByregionId:(NSString *)regionID amount:(NSString *)amount prepaidType:(NSString *)typeID payMode:(NSString *)pmode accountId:(NSString*)accountId
{
    NSString *path = [NSString stringWithFormat:@"%@%@",SERVERADRESS,Q_ACC_BILL];
    NSURL *url = [NSURL URLWithString:path];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    
    [request setPostValue:regionID forKey:@"regionId"];
    [request setPostValue:amount forKey:@"amount"];
    [request setPostValue:typeID forKey:@"prepaidType"];
    [request setPostValue:pmode forKey:@"payMode"];
    [request setPostValue:accountId forKey:@"accountId"];
    
    [request setUseCookiePersistence:YES];
    [self setGetMthodWith:request andRequestType:kCreatAccPrePayID];
    [_networkQueue addOperation:request];
}

//退款
- (void)drawBack:(NSString *)payId andReson:(NSString*)reason
{
    NSString *path = [NSString stringWithFormat:@"%@%@",SERVERADRESS,Q_DRAW_BACK];
    NSURL *url = [NSURL URLWithString:path];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    
    [request setPostValue:payId forKey:@"payId"];
    [request setPostValue:reason forKey:@"reason"];
    
    [request setUseCookiePersistence:YES];
    [self setGetMthodWith:request andRequestType:kDrawback];
    [_networkQueue addOperation:request];
}

//删除收藏
- (void)accessDelectMyFavority:(NSString *)orderListId{
    NSString *path = [NSString stringWithFormat:@"%@%@",SERVERADRESS,Q_DELECT_MYFAVORITE];
    NSURL *url = [NSURL URLWithString:path];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:orderListId forKey:@"favoritesId"];
    [request setUseCookiePersistence:YES];
    [self setGetMthodWith:request andRequestType:kDelectMyFavorite];
    [_networkQueue addOperation:request];
}

//搜索商家/商品
- (void)accessSearch
{
    NSString *path = [NSString stringWithFormat:@"%@%@",SERVERADRESS,Q_SEARCH];
    NSURL *url = [NSURL URLWithString:path];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setUseCookiePersistence:YES];
    [self setGetMthodWith:request andRequestType:kDelectMyFavorite];
    [_networkQueue addOperation:request];

}
//本商家所有商品列表
- (void)accessCompanyProduct:(NSString*)companyId andRegionID:(NSString*)regionID
{
    NSString *path = [NSString stringWithFormat:@"%@%@", SERVERADRESS, Q_COMPANY_PRODUCT];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:path]];
    [request setRequestMethod:@"POST"];
    [request setPostValue:companyId forKey:@"companyId"];
    [request setPostValue:regionID forKey:@"regionId"];
    [request setUseCookiePersistence:YES];
    [self setGetMthodWith:request andRequestType:kCompanyProduct];
    [_networkQueue addOperation:request];
}

//热门词
- (void)accessHotSearchWord
{
    NSString *path = [NSString stringWithFormat:@"%@%@", SERVERADRESS, Q_HOT_SEARCHWORD];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:path]];
    [request setRequestMethod:@"POST"];
    [request setUseCookiePersistence:YES];
    [self setGetMthodWith:request andRequestType:kHotSearchWord];
    [_networkQueue addOperation:request];
}

//搜索商家
- (void)accessSearchBusiness:(NSString*)keyWord
{
    NSString *path = [NSString stringWithFormat:@"%@%@", SERVERADRESS, Q_SEARCH_BUSINESS];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:path]];
    [request setRequestMethod:@"POST"];
    [request setPostValue:keyWord forKey:@"keyword"];
    [request setUseCookiePersistence:YES];
    [self setGetMthodWith:request andRequestType:kSearchBusiness];
    [_networkQueue addOperation:request];
}

//会员卡概览
- (void)accessCardDetails
{
    NSString *path = [NSString stringWithFormat:@"%@%@", SERVERADRESS, Q_CARD_DETAILS];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:path]];
    [request setRequestMethod:@"POST"];
    [request setUseCookiePersistence:YES];
    [self setGetMthodWith:request andRequestType:kCardDetails];
    [_networkQueue addOperation:request];
}

//协议
- (void)accessGetAgreement:(int)agreementType
{
    NSString *path = [NSString stringWithFormat:@"%@%@", SERVERADRESS, Q_GET_AGREEMENT];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:path]];
    [request setRequestMethod:@"POST"];
    [request setPostValue:[NSNumber numberWithInt:agreementType] forKey:@"agreementType"];
    [request setUseCookiePersistence:YES];
    [self setGetMthodWith:request andRequestType:kGetAgreement];
    [_networkQueue addOperation:request];
}

//意见反馈
- (void)accessSuggestRetroaction:(NSString *)retroaction{
    NSString *path = [NSString stringWithFormat:@"%@%@", SERVERADRESS, Q_SUGGEST_RETROACTION];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:path]];
    [request setRequestMethod:@"POST"];
    [request setPostValue:retroaction forKey:@"content"];
    [request setUseCookiePersistence:YES];
    [self setGetMthodWith:request andRequestType:kSuggestRetroaction];
    [_networkQueue addOperation:request];
}
//会员卡延期
- (void)accessDelayExpire
{
    NSString *path = [NSString stringWithFormat:@"%@%@", SERVERADRESS, Q_DELAY_EXPIRE];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:path]];
    [request setRequestMethod:@"POST"];
    [request setUseCookiePersistence:YES];
    [self setGetMthodWith:request andRequestType:kDelayExpire];
    [_networkQueue addOperation:request];
}

//我的会员卡
- (void)accessGetMyMemberCard
{
    NSString *path = [NSString stringWithFormat:@"%@%@", SERVERADRESS, Q_MY_MEMBERCARD];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:path]];
    [request setRequestMethod:@"POST"];
    [request setUseCookiePersistence:YES];
    [self setGetMthodWith:request andRequestType:kMyMemberCard];
    [_networkQueue addOperation:request];
}

@end
