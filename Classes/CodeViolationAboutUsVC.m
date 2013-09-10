//
//  CViolationAboutUsViewController.m
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

#import "CodeViolationAboutUsVC.h"


@implementation CodeViolationAboutUsVC

@synthesize webView, url, activityIndicator;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.webView.backgroundColor= [UIColor blackColor];
	self.webView.opaque = NO;
	
	if(self.url!= nil)
	{
		[self.activityIndicator startAnimating];
		NSURLRequest *req=[NSURLRequest requestWithURL:self.url];
		[self.webView loadRequest:req];
	}

}


-(void) viewWillAppear:(BOOL)animated {
	self.webView.delegate = self;
	[self.webView stringByEvaluatingJavaScriptFromString:@"window.scrollTo(0,0)"];
	
	if(self.url!= nil)
	{
		[self.activityIndicator startAnimating];
		NSURLRequest *req=[NSURLRequest requestWithURL:self.url];
		[self.webView loadRequest:req];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}

#pragma mark -
#pragma mark UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
	[self.activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView { 
	[self.activityIndicator stopAnimating];	
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
	if ([self.activityIndicator isAnimating]) {
		[self.activityIndicator stopAnimating];
	}
}

#pragma mark -
#pragma mark IBAction

- (IBAction) dismissAboutUs:(id)sender
{
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark Memory Management

-(void)viewDidUnload {
	
	self.webView = nil;
	self.url = nil;
	self.activityIndicator = nil;
	
	[super viewDidUnload];
}

- (void)dealloc {
    [super dealloc];
	[self.webView release];
	[self.activityIndicator release];
	[self.url release];
}

#pragma mark -

@end
