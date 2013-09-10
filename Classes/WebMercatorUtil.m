//
//  WebMercatorUtil.m
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


#import "WebMercatorUtil.h"


@implementation WebMercatorUtil

+ (double)toWebMercatorY:(double)latitude
{
	double originShift = 2.0f * M_PI * 6378137 / 2.0f; 
	float mercatorY = log(tan((90.0f + latitude) * M_PI / 360.0f)) / (M_PI / 180.0f); 
	mercatorY = mercatorY * originShift / 180.0f;
	return mercatorY;	
}


+ (double)toWebMercatorX:(double)longitude
{
	double originShift = 2.0f * M_PI * 6378137 / 2.0f; 
	double mercatorX = longitude * originShift / 180.0f; 
	return mercatorX;
}
@end
