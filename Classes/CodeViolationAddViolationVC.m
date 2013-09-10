//
//  CodeViolationAddViolationVC.m
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


#import "CodeViolationAddViolationVC.h"
#import "CodeViolationMapVC.h"

@implementation CodeViolationAddViolationVC

@synthesize violationTypeDomainValues, violationAndInspectionScrollView, currentMapPoint, fullAddress, locationDescription, 
violationDescription, municipalCode, submittedDateLabel, visiableFromPublicSegmentedControl, actionsheetView, 
actionsheetSelectDateLabel, actionsheetCloseButton, actionsheetSubmitDatePicker, actionsheetSelectDateButton, 
violationGraphicNew, isEditingViolation, violationID, violationObjectId,violationIDField;

@synthesize violationTypePickerView, selectViolationTypeLabel, violationTypePickerCloseButton, violationTypePicker, 
violationTypePickerSubmitButton, submittedViolationTypeLabel,shouldAskToSave,saveViolationButton,didClickSearchButton,activeField,violationStatusSegmentedControl;


#pragma mark View Lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
        
	self.title = [CodeViolationConfigSettings panelTitle];
	[self.saveViolationButton setBackgroundImage:[[UIImage imageNamed:@"image165.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:0.0] forState:UIControlStateNormal]  ;
	[self.actionsheetSelectDateButton setBackgroundImage:[[UIImage imageNamed:@"image165.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:0.0] forState:UIControlStateNormal] ;
	[self.violationTypePickerSubmitButton setBackgroundImage:[[UIImage imageNamed:@"image165.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:0.0] forState:UIControlStateNormal] ;

	UIButton *backButton =[UIButton buttonWithType:UIButtonTypeCustom];
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton.png"] forState:UIControlStateNormal];
	[backButton setFrame:CGRectMake(5,8,49,30)];
	[backButton addTarget:self action:@selector(methodForAskToSave) forControlEvents:UIControlEventTouchDown];

	UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
	[backButtonItem setTitle:@"Back"];
	self.navigationItem.leftBarButtonItem = backButtonItem;	
	
	UIBarButtonItem *searchBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchBarButtonClicked)];
	self.navigationItem.rightBarButtonItem = searchBarButton;

	self.fullAddress.layer.cornerRadius = 5.0;
	self.locationDescription.layer.cornerRadius = 5.0;
	self.municipalCode.layer.cornerRadius = 5.0;
	self.violationDescription.layer.cornerRadius = 5.0;
	
	[super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated {
	
	self.actionsheetSubmitDatePicker.date = [NSDate date];
	self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
	
	CGRect tempFrame = self.actionsheetView.frame;
	tempFrame.size = CGSizeMake(320.0, 1400.0);
	
	self.violationTypePickerView.frame = tempFrame;
	[self registerForKeyboardNotifications];
	[self setUpScreen];
	
	[super viewWillAppear:YES];
}

-(void) viewWillDisappear:(BOOL)animated {
	NSLog(@"viewWillDisappear");
}

- (void) setUpScreen {
	[self.fullAddress resignFirstResponder];
	[self.locationDescription resignFirstResponder];
	[self.violationDescription resignFirstResponder];
	[self.municipalCode resignFirstResponder];
	
	[self.fullAddress.layer setBorderWidth:1.0];
	[self.fullAddress.layer setBorderColor: [[UIColor grayColor] CGColor]];
	
	[self.locationDescription.layer setBorderWidth:1.0];
	[self.locationDescription.layer setBorderColor: [[UIColor grayColor] CGColor]];

	[self.violationDescription.layer setBorderWidth:1.0];
	[self.violationDescription.layer setBorderColor: [[UIColor grayColor] CGColor]];

	[self.saveViolationButton.layer setBorderColor:[[UIColor grayColor] CGColor]];
	[self.saveViolationButton.layer setBorderWidth:1.0];
	[self.saveViolationButton.layer setCornerRadius:8.0];
	
}

#pragma mark -
#pragma mark UIPickerViewDelegate Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return [self.violationTypeDomainValues count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	return [self.violationTypeDomainValues objectAtIndex:row];
}

#pragma mark -
#pragma mark Keyboard Notifications

- (void)registerForKeyboardNotifications {
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillBeHidden:)
											name:UIKeyboardWillHideNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillBeShown:)
												 name:UIKeyboardWillShowNotification object:nil];
	
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
	((CodeViolationMapVC *)(((CodeViolationAppDelegate *)[[UIApplication sharedApplication] delegate]).objCodeViolationMapVC)).mapView.userInteractionEnabled = YES;
	[self.violationAndInspectionScrollView setContentOffset:CGPointMake(0,0)];
}

// Called when the UIKeyboardWillShowNotification is sent
- (void)keyboardWillBeShown:(NSNotification*)aNotification {
	((CodeViolationMapVC *)(((CodeViolationAppDelegate *)[[UIApplication sharedApplication] delegate]).objCodeViolationMapVC)).mapView.userInteractionEnabled = NO;

}


#pragma mark -
#pragma mark UITextViewDelegate And UITextFieldDelegate Methods

- (IBAction)textFieldBeganEditing:(id)sender {
	self.activeField = sender;
    UITextField *nextField = nil;
	if ( sender == (UITextField*)self.fullAddress) {
        nextField = (UITextField *)self.locationDescription;
    } else if ( sender == (UITextField *)self.locationDescription ) {
        nextField = (UITextField *)self.violationDescription;
    } else if ( sender ==(UITextField *)self.violationDescription ) {
        nextField = self.municipalCode;
    }
	else if( sender ==(UITextField *)self.municipalCode ) {
		[self.violationAndInspectionScrollView setContentOffset:CGPointMake(0, 50) animated:YES];
		[sender setReturnKeyType:UIReturnKeyDone];
	}

	
	//if next field is blank, then set return as Next else set it as Done
	NSString *nextText = [nextField text];
	if(( ! nextText || [nextText isEqualToString:@""] ) && self.activeField != self.municipalCode ) {
		[activeField setReturnKeyType:UIReturnKeyNext];
	} else {
		[activeField setReturnKeyType:UIReturnKeyDone];
	}
}

- (IBAction)textFieldDoneEditing:(id)sender {
	if (activeField == self.municipalCode) {
		[self.violationAndInspectionScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
	}
    if( [sender returnKeyType] == UIReturnKeyNext ) {

		if( activeField == (UITextField*)self.fullAddress ) {
            [self.locationDescription becomeFirstResponder];
        } else if( activeField == (UITextField*)self.locationDescription ) {
            [self.violationDescription becomeFirstResponder];
        } else if( activeField == (UITextField*)self.violationDescription ) {
            [self.municipalCode becomeFirstResponder];
        }
    } else {
        [sender resignFirstResponder];
    }
}


#pragma mark -- UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
	[self textFieldBeganEditing:textView];
	return TRUE;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
	return TRUE;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)text{
	// Any new character added is passed in as the "text" parameter
    if ([text isEqualToString:@"\n"]) {
        // Be sure to test for equality using the "isEqualToString" message
        [textField resignFirstResponder];
		
        // Return FALSE so that the final '\n' character doesn't get added
        return FALSE;
    }
	else if([textField.text length] + text.length > 20){
		return NO ;
	}
	self.shouldAskToSave = YES;
    // For any other character return TRUE so that the text gets added to the view
    return TRUE;	
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
	// Any new character added is passed in as the "text" parameter
    if ([text isEqualToString:@"\n"]) {
        // Be sure to test for equality using the "isEqualToString" message
        [self textFieldDoneEditing:textView];
		
        // Return FALSE so that the final '\n' character doesn't get added
        return FALSE;
    }
	else if([textView.text length] + text.length > 255){
		return NO ;
	}
	self.shouldAskToSave = YES;
    // For any other character return TRUE so that the text gets added to the view
    return TRUE;	
	
}

#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch (buttonIndex) {
		case 0:
			if (self.didClickSearchButton) {
				self.didClickSearchButton = NO;
				[self.navigationController popToRootViewControllerAnimated:YES];
			}
			else {
				[self.navigationController popViewControllerAnimated:YES];
			}
			
			break;
		case 1:
			
			break;
	
		default:
			break;
	}
}

#pragma mark Actions
#pragma mark -

- (void) methodForAskToSave {
	if ([self checkForFieldChanges]) {
		 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                        message:NSLocalizedString(@"DoyouWanttoSavetheChanges", @"DoyouWanttoSavetheChanges Item")
                        delegate:self   cancelButtonTitle:nil
                        otherButtonTitles:NSLocalizedString(@"Yes", @"Yes Item"),NSLocalizedString(@"No", @"No Item"),nil];
		 
		 [alert show];
		 [alert release];
	 }
	else {
		[self.navigationController popViewControllerAnimated:YES];
	}
	 
}
- (BOOL) checkForFieldChanges {
	BOOL returnResult = NO;
	if (self.isEditingViolation) {
		if ([self checkForFieldChangesWhileEditingViolation] || self.shouldAskToSave) {
			returnResult = YES;
		}
		else {
			returnResult = NO;
		}

	}
	else {
		if (self.shouldAskToSave) {
			returnResult = YES;
		}
	}
	return returnResult;
}

-(BOOL) checkForFieldChangesWhileEditingViolation {
	BOOL returnValue = NO;
	
	AGSGraphic *tempGraphic = ((CodeViolationRootVC *)(((CodeViolationAppDelegate *)[[UIApplication sharedApplication] delegate]).objCodeViolationRootVC)).objCodeViolationFeatureDetailsVC.selectedViolationGraphic;
	//Full address
	NSString *fullAddr = nil;
	if ([[tempGraphic   attributeForKey:@"FULLADDR"] isKindOfClass:[NSNull class]] ||
		[tempGraphic   attributeForKey:@"FULLADDR"] == nil ||
		[[NSString stringWithFormat:@"%@", [tempGraphic   attributeForKey:@"FULLADDR"]] isEqualToString:@""]) 
	{
		fullAddr = @"";
	}
	else {
		
		fullAddr = [tempGraphic   attributeForKey:@"FULLADDR"];
	}
	
	if (![fullAddr isEqualToString:self.fullAddress.text]) {
		returnValue = YES;
	}
	
	// Location Description
	NSString *locDesc = nil;
	if ([[tempGraphic   attributeForKey:@"LOCDESC"] isKindOfClass:[NSNull class]] ||
		[tempGraphic   attributeForKey:@"LOCDESC"] == nil ||
		[[NSString stringWithFormat:@"%@", [tempGraphic   attributeForKey:@"LOCDESC"]] isEqualToString:@""]) 
	{
		locDesc = @"";
	}
	else {
		
		locDesc = [tempGraphic   attributeForKey:@"LOCDESC"];
	}
	if (![locDesc isEqualToString:self.locationDescription.text]) {
		returnValue = YES;
	}
	
	
	// Violation Description
	NSString *violateDesc = nil;
	if ([[tempGraphic   attributeForKey:@"VIOLATEDESC"] isKindOfClass:[NSNull class]] ||
		[tempGraphic   attributeForKey:@"VIOLATEDESC"] == nil ||
		[[NSString stringWithFormat:@"%@", [tempGraphic   attributeForKey:@"VIOLATEDESC"]] isEqualToString:@""]) 
	{
		violateDesc = @"";
	}
	else {
		
		violateDesc = [tempGraphic   attributeForKey:@"VIOLATEDESC"];
	}
	if (![violateDesc isEqualToString:self.violationDescription.text]) {
		returnValue = YES;
	}
	
	// Municipal Code
	NSString *municipleCode = nil;
	if ([[tempGraphic   attributeForKey:@"CODE"] isKindOfClass:[NSNull class]] ||
		[tempGraphic   attributeForKey:@"CODE"] == nil ||
		[[NSString stringWithFormat:@"%@", [tempGraphic   attributeForKey:@"CODE"]] isEqualToString:@""]) 
	{
		municipleCode = @"";
	}
	else {
		municipleCode = [tempGraphic   attributeForKey:@"CODE"];
	}
	if (![municipleCode isEqualToString:self.municipalCode.text]) {
		returnValue = YES;
	}
	
	//Visible
	NSString *visible = nil;
	if ([[tempGraphic   attributeForKey:@"VISABLE"] isKindOfClass:[NSNull class]] ||
		[tempGraphic   attributeForKey:@"VISABLE"] == nil ||
		[[NSString stringWithFormat:@"%@", [tempGraphic   attributeForKey:@"VISABLE"]] isEqualToString:@""]) 
	{
		visible = @"";
	}
	else {
		visible = [tempGraphic   attributeForKey:@"VISABLE"];
	}		
	
	if (![visible isEqualToString:[self.visiableFromPublicSegmentedControl titleForSegmentAtIndex:self.visiableFromPublicSegmentedControl.selectedSegmentIndex]]) {
		returnValue = YES;
	}
	
	
	//ViolationState
	NSString *violationStatus = nil;
	if ([[tempGraphic   attributeForKey:@"STATUS"]isKindOfClass:[NSNull class]] ||
		[tempGraphic   attributeForKey:@"STATUS"] == nil ||
		[[NSString stringWithFormat:@"%@", [tempGraphic   attributeForKey:@"STATUS"]] isEqualToString:@""]) 
	{
		violationStatus = @"";
	}
	else {
		violationStatus = [tempGraphic   attributeForKey:@"STATUS"];
	}		
	
	if (![violationStatus isEqualToString:[self.violationStatusSegmentedControl titleForSegmentAtIndex:self.violationStatusSegmentedControl.selectedSegmentIndex]]) {
		returnValue = YES;
	}
	
	//VIOLATETYPE
	NSString *violateType = nil;
	if ([[tempGraphic   attributeForKey:@"VIOLATETYPE"] isKindOfClass:[NSNull class]]||
		[tempGraphic   attributeForKey:@"VIOLATETYPE"] == nil ||
		[[NSString stringWithFormat:@"%@", [tempGraphic   attributeForKey:@"VIOLATETYPE"]] isEqualToString:@""]) 
	{
		violateType = [tempGraphic   attributeForKey:@"VIOLATETYPE"];
	}
	else {
		violateType = [tempGraphic   attributeForKey:@"VIOLATETYPE"];
	}
	if (![violateType isEqualToString: [self.violationTypeDomainValues objectAtIndex:[self.violationTypePicker selectedRowInComponent:0]]]) {
		returnValue = YES; 
	}
	
	
	NSDate *submittedDate = [NSDate dateWithTimeIntervalSince1970:[[tempGraphic   attributeForKey:@"SUBMITDT"] doubleValue]/1000];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"MMM dd yyyy"];
	if (![[dateFormatter stringFromDate:submittedDate] isEqualToString:self.submittedDateLabel.text]) {
		returnValue = YES;
	}
	[dateFormatter release];
	return returnValue; 
}



#pragma mark Date actionsheet
-(IBAction)showActionSheet:(id)sender {
	self.navigationItem.leftBarButtonItem.enabled = NO;
	self.navigationItem.rightBarButtonItem.enabled = NO;
	
	if (isEditingViolation) {
		
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"MMM dd yyyy"];
		NSDate *submittedDate = [dateFormatter dateFromString:self.submittedDateLabel.text];
		[self.actionsheetSubmitDatePicker setDate:submittedDate animated:NO];
		[dateFormatter release];
	}

	[self.fullAddress resignFirstResponder];
	[self.locationDescription resignFirstResponder];
	[self.violationDescription resignFirstResponder];
	[self.municipalCode resignFirstResponder];
	self.actionsheetView.hidden = NO;
}

-(IBAction)hideActionSheet:(id)sender {
	self.navigationItem.leftBarButtonItem.enabled = YES;
	self.navigationItem.rightBarButtonItem.enabled = YES;

	self.actionsheetView.hidden = YES;	
}

-(IBAction)setSubmittedDate:(id)sender {
	self.navigationItem.leftBarButtonItem.enabled = YES;
	self.navigationItem.rightBarButtonItem.enabled = YES;

	NSDateFormatter* formatter = [[[NSDateFormatter alloc] init] autorelease];
	//Set the required date format
	[formatter setDateFormat:@"MMM dd yyyy"];
	NSString *submittedDate = [formatter stringFromDate:self.actionsheetSubmitDatePicker.date];
	if (![submittedDate isEqualToString:self.submittedDateLabel.text]) {
		self.shouldAskToSave = YES;
	}
	self.submittedDateLabel.text = submittedDate;
	self.actionsheetView.hidden = YES;
}

#pragma mark -

-(IBAction)submitNewViolation:(id)sender {
   

	if ([self validateViolationFields])
	{
		if (self.shouldAskToSave) {
			self.shouldAskToSave = NO;
		}
        
        [((CodeViolationAppDelegate *)[[UIApplication sharedApplication]delegate]).activityAlertView show];
        
		[((CodeViolationMapVC *)((CodeViolationAppDelegate *)[UIApplication sharedApplication].delegate).objCodeViolationMapVC) beginActivityIndicator];
		
				
		NSString *selectedViolationType = [self.violationTypeDomainValues objectAtIndex:[self.violationTypePicker selectedRowInComponent:0]];	
		
		NSString *isVisibleForPublic = [self.visiableFromPublicSegmentedControl titleForSegmentAtIndex:self.visiableFromPublicSegmentedControl.selectedSegmentIndex];
		
		NSString *inspectionStatus = [self.violationStatusSegmentedControl titleForSegmentAtIndex:self.violationStatusSegmentedControl.selectedSegmentIndex];
		
		NSTimeInterval timeIntervalForLastUpdate = ([[NSDate date] timeIntervalSince1970]*1000);
		
		// Convert string to date object
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"MMM dd yyyy"];
		
		NSDate *violationSubmitDate = [dateFormatter dateFromString:self.submittedDateLabel.text]; 
		NSTimeInterval timeIntervalSubmitDate = ([violationSubmitDate timeIntervalSince1970]*1000);
		
		
		if (isEditingViolation) {
			
			NSMutableDictionary *newViolationAttributes = [NSMutableDictionary dictionaryWithObjectsAndKeys:
														   [NSNumber numberWithInt:self.violationObjectId], @"OBJECTID",
														   self.violationID ,@"VIOLATIONID",
														   self.fullAddress.text, @"FULLADDR",
														   self.locationDescription.text, @"LOCDESC",
														   selectedViolationType, @"VIOLATETYPE",
														   self.violationDescription.text, @"VIOLATEDESC",
														   self.municipalCode.text, @"CODE",
														   isVisibleForPublic, @"VISABLE",
														   [NSNumber numberWithDouble:timeIntervalSubmitDate], @"SUBMITDT",
														   inspectionStatus, @"STATUS",
														   [NSNumber numberWithDouble:timeIntervalForLastUpdate], @"LASTUPDATE",
														   nil];
			
			
			AGSGraphic *tempGraphic = ((CodeViolationRootVC *)(((CodeViolationAppDelegate *)[[UIApplication sharedApplication] delegate]).objCodeViolationRootVC)).objCodeViolationFeatureDetailsVC.selectedViolationGraphic;
			
			((CodeViolationRootVC *)(((CodeViolationAppDelegate *)[[UIApplication sharedApplication] delegate]).objCodeViolationRootVC)).objCodeViolationFeatureDetailsVC.selectedViolationGraphic = [AGSGraphic graphicWithGeometry:tempGraphic.geometry symbol:nil  attributes:newViolationAttributes 
				infoTemplateDelegate:nil];

			//commit changes to featurelayer
			
			[((CodeViolationMapVC *)(((CodeViolationAppDelegate *)[[UIApplication sharedApplication] delegate]).objCodeViolationMapVC)).violationsFeatureLayer applyEditsWithFeaturesToAdd: nil
																																												  toUpdate: [NSArray arrayWithObject:((CodeViolationRootVC *)(((CodeViolationAppDelegate *)[[UIApplication sharedApplication] delegate]).objCodeViolationRootVC)).objCodeViolationFeatureDetailsVC.selectedViolationGraphic]
																																												  toDelete: nil];
		}
		else {
			
			
			NSMutableDictionary *newViolationAttributes = [NSMutableDictionary dictionaryWithObjectsAndKeys:
														   @"0",@"VIOLATIONID",
														   self.fullAddress.text, @"FULLADDR",
														   self.locationDescription.text, @"LOCDESC",
														   selectedViolationType, @"VIOLATETYPE",
														   self.violationDescription.text, @"VIOLATEDESC",
														   self.municipalCode.text, @"CODE",
														   isVisibleForPublic, @"VISABLE",
														   [NSNumber numberWithDouble:timeIntervalSubmitDate], @"SUBMITDT",
														   inspectionStatus, @"STATUS",
														   [NSNumber numberWithDouble:timeIntervalForLastUpdate], @"LASTUPDATE",
														   nil];
			
			self.violationGraphicNew = [[AGSGraphic alloc] initWithGeometry:self.currentMapPoint symbol:nil attributes:newViolationAttributes infoTemplateDelegate:nil];
			
			//commit changes to featurelayer
			
			[((CodeViolationMapVC *)(((CodeViolationAppDelegate *)[[UIApplication sharedApplication] delegate]).objCodeViolationMapVC)).violationsFeatureLayer applyEditsWithFeaturesToAdd:[NSArray arrayWithObject:self.violationGraphicNew] 
																																												  toUpdate: nil 
																																												  toDelete: nil];
		}
		
		[dateFormatter release];
	}
}

-(void)clearViolationsFields {
	
	self.fullAddress.text = @"";
	self.locationDescription.text = @"";
	[self.violationTypePicker selectRow:0 inComponent:0 animated:NO];
	self.violationDescription.text = @"";
	self.municipalCode.text = @"";
	[self.visiableFromPublicSegmentedControl setSelectedSegmentIndex:0];
	[self.violationStatusSegmentedControl setSelectedSegmentIndex:0];
}

-(BOOL)validateViolationFields {

	BOOL returnString;
	
	if (self.fullAddress.text.length == 0 || self.locationDescription.text.length == 0 || 
		self.violationDescription.text.length == 0 || self.municipalCode.text.length == 0) {
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ErrorTitle", @"ErrorTitle Item")
														message:NSLocalizedString(@"Pleaseenterdetailsinallthefields", @"Pleaseenterdetailsinallthefields Item") 
													   delegate:nil 
											  cancelButtonTitle:NSLocalizedString(@"OKTitle", @"OKTitle Item") 
											  otherButtonTitles:nil];
		
		[alert show];
		[alert release];
		
		
		returnString = NO;
				    
		[((CodeViolationMapVC *)((CodeViolationAppDelegate *)[UIApplication sharedApplication].delegate).objCodeViolationMapVC) endActivityIndicator];            
		
	}
	else if (self.fullAddress.text.length > 255 || self.locationDescription.text.length > 255 || 
			 self.violationDescription.text.length > 255 || self.municipalCode.text.length > 255) {
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ErrorTitle", @"ErrorTitle Item")
														message:NSLocalizedString(@"Pleaseenterdetailsinallthefields", @"Pleaseenterdetailsinallthefields Item") 
													   delegate:nil 
											  cancelButtonTitle:NSLocalizedString(@"OKTitle", @"OKTitle Item") 
											  otherButtonTitles:nil];
		
		[alert show];
		[alert release];
		
		
		returnString = NO;
				      
		[((CodeViolationMapVC *)((CodeViolationAppDelegate *)[UIApplication sharedApplication].delegate).objCodeViolationMapVC) endActivityIndicator];
	}
	else {
		
		returnString = YES;
	}
	
	
	return returnString;
	
}

-(void)searchBarButtonClicked {
	if ([self checkForFieldChanges]) {
		self.didClickSearchButton = YES;
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
														message:NSLocalizedString(@"DoyouWanttoSavetheChanges", @"DoyouWanttoSavetheChanges Item") 
													   delegate:self 
											  cancelButtonTitle:nil
											  otherButtonTitles:NSLocalizedString(@"Yes", @"Yes Item"),NSLocalizedString(@"No", @"No Item"),nil];
		
		[alert show];
		[alert release];
	}
	else {		
		[((CodeViolationRootVC *)((CodeViolationAppDelegate *)[UIApplication sharedApplication].delegate).objCodeViolationRootVC).navigationController popToRootViewControllerAnimated:YES];
	}
}

#pragma mark Violation Type Picker View

-(IBAction)showViolationTypePickerView:(id)sender {

	self.navigationItem.leftBarButtonItem.enabled = NO;
	self.navigationItem.rightBarButtonItem.enabled = NO;

	
	for (int i=0; i<self.violationTypeDomainValues.count; i++) {
		
		if ([self.submittedViolationTypeLabel.text isEqualToString:[self.violationTypeDomainValues objectAtIndex:i]]) {
			
			[self.violationTypePicker selectRow:i inComponent:0 animated:NO];
			break;
		}
		
	}
	
	[self.fullAddress resignFirstResponder];
	[self.locationDescription resignFirstResponder];
	[self.violationDescription resignFirstResponder];
	[self.municipalCode resignFirstResponder];
	self.violationTypePickerView.hidden = NO;
}

-(IBAction)hideViolationTypePickerView:(id)sender {
	
	self.navigationItem.leftBarButtonItem.enabled = YES;
	self.navigationItem.rightBarButtonItem.enabled = YES;
	self.violationTypePickerView.hidden = YES;
}

-(IBAction)setViolationType:(id)sender {
	
	self.navigationItem.leftBarButtonItem.enabled = YES;
	self.navigationItem.rightBarButtonItem.enabled = YES;
	
	self.violationTypePickerView.hidden = YES;
	self.submittedViolationTypeLabel.text = [self.violationTypeDomainValues objectAtIndex:[self.violationTypePicker selectedRowInComponent:0]];
	if (!self.isEditingViolation && [self.violationTypePicker selectedRowInComponent:0] != 0) {
		self.shouldAskToSave = YES;
	}
	
}

#pragma mark -

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.

	return YES;
}

#pragma mark Memory Management

- (void)viewDidUnload {
	
	self.violationTypeDomainValues = nil;
	self.violationAndInspectionScrollView = nil;
	self.currentMapPoint = nil;
	self.fullAddress = nil;
	self.locationDescription = nil;
	self.violationDescription = nil;
	self.municipalCode = nil;
	self.submittedDateLabel = nil;
	self.visiableFromPublicSegmentedControl = nil;
	self.violationStatusSegmentedControl = nil;
	self.actionsheetView = nil;
	self.actionsheetSelectDateLabel = nil;
	self.actionsheetCloseButton = nil;
	self.actionsheetSubmitDatePicker = nil;
	self.actionsheetSelectDateButton = nil;
	self.violationGraphicNew = nil;
	self.violationID = nil;
	self.violationTypePickerView = nil;
	self.selectViolationTypeLabel = nil;
	self.violationTypePickerCloseButton = nil;
	self.violationTypePicker = nil;
	self.violationTypePickerSubmitButton = nil;
	self.submittedViolationTypeLabel = nil;
	[super viewDidUnload];
	
}


- (void)dealloc {
	
	[self.violationTypeDomainValues release];
	[self.violationAndInspectionScrollView release];
	[self.currentMapPoint release];
	[self.fullAddress release];
	[self.locationDescription release];
	[self.violationDescription release];
	[self.municipalCode release];
	[self.submittedDateLabel release];
	[self.visiableFromPublicSegmentedControl release];
	[self.violationStatusSegmentedControl release];
	[self.actionsheetView release];
	[self.actionsheetSelectDateLabel release];
	[self.actionsheetCloseButton release];
	[self.actionsheetSubmitDatePicker release];
	[self.actionsheetSelectDateButton release];
	[self.violationGraphicNew release];
	[self.violationID release];
	[self.violationTypePickerView release];
	[self.selectViolationTypeLabel release];
	[self.violationTypePickerCloseButton release];
	[self.violationTypePicker release];
	[self.violationTypePickerSubmitButton release];
	[self.submittedViolationTypeLabel release];
    [super dealloc];
}

#pragma mark -



@end
