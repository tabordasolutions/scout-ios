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
//  MarkupTileProjection.h
//  SCOUT
//
//

#import <GoogleMaps/GoogleMaps.h>

@interface MarkupTileProjection : NSObject

@property int x;
@property int y;
@property int zoom;
@property int TILE_SIZE;

@property CGPoint pixelOrigin_;
@property double pixelsPerLonDegree_;
@property double pixelsPerLonRadian_;

-(id) initWithTileSize:(int)size x:(int)x y:(int)y zoom:(int)zoom;

/** Get the dimensions of the Tile in LatLng coordinates */
-(GMSCoordinateBounds *) getTileBounds;

/**
 * Calculate the pixel coordinates inside a tile, relative to the left upper
 * corner (origin) of the tile.
 */
-(CGPoint) latLngToPoint:(CLLocationCoordinate2D)latLng;
-(CGPoint) pixelToWorldCoordinates:(CGPoint)pixelCoord;

/**
 * Transform the world coordinates into pixel-coordinates relative to the
 * whole tile-area. (i.e. the coordinate system that spans all tiles.)
 */

-(CGPoint) worldToPixelCoordinates:(CGPoint) worldCoord;
-(CLLocationCoordinate2D) worldCoordToLatLng:(CGPoint) worldCoord;

/**
 * Get the coordinates in a system describing the whole globe in a
 * coordinate range from 0 to TILE_SIZE (type double).
 */
-(CGPoint) latLngToWorldCoordinates:(CLLocationCoordinate2D)latLng;

@end
