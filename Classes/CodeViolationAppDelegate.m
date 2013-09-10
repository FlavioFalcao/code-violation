//
//  CodeViolationAppDelegate.m
//  CodeViolation
//
/** @license
 | Version 10.1.1
 | Copyright 2012 Esri
 |
 | Licensed under the Apache License, Version 2.0 (the "License");
 | you may not use this file except in compliance with the License.
 | You may obtain a copy of the License at
 |
 |    http://www.apache.org/licenses/LICENSE-2.0
 |
 | Unless required by applicable law or agreed to in writing, software
 | distributed under the License is distributed on an "AS IS" BASIS,
 | WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 | See the License for the specific language governing permissions and
 | limitations under the License.
 */


#import "CodeViolationAppDelegate.h"
#import "CodeViolationRootVC.h"
#import "CodeViolationMapVC.h"



@implementation CodeViolationAppDelegate

@synthesize window, splitViewController, objCodeViolationRootVC, objCodeViolationMapVC;
@synthesize reachability, networkDisconnectionVC, configURLRequest, configURLConnection,configResponseData,activityAlertView,activityAlertViewInspection;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
        
		[CodeViolationConfigSettings sharedCodeViolationConfigSettings];
           
        [self.window setRootViewController:splitViewController];
    
	[window makeKeyAndVisible];
	
    return YES;
}

-(void) retryInternetConnection
{
    // Override point for customization after app launch.
    
    // Add the split view controller's view to the window and display.
    
	
	// Override point for customization after app launch
	
	reachability = [Reachability reachabilityForInternetConnection];
	NetworkStatus netWorkStatus = [reachability currentReachabilityStatus];
	
	if (netWorkStatus == NotReachable) {
		
		self.networkDisconnectionVC = [[NetworkDisconnectionVC alloc] initWithNibName:@"NetworkDisconnectionVC"
																			   bundle:nil] ;
		[self.window addSubview:self.networkDisconnectionVC.view] ;
		[self.networkDisconnectionVC release] ;
		
		[self saveNetworkFlag:YES];
		
	}
	else {
        
        self.activityAlertViewInspection=[[UIAlertView alloc]initWithTitle:@"Updating Inspections Data" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
        
        
        UIActivityIndicatorView *activityIndicatorInspection=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [activityIndicatorInspection startAnimating];
        [self.activityAlertViewInspection addSubview:activityIndicatorInspection];
        [activityIndicatorInspection release];
        [activityIndicatorInspection setCenter:CGPointMake(140.0,65.0)];
        
        
		self.activityAlertView=[[UIAlertView alloc]initWithTitle:@"Updating Data" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
        
        UIActivityIndicatorView *activityIndicator=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [activityIndicator startAnimating];
        [self.activityAlertView addSubview:activityIndicator];
        [activityIndicator release];
        [activityIndicator setCenter:CGPointMake(140.0,65.0)];
        
		[CodeViolationConfigSettings sharedCodeViolationConfigSettings];
        [self.window setRootViewController:splitViewController];
		[self.window addSubview:splitViewController.view];
        
	}
    
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    [self retryInternetConnection];
}

-(void)applicationDidEnterBackground:(UIApplication *)application
{
    for (UIWindow* window1 in [UIApplication sharedApplication].windows) {
        NSArray* subviews = window1.subviews;
        if ([subviews count] > 0)
            if ([[subviews objectAtIndex:0] isKindOfClass:[UIAlertView class]])
                [(UIAlertView *)[subviews objectAtIndex:0] dismissWithClickedButtonIndex:[(UIAlertView *)[subviews objectAtIndex:0] cancelButtonIndex] animated:NO]; 
    }
    
    
}

- (void) saveNetworkFlag :(BOOL) NetworkStatusFlag {
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs setBool:NetworkStatusFlag forKey:@"NetworkStatus"];
	
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	
	[self.window release];
    [self.activityAlertViewInspection release];
    [self.activityAlertView release];
	[self.splitViewController release];
	[self.objCodeViolationMapVC release];
	[self.objCodeViolationRootVC release];
	[self.reachability release];
	[self.networkDisconnectionVC release];
	[self.configURLRequest release];
	[self.configURLConnection release];
	[self.configResponseData release];
	
	[super dealloc];
}

#pragma mark -


@end

