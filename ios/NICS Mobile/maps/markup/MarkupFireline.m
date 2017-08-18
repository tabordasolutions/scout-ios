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
//  MarkupSymbol.m
//  nics_iOS
//
//

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


- (id)initWithMap:(GMSMapView *)view feature:(MarkupFeature *)feature
{
    self = [super initWithMap:view feature:feature];
    
    if(self)
    {
        self.points = [feature getCLPointsArray];
        
        GMSCoordinateBounds *lineBounds = [GMSCoordinateBounds new];
        GMSMutablePath *coordinatePath = [GMSMutablePath path];
        
        NSMutableArray *coordinates = [NSMutableArray new];
        CLLocation *location;
        CLLocationCoordinate2D markerLocation;
        
        for(id point in self.points)
        {
            [point getValue:&markerLocation];
            
            location = [[CLLocation alloc] initWithLatitude:markerLocation.latitude longitude:markerLocation.longitude];
            lineBounds = [lineBounds includingCoordinate:markerLocation];
            
            [coordinates addObject:location];
            [coordinatePath addCoordinate:location.coordinate];
        }
        self.path = coordinatePath;
        
        CLLocationCoordinate2D modSW = CLLocationCoordinate2DMake(lineBounds.southWest.latitude - 0.01, lineBounds.southWest.longitude - 0.01);
        CLLocationCoordinate2D modNE = CLLocationCoordinate2DMake(lineBounds.northEast.latitude + 0.01,  lineBounds.northEast.longitude + 0.01);
        
        lineBounds = [lineBounds includingCoordinate:modSW];
        lineBounds = [lineBounds includingCoordinate:modNE];
        
        CGPoint sw = [view.projection pointForCoordinate:modSW];
        CGPoint ne = [view.projection pointForCoordinate:modNE];
        
        
        //PolyLineBezierPath *path = [PolyLineBezierPath bezierPath];
        
        int size = (int) self.points.count * 2;
        float floatPoints[size];
        memset(floatPoints, 0, size * sizeof(int));
        
        for(int i = 0; i < coordinates.count; i++)
        {
            CLLocation *location = [coordinates objectAtIndex:i];
            CGPoint pt = [view.projection pointForCoordinate:location.coordinate];
            floatPoints[(i * 2)] = pt.x - sw.x;
            floatPoints[(i * 2) + 1] = pt.y - ne.y;
        }
        
        //Luis disabled this. I'm not sure what this does...
        /*if([feature.dashStyle isEqualToString:@"map"]) {
         CGPoint start = CGPointMake(floatPoints[0], floatPoints[1]);
         CGPoint end = CGPointMake(floatPoints[size - 2], floatPoints[size - 1]);
         [path moveToPoint:start];
         [path addArcWithCenter:start radius:1.5 startAngle:0 endAngle:360 clockwise:YES];
         
         [path moveToPoint:end];
         [path addArcWithCenter:end radius:1.5 startAngle:0 endAngle:360 clockwise:YES];
         }*/
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        
        
        //Whether or not we add the line itself to the path
        bool fillLine = false;
        
        NSString *dashStyle = feature.dashStyle;
        UIColor *featureColor = [UIColor blackColor];
        
        if([dashStyle isEqualToString:@"primary-fire-line"])
        {
            fillLine = true;
            path = [self primaryFireLine:path];
        }
        else if([dashStyle isEqualToString:@"secondary-fire-line"])
        {
            fillLine = true;
            path = [self secondaryFireLine:path];
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
            path = [self proposedDozerLine:path];
        }
        else if([dashStyle isEqualToString:@"completed-dozer-line"])
        {
            //x x x x
            [MarkupFireline addAdvancedStyling:floatPoints pathPtLen:size path:path markupStyle:1 markupSpacing:13.0f markupOfs:0.0f];
            path = [self completedDozerLine:path];
        }
        else if([dashStyle isEqualToString:@"fire-edge-line"])
        {
            //barb barb barb
            fillLine = true;
            [MarkupFireline addAdvancedStyling:floatPoints pathPtLen:size path:path markupStyle:0 markupSpacing:10.0f markupOfs:0.0f];
            path = [self fireEdgeLine:path];
            featureColor = [UIColor redColor];
        }
        else if ([dashStyle isEqualToString:@"action-point"])
        {
            // this needs to be a yellow fill line with black border and round caps
            fillLine = true;
            path = [self actionPoint:path];
            
        }
        else if([dashStyle isEqualToString:@"map"])
        {
            fillLine = true;
        }
        
        
        //If fillLine is set, we the line itself to the path
        if(fillLine == true)
        {
            for(int i = 0; i < coordinates.count; i++)
            {
                if(i == 0)
                {
                    [path moveToPoint:CGPointMake(floatPoints[0], floatPoints[1])];
                }
                else
                {
                    [path addLineToPoint:CGPointMake(floatPoints[i * 2], floatPoints[(i * 2) + 1])];
                }
            }
        }
        
        
        
        float width = ne.x - sw.x;
        float height = sw.y - ne.y;
        
        if(width > 0 && height > 0 && width < 2048 && height < 2048)
        {
            UIImage *image = [self generateImageFromPath:path Size:CGSizeMake(width, height) Color:featureColor dashStyle:feature.dashStyle];
            
            _groundOverlay = [GMSGroundOverlay groundOverlayWithBounds:lineBounds icon:image];
            _groundOverlay.anchor = CGPointMake(0.5, 0.5);
            _groundOverlay.map = self.mapView;
        }
    }
    return self;
}

-(UIBezierPath *)primaryFireLine:(UIBezierPath *)path
{
    UIBezierPath *newPath = path.copy;
    
    // squares should be more rectangular, but is very close
    [newPath setLineCapStyle:kCGLineCapSquare];
    [newPath setLineWidth:3.0];
    CGFloat dashes[] = {0, 8};
    [newPath setLineDash:dashes count:2 phase:0];
    return newPath;
}

-(UIBezierPath *)completedDozerLine:(UIBezierPath *)path
{
    UIBezierPath *newPath = path.copy;
    
    [newPath setLineCapStyle: kCGLineCapRound];
    [newPath setLineWidth:3.0];
    return newPath;
}

-(UIBezierPath *)secondaryFireLine:(UIBezierPath *)path
{
    UIBezierPath *newPath = path.copy;
    
    [newPath setLineCapStyle:kCGLineCapRound];
    CGFloat dashes[] = {0, 8};
    [newPath setLineDash:dashes count:2 phase:0];
    return newPath;
}

-(UIBezierPath *)proposedDozerLine:(UIBezierPath *)path
{
    UIBezierPath *newPath = path.copy;
    
    [newPath setLineCapStyle: kCGLineCapRound];
    [newPath setLineWidth:3.0];
    return newPath;
}

-(UIBezierPath *)fireEdgeLine:(UIBezierPath *)path
{
    UIBezierPath *newPath = path.copy;
    [[UIColor redColor] set];
    [newPath setLineWidth:2.0];
    return newPath;
}

-(UIBezierPath *)actionPoint:(UIBezierPath *)path
{
    UIBezierPath *newPath = path.copy;
    // this needs to be a yellow fill line with black border and round caps

    return newPath;
}

-(UIBezierPath *)mapLine:(UIBezierPath *)path
{
    UIBezierPath *newPath = path.copy;
    [newPath setLineWidth:4.0];
    [newPath stroke];
    
    [[UIColor colorWithRed:0.964844f green:0.578125f blue:0.117188f alpha:1.0f] set];
    [newPath setLineWidth:2.0];
    return newPath;
}

- (UIImage *)generateImageFromPath:(UIBezierPath *)path Size:(CGSize)size Color:(UIColor *)featureColor dashStyle:(NSString *)dashStyle
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [featureColor set];
    
    [path stroke];
    CGContextAddPath(context, path.CGPath);
    
    // transfer image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)removeFromMap {
    if(_groundOverlay != nil) {
        _groundOverlay.map = nil;
    }
}
@end

