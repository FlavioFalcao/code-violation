//
//  CodeViolationInspectionDetailsVC.m
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

#import "CodeViolationInspectionDetailsVC.h"
#import "CodeViolationRootVC.h"

@implementation CodeViolationInspectionDetailsVC
@synthesize selectedViolationGraphic, selectedInspectionGraphic, currentInspectionGraphic, violationDetailsTableView, 
inspectionDetailsTableView, violationsFieldAliasDictionary, violationDetailsDisplayFieldsArray, 
inspectionsFieldAliasDictionary, inspectionDetailsDisplayFieldsArray, violationAndInspectionScrollView, 
objCodeViolationAddInspectionVC, editInspectionButton, inspectionAttachmentImageView, inspectionsFeatureLayer, 
inspectionObjectId, actionDomainValues, inspectionStatusDomainValues, loadingImageActivityIndicator,imageIndex,noImageFound,fetchedImage;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	self.title = [CodeViolationConfigSettings panelTitle];
	self.inspectionsFeatureLayer = [AGSFeatureLayer featureServiceLayerWithURL:[NSURL URLWithString:[CodeViolationConfigSettings inspectionFeatureLayerUrl]] 
																		  mode:AGSFeatureLayerModeSnapshot];
	self.inspectionAttachmentImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loading.png"]];
	self.loadingImageActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	self.loadingImageActivityIndicator.hidesWhenStopped = YES;
	
	self.inspectionsFeatureLayer.editingDelegate = self;
	
	self.violationDetailsTableView.backgroundView = nil;
	self.inspectionDetailsTableView.backgroundView = nil;

	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
	backButton.title = NSLocalizedString(@"Back", @"Back Item");
	self.navigationItem.backBarButtonItem = backButton;
	
	UIBarButtonItem *searchBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchBarButtonClicked)];
	self.navigationItem.rightBarButtonItem = searchBarButton;
	
	self.inspectionAttachmentImageView.layer.cornerRadius = 5.0;
	[super viewDidLoad];
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

-(void)viewWillAppear:(BOOL)animated {
      	
	if (!self.objCodeViolationAddInspectionVC.isEditingInspection && self.objCodeViolationAddInspectionVC.didUpdateInspection) {
		
		[((CodeViolationRootVC *)((CodeViolationAppDelegate *)[UIApplication sharedApplication].delegate).objCodeViolationRootVC).navigationController popViewControllerAnimated:YES];
		
		self.objCodeViolationAddInspectionVC.isEditingInspection = NO;
		self.objCodeViolationAddInspectionVC.didUpdateInspection = NO;
	}
	else {
		
		if([self.currentInspectionGraphic attributeForKey:@"OBJECTID"] != [self.selectedInspectionGraphic attributeForKey:@"OBJECTID"] || self.objCodeViolationAddInspectionVC.didupdateAttachment)
		{
			self.currentInspectionGraphic = self.selectedInspectionGraphic;
			[self.inspectionAttachmentImageView setImage:[UIImage imageNamed:@"loading.png"]];
			[self.loadingImageActivityIndicator startAnimating];
			self.inspectionObjectId = [[self.selectedInspectionGraphic attributeForKey:@"OBJECTID"] integerValue];
			[self.inspectionsFeatureLayer queryAttachmentInfosForObjectId:self.inspectionObjectId];
			if (self.objCodeViolationAddInspectionVC.didupdateAttachment) {
				self.objCodeViolationAddInspectionVC.didupdateAttachment = NO;
			}
		}
	}
	
	self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
	[super viewWillAppear:YES];
}

#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	
	int returnCount;
	
	if (tableView == self.violationDetailsTableView) {
		
		returnCount = [self.violationDetailsDisplayFieldsArray count];
		
	}
	else {
		
		returnCount = [self.inspectionDetailsDisplayFieldsArray count];
	}

	
	return returnCount;
	
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	UITableViewCell *cell = nil;
	
	static NSString *ViolationCellIdentifier = @"AddressCell";
	static NSString *InspectionPhotoCellIdentifier = @"InspectionPhotoCell";
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
			//propertyAttributeLabel.numberOfLines = 2;
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
				if ([[self.selectedViolationGraphic attributeForKey:[tempArray objectAtIndex:0]] isKindOfClass:[NSNull class]] ||
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
					NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[self.selectedViolationGraphic
                                                attributeForKey:[tempArray objectAtIndex:0]] doubleValue]/1000];
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
			tempPropertyValueLabel.center = CGPointMake(tempPropertyValueLabel.frame.origin.x  + (tempPropertyValueLabel.frame.size.width /2),tempPropertyAttributeLabel.frame.size.height + (TOP_MARGIN ) + (tempPropertyValueLabel.frame.size.height/2));
			
			tempPropertyValueLabel.text = propertyValue ;
		}
		
	}
	else if(tableView == self.inspectionDetailsTableView)
	{
		NSArray *tempArray = nil;
		if ([[self.selectedInspectionGraphic.allAttributes allKeys] count] > 0)
		{
			tempArray = [[NSString stringWithFormat:@"%@", [self.inspectionDetailsDisplayFieldsArray objectAtIndex:indexPath.row]] componentsSeparatedByString:@"|"];
		}	
		
		
		NSString * isImageString = @""; 
		if ([tempArray count] > 1){
			isImageString = [tempArray objectAtIndex:1] ;
		}
		
		if ([tempArray count] > 1 && [isImageString isEqualToString:@"image"]) {
			self.imageIndex = [indexPath row];
			
			cell = [tableView dequeueReusableCellWithIdentifier:InspectionPhotoCellIdentifier];
			
			if (cell == nil) {
				
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:InspectionPhotoCellIdentifier] autorelease];
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
				propertyAttributeLabel.text = @"Photo ";
				[cell.contentView addSubview:propertyAttributeLabel];
				
				
				UIImageView *inspectionImage = [[[UIImageView alloc] initWithFrame:CGRectMake(cell.frame.size.width / 2, TOP_MARGIN, 120, 120)] autorelease];
				inspectionImage.center = CGPointMake(cell.frame.size.width / 2 + inspectionImage.frame.size.width/2 , TOP_MARGIN + inspectionImage.frame.size.height/2 );
				inspectionImage.layer.cornerRadius = 5.0;
				inspectionImage.tag = 2;
				[inspectionImage setBackgroundColor:[UIColor darkGrayColor]];
				[cell.contentView addSubview:inspectionImage];
				
			}
			
			if ([indexPath row] == self.imageIndex) {
				UIImageView *tempImageView = (UIImageView *) [cell.contentView viewWithTag:2];
				[tempImageView setImage:self.inspectionAttachmentImageView.image];
			}
			
		}
		else {
			
			cell = [tableView dequeueReusableCellWithIdentifier:InspectionCellIdentifier];
			
			if (cell == nil) {
				
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:InspectionCellIdentifier] autorelease];
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
			
			
			if ([[self.selectedInspectionGraphic.allAttributes allKeys] count] > 0)
			{
				
				NSArray *tempArray = [[NSString stringWithFormat:@"%@", [self.inspectionDetailsDisplayFieldsArray objectAtIndex:indexPath.row]] componentsSeparatedByString:@"|"];
				NSString *propertyValue = @"";
				tempPropertyAttributeLabel.text = [NSString stringWithFormat:@"%@", [self.inspectionsFieldAliasDictionary valueForKey:[tempArray objectAtIndex:0]]];
				
				if ([tempArray count] == 1) {
					
					
					// Check Null field
					
					if ([[self.selectedInspectionGraphic attributeForKey:[tempArray objectAtIndex:0]]   isKindOfClass:[NSNull class]] ||
						[self.selectedInspectionGraphic attributeForKey:[tempArray objectAtIndex:0]] == nil ||
						[[NSString stringWithFormat:@"%@", [self.selectedInspectionGraphic attributeForKey:[tempArray objectAtIndex:0]]] isEqualToString:@""]) {
						propertyValue = NSLocalizedString(@"NoData", @"NoData Item");
					}
					else {
						propertyValue = [NSString stringWithFormat:@"%@", [self.selectedInspectionGraphic attributeForKey:[tempArray objectAtIndex:0]]];
					}
					
				}
				else if ([tempArray count] > 1)
				{
					// Check Null field
					
					if ([[self.selectedInspectionGraphic attributeForKey:[tempArray objectAtIndex:0]] isKindOfClass:[NSNull class]] ||
						[self.selectedInspectionGraphic attributeForKey:[tempArray objectAtIndex:0]] == nil ||
						[[NSString stringWithFormat:@"%@", [self.selectedInspectionGraphic attributeForKey:[tempArray objectAtIndex:0]]] isEqualToString:@""]) {
						propertyValue = NSLocalizedString(@"NoData", @"NoData Item");
					}
					else {
						
						NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[self.selectedInspectionGraphic attributeForKey:[tempArray objectAtIndex:0]] doubleValue]/1000];
						
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
		
	}
	return cell;
	
}


#pragma mark -
#pragma mark UITableViewDelegate

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
						
						if ([[self.selectedViolationGraphic attributeForKey:[tempArray objectAtIndex:0]]
                             isKindOfClass:[NSNull class]] ||
							[self.selectedViolationGraphic attributeForKey:[tempArray objectAtIndex:0]] == nil ||
							[[NSString stringWithFormat:@"%@", [self.selectedViolationGraphic attributeForKey:[tempArray objectAtIndex:0]]] isEqualToString:@""]) {
							propertyValue = NSLocalizedString(@"NoData", @"NoData Item");
						}
						else {
							propertyValue = [NSString stringWithFormat:@"%@", [self.selectedViolationGraphic attributeForKey:[tempArray objectAtIndex:0]]];
						}
						
					}
					else if ([tempArray count] > 1)
					{
						// Check Null field
						
						if ([[self.selectedViolationGraphic attributeForKey:[tempArray objectAtIndex:0]]  isKindOfClass:[NSNull class]] ||
							[self.selectedViolationGraphic attributeForKey:[tempArray objectAtIndex:0]] == nil ||
							[[NSString stringWithFormat:@"%@", [self.selectedViolationGraphic attributeForKey:[tempArray objectAtIndex:0]]] isEqualToString:@""]) {
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
					
					CGSize constraint = CGSizeMake(self.view.frame.size.width, 20000.0f);
					CGSize size = [propertyValue sizeWithFont:[UIFont boldSystemFontOfSize:13.0] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
					height =  MAX(TOP_MARGIN + BOTTOM_MARGIN/2 + size.height + 35 ,35.0)  ;
				}
				
				break;
		}
	}
	else if (tableView == self.inspectionDetailsTableView) {
	
		NSArray *tempArray = nil;
		if ([[self.selectedInspectionGraphic.allAttributes allKeys] count] > 0)
		{
			tempArray = [[NSString stringWithFormat:@"%@", [self.inspectionDetailsDisplayFieldsArray objectAtIndex:indexPath.row]] componentsSeparatedByString:@"|"];
		}	
		
		switch ([indexPath section]) {
			case 0:
			{
				NSString *str = @"";
				if([tempArray count] > 1){
					str = [tempArray objectAtIndex:1];
				}
				if ([str isEqualToString:@"image"]) {
					height = 140.0;
				}
				else {
					if ([[self.selectedInspectionGraphic.allAttributes allKeys] count] > 0)
					{
						NSArray *tempArray = [[NSString stringWithFormat:@"%@", [self.inspectionDetailsDisplayFieldsArray objectAtIndex:indexPath.row]] componentsSeparatedByString:@"|"];
						
						NSString *propertyValue = @"";
						
						if ([tempArray count] == 1) {
													
							// Check Null field
							
							if ([[self.selectedInspectionGraphic attributeForKey:[tempArray objectAtIndex:0]]   isKindOfClass:[NSNull class]] ||
								[self.selectedInspectionGraphic attributeForKey:[tempArray objectAtIndex:0]] == nil ||
								[[NSString stringWithFormat:@"%@", [self.selectedInspectionGraphic attributeForKey:[tempArray objectAtIndex:0]]] isEqualToString:@""]) {
								propertyValue = NSLocalizedString(@"NoData", @"NoData Item");
							}
							else {
								propertyValue = [NSString stringWithFormat:@"%@", [self.selectedInspectionGraphic attributeForKey:[tempArray objectAtIndex:0]]];
							}
							
						}
						else if ([tempArray count] > 1)
						{
							// Check Null field
							
							if ([[self.selectedInspectionGraphic attributeForKey:[tempArray objectAtIndex:0]]   isKindOfClass:[NSNull class]] ||
								[self.selectedInspectionGraphic attributeForKey:[tempArray objectAtIndex:0]] == nil ||
								[[NSString stringWithFormat:@"%@", [self.selectedInspectionGraphic attributeForKey:[tempArray objectAtIndex:0]]] isEqualToString:@""]) {
								propertyValue = NSLocalizedString(@"NoData", @"NoData Item");
							}
							else {
								
								NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[self.selectedInspectionGraphic attributeForKey:[tempArray objectAtIndex:0]] doubleValue]/1000];
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
					
				}
				
				break;
		}
	}
	}
	return height;
}


#pragma mark AGSFeatureLayerEditingDelegate Methods

- (void)featureLayer:(AGSFeatureLayer *) featureLayer operation:(NSOperation *) op 
didQueryAttachmentInfosWithResults:(NSArray *) attachmentInfos {
	
	if (attachmentInfos.count > 0) {
		[self.inspectionsFeatureLayer retrieveAttachmentForObjectId:self.inspectionObjectId attachmentId:((AGSAttachmentInfo *)[attachmentInfos objectAtIndex:0]).attachmentId];
	}
	else if(attachmentInfos.count > 0){
		self.inspectionAttachmentImageView.image = nil;
		self.fetchedImage = nil;
		[self.loadingImageActivityIndicator stopAnimating];
		if (self.objCodeViolationAddInspectionVC != nil) {
			self.objCodeViolationAddInspectionVC.inspectionAttachmentImageView.image = nil;
			([self.objCodeViolationAddInspectionVC.loadingImageActivityIndicator isAnimating] == YES ? [self.objCodeViolationAddInspectionVC.loadingImageActivityIndicator stopAnimating] :[self.objCodeViolationAddInspectionVC.loadingImageActivityIndicator stopAnimating]);
			self.objCodeViolationAddInspectionVC.addAttachmentImageButton.hidden = YES;
			self.objCodeViolationAddInspectionVC.removeAttachmentImageButton.hidden = NO;
		}
	}
	else {
		self.inspectionAttachmentImageView.image = [UIImage imageNamed:@"noAttachment.png"];
		self.fetchedImage = nil;
		self.noImageFound = YES;
		[self.loadingImageActivityIndicator stopAnimating];
		if (self.objCodeViolationAddInspectionVC != nil) {
			self.objCodeViolationAddInspectionVC.inspectionAttachmentImageView.image = nil;
			([self.objCodeViolationAddInspectionVC.loadingImageActivityIndicator isAnimating] == YES ? [self.objCodeViolationAddInspectionVC.loadingImageActivityIndicator stopAnimating] :[self.objCodeViolationAddInspectionVC.loadingImageActivityIndicator stopAnimating]);
			self.objCodeViolationAddInspectionVC.addAttachmentImageButton.hidden = NO;
			self.objCodeViolationAddInspectionVC.removeAttachmentImageButton.hidden = YES;
		}
		[self.inspectionDetailsTableView reloadData];
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
	
	[self.loadingImageActivityIndicator stopAnimating];
	
}

- (void)featureLayer:(AGSFeatureLayer *) featureLayer operation:(NSOperation *) op 
didRetrieveAttachmentWithData:(NSData *) attachmentData {
	
	[self.loadingImageActivityIndicator stopAnimating];
	[self.inspectionAttachmentImageView setImage:[UIImage imageWithData:attachmentData]];	
	self.fetchedImage = [UIImage imageWithData:attachmentData];
	[self.objCodeViolationAddInspectionVC.loadingImageActivityIndicator stopAnimating];
	[self.objCodeViolationAddInspectionVC.inspectionAttachmentImageView setImage:[UIImage imageWithData:attachmentData]];
	
	
	if (self.objCodeViolationAddInspectionVC != nil) {
		self.objCodeViolationAddInspectionVC.addAttachmentImageButton.hidden = YES;
		self.objCodeViolationAddInspectionVC.removeAttachmentImageButton.hidden = NO;
		[self.objCodeViolationAddInspectionVC.inspectionAttachmentImageView setImage:[UIImage imageWithData:attachmentData]];
	}
	[self.inspectionDetailsTableView reloadData];
}

- (void)featureLayer:(AGSFeatureLayer *) featureLayer operation:(NSOperation *) op 
didFailRetrieveAttachmentWithError:(NSError *) error {
	
	UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ErrorTitle", @"ErrorTitle Item") 
													 message:[error localizedDescription]  
													delegate:nil 
										   cancelButtonTitle:NSLocalizedString(@"OK", @"OKTitle Item")
										   otherButtonTitles:nil] ;
	[alert show];
	[alert release];
	
	[self.loadingImageActivityIndicator stopAnimating];
}

#pragma mark -


#pragma mark Actions

-(IBAction)editInspection:(id)sender {

	if(self.objCodeViolationAddInspectionVC == nil)
	{
		self.objCodeViolationAddInspectionVC = [[CodeViolationAddInspectionVC alloc] initWithNibName:@"CodeViolationAddInspectionVC" bundle:nil];
	}
	
	[((CodeViolationRootVC *)((CodeViolationAppDelegate *)[UIApplication sharedApplication].delegate).objCodeViolationRootVC).navigationController pushViewController:self.objCodeViolationAddInspectionVC animated:YES];
	
	self.objCodeViolationAddInspectionVC.isEditingInspection = YES;
	self.objCodeViolationAddInspectionVC.didUpdateInspection = NO;
	
	self.objCodeViolationAddInspectionVC.addNewInspectionLabel.text = NSLocalizedString(@"EditInspection" , @"EditInspection Item");
	
	self.objCodeViolationAddInspectionVC.selectedViolationGraphic = self.selectedViolationGraphic;
	self.objCodeViolationAddInspectionVC.violationDetailsDisplayFieldsArray = [CodeViolationConfigSettings violationDetailsDisplayFields];
	self.objCodeViolationAddInspectionVC.violationsFieldAliasDictionary = self.violationsFieldAliasDictionary;
	
	self.objCodeViolationAddInspectionVC.actionDomainValues = self.actionDomainValues;
	[self.objCodeViolationAddInspectionVC.actionPicker reloadAllComponents];
	
	self.objCodeViolationAddInspectionVC.inspectionStatusDomainValues = self.inspectionStatusDomainValues;
	
	[self.objCodeViolationAddInspectionVC.violationDetailsTableView reloadData];
	
	// selectedInspectionGraphic is only for editing
	
	self.objCodeViolationAddInspectionVC.selectedInspectionGraphic = self.selectedInspectionGraphic;
	
	
	// Object Id
	
	self.objCodeViolationAddInspectionVC.inspectionObjectId = [[self.selectedInspectionGraphic attributeForKey:@"OBJECTID"] integerValue];
	
	// Violation Id
	
	if ([[self.selectedInspectionGraphic attributeForKey:@"INSPECTID"] isKindOfClass:[NSNull class]] ||
		[self.selectedInspectionGraphic attributeForKey:@"INSPECTID"] == nil ||
		[[NSString stringWithFormat:@"%@", [self.selectedInspectionGraphic attributeForKey:@"INSPECTID"]] isEqualToString:@""])
	{
		self.objCodeViolationAddInspectionVC.inspectionId = [NSString stringWithFormat:@"%i", self.objCodeViolationAddInspectionVC.inspectionObjectId];
	}
	else {
		self.objCodeViolationAddInspectionVC.inspectionId = [NSString stringWithFormat:@"%@", [self.selectedInspectionGraphic attributeForKey:@"INSPECTID"]];
	}
	
	// Fill the controls with inspection fields
	// Set Image
	
	self.objCodeViolationAddInspectionVC.inspectionAttachmentImageData = UIImageJPEGRepresentation(self.fetchedImage, 0.1);
	if ([self.loadingImageActivityIndicator isAnimating]) {
		self.objCodeViolationAddInspectionVC.addAttachmentImageButton.hidden = YES;
		self.objCodeViolationAddInspectionVC.removeAttachmentImageButton.hidden = YES;
		[self.objCodeViolationAddInspectionVC.loadingImageActivityIndicator startAnimating];
	}
	
	if(self.objCodeViolationAddInspectionVC.inspectionAttachmentImageData != nil && !self.noImageFound)
	{		
		self.noImageFound = NO;
		[self.objCodeViolationAddInspectionVC.inspectionAttachmentImageView setImage:self.inspectionAttachmentImageView.image];
		self.objCodeViolationAddInspectionVC.addAttachmentImageButton.hidden = YES;
		self.objCodeViolationAddInspectionVC.removeAttachmentImageButton.hidden = NO;
	}
	else {
		self.objCodeViolationAddInspectionVC.inspectionAttachmentImageView.image = nil;
		self.objCodeViolationAddInspectionVC.addAttachmentImageButton.hidden = NO;
		self.objCodeViolationAddInspectionVC.removeAttachmentImageButton.hidden = YES;
		if (self.noImageFound) {
			self.noImageFound = NO;
		}
	}

	// Workorder Id
	
	if ([[self.selectedInspectionGraphic attributeForKey:@"WORKKEY"] isKindOfClass:[NSNull class]] ||
		[self.selectedInspectionGraphic attributeForKey:@"WORKKEY"] == nil ||
		[[NSString stringWithFormat:@"%@", [self.selectedInspectionGraphic attributeForKey:@"WORKKEY"]] isEqualToString:@""])
	{
		self.objCodeViolationAddInspectionVC.workorderId.text = @"";
	}
	else {
		
		self.objCodeViolationAddInspectionVC.workorderId.text = [self.selectedInspectionGraphic attributeForKey:@"WORKKEY"];
	}
	
	// Start Date
	
	if ([[self.selectedInspectionGraphic attributeForKey:@"INSSTART"] isKindOfClass:[NSNull class]] ||
		[self.selectedInspectionGraphic attributeForKey:@"INSSTART"] == nil ||
		[[NSString stringWithFormat:@"%@", [self.selectedInspectionGraphic attributeForKey:@"INSSTART"]] isEqualToString:@""])
	{
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"MMM dd yyyy"];
		self.objCodeViolationAddInspectionVC.inspectionStartDateLabel.text = [dateFormatter stringFromDate:[NSDate date]];
		[dateFormatter release];
	}
	else {
		
		NSDate *inspectionStartDate = [NSDate dateWithTimeIntervalSince1970:[[self.selectedInspectionGraphic attributeForKey:@"INSSTART"] doubleValue]/1000];
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"MMM dd yyyy"];
		self.objCodeViolationAddInspectionVC.inspectionStartDateLabel.text = [dateFormatter stringFromDate:inspectionStartDate];
		[dateFormatter release];
	}
	
	// Notes
	
	if ([[self.selectedInspectionGraphic attributeForKey:@"NOTES"]  isKindOfClass:[NSNull class]] ||
		[self.selectedInspectionGraphic attributeForKey:@"NOTES"] == nil ||
		[[NSString stringWithFormat:@"%@", [self.selectedInspectionGraphic attributeForKey:@"NOTES"]] isEqualToString:@""])
	{
		self.objCodeViolationAddInspectionVC.inspectionNotes.text = @"";
	}
	else {
		
		self.objCodeViolationAddInspectionVC.inspectionNotes.text = [self.selectedInspectionGraphic attributeForKey:@"NOTES"];
	}	
	
	// Contact Owner Segmented Control
	
	if ([[self.selectedInspectionGraphic attributeForKey:@"CONTACTOWN"]   isKindOfClass:[NSNull class]] ||
		[self.selectedInspectionGraphic attributeForKey:@"CONTACTOWN"] == nil ||
		[[NSString stringWithFormat:@"%@", [self.selectedInspectionGraphic attributeForKey:@"CONTACTOWN"]]
         isEqualToString:@""])
	{
		[self.objCodeViolationAddInspectionVC.contactOwnerSegmentedControl setSelectedSegmentIndex:0];
	}
	else {
		
		if ([[self.selectedInspectionGraphic attributeForKey:@"CONTACTOWN"] isEqualToString:@"Yes"]) {
			
			[self.objCodeViolationAddInspectionVC.contactOwnerSegmentedControl setSelectedSegmentIndex:0];
		}
		else if ([[self.selectedInspectionGraphic attributeForKey:@"CONTACTOWN"] isEqualToString:@"No"]) {
			[self.objCodeViolationAddInspectionVC.contactOwnerSegmentedControl setSelectedSegmentIndex:1];
		}
	}

	// Action Picker
	
	if ([[self.selectedInspectionGraphic attributeForKey:@"ACTION"] isKindOfClass:[NSNull class]]||
		[self.selectedInspectionGraphic attributeForKey:@"ACTION"] == nil ||
		[[NSString stringWithFormat:@"%@", [self.selectedInspectionGraphic attributeForKey:@"ACTION"]] isEqualToString:@""])
	{
		[self.objCodeViolationAddInspectionVC.actionPicker selectRow:0 inComponent:0 animated:NO];
		self.objCodeViolationAddInspectionVC.submittedActionLabel.text = [self.actionDomainValues objectAtIndex:0];
	}
	else {
		
		for (int i=0; i<self.actionDomainValues.count; i++) {
			
			if ([[self.selectedInspectionGraphic attributeForKey:@"ACTION"] isEqualToString:[self.actionDomainValues objectAtIndex:i]]) {
				
				[self.objCodeViolationAddInspectionVC.actionPicker selectRow:i inComponent:0 animated:NO];
				self.objCodeViolationAddInspectionVC.submittedActionLabel.text = [self.actionDomainValues objectAtIndex:i];
				break;
			}
			
		}
	}

	
	// End date
	
	if ([[self.selectedInspectionGraphic attributeForKey:@"INSEND"]   isKindOfClass:[NSNull class]] ||
		[self.selectedInspectionGraphic attributeForKey:@"INSEND"] == nil ||
		[[NSString stringWithFormat:@"%@", [self.selectedInspectionGraphic attributeForKey:@"INSEND"]] isEqualToString:@""])
	{
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"MMM dd yyyy"];
		self.objCodeViolationAddInspectionVC.inspectionEndDateLabel.text = [dateFormatter stringFromDate:[NSDate date]];
		[dateFormatter release];
	}
	else {
		
		NSDate *inspectionStartDate = [NSDate dateWithTimeIntervalSince1970:[[self.selectedInspectionGraphic attributeForKey:@"INSEND"] doubleValue]/1000];
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"MMM dd yyyy"];
		self.objCodeViolationAddInspectionVC.inspectionEndDateLabel.text = [dateFormatter stringFromDate:inspectionStartDate];
		[dateFormatter release];
	}

	
	// Inspection User
	
	if ([[self.selectedInspectionGraphic   attributeForKey:@"INSPECTOR"]   isKindOfClass:[NSNull class]] ||
		[self.selectedInspectionGraphic   attributeForKey:@"INSPECTOR"] == nil ||
		[[NSString stringWithFormat:@"%@", [self.selectedInspectionGraphic   attributeForKey:@"INSPECTOR"]] isEqualToString:@""]) 
	{
		self.objCodeViolationAddInspectionVC.inspectionUser.text = @"";
	}
	else {
		self.objCodeViolationAddInspectionVC.inspectionUser.text = [self.selectedInspectionGraphic   attributeForKey:@"INSPECTOR"];
	}
	
}

-(void)searchBarButtonClicked {
	
	[((CodeViolationRootVC *)((CodeViolationAppDelegate *)[UIApplication sharedApplication].delegate).objCodeViolationRootVC).navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark -

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}

#pragma mark Memory Management

- (void)viewDidUnload {
	
	self.selectedViolationGraphic = nil;
	self.violationDetailsTableView = nil;
	self.inspectionDetailsTableView = nil;
	self.violationsFieldAliasDictionary = nil;
	self.violationDetailsDisplayFieldsArray = nil;
	self.inspectionsFieldAliasDictionary = nil;
	self.inspectionDetailsDisplayFieldsArray = nil;
	self.violationAndInspectionScrollView = nil;
	self.objCodeViolationAddInspectionVC = nil;
	self.selectedInspectionGraphic = nil;
	self.editInspectionButton = nil;
	self.inspectionAttachmentImageView = nil;
	self.inspectionsFeatureLayer = nil;
	self.actionDomainValues = nil;
	self.inspectionStatusDomainValues = nil;
	self.loadingImageActivityIndicator = nil;
	
    [super viewDidUnload];
}


- (void)dealloc {
	
	[self.selectedViolationGraphic release];
	[self.violationDetailsTableView release];
	[self.inspectionDetailsTableView release];
	[self.violationsFieldAliasDictionary release];
	[self.violationDetailsDisplayFieldsArray release];
	[self.inspectionsFieldAliasDictionary release];
	[self.inspectionDetailsDisplayFieldsArray release];
	[self.violationAndInspectionScrollView release];
	[self.objCodeViolationAddInspectionVC release];
	[self.selectedInspectionGraphic release];
	[self.editInspectionButton release];
	[self.inspectionAttachmentImageView release];
	[self.inspectionsFeatureLayer release];
	[self.actionDomainValues release];
	[self.inspectionStatusDomainValues release];
	[self.loadingImageActivityIndicator release];
	
    [super dealloc];
}

#pragma mark -



@end
