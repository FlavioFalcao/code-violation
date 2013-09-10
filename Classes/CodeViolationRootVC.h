//
//  CodeViolationRootVC.h
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
#import "CodeViolationFeatureDetailsVC.h"
#import "CodeViolationConfigSettings.h"
#import <ArcGIS/ArcGIS.h>

@class CodeViolationMapVC;


@interface CodeViolationRootVC : UIViewController <AGSQueryTaskDelegate, UISearchBarDelegate, UITableViewDelegate, 
UITableViewDataSource, AGSLocatorDelegate> {

	UINavigationController *navigationController;
	UISearchBar *objSearchBar;
	UITableView *violationsTableView;
    CodeViolationMapVC *objCodeViolationMapVC;
	NSMutableArray *violationsFeaturesArray;
	CodeViolationFeatureDetailsVC *objCodeViolationFeatureDetailsVC;
	UIActivityIndicatorView *searchActivityIndicator;
	AGSQueryTask *violationsQueryTask;
	AGSQuery *violationsQuery;
	NSMutableDictionary *violationsFieldAliasDictionary;
	AGSQueryTask *inspectionsQueryTask;
	AGSQuery *inspectionsQuery;
	AGSLocator *addressLocator;
	AGSGraphic *violationGrahicNew;
	
}

@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) IBOutlet UISearchBar *objSearchBar;
@property (nonatomic, retain) IBOutlet UITableView *violationsTableView;
@property (nonatomic, retain) IBOutlet CodeViolationMapVC *objCodeViolationMapVC;
@property (nonatomic, retain) NSMutableArray *violationsFeaturesArray;
@property (nonatomic, retain) CodeViolationFeatureDetailsVC *objCodeViolationFeatureDetailsVC;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *searchActivityIndicator;
@property (nonatomic, retain) AGSQueryTask *violationsQueryTask;
@property (nonatomic, retain) AGSQuery *violationsQuery;

@property (nonatomic, retain) NSMutableDictionary *violationsFieldAliasDictionary;

@property (nonatomic, retain) AGSQueryTask *inspectionsQueryTask;
@property (nonatomic, retain) AGSQuery *inspectionsQuery;

@property (nonatomic, retain) AGSLocator *addressLocator;

@property (nonatomic, retain) AGSGraphic *violationGrahicNew;

-(void)reloadFeatureDetails:(AGSGraphic *)currentGraphic;
- (NSArray*) formatAddress:(NSString *)addressString;
- (BOOL) isZipCode:(NSString *)field;
- (void) showViolationGraphicDetail :(NSIndexPath *)indexPath;

@end
