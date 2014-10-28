//
//  TestHook1.mm
//  TestHook1
//
//  Created by MartinPham on 10/28/14.
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

// CaptainHook by Ryan Petrich
// see https://github.com/rpetrich/CaptainHook/

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CaptainHook/CaptainHook.h"
#include <notify.h> // not required; for examples only
#include <objc/runtime.h>

// Objective-C runtime hooking using CaptainHook:
//   1. declare class using CHDeclareClass()
//   2. load class using CHLoadClass() or CHLoadLateClass() in CHConstructor
//   3. hook method using CHOptimizedMethod()
//   4. register hook using CHHook() in CHConstructor
//   5. (optionally) call old method using CHSuper()


@interface TestHook1 : NSObject

@end

@implementation TestHook1

-(id)init
{
	if ((self = [super init]))
	{
	}

    return self;
}

@end

#import "ViewController.h"
#import "LMViewControllerView.h"


@class UIView;

CHDeclareClass(UIView); // declare class

CHOptimizedMethod(1, self, void, UIView, addSubview, UIView *, v) // hook method (with no arguments and no return value)
{
	// write code here ...
	
//	NSLog(@">>> %@ addSubview %@", self, v);
	CHSuper(1, UIView, addSubview, v); // call old (original) method
	
	@try {
		if([self isKindOfClass:[objc_getClass("SBRootFolderView") class]]){
//			NSLog(@"view structure %@", [self recursiveDescription]);
			if(self.tag != 181188 && v.tag != 30052014 && [self viewWithTag:30052014] == nil){
				if([[self subviews] count] == 2){
					self.tag = 181188;
					for(UIView *sv in [self subviews]){
						sv.hidden = YES;
					}
					
					
						NSLog(@"call me once");
						
						[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
						
						
						ViewController *vc = [[ViewController alloc] init];
						
						
						[[NSNotificationCenter defaultCenter] addObserver: vc selector: @selector(receivedRotate:) name: UIDeviceOrientationDidChangeNotification object: nil];
						
						vc.view = [[LMViewControllerView alloc] init];
//						vc.view.frame = [UIScreen mainScreen].bounds;//CGRectMake(0, 0, 1024, 1024);

					UIDeviceOrientation toInterfaceOrientation = [[UIDevice currentDevice] orientation];
					
					if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft){
						NSLog(@"left");
						vc.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
					} else if(toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
						NSLog(@"right");
						vc.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
					} else if(toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
						NSLog(@"down");
						vc.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
					} else if(toInterfaceOrientation == UIInterfaceOrientationPortrait) {
						NSLog(@"up");
						vc.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
					}
					
						vc.view.tag = 30052014;
						[vc.view initView];
						[self addSubview:vc.view];
						
						[vc viewDidLoad];
						[vc viewWillAppear:YES];
					
				}
			}
			
		}
	}
	@catch (NSException *exception) {
		NSLog(@"$$$ = %@", exception);
	}
	
	
	
	
//	if([self isKindOfClass:[objc_getClass("SBIconScrollView") class]]){
//		v.hidden = YES;
//	}
	
	
}

//
//CHOptimizedMethod(2, self, BOOL, ClassToHook, arg1, NSString*, value1, arg2, BOOL, value2) // hook method (with 2 arguments and a return value)
//{
//	// write code here ...
//
//	return CHSuper(2, ClassToHook, arg1, value1, arg2, value2); // call old (original) method and return its return value
//}
//
//static void WillEnterForeground(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
//{
//	// not required; for example only
//}
//
//static void ExternallyPostedNotification(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
//{
//	// not required; for example only
//}

CHConstructor // code block that runs immediately upon load
{
	@autoreleasepool
	{
		NSLog(@">>>> LOADED >>>>");
//		
//		
//		
//		
//		// listen for local notification (not required; for example only)
//		CFNotificationCenterRef center = CFNotificationCenterGetLocalCenter();
//		CFNotificationCenterAddObserver(center, NULL, WillEnterForeground, CFSTR("UIApplicationWillEnterForegroundNotification"), NULL, CFNotificationSuspensionBehaviorCoalesce);
//		
//		// listen for system-side notification (not required; for example only)
//		// this would be posted using: notify_post("gg.ki.TestHook1.eventname");
//		CFNotificationCenterRef darwin = CFNotificationCenterGetDarwinNotifyCenter();
//		CFNotificationCenterAddObserver(darwin, NULL, ExternallyPostedNotification, CFSTR("gg.ki.TestHook1.eventname"), NULL, CFNotificationSuspensionBehaviorCoalesce);
		
		 CHLoadLateClass(UIView); // load class (that is "available now")
		// CHLoadLateClass(ClassToHook);  // load class (that will be "available later")
		
		CHHook(1, UIView, addSubview); // register hook
//		CHHook(2, ClassToHook, arg1, arg2); // register hook
	}
}
