//
//  LMViewControllerView.m
//  WatchSpringboard
//
//  Created by Lucas Menge on 10/24/14.
//  Copyright (c) 2014 Lucas Menge. All rights reserved.
//

#import "LMViewControllerView.h"

#import "LMSpringboardItemView.h"
#import "LMSpringboardView.h"

@interface LMViewControllerView ()
{
  __strong UIImageView* _appLaunchMaskView;
  LMSpringboardItemView* _lastLaunchedItem;
	
	NSMutableArray *apps;
}

@end

@implementation LMViewControllerView

- (void)launchAppItem:(LMSpringboardItemView*)item
{
  if(_isAppLaunched == NO)
  {
	  NSLog(@"id = %@", item.id);
	  _appView.image = item.limg;
	  
	  if([item.icon.image isEqual:item.limg]){
		  _appView.contentMode = UIViewContentModeCenter;
	  }else{
		  _appView.contentMode = UIViewContentModeScaleAspectFit;
	  }
	  id task = [objc_getClass("NSTask") new];
	  [task setLaunchPath:@"/usr/bin/open"];
	  [task setArguments:[NSArray arrayWithObject:item.id]];
	  [task launch];
	  
	  
	  
    _isAppLaunched = YES;

    _lastLaunchedItem = item;
    
    CGPoint pointInSelf = [self convertPoint:item.icon.center fromView:item];
    CGFloat dx = pointInSelf.x-_appView.center.x;
    CGFloat dy = pointInSelf.y-_appView.center.y;
    
    double appScale = 60*item.scale/MIN(_appView.bounds.size.width,_appView.bounds.size.height);
    _appView.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(dx, dy), appScale,appScale);
    _appView.alpha = 1;
    _appView.maskView = _appLaunchMaskView;
    
    _appLaunchMaskView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    
    double springboardScale = MIN(self.bounds.size.width,self.bounds.size.height)/(60*item.scale);
    
    double maskScale = MAX(self.bounds.size.width,self.bounds.size.height)/(60*item.scale)*1.2*item.scale;
    
    [UIView animateWithDuration:0.5 animations:^{
      _appView.transform = CGAffineTransformIdentity;
      _appView.alpha = 1;
      
      _appLaunchMaskView.transform = CGAffineTransformMakeScale(maskScale,maskScale);
      
      _springboard.transform = CGAffineTransformTranslate(CGAffineTransformMakeScale(springboardScale,springboardScale), -dx, -dy);
      _springboard.alpha = 0;
    } completion:^(BOOL finished) {
      _appView.maskView = nil;
      _appLaunchMaskView.transform = CGAffineTransformIdentity;
      
      _springboard.transform = CGAffineTransformIdentity;
      _springboard.alpha = 1;
      NSUInteger index = [_springboard indexOfItemClosestToPoint:[_springboard convertPoint:pointInSelf fromView:self]];
      [_springboard centerOnIndex:index zoomScale:_springboard.zoomScale animated:NO];
		
		[NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(quitAppNoAnimate) userInfo:nil repeats:NO];
    }];
  }
}


- (void)quitAppNoAnimate
{
	if(_isAppLaunched == YES)
	{
		_isAppLaunched = NO;
		
		
			
			_appLaunchMaskView.transform = CGAffineTransformMakeScale(0.01, 0.01);
			
			_springboard.alpha = 1;
			_springboard.transform = CGAffineTransformIdentity;
		
			_appView.alpha = 0;
			_appView.maskView = nil;
		
		_lastLaunchedItem = nil;
	}
}

- (void)quitApp
{
  if(_isAppLaunched == YES)
  {
    _isAppLaunched = NO;
    
    CGPoint pointInSelf = [self convertPoint:_lastLaunchedItem.icon.center fromView:_lastLaunchedItem];
    CGFloat dx = pointInSelf.x-_appView.center.x;
    CGFloat dy = pointInSelf.y-_appView.center.y;
    
    double appScale = 60*_lastLaunchedItem.scale/MIN(_appView.bounds.size.width,_appView.bounds.size.height);
    CGAffineTransform appTransform = CGAffineTransformScale(CGAffineTransformMakeTranslation(dx, dy), appScale, appScale);
    _appView.maskView = _appLaunchMaskView;
    
    double springboardScale = MIN(self.bounds.size.width,self.bounds.size.height)/(60*_lastLaunchedItem.scale);
    _springboard.transform = CGAffineTransformTranslate(CGAffineTransformMakeScale(springboardScale,springboardScale), -dx, -dy);
    _springboard.alpha = 0;
    
    double maskScale = MAX(self.bounds.size.width,self.bounds.size.height)/(60*_lastLaunchedItem.scale)*1.2*_lastLaunchedItem.scale;
    
    _appLaunchMaskView.transform = CGAffineTransformMakeScale(maskScale,maskScale);
    
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
      _appView.alpha = 1;
      _appView.transform = appTransform;
      
      _appLaunchMaskView.transform = CGAffineTransformMakeScale(0.01, 0.01);
      
      _springboard.alpha = 1;
      _springboard.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
      _appView.alpha = 0;
      _appView.maskView = nil;
    }];
    
    _lastLaunchedItem = nil;
  }
}

#pragma mark - UIView

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	NSLog(@"initWithCoder");
  self = [super initWithCoder:aDecoder];
  if(self)
  {
   [self initView];
  }
  return self;
}

- (void)initView {
	apps = [[NSMutableArray alloc] init];
	
	NSArray *appList = [[objc_getClass("SBApplicationController") sharedInstance] allApplications];
	
	
	for(id app in appList){
		NSString *id = [app bundleIdentifier];
		if(
		   ![id isEqualToString:@"com.apple.GameController"]
		   &&![id isEqualToString:@"com.apple.MailCompositionService"]
		   &&![id isEqualToString:@"com.apple.SharedWebCredentialViewService"]
		   &&![id isEqualToString:@"com.apple.ios.StoreKitUIService"]
		   &&![id isEqualToString:@"com.apple.quicklook.quicklookd"]
		   &&![id isEqualToString:@"com.apple.webapp"]
		   &&![id isEqualToString:@"com.apple.CompassCalibrationViewService"]
		   &&![id isEqualToString:@"com.apple.iad.iAdOptOut"]
		   &&![id isEqualToString:@"com.apple.MusicUIService"]
		   &&![id isEqualToString:@"com.apple.WebContentFilter.remoteUI.WebContentAnalysisUI"]
		   &&![id isEqualToString:@"com.apple.mobilesms.notification"]
		   &&![id isEqualToString:@"com.apple.mobilesms.compose"]
		   &&![id isEqualToString:@"com.apple.MobileReplayer"]
		   &&![id isEqualToString:@"com.apple.purplebuddy"]
		   &&![id isEqualToString:@"com.apple.AccountAuthenticationDialog"]
		   &&![id isEqualToString:@"com.apple.AdSheetPhone"]
		   &&![id isEqualToString:@"com.apple.Diagnostics"]
		   &&![id isEqualToString:@"com.apple.PrintKit.Print-Center"]
		   &&![id isEqualToString:@"com.apple.uikit.PrintStatus"]
		   &&![id isEqualToString:@"com.apple.fieldtest"]
		   &&![id isEqualToString:@"com.apple.iosdiagnostics"]
		   &&![id isEqualToString:@"com.apple.FacebookAccountMigrationDialog"]
		   &&![id isEqualToString:@"com.apple.AskPermissionUI"]
		   &&![id isEqualToString:@"com.apple.appleaccount.AACredentialRecoveryDialog"]
		   &&![id isEqualToString:@"com.apple.PhotosViewService"]
		   &&![id isEqualToString:@"com.apple.TencentWeiboAccountMigrationDialog"]
		   &&![id isEqualToString:@"com.apple.share"]
		   &&![id isEqualToString:@"com.apple.CoreAuthUI"]
		   &&![id isEqualToString:@"com.apple.TrustMe"]
		   &&![id isEqualToString:@"com.apple.datadetectors.DDActionsService"]
		   &&![id isEqualToString:@"com.apple.DataActivation"]
		   &&![id isEqualToString:@"com.apple.webapp1"]
		   &&![id isEqualToString:@"com.apple.WebSheet"]
		   &&![id isEqualToString:@"com.apple.InCallService"]
		   &&![id isEqualToString:@"com.apple.family"]
		   &&![id isEqualToString:@"com.apple.gamecenter.GameCenterUIService"]
		   &&![id isEqualToString:@"com.apple.PreBoard"]
		   &&![id isEqualToString:@"com.apple.SiriViewService"]
		   &&![id isEqualToString:@"com.apple.DemoApp"]
		   &&![id isEqualToString:@"com.apple.WebViewService"]
		   ){
			NSString *name = [app displayName];
			
			NSArray *lis = [[[app bundle] infoDictionary] objectForKey:@"UILaunchImages"];
			NSString *l = @"";
			if([lis count] > 0){
				for(NSDictionary *li in lis){
					l = [li objectForKey:@"UILaunchImageName"];
					if(l != nil){
						l = [l stringByAppendingString:@"@2x.png"];
						l = [[[[app bundle] bundlePath] stringByAppendingString:@"/"] stringByAppendingString:l];
						
						NSLog(@"l = %@", l);
						if([[NSFileManager defaultManager] fileExistsAtPath:l]){
							NSLog(@"found");
							break;
						}
					}
				}
			}
			
			
			
			//		id appIcon = [[objc_getClass("SBApplicationIcon") alloc] initWithApplication:app];
			//		UIView *iconView = [[objc_getClass("SBIconView") alloc] initWithDefaultSize];
			//		[iconView setIcon:appIcon];
			//
			//
			//		UIView *iconViewIV = [iconView _iconImageView];
			//
			UIView *ai = [[objc_getClass("SBApplicationIcon") alloc] initWithApplication:app];
			UIView *iv = [[objc_getClass("SBIconView") alloc] initWithDefaultSize];
			[iv setIcon:ai];
			UIView *iconViewIV = [iv _iconImageView];
			
//			NSLog(@"iviv = %@", iconViewIV);
			
//			iconViewIV.layer.cornerRadius = (iconViewIV.bounds.size.width)/2;
//			iconViewIV.clipsToBounds = YES;
			UIGraphicsBeginImageContextWithOptions(iconViewIV.bounds.size, YES, [UIScreen mainScreen].scale);
//			UIGraphicsBeginImageContext(iconViewIV.bounds.size);
			[iconViewIV.layer renderInContext:UIGraphicsGetCurrentContext()];
			UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
			UIGraphicsEndImageContext();
			
			NSLog(@"img = %@", img);
			
			UIImage *limg = img;
			if(![l isEqualToString:@""]){
				limg = [UIImage imageWithContentsOfFile:l];
			}
			if(limg == nil) limg = img;
			
			[apps addObject:@{
								@"id": id,
								@"name": name,
								@"img": img,
								@"limg": limg
							  }];
			
		}
		
	}
	
	NSLog(@"apps = %@", apps);
	
	
	CGRect fullFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
	UIViewAutoresizing mask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	
//	UIImageView* bg = [[UIImageView alloc] initWithFrame:fullFrame];
//	bg.backgroundColor = [UIColor greenColor];
//	bg.image = [UIImage imageNamed:@"Wallpaper.png"];
//	bg.contentMode = UIViewContentModeScaleAspectFill;
//	bg.autoresizingMask = mask;
////	    [self addSubview:bg];
//	self.backgroundColor = [UIColor greenColor];
	
	_springboard = [[LMSpringboardView alloc] initWithFrame:fullFrame];
	_springboard.autoresizingMask = mask;
	
//	NSLog(@"apps = %@", [[objc_getClass("SBApplicationController") sharedInstance] allApplications]);
	
	
	
	
	
	NSMutableArray* itemViews = [NSMutableArray array];
//	NSArray* iconNames = @[
//						   @"Spotlight",
//						   @"Calculator",
//						   @"Clock",
//						   @"Compass",
//						   @"Connect",
//						   @"Photos",
//						   @"iTunes Store",
//						   @"Passbook",
//						   @"Remote",
//						   @"Stocks",
//						   @"Contacts",
//						   @"Videos",
//						   @"Podcasts",
//						   @"Weather",
//						   @"Game Center",
//						   @"Health",
//						   @"Tips",
//						   @"Newsstand",
//						   @"FaceTime",
//						   @"Messages",
//						   @"WhatsApp",
//						   @"Voice Memos",
//						   @"Phone",
//						   @"Mail",
//						   @"Safari",
//						   @"Music",
//						   @"Reeder",
//						   @"Overcast",
//						   @"Google Maps",
//						   @"Settings",
//						   @"Notes",
//						   @"Reminders",
//						   @"Calendar",
//						   @"Find Friends",
//						   @"Tweetbot"
//						   ];
	
	NSMutableArray *iconNames = [NSMutableArray array];
	
	
	for(NSDictionary *app in apps){
		[iconNames addObject:[app objectForKey:@"name"]];
	}
	
	// pre-render the known icons
	NSMutableArray* images = [NSMutableArray array];
	UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
	UIImageView* maskImage = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Library/Application Support/WatchSpring/Icon.png"]];
	[view addSubview:maskImage];
	UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.maskView = maskImage;
	button.frame = maskImage.frame;
	button.layer.cornerRadius = maskImage.frame.size.width/2;
//	button.backgroundColor = [UIColor clearColor];
	button.clipsToBounds = YES;
	[view addSubview:button];
	for(NSUInteger i=0; i<[iconNames count]; i++)
	{
		
		
		[button setBackgroundImage:[[apps objectAtIndex:i] objectForKey:@"img"] forState:UIControlStateNormal];

//		NSLog(@"dump %@", [iconView _iconImageView]);
		
		
		UIGraphicsBeginImageContextWithOptions(CGSizeMake(60, 60), NO, [UIScreen mainScreen].scale);
		[view.layer renderInContext:UIGraphicsGetCurrentContext()];
		UIImage* renderedImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		
		[images addObject:renderedImage];
	}
	
	// build out item set
	NSUInteger amount = [iconNames count];
	amount = 256;
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		amount = 1024;
	int skipCount = 0;
		  amount = [iconNames count];
	for(NSUInteger i=0; i<amount; i++)
	{
		LMSpringboardItemView* item = [[LMSpringboardItemView alloc] init];
		NSString* iconName = iconNames[(int)((i+skipCount)%[iconNames count])];
		// make sure we only have one spotlight icon.
		if([iconName isEqualToString:@"Spotlight"] == YES)
		{
			if(i != 0)
			{
				skipCount++;
				iconName = iconNames[(int)((i+skipCount)%[iconNames count])];
			}
			//item.isFolderLike = YES; // this makes the icon have a blurred background. kills performance, tho
		}
		item.id = [[apps objectAtIndex:i] objectForKey:@"id"];
		[item setTitle:iconName];
		item.limg = [[apps objectAtIndex:i] objectForKey:@"limg"];
		item.icon.image = images[(int)((i+skipCount)%[images count])];
		[itemViews addObject:item];
	}
	_springboard.itemViews = itemViews;
	
	[self addSubview:_springboard];
	
	_appView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Library/Application Support/WatchSpring/App.png"]];
	_appView.transform = CGAffineTransformMakeScale(0, 0);
	_appView.alpha = 0;
	_appView.backgroundColor = [UIColor whiteColor];
	[self addSubview:_appView];
	
	_appLaunchMaskView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Library/Application Support/WatchSpring/Icon.png"]];
	
//	_respringButton = [UIButton buttonWithType:UIButtonTypeCustom];
//	[self addSubview:_respringButton];
}

- (void)layoutSubviews
{
  [super layoutSubviews];
	
  CGRect statusFrame = {0};
  if(self.window != nil)
  {
    CGRect statusFrame = [UIApplication sharedApplication].statusBarFrame;
    statusFrame = [self.window convertRect:statusFrame toView:self];
	  
    UIEdgeInsets insets = _springboard.contentInset;
    insets.top = statusFrame.size.height;
    _springboard.contentInset = insets;
  }
	
  CGSize size = self.bounds.size;
	
  _appView.bounds = CGRectMake(0, 0, size.width, size.height);
  _appView.center = CGPointMake(size.width*0.5, size.height*0.5);
	
  _appLaunchMaskView.center  =CGPointMake(size.width*0.5, size.height*0.5+statusFrame.size.height);
	
  _respringButton.bounds = CGRectMake(0, 0, 60, 60);
  _respringButton.center = CGPointMake(size.width*0.5, size.height-60*0.5);
}

@end
