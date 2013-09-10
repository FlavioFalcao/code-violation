//
//  CodeViolationSettingsVC.m
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

#import "CodeViolationSettingsVC.h"
#import "CodeViolationMapVC.h"

@implementation CodeViolationSettingsVC
@synthesize settingsTableView;
@synthesize parcelMapSwitch,hybridMapSwitch,objCodeViolationMapVC,violationStatus,baseMaps,openViolationSwitch,closeViolationSwitch;

@synthesize myAlertView;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.violationStatus = [[NSArray alloc] initWithObjects:@"Open", @"Closed", nil];
	self.baseMaps = [[NSArray alloc] initWithObjects:@"Parcel", @"Imagery Hybrid", nil];

}

-(void) viewDidAppear:(BOOL)animated
{
	self.contentSizeForViewInPopover=CGSizeMake(260,280);
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSString *returnStr = nil;
	switch (section) {
		case 0:
			returnStr =  NSLocalizedString(@"CodeViolations" ,@"CodeViolations Item"); //[NSString stringWithString:@"CodeViolations"];
			break;
		case 1:
			returnStr =  NSLocalizedString(@"Basemaps" ,@"Basemaps Item"); //[NSString stringWithString:@"Basemaps"];
			break;
		default:
			break;
	}
	return returnStr;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *violationStatusCellIdentifier = @"violationStatusCellIdentifier";
	static NSString *baseMapCellIdentifier = @"baseMapCellIdentifier";
	
	NSUInteger section = [indexPath section];
	UITableViewCell *cell = nil;
	
	switch (section) {
		case 0:
			cell = [settingsTableView dequeueReusableCellWithIdentifier:violationStatusCellIdentifier];
			break;
		case 1:
			cell = [settingsTableView dequeueReusableCellWithIdentifier:baseMapCellIdentifier];
			break;
			
		default:
			break;
	}
	
	if (cell == nil) {
		
		switch (section) {
			case 0:
			{	
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:violationStatusCellIdentifier] autorelease];
				[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
				
			
				UILabel * attributeLabel = [[[UILabel alloc]
											 initWithFrame:CGRectZero] autorelease];
				attributeLabel.backgroundColor = [UIColor clearColor];
				attributeLabel.opaque = NO;
				attributeLabel.textColor = [UIColor blackColor];
				attributeLabel.font = [UIFont boldSystemFontOfSize:13];
				attributeLabel.frame = CGRectMake(10.0,10.0,240.0,200.0);
			    attributeLabel.center = CGPointMake(attributeLabel.frame.origin.x + attributeLabel.frame.size.width/2 , cell.frame.size.height/2);
				[attributeLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
				attributeLabel.textAlignment = UITextAlignmentLeft;
				attributeLabel.tag = 2;
				[cell.contentView addSubview:attributeLabel];
				
				UISwitch *featureLayerSwitch = [[[UISwitch alloc] initWithFrame:CGRectZero] autorelease];
				
				featureLayerSwitch.frame = CGRectMake(cell.frame.size.width - 100.0, 0.0, 80.0, cell.frame.size.height- 10.0) ;
				featureLayerSwitch.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin ;
				featureLayerSwitch.center = CGPointMake((featureLayerSwitch.frame.origin.x + featureLayerSwitch.frame.size.width/2) , cell.frame.size.height/2);
				featureLayerSwitch.tag = 3 ;
				if(indexPath.row == 0)
				{
					self.openViolationSwitch = featureLayerSwitch;
					[self.openViolationSwitch addTarget:self action:@selector(ViolationTypeSwitchChanged:) forControlEvents:UIControlEventValueChanged];
					[cell.contentView addSubview:self.openViolationSwitch];
					[self.openViolationSwitch setOn:YES];
				}
				else {
					self.closeViolationSwitch = featureLayerSwitch;
					[self.closeViolationSwitch addTarget:self action:@selector(ViolationTypeSwitchChanged:) forControlEvents:UIControlEventValueChanged];
					[cell.contentView addSubview:self.closeViolationSwitch];
				}

				}
		
		break;
		
			case 1:
			{

				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:baseMapCellIdentifier] autorelease];
				[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
				UILabel * attributeLabel = [[[UILabel alloc]
											 initWithFrame:CGRectZero] autorelease];
				attributeLabel.backgroundColor = [UIColor clearColor];
				attributeLabel.opaque = NO;
				attributeLabel.textColor = [UIColor blackColor];
				attributeLabel.font = [UIFont boldSystemFontOfSize:13];
				attributeLabel.frame = CGRectMake(10.0, 10.0, 200.0, 200.0);
				attributeLabel.center = CGPointMake(attributeLabel.frame.origin.x + attributeLabel.frame.size.width/2 , cell.frame.size.height/2);
				[attributeLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
				attributeLabel.textAlignment = UITextAlignmentLeft;
				attributeLabel.tag = 2;
				[cell.contentView addSubview:attributeLabel];
				UISwitch *baseMapSwitch = [[[UISwitch alloc] initWithFrame:CGRectZero] autorelease];
				baseMapSwitch.frame = CGRectMake(cell.frame.size.width - 100.0, 0.0, 80.0, cell.frame.size.height- 10.0) ;				
				baseMapSwitch.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin ;
				baseMapSwitch.center = CGPointMake((baseMapSwitch.frame.origin.x + baseMapSwitch.frame.size.width/2) , cell.frame.size.height/2);
				baseMapSwitch.tag = 3 ;
				
				if(indexPath.row == 0)
				{
					self.parcelMapSwitch = baseMapSwitch;
					[self.parcelMapSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
					[cell.contentView addSubview:self.parcelMapSwitch];
					[self.parcelMapSwitch setOn:YES];
				}
				else {	
					self.hybridMapSwitch = baseMapSwitch;
					[self.hybridMapSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
					[cell.contentView addSubview:self.hybridMapSwitch];
					
				}
							
			}
				
				break;
				
			default:
				break;
		}
		
	}
	switch (section) {
		case 0:{
			int row = [indexPath row];
			UILabel *tempLabel = (UILabel *) [cell viewWithTag:2];

			if (row == 0)  {
				tempLabel.text = [self.violationStatus objectAtIndex:0];

			}
			else {
				tempLabel.text = [self.violationStatus objectAtIndex:1];

			}

		}	
			break;
			
		case 1:{
			
			int row = [indexPath row];
			UILabel *tempLabel = (UILabel *) [cell viewWithTag:2];
			
			if (row == 0)  {
				tempLabel.text = [self.baseMaps objectAtIndex:0];
				
			}
			else {
				tempLabel.text = [self.baseMaps objectAtIndex:1];
				
			}
		}
			break;
		default:
			break;
	}
	
	return cell;
}

#pragma mark Actions

-(IBAction)ViolationTypeSwitchChanged:(id)sender{
    
    self.myAlertView = [[UIAlertView alloc] initWithTitle:@"Loading..."
                        message:@"\n" delegate:self cancelButtonTitle:nil
                        otherButtonTitles:nil];
            
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.center = CGPointMake(139.5, 75.5); // .5 so it doesn't blur
    
    [self.myAlertView addSubview:spinner];
    [spinner startAnimating];
    
     
    [self.myAlertView show];
	   
    
    
    [self.view setUserInteractionEnabled:FALSE];
    
    
	AGSGraphic *tempViolationGraphic = self.objCodeViolationMapVC.objCodeViolationRootVC.objCodeViolationFeatureDetailsVC.selectedViolationGraphic ;
	NSString *CurrentGraphicStatus = [tempViolationGraphic attributeForKey:@"STATUS"];
	
	if (![self.objCodeViolationMapVC.objCodeViolationRootVC.objSearchBar.text isEqualToString:@""]) {
        
		self.objCodeViolationMapVC.objCodeViolationRootVC.objSearchBar.text = @"";
	}
	
	if (![self.openViolationSwitch isOn] && [self.closeViolationSwitch isOn]) {
        
		self.objCodeViolationMapVC.violationsFeatureLayer.definitionExpression = @"STATUS='Closed'";
        
        [self.objCodeViolationMapVC.violationsFeatureLayer refresh];
        
		self.objCodeViolationMapVC.violationsFeatureLayerQuery.where = nil;
		self.objCodeViolationMapVC.violationsFeatureLayerQuery.where = @"STATUS='Closed'";
        
		if ([CurrentGraphicStatus isEqualToString:@"Open"]) {
			if ([self.objCodeViolationMapVC.objGraphicsLayer.graphics count] > 0) {
				[self removeRingGraphicAndPopOut];
			}
		}
		[self.objCodeViolationMapVC executeQueryWithCondition];
	}
	else if([self.openViolationSwitch isOn] && ![self.closeViolationSwitch isOn]){
		self.objCodeViolationMapVC.violationsFeatureLayerQuery.where = nil;
		self.objCodeViolationMapVC.violationsFeatureLayer.definitionExpression = @"STATUS='Open'";
        [self.objCodeViolationMapVC.violationsFeatureLayer refresh];
		self.objCodeViolationMapVC.violationsFeatureLayerQuery.where = @"STATUS='Open'";
		if ([CurrentGraphicStatus isEqualToString:@"Closed"]) {
			if ([self.objCodeViolationMapVC.objGraphicsLayer.graphics count] > 0) {
				[self removeRingGraphicAndPopOut];
			}
		}
		[self.objCodeViolationMapVC executeQueryWithCondition];
		
	}
	else if([self.openViolationSwitch isOn] && [self.closeViolationSwitch isOn]){
		self.objCodeViolationMapVC.violationsFeatureLayerQuery.where = nil;
		self.objCodeViolationMapVC.violationsFeatureLayer.definitionExpression = @"(STATUS='Closed' or STATUS='Open')";
        [self.objCodeViolationMapVC.violationsFeatureLayer refresh];
        
		self.objCodeViolationMapVC.violationsFeatureLayerQuery.where = @"(STATUS='Closed' or STATUS='Open')";
		[self.objCodeViolationMapVC executeQueryWithCondition];
	}
	else if(![self.openViolationSwitch isOn] && ![self.closeViolationSwitch isOn]){        
		self.objCodeViolationMapVC.violationsFeatureLayerQuery.where = nil;
		self.objCodeViolationMapVC.violationsFeatureLayer.definitionExpression = @"1=2";
        [self.objCodeViolationMapVC.violationsFeatureLayer refresh];
		self.objCodeViolationMapVC.violationsFeatureLayerQuery.where = @"1=2";
		if ([self.objCodeViolationMapVC.objGraphicsLayer.graphics count] > 0) {
			[self removeRingGraphicAndPopOut];
		}
        
		[self.objCodeViolationMapVC executeQueryWithCondition];
		
	}
    
	
        
    if ([[UIApplication sharedApplication] isIgnoringInteractionEvents]) {
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }     
}


-(IBAction)switchChanged:(id)sender {

	UISwitch *whichSwitch = (UISwitch *)sender;
	
	BOOL setting = [whichSwitch isOn];
	[whichSwitch setOn:setting animated:YES];
	
	if (whichSwitch == self.parcelMapSwitch) {
		[self.hybridMapSwitch setOn:!setting animated:YES];
	}
	else {
		[self.parcelMapSwitch setOn:!setting animated:YES];
	}
	
	[self performSelector:@selector(switchBaseMaps) withObject:nil afterDelay:0.30];	
}

-(void)switchBaseMaps {
    
	if([self.parcelMapSwitch isOn])
	{		         
        [self.objCodeViolationMapVC.mapView removeMapLayerWithName:@"Hybrid_Map"];
        
        self.objCodeViolationMapVC.parcelMapServiceLayer = [AGSTiledMapServiceLayer tiledMapServiceLayerWithURL:[NSURL URLWithString:[CodeViolationConfigSettings parcelBaseMapUrl]]];
        self.objCodeViolationMapVC.parcelMapServiceLayer.name = @"Parcel_Map";
        
        [self.objCodeViolationMapVC.mapView insertMapLayer:self.objCodeViolationMapVC.parcelMapServiceLayer atIndex:0];
      
	}
	else if([self.hybridMapSwitch isOn])
	{
		         
        [self.objCodeViolationMapVC.mapView removeMapLayerWithName:@"Parcel_Map"];
        
        self.objCodeViolationMapVC.hybridMapServiceLayer = [AGSTiledMapServiceLayer tiledMapServiceLayerWithURL:[NSURL URLWithString:[CodeViolationConfigSettings hybridBaseMapUrl]]];
        self.objCodeViolationMapVC.hybridMapServiceLayer.name = @"Hybrid_Map";
        
        [self.objCodeViolationMapVC.mapView insertMapLayer:self.objCodeViolationMapVC.hybridMapServiceLayer atIndex:0];
        
    }
	
}


- (void) removeRingGraphicAndPopOut {
	[self.objCodeViolationMapVC.objGraphicsLayer removeAllGraphics];
     
	[self.objCodeViolationMapVC.objCodeViolationRootVC.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark -

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}

#pragma mark Memory Management

- (void)viewDidUnload {
	
	self.settingsTableView = nil;
	self.parcelMapSwitch = nil;
	self.hybridMapSwitch = nil;
	self.objCodeViolationMapVC = nil;
	self.violationStatus = nil;
	self.baseMaps = nil;
	self.openViolationSwitch = nil;
	self.closeViolationSwitch = nil;
	
    [super viewDidUnload];
}


- (void)dealloc {
	
	[self.settingsTableView release];
	[self.parcelMapSwitch release];
	[self.hybridMapSwitch release];
	[self.objCodeViolationMapVC release];
	[self.violationStatus release];
	[self.baseMaps release];
	[self.openViolationSwitch release];
	[self.closeViolationSwitch release];
	
    [super dealloc];
}

#pragma mark -


@end
