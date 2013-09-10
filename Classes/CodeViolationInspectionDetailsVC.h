//
//  CodeViolationInspectionDetailsVC.h
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
#import "CodeViolationAddInspectionVC.h"

@interface CodeViolationInspectionDetailsVC : UIViewController <AGSFeatureLayerEditingDelegate> {

	AGSGraphic *selectedViolationGraphic;
	AGSGraphic *selectedInspectionGraphic;
	AGSGraphic *currentInspectionGraphic;
	
	// Table Views
	
	UITableView *violationDetailsTableView;
	UITableView *inspectionDetailsTableView;
	
	// Violations display fields
	
	NSDictionary *violationsFieldAliasDictionary;
	NSArray *violationDetailsDisplayFieldsArray;
	
	// Inspections display fields
	
	NSDictionary *inspectionsFieldAliasDictionary;
	NSArray *inspectionDetailsDisplayFieldsArray;
	
	UIScrollView *violationAndInspectionScrollView;
	CodeViolationAddInspectionVC *objCodeViolationAddInspectionVC;

	UIButton *editInspectionButton;
	UIImageView *inspectionAttachmentImageView;
	
	AGSFeatureLayer *inspectionsFeatureLayer;
	
	NSInteger inspectionObjectId;
	
	// Inspections Domain Values
	
	NSArray *actionDomainValues;
	NSArray *inspectionStatusDomainValues;
	
	UIActivityIndicatorView *loadingImageActivityIndicator;
	int imageIndex;
	BOOL noImageFound;
	UIImage *fetchedImage;
}

@property (nonatomic, retain) AGSGraphic *selectedViolationGraphic;
@property (nonatomic, retain) AGSGraphic *selectedInspectionGraphic;
@property (nonatomic, retain) AGSGraphic *currentInspectionGraphic;

// TableViews

@property (nonatomic, retain) IBOutlet UITableView *violationDetailsTableView;
@property (nonatomic, retain) IBOutlet UITableView *inspectionDetailsTableView;

// Violations display fields

@property (nonatomic, retain) NSDictionary *violationsFieldAliasDictionary;
@property (nonatomic, retain) NSArray *violationDetailsDisplayFieldsArray;

// Inspections display fields

@property (nonatomic, retain) NSDictionary *inspectionsFieldAliasDictionary;
@property (nonatomic, retain) NSArray *inspectionDetailsDisplayFieldsArray;

@property (nonatomic, retain) IBOutlet UIScrollView *violationAndInspectionScrollView;
@property (nonatomic, retain) CodeViolationAddInspectionVC *objCodeViolationAddInspectionVC;

@property (nonatomic, retain) IBOutlet UIButton *editInspectionButton;
@property (nonatomic, retain) UIImageView *inspectionAttachmentImageView;

@property (nonatomic, retain) AGSFeatureLayer *inspectionsFeatureLayer;

@property (nonatomic, assign) NSInteger inspectionObjectId;

// Inspections Domain Values

@property (nonatomic, retain) NSArray *actionDomainValues;
@property (nonatomic, retain) NSArray *inspectionStatusDomainValues;

@property (nonatomic, retain) UIActivityIndicatorView *loadingImageActivityIndicator;
@property (nonatomic, assign) int imageIndex;
@property (nonatomic, assign) BOOL noImageFound;
@property (nonatomic, retain) UIImage *fetchedImage;

-(IBAction)editInspection:(id)sender;

@end
