//
//  CodeViolationFeatureDetailsVC.h
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
#import "CodeViolationAddViolationVC.h"
#import "CodeViolationAddInspectionVC.h"
#import "CodeViolationInspectionDetailsVC.h"

#define LEFT_MARGIN 10.0
#define RIGHT_MARGIN 10.0
#define TOP_MARGIN 10.0
#define BOTTOM_MARGIN 10.0

@interface CodeViolationFeatureDetailsVC : UIViewController <UITableViewDelegate, UITableViewDataSource,
AGSQueryTaskDelegate> {

	UITableView *violationDetailsTableView;
	UITableView *inspectionDetailsTableView;
	AGSGraphic *selectedViolationGraphic;
	NSDictionary *violationsFieldAliasDictionary;
	NSMutableDictionary *inspectionsFieldAliasDictionary;
	NSArray *violationDetailsDisplayFieldsArray;
	NSArray *inspectionDetailsDisplayFieldsArray;
	NSArray *inspectionsFeaturesArray;
	CodeViolationAddViolationVC *objCodeViolationAddViolationVC;
	
	UIScrollView *violationAndInspectionScrollView;
	
	CodeViolationAddInspectionVC *objCodeViolationAddInspectionVC;
	CodeViolationInspectionDetailsVC *objCodeViolationInspectionDetailsVC;
	
	AGSFeatureLayer *inspectionsFeatureLayer;
	AGSQueryTask *inspectionsQueryTask;
	AGSQuery *inspectionsQuery;
	
	NSMutableArray *actionDomainValues;
	NSMutableArray *inspectionStatusDomainValues;
	
	UIButton *editViolationButton;
	UIButton *addInspectionButton;
	
	AGSGraphic *inspectionGraphicNew;
	
	UIImageView *tableViewBackgroundImage;
	
	BOOL didUpdateViolation;
	UIActivityIndicatorView *loadingInspectionsIndicator;
    UIActivityIndicatorView *loadingInspectionsIndicatorForButton;
	
}

@property (nonatomic, retain) IBOutlet UITableView *violationDetailsTableView;
@property (nonatomic, retain) IBOutlet UITableView *inspectionDetailsTableView;
@property (nonatomic, retain) AGSGraphic *selectedViolationGraphic;
@property (nonatomic, retain) NSDictionary *violationsFieldAliasDictionary;
@property (nonatomic, retain) NSMutableDictionary *inspectionsFieldAliasDictionary;
@property (nonatomic, retain) NSArray *violationDetailsDisplayFieldsArray;
@property (nonatomic, retain) NSArray *inspectionDetailsDisplayFieldsArray;
@property (nonatomic, retain) NSArray *inspectionsFeaturesArray;

@property (nonatomic, retain) CodeViolationAddViolationVC *objCodeViolationAddViolationVC;

@property (nonatomic, retain) IBOutlet UIScrollView *violationAndInspectionScrollView;

@property (nonatomic, retain) CodeViolationAddInspectionVC *objCodeViolationAddInspectionVC;
@property (nonatomic, retain) CodeViolationInspectionDetailsVC *objCodeViolationInspectionDetailsVC;

@property (nonatomic, retain) AGSFeatureLayer *inspectionsFeatureLayer;
@property (nonatomic, retain) AGSQueryTask *inspectionsQueryTask;
@property (nonatomic, retain) AGSQuery *inspectionsQuery;

@property (nonatomic, retain) NSMutableArray *actionDomainValues;
@property (nonatomic, retain) NSMutableArray *inspectionStatusDomainValues;

@property (nonatomic, retain) IBOutlet UIButton *editViolationButton;
@property (nonatomic, retain) IBOutlet UIButton *addInspectionButton;

@property (nonatomic, retain) AGSGraphic *inspectionGraphicNew;

@property (nonatomic, retain) IBOutlet UIImageView *tableViewBackgroundImage;

@property (nonatomic, assign) BOOL didUpdateViolation; 
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loadingInspectionsIndicator;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loadingInspectionsIndicatorForButton;

-(void)getInspectionFieldsAndDomainValues;

- (IBAction) editViolation:(id)sender;
- (IBAction) addInspection:(id)sender;
- (void) showInspectionDetailsView :(int) tappedRow;
- (void) endActivityIndicatorDelayed ;
-(void) showInspectionDetailsViewDelayed:(NSNumber*)tappedRow ;

@end
