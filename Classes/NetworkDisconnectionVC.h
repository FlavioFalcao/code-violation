//
//  NetworkDisconnectionVC.h
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


#import <UIKit/UIKit.h>
#import "CodeViolationConfigSettings.h"


@interface NetworkDisconnectionVC : UIViewController<UIAlertViewDelegate> {
	
	BOOL noConfigFound;
	NSMutableData *data;
	NSURLRequest *urlRequest;
	NSURLConnection *urlConnection;
	BOOL failParsingXml;
    
     UIAlertView *alertMsg;
	
}

@property (nonatomic,assign) BOOL noConfigFound;

@property(nonatomic,retain) NSMutableData *data;
@property(nonatomic,retain) NSURLRequest *urlRequest;
@property(nonatomic,retain) NSURLConnection *urlConnection;
@property(nonatomic,assign) BOOL failParsingXml;

-(void) showAlert;
-(void) showNoConfigAlert;

@end
