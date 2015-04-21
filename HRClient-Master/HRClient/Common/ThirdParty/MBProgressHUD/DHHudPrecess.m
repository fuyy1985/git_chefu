//
//  DHHudPrecess.m
//  iDMSS
//
//  Created by nobuts on 13-4-1.
//
//

#import "DHHudPrecess.h"
#import "QViewController.h"
#import <pthread.h>

static DHHudPrecess * __shareHudPrecess = nil;

@implementation DHHudPrecess

+ (DHHudPrecess *) sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __shareHudPrecess = [[self alloc] init];
    });    
    return __shareHudPrecess;
}


- (id)init
{
	if ((self = [super init]))
    {
       
	}
	
	return self;
}


- (void) ShowTips:(NSString*)strTips  delayTime:(NSTimeInterval)delay  atView:(UIView*)pView
{
    if (HUD != NULL)
    {
        if (pthread_main_np() != 0)
        {
            NSLog(@"ShowTips1: should not run to here!");
            
            return;
        }
        
        HUD.mode = MBProgressHUDModeText;
        HUD.labelText = strTips;
        
        sleep(delay);
    }
    else
    {
        if (0 == pthread_main_np())
        {
            NSLog(@"ShowTips2: should not run to here!");
            
            return;
        }
        
        if (NULL == pView)
        {
            pView = [[UIApplication sharedApplication] keyWindow];
        }
        
        if (NULL == pView)
        {
            return;
        }
        
       MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:pView animated:YES];

        hud.mode = MBProgressHUDModeText;
        hud.labelText = strTips;
        //hud.detailsLabelText = strTips;
        hud.margin = 10.f;
        hud.yOffset = 50.f;
        hud.removeFromSuperViewOnHide = YES;
        
        [hud hide:YES afterDelay:delay];
    }
}


- (void) showWaiting:(NSString*)strTips WhileExecuting:(SEL)method onTarget:(id)target withObject:(id)object animated:(BOOL)animated   atView:(UIView*)pView
{
    pView = [QViewController shareController].view;
    HUD = [[MBProgressHUD alloc] initWithView:pView];
    HUD.delegate = self;
   
	[pView addSubview:HUD];
	
	HUD.labelText = strTips;
	
	[HUD showWhileExecuting:method onTarget:target withObject:object animated:animated];
}

- (void) showProgress:(NSString*)strTips WhileExecuting:(SEL)method onTarget:(id)target withObject:(id)object animated:(BOOL)animated   atView:(UIView*)pView
{
    if (NULL == pView)
    {
        pView = [QViewController topPage].view;
    }
    
    
    if (NULL == pView) {
        pView = [UIApplication sharedApplication].keyWindow;
    }
    
    HUD = [[MBProgressHUD alloc] initWithView:pView];
    HUD.delegate = self;
    HUD.mode = MBProgressHUDModeDeterminate;
    
	[pView addSubview:HUD];
	
	HUD.labelText = strTips;
	
	[HUD showWhileExecuting:method onTarget:target withObject:object animated:animated];
}

- (void) updateProgress:(float)progress
{
    if (HUD != NULL &&  HUD.superview)
    {
        HUD.progress = progress;
    }
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
	// Remove HUD from screen when the HUD was hidded
	[HUD removeFromSuperview];
	HUD = nil;
}

@end
