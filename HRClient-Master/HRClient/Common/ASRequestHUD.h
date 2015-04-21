//
//  ASRequestHUD.h
//  HRClient
//
//  Created by fyy6682 on 15-3-10.
//  Copyright (c) 2015年 panyj. All rights reserved.
//

#import <UIKit/UIKit.h>


enum {
    ASRequestHUDMaskTypeNone = 1, // allow user interactions while HUD is displayed
    ASRequestHUDMaskTypeClear, // don't allow
    ASRequestHUDMaskTypeBlack, // don't allow and dim the UI in the back of the HUD
    ASRequestHUDMaskTypeGradient // don't allow and dim the UI with a a-la-alert-view bg gradient
};

typedef NSUInteger ASRequestHUDMaskType;

@interface ASRequestHUD : UIView


+ (void)show;
+ (void)showWithStatus:(NSString*)status;
+ (void)showWithStatus:(NSString*)status maskType:(ASRequestHUDMaskType)maskType;
+ (void)showWithMaskType:(ASRequestHUDMaskType)maskType;
+ (void)showErrorWithStatus:(NSString *)string;
+ (void)setStatus:(NSString*)string; // change the HUD loading status while it's showing

+ (void)dismiss; // simply dismiss the HUD with a fade+scale out animation
+ (void)dismissWithSuccess:(NSString*)successString; // also displays the success icon image
+ (void)dismissWithSuccess:(NSString*)successString afterDelay:(NSTimeInterval)seconds;
+ (void)dismissWithError:(NSString*)errorString; // also displays the error icon image
+ (void)dismissWithError:(NSString*)errorString afterDelay:(NSTimeInterval)seconds;
+ (void)dismissWithError:(NSString *)successString title:(NSString *)titleString andImage:(UIImage *)image afterDelay:(NSTimeInterval)duration;

+ (BOOL)isVisible;

@end
