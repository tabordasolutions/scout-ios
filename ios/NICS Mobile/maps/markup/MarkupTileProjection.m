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
//  MarkupTileProjection.m
//  SCOUT
//
//


#import "MarkupTileProjection.h"

@implementation MarkupTileProjection




/*@property int x;
@property int y;
@property int zoom;
@property int TILE_SIZE;

@property CGPoint pixelOrigin_;
@property double pixelsPerLonDegree_;
@property double pixelsPerLonRadian_;*/

-(id) initWithTileSize:(int)size x:(int)x y:(int)y zoom:(int)zoom
{
	self = [super init];
	
	_TILE_SIZE = size;
	_x = x;
	_y = y;
	_zoom = zoom;
	
	_pixelOrigin_ = CGPointMake(_TILE_SIZE / 2, _TILE_SIZE / 2);
	_pixelsPerLonDegree_ = _TILE_SIZE / 360.0;
	_pixelsPerLonRadian_ = _TILE_SIZE / (2 * M_PI);
	
	return self;
}

/** Get the dimensions of the Tile in LatLng coordinates */
-(GMSCoordinateBounds *) getTileBounds
{
	CGPoint tileSW = CGPointMake(_x * _TILE_SIZE, (_y + 1) * _TILE_SIZE);
	CGPoint worldSW = [self pixelToWorldCoordinates:tileSW];
	
	CLLocationCoordinate2D SW = [self worldCoordToLatLng:worldSW];
	
	CGPoint tileNE = CGPointMake((_x + 1) * _TILE_SIZE, _y * _TILE_SIZE);
	CGPoint worldNE = [self pixelToWorldCoordinates:tileNE];
	
	CLLocationCoordinate2D NE = [self worldCoordToLatLng:worldNE];
	
	return [[GMSCoordinateBounds alloc] initWithCoordinate:NE coordinate:SW];
}

/**
 * Calculate the pixel coordinates inside a tile, relative to the left upper
 * corner (origin) of the tile.
 */
-(CGPoint) latLngToPoint:(CLLocationCoordinate2D)latLng
{
	CGPoint result = CGPointMake(0,0);
	result = [self latLngToWorldCoordinates:latLng];
	result = [self worldToPixelCoordinates:result];
	
	result.x -= _x * _TILE_SIZE;
	result.y -= _y * _TILE_SIZE;
	
	return result;
}
-(CGPoint) pixelToWorldCoordinates:(CGPoint)pixelCoord
{
	int numTiles = 1 << _zoom;
	CGPoint worldCoord = CGPointMake(pixelCoord.x / numTiles, pixelCoord.y / numTiles);
	return worldCoord;
}

/**
 * Transform the world coordinates into pixel-coordinates relative to the
 * whole tile-area. (i.e. the coordinate system that spans all tiles.)
 */

-(CGPoint) worldToPixelCoordinates:(CGPoint) worldCoord
{
	int numTiles = 1 << _zoom;
	CGPoint pixelCoord = CGPointMake( worldCoord.x * numTiles, worldCoord.y * numTiles);
	return pixelCoord;
}
-(CLLocationCoordinate2D) worldCoordToLatLng:(CGPoint) worldCoord
{
	CGPoint origin = _pixelOrigin_;
	double lng = (worldCoord.x - origin.x) / _pixelsPerLonDegree_;
	double latRadians = (worldCoord.y - origin.y) / -_pixelsPerLonRadian_;
	double lat = (180.0 / M_PI) * (2 * atan(exp(latRadians)) - (M_PI * 0.5));
		
	return CLLocationCoordinate2DMake(lat, lng);
}

/**
 * Get the coordinates in a system describing the whole globe in a
 * coordinate range from 0 to TILE_SIZE (type double).
 */
-(CGPoint) latLngToWorldCoordinates:(CLLocationCoordinate2D)latLng
{
	CGPoint origin = _pixelOrigin_;
	
	CGPoint worldCoord = CGPointMake(0, 0);
	
	worldCoord.x = origin.x + latLng.longitude * _pixelsPerLonDegree_;
	
	// Truncating to 0.9999 effectively limits latitude to 89.189. This is
	// about a third of a tile past the edge of the world tile.
	double siny = sin((M_PI / 180.0)*latLng.latitude);
	// Clamp to [-0.9999 , 0.9999]
	siny = siny > 0.9999 ? 0.9999 : (siny < -0.9999 ? -0.9999 : siny);
	
	worldCoord.y = origin.y + 0.5 * log((1 + siny) / (1 - siny)) * - _pixelsPerLonRadian_;

	return worldCoord;
}


@end
