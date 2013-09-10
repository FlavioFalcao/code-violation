//
//  CodeViolationAddViolationVC.h
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
#import "CodeViolationAppDelegate.h"
#import <ArcGIS/ArcGIS.h>
#import <QuartzCore/QuartzCore.h>

@interface CodeViolationAddViolationVC : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, 
UIActionSheetDelegate, UITextFieldDelegate, UITextViewDelegate,UIAlertViewDelegate>{
	
	NSArray *violationTypeDomainValues;
		
	UIScrollView *violationAndInspectionScrollView;
	
	AGSPoint *currentMapPoint;
	
	//Feature Attributes
	
	UITextField *violationIDField;
	UITextView *fullAddress;
	UITextView *locationDescription;
	UITextView *violationDescription;
	UITextField *municipalCode;
	UILabel *submittedDateLabel;
	UISegmentedControl *visiableFromPublicSegmentedControl;
	
	UISegmentedControl *violationStatusSegmentedControl;
	
	//Custom Action Sheet controls
	UIView *actionsheetView;
	UILabel *actionsheetSelectDateLabel;
	UIButton *actionsheetCloseButton;
	UIDatePicker *actionsheetSubmitDatePicker;
	UIButton *actionsheetSelectDateButton;
	
	// Violation Type Picker View
	UIView *violationTypePickerView;
	UILabel *selectViolationTypeLabel;
	UIButton *violationTypePickerCloseButton;
	UIPickerView *violationTypePicker;
	UIButton *violationTypePickerSubmitButton;
	UITextField *submittedViolationTypeLabel;
	
	AGSGraphic *violationGraphicNew;
	
	BOOL isEditingViolation;
	BOOL shouldAskToSave;
	
	NSString *violationID;
	NSInteger violationObjectId;
	UIButton *saveViolationButton;
	BOOL didClickSearchButton;
	UITextField *activeField;
	
}

@property (nonatomic,retain) NSArray *violationTypeDomainValues;
@property (nonatomic, retain) IBOutlet UIScrollView *violationAndInspectionScrollView;

@property (nonatomic, retain) AGSPoint *currentMapPoint;

//Feature Attributes
@property (nonatomic,retain) IBOutlet UITextField *violationIDField;
@property (nonatomic,retain) IBOutlet UITextView *fullAddress;
@property (nonatomic,retain) IBOutlet UITextView *locationDescription;
@property (nonatomic,retain) IBOutlet UITextView *violationDescription;
@property (nonatomic,retain) IBOutlet UITextField *municipalCode;
@property (nonatomic,retain) IBOutlet UILabel *submittedDateLabel;
@property (nonatomic,retain) IBOutlet UISegmentedControl *visiableFromPublicSegmentedControl;
@property (nonatomic,retain) IBOutlet UISegmentedControl *violationStatusSegmentedControl;

//Custom Action Sheet controls
@property (nonatomic,retain) IBOutlet UIView *actionsheetView;
@property (nonatomic,retain) IBOutlet UILabel *actionsheetSelectDateLabel;
@property (nonatomic,retain) IBOutlet UIButton *actionsheetCloseButton;
@property (nonatomic,retain) IBOutlet UIDatePicker *actionsheetSubmitDatePicker;
@property (nonatomic,retain) IBOutlet UIButton *actionsheetSelectDateButton;

// Violation Action Picker View
@property (nonatomic,retain) IBOutlet UIView *violationTypePickerView;
@property (nonatomic,retain) IBOutlet UILabel *selectViolationTypeLabel;
@property (nonatomic,retain) IBOutlet UIButton *violationTypePickerCloseButton;
@property (nonatomic,retain) IBOutlet UIPickerView *violationTypePicker;
@property (nonatomic,retain) IBOutlet UIButton *violationTypePickerSubmitButton;
@property (nonatomic,retain) IBOutlet UITextField *submittedViolationTypeLabel;

@property (nonatomic, retain) AGSGraphic *violationGraphicNew;

@property (nonatomic, assign) BOOL isEditingViolation;
@property (nonatomic, assign) BOOL shouldAskToSave;

@property (nonatomic, retain) NSString *violationID;
@property (nonatomic, assign) NSInteger violationObjectId;
@property (nonatomic, retain) IBOutlet UIButton *saveViolationButton;
@property (nonatomic, assign) BOOL didClickSearchButton;
@property (nonatomic, retain) UITextField *activeField;

-(IBAction)showActionSheet:(id)sender;
-(IBAction)hideActionSheet:(id)sender;
-(IBAction)setSubmittedDate:(id)sender;
-(IBAction)submitNewViolation:(id)sender;

- (void)registerForKeyboardNotifications;

-(void) clearViolationsFields;
-(BOOL) validateViolationFields;
- (void) setUpScreen ;


// Violation Type Picker View

-(IBAction)showViolationTypePickerView:(id)sender;
-(IBAction)hideViolationTypePickerView:(id)sender;
-(IBAction)setViolationType:(id)sender;


- (IBAction)textFieldBeganEditing:(id)sender;
- (IBAction)textFieldDoneEditing:(id)sender;

- (BOOL) checkForFieldChanges;
- (BOOL) checkForFieldChangesWhileEditingViolation;
- (void) methodForAskToSave;

@end
