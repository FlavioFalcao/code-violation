//
//  NetworkDisconnectionVC.m
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


#import "NetworkDisconnectionVC.h"
#import "CodeViolationAppDelegate.h"


@implementation NetworkDisconnectionVC

@synthesize noConfigFound, data, urlRequest, urlConnection, failParsingXml;

-(void) viewDidAppear:(BOOL)animated
{
    if (self.noConfigFound) {
		
		NSString *configPath = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"ConfigFileURL"];
		
		self.data = [[NSMutableData data] retain];
		NSURL *baseUrl = [NSURL URLWithString:configPath];
		self.urlRequest = [[NSURLRequest alloc] initWithURL:baseUrl];
		self.urlConnection = [[NSURLConnection alloc] initWithRequest:self.urlRequest delegate:self];
		[self.urlConnection start];
	}
	else {		 
        [self showAlert];
        
	}

}
-(void) viewWillAppear:(BOOL)animated {
	
	
}


-(void)showAlert {
	alertMsg = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ErrorTitle", @"ErrorTitle Item")  message:NSLocalizedString(@"ConnectionErrorAlert1", @"ConnectionErrorAlert1 Item") delegate: self
                                cancelButtonTitle:@"Retry" otherButtonTitles:@"Close",nil] ;
	
	[alertMsg show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        // Reload again this View
        
        CodeViolationAppDelegate *appDelegate= (CodeViolationAppDelegate *)[[UIApplication sharedApplication] delegate];
                
        [appDelegate retryInternetConnection];
    }
    else
    {
        // Kill the application
        exit(0);
    }
    
}


-(void) showNoConfigAlert{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:YES forKey:@"NoConfigFound"];
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ErrorTitle", @"ErrorTitle Item")
                    message:NSLocalizedString(@"CheckConfigURL", @"CheckConfigURL Item") delegate:nil
                    cancelButtonTitle:NSLocalizedString(@"OK", @"OKTitle Item") otherButtonTitles:nil];
    
	[alertView show];
	[alertView release];
	
	self.failParsingXml = YES;
	[self.urlConnection cancel];
}

#pragma mark -
#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response { 
	
	[self.data setLength:0];
	
	NSHTTPURLResponse * httpResponse;
    
    httpResponse = (NSHTTPURLResponse *) response;
	
	if (httpResponse.statusCode == 403 || httpResponse.statusCode == 404) {
		[self performSelector:@selector(showNoConfigAlert) withObject:nil afterDelay:1.0];
		
		self.failParsingXml = YES;
		[self.urlConnection cancel];
		
	}
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	//[self.data appendData:data] ;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	[self performSelector:@selector(showNoConfigAlert) withObject:nil afterDelay:1.0];
	self.failParsingXml = YES;
	[self.urlConnection cancel];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // Once this method is invoked, "responseData" contains the complete result
	
	if (self.failParsingXml == NO) {
        
        alertMsg = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ErrorTitle", @"ErrorTitle Item")  message:NSLocalizedString(@"ConnectionErrorAlert1", @"ConnectionErrorAlert Item") delegate: self
                                    cancelButtonTitle:@"Retry" otherButtonTitles:@"Close",nil] ;
        
        [alertMsg show];
	}
	
}

#pragma mark Rotation support

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}

#pragma mark -

#pragma mark Memory Management

-(void)viewDidUnload {
	
	self.data = nil;
	self.urlRequest = nil;
	self.urlConnection = nil;
	
	[super viewDidUnload];
}

-(void)dealloc {
	
	[self.data release];
	[self.urlRequest release];
	[self.urlConnection release];
	
	[super dealloc];
}

#pragma mark -

@end
