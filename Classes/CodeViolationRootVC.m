//
//  CodeViolationRootVC.m
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

#import "CodeViolationRootVC.h"
#import "CodeViolationMapVC.h"


@implementation CodeViolationRootVC

@synthesize navigationController, objSearchBar, violationsTableView, objCodeViolationMapVC, 
violationsFeaturesArray, objCodeViolationFeatureDetailsVC, searchActivityIndicator, 
violationsQueryTask, violationsQuery, violationsFieldAliasDictionary, inspectionsQueryTask, inspectionsQuery, addressLocator;

@synthesize violationGrahicNew;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    	
	self.violationsFieldAliasDictionary = [[NSMutableDictionary alloc] init];
		
	if(self.objCodeViolationFeatureDetailsVC == nil)
	{
		self.objCodeViolationFeatureDetailsVC = [[CodeViolationFeatureDetailsVC alloc] initWithNibName:@"CodeViolationFeatureDetailsVC" bundle:nil];
	}
	self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
	
	// Violations QueryTask
	self.violationsQueryTask = [AGSQueryTask queryTaskWithURL:[NSURL URLWithString:[CodeViolationConfigSettings violationFeatureLayerUrl]]];
	self.violationsQueryTask.delegate = self;
	
	self.violationsQuery = [AGSQuery query];
	self.violationsQuery.outFields = [NSArray arrayWithObjects:@"*", nil];
	

	self.addressLocator = [AGSLocator locatorWithURL:[NSURL URLWithString:[CodeViolationConfigSettings locatorUrl]]];
	self.addressLocator.delegate = self;
	
	[super viewDidLoad];
}


- (void)viewWillAppear:(BOOL)animated {
	
	self.title = [CodeViolationConfigSettings panelTitle];
	self.navigationController.contentSizeForViewInPopover = CGSizeMake(319.0, 599.0);
	self.navigationController.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);

	[self.objCodeViolationMapVC.objGraphicsLayer removeAllGraphics];
	
	[super viewWillAppear:animated];
}


// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


#pragma mark -
#pragma mark UISearchBarDelegate Methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	
	[self.objSearchBar resignFirstResponder];
	[self.searchActivityIndicator startAnimating];
	 if (![[UIApplication sharedApplication] isIgnoringInteractionEvents])
	[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
	
	NSString *trimmedSearchString = [searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	
	if([trimmedSearchString length] == 0)
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ErrorTitle", @"ErrorTitle Item")	
														message:NSLocalizedString(@"EnterValidData", @"EnterValidData Item") 
													   delegate:nil 
											  cancelButtonTitle:NSLocalizedString(@"OKTitle", @"OKTitle Item") 
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
		
		[self.searchActivityIndicator stopAnimating];
		if([[UIApplication sharedApplication] isIgnoringInteractionEvents])
		{
			[[UIApplication sharedApplication] endIgnoringInteractionEvents];
		}
	}
	else {
		
        NSArray *searchStringArray = [[NSString stringWithFormat:@"%@", searchBar.text] componentsSeparatedByString:@" "];
        
        if(!([searchStringArray count]>1))
        {
          searchStringArray = [[NSString stringWithFormat:@"%@", searchBar.text] componentsSeparatedByString:@","];
        }
		
		
		if ([searchStringArray count] > 1) {
			
			// Geocode
			NSArray *returnFields = [[CodeViolationConfigSettings locatorFields] componentsSeparatedByString:@","];
		        
            NSDictionary *address = [NSDictionary dictionaryWithObject:searchBar.text forKey:@"SingleLine"];
                        
            [self.addressLocator locationsForAddress:address returnFields:returnFields outSpatialReference:self.objCodeViolationMapVC.mapView.spatialReference];
           			
		}
		else {
            
			// Search by violation type
			self.violationsQuery.where = [NSString stringWithFormat:@"%@ like '%%%@%%' and %@", [CodeViolationConfigSettings violationTypeField], searchBar.text, self.objCodeViolationMapVC.violationsFeatureLayer.definitionExpression];
			
			self.violationsQuery.returnGeometry = NO;
			
			if (self.objCodeViolationMapVC.mapView.visibleArea.envelope!=nil) {
				self.violationsQuery.geometry = self.objCodeViolationMapVC.mapView.visibleArea.envelope;
			}
			
			[self.violationsQueryTask executeWithQuery:self.violationsQuery];

		}
	}
	
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	[self.objSearchBar resignFirstResponder];
}


#pragma mark -
#pragma mark SearchFunctionality

- (NSArray*) formatAddress:(NSString *)addressString {
	NSArray *addressFields = [addressString componentsSeparatedByString:@","];
	NSMutableArray *addressFields1 = [NSMutableArray arrayWithObjects:@"",@"",@"",@"",nil];
	
	for (int i=0;i<[addressFields count]; i++) {
		if (i>3) {
			break;
		}
		NSString *field = [addressFields objectAtIndex:i];
		// if numeric and has length of 5 then it is zip code
		if ([self isZipCode:field]) {
			[addressFields1 replaceObjectAtIndex:3 withObject:field];
			break;
		}
		else if([field length] == 2){
			[addressFields1 replaceObjectAtIndex:2 withObject:[NSString stringWithFormat:@"%@",field]];
		}

		else {
			[addressFields1 replaceObjectAtIndex:i withObject:field];
		}
	}
	
	return addressFields1;
}

- (BOOL) isZipCode:(NSString *)field
{
	for (int i=0; i<[field length]; i++) {
		int asciiCode = (int)[field characterAtIndex:i];
		if ((asciiCode<48) || (asciiCode>57)){
			return NO;
		}
	}
	
	return([field length]==5)?YES:NO;
}


#pragma mark -
#pragma mark AGSLocatorDelegate

- (void)locator:(AGSLocator *)locator operation:(NSOperation *)op didFindLocationsForAddress:(NSArray *)candidates
{
		
    //check and see if we didn't get any results
	if (candidates == nil || [candidates count] == 0)
	{
        //show alert if we didn't get results
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
														message:NSLocalizedString(@"NoResultsFoundByLocator", @"NoResultsFoundByLocator Item")
													   delegate:nil
											  cancelButtonTitle:NSLocalizedString(@"OKTitle", @"OKTitle Item")
											  otherButtonTitles:nil];
        
        [alert show];
        [alert release];
	}
	else
	{
		AGSAddressCandidate *tempCandidate = [candidates objectAtIndex:0];
		
		if (tempCandidate.score >= 50) {
			
			
			AGSPoint *point = tempCandidate.location;
			
			if ([self.objCodeViolationMapVC.currentBaseMapServiceLayer.fullEnvelope containsPoint:point]) {
				
				AGSEnvelope *tempEnv = self.objCodeViolationMapVC.currentBaseMapServiceLayer.fullEnvelope;
				AGSMutableEnvelope *envelope = [AGSMutableEnvelope envelopeWithXmin:tempEnv.xmin ymin:tempEnv.ymin xmax:tempEnv.xmax ymax:tempEnv.ymax spatialReference:self.objCodeViolationMapVC.mapView.spatialReference];
				
				[envelope expandByFactor:[[CodeViolationConfigSettings ExpandFactorForSearch] doubleValue] withAnchorPoint:point];			    
				
				AGSPictureMarkerSymbol *newViolationPictureSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImage:[UIImage imageNamed:@"MapPointPin.png"]] ;
						
                newViolationPictureSymbol.offset = CGPointMake(8, -18);
                
				AGSGraphic *violationGraphicNew = [AGSGraphic graphicWithGeometry:point 
																		   symbol:newViolationPictureSymbol 
																	   attributes:nil 
															 infoTemplateDelegate:nil];
				
           
                [self.objCodeViolationMapVC.objGraphicsLayer removeAllGraphics];
               
				[self.objCodeViolationMapVC.objGraphicsLayer addGraphic:violationGraphicNew];
                							
				[self.objCodeViolationMapVC.mapView zoomToEnvelope:envelope animated:NO];
				
			}
			else {
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
																message:NSLocalizedString(@"ResultsFoundAreOutsideMap", @"ResultsFoundAreOutsideMap Item")
															   delegate:nil
													  cancelButtonTitle:NSLocalizedString(@"OKTitle", @"OKTitle Item")
													  otherButtonTitles:nil];
				
				[alert show];
				[alert release];
			}

		}
	}
	
	[self.searchActivityIndicator stopAnimating];
	if([[UIApplication sharedApplication] isIgnoringInteractionEvents])
	{
		[[UIApplication sharedApplication] endIgnoringInteractionEvents];
	}
}

- (void)locator:(AGSLocator *)locator operation:(NSOperation *)op didFailLocationsForAddress:(NSError *)error
{
    //The location operation failed, display the error
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LocatorFailed",@"LocatorFailed Item")
                    message:[NSString stringWithFormat:@"Error: %@", error.description] delegate:nil
                    cancelButtonTitle:NSLocalizedString(@"OKTitle", @"OKTitle Item") otherButtonTitles:nil];
	
    [alert show];
    [alert release];
	
	[self.searchActivityIndicator stopAnimating];
    
	if([[UIApplication sharedApplication] isIgnoringInteractionEvents])
	{
		[[UIApplication sharedApplication] endIgnoringInteractionEvents];
	}
}

#pragma mark -
#pragma mark AGSQueryTaskDelegate Methods

- (void)queryTask:(AGSQueryTask *)queryTask operation:(NSOperation *)op 
didExecuteWithFeatureSetResult:(AGSFeatureSet *)featureSet {
	//get feature, and load in to table

	if (queryTask == self.violationsQueryTask) {
		
		self.violationsFeaturesArray = (NSMutableArray *)featureSet.features;
        
		[self.violationsTableView reloadData];
        
		[self.searchActivityIndicator stopAnimating];
        
		if([[UIApplication sharedApplication] isIgnoringInteractionEvents]) {
            
			[[UIApplication sharedApplication] endIgnoringInteractionEvents];
		}
        
		if ([self.violationsFeaturesArray count] == 0) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil	
                        message:NSLocalizedString(@"NoResultsFoundforViolationType", @"NoResultsFoundforViolationType Item")
                        delegate:nil cancelButtonTitle:NSLocalizedString(@"OKTitle", @"OKTitle Item") otherButtonTitles:nil];
            
			[alert show];
			[alert release];
		}
		
	}

}	

- (void)queryTask:(AGSQueryTask *) queryTask operation:(NSOperation *) op didFailWithError:(NSError *) error {
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ErrorTitle", @"ErrorTitle Item")	
                    message:NSLocalizedString(@"QueryTaskfailwitherror", @"QueryTaskfailwitherror Item")
                    delegate:nil cancelButtonTitle:NSLocalizedString(@"OKTitle", @"OKTitle Item") otherButtonTitles:nil];
    
	[alert show];
	[alert release];
	
	[self.searchActivityIndicator stopAnimating];
    
	if([[UIApplication sharedApplication] isIgnoringInteractionEvents]) {
        
		[[UIApplication sharedApplication] endIgnoringInteractionEvents];
	}
	
}

#pragma mark -

#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if ([self.violationsFeaturesArray count] > 0) {
		return [self.violationsFeaturesArray count];
	}
	else {
		return 0;
	}
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	[cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
	
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];		
    }
    
    // Configure the cell...
	
	if ([self.violationsFeaturesArray count] > 0) 
	{
		NSArray *violationsDisplayFields = [CodeViolationConfigSettings violationsDisplayFields];
		
		// Check Null Fields
		
		if ([[((AGSGraphic *)[self.violationsFeaturesArray objectAtIndex:indexPath.row]) attributeForKey:[violationsDisplayFields objectAtIndex:0]] isKindOfClass:[NSNull class]] ||
			[((AGSGraphic *)[self.violationsFeaturesArray objectAtIndex:indexPath.row]) attributeForKey:[violationsDisplayFields objectAtIndex:0]] == nil ||
			[[NSString stringWithFormat:@"%@", [((AGSGraphic *)[self.violationsFeaturesArray objectAtIndex:indexPath.row]) attributeForKey:[violationsDisplayFields objectAtIndex:0]]] isEqualToString:@""])
		{
			cell.textLabel.text = NSLocalizedString(@"NoData", @"NoData Item");
		}
		else {
			
			cell.textLabel.text = [NSString stringWithFormat:@"%@", [((AGSGraphic *)[self.violationsFeaturesArray objectAtIndex:indexPath.row]) attributeForKey:[violationsDisplayFields objectAtIndex:0]]];
		}

		
		if ([[((AGSGraphic *)[self.violationsFeaturesArray objectAtIndex:indexPath.row]) attributeForKey:[violationsDisplayFields objectAtIndex:1]] isKindOfClass:[NSNull class]] ||
			[((AGSGraphic *)[self.violationsFeaturesArray objectAtIndex:indexPath.row]) attributeForKey:[violationsDisplayFields objectAtIndex:1]] == nil ||
			[[NSString stringWithFormat:@"%@", [((AGSGraphic *)[self.violationsFeaturesArray objectAtIndex:indexPath.row]) attributeForKey:[violationsDisplayFields objectAtIndex:1]]] isEqualToString:@""])
		{
			cell.detailTextLabel.text = NSLocalizedString(@"NoData", @"NoData Item");
		}
		else {
			
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [((AGSGraphic *)[self.violationsFeaturesArray objectAtIndex:indexPath.row]) attributeForKey:[violationsDisplayFields objectAtIndex:1]]];
		}
		
		
		UIImage *image = nil;
		AGSGraphic *currentGraphic = (AGSGraphic *)[self.violationsFeaturesArray objectAtIndex:indexPath.row];
		
		if ([[NSString stringWithFormat:@"%@", [currentGraphic attributeForKey:[CodeViolationConfigSettings statusField]]] isEqualToString:@"Open"]) {
			image = [UIImage imageNamed:@"openViolation.png"];
		}
		else {
			image = [UIImage imageNamed:@"closeViolation.png"];
		}
		
		UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
		button.tag = indexPath.row;
		CGRect frame = CGRectMake(0.0, 0.0, 36, 36);
		button.frame = frame;	// match the button's size with the image size
		
		[button setBackgroundImage:image forState:UIControlStateNormal];
		
		// set the button's target to this table view controller so we can interpret touch events and map that to a NSIndexSet
		[button addTarget:self action:@selector(accessoryButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		cell.backgroundColor = [UIColor clearColor];
		cell.accessoryView = button;
		
		if ([[currentGraphic attributeForKey:@"OBJECTID"] integerValue] == [[self.violationGrahicNew attributeForKey:@"OBJECTID"] integerValue]) {
				
			[self.violationsTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
			self.violationGrahicNew = nil;
		}
	}
	
	return cell;
	
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    /*
     When a row is selected, set the detail view controller's detail item to the item associated with the selected row.
     */
		
	// Load Violations
    
    //nav added
    
  
  
	if ([self.violationsFieldAliasDictionary count] > 0) {
		[self showViolationGraphicDetail:indexPath];
	}
	else {
		[self.objCodeViolationMapVC executeQueryWithCondition];
		[self performSelector:@selector(showViolationGraphicDetail:) withObject:indexPath afterDelay:1.5];
	}
    
}


#pragma mark -
#pragma mark Actions

-(void)accessoryButtonTapped:(id)sender {

	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:((UIButton *)sender).tag inSection:0];
	
	/*
     When a row is selected, set the detail view controller's detail item to the item associated with the selected row.
     */	
	
	// Load Violations
	if ([self.violationsFieldAliasDictionary count] > 0) {
		[self showViolationGraphicDetail:indexPath];
	}
	else {
		[self.objCodeViolationMapVC executeQueryWithCondition];
		[self performSelector:@selector(showViolationGraphicDetail:) withObject:indexPath afterDelay:1.5];
	}
}


- (void) showViolationGraphicDetail :(NSIndexPath *)indexPath {
	
	[self.navigationController pushViewController:self.objCodeViolationFeatureDetailsVC animated:YES];
		
	AGSGraphic *currentGraphic = [self.violationsFeaturesArray objectAtIndex:indexPath.row];
	AGSGraphic *ringGraphic = [AGSGraphic graphicWithGeometry:currentGraphic.geometry 
                        symbol:nil attributes:nil infoTemplateDelegate:nil];
	
	[self.objCodeViolationMapVC addRingForSelectedViolation:ringGraphic];
	[self reloadFeatureDetails:currentGraphic];	
}

-(void)reloadFeatureDetails:(AGSGraphic *)currentGraphic {
	
	if (([[currentGraphic attributeForKey:@"OBJECTID"] intValue] != [[self.objCodeViolationFeatureDetailsVC.selectedViolationGraphic attributeForKey:@"OBJECTID"] intValue]) || (self.objCodeViolationFeatureDetailsVC.didUpdateViolation == YES)) {
				
		self.objCodeViolationFeatureDetailsVC.selectedViolationGraphic = currentGraphic;
		self.objCodeViolationFeatureDetailsVC.didUpdateViolation = NO;
		
		if (self.objCodeViolationFeatureDetailsVC.inspectionsQueryTask == nil) {
			
			self.objCodeViolationFeatureDetailsVC.inspectionsQueryTask = [AGSQueryTask queryTaskWithURL:[NSURL URLWithString:[CodeViolationConfigSettings inspectionFeatureLayerUrl]]];
			self.objCodeViolationFeatureDetailsVC.inspectionsQueryTask.delegate = self.objCodeViolationFeatureDetailsVC;
			
			// Load Inspections
			
			self.objCodeViolationFeatureDetailsVC.inspectionsQuery = [AGSQuery query];
			self.objCodeViolationFeatureDetailsVC.inspectionsQuery.outFields = [NSArray arrayWithObjects:@"*", nil];
			self.objCodeViolationFeatureDetailsVC.inspectionsQuery.returnGeometry = NO;
			
			AGSSpatialReference *sr = ((CodeViolationMapVC *)((CodeViolationAppDelegate *)[UIApplication sharedApplication].delegate).objCodeViolationMapVC).mapView.spatialReference;
			
			self.objCodeViolationFeatureDetailsVC.inspectionsQuery.outSpatialReference = sr;
			
		}
		
		// check for same graphic
		self.objCodeViolationFeatureDetailsVC.inspectionsFeaturesArray = nil;
		[self.objCodeViolationFeatureDetailsVC.inspectionDetailsTableView reloadData];
        
		[self.objCodeViolationFeatureDetailsVC.loadingInspectionsIndicator startAnimating];
        
		self.objCodeViolationFeatureDetailsVC.inspectionsQuery.where = [NSString stringWithFormat:@"VIOLATEKEY='%@'", [self.objCodeViolationFeatureDetailsVC.selectedViolationGraphic attributeForKey:@"VIOLATIONID"]];
        
        
		[self.objCodeViolationFeatureDetailsVC.inspectionsQueryTask executeWithQuery:self.objCodeViolationFeatureDetailsVC.inspectionsQuery];
		
	}
	else {
		if ([self.objCodeViolationFeatureDetailsVC.inspectionsFeaturesArray count] > 0) {
			[self.objCodeViolationFeatureDetailsVC.inspectionDetailsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
		}
	}

	if ([[self.objCodeViolationFeatureDetailsVC.selectedViolationGraphic attributeForKey:@"STATUS"] isEqualToString:@"Open"]) {
		
		self.objCodeViolationFeatureDetailsVC.editViolationButton.enabled = YES;
        
        if (([self.objCodeViolationFeatureDetailsVC.actionDomainValues count]>0) ||([self.objCodeViolationFeatureDetailsVC.inspectionStatusDomainValues count]>0)) {
            
            self.objCodeViolationFeatureDetailsVC.addInspectionButton.enabled = YES;                       
        }
        else {
            [self.objCodeViolationFeatureDetailsVC.loadingInspectionsIndicatorForButton startAnimating];
            
            self.objCodeViolationFeatureDetailsVC.addInspectionButton.enabled = NO;
        }
		
	}
	else if ([[self.objCodeViolationFeatureDetailsVC.selectedViolationGraphic attributeForKey:@"STATUS"] isEqualToString:@"Closed"]) {
		
		self.objCodeViolationFeatureDetailsVC.editViolationButton.enabled = NO;
		self.objCodeViolationFeatureDetailsVC.addInspectionButton.enabled = NO;
	}
	
	// Violation Details Display Fields
	
	self.objCodeViolationFeatureDetailsVC.violationDetailsDisplayFieldsArray = [CodeViolationConfigSettings violationDetailsDisplayFields];
	self.objCodeViolationFeatureDetailsVC.violationsFieldAliasDictionary = self.violationsFieldAliasDictionary;
	
	// Inspection Details Display Fields
	
	self.objCodeViolationFeatureDetailsVC.inspectionDetailsDisplayFieldsArray = [CodeViolationConfigSettings inspectionDetailsDisplayFields];
	
	[self.objCodeViolationFeatureDetailsVC.violationDetailsTableView reloadData];
	[self.objCodeViolationFeatureDetailsVC.violationDetailsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
       
	
}



#pragma mark -

#pragma mark Memory management

- (void)viewDidUnload {
    
	self.navigationController = nil;
	self.objSearchBar = nil;
	self.violationsTableView = nil;
	self.objCodeViolationMapVC = nil;
	self.violationsFeaturesArray = nil;
	self.objCodeViolationFeatureDetailsVC = nil;
	self.searchActivityIndicator = nil;
	self.violationsQueryTask = nil;
	self.violationsQuery = nil;
	self.violationsFieldAliasDictionary = nil;
	self.inspectionsQueryTask = nil;
	self.inspectionsQuery = nil;
	self.addressLocator = nil;
	self.violationGrahicNew = nil;
	
	[super viewDidUnload];
}


- (void)dealloc {
	
	[self.navigationController release];
	[self.objSearchBar release];
	[self.violationsTableView release];
	[self.objCodeViolationMapVC release];
	[self.violationsFeaturesArray release];
	[self.objCodeViolationFeatureDetailsVC release];
	[self.searchActivityIndicator release];
	[self.violationsQueryTask release];
	[self.violationsQuery release];
	[self.violationsFieldAliasDictionary release];
	[self.inspectionsQueryTask release];
	[self.inspectionsQuery release];
	[self.addressLocator release];
	[self.violationGrahicNew release];
	
    [super dealloc];
}

#pragma mark -

@end

