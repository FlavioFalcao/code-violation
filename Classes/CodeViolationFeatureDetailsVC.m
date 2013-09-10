//
//  CodeViolationFeatureDetailsVC.m
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

#import "CodeViolationFeatureDetailsVC.h"
#import "CodeViolationRootVC.h"
#import "CodeViolationMapVC.h"

@implementation CodeViolationFeatureDetailsVC
@synthesize selectedViolationGraphic, violationsFieldAliasDictionary, inspectionsFieldAliasDictionary, 
violationDetailsDisplayFieldsArray, inspectionDetailsDisplayFieldsArray, inspectionsFeaturesArray, violationDetailsTableView, 
inspectionDetailsTableView, objCodeViolationAddViolationVC, violationAndInspectionScrollView,objCodeViolationAddInspectionVC, 
objCodeViolationInspectionDetailsVC, inspectionsFeatureLayer, inspectionsQueryTask, inspectionsQuery, actionDomainValues, 
inspectionStatusDomainValues, editViolationButton, addInspectionButton;

@synthesize inspectionGraphicNew, tableViewBackgroundImage, didUpdateViolation,loadingInspectionsIndicator,loadingInspectionsIndicatorForButton;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    
         
	self.actionDomainValues = [[NSMutableArray alloc] init];
	self.inspectionStatusDomainValues = [[NSMutableArray alloc] init];
	self.inspectionsFieldAliasDictionary = [[NSMutableDictionary alloc] init];
	
	// Inspections Feature Layer
	
	if (self.inspectionsFeatureLayer == nil) {
        
		self.inspectionsFeatureLayer = [AGSFeatureLayer featureServiceLayerWithURL:[NSURL URLWithString:[CodeViolationConfigSettings inspectionFeatureLayerUrl]] mode:AGSFeatureLayerModeSnapshot];
		
        
		[self performSelector:@selector(getInspectionFieldsAndDomainValues) withObject:nil afterDelay:2.0];
        
       if (![[UIApplication sharedApplication] isIgnoringInteractionEvents])
		[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
	}

             
	self.violationDetailsTableView.backgroundView = nil;
	self.inspectionDetailsTableView.backgroundView = nil;
	self.title = [CodeViolationConfigSettings panelTitle];
	
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
	backButton.title =  NSLocalizedString(@"Back", @"Back Item");
	self.navigationItem.backBarButtonItem = backButton;
	
	UIBarButtonItem *searchBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchBarButtonClicked)];
	self.navigationItem.rightBarButtonItem = searchBarButton;

	[super viewDidLoad];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Override to allow orientations other than the default portrait orientation.
      
    return YES;
}



- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
 
    
    UIInterfaceOrientation deviceOrientation = [UIApplication sharedApplication].statusBarOrientation;    
    
    if (UIDeviceOrientationIsLandscape(deviceOrientation))        
    {
               
        inspectionDetailsTableView.contentInset = UIEdgeInsetsMake(0, 0, 190, 0);
    
    }
    
     if (deviceOrientation == UIDeviceOrientationPortrait)        
    {
        inspectionDetailsTableView.contentInset = UIEdgeInsetsMake(0, 0, 390, 0);
        
    }
    
}

 
#pragma mark -

#pragma mark AGSQueryTaskDelegate Methods

- (void)queryTask:(AGSQueryTask *)queryTask operation:(NSOperation *)op 
didExecuteWithFeatureSetResult:(AGSFeatureSet *)featureSet {
    
        
	//get feature, and load in to table
    if ([[UIApplication sharedApplication] isIgnoringInteractionEvents]) {
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }
    
	if ([self.loadingInspectionsIndicator isAnimating]) {
        
		[self.loadingInspectionsIndicator stopAnimating];
        
	}
	if (queryTask == self.inspectionsQueryTask) {

		if (featureSet.features.count > 0) {
			self.inspectionsFeaturesArray = (NSArray *)featureSet.features;
			[self.inspectionDetailsTableView reloadData];
		}
		else {
			self.inspectionsFeaturesArray = nil;
			[self.inspectionDetailsTableView reloadData];
		}
	}
}	

- (void)queryTask:(AGSQueryTask *) queryTask operation:(NSOperation *) op didFailWithError:(NSError *) error {
	
    
    if ([self.loadingInspectionsIndicator isAnimating]) {
        
		[self.loadingInspectionsIndicator stopAnimating];
        
	}
    
    
    if ([[UIApplication sharedApplication] isIgnoringInteractionEvents]) {
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }
    
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ErrorTitle", @"ErrorTitle Item")	
                    message:NSLocalizedString(@"QueryTaskfailwitherror", @"QueryTaskfailwitherror Item")
                    delegate:nil cancelButtonTitle:NSLocalizedString(@"OKTitle", @"OKTitle Item")
                    otherButtonTitles:nil];
    
	[alert show];
	[alert release];

}

#pragma mark -


#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
   
	int returnCount = 0;
	
	if (tableView == self.violationDetailsTableView) {

		returnCount =  [self.violationDetailsDisplayFieldsArray count];
	}
	else if (tableView == self.inspectionDetailsTableView) {
		
		returnCount = [self.inspectionsFeaturesArray count];
	}
	
	return returnCount;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UITableViewCell *cell = nil;

	static NSString *ViolationCellIdentifier = @"AddressCell";
	static NSString *InspectionCellIdentifier = @"RatingCell";

	
	if (tableView == self.violationDetailsTableView) {
		cell = [tableView dequeueReusableCellWithIdentifier:ViolationCellIdentifier];
		
		if (cell == nil) {
			
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:ViolationCellIdentifier] autorelease];
			[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
			
			UILabel * propertyAttributeLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
			propertyAttributeLabel.backgroundColor = [UIColor clearColor];
			propertyAttributeLabel.opaque = NO;
			propertyAttributeLabel.textColor = [UIColor blackColor];
			propertyAttributeLabel.font = [UIFont boldSystemFontOfSize:14];
			propertyAttributeLabel.numberOfLines = 2;
			propertyAttributeLabel.frame = CGRectMake(LEFT_MARGIN,TOP_MARGIN, cell.frame.size.width/1.5, TOP_MARGIN * 2);
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
				if ([[self.selectedViolationGraphic attributeForKey:[tempArray objectAtIndex:0]] isKindOfClass:[NSNull class]]||
					[self.selectedViolationGraphic attributeForKey:[tempArray objectAtIndex:0]] == nil ||
					[[NSString stringWithFormat:@"%@", [self.selectedViolationGraphic attributeForKey:[tempArray objectAtIndex:0]]] isEqualToString:@""])  {
					propertyValue = NSLocalizedString(@"NoData", @"NoData Item");
				}
				else {
					propertyValue = [NSString stringWithFormat:@"%@", [self.selectedViolationGraphic attributeForKey:[tempArray objectAtIndex:0]]];
				}

			}
			else if ([tempArray count] > 1)
			{
				// Check Null field
				if ([[self.selectedViolationGraphic attributeForKey:[tempArray objectAtIndex:0]] isKindOfClass:[NSNull class]] ||
					[self.selectedViolationGraphic attributeForKey:[tempArray objectAtIndex:0]] == nil ||
					[[NSString stringWithFormat:@"%@", [self.selectedViolationGraphic attributeForKey:[tempArray objectAtIndex:0]]] isEqualToString:@""])  {
					propertyValue = NSLocalizedString(@"NoData", @"NoData Item");
				}
				else {
					
					NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[self.selectedViolationGraphic attributeForKey:[tempArray objectAtIndex:0]] doubleValue]/1000];
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
			tempPropertyValueLabel.frame = CGRectMake(tempPropertyAttributeLabel.frame.origin.x , tempPropertyAttributeLabel.frame.size.height + (TOP_MARGIN) , (cell.frame.size.width - 30), MAX(size.height,35.0)) ;
			tempPropertyValueLabel.center = CGPointMake(tempPropertyValueLabel.frame.origin.x  + (tempPropertyValueLabel.frame.size.width /2),tempPropertyAttributeLabel.frame.size.height + (TOP_MARGIN) + (tempPropertyValueLabel.frame.size.height/2));
		
			tempPropertyValueLabel.text = propertyValue ;
		}
		
	}
	else if (tableView == self.inspectionDetailsTableView) {

		cell = [tableView dequeueReusableCellWithIdentifier:InspectionCellIdentifier];
		
		
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:InspectionCellIdentifier] autorelease];
			[cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
			
			UILabel *propertyValueLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
			propertyValueLabel.backgroundColor = [UIColor clearColor];
			propertyValueLabel.opaque = NO;
			propertyValueLabel.textColor = [UIColor blackColor];
			propertyValueLabel.font = [UIFont boldSystemFontOfSize:14];
			propertyValueLabel.numberOfLines = 2;
			propertyValueLabel.frame = CGRectMake(cell.frame.origin.x + 10.0, 0.0, cell.frame.size.width/1.1, cell.frame.size.height - 4.0);
			propertyValueLabel.center = CGPointMake(propertyValueLabel.frame.origin.x + propertyValueLabel.frame.size.width/2 , cell.frame.size.height/2);
			[propertyValueLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
			propertyValueLabel.textAlignment = UITextAlignmentLeft;
			propertyValueLabel.tag = 1;
			[cell.contentView addSubview:propertyValueLabel];
			
		}
		
		UILabel *tempPropertyValueLabel = (UILabel *)[cell.contentView viewWithTag:1];
		
		if ([self.inspectionsFeaturesArray count] > 0)
		{
			AGSGraphic *currentInspectionGraphic = [self.inspectionsFeaturesArray objectAtIndex:indexPath.row];			
			
			// Check Null field
			
			if ([[currentInspectionGraphic   attributeForKey:@"NOTES"] isKindOfClass:[NSNull class]] ||
				[currentInspectionGraphic   attributeForKey:@"NOTES"] == nil ||
				[[NSString stringWithFormat:@"%@", [currentInspectionGraphic   attributeForKey:@"NOTES"]]
                 isEqualToString:@""])
			{
				tempPropertyValueLabel.text = NSLocalizedString(@"NoData", @"NoData Item");
			}
			else {
				
				tempPropertyValueLabel.text = [currentInspectionGraphic   attributeForKey:@"NOTES"];
			}
			
			if ([[currentInspectionGraphic   attributeForKey:@"OBJECTID"] integerValue] == [[self.inspectionGraphicNew   attributeForKey:@"OBJECTID"] integerValue]) {
				[self.inspectionDetailsTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
				self.inspectionGraphicNew = nil;
			}
			
		}
		
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
		
	}

	return cell;

}

#pragma mark -
#pragma mark Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	float height = 0;
	if (tableView == self.violationDetailsTableView) {
		switch ([indexPath section]) {
			case 0:
				if ([[self.selectedViolationGraphic.allAttributes allKeys] count] > 0)
				{
					NSArray *tempArray = [[NSString stringWithFormat:@"%@", [self.violationDetailsDisplayFieldsArray objectAtIndex:indexPath.row]] componentsSeparatedByString:@"|"];

					NSString *propertyValue = @"";
					
					if ([tempArray count] == 1) {
						// Check Null field
						
						if ([[self.selectedViolationGraphic attributeForKey:[tempArray objectAtIndex:0]] isKindOfClass:[NSNull class]] ||
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
	}
	else if (tableView == self.inspectionDetailsTableView) {
		height = 44 ;
	}
	return height;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	int row = [indexPath row];
	if (tableView == self.inspectionDetailsTableView) {
		[self showInspectionDetailsView:row];			
	}
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	int row = [indexPath row];
	if (tableView == self.inspectionDetailsTableView) {
		[self showInspectionDetailsView:row];			
	}
}


#pragma mark -
#pragma mark Actions

-(void) showInspectionDetailsView :(int) tappedRow {
	
	if ([self.inspectionsFieldAliasDictionary count] > 0) {
		[self showInspectionDetailsViewDelayed:[NSNumber numberWithInt:tappedRow]];
	}
	else {
		[self performSelector:@selector(showInspectionDetailsViewDelayed:) withObject:[NSNumber numberWithInt:tappedRow] afterDelay:2.0];
	}
}

-(void) showInspectionDetailsViewDelayed:(NSNumber *)tappedRow {
	
	if(self.objCodeViolationInspectionDetailsVC == nil)
	{
		self.objCodeViolationInspectionDetailsVC = [[CodeViolationInspectionDetailsVC alloc] initWithNibName:@"CodeViolationInspectionDetailsVC" bundle:nil];
	}
	
	
	AGSGraphic *tempInspectionGraphic = [self.inspectionsFeaturesArray objectAtIndex:[tappedRow intValue]];
	
	self.objCodeViolationInspectionDetailsVC.selectedInspectionGraphic = tempInspectionGraphic;
	
	[((CodeViolationRootVC *)((CodeViolationAppDelegate *)[UIApplication sharedApplication].delegate).objCodeViolationRootVC).navigationController pushViewController:self.objCodeViolationInspectionDetailsVC animated:YES];
	
	self.objCodeViolationInspectionDetailsVC.selectedViolationGraphic = self.selectedViolationGraphic;
	
	if ([[self.objCodeViolationInspectionDetailsVC.selectedViolationGraphic   attributeForKey:@"STATUS"] isEqualToString:@"Open"]) {
		
		self.objCodeViolationInspectionDetailsVC.editInspectionButton.enabled = YES;
	}
	else if ([[self.objCodeViolationInspectionDetailsVC.selectedViolationGraphic   attributeForKey:@"STATUS"] isEqualToString:@"Closed"]) {
		
		self.objCodeViolationInspectionDetailsVC.editInspectionButton.enabled = NO;
	}
	
	// Violation details display fields
	
	self.objCodeViolationInspectionDetailsVC.violationDetailsDisplayFieldsArray = self.violationDetailsDisplayFieldsArray;
	self.objCodeViolationInspectionDetailsVC.violationsFieldAliasDictionary = self.violationsFieldAliasDictionary;
	
	// Inspection details display fields
	
	self.objCodeViolationInspectionDetailsVC.inspectionDetailsDisplayFieldsArray = self.inspectionDetailsDisplayFieldsArray;
	self.objCodeViolationInspectionDetailsVC.inspectionsFieldAliasDictionary = self.inspectionsFieldAliasDictionary;
	
	self.objCodeViolationInspectionDetailsVC.actionDomainValues = self.actionDomainValues;
	self.objCodeViolationInspectionDetailsVC.inspectionStatusDomainValues = self.inspectionStatusDomainValues;
	
	// Violations and Inspections table views
	
	[self.objCodeViolationInspectionDetailsVC.violationDetailsTableView reloadData];
	[self.objCodeViolationInspectionDetailsVC.inspectionDetailsTableView reloadData];
	
	[self.objCodeViolationInspectionDetailsVC.violationDetailsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
	[self.objCodeViolationInspectionDetailsVC.inspectionDetailsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
	
}

-(void)getInspectionFieldsAndDomainValues {
	   
    
           
	// Get Display Field Alias
	
	self.inspectionDetailsDisplayFieldsArray = [CodeViolationConfigSettings inspectionDetailsDisplayFields];
    
	for (int i=0; i<self.inspectionsFeatureLayer.fields.count; i++) {
		
		AGSField *inspectionField = [self.inspectionsFeatureLayer.fields objectAtIndex:i];
		
		// Field Alias Dictionary
		
		[self.inspectionsFieldAliasDictionary setValue:inspectionField.alias forKey:inspectionField.name];
		
		if ([inspectionField.name isEqualToString:@"ACTION"])
		{
			
			AGSField *action = (AGSField *)[self.inspectionsFeatureLayer.fields objectAtIndex:i];
			AGSCodedValueDomain *codedDomainValues = (AGSCodedValueDomain *)action.domain;
			
			for (int count = 0; count < [codedDomainValues.codedValues count]; count ++)
			{
				AGSCodedValue *codedValue = (AGSCodedValue *) [codedDomainValues.codedValues objectAtIndex:count] ;
				[self.actionDomainValues addObject:codedValue.name];
			}
			
		}
		else if([inspectionField.name isEqualToString:@"INSSTATUS"])
		{
			AGSField *inspectionStatus = (AGSField *)[self.inspectionsFeatureLayer.fields objectAtIndex:i];
			AGSCodedValueDomain *codedDomainValues = (AGSCodedValueDomain *)inspectionStatus.domain;
			
			for (int count = 0; count < [codedDomainValues.codedValues count]; count ++)
			{
				AGSCodedValue *codedValue = (AGSCodedValue *) [codedDomainValues.codedValues objectAtIndex:count] ;
				[self.inspectionStatusDomainValues addObject:codedValue.name];
			}
		}
	}
	
 
	[self.objCodeViolationAddInspectionVC.actionPicker reloadAllComponents];
	
	[self.inspectionDetailsTableView reloadData];
    
    if (([self.actionDomainValues count]>0) ||([self.inspectionStatusDomainValues count]>0)) {
        
        self.addInspectionButton.enabled = YES;
        
        if ([self.loadingInspectionsIndicatorForButton isAnimating]) {
            
            [self.loadingInspectionsIndicatorForButton stopAnimating];
        }
        
        
    }
    

}

-(IBAction)editViolation:(id)sender {

	if (self.objCodeViolationAddViolationVC == nil) {
				
		self.objCodeViolationAddViolationVC = [[CodeViolationAddViolationVC alloc] initWithNibName:@"CodeViolationAddViolationVC" bundle:nil];
	}
	
	[((CodeViolationRootVC *)(((CodeViolationAppDelegate *)([UIApplication sharedApplication].delegate)).objCodeViolationRootVC)).navigationController pushViewController:self.objCodeViolationAddViolationVC animated:YES];

	self.objCodeViolationAddViolationVC.isEditingViolation = YES;
	

	// Object Id
	
	self.objCodeViolationAddViolationVC.violationObjectId = [[self.selectedViolationGraphic   attributeForKey:@"OBJECTID"] integerValue];
	
	// Violation Id
	
	if ([[self.selectedViolationGraphic   attributeForKey:@"VIOLATIONID"] isKindOfClass:[NSNull class]] ||
		[self.selectedViolationGraphic   attributeForKey:@"VIOLATIONID"] == nil ||
		[[NSString stringWithFormat:@"%@", [self.selectedViolationGraphic   attributeForKey:@"VIOLATIONID"]] isEqualToString:@""]) 
	{
		self.objCodeViolationAddViolationVC.violationID = [NSString stringWithFormat:@"%i", self.objCodeViolationAddViolationVC.violationObjectId];
		self.objCodeViolationAddViolationVC.violationIDField.text = self.objCodeViolationAddViolationVC.violationID;
	}
	else {
		self.objCodeViolationAddViolationVC.violationID = [NSString stringWithFormat:@"%@", [self.selectedViolationGraphic   attributeForKey:@"VIOLATIONID"]];		
		self.objCodeViolationAddViolationVC.violationIDField.text = self.objCodeViolationAddViolationVC.violationID;
	}

	// Full Address
	
	if ([[self.selectedViolationGraphic   attributeForKey:@"FULLADDR"] isKindOfClass:[NSNull class]] ||
		[self.selectedViolationGraphic   attributeForKey:@"FULLADDR"] == nil ||
		[[NSString stringWithFormat:@"%@", [self.selectedViolationGraphic   attributeForKey:@"FULLADDR"]] isEqualToString:@""]) 
	{
		self.objCodeViolationAddViolationVC.fullAddress.text = @"";
	}
	else {
		
		self.objCodeViolationAddViolationVC.fullAddress.text = [self.selectedViolationGraphic   attributeForKey:@"FULLADDR"];
	}

	// Location Description
	
	if ([[self.selectedViolationGraphic   attributeForKey:@"LOCDESC"]   isKindOfClass:[NSNull class]] ||
		[self.selectedViolationGraphic   attributeForKey:@"LOCDESC"] == nil ||
		[[NSString stringWithFormat:@"%@", [self.selectedViolationGraphic   attributeForKey:@"LOCDESC"]] isEqualToString:@""]) 
	{
		self.objCodeViolationAddViolationVC.locationDescription.text = @"";
	}
	else {
		
		self.objCodeViolationAddViolationVC.locationDescription.text = [self.selectedViolationGraphic   attributeForKey:@"LOCDESC"];
	}
	
	// Violation Type
	
	NSArray *violationTypeDomainValues = ((CodeViolationMapVC *)((CodeViolationAppDelegate *)[[UIApplication sharedApplication] delegate]).objCodeViolationMapVC).violationsFeatureLayerDomainValues;
	
	self.objCodeViolationAddViolationVC.violationTypeDomainValues = ((CodeViolationMapVC *)((CodeViolationAppDelegate *)[[UIApplication sharedApplication] delegate]).objCodeViolationMapVC).violationsFeatureLayerDomainValues;
	
	[self.objCodeViolationAddViolationVC.violationTypePicker reloadAllComponents];
	
	if ([[self.selectedViolationGraphic   attributeForKey:@"VIOLATETYPE"]   isKindOfClass:[NSNull class]] ||
		[self.selectedViolationGraphic   attributeForKey:@"VIOLATETYPE"] == nil ||
		[[NSString stringWithFormat:@"%@", [self.selectedViolationGraphic   attributeForKey:@"VIOLATETYPE"]] isEqualToString:@""]) 
	{
		[self.objCodeViolationAddViolationVC.violationTypePicker selectRow:0 inComponent:0 animated:NO];
		self.objCodeViolationAddViolationVC.submittedViolationTypeLabel.text = [violationTypeDomainValues objectAtIndex:0];
	}
	else {
		
		for (int i=0; i<violationTypeDomainValues.count; i++) {
			
			if ([[self.selectedViolationGraphic   attributeForKey:@"VIOLATETYPE"] isEqualToString:[violationTypeDomainValues objectAtIndex:i]]) {
				[self.objCodeViolationAddViolationVC.violationTypePicker selectRow:i inComponent:0 animated:NO];
				self.objCodeViolationAddViolationVC.submittedViolationTypeLabel.text = [violationTypeDomainValues objectAtIndex:i];
				break;
			}
		}
	}

	// Violation Description
	
	if ([[self.selectedViolationGraphic   attributeForKey:@"VIOLATEDESC"]   isKindOfClass:[NSNull class]] ||
		[self.selectedViolationGraphic   attributeForKey:@"VIOLATEDESC"] == nil ||
		[[NSString stringWithFormat:@"%@", [self.selectedViolationGraphic   attributeForKey:@"VIOLATEDESC"]] isEqualToString:@""]) 
	{
		self.objCodeViolationAddViolationVC.violationDescription.text = @"";
	}
	else {
		
		self.objCodeViolationAddViolationVC.violationDescription.text = [self.selectedViolationGraphic   attributeForKey:@"VIOLATEDESC"];
	}
	
	// Municipal Code
	
	if ([[self.selectedViolationGraphic   attributeForKey:@"CODE"]   isKindOfClass:[NSNull class]] ||
		[self.selectedViolationGraphic   attributeForKey:@"CODE"] == nil ||
		[[NSString stringWithFormat:@"%@", [self.selectedViolationGraphic   attributeForKey:@"CODE"]] isEqualToString:@""]) {
		self.objCodeViolationAddViolationVC.municipalCode.text = @"";
	}
	else {
		
		self.objCodeViolationAddViolationVC.municipalCode.text = [self.selectedViolationGraphic   attributeForKey:@"CODE"];
	}

	// Visable segmented control
	
	if ([[self.selectedViolationGraphic   attributeForKey:@"VISABLE"]   isKindOfClass:[NSNull class]] ||
		[self.selectedViolationGraphic   attributeForKey:@"VISABLE"] == nil ||
		[[NSString stringWithFormat:@"%@", [self.selectedViolationGraphic   attributeForKey:@"VISABLE"]] isEqualToString:@""]) {
		[self.objCodeViolationAddViolationVC.visiableFromPublicSegmentedControl setSelectedSegmentIndex:0];
	}
	else {
		
		if ([[self.selectedViolationGraphic   attributeForKey:@"VISABLE"] isEqualToString:@"Yes"]) {
			[self.objCodeViolationAddViolationVC.visiableFromPublicSegmentedControl setSelectedSegmentIndex:0];
		}
		else {
			[self.objCodeViolationAddViolationVC.visiableFromPublicSegmentedControl setSelectedSegmentIndex:1];
		}
	}
	
	
	// inspection Status segmented control
	
	if ([[self.selectedViolationGraphic   attributeForKey:@"STATUS"]   isKindOfClass:[NSNull class]] ||
		[self.selectedViolationGraphic   attributeForKey:@"STATUS"] == nil ||
		[[NSString stringWithFormat:@"%@", [self.selectedViolationGraphic   attributeForKey:@"STATUS"]] isEqualToString:@""]) {
		[self.objCodeViolationAddViolationVC.violationStatusSegmentedControl setSelectedSegmentIndex:0];
	}
	else {
		
		if ([[self.selectedViolationGraphic   attributeForKey:@"STATUS"] isEqualToString:@"Open"]) {
			[self.objCodeViolationAddViolationVC.violationStatusSegmentedControl setSelectedSegmentIndex:0];
		}
		else {
			[self.objCodeViolationAddViolationVC.violationStatusSegmentedControl setSelectedSegmentIndex:1];
		}
	}
	
	
	// Submitted Date
	self.objCodeViolationAddViolationVC.actionsheetSubmitDatePicker.maximumDate = [NSDate date];
	if ([[self.selectedViolationGraphic   attributeForKey:@"SUBMITDT"]   isKindOfClass:[NSNull class]] ||
		[self.selectedViolationGraphic   attributeForKey:@"SUBMITDT"] == nil ||
		[[NSString stringWithFormat:@"%@", [self.selectedViolationGraphic   attributeForKey:@"SUBMITDT"]] isEqualToString:@""]) 
	{
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];	
		
		[dateFormatter setDateFormat:@"MMM dd yyyy"];
		self.objCodeViolationAddViolationVC.submittedDateLabel.text = [dateFormatter stringFromDate:[NSDate date]];

		self.objCodeViolationAddViolationVC.actionsheetSubmitDatePicker.date = [NSDate date];
		[dateFormatter release];
	}
	else {
		
		NSDate *submittedDate = [NSDate dateWithTimeIntervalSince1970:[[self.selectedViolationGraphic   attributeForKey:@"SUBMITDT"] doubleValue]/1000];
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"MMM dd yyyy"];

		self.objCodeViolationAddViolationVC.submittedDateLabel.text = [dateFormatter stringFromDate:submittedDate];
		[self.objCodeViolationAddViolationVC.actionsheetSubmitDatePicker setDate:submittedDate animated:NO];	
		
		[dateFormatter release];
	}

}

-(IBAction)addInspection:(id)sender {
	
	if(self.objCodeViolationAddInspectionVC == nil)
	{
		self.objCodeViolationAddInspectionVC = [[CodeViolationAddInspectionVC alloc] initWithNibName:@"CodeViolationAddInspectionVC" bundle:nil];
	}
	
	
	[((CodeViolationRootVC *)((CodeViolationAppDelegate *)[UIApplication sharedApplication].delegate).objCodeViolationRootVC).navigationController pushViewController:self.objCodeViolationAddInspectionVC animated:YES];
	
	self.objCodeViolationAddInspectionVC.addNewInspectionLabel.text = NSLocalizedString(@"AddNewInspection",@"AddNewInspection Item");
	
	NSDate *currentDate = [NSDate date];
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"MMM dd yyyy"];
	self.objCodeViolationAddInspectionVC.actionsheetSubmitDatePicker.maximumDate = [NSDate date];
	self.objCodeViolationAddInspectionVC.inspectionStartDateLabel.text = [dateFormatter stringFromDate:currentDate];
	
	self.objCodeViolationAddInspectionVC.submittedActionLabel.text = [self.actionDomainValues objectAtIndex:0];
	self.objCodeViolationAddInspectionVC.actionDomainValues = self.actionDomainValues;
	[self.objCodeViolationAddInspectionVC.actionPicker reloadAllComponents];
	[self.objCodeViolationAddInspectionVC.actionPicker selectRow:0 inComponent:0 animated:NO];
	
	self.objCodeViolationAddInspectionVC.isEditingInspection = NO;
	[self.objCodeViolationAddInspectionVC clearInspectionFields];
	
	self.objCodeViolationAddInspectionVC.selectedViolationGraphic = self.selectedViolationGraphic;
	self.objCodeViolationAddInspectionVC.violationDetailsDisplayFieldsArray = [CodeViolationConfigSettings violationDetailsDisplayFields];
	self.objCodeViolationAddInspectionVC.violationsFieldAliasDictionary = self.violationsFieldAliasDictionary;
		
	[self.objCodeViolationAddInspectionVC.violationDetailsTableView reloadData];

	self.objCodeViolationAddInspectionVC.selectedInspectionGraphic = nil;

	self.objCodeViolationAddInspectionVC.addAttachmentImageButton.hidden = NO;
	self.objCodeViolationAddInspectionVC.removeAttachmentImageButton.hidden = YES;
	self.objCodeViolationAddInspectionVC.inspectionAttachmentImageView.image = nil;
	[dateFormatter release];
}
										
-(void)searchBarButtonClicked {
	[((CodeViolationRootVC *)((CodeViolationAppDelegate *)[UIApplication sharedApplication].delegate).objCodeViolationRootVC).navigationController popToRootViewControllerAnimated:YES];
}

- (void) endActivityIndicatorDelayed {

}

#pragma mark -
#pragma mark Memory management

- (void)viewDidUnload {
	
	self.selectedViolationGraphic = nil;
	self.violationsFieldAliasDictionary = nil;
	self.inspectionsFieldAliasDictionary = nil;
	self.violationDetailsDisplayFieldsArray = nil;
	self.inspectionDetailsDisplayFieldsArray = nil;
	self.inspectionsFeaturesArray = nil;
	self.violationDetailsTableView = nil;
	self.inspectionDetailsTableView = nil;
	self.objCodeViolationAddViolationVC = nil;
	self.violationAndInspectionScrollView = nil;
	self.objCodeViolationAddInspectionVC = nil;
	self.objCodeViolationInspectionDetailsVC = nil;
	self.inspectionsFeatureLayer = nil;
	self.inspectionsQueryTask = nil;
	self.inspectionsQuery = nil;
	self.actionDomainValues = nil;
	self.inspectionStatusDomainValues = nil;
	self.editViolationButton = nil;
	self.addInspectionButton = nil;
	self.inspectionGraphicNew = nil;
	self.tableViewBackgroundImage = nil;
	
	[super viewDidUnload];
}


- (void)dealloc {
	
	[self.selectedViolationGraphic release];
	[self.violationsFieldAliasDictionary release];
	[self.inspectionsFieldAliasDictionary release];
	[self.violationDetailsDisplayFieldsArray release];
	[self.inspectionDetailsDisplayFieldsArray release];
	[self.inspectionsFeaturesArray release];
	[self.violationDetailsTableView release];
	[self.inspectionDetailsTableView release];
	[self.objCodeViolationAddViolationVC release];
	[self.violationAndInspectionScrollView release];
	[self.objCodeViolationAddInspectionVC release];
	[self.objCodeViolationInspectionDetailsVC release];
	[self.inspectionsFeatureLayer release];
	[self.inspectionsQueryTask release];
	[self.inspectionsQuery release];
	[self.actionDomainValues release];
	[self.inspectionStatusDomainValues release];
	[self.editViolationButton release];
	[self.addInspectionButton release];
	[self.inspectionGraphicNew release];
	[self.tableViewBackgroundImage release];
	
    [super dealloc];
}

#pragma mark -

@end

