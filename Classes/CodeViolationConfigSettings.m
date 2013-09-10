//
//  CodeViolationConfigSettings.m
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


#import "CodeViolationConfigSettings.h"


@interface CodeViolationConfigSettings(Private)
// these are private methods that outside classes need not use
+ (void)setupCodeViolationConfigSettings;
//static NSDictionary *configDict = nil;
@end

static NSDictionary *configDict = nil;
@implementation CodeViolationConfigSettings

static CodeViolationConfigSettings *sharedCodeViolationConfigSettingsInstance = nil;

+ (CodeViolationConfigSettings*)sharedCodeViolationConfigSettings {
    @synchronized(self) {
        if (sharedCodeViolationConfigSettingsInstance == nil) {
            sharedCodeViolationConfigSettingsInstance = [[self alloc] init];
        }
    }
    return sharedCodeViolationConfigSettingsInstance;
}

- init {
	if( self = [super init]) {     //this id for the xml validation
		
		[CodeViolationConfigSettings setupCodeViolationConfigSettings];
	}
	return self;
}

+ (void)setupCodeViolationConfigSettings {
	
	NSString *configFileURL = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"ConfigFileURL"];
	configDict = [[NSMutableDictionary alloc] initWithContentsOfURL:[NSURL URLWithString:configFileURL]];
}

+ (NSArray *)getDefaultMapExtent {
	NSArray *defaultExtentArray = [[configDict valueForKey:@"DefaultExtent"] componentsSeparatedByString:@","];
	return defaultExtentArray;
}

+ (NSString*)parcelBaseMapUrl {
    return [configDict objectForKey:@"ParcelBaseMapURL"];
}

+ (NSString*)hybridBaseMapUrl {
    return [configDict objectForKey:@"HybridBaseMapURL"];
}
+ (NSString*)violationFeatureLayerUrl{
	return [configDict objectForKey:@"ViolationFeatureLayerURL"];
}

+ (NSString *)inspectionFeatureLayerUrl {
	return [configDict objectForKey:@"InspectionFeatureLayerURL"];
}

+ (NSString *)violationsMapServerUrl {
	return [configDict objectForKey:@"ViolationsMapServerURL"];
}

+ (NSString *)violationsFeatureLayerId {
	return [configDict objectForKey:@"ViolationsFeatureLayerId"];
}

+ (NSString*)panelTitle {
	return [configDict objectForKey:@"SummaryPanelTitle"];
}

+ (NSString*)locatorUrl {
    
    return @"http://tasks.arcgisonline.com/ArcGIS/rest/services/Locators/TA_Address_NA_10/GeocodeServer";
	return [configDict objectForKey:@"Locator"];
}

+ (NSString*)locatorFields {
	return [configDict objectForKey:@"LocatorFields"];
}

+ (NSString *)ExpandFactorForSearch{
	return [configDict objectForKey:@"ZoomFactor"];
}

+ (NSArray *)violationDetailsDisplayFields {
	return[configDict objectForKey:@"ViolationDetailsDisplayFields"];	
}

+ (NSArray *)inspectionDetailsDisplayFields {
	return[configDict objectForKey:@"InspectionDetailsDisplayFields"];	
}

+(NSArray*)violationsDisplayFields{
	return[configDict objectForKey:@"ViolationsDisplayFields"];
}

+ (NSString *)violationTypeField {
	return[configDict objectForKey:@"ViolationTypeField"];		
}

+ (NSString *)statusField {
	return[configDict objectForKey:@"StatusField"];	
}

+(int) configDictCount {
	return [configDict count];
}


@end
