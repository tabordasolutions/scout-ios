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
//
//  MarkupTileLayer.m
//  SCOUT
//
//

#import "MarkupTileLayer.h"

@implementation MarkupTileLayer

-(MarkupTileLayer*) init
{
	self = [super init];
	_threadNames = [[NSMutableArray alloc] init];
	return self;
}

-(void) drawFirelineFeature:(MarkupFireline *)fireline withProjection:(MarkupTileProjection *)proj
{
	CLLocationCoordinate2D *points = fireline.featurePoints;
	
	int pointCount = fireline.featurePointsCount;
	int size = pointCount * 2;
	float floatPoints[size];
	memset(floatPoints, 0, size * sizeof(float));
	
	for(int i = 0; i < pointCount; i++)
	{
		CGPoint pointPx = [proj latLngToPoint: points[i]];
		
		floatPoints[i*2] = pointPx.x;
		floatPoints[i*2 + 1] = pointPx.y;
	}
	NSString *dashStyle = fireline.dashStyle;
	
	UIBezierPath *path = [UIBezierPath bezierPath];
	
	
	//Default to black
	[[UIColor blackColor] set];
	
	if([dashStyle isEqualToString:@"primary-fire-line"])
	{
		//Add the line itself to the path
		[MarkupFireline addLine:floatPoints pathPtLen:size ToPath:path];
		[path setLineCapStyle:kCGLineCapSquare];
		[path setLineWidth:2.0];
		CGFloat dashes[] = {0, 8};
		[path setLineDash:dashes count:2 phase:0];
		
		[path stroke];
	}
	else if([dashStyle isEqualToString:@"secondary-fire-line"])
	{
		//Add the line itself to the path
		[MarkupFireline addLine:floatPoints pathPtLen:size ToPath:path];
		[path setLineCapStyle:kCGLineCapRound];
		CGFloat dashes[] = {0, 8};
		[path setLineDash:dashes count:2 phase:0];
		
		[path stroke];
	}
	else if([dashStyle isEqualToString:@"proposed-dozer-line"])
	{
		//X dot X dot
		//markupStyle values:
		//0: uncontrolled fireline barbs
		//1: 'x'
		//2: 'X'
		//3: dots
		[MarkupFireline addAdvancedStyling:floatPoints pathPtLen:size path:path markupStyle:2 markupSpacing:20.0f markupOfs:0.0f];
		[MarkupFireline addAdvancedStyling:floatPoints pathPtLen:size path:path markupStyle:3 markupSpacing:20.0f markupOfs:10.0f];
		[path setLineCapStyle: kCGLineCapRound];
		[path setLineWidth:2.0];
		
		[path stroke];
	}
	else if([dashStyle isEqualToString:@"completed-dozer-line"])
	{
		//x x x x
		[MarkupFireline addAdvancedStyling:floatPoints pathPtLen:size path:path markupStyle:1 markupSpacing:13.0f markupOfs:0.0f];
		[path setLineCapStyle: kCGLineCapRound];
		[path setLineWidth:2.0];
		
		[path stroke];
	}
	else if([dashStyle isEqualToString:@"fire-edge-line"])
	{
		//barb barb barb
		//Add the line itself to the path
		[MarkupFireline addLine:floatPoints pathPtLen:size ToPath:path];
		[MarkupFireline addAdvancedStyling:floatPoints pathPtLen:size path:path markupStyle:0 markupSpacing:10.0f markupOfs:0.0f];
		[[UIColor redColor] set];
		[path setLineWidth:2.0];
		
		[path stroke];
	}
	else if ([dashStyle isEqualToString:@"action-point"])
	{
		//Add the line itself to the path
		[MarkupFireline addLine:floatPoints pathPtLen:size ToPath:path];
		
		//Drawing a thick black border
		[path setLineWidth:6.0];
		[path stroke];
		
		
		//Drawing a thin orange line
		[path setLineWidth:4.0f];
		[[UIColor colorWithRed:1.0f green:0.639216f blue:0.0f alpha:1.0f] set];
		[path stroke];
		
		//Adding two large circles at the start and end of the line
		CGContextRef context = UIGraphicsGetCurrentContext();
		float diameter = 10.0f;
		CGContextSetRGBFillColor(context, 1.0f, 0.639216f, 0.0f, 1.0f);
		CGPoint start = CGPointMake(floatPoints[0] - 0.5*diameter, floatPoints[1] - 0.5*diameter);
		CGContextFillEllipseInRect(context, CGRectMake(start.x,start.y,diameter,diameter));
		
		CGPoint end = CGPointMake(floatPoints[size - 2] - 0.5*diameter, floatPoints[size - 1] - 0.5*diameter);
		CGContextFillEllipseInRect(context,  CGRectMake(end.x,end.y,diameter,diameter));
	}

	
	[path stroke];
}

-(void) requestTileForX:(NSUInteger)x y:(NSUInteger)y zoom:(NSUInteger)zoom receiver:(id<GMSTileReceiver>)receiver
{
	//==================================================================
	//         Debug code to see how many threads are being used
	//==================================================================
	
	NSString *threadName = [[NSThread currentThread] description];
	
	//Add a new thread to the list of threads
	bool isNew = true;
	for(NSString *s in _threadNames)
	{
		if(s != NULL && [s isEqualToString:threadName])
		{
			isNew = false;
			break;
		}
	}

	if(isNew)
	{
		[_threadNames addObject:threadName];
		//NSLog(@"New thread detected: %@\n",threadName);
	}
	
	NSLog(@"Request tile for x ran on the %@ thread (X: %d, Y: %d, zoom: %d)\n",threadName,(int)x,(int)y,(int)zoom);
	NSLog(@"Total unique threads: %d\n",(int)[_threadNames count]);
	
	
	//Luis Notes:
	// So the reason I debugged how many unique threads this method is called on above is that:
	// On Android, the equivalent method of this is only called on a set specific threads (10 unique threads)
	// On Android, each of these 10 threads has 1 image allocated at the app startup (technically at the first map render call)
	// Hence, Android reuses 10 images over and over again for drawing ALL of the markup
	// This is pretty efficient, and I wanted to check how threads are handled on iOS to see if this same optimization could be done on iOS
	// Apparently, however, iOS calls this method on any number of threads (the unique thread count continues to rise the more tiles you cause to be drawn)
	// Given this info, I'm not too sure how we might be able to use, say 10 UIImages, and reuse them over and over again, like on Android
	// However, on-iOS-device testing should tell us whether this is even required or not... because the current set up (creating and caching many UIImages)
 	// might not even be that resource intensive (on-device testing is required to reach a conclusion)
	
	
	//==================================================================
	//               Setting up the tile image to draw
	//==================================================================
	
	//Starting the image contex with a specified size
	CGSize size = CGSizeMake(self.tileSize, self.tileSize);
	UIGraphicsBeginImageContextWithOptions(size, NO, 1.0f);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	MarkupTileProjection *tileProj = [[MarkupTileProjection alloc] initWithTileSize:self.tileSize x:x y:y zoom:zoom];

	
	//==================================================================
	//                      Drawing a debug grid
	//==================================================================
	
	//Drawing a black 10px x 10px grid
	CGContextSetRGBStrokeColor(context, 0.0f, 0.0f, 0.0f, 0.2f);
	CGContextSetLineWidth(context, 1.0f);
	for(int i = 0; i < self.tileSize; i += 10)
	{
		CGContextMoveToPoint(context, i, 0);
		CGContextAddLineToPoint(context, i, self.tileSize);
		
		CGContextMoveToPoint(context, 0, i);
		CGContextAddLineToPoint(context, self.tileSize, i);
	}
	//This draws the current path, and clears the current path
	CGContextStrokePath(context);
	
	//Drawing a thicker blue border around each tile image
	CGContextSetRGBStrokeColor(context, 0.0f, 0.0f, 1.0f, 1.0f);
	CGContextSetLineWidth(context, 5.0f);
	CGContextMoveToPoint(context, 0, 0);
	CGContextAddLineToPoint(context, self.tileSize, 0);
	CGContextAddLineToPoint(context, self.tileSize, self.tileSize);
	CGContextAddLineToPoint(context, 0, self.tileSize);
	CGContextAddLineToPoint(context, 0, 0);

	//This draws the current path, and clears the current path
	CGContextStrokePath(context);
	
	
	//==================================================================
	//                       Drawing the firelines
	//==================================================================
	if(_firelinesMarkup != NULL)
	{
		
		NSLog(@"Drawing %d fireline features\n",(int)[_firelinesMarkup.firelineFeatures count]);
		
		for (MarkupFireline *feature in _firelinesMarkup.firelineFeatures)
		{
			[self drawFirelineFeature:feature withProjection:tileProj];
		}
	}
	
	//==================================================================
	//                  Finishing up the tile rendering
	//==================================================================
	
	//Getting the UIImage and returning it to the receiver
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	[receiver receiveTileWithX:x y:y zoom:zoom image:image];
}

@end
