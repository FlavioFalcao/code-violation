//
//  CodeViolationMapVC.m
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

#import "CodeViolationMapVC.h"
#import "CodeViolationRootVC.h"

@implementation CodeViolationMapVC

@synthesize toolbar, popoverController, detailItem;
@synthesize mapView, parcelMapServiceLayer, hybridMapServiceLayer, currentBaseMapServiceLayer, violationsFeatureLayer, 
parcelMapView, hybridMapView, violationsFeatureLayerView, window, networkDisconnectionVC, violationsFeatureLayerQuery, 
objGraphicsLayer, settingsButton, GPSButton, locationManager, 
settingsPopoverController, objCodeViolationSettingsVC, objCodeViolationAboutUsVC, objCodeViolationRootVC, 
violationsFeatureLayerDomainValues, objCodeViolationAddViolationVC,violationsItem;

@synthesize progressLabel, activityIndicator,topViewController,ClickAtPointAlert,tempGraphicsArray,graphicPointNew,tapAndHoldAlert,viewDidAppear,defaultSymbol;

@synthesize alertForFail;

#pragma mark -
#pragma mark View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
   self.title=@"Code Violation";
	
	if ([CodeViolationConfigSettings configDictCount] == 0) {
		if ([[UIApplication sharedApplication] isIgnoringInteractionEvents]) {
			[[UIApplication sharedApplication] endIgnoringInteractionEvents];
		}
        		
		self.networkDisconnectionVC = [[NetworkDisconnectionVC alloc] initWithNibName:@"NetworkDisconnectionVC" bundle:nil] ;
        
		self.networkDisconnectionVC.noConfigFound = YES;
		[self.window addSubview:self.networkDisconnectionVC.view] ;
		[self.networkDisconnectionVC release] ;
		
		return;
	}
	
	if([self detectEmptyConfigFields])
	{
		return;
	}
	
	self.progressLabel.text = NSLocalizedString(@"Loading Map",@"LoadingMap String");
	[self beginActivityIndicator];
	
	
	self.mapView.layerDelegate = self;
    
	self.mapView.touchDelegate = self;
    
	self.mapView.calloutDelegate = self;
    
    self.mapView.callout.delegate = self;
	
	 self.parcelMapServiceLayer = [[AGSTiledMapServiceLayer alloc] initWithURL:[NSURL URLWithString:[CodeViolationConfigSettings parcelBaseMapUrl]]];
         
    
    self.parcelMapServiceLayer.name = @"Parcel_Map";
    [self.mapView insertMapLayer:self.parcelMapServiceLayer atIndex:0];
	
	self.hybridMapServiceLayer = [[AGSTiledMapServiceLayer alloc] initWithURL:[NSURL URLWithString:[CodeViolationConfigSettings hybridBaseMapUrl]]];
    	
	
	self.currentBaseMapServiceLayer = self.parcelMapServiceLayer;

	
	self.violationsFeatureLayerDomainValues = [[NSMutableArray alloc] init];
	
	self.ClickAtPointAlert = [[UIAlertView alloc] initWithTitle:nil
                    message:NSLocalizedString(@"DoyouWanttoSavetheChanges", @"DoyouWanttoSavetheChanges Item")
                    delegate:self   cancelButtonTitle:nil
                    otherButtonTitles:NSLocalizedString(@"Yes", @"Yes Item"),NSLocalizedString(@"No", @"No Item"),nil];
	
	self.tapAndHoldAlert = [[UIAlertView alloc] initWithTitle:nil
                    message:NSLocalizedString(@"DoyouWanttoSavetheChanges", @"DoyouWanttoSavetheChanges Item")
                    delegate:self   cancelButtonTitle:nil
                    otherButtonTitles:NSLocalizedString(@"Yes", @"Yes Item"),NSLocalizedString(@"No", @"No Item"),nil];

	
	[super viewDidLoad];
}

- (void) viewDidAppear:(BOOL)animated {
	self.viewDidAppear = YES;
}

#pragma mark -
- (BOOL) detectEmptyConfigFields {
    
	BOOL returnVal = NO;
	if ([CodeViolationConfigSettings parcelBaseMapUrl] == nil || [CodeViolationConfigSettings hybridBaseMapUrl]== nil 
		||[CodeViolationConfigSettings violationFeatureLayerUrl]== nil || [CodeViolationConfigSettings locatorUrl]== nil ) {
		
		UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ErrorTitle", @"ErrorTitle Item")
                    message:NSLocalizedString(@"UnableToLoadConfig", @"UnableToLoadConfig Item")    delegate:nil
                    cancelButtonTitle:NSLocalizedString(@"OKTitle", @"OKTitle Item") otherButtonTitles:nil];
        
		[alert show] ;
		[alert release];
		returnVal =  YES;
	}
	else {
		returnVal = NO;
	}
    
	return returnVal;
}

- (void) zoomToDefaultEnvelope {
	
	NSArray *defaultExtentArray = [CodeViolationConfigSettings getDefaultMapExtent];
	if ([defaultExtentArray count] == 4) {
		AGSMutableEnvelope *defaultMapExtent = [[AGSMutableEnvelope alloc] initWithXmin:[[defaultExtentArray objectAtIndex:0] doubleValue]
                    ymin:[[defaultExtentArray objectAtIndex:1] doubleValue]
                    xmax:[[defaultExtentArray objectAtIndex:2] doubleValue]
                    ymax:[[defaultExtentArray objectAtIndex:3] doubleValue]
                    spatialReference:self.mapView.spatialReference];
	
		[self.mapView zoomToEnvelope:defaultMapExtent animated:YES];
		[defaultMapExtent release];
	}
	
}

#pragma mark AGSMapViewDelegate Methods

- (void)mapViewDidLoad:(AGSMapView *) mapView
{
	//Zoom to a perticular envelop
	[self  zoomToDefaultEnvelope];
	
	self.violationsFeatureLayer = [AGSFeatureLayer featureServiceLayerWithURL:[NSURL URLWithString:[CodeViolationConfigSettings violationFeatureLayerUrl]]  
                                    mode:AGSFeatureLayerModeSnapshot];
	
	self.violationsFeatureLayer.outFields = [NSArray arrayWithObject:@"*"];
	self.violationsFeatureLayer.definitionExpression = @"STATUS='Open'";
	self.violationsFeatureLayer.queryDelegate = self;
	self.violationsFeatureLayer.editingDelegate = self;	 
    
    [self.mapView addMapLayer:self.violationsFeatureLayer withName:@"ViolationsFeatureLayer"];
	
	self.objGraphicsLayer = [AGSGraphicsLayer graphicsLayer];
	[self.mapView addMapLayer:self.objGraphicsLayer withName:@"ViolationsGraphicsLayer"];
	
	self.violationsFeatureLayerQuery = [AGSQuery query];
	self.violationsFeatureLayerQuery.where = @"STATUS='Open'";
	self.violationsFeatureLayerQuery.returnGeometry = YES;
	self.violationsFeatureLayerQuery.outSpatialReference = self.mapView.spatialReference;
	self.violationsFeatureLayerQuery.outFields = [NSArray arrayWithObject:@"*"];
	
	[self performSelector:@selector(executeQueryWithCondition) withObject:nil afterDelay:2.0];
}

- (void)mapView:(AGSMapView *) mapView didClickAtPoint:(CGPoint) screen mapPoint:(AGSPoint *) mappoint graphics:(NSDictionary *) graphics 
{
	[self.objGraphicsLayer removeAllGraphics];
	self.tempGraphicsArray = [graphics valueForKey:@"ViolationsFeatureLayer"];
	if ([self.tempGraphicsArray count] > 0) {
		
		//if popover is not visible and user clicks on the map.
		if (![self.popoverController isPopoverVisible]) {
			[self.popoverController presentPopoverFromBarButtonItem:self.violationsItem permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
		}
		
		if ([self.objCodeViolationRootVC.navigationController.topViewController isKindOfClass:[CodeViolationAddViolationVC class]]) {
			CodeViolationAddViolationVC *tempController = (CodeViolationAddViolationVC*) self.objCodeViolationRootVC.navigationController.topViewController;

			if ([tempController checkForFieldChanges]) {
				[self.ClickAtPointAlert show];
			}
			else {
				[self addRingAndPushDesiredView];
			}

		}
		else if ([self.objCodeViolationRootVC.navigationController.topViewController isKindOfClass:[CodeViolationAddInspectionVC class]]){
			CodeViolationAddInspectionVC *tempController = (CodeViolationAddInspectionVC*) self.objCodeViolationRootVC.navigationController.topViewController;
			
			if ([tempController checkForFieldChanges]) {
				[self.ClickAtPointAlert show];
			}
			else {
				[self addRingAndPushDesiredView];
			}
		}

		else {
			[self addRingAndPushDesiredView];
		}
	}
	else {
		[self.popoverController dismissPopoverAnimated:YES];
	}
	
}

- (void)mapView:(AGSMapView *) mapView didTapAndHoldAtPoint:(CGPoint) screen mapPoint:(AGSPoint *) mappoint graphics:(NSDictionary *) graphics
{
	self.graphicPointNew = mappoint;
    
	if ([self.objCodeViolationRootVC.navigationController.topViewController isKindOfClass:[CodeViolationAddViolationVC class]]) {
		CodeViolationAddViolationVC *tempController = (CodeViolationAddViolationVC*) self.objCodeViolationRootVC.navigationController.topViewController;
		
		if ([tempController checkForFieldChanges]) {
			[self.tapAndHoldAlert show];
		}
		else {
			[self addRingAndPushAddNewViolationView];
		}
		
	}
	else if ([self.objCodeViolationRootVC.navigationController.topViewController isKindOfClass:[CodeViolationAddInspectionVC class]]){
		CodeViolationAddViolationVC *tempController = (CodeViolationAddViolationVC*) self.objCodeViolationRootVC.navigationController.topViewController;
		
		if ([tempController checkForFieldChanges]) {
			[self.tapAndHoldAlert show];
		}
		else {
			[self addRingAndPushAddNewViolationView];
		}
		
	}
	
	else {
		[self addRingAndPushAddNewViolationView];
	}
	
}

#pragma mark -

#pragma mark AGSFeatureLayerQueryDelegate Methods

- (void) featureLayer:(AGSFeatureLayer *) featureLayer operation:(NSOperation *) op 
didQueryFeaturesWithFeatureSet:(AGSFeatureSet *) featureSet
{
  	
	if (self.defaultSymbol == nil) {
		AGSUniqueValueRenderer *tempRenderer = (AGSUniqueValueRenderer *) featureLayer.renderer ;
		self.defaultSymbol = tempRenderer.defaultSymbol ;
	}
	
	// Make CodeViolationRootVCFieldAliasDictionary
	if ([self.objCodeViolationRootVC.violationsFieldAliasDictionary count] == 0) {
		for (AGSField *violationField in self.violationsFeatureLayer.fields) {
            
			[self.objCodeViolationRootVC.violationsFieldAliasDictionary setValue:violationField.alias forKey:violationField.name];            
		}
	}
	
		
    if (([featureSet.features count] > 0)||([featureSet.features count] == 0))
	{		
		self.objCodeViolationRootVC.violationsFeaturesArray = (NSMutableArray *)featureSet.features;
		
		[self.objCodeViolationRootVC.violationsTableView reloadData];
		
	}
    

	
	if ([self.violationsFeatureLayerDomainValues count] == 0) {
		
		
		for (int i=0; i<self.violationsFeatureLayer.fields.count; i++) {
			
			
			AGSField *violationTypeField = [self.violationsFeatureLayer.fields objectAtIndex:i];
			
			if ([violationTypeField.name isEqualToString:[CodeViolationConfigSettings violationTypeField]]) 
			{
				
				AGSField *voilationType = (AGSField *)[self.violationsFeatureLayer.fields objectAtIndex:i];
				AGSCodedValueDomain *codedDomainValues = (AGSCodedValueDomain *)voilationType.domain;
				
				for (int count = 0; count < [codedDomainValues.codedValues count]; count ++) 
				{
					AGSCodedValue *codedValue = (AGSCodedValue *) [codedDomainValues.codedValues objectAtIndex:count] ;
					[self.violationsFeatureLayerDomainValues addObject:codedValue.name];
				}
			
			}
		}
	}
		
  
	[self addObserversForZoomingAndPanning];
    
    [self.violationsFeatureLayer refresh];
    
   
    
	[self endActivityIndicator];
    
    
    //code to be executed on the main queue after delay
    
        [self.objCodeViolationSettingsVC.view setUserInteractionEnabled:TRUE];
    
    
        if ([self.objCodeViolationSettingsVC.myAlertView isVisible]) {
            
            [self.objCodeViolationSettingsVC.myAlertView dismissWithClickedButtonIndex:0 animated:0];
        }
        
    
}

- (void)featureLayer:(AGSFeatureLayer *) featureLayer operation:(NSOperation *) op didFailQueryFeaturesWithError:(NSError *) error {
    
    
    
    
    if (!alertForFail) {
        
    

	alertForFail = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ErrorTitle", @"ErrorTitle Item") 
													 message:NSLocalizedString(@"UnableToGetResult", @"UnableToGetResult Item")  
													delegate:nil 
										   cancelButtonTitle:NSLocalizedString(@"OK", @"OKTitle Item")
										   otherButtonTitles:nil] ;
	[alertForFail show];
	[alertForFail release];
	}
	[self addObserversForZoomingAndPanning];
    
   
	[self endActivityIndicator];
    
    
    if ([self.objCodeViolationSettingsVC.myAlertView isVisible]) {
        
    [self.objCodeViolationSettingsVC.myAlertView dismissWithClickedButtonIndex:0 animated:0];
        
    }
    

    
}

#pragma mark -

#pragma mark AGSFeatureLayerEditingDelegate Methods

- (void)featureLayer:(AGSFeatureLayer *) featureLayer operation:(NSOperation *) op didFeatureEditsWithResults:(AGSFeatureLayerEditResults *) editResults
{
	
	if ([editResults.addResults count] > 0) {
		
		AGSEditResult *addresult = (AGSEditResult*)[editResults.addResults objectAtIndex:0];
			        
        NSDictionary *violationGraphicNewAttributes = (NSDictionary *)self.objCodeViolationAddViolationVC.violationGraphicNew.allAttributes;
		
		NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithObjectsAndKeys:
									[NSNumber numberWithInt:addresult.objectId], @"OBJECTID",
									[NSString stringWithFormat:@"%d",addresult.objectId],@"VIOLATIONID",
									[violationGraphicNewAttributes objectForKey: @"FULLADDR"], @"FULLADDR",
									[violationGraphicNewAttributes objectForKey: @"LOCDESC"], @"LOCDESC",
									[violationGraphicNewAttributes objectForKey: @"VIOLATETYPE"], @"VIOLATETYPE",
									[violationGraphicNewAttributes objectForKey: @"VIOLATEDESC"], @"VIOLATEDESC",
									[violationGraphicNewAttributes objectForKey: @"CODE"], @"CODE",
									[violationGraphicNewAttributes objectForKey: @"VISABLE"], @"VISABLE",
									[violationGraphicNewAttributes objectForKey: @"SUBMITDT"], @"SUBMITDT",
									[violationGraphicNewAttributes objectForKey: @"STATUS"], @"STATUS",
									[violationGraphicNewAttributes objectForKey: @"LASTUPDATE"], @"LASTUPDATE",
									nil];
		
		AGSGraphic *violationGraphicNew = [AGSGraphic graphicWithGeometry:self.objCodeViolationAddViolationVC.violationGraphicNew.geometry symbol:self.objCodeViolationAddViolationVC.violationGraphicNew.symbol attributes:attributes infoTemplateDelegate:nil];
		
		self.objCodeViolationRootVC.violationGrahicNew = violationGraphicNew;

		//commit changes to featurelayer
		[self.violationsFeatureLayer applyEditsWithFeaturesToAdd: nil
														toUpdate: [NSArray arrayWithObject:violationGraphicNew]
														toDelete: nil];
		
	}
	else if ([editResults.updateResults count] > 0)
	{
		[self executeQueryWithCondition];
		
		if (self.objCodeViolationRootVC.objCodeViolationFeatureDetailsVC.objCodeViolationAddViolationVC.isEditingViolation) {
			self.objCodeViolationRootVC.objCodeViolationFeatureDetailsVC.objCodeViolationAddViolationVC.isEditingViolation = NO;
			self.objCodeViolationRootVC.objCodeViolationFeatureDetailsVC.didUpdateViolation = YES;
			AGSGraphic *tempGraphic =  self.objCodeViolationRootVC.objCodeViolationFeatureDetailsVC.selectedViolationGraphic;
			
			//Visible
			NSString *violationStatus = nil;
			if ([[tempGraphic attributeForKey:@"STATUS"]   isKindOfClass:[NSNull class]] ||
				[tempGraphic attributeForKey:@"STATUS"] == nil ||
				[[NSString stringWithFormat:@"%@", [tempGraphic attributeForKey:@"STATUS"]] isEqualToString:@""])
			{
				violationStatus = @"";
			}
			else {
				violationStatus = [tempGraphic attributeForKey:@"STATUS"];
			}	
			
			if ([violationStatus isEqualToString:@"Closed"]) {
				self.objCodeViolationRootVC.objCodeViolationFeatureDetailsVC.editViolationButton.enabled = NO;
				self.objCodeViolationRootVC.objCodeViolationFeatureDetailsVC.addInspectionButton.enabled = NO;
			}
			[self.objCodeViolationRootVC.objCodeViolationFeatureDetailsVC.violationDetailsTableView reloadData];
			[self.objCodeViolationRootVC.navigationController popViewControllerAnimated:YES];
		}
		else {
			
			// Reload CodeViolationRootVC TableView rows
			
			[self.objCodeViolationRootVC.violationsTableView reloadData];
			[self.objCodeViolationRootVC.navigationController popToRootViewControllerAnimated:YES];
		}
        
        [self.objCodeViolationSettingsVC.view setUserInteractionEnabled:TRUE];
        
        
        if ([self.objCodeViolationSettingsVC.myAlertView isVisible]) {
            
            [self.objCodeViolationSettingsVC.myAlertView dismissWithClickedButtonIndex:0 animated:0];
            
        }


	}
	
	
	[self.objGraphicsLayer removeAllGraphics];
}

- (void)featureLayer:(AGSFeatureLayer *) featureLayer operation:(NSOperation *) op 
didFailFeatureEditsWithError:(NSError *) error {
	
    
	UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ErrorTitle", @"ErrorTitle Item") 
                message:NSLocalizedString(@"RequestTimedOut", @"RequestTimedOut Item") delegate:nil
										   cancelButtonTitle:NSLocalizedString(@"OK", @"OKTitle Item")
										   otherButtonTitles:nil] ;
	[alert show];
	[alert release];	
	  
	[self endActivityIndicator];
}


#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView == self.ClickAtPointAlert) {
		switch (buttonIndex) {
			case 0:
				[self addRingAndPushDesiredView];
				break;
			case 1:
				
				break;
				
			default:
				break;
		}
	}
	else {
		switch (buttonIndex) {
			case 0:
				[self addRingAndPushAddNewViolationView];
				break;
			case 1:
				
				break;
				
			default:
				break;
		}
	}

}

#pragma mark -
#pragma mark Actions

- (void) addRingAndPushDesiredView {
	AGSGraphic *currentGraphic = [self.tempGraphicsArray objectAtIndex:([self.tempGraphicsArray count] - 1)];		
	AGSGraphic *ringGraphic = [AGSGraphic graphicWithGeometry:currentGraphic.geometry 
                                symbol:nil attributes:nil infoTemplateDelegate:nil];
	
	[self addRingForSelectedViolation:ringGraphic];
	
	if ([self.objCodeViolationRootVC.navigationController.viewControllers count] > 1) {
		if (self.objCodeViolationRootVC.navigationController.topViewController != self.objCodeViolationRootVC.objCodeViolationFeatureDetailsVC) {
			[self.objCodeViolationRootVC.navigationController popToRootViewControllerAnimated:NO];
			[self.objCodeViolationRootVC.navigationController pushViewController:self.objCodeViolationRootVC.objCodeViolationFeatureDetailsVC animated:YES];
			 
		}
		
	}
	else {
		[self.objCodeViolationRootVC.navigationController pushViewController:self.objCodeViolationRootVC.objCodeViolationFeatureDetailsVC animated:YES];
	}
	 if (![[UIApplication sharedApplication] isIgnoringInteractionEvents])
	[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
	[self.objCodeViolationRootVC reloadFeatureDetails:currentGraphic];

}

- (void) addRingAndPushAddNewViolationView {
	
	[self.objGraphicsLayer removeAllGraphics];
	
	AGSGraphic *ringGraphic = [AGSGraphic graphicWithGeometry:self.graphicPointNew 
													   symbol:nil 
												   attributes:nil 
										 infoTemplateDelegate:nil];
	
	[self addRingForSelectedViolation:ringGraphic];
	
	AGSSymbol *symbolForGraphic = nil;
	if (self.defaultSymbol != nil) {
		symbolForGraphic = self.defaultSymbol;
	}
	else {
		AGSPictureMarkerSymbol *newViolationPictureSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImage:[UIImage imageNamed:@"MapPointPin.png"]] ;	 
        
        newViolationPictureSymbol.offset = CGPointMake(8, -18);
		
		symbolForGraphic = newViolationPictureSymbol;
	}

	AGSGraphic *violationGraphicNew = [AGSGraphic graphicWithGeometry:self.graphicPointNew 
															   symbol:symbolForGraphic 
														   attributes:nil
												 infoTemplateDelegate:nil];
	
	[self.objGraphicsLayer addGraphic:violationGraphicNew];
	 
	
	if (self.objCodeViolationAddViolationVC == nil) {
		
		self.objCodeViolationAddViolationVC = [[CodeViolationAddViolationVC alloc] initWithNibName:@"CodeViolationAddViolationVC" bundle:nil];
		
	}
	
	if ([self.objCodeViolationRootVC.navigationController.viewControllers count] > 1) 
	{
		
		if(self.objCodeViolationRootVC.navigationController.topViewController != self.objCodeViolationAddViolationVC)
		{
			[self.objCodeViolationRootVC.navigationController popToRootViewControllerAnimated:NO];
			[self.objCodeViolationRootVC.navigationController pushViewController:self.objCodeViolationAddViolationVC animated:YES];
			
			self.objCodeViolationAddViolationVC.isEditingViolation = NO;
			[self.objCodeViolationAddViolationVC clearViolationsFields];
			
			self.objCodeViolationAddViolationVC.violationTypeDomainValues = self.violationsFeatureLayerDomainValues;
			[self.objCodeViolationAddViolationVC.violationTypePicker reloadAllComponents];
			
			NSDate *currentDate = [NSDate date];
			NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
			[dateFormatter setDateFormat:@"MMM dd yyyy"];
			self.objCodeViolationAddViolationVC.actionsheetSubmitDatePicker.maximumDate = [NSDate date];
			self.objCodeViolationAddViolationVC.submittedDateLabel.text = [dateFormatter stringFromDate:currentDate];
			self.objCodeViolationAddViolationVC.submittedViolationTypeLabel.text = [self.violationsFeatureLayerDomainValues objectAtIndex:0];
			[self.objCodeViolationAddViolationVC.violationTypePicker selectRow:0 inComponent:0 animated:NO];
			
			self.objCodeViolationAddViolationVC.currentMapPoint = self.graphicPointNew;
			
			[dateFormatter release];
		}
	}
	else {
		
		[self.objCodeViolationRootVC.navigationController pushViewController:self.objCodeViolationAddViolationVC animated:YES];
		
		self.objCodeViolationAddViolationVC.isEditingViolation = NO;
		[self.objCodeViolationAddViolationVC clearViolationsFields];
		
		self.objCodeViolationAddViolationVC.violationTypeDomainValues = self.violationsFeatureLayerDomainValues;
		[self.objCodeViolationAddViolationVC.violationTypePicker reloadAllComponents];
		
		NSDate *currentDate = [NSDate date];
		
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"MMM dd yyyy"];
		self.objCodeViolationAddViolationVC.actionsheetSubmitDatePicker.maximumDate = [NSDate date];
		self.objCodeViolationAddViolationVC.submittedDateLabel.text = [dateFormatter stringFromDate:currentDate];
		self.objCodeViolationAddViolationVC.submittedViolationTypeLabel.text = [self.violationsFeatureLayerDomainValues objectAtIndex:0];
		[self.objCodeViolationAddViolationVC.violationTypePicker selectRow:0 inComponent:0 animated:NO];		
		
		self.objCodeViolationAddViolationVC.currentMapPoint = self.graphicPointNew;
		
		[dateFormatter release];
	}
	
	//if popover is not visible and user clicks on the map.
	if (![self.popoverController isPopoverVisible]) {
		[self.popoverController presentPopoverFromBarButtonItem:self.violationsItem permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
	}
		
}

-(void)hidePopoverController {

	//if popover is not visible and user clicks on the map.
	if (![self.popoverController isPopoverVisible]) {
        
		[self.popoverController presentPopoverFromBarButtonItem:self.violationsItem permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
	}
	else {
		[self.popoverController dismissPopoverAnimated:YES];
	}

}

- (void) executeQueryWithCondition { 

    
    self.progressLabel.text = NSLocalizedString(@"LoadingViolations",@"LoadingViolations Item");
    
    [self beginActivityIndicator];
	
	if (self.mapView.visibleArea.envelope!=nil) {
		self.violationsFeatureLayerQuery.geometry = self.mapView.visibleArea.envelope;
	}
	
	[self.violationsFeatureLayer queryFeatures:self.violationsFeatureLayerQuery];
}

-(void) addObserversForZoomingAndPanning {
     
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToZooming:)
                                name:AGSMapViewDidEndZoomingNotification object: self.mapView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToPanning:)
                                name:AGSMapViewDidEndPanningNotification object: self.mapView];
}

-(void) removeObservers {
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToZooming:)
                                name:AGSMapViewDidEndZoomingNotification object: self.mapView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToPanning:)
                                name:AGSMapViewDidEndPanningNotification object: self.mapView];
    
}

- (void)respondToZooming:(NSNotification *)notification  {
	[self removeObservers];
    
	[self executeQueryWithCondition];		
}

- (void)respondToPanning:(NSNotification *)notification {
	[self removeObservers];
    
	[self executeQueryWithCondition];
	
}

-(IBAction)GPSButtonClicked {		
	
    if (mapView.locationDisplay.dataSourceStarted) {
        
        [self.mapView.locationDisplay stopDataSource];
        [self.GPSButton setImage:[UIImage imageNamed:@"GPS_Off.png"] forState:UIControlStateNormal];
        [self removeObserver];
    }
    else
    {
	[self.GPSButton setImage:[UIImage imageNamed:@"GPS_On.png"] forState:UIControlStateNormal];
          
    [self registerAsObserver];
    
    [self.mapView.locationDisplay startDataSource];
    }
}

-(IBAction)showSettings {
	
	[UIView commitAnimations];
    
	if (self.objCodeViolationSettingsVC == nil) {
		self.objCodeViolationSettingsVC = [[CodeViolationSettingsVC alloc] initWithNibName:@"CodeViolationSettingsVC" bundle:nil];
	}
    
	UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:self.objCodeViolationSettingsVC];
    	self.settingsPopoverController= popover;
	self.objCodeViolationSettingsVC.objCodeViolationMapVC = self;
	self.settingsPopoverController.delegate =self;
	[self.settingsPopoverController presentPopoverFromRect:self.settingsButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
		
}

-(IBAction)showAboutUs {
	
	if(self.objCodeViolationAboutUsVC== nil)
	{
		self.objCodeViolationAboutUsVC = [[CodeViolationAboutUsVC alloc] initWithNibName:@"CodeViolationAboutUsVC" bundle:nil];
	}
	
	self.objCodeViolationAboutUsVC.title = @"About";
	self.objCodeViolationAboutUsVC.url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"About" ofType:@"htm"] isDirectory:NO];
	self.objCodeViolationAboutUsVC.modalPresentationStyle = UIModalPresentationFormSheet;
	self.objCodeViolationAboutUsVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	[self presentModalViewController:self.objCodeViolationAboutUsVC animated:YES];
}

-(void)addRingForSelectedViolation:(AGSGraphic *)selectedViolationGraphic {
	
	
	AGSPictureMarkerSymbol *ringSymbol = [[AGSPictureMarkerSymbol alloc] initWithImage:[UIImage imageNamed:@"RedRing.png"]] ;
	
	[selectedViolationGraphic setSymbol:ringSymbol];
	
	[self.objGraphicsLayer addGraphic:selectedViolationGraphic];
	
	[self.mapView centerAtPoint:(AGSPoint *)selectedViolationGraphic.geometry animated:YES];
	
	[ringSymbol release];
	
	return;
}


#pragma mark - GPS methods
- (void)registerAsObserver {
    [self.mapView.locationDisplay addObserver:self
                                    forKeyPath:@"location" options:(NSKeyValueObservingOptionNew) context:NULL];
}
- (void)removeObserver {
     [self.mapView.locationDisplay removeObserver:self forKeyPath:@"location"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqual:@"location"]) {
        
        
        if([self.currentBaseMapServiceLayer.fullEnvelope containsPoint:[self.mapView.locationDisplay mapLocation]])
        {
            
            AGSEnvelope *currentLocationEnvelope = [AGSEnvelope envelopeWithXmin:([self.mapView.locationDisplay mapLocation].envelope.xmin - 15000.0) ymin:([self.mapView.locationDisplay mapLocation].envelope.ymin - 15000.0) xmax:([self.mapView.locationDisplay mapLocation].envelope.xmax + 15000.0) ymax:([self.mapView.locationDisplay mapLocation].envelope.ymax + 15000.0)	spatialReference:self.mapView.spatialReference];
            [self.mapView zoomToEnvelope:currentLocationEnvelope animated:YES];
        }
        else{
        	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:NSLocalizedString(@"PointOutsideMapExtent", @"PointOutsideMapExtent Item")
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OKTitle", @"OKTitle Item")
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
            
             [self.mapView.locationDisplay stopDataSource];
            [self.GPSButton setImage:[UIImage imageNamed:@"GPS_Off.png"] forState:UIControlStateNormal];
            [self removeObserver];
            
        }
    }
  }  


#pragma mark -

#pragma mark activity indicator

-(void)beginActivityIndicator {
	  
	[self.activityIndicator startAnimating];
	self.activityIndicator.hidden = NO;
	self.progressLabel.hidden = NO;
    
    if (![[UIApplication sharedApplication] isIgnoringInteractionEvents]) {
    
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    }
    
}

-(void)endActivityIndicator {
    
    
    [((CodeViolationAppDelegate *)[[UIApplication sharedApplication ]delegate]).activityAlertViewInspection dismissWithClickedButtonIndex:0 animated:YES];
    
    [((CodeViolationAppDelegate *)[[UIApplication sharedApplication ]delegate]).activityAlertView dismissWithClickedButtonIndex:0 animated:YES];
    
	[self.activityIndicator stopAnimating];
	self.activityIndicator.hidden = YES;
	self.progressLabel.hidden = YES;
	
	if ([[UIApplication sharedApplication] isIgnoringInteractionEvents]) {
                
		[[UIApplication sharedApplication] endIgnoringInteractionEvents];
	}
}


#pragma mark -
#pragma mark Split view support

- (void)splitViewController: (UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController 
		  withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc {
    
    barButtonItem.title = [CodeViolationConfigSettings panelTitle];
	self.violationsItem = barButtonItem;	
	[self.violationsItem setTarget:self];
	[self.violationsItem setAction:@selector(hidePopoverController)];
    NSMutableArray *items = [[toolbar items] mutableCopy];
    [items insertObject:barButtonItem atIndex:0];
    [toolbar setItems:items animated:YES];
    [items release];
    self.popoverController = pc;
	self.popoverController.passthroughViews = [NSArray arrayWithObject:self.view];
}


// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController: (UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController 
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    
    NSMutableArray *items = [[toolbar items] mutableCopy];
    [items removeObjectAtIndex:0];
    [toolbar setItems:items animated:YES];
    [items release];
    self.popoverController = nil;
}

#pragma mark -
#pragma mark Rotation support

// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	if ([self.settingsPopoverController isPopoverVisible]) {
		[self.settingsPopoverController dismissPopoverAnimated:YES];
	}
}

#pragma mark -
#pragma mark Memory management

-(void)viewDidUnload {
	
	self.toolbar = nil;
	self.popoverController = nil;
	self.detailItem = nil;
	self.mapView = nil;
	self.parcelMapServiceLayer = nil;
	self.hybridMapServiceLayer = nil;
	self.currentBaseMapServiceLayer = nil;
	self.violationsFeatureLayer = nil;
	self.parcelMapView = nil;
	self.hybridMapView = nil;
	self.violationsFeatureLayerView = nil;
	self.window = nil;
	self.networkDisconnectionVC = nil;
	self.violationsFeatureLayerQuery = nil;
	self.objGraphicsLayer = nil;
	self.settingsButton = nil;
	self.GPSButton = nil;
	self.locationManager = nil;
	self.settingsPopoverController = nil;
	self.objCodeViolationSettingsVC = nil;
	self.objCodeViolationAboutUsVC = nil;
	self.objCodeViolationRootVC = nil;
	self.violationsFeatureLayerDomainValues = nil;
	self.objCodeViolationAddViolationVC = nil;
	self.violationsItem = nil;
	self.progressLabel = nil;
	self.activityIndicator = nil;
	
	[super viewDidUnload];
}

- (void)dealloc {
	
	[self.toolbar release];
	[self.popoverController release];
	[self.detailItem release];
	[self.mapView release];
	[self.parcelMapServiceLayer release];
	[self.hybridMapServiceLayer release];
	[self.currentBaseMapServiceLayer release];
	[self.violationsFeatureLayer release];
	[self.parcelMapView release];
	[self.hybridMapView release];
	[self.violationsFeatureLayerView release];
	[self.window release];
	[self.networkDisconnectionVC release];
	[self.violationsFeatureLayerQuery release];
	[self.objGraphicsLayer release];
	[self.settingsButton release];
	[self.GPSButton release];
	[self.locationManager release];
	[self.settingsPopoverController release];
	[self.objCodeViolationSettingsVC release];
	[self.objCodeViolationAboutUsVC release];
	[self.objCodeViolationRootVC release];
	[self.violationsFeatureLayerDomainValues release];
	[self.objCodeViolationAddViolationVC release];
	[self.violationsItem release];
	[self.progressLabel release];
	[self.activityIndicator release];
	
    [super dealloc];
}

#pragma mark -


@end
