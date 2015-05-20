//
//  QHttpMessageManager.m
//  HRClient
//
//  Created by ekoo on 15/1/4.
//  Copyright (c) 2015年 panyj. All rights reserved.
//

#import "QHttpMessageManager.h"
#import "QLoginModel.h"
#import "QDifStatusListQtyModel.h"
#import "QMyListDetailModel.h"
#import "QProductDetail.h"
#import "QMyListModel.h"
#import "QRegisterModel.h"

@interface QHttpMessageManager ()
@property (nonatomic,strong)QHttpManager *httpManager;

@end

static QHttpMessageManager *httpMessageManager = nil;

@implementation QHttpMessageManager

+ (QHttpMessageManager *)sharedHttpMessageManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        httpMessageManager = [[super allocWithZone:NULL] init];
    });
    return httpMessageManager;
}

- (id)init{
    if (self = [super init]) {
        _httpManager = [[QHttpManager alloc] initWithDelegate:self];
        [self.httpManager start];
    }
    return self;
}

- (void)didGetDataFailed:(RequestType)type
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kInterfaceFailed object:[NSNumber numberWithInt:type]];
}

- (void)accessHotCity{
    [self.httpManager accessHotCity];
}

- (void)didGetHotCity:(NSMutableArray *)dataArr{
    [[NSNotificationCenter defaultCenter] postNotificationName:kHotCity object:dataArr];
}

//退单
- (void)retDrawback:(NSNumber*)retStatus
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kDrawback object:retStatus];
}

- (void)accessGetRegion:(NSString*)parentId{
    [self.httpManager accessGetRegion:parentId];
}
- (void)didGetRegion:(NSMutableArray *)dataArr{
    [[NSNotificationCenter defaultCenter] postNotificationName:kGetRegion object:dataArr];
}

- (void)accessAcquireCode:(NSString *)phone andMessage:(NSString *)message{
    [self.httpManager accessAcquireCode:phone andMessage:message];
}
//- (void)accessAcquireCode:(NSString *)phone{
//    [self.httpManager accessAcquireCode:phone];
//}

- (void)didGetAcquireCode:(NSString *)whetherSuccess{
    [[NSNotificationCenter defaultCenter] postNotificationName:kAcquireCode object:whetherSuccess];
}
//登录
- (void)accessLogin:(NSString *)nick andPassword:(NSString *)password{
    [self.httpManager accessLogin:nick andPassword:password];
}
- (void)didGetLogin:(QLoginModel *)dataArr{
    [[NSNotificationCenter defaultCenter] postNotificationName:kLogin object:dataArr];
}
//商家评论
- (void)accessBusinessComment:(NSString*)companyId andPage:(int)pageSize andIndex:(int)index{
    [self.httpManager accessBussinessComment:companyId andPage:pageSize andIndex:index];
}
- (void)didGetBusinessComment:(NSMutableArray *)dataArr{
    [[NSNotificationCenter defaultCenter] postNotificationName:kBusinessComment object:dataArr];
}
//商品评论
- (void)accessProductComment:(NSString*)companyId andProductID:(NSString *)productId andPage:(int)pageSize andIndex:(int)index{
    [self.httpManager accessProductComment:companyId andProductID:productId andPage:index andIndex:index];
}
- (void)didGetProductComment:(NSMutableArray *)dataArr{
    [[NSNotificationCenter defaultCenter] postNotificationName:kProductComment object:dataArr];
}
//修改账户名
- (void)accessAcommendNick:(NSString *)nick{
    [self.httpManager accessAcommendNick:nick];
}

- (void)didGetNick:(NSString *)alertStr{
    [[NSNotificationCenter defaultCenter] postNotificationName:kAcommendNick object:alertStr];
}

//修改登录密码
- (void)accessAcommendLoginPwd:(NSString *)oldPassword andPassword:(NSString *)password andVerifyPassword:(NSString *)verifyPassword{
    [self.httpManager accessAcommendLoginPwd:oldPassword andPassword:password andVerifyPassword:verifyPassword];
}
- (void)didGetNewLoginPwd:(NSString *)message{
    [[NSNotificationCenter defaultCenter] postNotificationName:kAcommendLoginPwd object:message];
}
//验证绑定手机
- (void)accessConfirmBindPhone:(NSString *)phone andVerifyCode:(NSString *)verifyCode{
    [self.httpManager accessConfirmBindPhone:phone andVerifyCode:verifyCode];
}
- (void)didGetConfirmBindPhone:(NSString *)message{
    [[NSNotificationCenter defaultCenter] postNotificationName:kConfirmBindPhone object:message];
}
//修改绑定手机
- (void)accessChangeBindPhone:(NSString *)phone andVerifyCode:(NSString *)verifyCode{
    [self.httpManager accessChangeBindPhone:phone andVerifyCode:verifyCode];
}
- (void)didGetNewBindPhone:(NSString *)message{
    [[NSNotificationCenter defaultCenter] postNotificationName:kChangeBindPhone object:message];
}
//修改支付密码
- (void)accessAcommendPayPwd:(NSString *)oldPayPasswd andNewPayPasswd:(NSString *)newPayPasswd andVerifyNewPayPasswd:(NSString *)verifyNewPayPasswd{
    [self.httpManager accessAcommendPayPwd:oldPayPasswd andNewPayPasswd:newPayPasswd andVerifyNewPayPasswd:verifyNewPayPasswd];
}
- (void)didGetNewPayPwd:(NSString *)message{
    [[NSNotificationCenter defaultCenter] postNotificationName:kAcommedPayPwd object:message];
}
//找回支付密码
- (void)accessFindePayPwd:(NSString *)phone andVerifyCode:(NSString *)verifyCode{
    [self.httpManager accessFindePayPwd:phone andVerifyCode:verifyCode];
}
- (void)didGetPayPwd:(NSString *)message{
    [[NSNotificationCenter defaultCenter] postNotificationName:kFindPayPwd object:message];
}
//设置支付密码
- (void)accessSetPayPwd:(NSString *)payPasswd andVerifyPayPasswd:(NSString *)verifyPayPasswd andPhone:(NSString *)phone andVerifyCode:(NSString *)verifyCode{
    [self.httpManager accessSetPayPwd:payPasswd andVerifyPayPasswd:verifyPayPasswd andPhone:phone andVerifyCode:verifyCode];
}
- (void)didSetPayPwd:(NSString *)message{
    [[NSNotificationCenter defaultCenter] postNotificationName:kSetPayPwd object:message];
}

- (void)accessReSetPayPwd:(NSString *)payPasswd andVerifyPayPasswd:(NSString *)verifyPayPasswd{
    [self.httpManager accessReSetPayPwd:payPasswd andVerifyPayPasswd:verifyPayPasswd];
}

- (void)didReSetPayPwd:(NSString*)message{
    [[NSNotificationCenter defaultCenter] postNotificationName:kReSetPayPwd object:message];
}

//注册
- (void)accessRegister:(NSString *)phone andVerifyCode:(NSString *)verifyCode andPassword:(NSString *)password andVerifyPassword:(NSString *)verifyPassword{
    [self.httpManager accessRegister:phone andVerifyCode:verifyCode andPassword:password andVerifyPassword:verifyPassword];
}
- (void)didGetNewUserInfro:(QRegisterModel *)dataModel{
    [[NSNotificationCenter defaultCenter] postNotificationName:kRegister object:dataModel];
}
//找回登录密码
- (void)accessFindLoginPwd:(NSString *)phone andVerifyCode:(NSString *)verifyCode{
    [self.httpManager accessFindLoginPwd:phone andVerifyCode:verifyCode];
}
- (void)didGetLoginPwd:(QLoginModel *)dataArr{
    [[NSNotificationCenter defaultCenter] postNotificationName:kFindLoginPwd  object:dataArr];
}

//确认找回登录密码
- (void)accessSureFindLoginPwd:(NSString *)newPassword andVerifyNewPassword:(NSString *)verifyNewPassword{
    [self.httpManager accessSureFindLoginPwd:newPassword andVerifyNewPassword:verifyNewPassword];
}
- (void)didGetSureFindLginPwd:(NSString *)message{
    [[NSNotificationCenter defaultCenter] postNotificationName:kSureFindLoginPwd object:message];
}
//不同状态订单数
- (void)accessGetListQtyAccordingDifStatus:(NSString *)customerId{
    [self.httpManager accessGetListQtyAccordingDifStatus:customerId];
}
- (void)didGetQtyInDifStatus:(QDifStatusListQtyModel *)dataArr{
    [[NSNotificationCenter defaultCenter] postNotificationName:kGetQtyAccountStatus object:dataArr];
}
//不同状态订单
- (void)accessGetListAccordStatus:(NSString *)status andcurrentPage:(NSString *)currentPage andPageSize:(NSString *)pageSize{
    [self.httpManager accessGetListAccordStatus:status andcurrentPage:currentPage andPageSize:pageSize];
}
- (void)didGetDifStatusList:(NSMutableArray *)dataArr{
    [[NSNotificationCenter defaultCenter] postNotificationName:kGetListAccountStatus object:dataArr];
}
//我的账户
- (void)accessMyAccount{
    [self.httpManager accessMyAccount];
}
- (void)didGetMyAccountInfro:(NSMutableArray *)dataArr{
    [[NSNotificationCenter defaultCenter] postNotificationName:kGetMyAccountInfro object:dataArr];
}
//我的订单详情
- (void)accessMyListDetail:(NSString *)orderListId andStatus:(NSString *)status{
    [self.httpManager accessMyListDetail:orderListId andStatus:status];
}
- (void)didGetMyListDetail:(QMyListDetailModel *)dataArr{
    [[NSNotificationCenter defaultCenter] postNotificationName:kGetMyListDetail object:dataArr];
}
//编辑删除
- (void)accessEditDelegate:(NSString *)orderIds{
    [self.httpManager accessEditDelegate:orderIds];
}
- (void)didGetEditDelegate:(NSString *)message{
    [[NSNotificationCenter defaultCenter] postNotificationName:kGetEditDelegate object:message];
}
//订单评价
- (void)accessSetListRemark:(NSString *)content andUserId:(NSString *)userId andProductId:(NSString *)productId andServiceAttitude:(NSString *)serviceAttitude andQuality:(NSString *)quality andEnvironment:(NSString *)environment andDescription:(NSString *)description andCommentType:(NSString *)commentType andCompanyId:(NSString *)companyId andOrderListId:(NSString *)orderListId{
    [self.httpManager accessSetListRemark:content andUserId:userId andProductId:productId andServiceAttitude:serviceAttitude andQuality:quality andEnvironment:environment andDescription:description andCommentType:commentType andCompanyId:companyId andOrderListId:orderListId];
}
- (void)didGetListRemark:(NSString *)message{
    [[NSNotificationCenter defaultCenter] postNotificationName:kListRemark object:message];
}
//收藏
- (void)accessMyfavority:(NSString *)currentPage andPageSize:(NSString *)pageSize
{
    [self.httpManager accessMyfavority:currentPage andPageSize:pageSize];
}
- (void)didiGetMyFavority:(NSMutableArray *)dataArr{
    [[NSNotificationCenter defaultCenter] postNotificationName:kMyFavority object:dataArr];
}

//添加收藏
- (void)accessAddMyFavorite:(NSString *)companyId andProductId:(NSString *)productId andCategoryId:(NSString *)categoryId{
    [self.httpManager accessAddMyFavorite:companyId andProductId:productId andCategoryId:categoryId];
}
- (void)didAddMyFavority:(NSString *)message{
    [[NSNotificationCenter defaultCenter] postNotificationName:kAddMyFavority object:message];
}
//删除收藏
- (void)accessDelectMyFavority:(NSString *)orderListId{
    [self.httpManager accessDelectMyFavority:orderListId];
}
- (void)didDelectMyFavority:(NSString *)message{
    [[NSNotificationCenter defaultCenter] postNotificationName:kDelectFavority object:message];
}

//添加订单
- (void)accessAddList:(NSString *)productId andQuantity:(NSString *)quantity andBidType:(NSString*)bidType
{
    [self.httpManager accessAddList:productId andQuantity:quantity andBidType:bidType];
}

- (void)didAddList:(QMyListModel *)model{
    [[NSNotificationCenter defaultCenter] postNotificationName:kAddList object:model];
}

- (void)didretList:(QMyListModel *)model
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kRetList object:model];
}

//搜索
- (void)accessSearch{
}
- (void)didSearch {
}

//商家列表
- (void)accessBusinessListThourghLocation:(NSString *)regionId andCategory:(NSString*)categoryId andLongitude:(NSNumber*)longitude andLatitude:(NSNumber*)latitude andCurrentPage:(NSString *)currentPage andPageSize:(NSString *)pageSize{
    [self.httpManager accessBusinessListThourghLocation:regionId andCategory:categoryId andLongitude:longitude andLatitude:latitude andCurrentPage:currentPage andPageSize:pageSize];
}
- (void)didGetBusinessList:(NSMutableArray *)dataArr{
    [[NSNotificationCenter defaultCenter] postNotificationName:kBusinessList object:dataArr];
}

//商家详情
- (void)accessBusinessDetail:(NSString *)companyId{
    [self.httpManager accessBusinessDetail:companyId];
}
- (void)didGetBusinessDetail:(QBusinessDetailModel *)dataModel{
    [[NSNotificationCenter defaultCenter] postNotificationName:kBusinessDetail object:dataModel];
}
//商家详情评论
- (void)didGetBusinessDetailComment:(NSMutableArray *)dataArr{
    [[NSNotificationCenter defaultCenter] postNotificationName:kBusinessDetailComment object:dataArr];
}
//商家详情商品
- (void)didGetBusinessDetailProductList:(NSMutableArray *)dataArr{
    [[NSNotificationCenter defaultCenter] postNotificationName:kBusinessDetailProduct object:dataArr];
}
//首页列表
- (void)accessHomePageList:(NSString *)regionId andLongitude:(NSString *)longitude andLatitude:(NSString *)latitude andCurrentPage:(NSString *)currentPage{
    [self.httpManager accessHomePageList:regionId andLongitude:longitude andLatitude:latitude andCurrentPage:currentPage];
}
- (void)didGetHomePageList:(NSMutableArray *)dataArr{
    [[NSNotificationCenter defaultCenter] postNotificationName:kHomePage object:dataArr];
}
//商品详情
- (void)accessProductDetail:(NSString *)productId{
    [self.httpManager accessProductDetail:productId];
}
- (void)didGetProductDetail:(QProductDetail *)dataArr{
    [[NSNotificationCenter defaultCenter] postNotificationName:kProductDetail object:dataArr];
}
//商品详情里面的商家
- (void)didGetProductDetailCompany:(QProductDetailCompany *)dataModel{
    [[NSNotificationCenter defaultCenter] postNotificationName:kProductDetailCompany object:dataModel];
}
//商品详情里面的评论
- (void)didGetProductDetailComment:(NSMutableArray *)dataArr{
    [[NSNotificationCenter defaultCenter] postNotificationName:kProductDetailComment object:dataArr];
}
//洗车列表
- (void)accessCarWashList:(NSString *)regionId andCategoryId:(NSString *)categoryId andLongitude:(NSString *)longitude andLatitude:(NSString *)latitude andKey:(NSString *)key andCurrentPage:(NSString *)currentPage andPageSize:(NSString *)pageSize{
    [self.httpManager accessCarWashList:regionId andCategoryId:categoryId andLongitude:longitude andLatitude:latitude andKey:key andCurrentPage:currentPage andPageSize:pageSize];
}
- (void)didGetCarWashList:(NSMutableArray *)dataArr{
    [[NSNotificationCenter defaultCenter] postNotificationName:kCarWashList object:dataArr];
}
//洗车选项
- (void)accessCarWashOption:(NSString *)companyId{
    [self.httpManager accessCarWashOption:companyId];
}
- (void)didGetCarWashOption:(NSMutableArray *)dataArr{
    [[NSNotificationCenter defaultCenter] postNotificationName:kCarWashOption object:dataArr];
}
//更多分类
- (void)accessCategorySubList{
    [self.httpManager accessCategorySubList];
}
- (void)didGetCategoryList:(NSMutableArray*)dataArr
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kCategoryList object:dataArr];
}
- (void)didGetCategorySubList:(NSMutableArray*)dataArr{
    [[NSNotificationCenter defaultCenter] postNotificationName:kCategorySubList object:dataArr];
}

//我的车夫券
//bidtype=0--全部 bidtype=1--消费券 bidtype=2--会员券
- (void)accessMyCoupon:(NSString *)bidtype{
    [self.httpManager accessMyCoupon:bidtype];
}
- (void)didGetMyCoupon:(NSMutableArray *)dataArr{
    [[NSNotificationCenter defaultCenter] postNotificationName:kMyCoupon object:dataArr];
}
//我的车夫券详情
- (void)accessMyCouponDetail:(NSString *)orderListId{
    [self.httpManager accessMyCouponDetail:orderListId];
}
- (void)didGetMyCouponDetail:(QMyCouponDetailModel *)dataDic{
    [[NSNotificationCenter defaultCenter] postNotificationName:kMyCouponDetail object:dataDic];
}

//支付操作和返回
- (void)payAction:(NSString *)strPwd andOrderListId:(NSString*)strOrder andPayType:(BOOL)isAliPay
{
    [self.httpManager payAction:strPwd andOrderListId:strOrder andPayType:isAliPay];
}
- (void)didGetPayResult:(int)retValue
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kPayResult object:[NSNumber numberWithInt:retValue]];
}

//创建会员卡充值订单
- (void)createPrePayBillIDByregionId:(NSString *)regionID amount:(NSString *)amount memberTypeId:(NSString *)typeID payMode:(NSString *)pmode
{
    [self.httpManager createPrePayBillIDByregionId:regionID amount:amount memberTypeId:typeID payMode:pmode];
}

- (void)didGetVipPayBill:(NSString*)vipPayBill
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kCreatVipPrePayID object:vipPayBill];
}

//创建充值余额订单
- (void)createAccPrePayBillIDByregionId:(NSString *)regionID amount:(NSString *)amount prepaidType:(NSString *)typeID payMode:(NSString *)pmode accountId:(NSString*)accountId
{
    [self.httpManager createAccPrePayBillIDByregionId:regionID amount:amount prepaidType:typeID payMode:pmode accountId:accountId];
}

//退款
- (void)drawBack:(NSString *)payId andReson:(NSString*)reason
{
    [self.httpManager drawBack:payId andReson:reason];
}

- (void)didGetAccPayBill:(NSString*)vipPayBill
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kCreatAccPrePayID object:vipPayBill];
}

- (void)accessCompanyProduct:(NSString*)companyId andRegionID:(NSString*)regionID{
    [self.httpManager accessCompanyProduct:companyId andRegionID:regionID];
}

- (void)didGetCompanyProduct:(NSMutableArray*)dataArr {
    [[NSNotificationCenter defaultCenter] postNotificationName:kCompanyProduct object:dataArr];
}

//热门搜索词
- (void)accessHotSearchWord {
    [self.httpManager accessHotSearchWord];
}
- (void)didGetHotSearchWord:(NSMutableArray*)dataArr {
    [[NSNotificationCenter defaultCenter] postNotificationName:kHotSearchWord object:dataArr];
}
//搜索商家
- (void)accessSearchBusiness:(NSString*)keyWord
{
    [self.httpManager accessSearchBusiness:keyWord];
}
- (void)didSearchBusiness:(NSMutableArray*)dataArr {
    [[NSNotificationCenter defaultCenter] postNotificationName:kSearchBusiness object:dataArr];
}

//会员卡概览
- (void)accessCardDetails
{
    [self.httpManager accessCardDetails];
}

- (void)didGetCardDetails:(NSMutableArray*)dataArr {
    [[NSNotificationCenter defaultCenter] postNotificationName:kCardDetails object:dataArr];
}

//协议
- (void)accessGetAgreement:(int)agreementType
{
    [self.httpManager accessGetAgreement:agreementType];
}

- (void)didGetAgreement:(NSMutableArray*)dataArr {
    [[NSNotificationCenter defaultCenter] postNotificationName:kGetAgreement object:dataArr];
}

//意见反馈
- (void)accessSuggestRetroaction:(NSString *)retroaction{
    [self.httpManager accessSuggestRetroaction:retroaction];
}

- (void)didGetSuggestRetroaction:(NSString *)message{
    [[NSNotificationCenter defaultCenter] postNotificationName:kSuggestRetroaction object:message];
}
//延长会员卡使用时间
- (void)accessDelayExpire
{
    [self.httpManager accessDelayExpire];
}

- (void)didDelayExpire:(NSString*)message
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kDelayExpire object:message];
}

//我的会员卡
- (void)accessGetMyMemberCard
{
    [self.httpManager accessGetMyMemberCard];
}

- (void)didGetMyMemberCard:(id)model
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kMyMemberCard object:model];
}

@end
