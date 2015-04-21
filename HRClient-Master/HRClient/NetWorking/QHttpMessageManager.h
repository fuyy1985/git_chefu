//
//  QHttpMessageManager.h
//  HRClient
//
//  Created by ekoo on 15/1/4.
//  Copyright (c) 2015年 panyj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QHttpManager.h"

#define kInterfaceFailed @"kInterfaceFailed"
#define kHotCity @"kHotCity"//热门城市
#define kGetRegion @"kGetRegion"
#define kAcquireCode @"kAcquireCode"
#define kLogin @"kLogin"
#define kProductComment @"kProductComment"
#define kBusinessComment @"kBusinessComment"
#define kAcommendNick @"kAcommendNick"
#define kAcommendLoginPwd @"kAcommendLoginPwd"
#define kConfirmBindPhone @"kConfirmBindPhone"
#define kChangeBindPhone @"kChangeBindPhone"
#define kAcommedPayPwd @"kAcommedPayPwd"
#define kFindPayPwd @"kFindPayPwd"
#define kSetPayPwd @"kSetPayPwd"//设置支付密码
#define kReSetPayPwd @"kResetPayPwd"
#define kRegister @"kRegister"
#define kFindLoginPwd @"kFindLoginPwd"
#define kSureFindLoginPwd @"kSureFindLoginPwd"
#define kGetQtyAccountStatus @"kGetQtyAccountStatus"
#define kGetListAccountStatus @"kGetListAccountStatus"//获取不同状态订单
#define kGetMyAccountInfro @"kGetMyAccountInfro"//我的账户
#define kGetMyListDetail @"kGetMyListDetail"//订单详情
#define kGetEditDelegate @"kGetEditDelegate"//编辑删除
#define kListRemark @"kListRemark"//订单评价
#define kMyFavority @"kMyFavority"//收藏
#define kAddMyFavority @"kAddMyFavority"//添加收藏
#define kDelectFavority @"kDelectFavority"//删除收藏
#define kAddList @"kAddList"//添加订单
#define kRetList @"kRetList"//返回已经存在订单
#define kSearch  @"kSearch"//搜索
#define kBusinessList @"kBusinessList"//商家列表
#define kBusinessDetail @"kBusinessDetail"//商家详情
#define kBusinessDetailComment @"kBusinessDetailComment"//商家详情评论
#define kBusinessDetailProduct @"kBusinessDetailProduct"//商家详情商品
#define kHomePage @"kHomePage"//首页
#define kProductDetail @"kProductDetail"//商品详情
#define kProductDetailCompany @"kProductDetailCompany"//商品里面的商家信息
#define kProductDetailComment @"kProductDetailComment"//商品里面的评论
#define kCarWashList @"kCarWashList"//洗车列表
#define kCarWashOption @"kCarWashOption"//洗车选项
#define kCategoryList @"kCategoryList"
#define kCategorySubList @"kCategorySubList"
#define kMyCoupon @"kMyCoupon"//我的车夫券
#define kMyCouponDetail @"kMyCouponDetail"//我的车夫券详情
#define kPayResult @"kPayResult"//我的车夫券详情
#define kCompanyProduct @"kCompanyProduct" //本商家所有商品
#define kHotSearchWord  @"kHotSearchWord" //热门搜索词
#define kSearchBusiness @"kSearchBusiness"//搜索商家
#define kCardDetails @"kCardDetails"//会员卡概览
#define kGetAgreement @"kGetAgreement"//获取协议
#define kSuggestRetroaction @"kSuggestRetroaction"//意见反馈
#define kCreatVipPrePayID @"kCreatVipPrePayID"//会员卡订单生成ID
#define kCreatAccPrePayID @"kCreatAccPrePayID"//账户余额充值订单生成ID
#define kDelayExpire @"kDelayExpire"//延长会员卡使用时间
#define kMyMemberCard @"kMyMemberCard" //我的会员卡
#define kDrawback @"kDrawback" //退款

@interface QHttpMessageManager : NSObject<QiaoHttpDelegate>

@property (nonatomic,copy)NSString *filePath;
+ (QHttpMessageManager *)sharedHttpMessageManager;
- (void)accessHotCity;
//获取区域
- (void)accessGetRegion:(NSString*)parentId;
//验证码
- (void)accessAcquireCode:(NSString *)phone andMessage:(NSString *)message;
//- (void)accessAcquireCode:(NSString *)phone;
//登录
- (void)accessLogin:(NSString *)nick andPassword:(NSString *)password;
//评论
- (void)accessBusinessComment:(NSString*)companyId andPage:(int)pageSize andIndex:(int)index;
- (void)accessProductComment:(NSString*)companyId andProductID:(NSString *)productId andPage:(int)pageSize andIndex:(int)index;
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
//搜索
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
//余额充值订单
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
