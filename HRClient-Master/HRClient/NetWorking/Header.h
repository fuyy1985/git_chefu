//
//  Header.h
//  HRClient
//
//  Created by ekoo on 15/1/4.
//  Copyright (c) 2015年 panyj. All rights reserved.
//

#ifndef HRClient_Header_h
#define HRClient_Header_h
#import "ASINetworkQueue.h"
#import "ASIFormDataRequest.h"
#import "ASIHTTPRequest.h"
#import "ASIHTTPRequestDelegate.h"

//测试地址
#define TESTADRESS @"http://121.41.116.252/"
//域名
#define DOMAINN @"appapi"
//测试
#define SERVERADRESS [NSString stringWithFormat:@"%@%@",TESTADRESS,DOMAINN]
//热门城市
#define HOT_CITY_MESSAGE @"/region/findAll"
//获取区域
#define Q_REGION @"/region/findById"
//手机号码获取验证码
#define ACQUIRE_CODE @"/user/sendSMSVerifyCode"
//登录
#define Q_LOGIN @"/user/doLogin"
//评论
#define Q_BUSINESS_COMMENT @"/comment/getAllComments"
#define Q_PRODUCT_COMMENT @"/comment/getproduct"
//修改账户名
#define Q_ACOMMEND_NICK @"/user/updateNick"
//修改登录密码
#define Q_ACOMMEND_LOGIN_KEY @"/user/updateOldPassword"
//验证绑定手机
#define Q_CONFIRM_BIND_PHONE @"/user/verifyPhone"
//更改绑定手机
#define Q_CHANGEBINDPHONE @"/user/updatePhone"
//修改支付密码
#define Q_ACOMMENDPAYPWD @"/user/updateOldPayPasswd"
//找回支付密码
#define Q_FINDPAYPWD @"/user/findPayPasswd"
//设置支付密码
#define Q_SET_PAYPWD @"/user/setPayPasswd"
//重置支付密码
#define Q_RESET_PAYPWD @"/user/updatePayPasswd"
//注册
#define Q_REGISTER @"/user/doRegister"
//找回登录密码
#define Q_FIND_LOGIN_PWD @"/user/quickLogin"
//确认找回登录密码
#define Q_SURE_FIND_LOGIN_PWD @"/user/updatePassword"
//获取不同状态订单的数
#define Q_DIF_STATUS_LIST_QTY @"/orderList/getStatusCount"
//获取不同状态的订单
#define Q_DIF_STATUS_LIST @"/orderList/findByStatus"
//我的账户
#define Q_MY_ACCOUNT @"/account/selectBalance"
//订单详情
#define Q_MY_LIST_DETAIL @"/orderList/getOrderdetailByOrderID"
//编辑删除订单
#define Q_DELEGATE_LIST @"/orderList/editOrderByOrderID"
//订单评论
#define Q_LIST_REMARK @"/comment/addComments"
//收藏
#define Q_MY_FAVORITE  @"/MyFavorites/getMyFavorite"
//添加收藏
#define Q_ADD_MYFAVORITE @"/MyFavorites/addFavorite"
//删除收藏
#define Q_DELECT_MYFAVORITE @"/MyFavorites/delectFavorite"
//搜索商品，商铺
#define Q_SEARCH @"/searchWord/search"
//添加订单
#define Q_ADD_LIST @"/orderList/addOrderlist"
//商家列表
#define Q_BUSINESSLIST @"/company/getCompanyList"
//商家详情
#define Q_BUSINESS_DETAIL @"/company/getDetail"
//首页列表
#define Q_HOME_PAGE_LIST @"/product/getProductList"
//商品详情
#define Q_PRODUCTDETAIL @"/product/getDetail"
//洗车列表
#define Q_CARWASH_LIST @"/product/findProductList"
//洗车选项
#define Q_CAR_WASH_OPTION @"/category/findByategory"
//更多类别
#define Q_Category_SubList @"/category/findCategoryList"
//我的车夫券
#define Q_MY_COUPON @"/pay/mywanliwuyou"
//支付
#define Q_PAY_OPERATION @"/pay/addwanliwuyou"
//会员卡支付订单生成
#define Q_VIPCARD_BILL @"/prepaidBill/createMbrAcc"
//账户余额支付订单生成
#define Q_ACC_BILL @"/prepaidBill/prepaidCommAcc"
//退款
#define Q_DRAW_BACK @"/pay/refund.html"
//我的车夫券详情
#define Q_MY_COUPON_DETAIL @"/pay/paywanliwuyou"
//本商家所有商品列表
#define Q_COMPANY_PRODUCT @"/company/getCompanyProduct"
//热门词
#define Q_HOT_SEARCHWORD    @"/searchWord/hotWord"
//搜索商家
#define Q_SEARCH_BUSINESS   @"/company/getCompanyByWords"
//会员卡概览
#define Q_CARD_DETAILS  @"/prepaidBill/mbrAccDetails"
//app协议
#define Q_GET_AGREEMENT @"/agreement/getAgreement"
//用户反馈
#define Q_SUGGEST_RETROACTION @"/feedback/addFeedback"
//延长会员卡使用时间
#define Q_DELAY_EXPIRE @"/mbrAcc/delayExpireDate"
//我的会员卡
#define Q_MY_MEMBERCARD @"/mbrAcc/myMbrAcc"

#endif
