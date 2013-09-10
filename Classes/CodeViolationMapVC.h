//
//  CodeViolationMapVC.h
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
#import <ArcGIS/ArcGIS.h>
#import "CodeViolationConfigSettings.h"
#import "NetworkDisconnectionVC.h"
#import "WebMercatorUtil.h"
#import "CodeViolationRootVC.h"
#import "CodeViolationSettingsVC.h"
#import "CodeViolationAboutUsVC.h"
#import "CodeViolationAddViolationVC.h"
#import "CodeViolationAddInspectionVC.h"

@interface CodeViolationMapVC : UIViewController <UIPopoverControllerDelegate, UISplitViewControllerDelegate, 
AGSMapViewLayerDelegate,AGSLayerDelegate, AGSCalloutDelegate,AGSMapViewCalloutDelegate, AGSMapViewTouchDelegate, AGSFeatureLayerQueryDelegate, AGSFeatureLayerEditingDelegate, CLLocationManagerDelegate
,UIAlertViewDelegate > {
    
    UIPopoverController *popoverController;
    UIToolbar *toolbar;
    UIBarButtonItem *violationsItem;
	
    id detailItem;
	
	AGSMapView *mapView;
	AGSTiledMapServiceLayer *parcelMapServiceLayer;
	AGSTiledMapServiceLayer *hybridMapServiceLayer;
	AGSTiledMapServiceLayer *currentBaseMapServiceLayer;
	AGSFeatureLayer *violationsFeatureLayer;
	AGSGraphicsLayer *objGraphicsLayer;
    
	UIView *parcelMapView;
	UIView *hybridMapView;
	UIView *violationsFeatureLayerView;
	
	UIWindow *window;
	NetworkDisconnectionVC *networkDisconnectionVC;
	
	AGSQuery *violationsFeatureLayerQuery;
	
	UIButton *settingsButton;
	UIButton *GPSButton;
	CLLocationManager *locationManager;
	
	
	UIPopoverController *settingsPopoverController;
	CodeViolationSettingsVC *objCodeViolationSettingsVC;
	CodeViolationAboutUsVC *objCodeViolationAboutUsVC;
	
	CodeViolationRootVC *objCodeViolationRootVC;
	NSMutableArray *violationsFeatureLayerDomainValues;
	
	CodeViolationAddViolationVC *objCodeViolationAddViolationVC;
	
	UILabel *progressLabel;
	UIActivityIndicatorView *activityIndicator;
	UIViewController *topViewController;
	
	UIAlertView *ClickAtPointAlert;
	NSArray *tempGraphicsArray;
	AGSPoint *graphicPointNew;
	
	UIAlertView *tapAndHoldAlert;
	BOOL viewDidAppear;
	AGSSymbol *defaultSymbol;
    
    UIAlertView *alertForFail;
    
  
	
}
@property (nonatomic, retain) UIAlertView *alertForFail;

@property (nonatomic, retain) UIPopoverController *popoverController;

@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) UIBarButtonItem *violationsItem;
@property (nonatomic, retain) id detailItem;

@property (nonatomic, retain) IBOutlet AGSMapView *mapView;
@property (nonatomic, retain) AGSTiledMapServiceLayer *parcelMapServiceLayer;
@property (nonatomic, retain) AGSTiledMapServiceLayer *hybridMapServiceLayer;
@property (nonatomic, retain) AGSTiledMapServiceLayer *currentBaseMapServiceLayer;
@property (nonatomic, retain) AGSFeatureLayer *violationsFeatureLayer;
@property (nonatomic, retain) AGSGraphicsLayer *objGraphicsLayer;
@property (nonatomic, retain) UIView *parcelMapView;
@property (nonatomic, retain) UIView *hybridMapView;
@property (nonatomic, retain) UIView *violationsFeatureLayerView;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) NetworkDisconnectionVC *networkDisconnectionVC;

@property (nonatomic, retain) AGSQuery *violationsFeatureLayerQuery;

@property (nonatomic, retain) IBOutlet UIButton *settingsButton;
@property (nonatomic, retain) IBOutlet UIButton *GPSButton;
@property (nonatomic, retain) CLLocationManager *locationManager;

@property (nonatomic, retain) UIPopoverController *settingsPopoverController;
@property (nonatomic, retain) CodeViolationSettingsVC *objCodeViolationSettingsVC;
@property (nonatomic, retain) CodeViolationAboutUsVC *objCodeViolationAboutUsVC;

@property (nonatomic, retain) IBOutlet CodeViolationRootVC *objCodeViolationRootVC;
@property (nonatomic, retain) NSMutableArray *violationsFeatureLayerDomainValues;

@property (nonatomic, retain) CodeViolationAddViolationVC *objCodeViolationAddViolationVC;

@property (nonatomic, retain) IBOutlet UILabel *progressLabel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) UIViewController *topViewController;
@property (nonatomic, retain) UIAlertView *ClickAtPointAlert;
@property (nonatomic, retain) NSArray *tempGraphicsArray; 
@property (nonatomic, retain) AGSPoint *graphicPointNew;

@property (nonatomic, retain) UIAlertView *tapAndHoldAlert;
@property (nonatomic, assign) BOOL viewDidAppear;
@property (nonatomic, retain) AGSSymbol *defaultSymbol;




- (void) hidePopoverController;
- (BOOL) detectEmptyConfigFields;
- (void) executeQueryWithCondition;

- (void) addObserversForZoomingAndPanning;
- (void) removeObservers;
- (void) respondToZooming:(NSNotification *)notification;
- (void) respondToPanning:(NSNotification *)notification;

- (IBAction) GPSButtonClicked;
- (IBAction) showSettings;
- (IBAction) showAboutUs;

- (void) beginActivityIndicator;
- (void) endActivityIndicator;
- (void) addRingForSelectedViolation:(AGSGraphic *)selectedViolationGraphic;
- (void) addRingAndPushDesiredView;
- (void) addRingAndPushAddNewViolationView;

@end
