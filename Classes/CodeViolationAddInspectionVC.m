//
//  CodeViolationAddInspectionVC.m
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

#import "CodeViolationAddInspectionVC.h"
#import "CodeViolationMapVC.h"

@implementation CodeViolationAddInspectionVC
@synthesize selectedViolationGraphic, selectedInspectionGraphic, violationDetailsTableView, violationsFieldAliasDictionary, 
violationDetailsDisplayFieldsArray, violationAndInspectionScrollView, isEditingInspection, inspectionsFeatureLayer, 
inspectionAttributesDict, inspectionAttachmentImageData, inspectionAttachmentImageView, addAttachmentImageButton,
removeAttachmentImageButton, imagePickerPopover, inspectionObjectId;
@synthesize workorderId, inspectionStartDateLabel, inspectionNotes, contactOwnerSegmentedControl, 
inspectionEndDateLabel, inspectionUser, addNewInspectionLabel;

// Date Actionsheet

@synthesize actionsheetView, actionsheetSelectDateLabel, actionsheetCloseButton, actionsheetSubmitDatePicker, 
actionsheetSelectDateButton, isStartDateSelected, actionDomainValues, inspectionStatusDomainValues, 
selectStartDateButton, selectEndDateButton,shouldAskToSave;

// Action Picker View
@synthesize actionPickerView, actionPickerSelectActionLabel, actionPickerCloseButton, actionPicker, actionPickerSubmitButton, 
submittedActionLabel;

@synthesize inspectionId, didUpdateInspection,saveInspectionButton,didClickSearchButton,loadingImageActivityIndicator,didupdateAttachment,activeField;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 

#pragma mark View Lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	self.title = [CodeViolationConfigSettings panelTitle];	

	self.inspectionsFeatureLayer = [AGSFeatureLayer featureServiceLayerWithURL:[NSURL URLWithString:[CodeViolationConfigSettings inspectionFeatureLayerUrl]] 
																		  mode:AGSFeatureLayerModeSnapshot];
	self.inspectionsFeatureLayer.editingDelegate = self;
	self.violationDetailsTableView.backgroundView = nil;
	
	UIButton *backButton =[UIButton buttonWithType:UIButtonTypeCustom];
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton.png"] forState:UIControlStateNormal];
	[backButton setFrame:CGRectMake(5,8,49,30)];
	[backButton addTarget:self action:@selector(methodForAskToSave) forControlEvents:UIControlEventTouchDown];
	
	UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];

	self.navigationItem.leftBarButtonItem = backButtonItem;
	
	UIBarButtonItem *searchBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchBarButtonClicked)];
	self.navigationItem.rightBarButtonItem = searchBarButton;
	
	//self.violationDetailsTableView.layer.cornerRadius = 10.0;
	self.inspectionNotes.layer.cornerRadius = 5.0;
	self.inspectionAttachmentImageView.layer.cornerRadius = 5.0;
	[self.inspectionAttachmentImageView setImage:nil];
	
	 
	[self.saveInspectionButton setBackgroundImage:[[UIImage imageNamed:@"image165.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:0.0] forState:UIControlStateNormal] ;
	[self.actionPickerSubmitButton setBackgroundImage:[[UIImage imageNamed:@"image165.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:0.0] forState:UIControlStateNormal] ;
	[self.actionsheetSelectDateButton setBackgroundImage:[[UIImage imageNamed:@"image165.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:0.0] forState:UIControlStateNormal] ;
	
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated {
	
	[self.violationAndInspectionScrollView setContentOffset:CGPointMake(0, 0)];
	self.actionsheetSubmitDatePicker.date = [NSDate date];
	[self.violationAndInspectionScrollView setContentSize:CGSizeMake(320.0, 1250.0)];
	self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
	
	CGRect tempFrame = self.actionsheetView.frame;
	tempFrame.size = CGSizeMake(320.0, 1400.0);
	
	self.actionsheetView.frame = tempFrame;
	self.actionPickerView.frame = tempFrame;

	[self registerForKeyboardNotifications];
	[self.workorderId resignFirstResponder];
	[self.inspectionNotes resignFirstResponder];
	[self.inspectionUser resignFirstResponder];
	
	[self.inspectionNotes.layer setBorderWidth:1.0];
	[self.inspectionNotes.layer setBorderColor: [[UIColor grayColor] CGColor]];
	
	[self.saveInspectionButton.layer setBorderColor:[[UIColor grayColor] CGColor]];
	[self.saveInspectionButton.layer setBorderWidth:1.0];
	[self.saveInspectionButton.layer setCornerRadius:8.0];

	
	[super viewWillAppear:YES];
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
	[self.violationAndInspectionScrollView setContentOffset:CGPointMake(0, 0)];
}

// Called when the UIKeyboardWillShowNotification is sent
- (void)keyboardWillBeShown:(NSNotification*)aNotification {
	((CodeViolationMapVC *)(((CodeViolationAppDelegate *)[[UIApplication sharedApplication] delegate]).objCodeViolationMapVC)).mapView.userInteractionEnabled = NO;
	
}

#pragma mark -
#pragma mark UITextViewDelegate And UITextFieldDelegate Methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)text{
	// Any new character added is passed in as the "text" parameter
    if ([text isEqualToString:@"\n"]) {
        // Be sure to test for equality using the "isEqualToString" message
        [self textFieldDoneEditing:textField];
		
        // Return FALSE so that the final '\n' character doesn't get added
        return FALSE;
    }
	else if([textField.text length] + text.length > 50){
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

#pragma mark -- UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
	[self textFieldBeganEditing:textView];
	return TRUE;
}


- (IBAction)textFieldBeganEditing:(id)sender {
	self.activeField = sender;
	[self.violationAndInspectionScrollView setContentOffset:CGPointMake(0, 260)];
    UITextField *nextField = nil;
	if ( sender == self.workorderId) {
        nextField = (UITextField *)self.inspectionUser;
    } else if ( sender == (UITextField *)self.inspectionUser ) {
        nextField = (UITextField *)self.inspectionNotes;
    } else if ( sender == self.inspectionNotes ) {
		//nextField = nil;
		[sender setReturnKeyType:UIReturnKeyDone];
    }
	
	//if next field is blank, then set return as Next else set it as Done
	NSString *nextText = [nextField text];
	if( (! nextText || [nextText isEqualToString:@""] ) && sender != self.inspectionNotes) {
		[activeField setReturnKeyType:UIReturnKeyNext];
	} else {
		[activeField setReturnKeyType:UIReturnKeyDone];
	}
}

- (IBAction)textFieldDoneEditing:(id)sender {
	
    if( [sender returnKeyType] == UIReturnKeyNext ) {
		if( activeField == self.workorderId ) {
            [self.inspectionUser becomeFirstResponder];
        } else if( activeField == (UITextField*)self.inspectionUser ) {
            [self.inspectionNotes becomeFirstResponder];
        } 
    } else {
        [sender resignFirstResponder];
    }
}



#pragma mark -

#pragma mark AGSFeatureLayerEditingDelegate Methods

- (void)featureLayer:(AGSFeatureLayer *) featureLayer operation:(NSOperation *) op didFeatureEditsWithResults:(AGSFeatureLayerEditResults *) editResults
{
	[((CodeViolationAppDelegate *)[[UIApplication sharedApplication]delegate]).activityAlertViewInspection dismissWithClickedButtonIndex:0 animated:YES];
    
	if ([editResults.addResults count] > 0) {
		
		AGSEditResult *addresult = (AGSEditResult*)[editResults.addResults objectAtIndex:0];
		
		NSMutableDictionary *updatedInspectionAttributes = [NSMutableDictionary dictionaryWithObjectsAndKeys:
													 [NSNumber numberWithInt:addresult.objectId],@"OBJECTID",
													 [NSString stringWithFormat:@"%@", [NSNumber numberWithInt:addresult.objectId]], @"INSPECTID",
													 [self.inspectionAttributesDict valueForKey:@"VIOLATEKEY"], @"VIOLATEKEY",
													 [self.inspectionAttributesDict valueForKey:@"WORKKEY"], @"WORKKEY",
													 [self.inspectionAttributesDict valueForKey:@"INSSTART"], @"INSSTART",
													 [self.inspectionAttributesDict valueForKey:@"NOTE"], @"NOTE",
													 [self.inspectionAttributesDict valueForKey:@"CONTACTOWN"], @"CONTACTOWN",
													 [self.inspectionAttributesDict valueForKey:@"ACTION"], @"ACTION",
													 [self.inspectionAttributesDict valueForKey:@"INSEND"], @"INSEND",
													 [self.inspectionAttributesDict valueForKey:@"INSPECTOR"], @"INSPECTOR",
													 [self.inspectionAttributesDict valueForKey:@"INSSTATUS"], @"INSSTATUS",
													 [self.inspectionAttributesDict valueForKey:@"LASTUPDATE"], @"LASTUPDATE",
													 nil];
		
		AGSGraphic *inspectionGraphicNew = [AGSGraphic graphicWithGeometry:nil symbol:nil attributes:updatedInspectionAttributes infoTemplateDelegate:nil];
		
		((CodeViolationRootVC *)((CodeViolationAppDelegate *)[UIApplication sharedApplication].delegate).objCodeViolationRootVC).objCodeViolationFeatureDetailsVC.inspectionGraphicNew = inspectionGraphicNew;
		
		[self.inspectionsFeatureLayer addAttachment:addresult.objectId data:self.inspectionAttachmentImageData filename:[NSString stringWithFormat:@"%i.jpg",addresult.objectId]];
		
		
		//commit changes to featurelayer
		[self.inspectionsFeatureLayer applyEditsWithFeaturesToAdd: nil
														 toUpdate: [NSArray arrayWithObject:inspectionGraphicNew]
														 toDelete: nil];
		
	}
	else if([editResults.updateResults count] > 0)
	{
		
		AGSEditResult *updateResult = (AGSEditResult *)[editResults.updateResults objectAtIndex:0];
				
		self.inspectionObjectId = updateResult.objectId;
		
		[self.inspectionsFeatureLayer queryAttachmentInfosForObjectId:self.inspectionObjectId];
		
		[self.inspectionsFeatureLayer refresh];

		(((CodeViolationAppDelegate *)[UIApplication sharedApplication].delegate).objCodeViolationRootVC).objCodeViolationFeatureDetailsVC.inspectionsQuery.where = [NSString stringWithFormat:@"VIOLATEKEY='%@'", [self.selectedViolationGraphic   attributeForKey:@"VIOLATIONID"]];
		
		[(((CodeViolationAppDelegate *)[UIApplication sharedApplication].delegate).objCodeViolationRootVC).objCodeViolationFeatureDetailsVC.inspectionsQueryTask executeWithQuery:(((CodeViolationAppDelegate *)[UIApplication sharedApplication].delegate).objCodeViolationRootVC).objCodeViolationFeatureDetailsVC.inspectionsQuery];
		
		self.isEditingInspection = NO;
		self.didUpdateInspection = YES;
		
		[((CodeViolationRootVC *)((CodeViolationAppDelegate *)[UIApplication sharedApplication].delegate).objCodeViolationRootVC).objCodeViolationFeatureDetailsVC.inspectionDetailsTableView reloadData];
		[((CodeViolationRootVC *)((CodeViolationAppDelegate *)[UIApplication sharedApplication].delegate).objCodeViolationRootVC).navigationController popViewControllerAnimated:YES];


		
		[((CodeViolationMapVC *)((CodeViolationAppDelegate *)[UIApplication sharedApplication].delegate).objCodeViolationMapVC) endActivityIndicator];
	}
	
}

- (void)featureLayer:(AGSFeatureLayer *) featureLayer operation:(NSOperation *) op 
didFailFeatureEditsWithError:(NSError *) error {
	
	UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ErrorTitle", @"ErrorTitle Item") 
													 message:[error localizedDescription]  
													delegate:nil 
										   cancelButtonTitle:NSLocalizedString(@"OK", @"OKTitle Item")
										   otherButtonTitles:nil] ;
	[alert show];
	[alert release];	
	   
	[((CodeViolationMapVC *)((CodeViolationAppDelegate *)[UIApplication sharedApplication].delegate).objCodeViolationMapVC) endActivityIndicator];
	
}

- (void)featureLayer:(AGSFeatureLayer *) featureLayer operation:(NSOperation *) op 
didQueryAttachmentInfosWithResults:(NSArray *) attachmentInfos {
	
	if (attachmentInfos.count > 0) {
		AGSAttachmentInfo *attachmentInfo = [attachmentInfos objectAtIndex:0];
		if (self.inspectionAttachmentImageView.image == nil) {
			[self.inspectionsFeatureLayer deleteAttachmentsForObjectId:self.inspectionObjectId attachmentIds:[NSArray arrayWithObject:[NSNumber numberWithInt:attachmentInfo.attachmentId]]];
		}
		else {
			[self.inspectionsFeatureLayer updateAttachment:self.inspectionObjectId data:self.inspectionAttachmentImageData filename:[NSString stringWithFormat:@"%i.jpg", self.inspectionObjectId] attachmentId:attachmentInfo.attachmentId];
		}
		self.didupdateAttachment = YES;
	}
	else {
		if (self.inspectionAttachmentImageView.image != nil) {
			[self.inspectionsFeatureLayer addAttachment:self.inspectionObjectId data:self.inspectionAttachmentImageData filename:[NSString stringWithFormat:@"%i.jpg",self.inspectionObjectId]];
		self.didupdateAttachment = YES;
		}
		
	}
}


- (void)featureLayer:(AGSFeatureLayer *) featureLayer operation:(NSOperation *) op 
didFailQueryAttachmentInfosWithError:(NSError *) error {
	
	UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ErrorTitle", @"ErrorTitle Item") 
													 message:[error localizedDescription]  
													delegate:nil 
										   cancelButtonTitle:NSLocalizedString(@"OK", @"OKTitle Item")
										   otherButtonTitles:nil] ;
	[alert show];
	[alert release];	
	
}


#pragma mark -



#pragma mark UIImagePickerControllerDelegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	self.shouldAskToSave = YES;
	self.addAttachmentImageButton.hidden = YES;
	self.removeAttachmentImageButton.hidden = NO;
	self.shouldAskToSave = YES;	
	UIImage *selectedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
	
	self.inspectionAttachmentImageData = UIImageJPEGRepresentation(selectedImage, 0.1);
	
	[self.inspectionAttachmentImageView setImage:selectedImage];
	
	[self.imagePickerPopover dismissPopoverAnimated:YES];

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -

#pragma mark UIPickerViewDelegate Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {

	int returnCount = 0;
	
	if (pickerView == self.actionPicker) {
		returnCount = [self.actionDomainValues count];
	}	
	return returnCount;

}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	
	NSString *pickerRow = nil;
	
	if (pickerView == self.actionPicker) {
		pickerRow = [NSString stringWithFormat:@"%@", [self.actionDomainValues objectAtIndex:row]];
	}
	
	return pickerRow;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.		
	return [self.violationDetailsDisplayFieldsArray count];

}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil) {
		
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
		
		UILabel * propertyAttributeLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
		propertyAttributeLabel.backgroundColor = [UIColor clearColor];
		propertyAttributeLabel.opaque = NO;
		propertyAttributeLabel.textColor = [UIColor blackColor];
		propertyAttributeLabel.font = [UIFont boldSystemFontOfSize:14];
		propertyAttributeLabel.numberOfLines = 2;
		propertyAttributeLabel.frame = CGRectMake(LEFT_MARGIN,TOP_MARGIN, cell.frame.size.width/2.3, TOP_MARGIN * 2);
		propertyAttributeLabel.center = CGPointMake(LEFT_MARGIN + propertyAttributeLabel.frame.size.width/2 , TOP_MARGIN + propertyAttributeLabel.frame.size.height/2 );
		[propertyAttributeLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
		propertyAttributeLabel.textAlignment = UITextAlignmentLeft;
		propertyAttributeLabel.tag = 1;
		[cell.contentView addSubview:propertyAttributeLabel];
		
		UILabel * propertyValueLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
		propertyValueLabel.backgroundColor = [UIColor clearColor];
		propertyValueLabel.opaque = NO;
		propertyValueLabel.textColor = [UIColor blackColor];
		propertyValueLabel.font = [UIFont systemFontOfSize:13];
		propertyValueLabel.numberOfLines = 0;
		propertyValueLabel.tag = 2;
		[cell.contentView addSubview:propertyValueLabel];
		
	}
	
	UILabel *tempPropertyAttributeLabel = (UILabel *)[cell.contentView viewWithTag:1];
	
	UILabel *tempPropertyValueLabel = (UILabel *)[cell.contentView viewWithTag:2];
	
	if ([[self.selectedViolationGraphic.allAttributes allKeys] count] > 0)
	{
		
		NSArray *tempArray = [[NSString stringWithFormat:@"%@", [self.violationDetailsDisplayFieldsArray objectAtIndex:indexPath.row]] componentsSeparatedByString:@"|"];
		
		tempPropertyAttributeLabel.text = [NSString stringWithFormat:@"%@", [self.violationsFieldAliasDictionary valueForKey:[tempArray objectAtIndex:0]]];
		
		NSString *propertyValue = @"";
		
		if ([tempArray count] == 1) {
			// Check Null field
			if ([[self.selectedViolationGraphic   attributeForKey:[tempArray objectAtIndex:0]] isKindOfClass:[NSNull class]]
            || [self.selectedViolationGraphic   attributeForKey:[tempArray objectAtIndex:0]] == nil ||
            [[NSString stringWithFormat:@"%@", [self.selectedViolationGraphic   attributeForKey:[tempArray objectAtIndex:0]]] isEqualToString:@""])  {
				propertyValue = NSLocalizedString(@"NoData", @"NoData Item");
			}
			else {
				propertyValue = [NSString stringWithFormat:@"%@", [self.selectedViolationGraphic   attributeForKey:[tempArray objectAtIndex:0]]];
			}
			
		}
		else if ([tempArray count] > 1)
		{
			// Check Null field
			if ([self.selectedViolationGraphic   attributeForKey:[tempArray objectAtIndex:0]] == [NSNull null] ||
				[self.selectedViolationGraphic   attributeForKey:[tempArray objectAtIndex:0]] == nil ||
				[[NSString stringWithFormat:@"%@", [self.selectedViolationGraphic   attributeForKey:[tempArray objectAtIndex:0]]] isEqualToString:@""])  {
				propertyValue = NSLocalizedString(@"NoData", @"NoData Item");
			}
			else {
				
				NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[self.selectedViolationGraphic   attributeForKey:[tempArray objectAtIndex:0]] doubleValue]/1000];
				NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
				[dateFormatter setDateStyle:NSDateFormatterLongStyle];
				NSTimeZone *timeZone = [NSTimeZone timeZoneWithAbbreviation:@"IST"];
				[dateFormatter setTimeZone:timeZone];
				propertyValue = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:date]];
				[dateFormatter release];
			}				
			
		}
		
		CGSize constraint = CGSizeMake((cell.frame.size.width - (LEFT_MARGIN+RIGHT_MARGIN)),20000) ;
		CGSize size = [propertyValue sizeWithFont:[UIFont boldSystemFontOfSize:13.0] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap] ;
		tempPropertyValueLabel.frame = CGRectMake(tempPropertyAttributeLabel.frame.origin.x , tempPropertyAttributeLabel.frame.size.height + (TOP_MARGIN/2) , (cell.frame.size.width - 30), MAX(size.height,35.0)) ;
		tempPropertyValueLabel.center = CGPointMake(tempPropertyValueLabel.frame.origin.x  + (tempPropertyValueLabel.frame.size.width /2),tempPropertyAttributeLabel.frame.size.height + (TOP_MARGIN / 2) + (tempPropertyValueLabel.frame.size.height/2));
		
		tempPropertyValueLabel.text = propertyValue ;
	}
	
	
	return cell;
	
}


#pragma mark -
#pragma mark Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	float height = 0;
		switch ([indexPath section]) {
			case 0:
				if ([[self.selectedViolationGraphic.allAttributes allKeys] count] > 0)
				{
					NSArray *tempArray = [[NSString stringWithFormat:@"%@", [self.violationDetailsDisplayFieldsArray objectAtIndex:indexPath.row]] componentsSeparatedByString:@"|"];
					
					NSString *propertyValue = @"";
					
					if ([tempArray count] == 1) {
											
						// Check Null field
						
						if ([self.selectedViolationGraphic   attributeForKey:[tempArray objectAtIndex:0]] == [NSNull null] ||
							[self.selectedViolationGraphic   attributeForKey:[tempArray objectAtIndex:0]] == nil ||
							[[NSString stringWithFormat:@"%@", [self.selectedViolationGraphic   attributeForKey:[tempArray objectAtIndex:0]]] isEqualToString:@""]) {
							propertyValue = NSLocalizedString(@"NoData", @"NoData Item");
						}
						else {
							propertyValue = [NSString stringWithFormat:@"%@", [self.selectedViolationGraphic   attributeForKey:[tempArray objectAtIndex:0]]];
						}
						
					}
					else if ([tempArray count] > 1)
					{
						// Check Null field
						
						if ([[self.selectedViolationGraphic   attributeForKey:[tempArray objectAtIndex:0]] isKindOfClass:[NSNull class]] ||
							[self.selectedViolationGraphic   attributeForKey:[tempArray objectAtIndex:0]] == nil ||
							[[NSString stringWithFormat:@"%@", [self.selectedViolationGraphic   attributeForKey:[tempArray objectAtIndex:0]]] isEqualToString:@""]) {
							propertyValue = NSLocalizedString(@"NoData", @"NoData Item");
						}
						else {
							
							NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[self.selectedViolationGraphic   attributeForKey:[tempArray objectAtIndex:0]] doubleValue]/1000];
							NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
							
							[dateFormatter setDateStyle:NSDateFormatterLongStyle];
							
							NSTimeZone *timeZone = [NSTimeZone timeZoneWithAbbreviation:@"IST"];
							[dateFormatter setTimeZone:timeZone];
							
							propertyValue = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:date]];
							
							[dateFormatter release];
						}				
						
					}
					
					CGSize constraint = CGSizeMake(self.view.frame.size.width, 20000.0f);
					CGSize size = [propertyValue sizeWithFont:[UIFont boldSystemFontOfSize:13.0] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
					height =  MAX(TOP_MARGIN + BOTTOM_MARGIN/2 + size.height + 35 ,35.0)  ;
				}
				
				break;
		}
	return height;
}



#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch (buttonIndex) {
		case 0:
			self.shouldAskToSave = NO;
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


#pragma mark -
#pragma mark Actions
- (void) methodForAskToSave {
	if ([self checkForFieldChanges]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
														message:NSLocalizedString(@"DoyouWanttoSavetheChanges", @"DoyouWanttoSavetheChanges Item") 
													   delegate:self 
											  cancelButtonTitle:nil
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
	if (self.isEditingInspection) {
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
	
	//Inspection notes
	NSString *notes = nil;
	if ([[self.selectedInspectionGraphic   attributeForKey:@"NOTES"] isKindOfClass:[NSNull class]] ||
		[self.selectedInspectionGraphic   attributeForKey:@"NOTES"] == nil ||
		[[NSString stringWithFormat:@"%@", [self.selectedInspectionGraphic   attributeForKey:@"NOTES"]] isEqualToString:@""]) 
	{
		notes = @"";
	}
	else {
		
		notes = [self.selectedInspectionGraphic   attributeForKey:@"NOTES"];
	}
	
	if (![notes isEqualToString:self.inspectionNotes.text]) {
		returnValue = YES;
	}
	
	//WORKKEY 
	NSString *workKey = nil;
	if ([[self.selectedInspectionGraphic   attributeForKey:@"WORKKEY"] isKindOfClass:[NSNull class]] ||
		[self.selectedInspectionGraphic   attributeForKey:@"WORKKEY"] == nil ||
		[[NSString stringWithFormat:@"%@", [self.selectedInspectionGraphic   attributeForKey:@"WORKKEY"]] isEqualToString:@""]) 
	{
		workKey = @"";
	}
	else {
		
		workKey = [self.selectedInspectionGraphic   attributeForKey:@"WORKKEY"];
	}
	
	if (![workKey isEqualToString:self.workorderId.text]) {
		returnValue = YES;
	}
	
	//INSPECTOR 
	NSString *inspector = nil;
	if ([[self.selectedInspectionGraphic   attributeForKey:@"INSPECTOR"] isKindOfClass:[NSNull class]] ||
		[self.selectedInspectionGraphic   attributeForKey:@"INSPECTOR"] == nil ||
		[[NSString stringWithFormat:@"%@", [self.selectedInspectionGraphic   attributeForKey:@"INSPECTOR"]] isEqualToString:@""]) 
	{
		inspector = @"";
	}
	else {
		
		inspector = [self.selectedInspectionGraphic   attributeForKey:@"INSPECTOR"];
	}
	
	if (![inspector isEqualToString:self.inspectionUser.text]) {
		returnValue = YES;
	}
	
	//contactOwner
	NSString *contactOwner = nil;
	if ([[self.selectedInspectionGraphic   attributeForKey:@"CONTACTOWN"] isKindOfClass:[NSNull class]] ||
		[self.selectedInspectionGraphic   attributeForKey:@"CONTACTOWN"] == nil ||
		[[NSString stringWithFormat:@"%@", [self.selectedInspectionGraphic   attributeForKey:@"CONTACTOWN"]] isEqualToString:@""]) 
	{
		contactOwner = @"";
	}
	else {
		contactOwner = [self.selectedInspectionGraphic   attributeForKey:@"CONTACTOWN"];
	}		
	
	if (![contactOwner isEqualToString:[self.contactOwnerSegmentedControl titleForSegmentAtIndex:self.contactOwnerSegmentedControl.selectedSegmentIndex]]) {
		returnValue = YES;
	}
	
	return returnValue;
}

#pragma mark -

-(IBAction)showPhotoLobrary:(id)sender {
	
	UIButton *addImageButton = (UIButton *)sender;
	CGPoint scrollOffsetPoint = self.violationAndInspectionScrollView.contentOffset;
	
	CGRect addImageButtonRect = CGRectMake(addImageButton.frame.origin.x, (addImageButton.frame.origin.y - scrollOffsetPoint.y), addImageButton.frame.size.width, addImageButton.frame.size.height);
	
	if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
	{
		UIImagePickerController* picker = [[UIImagePickerController alloc] init]; 
		picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary; 
		picker.delegate = self; 
		
		UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:picker];
		self.imagePickerPopover = popover;
		self.imagePickerPopover.delegate = self;
		[self.imagePickerPopover presentPopoverFromRect:addImageButtonRect 
												 inView:self.view 
							   permittedArrowDirections:UIPopoverArrowDirectionLeft 
											   animated:YES];
		[picker release];
		[popover release];
	}
}

-(IBAction)removeAttachmentImage:(id)sender {
	self.shouldAskToSave = YES;
	[self.inspectionAttachmentImageView setImage:nil];
	self.addAttachmentImageButton.hidden = NO;
	self.removeAttachmentImageButton.hidden = YES;
}

-(IBAction)addInspection:(id)sender {

	if([self validateInspectionFields])
	{
		if (self.shouldAskToSave) {
			self.shouldAskToSave = NO;
		}
		((CodeViolationMapVC *)((CodeViolationAppDelegate *)[UIApplication sharedApplication].delegate).objCodeViolationMapVC).progressLabel.hidden = YES;
		
		if (isEditingInspection) {
			
			// Edit Inspection
			
			NSString *contactOwner = [self.contactOwnerSegmentedControl titleForSegmentAtIndex:self.contactOwnerSegmentedControl.selectedSegmentIndex];
			
			// Convert string to date object
			NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
			[dateFormatter setDateFormat:@"MMM dd yyyy"];
			
			NSDate *inspectionStartDate = [dateFormatter dateFromString:self.inspectionStartDateLabel.text]; 
			NSTimeInterval timeIntervalForStartDate = ([inspectionStartDate timeIntervalSince1970]*1000);
			
			NSDate *inspectionEndDate = [dateFormatter dateFromString:self.inspectionEndDateLabel.text];
			NSTimeInterval timeIntervalForEndDate = ([inspectionEndDate timeIntervalSince1970]*1000);
			
			NSTimeInterval timeIntervalForLastUpdate = [[NSDate date] timeIntervalSince1970]*1000;
			
			
			self.inspectionAttributesDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
											 [NSNumber numberWithInt:self.inspectionObjectId], @"OBJECTID",
											 self.inspectionId, @"INSPECTID",
											 [self.selectedInspectionGraphic   attributeForKey:@"VIOLATEKEY"], @"VIOLATEKEY",
											 self.workorderId.text, @"WORKKEY",
											 [NSNumber numberWithDouble:timeIntervalForStartDate], @"INSSTART",
											 self.inspectionNotes.text, @"NOTES",
											 contactOwner, @"CONTACTOWN",
											 self.submittedActionLabel.text, @"ACTION",
											 [NSNumber numberWithDouble:timeIntervalForEndDate], @"INSEND",
											 self.inspectionUser.text, @"INSPECTOR",
											 @"Unassigned", @"INSSTATUS",
											 [NSNumber numberWithDouble:timeIntervalForLastUpdate], @"LASTUPDATE",
											 nil];
			
			AGSGraphic *inspectionGraphicNew = [[AGSGraphic alloc] initWithGeometry:nil symbol:nil attributes:self.inspectionAttributesDict infoTemplateDelegate:nil];
			
			//commit changes to featurelayer
			[self.inspectionsFeatureLayer applyEditsWithFeaturesToAdd: nil
															 toUpdate: [NSArray arrayWithObject:inspectionGraphicNew]
															 toDelete: nil];
			
			
			[dateFormatter release];
			[inspectionGraphicNew release];
			
		}
		else {
			
			// Add new inspection
			
			NSString *contactOwner = [self.contactOwnerSegmentedControl titleForSegmentAtIndex:self.contactOwnerSegmentedControl.selectedSegmentIndex];

			// Convert string to date object
			NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
			[dateFormatter setDateFormat:@"MMM dd yyyy"];
			
			NSDate *inspectionStartDate = [dateFormatter dateFromString:self.inspectionStartDateLabel.text]; 
			NSTimeInterval timeIntervalForStartDate = ([inspectionStartDate timeIntervalSince1970]*1000);
			
			NSDate *inspectionEndDate = [dateFormatter dateFromString:self.inspectionEndDateLabel.text];
			NSTimeInterval timeIntervalForEndDate = ([inspectionEndDate timeIntervalSince1970]*1000);
			
			NSTimeInterval timeIntervalForLastUpdate = [[NSDate date] timeIntervalSince1970]*1000;
			
			self.inspectionAttributesDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
											 @"0", @"INSPECTID",
											 [self.selectedViolationGraphic   attributeForKey:@"VIOLATIONID"], @"VIOLATEKEY",
											 self.workorderId.text, @"WORKKEY",
											 [NSNumber numberWithDouble:timeIntervalForStartDate], @"INSSTART",
											 self.inspectionNotes.text, @"NOTES",
											 contactOwner, @"CONTACTOWN",
											 self.submittedActionLabel.text, @"ACTION",
											 [NSNumber numberWithDouble:timeIntervalForEndDate], @"INSEND",
											 self.inspectionUser.text, @"INSPECTOR",
											 @"Unassigned", @"INSSTATUS",
											 [NSNumber numberWithDouble:timeIntervalForLastUpdate], @"LASTUPDATE",
											 nil];
			
			AGSGraphic *inspectionGraphicNew = [[AGSGraphic alloc] initWithGeometry:nil symbol:nil attributes:self.inspectionAttributesDict infoTemplateDelegate:nil];
			
			
			//commit changes to featurelayer
			[self.inspectionsFeatureLayer applyEditsWithFeaturesToAdd:[NSArray arrayWithObject:inspectionGraphicNew]
															 toUpdate: nil
															 toDelete: nil];
			
			[dateFormatter release];
			[inspectionGraphicNew release];
		}
        
        
        [((CodeViolationAppDelegate *)[[UIApplication sharedApplication]delegate]).activityAlertViewInspection show];
        

        [((CodeViolationMapVC *)((CodeViolationAppDelegate *)[UIApplication sharedApplication].delegate).objCodeViolationMapVC) beginActivityIndicator];
               
	}
	else {        
        
		[((CodeViolationMapVC *)((CodeViolationAppDelegate *)[UIApplication sharedApplication].delegate).objCodeViolationMapVC) endActivityIndicator];            
	}

}

#pragma mark Date Actionsheet


-(IBAction)showActionSheet:(id)sender {
	
	self.navigationItem.leftBarButtonItem.enabled = NO;
	self.navigationItem.rightBarButtonItem.enabled = NO;
	
	self.actionsheetSubmitDatePicker.maximumDate = [NSDate date];
	if (isEditingInspection) {
		
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"MMM dd yyyy"];
		
		if (((UIButton *)sender) ==  self.selectStartDateButton) {
			self.isStartDateSelected = YES;
			NSDate *startDate = [dateFormatter dateFromString:self.inspectionStartDateLabel.text];
			[self.actionsheetSubmitDatePicker setDate:startDate animated:NO];
		}
		else if (((UIButton *)sender) == self.selectEndDateButton)
		{
			self.isStartDateSelected = NO;
			NSDate *endDate = [dateFormatter dateFromString:self.inspectionEndDateLabel.text];
			[self.actionsheetSubmitDatePicker setDate:endDate animated:NO];
		}
		
		[dateFormatter release];
	}
	else {
		
		
		if (((UIButton *)sender) ==  self.selectStartDateButton) {
			
			self.isStartDateSelected = YES;
		}
		else if (((UIButton *)sender) == self.selectEndDateButton)
		{
			self.isStartDateSelected = NO;
		}
	}
	
	[self.workorderId resignFirstResponder];
	[self.inspectionNotes resignFirstResponder];
	[self.inspectionUser resignFirstResponder];
	
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
	
	if (self.isStartDateSelected) {
		if (![submittedDate isEqualToString:self.inspectionStartDateLabel.text]) {
			self.shouldAskToSave = YES;
		}
		self.inspectionStartDateLabel.text = submittedDate;
	}
	else {
		if (![submittedDate isEqualToString:self.inspectionEndDateLabel.text]) {
			self.shouldAskToSave = YES;
		}
		self.inspectionEndDateLabel.text = submittedDate;
	}
	
	self.actionsheetView.hidden = YES;
	
}


#pragma mark Action Picker View

-(IBAction)showActionPickerView:(id)sender {
	
	self.navigationItem.leftBarButtonItem.enabled = NO;
	self.navigationItem.rightBarButtonItem.enabled = NO;
	
	for (int i=0; i<self.actionDomainValues.count; i++) {
		
		if ([self.submittedActionLabel.text isEqualToString:[self.actionDomainValues objectAtIndex:i]]) {
			
			[self.actionPicker selectRow:i inComponent:0 animated:NO];
			break;
		}
		
	}
	
	[self.workorderId resignFirstResponder];
	[self.inspectionNotes resignFirstResponder];
	[self.inspectionUser resignFirstResponder];
	
	self.actionPickerView.hidden = NO;
}

-(IBAction)hideActionPickerView:(id)sender {
	self.navigationItem.leftBarButtonItem.enabled = YES;
	self.navigationItem.rightBarButtonItem.enabled = YES;
	
	self.actionPickerView.hidden = YES;
}

-(IBAction)setSubmittedAction:(id)sender {
	self.navigationItem.leftBarButtonItem.enabled = YES;
	self.navigationItem.rightBarButtonItem.enabled = YES;
	
	if (![self.submittedActionLabel.text isEqualToString:[self.actionDomainValues objectAtIndex:[self.actionPicker selectedRowInComponent:0]]]) {
		self.shouldAskToSave = YES;
	}
	self.submittedActionLabel.text = [self.actionDomainValues objectAtIndex:[self.actionPicker selectedRowInComponent:0]];
	self.actionPickerView.hidden = YES;
}



-(void)clearInspectionFields {
	
	self.workorderId.text = @"";
	self.inspectionNotes.text = @"";
	[self.contactOwnerSegmentedControl setSelectedSegmentIndex:0];
	[self.actionPicker selectRow:0 inComponent:0 animated:NO];
	self.inspectionUser.text = @"";
}

-(BOOL)validateInspectionFields {

	BOOL returnString;
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"MMM dd yyyy"];
	
	NSDate *dateOne = [dateFormatter dateFromString:self.inspectionStartDateLabel.text];
	NSDate *dateTwo = [dateFormatter dateFromString:self.inspectionEndDateLabel.text];
	
	if (self.workorderId.text.length == 0 || self.inspectionStartDateLabel.text.length == 0 || 
		self.inspectionNotes.text.length == 0 ||  self.inspectionUser.text.length == 0) {

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
	else if (self.workorderId.text.length > 50 || self.inspectionNotes.text.length > 255 || 
			 self.inspectionUser.text.length > 50) {
	
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ErrorTitle", @"ErrorTitle Item") 
														message:NSLocalizedString(@"Noofcharactersexceeded", @"Noofcharactersexceeded Item") 
													   delegate:nil 
											  cancelButtonTitle:NSLocalizedString(@"ErrorTitle", @"ErrorTitle Item")
											  otherButtonTitles:nil];
		
		[alert show];
		[alert release];
		
		returnString = NO;
		       
		[((CodeViolationMapVC *)((CodeViolationAppDelegate *)[UIApplication sharedApplication].delegate).objCodeViolationMapVC) endActivityIndicator];
		
	}
	else if ([dateOne compare:dateTwo] == NSOrderedDescending){
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ErrorTitle", @"ErrorTitle Item")
														message:NSLocalizedString(@"StartDateCantBeGreaterThenEndDate", @"StartDateCantBeGreaterThenEndDate Item") 
													   delegate:nil 
											  cancelButtonTitle:NSLocalizedString(@"OKTitle", @"OKTitle Item") 
											  otherButtonTitles:nil];
		
		[alert show];
		[alert release];		
		
		
		returnString = NO;
	}
	else {
		returnString = YES;
	}
	[dateFormatter release];
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

#pragma mark -

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

#pragma mark Memory Management

- (void)viewDidUnload {
	
    self.selectedViolationGraphic = nil;
	self.selectedInspectionGraphic = nil;
	self.violationDetailsTableView = nil;
	self.violationsFieldAliasDictionary = nil;
	self.violationDetailsDisplayFieldsArray = nil;
	self.violationAndInspectionScrollView = nil;
	self.inspectionsFeatureLayer = nil;
	self.inspectionAttributesDict = nil;
	self.inspectionAttachmentImageData = nil;
	self.inspectionAttachmentImageView = nil;
	self.addAttachmentImageButton = nil;
	self.removeAttachmentImageButton = nil;
	self.imagePickerPopover = nil;
	self.workorderId = nil;
	self.inspectionStartDateLabel = nil;
	self.inspectionNotes = nil;
	self.contactOwnerSegmentedControl = nil;
	self.inspectionEndDateLabel = nil;
	self.inspectionUser = nil;
	self.addNewInspectionLabel = nil;
	self.actionsheetView = nil;
	self.actionsheetSelectDateLabel = nil;
	self.actionsheetCloseButton = nil;
	self.actionsheetSubmitDatePicker = nil;
	self.actionsheetSelectDateButton = nil;
	self.selectStartDateButton = nil;
	self.selectEndDateButton = nil;
	self.actionDomainValues = nil;
	self.inspectionStatusDomainValues = nil;
	self.actionPickerView = nil;
	self.actionPickerSelectActionLabel = nil;
	self.actionPickerCloseButton = nil;
	self.actionPicker = nil;
	self.actionPickerSubmitButton = nil;
	self.submittedActionLabel = nil;
	self.inspectionId = nil;
	
	[super viewDidUnload];
}


- (void)dealloc {
	
	[self.selectedViolationGraphic release];
	[self.selectedInspectionGraphic release];
	[self.violationDetailsTableView release];
	[self.violationsFieldAliasDictionary release];
	[self.violationDetailsDisplayFieldsArray release];
	[self.violationAndInspectionScrollView release];
	[self.inspectionsFeatureLayer release];
	[self.inspectionAttributesDict release];
	[self.inspectionAttachmentImageData release];
	[self.inspectionAttachmentImageView release];
	[self.addAttachmentImageButton release];
	[self.removeAttachmentImageButton release];
	[self.imagePickerPopover release];
	[self.workorderId release];
	[self.inspectionStartDateLabel release];
	[self.inspectionNotes release];
	[self.contactOwnerSegmentedControl release];
	[self.inspectionEndDateLabel release];
	[self.inspectionUser release];
	[self.addNewInspectionLabel release];
	[self.actionsheetView release];
	[self.actionsheetSelectDateLabel release];
	[self.actionsheetCloseButton release];
	[self.actionsheetSubmitDatePicker release];
	[self.actionsheetSelectDateButton release];
	[self.selectStartDateButton release];
	[self.selectEndDateButton release];
	[self.actionDomainValues release];
	[self.inspectionStatusDomainValues release];
	[self.actionPickerView release];
	[self.actionPickerSelectActionLabel release];
	[self.actionPickerCloseButton release];
	[self.actionPicker release];
	[self.actionPickerSubmitButton release];
	[self.submittedActionLabel release];
	[self.inspectionId release];
	
    [super dealloc];
}

#pragma mark -

@end
