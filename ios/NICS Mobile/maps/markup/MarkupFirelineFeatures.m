/*|~^~|Copyright (c) 2008-2016, Massachusetts Institute of Technology (MIT)
 |~^~|All rights reserved.
 |~^~|
 |~^~|Redistribution and use in source and binary forms, with or without
 |~^~|modification, are permitted provided that the following conditions are met:
 |~^~|
 |~^~|-1. Redistributions of source code must retain the above copyright notice, this
 |~^~|ist of conditions and the following disclaimer.
 |~^~|
 |~^~|-2. Redistributions in binary form must reproduce the above copyright notice,
 |~^~|this list of conditions and the following disclaimer in the documentation
 |~^~|and/or other materials provided with the distribution.
 |~^~|
 |~^~|-3. Neither the name of the copyright holder nor the names of its contributors
 |~^~|may be used to endorse or promote products derived from this software without
 |~^~|specific prior written permission.
 |~^~|
 |~^~|THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 |~^~|AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 |~^~|IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 |~^~|DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 |~^~|FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 |~^~|DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 |~^~|SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 |~^~|CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 |~^~|OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 |~^~|OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.\*/
/**
 *
 */
//
//  MarkupFirelineFeatures.m
//  nics_iOS
//
//

#import "MarkupFirelineFeatures.h"

@implementation MarkupFirelineFeatures

- (id) initWithFeatures:(NSArray*)features
{
	NSLog(@"Feature being created\n");
	self = [super init];
	
	NSMutableArray *featureList = [[NSMutableArray alloc] init];
	
	//Calculating the LatLng points of the feature
	for(MarkupFeature* feature in features)
	{
		NSMutableArray *points = [feature getCLPointsArray];
		CLLocationCoordinate2D markerLocation;
		
		NSMutableArray *latLngPoints = [[NSMutableArray alloc] init];
		
		for(int i = 0; i < points.count; i++)
		{
			id pointLatLng = points[i];
			[pointLatLng getValue:&markerLocation];
			
			CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(markerLocation.latitude, markerLocation.longitude);
			[latLngPoints addObject:[NSValue valueWithBytes:&coord objCType:@encode(CLLocationCoordinate2D)]];
		}
		
		[featureList addObject:[[MarkupFireline alloc] initWithPoints:latLngPoints AndFeature:feature]];
	}
	
	
	_firelineFeatures = featureList;
	
	NSLog(@"Feature finished being created\n");

	return self;
}


@end
