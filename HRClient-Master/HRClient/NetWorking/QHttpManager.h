//
//  QHttpManager.h
//  HRClient
//
//  Created by ekoo on 15/1/4.
//  Copyright (c) 2015年 panyj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Header.h"
#import "QLoginModel.h"
#import "QDifStatusListQtyModel.h"
#import "QMyListDetailModel.h"
#import "QBusinessDetailModel.h"
#import "QBusinessDetailComment.h"
#import "QBusinessDetailResult.h"
#import "QProductDetailCompany.h"
#import "QProductDetail.h"
#import "QMyCouponDetailModel.h"
#import "QAppDelegate.h"
#import "QMyListModel.h"
#import "QRegisterModel.h"

#define USER_INFO_KEY_TYPE          @"requestType"
typedef enum{
    kHotCity = 0,
    kAcquireCode,
    kLogin,
    kProductComment,
    kBusinessComment,
    kAcommendNick,
    kAcommendLoginPwd,
    kChangeBindPhone,
    kConfirmBindPhone,
    kAcommendPayPwd,
    kFindPayPwd,
    kSetPayPwd = 11 ,//设置支付密码
    kRegister,
    kFindLoginPwd,
    kSureFindLoginPwd,
    kDifStatusListQty,//不同状态订单数
    kDifStatusList,//不同状态订单
    kMyAccount,//我的账户
    kMyListDetail,//我的订单详情
    keditDelegate,//编辑删除
    kListRemark,//订单评价
    kMyFavorite = 21,//收藏
    kAddMyFavorite,//添加收藏
    kDelectMyFavorite,//删除收藏
    kSearch,//搜索
    kAddList,//添加订单
    kBusinessList,//商家列表
    kBusinessDetail,//商家详情
    kHomePageList,//首页列表
    kProductDetail,//商品详情
    kCarWashList = 31,//洗车列表
    kCarWashOption,//洗车选项
    kMyCoupon,//我的车夫券
    kMyCouponDetail,//我的车夫券详情
    kPayResult,//支付操作
    kCompanyProduct,//本商家所有商品列表
    kReSetPayPwd,//重新设置支付密码
    kCategorySubList, //更多子类
    kRegion,//获取区域
    kHotSearchWord,//热门搜索词
    kSearchBusiness,//搜索商家
    kCardDetails,//会员卡概览
    kGetAgreement,//协议
    kSuggestRetroaction,//意见反馈
    kCreatVipPrePayID,//会员卡支付订单
    kCreatAccPrePayID,//账户余额支付订单
    kDelayExpire,//延长会员卡使用时间
    kMyMemberCard,//我的会员卡
    kDrawback, //退款
}RequestType;

@protocol QiaoHttpDelegate <NSObject>
//代理方法
//接口返回失败
- (void)didGetDataFailed:(RequestType)type;
//热门城市的回调方法
- (void)didGetHotCity:(NSMutableArray *)dataArr;
//获取区域
- (void)didGetRegion:(NSMutableArray *)dataArr;
//验证码的回调方法
- (void)didGetAcquireCode:(NSString *)code;
//登录的回调方法
- (void)didGetLogin:(QLoginModel *)dataArr;
//评论
- (void)didGetBusinessComment:(NSMutableArray *)dataArr;
- (void)didGetProductComment:(NSMutableArray *)dataArr;
//修改账户名
- (void)didGetNick:(NSString *)alertStr;
//修改登录密码
- (void)didGetNewLoginPwd:(NSString *)message;
//验证绑定手机
- (void)didGetConfirmBindPhone:(NSString *)message;
//修改绑定手机
- (void)didGetNewBindPhone:(NSString *)message;
//修改支付密码
- (void)didGetNewPayPwd:(NSString *)message;
//找回支付密码
- (void)didGetPayPwd:(NSString *)message;
//设置支付密码
- (void)didSetPayPwd:(NSString *)message;
//重置支付密码
- (void)didReSetPayPwd:(NSString*)message;

//注册
- (void)didGetNewUserInfro:(QRegisterModel *)dataModel;
//找回登录密码
- (void)didGetLoginPwd:(QLoginModel *)dataArr;
//确认找回登录密码
- (void)didGetSureFindLginPwd:(NSString *)message;
//不同状态订单数
- (void)didGetQtyInDifStatus:(QDifStatusListQtyModel *)dataArr;
//不同状态订单
- (void)didGetDifStatusList:(NSMutableArray *)dataArr;
//我的账户
- (void)didGetMyAccountInfro:(NSMutableArray *)dataArr;
//我的订单详情
- (void)didGetMyListDetail:(QMyListDetailModel *)dataArr;
//编辑删除
- (void)didGetEditDelegate:(NSString *)message;
//订单评价
- (void)didGetListRemark:(NSString *)message;
//收藏
- (void)didiGetMyFavority:(NSMutableArray *)dataArr;
//添加收藏
- (void)didAddMyFavority:(NSString *)message;
//删除收藏
- (void)didDelectMyFavority:(NSString *)message;
//添加订单
- (void)didAddList:(QMyListModel *)model;
//返回已经购买的订单
- (void)didretList:(QMyListModel *)model;
//退单
- (void)retDrawback:(NSNumber*)retStatus;
//搜索商品，商铺
//- (void)did
//商家列表
- (void)didGetBusinessList:(NSMutableArray *)dataArr;
//商家详情
- (void)didGetBusinessDetail:(QBusinessDetailModel *)dataModel;
//商家详情里面的评论
- (void)didGetBusinessDetailComment:(NSMutableArray *)dataArr;
//商家详情里面的商品列表
- (void)didGetBusinessDetailProductList:(NSMutableArray *)dataArr;
//首页列表
- (void)didGetHomePageList:(NSMutableArray *)dataArr;
//商品详情
- (void)didGetProductDetail:(QProductDetail *)dataModel;
//商品详情里面的评论
- (void)didGetProductDetailComment:(NSMutableArray *)dataArr;
//商品详情里面的商家信息
- (void)didGetProductDetailCompany:(QProductDetailCompany *)dataModel;
//洗车列表
- (void)didGetCarWashList:(NSMutableArray *)dataArr;
//洗车选项
- (void)didGetCarWashOption:(NSMutableArray *)dataArr;
//更多类别
- (void)didGetCategoryList:(NSMutableArray*)dataArr;
- (void)didGetCategorySubList:(NSMutableArray*)dataArr;
//我的车夫券
- (void)didGetMyCoupon:(NSMutableArray *)dataArr;
//我的车夫券详情
- (void)didGetMyCouponDetail:(QMyCouponDetailModel *)dataDic;
//支付操作
- (void)didGetPayResult:(int)retValue;
//会员卡支付订单
- (void)didGetVipPayBill:(NSString*)vipPayBill;
//余额充值订单
- (void)didGetAccPayBill:(NSString*)vipPayBill;
//本店所有商品
- (void)didGetCompanyProduct:(NSMutableArray*)dataArr;
//热门搜索词
- (void)didGetHotSearchWord:(NSMutableArray*)dataArr;
//搜索商家
- (void)didSearchBusiness:(NSMutableArray*)dataArr;
//会员卡概览
- (void)didGetCardDetails:(NSMutableArray*)dataArr;
//协议
- (void)didGetAgreement:(NSMutableArray*)dataArr;
//意见反馈
- (void)didGetSuggestRetroaction:(NSString *)message;
//延长会员卡使用时间
- (void)didDelayExpire:(NSString*)message;
//我的会员卡
- (void)didGetMyMemberCard:(id)model;

@end


@class ASINetworkQueue;
@interface QHttpManager : NSObject

@property (nonatomic,strong)ASINetworkQueue *networkQueue;
@property (nonatomic,assign)id<QiaoHttpDelegate>delegate;

- (BOOL)isRunning;
- (void)start;
- (void)pause;
- (void)resume;
- (void)cancel;

- (id)initWithDelegate:(id<QiaoHttpDelegate>)delegate;
//需要用的方法
//热门城市
- (void)accessHotCity;
//获取区域
- (void)accessGetRegion:(NSString*)parentId;
//获取验证码
- (void)accessAcquireCode:(NSString *)phone andMessage:(NSString *)message;

//- (void)accessAcquireCode:(NSString *)phone;
//登录
- (void)accessLogin:(NSString *)nick andPassword:(NSString *)password;
//评论
- (void)accessBussinessComment:(NSString*)companyId andPage:(int)pageSize andIndex:(int)index;
- (void)accessProductComment:(NSString*)companyId andProductID:(NSString*)productId andPage:(int)pageSize andIndex:(int)index;
//修改账户名
- (void)accessAcommendNick:(NSString *)nick;
//修改登录密码
- (void)accessAcommendLoginPwd:(NSString *)oldPassword andPassword:(NSString *)password andVerifyPassword:(NSString *)verifyPassword;
//验证绑定手机
- (void)accessConfirmBindPhone:(NSString *)phone andVerifyCode:(NSString *)verifyCode;
//修改绑定手机
- (void)accessChangeBindPhone:(NSString *)phone andVerifyCode:(NSString *)verifyCode;
//修改支付密码
- (void)accessAcommendPayPwd:(NSString *)oldPayPasswd andNewPayPasswd:(NSString *)newPayPasswd andVerifyNewPayPasswd:(NSString *)verifyNewPayPasswd;
//找回支付密码
- (void)accessFindePayPwd:(NSString *)phone andVerifyCode:(NSString *)verifyCode;
//设置支付密码
- (void)accessSetPayPwd:(NSString *)payPasswd andVerifyPayPasswd:(NSString *)verifyPayPasswd andPhone:(NSString *)phone andVerifyCode:(NSString *)verifyCode;
//重置支付密码
- (void)accessReSetPayPwd:(NSString *)payPasswd andVerifyPayPasswd:(NSString *)verifyPayPasswd;
//注册
- (void)accessRegister:(NSString *)phone andVerifyCode:(NSString *)verifyCode andPassword:(NSString *)password andVerifyPassword:(NSString *)verifyPassword;
//找回登录密码
- (void)accessFindLoginPwd:(NSString *)phone andVerifyCode:(NSString *)verifyCode;
//确认找回登录密码
- (void)accessSureFindLoginPwd:(NSString *)newPassword andVerifyNewPassword:(NSString *)verifyNewPassword;
//不同状态订单数
- (void)accessGetListQtyAccordingDifStatus:(NSString *)customerId;
//不同状态订单
- (void)accessGetListAccordStatus:(NSString *)status andcurrentPage:(NSString *)currentPage andPageSize:(NSString *)pageSize;
//我的账户
- (void)accessMyAccount;
//我的订单详情
- (void)accessMyListDetail:(NSString *)orderListId andStatus:(NSString *)status;
//编辑删除
- (void)accessEditDelegate:(NSString *)orderIds;
//订单评价
- (void)accessSetListRemark:(NSString *)content andUserId:(NSString *)userId andProductId:(NSString *)productId andServiceAttitude:(NSString *)serviceAttitude andQuality:(NSString *)quality andEnvironment:(NSString *)environment andDescription:(NSString *)description andCommentType:(NSString *)commentType andCompanyId:(NSString *)companyId andOrderListId:(NSString *)orderListId;
//收藏
- (void)accessMyfavority:(NSString *)currentPage andPageSize:(NSString *)pageSize;
//添加收藏
- (void)accessAddMyFavorite:(NSString *)companyId andProductId:(NSString *)productId andCategoryId:(NSString *)categoryId;
//删除收藏
- (void)accessDelectMyFavority:(NSString *)orderListId;
//添加订单
- (void)accessAddList:(NSString *)productId andQuantity:(NSString *)quantity andBidType:(NSString*)bidType;
//商家列表
- (void)accessBusinessListThourghLocation:(NSString *)regionId andCategory:(NSString*)categoryId andLongitude:(NSNumber*)longitude andLatitude:(NSNumber*)latitude andCurrentPage:(NSString *)currentPage andPageSize:(NSString *)pageSize;
//商家详情
- (void)accessBusinessDetail:(NSString *)companyId;
//首页列表
- (void)accessHomePageList:(NSString *)regionId andLongitude:(NSString *)longitude andLatitude:(NSString *)latitude andCurrentPage:(NSString *)currentPage;
//商品详情
- (void)accessProductDetail:(NSString *)productId;
//洗车列表
- (void)accessCarWashList:(NSString *)regionId andCategoryId:(NSString *)categoryId andLongitude:(NSString *)longitude andLatitude:(NSString *)latitude andKey:(NSString *)key andCurrentPage:(NSString *)currentPage andPageSize:(NSString *)pageSize;
//洗车选项
- (void)accessCarWashOption:(NSString *)companyId;
//更多分类
- (void)accessCategorySubList;
//我的车夫券
- (void)accessMyCoupon:(NSString *)bidtype;
//我的车夫券详情
- (void)accessMyCouponDetail:(NSString *)orderListId;
//支付操作
- (void)payAction:(NSString *)strPwd andOrderListId:(NSString*)strOrder andPayType:(BOOL)isAliPay;
//创建会员卡充值订单
- (void)createPrePayBillIDByregionId:(NSString *)regionID amount:(NSString *)amount memberTypeId:(NSString *)typeID payMode:(NSString *)pmode;
//创建账户充值订单
- (void)createAccPrePayBillIDByregionId:(NSString *)regionID amount:(NSString *)amount prepaidType:(NSString *)typeID payMode:(NSString *)pmode accountId:(NSString*)accountId;
//退款
- (void)drawBack:(NSString *)payId andReson:(NSString*)reason;

//本店所有商品
- (void)accessCompanyProduct:(NSString*)companyId andRegionID:(NSString*)regionID;
//热门搜索词
- (void)accessHotSearchWord;
//搜索商家
- (void)accessSearchBusiness:(NSString*)keyWord;
//会员卡概览
- (void)accessCardDetails;
//协议
- (void)accessGetAgreement:(int)agreementType;
//意见反馈
- (void)accessSuggestRetroaction:(NSString *)retroaction;
//延长会员卡使用时间
- (void)accessDelayExpire;
//我的会员卡
- (void)accessGetMyMemberCard;

@end
