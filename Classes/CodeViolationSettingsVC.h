//
//  CodeViolationSettingsVC.h
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
@class CodeViolationMapVC;


@interface CodeViolationSettingsVC : UIViewController <UITableViewDelegate,UITableViewDataSource>{

	
	UITableView *settingsTableView;
	UISwitch *parcelMapSwitch,*hybridMapSwitch,*openViolationSwitch,*closeViolationSwitch;
	CodeViolationMapVC *objCodeViolationMapVC;
	NSArray *violationStatus;
	NSArray *baseMaps;
    
    UIAlertView *myAlertView;
    
}

@property (nonatomic, retain) UIAlertView *myAlertView;
@property (nonatomic, retain) IBOutlet UITableView *settingsTableView;
@property (nonatomic, retain) UISwitch *parcelMapSwitch;
@property (nonatomic, retain) UISwitch *hybridMapSwitch;
@property (nonatomic, retain) UISwitch *openViolationSwitch;
@property (nonatomic, retain) UISwitch *closeViolationSwitch;

@property (nonatomic, retain) CodeViolationMapVC *objCodeViolationMapVC;
@property (nonatomic, retain) NSArray *violationStatus;
@property (nonatomic, retain) NSArray *baseMaps;

- (IBAction) switchChanged:(id)sender;
- (IBAction) ViolationTypeSwitchChanged:(id)sender;
- (void) switchBaseMaps;
- (void) removeRingGraphicAndPopOut ;

@end
