/*|~^~|Copyright (c) 2008-2015, Massachusetts Institute of Technology (MIT)
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
//  FormLocation.m
//  NICS Mobile
//
//

#import "FormLocation.h"
#import "IncidentButtonBar.h"

@implementation FormLocation

float marginSize;
double doubleHitTestBuffer;
double lastHitTestTime;

- (void)setup {
    [super setup];
    self.type = @"location";
    [[NSBundle mainBundle] loadNibNamed:@"FormLocation" owner:self options:nil];
    
    for(UIView * subview in self.view.subviews) {
        [subview setUserInteractionEnabled:YES];
        [self addSubview:subview];
    }
//    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.superview.frame.size.width, self.view.frame.size.height);
    
//    self.field = self.latitudeTextView;
    self.label = self.locationLabel;
    
    
    [self.interactableViews addObject:self.latitudeTextView];
    [self.interactableViews addObject:self.longitudeTextView];
    
    self.latitudeTextView.returnKeyType = UIReturnKeyDefault;
    self.longitudeTextView.returnKeyType = UIReturnKeyDefault;
    
    marginSize = 5;
    doubleHitTestBuffer = 0.25;
    lastHitTestTime = 0;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mapCustomLocationChanged) name:@"mapCustomLocationChanged" object:nil];
    
    //    self.field.delegate = self.view;
}

- (void)configureFields{
    
    CGRect frameMyLocationBtn = self.myLocationButton.frame;
    frameMyLocationBtn.size.height =self.latitudeTextView.frame.size.height;
    frameMyLocationBtn.size.width =self.latitudeTextView.frame.size.height;
    
    CGRect frameLat =  self.latitudeTextView.frame;
    frameLat.size.width = ((frameLat.size.width - frameMyLocationBtn.size.width - frameMyLocationBtn.size.width) /2) - marginSize;
    self.latitudeTextView.frame = frameLat;
    [self.latitudeTextView setPlaceHolderText:NSLocalizedString(@"Latitude",nil)];
    
    CGRect frameLon = self.latitudeTextView.frame;
    frameLon.size.width = (frameLat.size.width) - marginSize;
    frameLon.origin.x = frameLat.size.width + marginSize;
    self.longitudeTextView.frame = frameLon;
    [self.longitudeTextView setPlaceHolderText:NSLocalizedString(@"Longitude",nil)];
    


    frameMyLocationBtn.origin.x =frameLon.origin.x + frameLon.size.width + marginSize;
    frameMyLocationBtn.origin.y =frameLon.origin.y;
    self.myLocationButton.frame =frameMyLocationBtn;
    
    frameMyLocationBtn.origin.x = self.myLocationButton.frame.origin.x + self.myLocationButton.frame.size.width + marginSize;
    self.mapLocationButton.frame = frameMyLocationBtn;
    
}

-(void)setData : (NSString*)lat : (NSString*) lon : (bool)readOnly{
    
    [self.latitudeTextView setText:lat];
    [self.longitudeTextView setText:lon];
    
    [self.latitudeTextView setEditable:!readOnly];
    [self.longitudeTextView setEditable:!readOnly];
    [self.myLocationButton setHidden:readOnly];
    [self.mapLocationButton setHidden:readOnly];

}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    UIView *touchedView = [super hitTest:point withEvent:event];
    
    if(([[NSDate date] timeIntervalSince1970] - lastHitTestTime) < doubleHitTestBuffer){
        lastHitTestTime = [[NSDate date] timeIntervalSince1970];
        return touchedView;
    }
    
    if(!_myLocationButton.isHidden){
        if(point.x > self.myLocationButton.frame.origin.x && point.x < self.myLocationButton.frame.origin.x + self.myLocationButton.frame.size.width && point.y > self.myLocationButton.frame.origin.y && point.y < self.myLocationButton.frame.origin.y + self.myLocationButton.frame.size.height) {
            [self setFieldsToMyLocation];
        }
    }
    
    if(!_mapLocationButton.isHidden){
        if(point.x > self.mapLocationButton.frame.origin.x && point.x < self.mapLocationButton.frame.origin.x + self.mapLocationButton.frame.size.width && point.y > self.mapLocationButton.frame.origin.y && point.y < self.mapLocationButton.frame.origin.y + self.mapLocationButton.frame.size.height) {
            [self startMapLocationPicker];
        }
    }
    
    lastHitTestTime = [[NSDate date] timeIntervalSince1970];
    return touchedView;
}

-(void)startMapLocationPicker{
    if(self.dataManager.isIpad){
        MapMarkupViewController *mapView = [IncidentButtonBar GetMapMarkupController];
        GMSMarker* marker = [mapView getCustomMarker];
        [self.latitudeTextView setText: [NSString stringWithFormat:@"%f", marker.position.latitude ]];
        [self.longitudeTextView setText: [NSString stringWithFormat:@"%f", marker.position.longitude ]];
    }else{
        [[self.dataManager getOverviewController] performSegueWithIdentifier:@"mapid" sender:self];

    }
}

-(void)mapCustomLocationChanged{
    [self.latitudeTextView setText: [NSString stringWithFormat:@"%f", self.dataManager.mapSelectedLatitude ]];
    [self.longitudeTextView setText: [NSString stringWithFormat:@"%f", self.dataManager.mapSelectedLongitude ]];
}

//-(void)prepareForSegue:(UIStoryboardSegue *)segue
//{
//    if ([segue.identifier isEqualToString:@"SubRecipeConnectorSegue"])
//    {
//        MapMarkupViewController *mapController = segue.destinationViewController;
//        
//    }
//}

-(void)setFieldsToMyLocation{
    [self.latitudeTextView setText: [NSString stringWithFormat:@"%f", self.dataManager.currentLocation.coordinate.latitude]];
    [self.longitudeTextView setText: [NSString stringWithFormat:@"%f", self.dataManager.currentLocation.coordinate.longitude]];
}

-(void)cleanNotificationListener{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
