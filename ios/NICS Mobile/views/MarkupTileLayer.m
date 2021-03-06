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
	return self;
}

-(void) drawFirelineFeature:(MarkupFireline *)fireline withProjection:(MarkupTileProjection *)proj
{
	int pointCount = (int) [fireline.featurePoints count];
	int size = pointCount * 2;
	float floatPoints[size];
	memset(floatPoints, 0, size * sizeof(float));
	
	int i = 0;
	for(NSValue *coord in fireline.featurePoints)
	{
		CLLocationCoordinate2D latLngCoord;
		[coord getValue:&latLngCoord];
		CGPoint pointPx = [proj latLngToPoint:latLngCoord];
		
		floatPoints[i++] = pointPx.x;
		floatPoints[i++] = pointPx.y;
	}

	NSString *dashStyle = fireline.feature.dashStyle;
	
	UIBezierPath *path = [UIBezierPath bezierPath];
	
	
	//Default to black
	[[UIColor blackColor] set];
	
	if([dashStyle isEqualToString:@"primary-fire-line"])
	{
		//Add the line itself to the path
		[MarkupFireline addLine:floatPoints pathPtLen:size ToPath:path];
		[path setLineCapStyle:kCGLineCapSquare];
		[path setLineWidth:16.0];
		CGFloat dashes[] = {0, 40};
		[path setLineDash:dashes count:2 phase:0];
		
		[path stroke];
	}
	else if([dashStyle isEqualToString:@"secondary-fire-line"])
	{
		//Add the line itself to the path
		[MarkupFireline addLine:floatPoints pathPtLen:size ToPath:path];
		[path setLineCapStyle:kCGLineCapRound];
		[path setLineWidth:16.0];
		CGFloat dashes[] = {0, 40};
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
		[MarkupFireline addAdvancedStyling:floatPoints pathPtLen:size path:path markupStyle:2 markupSpacing:80.0f markupOfs:0.0f];
		[MarkupFireline addAdvancedStyling:floatPoints pathPtLen:size path:path markupStyle:3 markupSpacing:80.0f markupOfs:40.0f];
		[path setLineCapStyle: kCGLineCapRound];
		[path setLineWidth:8.0];
		
		[path stroke];
	}
	else if([dashStyle isEqualToString:@"completed-dozer-line"])
	{
		//x x x x
		[MarkupFireline addAdvancedStyling:floatPoints pathPtLen:size path:path markupStyle:1 markupSpacing:40.0f markupOfs:0.0f];
		[path setLineCapStyle: kCGLineCapRound];
		[path setLineWidth:8.0];
		
		[path stroke];
	}
	else if([dashStyle isEqualToString:@"fire-edge-line"])
	{
		//barb barb barb
		//Add the line itself to the path
		[MarkupFireline addLine:floatPoints pathPtLen:size ToPath:path];
		//Stroke the line itself
		[[UIColor redColor] set];
		[path setLineWidth:8.0];
		
		[path stroke];
		
		//Clear the line and add the barbs to draw them at a thinner thickness
		[path removeAllPoints];
		[MarkupFireline addAdvancedStyling:floatPoints pathPtLen:size path:path markupStyle:0 markupSpacing:20.0f markupOfs:0.0f];
		[path setLineWidth:4.0];
		[path stroke];
		
	}
	else if ([dashStyle isEqualToString:@"action-point"])
	{
		//Add the line itself to the path
		[MarkupFireline addLine:floatPoints pathPtLen:size ToPath:path];
		
		//Drawing a thick black border
		[path setLineWidth:16.0];
		[path stroke];
		
		
		//Drawing a thin orange line
		[path setLineWidth:12.0f];
		[[UIColor colorWithRed:1.0f green:0.639216f blue:0.0f alpha:1.0f] set];
		[path stroke];
		
		//Adding two large circles at the start and end of the line
		CGContextRef context = UIGraphicsGetCurrentContext();
		float diameter = 40.0f;
		CGContextSetRGBFillColor(context, 1.0f, 0.639216f, 0.0f, 1.0f);
		CGPoint start = CGPointMake(floatPoints[0] - 0.5*diameter, floatPoints[1] - 0.5*diameter);
		CGContextFillEllipseInRect(context, CGRectMake(start.x,start.y,diameter,diameter));
		
		CGPoint end = CGPointMake(floatPoints[size - 2] - 0.5*diameter, floatPoints[size - 1] - 0.5*diameter);
		CGContextFillEllipseInRect(context,  CGRectMake(end.x,end.y,diameter,diameter));
	}
	
	//[path stroke];
}

-(void) requestTileForX:(NSUInteger)x y:(NSUInteger)y zoom:(NSUInteger)zoom receiver:(id<GMSTileReceiver>)receiver
{	
	//==================================================================
	//               Setting up the tile image to draw
	//==================================================================
	
	//Starting the image contex with a specified size
	CGSize size = CGSizeMake(self.tileSize, self.tileSize);
	UIGraphicsBeginImageContextWithOptions(size, NO, 1.0f);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	MarkupTileProjection *tileProj = [[MarkupTileProjection alloc] initWithTileSize:self.tileSize x:x y:y zoom:zoom];
	
	
	//Getting the tile bounds:
	GMSCoordinateBounds *tileBoundsLatLng = [tileProj getTileBounds];
	
	CGPoint tileBoundsNE = [tileProj latLngToPoint:tileBoundsLatLng.northEast];
	CGPoint tileBoundsSW = [tileProj latLngToPoint:tileBoundsLatLng.southWest];
	
	//Tile boundinx box:
	CGPoint tileBboxMins = CGPointMake(tileBoundsSW.x, tileBoundsNE.y);
	CGPoint tileBboxMaxs = CGPointMake(tileBoundsNE.x, tileBoundsSW.y);
	
	
	//==================================================================
	//                      Drawing a debug grid
	//==================================================================
	
	//Drawing a black 10px x 10px grid
	/*CGContextSetRGBStrokeColor(context, 0.0f, 0.0f, 0.0f, 0.2f);
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
	CGContextStrokePath(context);*/
	
	
	//==================================================================
	//                       Drawing the firelines
	//==================================================================
	if(_firelinesMarkup != NULL)
	{
		
		NSLog(@"Drawing %d fireline features\n",(int)[_firelinesMarkup.firelineFeatures count]);
		
		
		for (MarkupFireline *feature in _firelinesMarkup.firelineFeatures)
		{
			//Getting the fireline's bounds:
			
			CLLocationCoordinate2D boundsSWLatLng = feature.boundsSW;
			CLLocationCoordinate2D boundsNELatLng = feature.boundsNE;
			
			CGPoint boundsSW = [tileProj latLngToPoint:boundsSWLatLng];
			CGPoint boundsNE = [tileProj latLngToPoint:boundsNELatLng];
			
			//Getting the fireline's bounding box
			CGPoint bboxMins = CGPointMake(boundsSW.x, boundsNE.y);
			CGPoint bboxMaxs = CGPointMake(boundsNE.x, boundsSW.y);
			
			//If the line's bbox does not touch the tile's bbox, skip this line
			if([self bboxesIntersectBbox1Min:bboxMins Bbox1Maxs:bboxMaxs Bbox2Mins:tileBboxMins Bbox2Maxs:tileBboxMaxs] == false)
				continue;
			
			
			//===============================================================
			//      			Drawing Fireline Bounding Boxes
			//===============================================================
			
			//Drawing fireline bounding box:
			/*CGContextSetRGBStrokeColor(context, 0.0f, 1.0f, 0.0f, 1.0f);
			CGContextSetLineWidth(context, 1.0f);
			CGContextMoveToPoint(context, boundsSW.x, boundsSW.y);
			CGContextAddLineToPoint(context, boundsNE.x, boundsSW.y);
			CGContextAddLineToPoint(context, boundsNE.x, boundsNE.y);
			CGContextAddLineToPoint(context, boundsSW.x, boundsNE.y);
			CGContextAddLineToPoint(context, boundsSW.x, boundsSW.y);
			CGContextStrokePath(context);*/
			
			//===============================================================
			//
			//===============================================================
			
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

//Returns true of the two bounding boxes intersect
-(bool) bboxesIntersectBbox1Min:(CGPoint)bbox1Mins Bbox1Maxs:(CGPoint)bbox1Maxs Bbox2Mins:(CGPoint)bbox2Mins Bbox2Maxs:(CGPoint)bbox2Maxs
{
	//Adding a slight buffer to the bounding boxes (to not truncate markup styling on edges)
	double buffer = 30;
	
	//Check if bbox1 is to the left of bbox2
	if(bbox1Maxs.x + buffer <= bbox2Mins.x)
		return false;
	//Check if bbox1 is to the right of bbox2
	if(bbox1Mins.x - buffer >= bbox2Maxs.x)
		return false;
	//Check if bbox1 is above bbox2
	if(bbox1Mins.y - buffer >= bbox2Maxs.y)
		return false;
	//Check if bbox1 is below bbox2
	if(bbox1Maxs.y + buffer <= bbox2Mins.y)
		return false;
	return true;
}

@end
