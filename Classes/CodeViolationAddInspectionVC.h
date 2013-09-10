//
//  CodeViolationAddInspectionVC.h
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

@interface CodeViolationAddInspectionVC : UIViewController <UITableViewDelegate, UITableViewDataSource,
AGSFeatureLayerEditingDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,
UIPopoverControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate, UITextFieldDelegate,UIAlertViewDelegate> {

	AGSGraphic *selectedViolationGraphic;
	AGSGraphic *selectedInspectionGraphic;
	UITableView *violationDetailsTableView;
	NSDictionary *violationsFieldAliasDictionary;
	NSArray *violationDetailsDisplayFieldsArray;
	UIScrollView *violationAndInspectionScrollView;
	
	NSMutableDictionary *inspectionAttributesDict;
	
	AGSFeatureLayer *inspectionsFeatureLayer;
	
	BOOL isEditingInspection;
	
	NSData *inspectionAttachmentImageData;
	

	UIPopoverController *imagePickerPopover;
	
	NSInteger inspectionObjectId;

	// Add new inspection UI
	
	UIImageView *inspectionAttachmentImageView;
	UIButton *addAttachmentImageButton;
	UIButton *removeAttachmentImageButton;
	UITextField *workorderId;
	UILabel *inspectionStartDateLabel;
	UITextView *inspectionNotes;
	UISegmentedControl *contactOwnerSegmentedControl;
	UILabel *inspectionEndDateLabel;
	UITextField *inspectionUser;
	UILabel *addNewInspectionLabel;
	
	// Date Action Sheet controls
	UIView *actionsheetView;
	UILabel *actionsheetSelectDateLabel;
	UIButton *actionsheetCloseButton;
	UIDatePicker *actionsheetSubmitDatePicker;
	UIButton *actionsheetSelectDateButton;
	UIButton *selectStartDateButton;
	UIButton *selectEndDateButton;
	
	// Action Picker View
	UIView *actionPickerView;
	UILabel *actionPickerSelectActionLabel;
	UIButton *actionPickerCloseButton;
	UIPickerView *actionPicker;
	UIButton *actionPickerSubmitButton;
	UITextField *submittedActionLabel;
		
	BOOL isStartDateSelected;
	
	// Inspections Domain Values
	
	NSArray *actionDomainValues;
	NSArray *inspectionStatusDomainValues;
	
	NSString *inspectionId;
	
	BOOL didUpdateInspection;
	BOOL shouldAskToSave;
	UIButton *saveInspectionButton;
	BOOL didClickSearchButton;
	UIActivityIndicatorView *loadingImageActivityIndicator;
	BOOL  didupdateAttachment;
	UITextField *activeField;
	
}

@property (nonatomic, retain) AGSGraphic *selectedViolationGraphic;
@property (nonatomic, retain) AGSGraphic *selectedInspectionGraphic;
@property (nonatomic, retain) IBOutlet UITableView *violationDetailsTableView;
@property (nonatomic, retain) NSDictionary *violationsFieldAliasDictionary;
@property (nonatomic, retain) NSArray *violationDetailsDisplayFieldsArray;
@property (nonatomic, retain) IBOutlet UIScrollView *violationAndInspectionScrollView;

@property (nonatomic, retain) NSMutableDictionary *inspectionAttributesDict;

@property (nonatomic, retain) AGSFeatureLayer *inspectionsFeatureLayer;

@property (nonatomic, assign) BOOL isEditingInspection;

@property (nonatomic, retain) NSData *inspectionAttachmentImageData;


@property (nonatomic, retain) UIPopoverController *imagePickerPopover;

@property (nonatomic, assign) NSInteger inspectionObjectId;

// Add new inspection UI

@property (nonatomic, retain) IBOutlet UIImageView *inspectionAttachmentImageView;
@property (nonatomic, retain) IBOutlet UIButton *addAttachmentImageButton;
@property (nonatomic, retain) IBOutlet UIButton *removeAttachmentImageButton;
@property (nonatomic, retain) IBOutlet UITextField *workorderId;
@property (nonatomic, retain) IBOutlet UILabel *inspectionStartDateLabel;
@property (nonatomic, retain) IBOutlet UITextView *inspectionNotes;
@property (nonatomic, retain) IBOutlet UISegmentedControl *contactOwnerSegmentedControl;
@property (nonatomic, retain) IBOutlet UILabel *inspectionEndDateLabel;
@property (nonatomic, retain) IBOutlet UITextField *inspectionUser;
@property (nonatomic, retain) IBOutlet UILabel *addNewInspectionLabel;

//Custom Action Sheet controls
@property (nonatomic, retain) IBOutlet UIView *actionsheetView;
@property (nonatomic, retain) IBOutlet UILabel *actionsheetSelectDateLabel;
@property (nonatomic, retain) IBOutlet UIButton *actionsheetCloseButton;
@property (nonatomic, retain) IBOutlet UIDatePicker *actionsheetSubmitDatePicker;
@property (nonatomic, retain) IBOutlet UIButton *actionsheetSelectDateButton;
@property (nonatomic, retain) IBOutlet UIButton *selectStartDateButton;
@property (nonatomic, retain) IBOutlet UIButton *selectEndDateButton;

// Action Picker View
@property (nonatomic, retain) IBOutlet UIView *actionPickerView;
@property (nonatomic, retain) IBOutlet UILabel *actionPickerSelectActionLabel;
@property (nonatomic, retain) IBOutlet UIButton *actionPickerCloseButton;
@property (nonatomic, retain) IBOutlet UIPickerView *actionPicker;
@property (nonatomic, retain) IBOutlet UIButton *actionPickerSubmitButton;
@property (nonatomic, retain) IBOutlet UITextField *submittedActionLabel;

@property (nonatomic, assign) BOOL isStartDateSelected;

// Inspections Domain Values

@property (nonatomic, retain) NSArray *actionDomainValues;
@property (nonatomic, retain) NSArray *inspectionStatusDomainValues;

@property (nonatomic, retain) NSString *inspectionId;

@property (nonatomic, assign) BOOL didUpdateInspection;
@property (nonatomic, assign) BOOL shouldAskToSave;
@property (nonatomic, assign) BOOL didClickSearchButton;

@property (nonatomic, retain) IBOutlet UIButton *saveInspectionButton;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loadingImageActivityIndicator;
@property (nonatomic, assign) BOOL didupdateAttachment;
@property (nonatomic, retain) UITextField *activeField;


- (void)registerForKeyboardNotifications;
-(IBAction)showPhotoLobrary:(id)sender;
-(IBAction)removeAttachmentImage:(id)sender;
-(IBAction)addInspection:(id)sender;

// Custom Actionsheet
-(IBAction)showActionSheet:(id)sender;
-(IBAction)hideActionSheet:(id)sender;
-(IBAction)setSubmittedDate:(id)sender;

// Action Picker View
-(IBAction)showActionPickerView:(id)sender;
-(IBAction)hideActionPickerView:(id)sender;
-(IBAction)setSubmittedAction:(id)sender;

-(void)clearInspectionFields;
-(BOOL)validateInspectionFields;

- (BOOL) checkForFieldChanges;
- (BOOL) checkForFieldChangesWhileEditingViolation;
- (void) methodForAskToSave;

- (IBAction)textFieldBeganEditing:(id)sender;
- (IBAction)textFieldDoneEditing:(id)sender;

@end
