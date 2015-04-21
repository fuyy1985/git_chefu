//
//  ASRequestHUD.m
//  HRClient
//
//  Created by fyy6682 on 15-3-10.
//  Copyright (c) 2015年 panyj. All rights reserved.
//

#import "ASRequestHUD.h"

@interface ASRequestHUD ()
@property (nonatomic, readwrite) ASRequestHUDMaskType maskType;
@property (nonatomic, strong, readonly) NSTimer *fadeOutTimer;

@property (nonatomic, strong, readonly) UIWindow *overlayWindow;
@property (nonatomic, strong, readonly) UIView *hudView;
@property (nonatomic, strong, readonly) UILabel *stringLabel;
@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, strong, readonly) UIActivityIndicatorView *spinnerView;
@property (nonatomic, strong, readonly) UILabel *titleLabel;

@property (nonatomic, readonly) CGFloat visibleKeyboardHeight;

- (void)showWithStatus:(NSString*)string maskType:(ASRequestHUDMaskType)hudMaskType networkIndicator:(BOOL)show;
- (void)setStatus:(NSString*)string;
- (void)registerNotifications;
- (void)moveToPoint:(CGPoint)newCenter rotateAngle:(CGFloat)angle;
- (void)positionHUD:(NSNotification*)notification;

- (void)dismiss;
- (void)dismissWithStatus:(NSString*)string error:(BOOL)error;
- (void)dismissWithStatus:(NSString*)string error:(BOOL)error afterDelay:(NSTimeInterval)seconds;
- (void)dismissWithStatus:(NSString *)string title:(NSString *)titleString Image:(UIImage *)image afterDelay:(NSTimeInterval)seconds;

@end

@implementation ASRequestHUD

@synthesize overlayWindow, hudView, maskType, fadeOutTimer, stringLabel, imageView, spinnerView, visibleKeyboardHeight, titleLabel;

- (void)dealloc
{
    self.fadeOutTimer = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


+ (ASRequestHUD *)sharedView
{
    static dispatch_once_t once;
    static ASRequestHUD *sharedView;
    dispatch_once(&once, ^ { sharedView = [[ASRequestHUD alloc] initWithFrame:[[UIScreen mainScreen] bounds]]; });
    return sharedView;
}


+ (void)setStatus:(NSString *)string
{
    [[ASRequestHUD sharedView] setStatus:string];
}

#pragma mark - Show Methods

+ (void)show
{
    [[ASRequestHUD sharedView] showWithStatus:nil maskType:ASRequestHUDMaskTypeNone networkIndicator:NO];
}

+ (void)showWithStatus:(NSString *)status
{
    [[ASRequestHUD sharedView] showWithStatus:status maskType:ASRequestHUDMaskTypeNone networkIndicator:NO];
}

+ (void)showWithMaskType:(ASRequestHUDMaskType)maskType
{
    [[ASRequestHUD sharedView] showWithStatus:nil maskType:maskType networkIndicator:NO];
}

+ (void)showWithStatus:(NSString*)status maskType:(ASRequestHUDMaskType)maskType
{
    [[ASRequestHUD sharedView] showWithStatus:status maskType:maskType networkIndicator:NO];
}

+ (void)showErrorWithStatus:(NSString *)string
{
    [ASRequestHUD showErrorWithStatus:string duration:1];
}

+ (void)showErrorWithStatus:(NSString *)string duration:(NSTimeInterval)duration
{
    [ASRequestHUD show];
    [ASRequestHUD dismissWithError:string afterDelay:duration];
}

#pragma mark - Dismiss Methods

+ (void)dismiss
{
    [[ASRequestHUD sharedView] dismiss];
}

+ (void)dismissWithSuccess:(NSString*)successString
{
    [[ASRequestHUD sharedView] dismissWithStatus:successString error:NO];
}

+ (void)dismissWithSuccess:(NSString *)successString afterDelay:(NSTimeInterval)seconds
{
    [[ASRequestHUD sharedView] dismissWithStatus:successString error:NO afterDelay:seconds];
}

+ (void)dismissWithError:(NSString*)errorString
{
    [[ASRequestHUD sharedView] dismissWithStatus:errorString error:YES];
}

+ (void)dismissWithError:(NSString *)errorString afterDelay:(NSTimeInterval)seconds
{
    [[ASRequestHUD sharedView] dismissWithStatus:errorString error:YES afterDelay:seconds];
}

+ (void)dismissWithError:(NSString *)successString title:(NSString *)titleString andImage:(UIImage *)image afterDelay:(NSTimeInterval)duration {
    [[ASRequestHUD sharedView] dismissWithStatus:successString title:titleString Image:image afterDelay:duration];
}
#pragma mark - Instance Methods

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor clearColor];
        self.alpha = 0;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    switch (self.maskType)
    {
        case ASRequestHUDMaskTypeBlack:
        {
            [[UIColor colorWithWhite:0 alpha:0.5] set];
            CGContextFillRect(context, self.bounds);
            break;
        }
            
        case ASRequestHUDMaskTypeGradient:
        {
            size_t locationsCount = 2;
            CGFloat locations[2] = {0.0f, 1.0f};
            CGFloat colors[8] = {0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.75f};
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, locations, locationsCount);
            CGColorSpaceRelease(colorSpace);
            
            CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
            float radius = MIN(self.bounds.size.width , self.bounds.size.height) ;
            CGContextDrawRadialGradient (context, gradient, center, 0, center, radius, kCGGradientDrawsAfterEndLocation);
            CGGradientRelease(gradient);
            
            break;
        }
    }
}

- (void)setStatus:(NSString *)string
{
    CGFloat xSep = 10;
    CGFloat ySep = 10;
    CGFloat mSep = 5;
    CGFloat hudWidth = self.spinnerView.hidden ? 2*xSep : 2*xSep+self.spinnerView.frame.size.width;
    CGFloat hudHeight = self.spinnerView.hidden ? 2*ySep : 2*ySep+self.spinnerView.frame.size.height;
    CGFloat stringWidth = 0;
    CGFloat stringHeight = 0;
    CGRect labelRect = CGRectZero;
    
    if(string)
    {
        CGSize stringSize = [string sizeWithFont:self.stringLabel.font constrainedToSize:CGSizeMake(250, 300)];
        stringWidth = stringSize.width;
        stringHeight = stringSize.height;
        hudHeight = 2*ySep+stringHeight;
        
        /*
         if(stringWidth > hudWidth)
         hudWidth = ceil(stringWidth/2)*2;
         */
        
        int left = self.spinnerView.hidden ? xSep : xSep+self.spinnerView.frame.size.width+5;
        hudWidth += (stringWidth + mSep);
        labelRect = CGRectMake(left, (hudHeight-stringHeight)/2.0, hudWidth-left-xSep, stringHeight);
    }
    if (self.titleLabel.hidden == NO) {
        CGSize titleSize = [self.titleLabel.text sizeWithFont:self.titleLabel.font constrainedToSize:CGSizeMake(250, 300)];
        hudHeight += titleSize.height+5;
        self.titleLabel.frame = CGRectMake((hudWidth-titleSize.width)/2.0, 10, titleSize.width, titleSize.height);
        labelRect = CGRectMake(labelRect.origin.x, labelRect.origin.y+titleSize.height+5, labelRect.size.width, labelRect.size.height);
    }
    if (self.imageView.hidden == NO) {
        hudHeight += 33;
        labelRect = CGRectMake(labelRect.origin.x, labelRect.origin.y+33, labelRect.size.width, labelRect.size.height);
        self.titleLabel.frame = CGRectMake(self.titleLabel.frame.origin.x, self.titleLabel.frame.origin.y+33, self.titleLabel.frame.size.width, self.titleLabel.frame.size.height);
    }
    
    self.hudView.bounds = CGRectMake(0, 0, hudWidth, hudHeight);
    
    if(string)
        self.imageView.center = CGPointMake(CGRectGetWidth(self.hudView.bounds)/2, 24);
    else
       	self.imageView.center = CGPointMake(CGRectGetWidth(self.hudView.bounds)/2, CGRectGetHeight(self.hudView.bounds)/2);
    
    self.stringLabel.hidden = NO;
    self.stringLabel.text = string;
    self.stringLabel.frame = labelRect;
    
    if(string)
        self.spinnerView.center = CGPointMake(xSep+self.spinnerView.frame.size.width/2.0, self.hudView.bounds.size.height/2.0);
    else
        self.spinnerView.center = CGPointMake(CGRectGetWidth(self.hudView.bounds)/2.0, self.hudView.bounds.size.height/2.0);
}

- (void)setFadeOutTimer:(NSTimer *)newTimer
{
    if(fadeOutTimer)
        [fadeOutTimer invalidate], fadeOutTimer = nil;
    
    if(newTimer)
        fadeOutTimer = newTimer;
}

- (void)registerNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(positionHUD:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(positionHUD:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(positionHUD:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(positionHUD:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(positionHUD:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
}

- (void)positionHUD:(NSNotification*)notification
{
    CGFloat keyboardHeight;
    double animationDuration = 0;
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if(notification)
    {
        NSDictionary* keyboardInfo = [notification userInfo];
        CGRect keyboardFrame = [[keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
        animationDuration = [[keyboardInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        
        if(notification.name == UIKeyboardWillShowNotification || notification.name == UIKeyboardDidShowNotification) {
            if(UIInterfaceOrientationIsPortrait(orientation))
                keyboardHeight = keyboardFrame.size.height;
            else
                keyboardHeight = keyboardFrame.size.width;
        } else
            keyboardHeight = 0;
    }
    else
    {
        keyboardHeight = self.visibleKeyboardHeight;
    }
    
    CGRect orientationFrame = [UIScreen mainScreen].bounds;
    CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
    
    if(UIInterfaceOrientationIsLandscape(orientation))
    {
        float temp = orientationFrame.size.width;
        orientationFrame.size.width = orientationFrame.size.height;
        orientationFrame.size.height = temp;
        
        temp = statusBarFrame.size.width;
        statusBarFrame.size.width = statusBarFrame.size.height;
        statusBarFrame.size.height = temp;
    }
    
    CGFloat activeHeight = orientationFrame.size.height;
    
    if(keyboardHeight > 0)
        activeHeight += statusBarFrame.size.height*2;
    
    activeHeight -= keyboardHeight;
    CGFloat posY = floor(activeHeight*0.5);
    CGFloat posX = orientationFrame.size.width/2;
    
    CGPoint newCenter;
    CGFloat rotateAngle;
    
    switch (orientation)
    {
        case UIInterfaceOrientationPortraitUpsideDown:
            rotateAngle = M_PI;
            newCenter = CGPointMake(posX, orientationFrame.size.height-posY);
            break;
        case UIInterfaceOrientationLandscapeLeft:
            rotateAngle = -M_PI/2.0f;
            newCenter = CGPointMake(posY, posX);
            break;
        case UIInterfaceOrientationLandscapeRight:
            rotateAngle = M_PI/2.0f;
            newCenter = CGPointMake(orientationFrame.size.height-posY, posX);
            break;
        default: // as UIInterfaceOrientationPortrait
            rotateAngle = 0.0;
            newCenter = CGPointMake(posX, posY);
            break;
    }
    
    if(notification)
    {
        [UIView animateWithDuration:animationDuration
                              delay:0
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             [self moveToPoint:newCenter rotateAngle:rotateAngle];
                         } completion:NULL];
    }
    else
    {
        [self moveToPoint:newCenter rotateAngle:rotateAngle];
    }
}

- (void)moveToPoint:(CGPoint)newCenter rotateAngle:(CGFloat)angle
{
    self.hudView.transform = CGAffineTransformMakeRotation(angle);
    self.hudView.center = newCenter;
}

#pragma mark - Master show/dismiss methods

- (void)showWithStatus:(NSString*)string maskType:(ASRequestHUDMaskType)hudMaskType networkIndicator:(BOOL)show
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(!self.superview)
            [self.overlayWindow addSubview:self];
        
        self.fadeOutTimer = nil;
        self.imageView.hidden = YES;
        self.titleLabel.hidden = YES;
        self.maskType = hudMaskType;
        
        [self.spinnerView startAnimating];
        [self setStatus:string];
        
        if(self.maskType != ASRequestHUDMaskTypeNone)
        {
            self.overlayWindow.userInteractionEnabled = YES;
        }
        else
        {
            self.overlayWindow.userInteractionEnabled = NO;
        }
        
        [self.overlayWindow makeKeyAndVisible];
        [self positionHUD:nil];
        
        if(self.alpha != 1)
        {
            [self registerNotifications];
            self.hudView.transform = CGAffineTransformScale(self.hudView.transform, 1.3, 1.3);
            
            [UIView animateWithDuration:0.15
                                  delay:0
                                options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                             animations:^{
                                 self.hudView.transform = CGAffineTransformScale(self.hudView.transform, 1/1.3, 1/1.3);
                                 self.alpha = 1;
                             }
                             completion:NULL];
        }
        
        [self setNeedsDisplay];
    });
}

- (void)dismissWithStatus:(NSString*)string error:(BOOL)error
{
    [self dismissWithStatus:string error:error afterDelay:0.9];
}

- (void)dismissWithStatus:(NSString *)string error:(BOOL)error afterDelay:(NSTimeInterval)seconds
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.alpha != 1)
            return;
        
        //        if(error)
        //            self.imageView.image = [UIImage imageNamed:@"SVProgressHUD.bundle/error.png"];
        //        else
        //            self.imageView.image = [UIImage imageNamed:@"SVProgressHUD.bundle/success.png"];
        
        self.imageView.hidden = YES;
        self.titleLabel.hidden = YES;
        [self.spinnerView stopAnimating];
        [self setStatus:string];
        
        self.fadeOutTimer = [NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(dismiss) userInfo:nil repeats:NO];
    });
}

- (void)dismissWithStatus:(NSString *)string title:(NSString *)titleString Image:(UIImage *)image afterDelay:(NSTimeInterval)seconds {
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.alpha != 1)
            return;
        
        self.titleLabel.text = titleString;
        self.titleLabel.hidden = NO;
        self.imageView.image = image;
        self.imageView.hidden = NO;
        [self.spinnerView stopAnimating];
        [self setStatus:string];
        
        self.fadeOutTimer = [NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(dismiss) userInfo:nil repeats:NO];
    });
}

- (void)dismiss
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [UIView animateWithDuration:0.15
                              delay:0
                            options:UIViewAnimationCurveEaseIn | UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             self.hudView.transform = CGAffineTransformScale(self.hudView.transform, 0.8, 0.8);
                             self.alpha = 0;
                         }
                         completion:^(BOOL finished){
                             if(self.alpha == 0) {
                                 [[NSNotificationCenter defaultCenter] removeObserver:self];
                                 [hudView removeFromSuperview];
                                 hudView = nil;
                                 
                                 // Make sure to remove the overlay window from the list of windows
                                 // before trying to find the key window in that same list
                                 NSMutableArray *windows = [[NSMutableArray alloc] initWithArray:[UIApplication sharedApplication].windows];
                                 [windows removeObject:overlayWindow];
                                 overlayWindow = nil;
                                 
                                 [windows enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIWindow *window, NSUInteger idx, BOOL *stop) {
                                     if([window isKindOfClass:[UIWindow class]] && window.windowLevel == UIWindowLevelNormal) {
                                         [window makeKeyWindow];
                                         *stop = YES;
                                     }
                                 }];
                                 
                                 // uncomment to make sure UIWindow is gone from app.windows
                                 //NSLog(@"%@", [UIApplication sharedApplication].windows);
                                 //NSLog(@"keyWindow = %@", [UIApplication sharedApplication].keyWindow);
                             }
                         }];
    });
}

#pragma mark - Utilities

+ (BOOL)isVisible
{
    return ([ASRequestHUD sharedView].alpha == 1);
}

#pragma mark - Getters

- (UIWindow *)overlayWindow
{
    if(!overlayWindow)
    {
        overlayWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        overlayWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        overlayWindow.backgroundColor = [UIColor clearColor];
        overlayWindow.userInteractionEnabled = NO;
    }
    return overlayWindow;
}

- (UIView *)hudView
{
    if(!hudView)
    {
        hudView = [[UIView alloc] initWithFrame:CGRectZero];
        hudView.layer.cornerRadius = 5;
        hudView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
        hudView.autoresizingMask = (UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin |
                                    UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin);
        
        [self addSubview:hudView];
    }
    return hudView;
}

- (UILabel *)stringLabel
{
    if (stringLabel == nil)
    {
        stringLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        stringLabel.textColor = [UIColor whiteColor];
        stringLabel.backgroundColor = [UIColor clearColor];
        stringLabel.adjustsFontSizeToFitWidth = YES;
        stringLabel.textAlignment = NSTextAlignmentCenter;
        stringLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        stringLabel.font = [UIFont systemFontOfSize:14];
        stringLabel.shadowColor = [UIColor blackColor];
        stringLabel.shadowOffset = CGSizeMake(0, -1);
        stringLabel.numberOfLines = 0;
    }
    
    if(!stringLabel.superview)
        [self.hudView addSubview:stringLabel];
    
    return stringLabel;
}

- (UILabel *)titleLabel
{
    if (titleLabel == nil)
    {
        titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.adjustsFontSizeToFitWidth = YES;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        titleLabel.font = [UIFont systemFontOfSize:18];
        titleLabel.shadowColor = [UIColor blackColor];
        titleLabel.shadowOffset = CGSizeMake(0, -1);
        titleLabel.numberOfLines = 0;
    }
    
    if(!titleLabel.superview)
        [self.hudView addSubview:titleLabel];
    
    return titleLabel;
}

- (UIImageView *)imageView
{
    if (imageView == nil)
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
    
    if(!imageView.superview)
        [self.hudView addSubview:imageView];
    
    return imageView;
}

- (UIActivityIndicatorView *)spinnerView
{
    if (spinnerView == nil)
    {
        spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        spinnerView.hidesWhenStopped = YES;
        spinnerView.bounds = CGRectMake(0, 0, 37, 37);
    }
    
    if(!spinnerView.superview)
        [self.hudView addSubview:spinnerView];
    
    return spinnerView;
}

- (CGFloat)visibleKeyboardHeight
{
    UIWindow *keyboardWindow = nil;
    for (UIWindow *testWindow in [[UIApplication sharedApplication] windows])
    {
        if(![[testWindow class] isEqual:[UIWindow class]]) {
            keyboardWindow = testWindow;
            break;
        }
    }
    
    // Locate UIKeyboard.
    UIView *foundKeyboard = nil;
    for (__strong UIView *possibleKeyboard in [keyboardWindow subviews])
    {
        // iOS 4 sticks the UIKeyboard inside a UIPeripheralHostView.
        if ([[possibleKeyboard description] hasPrefix:@"<UIPeripheralHostView"])
        {
            
            for (UIView*tmpView in [possibleKeyboard subviews])
            {
                if ([[tmpView description] hasPrefix:@"<UIKeyboard"])
                {
                    foundKeyboard= tmpView;
                    break;
                }
            }
        }
    }
    
    if(foundKeyboard && foundKeyboard.bounds.size.height > 100)
        return foundKeyboard.bounds.size.height;
    
    return 0;
}
@end
