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
//  MarkupFireline.m
//  nics_iOS
//
//
#import "MapMarkupViewController.h"
#import "MarkupFireline.h"
#import "SCOUT_Mobile-Swift.h"

@implementation MarkupFireline

//Returns the tangent of the point in "points" at index "pt"
//pt: index of point
//points: array of points [ x0, y0, x1, y1, ... , xn, yn];
//pointLen: length of "points" array
+ (CGVector)getTangentForPoint:(int)pt pathPoints:(float[])points pathPtLen:(float)pointLen
{
    //if(pt == 0 && pts.length() < 2)
    //	This should never happen, this is an error
    
    float deltaX = 0.0f;
    float deltaY = 0.0f;
    
    //If pt is the first point in pts
    if(pt == 0)
    {
        //Calculate the tangent using the point after it
        deltaX = points[2*(pt + 1)] - points[2*(pt)];
        deltaY = points[2*(pt + 1) + 1] - points[2*(pt) + 1];
    }
    //If pt is the last point in pts
    else if(pt == (pointLen/2) - 1)
    {
        //Calculate the tangent using the point before it
        deltaX = points[2*(pt)] - points[2*(pt - 1)];
        deltaY = points[2*(pt) + 1] - points[2*(pt - 1) + 1];
    }
    else
    {
        //Calculate the tangent using the point before it and after it
        deltaX = points[2*(pt + 1)] - points[2*(pt - 1)];
        deltaY = points[2*(pt + 1) + 1] - points[2*(pt - 1) + 1];
    }
    
    //Calculate the tangent:
    //1) Get the length of the vector
    float vlen = sqrtf( (deltaX * deltaX) + (deltaY * deltaY) );
    //2) Normalize the vector
    return CGVectorMake( deltaX / vlen, deltaY / vlen);
}

//Returns a linearly interpolated tangent of the point in "points" at index "pt" and the index before it
//pt: index of point
//t: interpolation factor (0 <= t <= 1)
//points: array of points [ x0, y0, x1, y1, ... , xn, yn];
//pointLen: length of "points" array
+ (CGVector)lerpTangentForPoint:(int)pt lerpFactor:(float)t pathPoints:(float[])points pathPtLen:(float)pointLen
{
    //If pt is the first point in pts, return the tangent of the point
    if(pt == 0)
        return [MarkupFireline getTangentForPoint:pt pathPoints:points pathPtLen:pointLen];
    
    
    //Get the tangent of the current point
    CGVector curTan = [MarkupFireline getTangentForPoint:pt pathPoints:points pathPtLen:pointLen];
    
    //Get the tangent of the previous point
    CGVector prevTan = [MarkupFireline getTangentForPoint:(pt-2) pathPoints:points pathPtLen:pointLen];
    
    //Calculate the interpolated tangent
    float deltaX = prevTan.dx + t * (curTan.dx - prevTan.dx);
    float deltaY = prevTan.dy + t * (curTan.dy - prevTan.dy);
    
    //Calculate the length of the vector
    float vlen = sqrtf( (deltaX * deltaX) + (deltaY * deltaY) );
    
    
    return CGVectorMake( deltaX / vlen, deltaY / vlen);
}

//Accepts a fireline feature, and adds advanced styling to the passed in PolyLineBezierPath
//points: array of fireline path points [ x0, y0, x1, y1, ... , xn, yn];
//pointLen: length of points array
//style: integer that represents what type of markup to add:
//0: uncontrolled fireline barbs
//1: small 'X'
//2: big 'X'
//3: dots
//path: the path which the advanced styling is added to
+ (void)addAdvancedStyling:(float[])points pathPtLen:(float)pointLen path:(UIBezierPath *)path markupStyle:(int)style markupSpacing:(float)spacing markupOfs:(float)ofs
{
    //this is the index of the current point in the path
    int curPt = 0;
    
    //The number of points in the path
    int pathLen = pointLen / 2.0f;
    
    //The physical distance we need to travel before drawing the next markup
    float distToNext = ofs;
    
    //The last distance we traveled on a previous iteration (for multiple markups between points spaced far apart)
    float lastDist = 0.0f;
    
    
    //While we are not at the end of the path
    while(curPt < pathLen)
    {
        //How much distance between curPt and (curPt - 1) is left to travel
        float distLeft = 0.0f;
        
        
        //Only used if not on first point
        //X-distance between curPt and curPt - 1
        float deltaX = 0.0f;
        //Y-distance between curPt and curPt - 1
        float deltaY = 0.0f;
        //Physical distance between curPt and curPt - 1
        float deltaLen = 0.0f;
        
        //If we are not on the first point
        if(curPt > 0)
        {
            //Get distance we have left to walk
            //this is total distance, minus how much we have already walked (lastDist)
            
            deltaX = points[2 * curPt] - points[2 * (curPt - 1)];
            deltaY = points[(2 * curPt) + 1] - points[(2 * (curPt - 1)) + 1];
            
            deltaLen = sqrtf( (deltaX * deltaX) + (deltaY * deltaY) );
            
            //Getting the vector length of (deltaX,deltaY), and subtracting lastDist
            distLeft = deltaLen - lastDist;
        }
        
        //If there is not enough room for the next markup
        if(distToNext > distLeft)
        {
            //Advance to the next point
            curPt++;
            distToNext -= distLeft;
            lastDist = 0;
            continue;
        }
        
        
        //======================================================================
        //			Calculating markup position and rotation
        //======================================================================
        
        
        float centerX = points[2 * curPt]; //distLeft + distToNext * (normal between previous point and current point)
        float centerY = points[2 * curPt + 1];
        
        //If we have a previous point, get normal direction
        if(curPt > 0)
        {
            //Normalize the deltaX and deltaY:
            deltaX /= deltaLen;
            deltaY /= deltaLen;
            
            //Offset center position by (distToNext - distLeft) in the tangent direction
            centerX += (distToNext - distLeft) * deltaX;
            centerY += (distToNext - distLeft) * deltaY;
        }
        
        //Making the translation vector for the markup
        CGVector transPos = CGVectorMake(centerX, centerY);
        
        //Calculate the linear interpolation factor (how far we are between (curPt - 1) and curPt (0 <= t <= 1))
        float t = 0.0f;
        //If we are on the first point:
        if(curPt == 0)
        {
            t = 0;
        }
        else
        {
            t = (lastDist + distToNext) / deltaLen;
        }
        
        
        //Get the lerped tangent of the markup
        CGVector transTan = [MarkupFireline lerpTangentForPoint:curPt lerpFactor:t pathPoints:points pathPtLen:pointLen];
        
        //Calculate the normal vector from the tangent vector (rotates transTan
        CGVector transNor = CGVectorMake(-transTan.dy,transTan.dx);
        
        
        //Create transformation matrix using the position, tangent and transform
        CGAffineTransform trans = CGAffineTransformMake( transNor.dx,transNor.dy,transTan.dx,transTan.dy,transPos.dx,transPos.dy);
        
        
        //======================================================================
        //			Drawing the markup
        //======================================================================
        
        switch(style)
        {
                //Uncontrolled fireline barbs
            case 0:
            {
                float gap = 1.0f;
                float barbLength = 10.0f;
                
                [path moveToPoint: CGPointApplyAffineTransform(CGPointMake(-gap,0), trans)];
                [path addLineToPoint: CGPointApplyAffineTransform(CGPointMake(-gap - barbLength, 0), trans)];
                
                break;
            }
                //Small X
            case 1:
            {
                float lineLength = 4.0f;
                [path moveToPoint: CGPointApplyAffineTransform(CGPointMake(-lineLength, -lineLength), trans)];
                [path addLineToPoint: CGPointApplyAffineTransform(CGPointMake(lineLength, lineLength), trans)];
                [path moveToPoint: CGPointApplyAffineTransform(CGPointMake(-lineLength, lineLength), trans)];
                [path addLineToPoint: CGPointApplyAffineTransform(CGPointMake(lineLength, -lineLength), trans)];
                break;
            }
                //Big X:
            case 2:
            {
                float lineLength = 5.0f;
                [path moveToPoint: CGPointApplyAffineTransform(CGPointMake(-lineLength, -lineLength), trans)];
                [path addLineToPoint: CGPointApplyAffineTransform(CGPointMake(lineLength, lineLength), trans)];
                [path moveToPoint: CGPointApplyAffineTransform(CGPointMake(-lineLength, lineLength), trans)];
                [path addLineToPoint: CGPointApplyAffineTransform(CGPointMake(lineLength, -lineLength), trans)];
                break;
            }
                //Dot
            case 3:
            {
                [path moveToPoint: CGPointApplyAffineTransform(CGPointMake(0,0), trans)];
                //Lining by a very small amount to make a dot
                [path addLineToPoint: CGPointApplyAffineTransform(CGPointMake(0,0.1), trans)];
                break;
            }
                //No advanced styling?
            default:
                return;
        }
        
        
        //======================================================================
        //======================================================================
        
        lastDist += distToNext;
        distToNext = spacing;
    }
}


- (id) initWithPoints:(NSArray*)points AndFeature:(MarkupFeature*)feature
{
	NSLog(@"Fireline being created\n");

	self = [super initWithMap:nil feature:feature];
	
	_featurePoints = points;
	
	//TODO: calculate the bounding box for this fireline
	NSLog(@"Fireline finished being created\n");

	return self;
}

double getDistanceMetresBetweenLocationCoordinates(
                                                   CLLocationCoordinate2D coord1,
                                                   CLLocationCoordinate2D coord2)
{
    CLLocation* location1 =
    [[CLLocation alloc]
     initWithLatitude: coord1.latitude
     longitude: coord1.longitude];
    CLLocation* location2 =
    [[CLLocation alloc]
     initWithLatitude: coord2.latitude
     longitude: coord2.longitude];
    
    return [location1 distanceFromLocation: location2];
}


//Strokes the actual fireline defined by "points" into path
//points: array of fireline path points [ x0, y0, x1, y1, ... , xn, yn];
//pointLen: length of the points array
//path: the path which the strokes fireline is added to
+ (void) addLine:(float[])points pathPtLen:(float)pointLen ToPath:(UIBezierPath *)path
{
    for(int i = 0; i < pointLen; i+=2)
    {
        if(i == 0)
        {
            [path moveToPoint:CGPointMake(points[0], points[1])];
        }
        else
        {
            [path addLineToPoint:CGPointMake(points[i], points[i + 1])];
        }
    }
}

- (void)removeFromMap {
	//Nothing to do here
}
@end
