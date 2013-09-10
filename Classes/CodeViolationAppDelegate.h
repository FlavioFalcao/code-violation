//
//  CodeViolationAppDelegate.h
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


#import <UIKit/UIKit.h>
#import "Reachability.h"
#import "NetworkDisconnectionVC.h"

#import <CoreData/CoreData.h>

@class CodeViolationRootVC;
@class CodeViolationMapVC;

@interface CodeViolationAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    
    UISplitViewController *splitViewController;
    
    CodeViolationRootVC *objCodeViolationRootVC;
    CodeViolationMapVC *objCodeViolationMapVC;
	
	Reachability *reachability;
	NetworkDisconnectionVC *networkDisconnectionVC;
	NSURLRequest *configURLRequest;
	NSURLConnection *configURLConnection;
	NSMutableData *configResponseData;
	
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet UISplitViewController *splitViewController;
@property (nonatomic, retain) IBOutlet CodeViolationRootVC *objCodeViolationRootVC;
@property (nonatomic, retain) IBOutlet CodeViolationMapVC *objCodeViolationMapVC;

@property (nonatomic, retain) NetworkDisconnectionVC * networkDisconnectionVC;
@property (nonatomic, retain) Reachability *reachability;
@property (nonatomic, retain) NSURLRequest *configURLRequest;
@property (nonatomic, retain) NSURLConnection *configURLConnection;
@property (nonatomic, retain) NSMutableData *configResponseData;
@property (nonatomic, retain) UIAlertView *activityAlertView;
@property (nonatomic, retain) UIAlertView *activityAlertViewInspection;


-(void)saveNetworkFlag:(BOOL)NetworkStatusFlag;
-(void) retryInternetConnection;

@end
