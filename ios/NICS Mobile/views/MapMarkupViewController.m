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
//  ViewController.m
//  SidebarDemo
//
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import "MapMarkupViewController.h"
#import "RoomCanvasUIViewController.h"
@class SimpleReportDetailViewController;
@class DamageReportDetailViewController;

@interface MapMarkupViewController ()
@property float currentZoomLevel;
@property BOOL isExpanded;
@end

static NSNumber* selectedIndex;

@implementation MapMarkupViewController

//MapMarkupViewController *FullscreenMap = nil;
//UIPopoverController *myPopOver = nil;
bool markupProcessing = false;
int mapZoomLevel = 6;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _isExpanded = false;
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:@"MM/dd HH:mm:ss"];
    
    _dataManager = [DataManager getInstance];
    
    _markupShapes = [NSMutableDictionary new];
    _markupDraftShapes = [NSMutableArray new];
    _generalMessageSymbols = [NSMutableDictionary new];
    _damageReportSymbols = [NSMutableDictionary new];

    _wfsMarkers = [NSMutableArray new];

    _mapView.mapType = _dataManager.CurrentMapType;
    _mapView.trafficEnabled = _dataManager.TrafficDisplay;
    _mapView.indoorEnabled = _dataManager.IndoorDisplay;

    _currentZoomLevel = 8.0;
    
    [self addMarkupUpdateFromServer:nil];
    
    _originalFrame = self.view.frame;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addMarkupUpdateFromServer:) name:@"markupFeaturesUpdateReceived" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetMapFeatures) name:@"resetMapFeatures" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkIosVersionThenWfsUpdate) name:@"WfsUpdateRecieved" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recieveMapType:) name:@"MapTypeSwitched" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableView) name:@"CollabRoomSwitched" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addMarkupUpdateFromServer:) name:@"CollabRoomSwitched" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addMarkupUpdateFromServer:) name:@"IncidentSwitched" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SetMapPosition:) name:@"SetMapPosition" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SetMapCustomMarkerPosition:) name:@"SetMapCustomMarkerPosition" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(trackingLayerWasToggled:) name:@"wfsLayerWasToggled" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GeneralMessageUpdateRecieved:) name:@"simpleReportsUpdateReceived" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DamageReportUpdateRecieved:) name:@"damageReportsUpdateReceived" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView) name:@"DidBecomeActive" object:nil];
    
    if([_dataManager getIsIpad] == false){
        
        UIBarButtonItem *refreshBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshButtonPressed)];
        refreshBarButtonItem.style = UIBarButtonItemStyleBordered;
        
        UIBarButtonItem *mapSettingsBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Layers" style:UIBarButtonItemStylePlain target:self action:@selector(MapSettingsBarButtonPressed)];
        mapSettingsBarButton.style = UIBarButtonItemStyleBordered;
        
        self.navigationItem.rightBarButtonItems = @[mapSettingsBarButton,refreshBarButtonItem];
    }
    
    _mapView.settings.compassButton = YES;
    _mapView.myLocationEnabled = YES;
    _mapView.settings.myLocationButton = YES;
    
    [_mapView moveCamera:[GMSCameraUpdate setTarget:CLLocationCoordinate2DMake([_dataManager.currentIncident.lat doubleValue], [_dataManager.currentIncident.lon doubleValue]) zoom:10]];
    
    if(_zoomingToReport){
        [_mapView animateToLocation: _positionToZoomTo];
        [_mapView animateToZoom:mapZoomLevel];
        _zoomingToReport = false;
    }else{
        if ([_dataManager.locationManager location].coordinate.latitude > 0.0 && [_dataManager.locationManager location].coordinate.longitude > 0.0) {
            [_mapView animateToLocation:[_dataManager.locationManager location].coordinate];
            [_mapView animateToZoom:mapZoomLevel];

        } else {
            [_mapView animateToLocation:CLLocationCoordinate2DMake(36.7468, -119.7726)];
            [_mapView animateToZoom:mapZoomLevel];

        }


    }
    _mapView.delegate = self;
    
    _myCustomMarker = [[GMSMarker alloc] init];
    _myCustomMarker.position = CLLocationCoordinate2DMake(0,0);
    _myCustomMarker.draggable = TRUE;
    
    [self setupMapButtons];
}

-(void)setupMapButtons{
    UIImage *image;
    float mapBtnOffset = 65;
    
    if([_dataManager getIsIpad] == true){
//
        mapBtnOffset = 75;
//
//        _fullscreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        
//        image = [UIImage imageNamed:@"enter_fullscreen_button.png"];
//        [_fullscreenButton setImage:image forState:UIControlStateNormal];
//        
//        SEL noArgumentSelectorFullScreen = @selector(FullScreenMap);
//        [_fullscreenButton addTarget:self action:noArgumentSelectorFullScreen forControlEvents:UIControlEventTouchUpInside];
//        
//        _fullscreenButton.frame = CGRectMake(_mapView.bounds.size.width - 200, _mapView.bounds.size.height - mapBtnOffset, 50, 50);
//        _fullscreenButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
//        [_fullscreenButton setTitle:@"Fullscreen" forState:UIControlStateNormal];
//        [_mapView addSubview:_fullscreenButton];
    }
    _extendMapButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    image  = [UIImage imageNamed:@"down_arrow_icon.png"];
    [_extendMapButton setImage:image forState:UIControlStateNormal];
    
    SEL noArgumentSelectorExtend = @selector(ExtendMapDown);
    [_extendMapButton addTarget:self action:noArgumentSelectorExtend forControlEvents:UIControlEventTouchUpInside];
    
    _extendMapButton.frame = CGRectMake(_mapView.bounds.size.width - 130, _mapView.bounds.size.height - mapBtnOffset, 50, 50);
    _extendMapButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    [_extendMapButton setTitle:@"Extend" forState:UIControlStateNormal];
    [_mapView addSubview:_extendMapButton];
    
    
    _editMapButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    SEL noArgumentSelectorEdit = @selector(ToggleEditMap);
    [_editMapButton addTarget:self action:noArgumentSelectorEdit forControlEvents:UIControlEventTouchUpInside];
    [_editMapButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _editMapButton.frame = CGRectMake( 60, _mapView.bounds.size.height - mapBtnOffset, 50, 50);
    _editMapButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    [_editMapButton setImage:[UIImage imageNamed:@"pencil_icon.png"] forState:UIControlStateNormal];
    [_mapView addSubview:_editMapButton];
    
    CGRect mapEditFrame =_MapEditCanvas.frame;
    mapEditFrame.origin.x = 0;
    mapEditFrame.origin.y = 0;
    mapEditFrame.size.height = 70;
    //    _mapEditView = [[MapEditView alloc]initWithFrame: mapEditFrame];
    _mapEditView = [[MapEditView alloc] init];
    _mapEditView.mapViewController = self;
    [_mapEditView Setup:mapEditFrame];
    //    _mapEditView.frame = mapEditFrame;
    [_MapEditCanvas addSubview:_mapEditView.view];
    
    _editMapPanelOpen = false;
    [self checkAndEnableMarkupTools];
    
    _gotoReportButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_gotoReportButton setImage:[UIImage imageNamed:@"report_map_icon.png"] forState:UIControlStateNormal];
    SEL noArgumentSelectorGotoReport = @selector(GotoReport);
    [_gotoReportButton addTarget:self action:noArgumentSelectorGotoReport forControlEvents:UIControlEventTouchUpInside];
    
    _gotoReportButton.frame = CGRectMake(_editMapButton.frame.origin.x + mapBtnOffset, _mapView.bounds.size.height - mapBtnOffset, 50, 50);
    _gotoReportButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    [_gotoReportButton setTitle:@"Report" forState:UIControlStateNormal];
    [_mapView addSubview:_gotoReportButton];
    [_gotoReportButton setHidden:TRUE];
    [_gotoReportButton setEnabled:FALSE];
}

-(void)reloadTableView{
    [_tableView reloadData];
}

//-(void)FullScreenMap{
//    if(FullscreenMap == nil){
//        FullscreenMap = [[UIStoryboard storyboardWithName:@"Main_iPad_Prototype" bundle:nil] instantiateViewControllerWithIdentifier:@"MapFullscreenViewID"];
//    }
//    if(myPopOver == nil){
//        myPopOver = [[UIPopoverController alloc]initWithContentViewController:FullscreenMap];
//        CGRect displayFrom = CGRectMake(1,1,1,1);
//        [myPopOver presentPopoverFromRect:displayFrom inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
//        [FullscreenMap setPopoverButtons];
//    }else{
//        [myPopOver dismissPopoverAnimated:YES];
//        myPopOver = nil;
//    }
//}

// Returns cur offset by ofs.origin.y
-(CGRect) offsetFrame:(CGRect)cur with:(CGRect)ofs
{
	float deltaY = ofs.origin.y;
	// I don't need to manually do this, storyboard constraints should handle the
	// origin appropriately
	//cur.origin.y = deltaY;
	cur.size.height -= deltaY;
	return cur;
}

-(void) extendMapDowniPad{
	// If the original map frame is not yet initialized, store all original layer frame sizes
	if(_originalMapFrame.size.width == 0)
	{
		// Actual map
		_originalMapFrame = _mapView.frame;
		// Layer 1
		_originalFrameLayer1 = [IncidentButtonBar GetOverview].RoomCanvas.frame;
		// Layer 2
		RoomCanvasUIViewController *roomCanvasViewCntlr = nil;
		for(UIViewController *c in [IncidentButtonBar GetOverview].childViewControllers)
		{
			// Check if we found the RoomCanvasUIViewController object
			// This should ALWAYS return a valid controller
			if([c class] == [RoomCanvasUIViewController class])
				roomCanvasViewCntlr = (RoomCanvasUIViewController*) c;
		}
		_originalFrameLayer2 = roomCanvasViewCntlr.view.frame;
		// Layer 3
		_originalFrameLayer3 = roomCanvasViewCntlr.RoomCanvas.frame;
		// Layer 4
		_originalFrameLayer4 = [IncidentButtonBar GetMapMarkupController].view.frame;
	}
	
	
	//disables autolayouts allowing me more control over its positions
	_tableView.translatesAutoresizingMaskIntoConstraints = YES;
	_mapView.translatesAutoresizingMaskIntoConstraints = YES;
	_MapEditCanvas.translatesAutoresizingMaskIntoConstraints = YES;
	
	
	[UIView beginAnimations: @"tableAnim" context: nil];
	[UIView setAnimationBeginsFromCurrentState: NO];
	[UIView setAnimationDuration: 0.35f];
	
	if(_mapView.frame.size.width > _originalMapFrame.size.width){
		//=======================================================================================
		// This code restores the map to its smaller size
		//=======================================================================================
		OverviewViewControllerTablet *overviewViewController = [IncidentButtonBar GetOverview];
		// Showing the right pane
		[overviewViewController.IncidentCanvas setHidden:false];
		// Restoring the left pane
		[overviewViewController.RoomCanvas setFrame:_originalFrameLayer1];
		[overviewViewController.RoomCanvas setNeedsLayout];
		// Restoring the RoomCanvasUIViewController
		RoomCanvasUIViewController *roomCanvasViewCntlr = nil;
		for(UIViewController *c in overviewViewController.childViewControllers)
		{
			// Check if we found the RoomCanvasUIViewController object
			if([c class] == [RoomCanvasUIViewController class])
				roomCanvasViewCntlr = (RoomCanvasUIViewController*) c;
		}
		[roomCanvasViewCntlr.view setFrame:_originalFrameLayer2];
		[roomCanvasViewCntlr.view setNeedsLayout];
		[roomCanvasViewCntlr.RoomCanvas setFrame:_originalFrameLayer3];
		[roomCanvasViewCntlr.RoomCanvas setNeedsLayout];
		// Finally, restoring the new frame of the actual map view:
		MapMarkupViewController * mapViewCntlr = [IncidentButtonBar GetMapMarkupController];
		[mapViewCntlr.view setFrame:_originalFrameLayer4];
		[mapViewCntlr.view setNeedsLayout];
		[_extendMapButton setImage:[UIImage imageNamed:@"down_arrow_icon.png"] forState:UIControlStateNormal];
		// Showing the map edit button
		[_editMapButton setHidden:false];
		// Restoring the map frame
		_mapView.frame = _originalMapFrame;
	}else{
		//=======================================================================================
		// This code expands the map
		//=======================================================================================
		OverviewViewControllerTablet *overviewViewController = [IncidentButtonBar GetOverview];
		CGRect fullscreenFrame = overviewViewController.view.frame;
		fullscreenFrame.origin.x = 0;
		fullscreenFrame.origin.y = 0;
		// Hiding the right pane
		[overviewViewController.IncidentCanvas setHidden:true];
		// Expanding the left pane
		[overviewViewController.RoomCanvas setFrame:fullscreenFrame];
		[overviewViewController.RoomCanvas setNeedsLayout];
		// Scaling up the RoomCanvasUIViewController
		RoomCanvasUIViewController *roomCanvasViewCntlr = nil;
		for(UIViewController *c in overviewViewController.childViewControllers)
		{
			// Check if we found the RoomCanvasUIViewController object
			if([c class] == [RoomCanvasUIViewController class])
				roomCanvasViewCntlr = (RoomCanvasUIViewController*) c;
		}
		[roomCanvasViewCntlr.view setFrame:fullscreenFrame];
		[roomCanvasViewCntlr.view setNeedsLayout];
		fullscreenFrame = [self offsetFrame:fullscreenFrame with:roomCanvasViewCntlr.RoomCanvas.frame];
		[roomCanvasViewCntlr.RoomCanvas setFrame:fullscreenFrame];
		[roomCanvasViewCntlr.RoomCanvas setNeedsLayout];
		// Finally, setting the new frame of the actual map view:
		MapMarkupViewController * mapViewCntlr = [IncidentButtonBar GetMapMarkupController];
		[mapViewCntlr.view setFrame:fullscreenFrame];
		[mapViewCntlr.view setNeedsLayout];
		[_extendMapButton setImage:[UIImage imageNamed:@"up_arrow_icon.png"] forState:UIControlStateNormal];
		
		// Hiding the map edit button
		[_editMapButton setHidden:true];
		
		// Assigning the new map frame:
		_mapView.frame = fullscreenFrame;
	}
	
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(ToggleEditMapAnimationStopped)];
	[UIView commitAnimations];
}

-(void) extendMapDowniPhone{
	// If the original map frame is not yet initialized, store all original layer frame sizes
	if(_originalMapFrame.size.width == 0)
	{
		// Actual map
		_originalMapFrame = _mapView.frame;
	}
	
	
	//disables autolayouts allowing me more control over its positions
	_tableView.translatesAutoresizingMaskIntoConstraints = YES;
	_mapView.translatesAutoresizingMaskIntoConstraints = YES;
	_MapEditCanvas.translatesAutoresizingMaskIntoConstraints = YES;
	
	
	[UIView beginAnimations: @"tableAnim" context: nil];
	[UIView setAnimationBeginsFromCurrentState: NO];
	[UIView setAnimationDuration: 0.35f];
	

	
	if(_mapView.frame.size.height > _originalMapFrame.size.height){
		//=======================================================================================
		// This code restores the map to its smaller size
		//=======================================================================================
		// Showing the map edit button
		[_editMapButton setHidden:false];
		// Restoring the map frame
		_mapView.frame = _originalMapFrame;
		// Setting the button to expand button
		[_extendMapButton setImage:[UIImage imageNamed:@"down_arrow_icon.png"] forState:UIControlStateNormal];
	}else{
		//=======================================================================================
		// This code expands the map
		//=======================================================================================
		// Getting the fullscreen map layout
		MapMarkupViewController *mapMarkupViewCntlr = [IncidentButtonBar GetMapMarkupController];
		CGRect fullscreenFrame = mapMarkupViewCntlr.view.frame;
		fullscreenFrame.origin.x = 0;
		fullscreenFrame.origin.y = 0;
		// This is about right for what the map needs to be adjusted by
		fullscreenFrame.size.height -= 60;
		// Hiding the map edit button
		[_editMapButton setHidden:true];
		// Assigning the new map frame:
		_mapView.frame = fullscreenFrame;
		// Setting the button to restore button
		[_extendMapButton setImage:[UIImage imageNamed:@"up_arrow_icon.png"] forState:UIControlStateNormal];
	}
	
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(ToggleEditMapAnimationStopped)];
	[UIView commitAnimations];
}

-(void)ExtendMapDown
{
    if(_dataManager.isIpad)
    {
	    [self extendMapDowniPad];
	    return;
    }
    else
    {
	    [self extendMapDowniPhone];
	    return;
    }
}

-(void)ToggleEditMap{
    
    CGRect frame = _mapEditView.view.frame;
    frame.size.height=70;
    _mapEditView.view.frame = frame;
    
    //disables autolayouts allowing me more control over it's positions
    _tableView.translatesAutoresizingMaskIntoConstraints = YES;
    _mapView.translatesAutoresizingMaskIntoConstraints = YES;
    _MapEditCanvas.translatesAutoresizingMaskIntoConstraints = YES;
    
    if(_originalTableFrame.size.width ==0){
        _originalTableFrame = _tableView.frame;
    }

    [UIView beginAnimations: @"tableAnim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: NO];
    [UIView setAnimationDuration: 0.35f];
    
    if(_tableView.frame.size.height < _originalTableFrame.size.height){
        _tableView.frame = _originalTableFrame;
        _editMapPanelOpen = false;
    }else{
        CGRect newFrame = _tableView.frame;
        newFrame.size.height = _originalTableFrame.size.height - _MapEditCanvas.frame.size.height;
        newFrame.origin.y = _originalTableFrame.origin.y + _MapEditCanvas.frame.size.height;
        _tableView.frame = newFrame;
        _editMapPanelOpen = true;
    }
    
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(ToggleEditMapAnimationStopped)];
    [UIView commitAnimations];
}

-(void)ToggleEditMapAnimationStopped{
    if(_editMapPanelOpen == false){
        [_mapEditView switchViewState: TypeSelectView];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}


- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position {
    if(_previousZoomLevel != position.zoom) {
        if(position.bearing != 0) {
            GMSCameraPosition *newPosition = [GMSCameraPosition cameraWithTarget:position.target zoom:position.zoom bearing:0 viewingAngle:0];
            GMSCameraUpdate *update = [GMSCameraUpdate setCamera:newPosition];
            [_mapView moveCamera:update];
        }
    }
	//Disabled for tileOverlay drawing, this caused the tiles to disappear and reappear when a user stopped panning the map view
    //[self redrawLocalMapFeatures];
    _previousZoomLevel = position.zoom;
}

-(void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position {
    
    if (roundf(position.zoom) > _currentZoomLevel && roundf(position.zoom) < 16.0) {
        
        [self refreshView];
        _currentZoomLevel = roundf(position.zoom);
    }
}

-(void)addFirelinesToMap:(NSArray *) features
{
	//In this function, we are being passed the fireline features from the database
	//the database handles updating / deleting firelines from the server
	//this function simply adds them to our list of rendering firelines
	
	//Storing fireline features in this MarkupFireline object
	
	if(_firelineFeatures == nil)
	{
		_firelineFeatures = [[MarkupFirelineFeatures alloc] init];
	}
	//Should we delete the current _firelineFeatures.firelineFeatures array if its already instantiated?
	
	[_firelineFeatures setFeatures:features];
	
	//Setting MarkupTileLayer's fireline features to this new object
	if(_tileLayer != nil)
	{
		_tileLayer.firelinesMarkup = _firelineFeatures;
	}
	
	for(MarkupBaseShape *firelineShape in _firelineFeatures.firelineFeatures)
	{
		if([firelineShape.featureId isEqualToString: @"draft"]){
			[_markupDraftShapes addObject:firelineShape];
		}else{
			[_markupShapes setValue:firelineShape forKey:firelineShape.feature.featureId];
		}
	}
}

-(void)addFeatureToMap:(MarkupFeature*) feature {
    
//    [_markupFeatures setValue:feature forKey:feature.featureId];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        MarkupType currentType = [Enums convertToMarkupTypeFromString:feature.type];
        if(currentType == symbol) {
            NSString* dateString =  [[Utils getDateFormatter] stringFromDate:[NSDate dateWithTimeIntervalSince1970:[feature.seqtime longValue]]];
            
            feature.featureattributes = [@"" stringByAppendingFormat:@"%@%@%@%@%@%@",
                                         @"user: ",feature.username,
                                         @"\ntime: ",dateString,
                                         @"\ncoord: ",feature.geometry
                                         ];
            
            MarkupSymbol *symbol = [[MarkupSymbol alloc] initWithMap:_mapView feature:feature];
            if([feature.featureId isEqualToString: @"draft"]){
                [_markupDraftShapes addObject:symbol];
            }else{
                [_markupShapes setValue:symbol forKey:feature.featureId];
            }
            
        } else if(currentType == segment) {
            if(feature.dashStyle == nil) {  //line segment
                MarkupSegment *segment = [[MarkupSegment alloc] initWithMap:_mapView feature:feature];
                if([feature.featureId isEqualToString: @"draft"]){
                    [_markupDraftShapes addObject:segment];
                }else{
                    [_markupShapes setValue:segment forKey:feature.featureId];
                }
            }
        } else if(currentType == rectangle || currentType == polygon) {
            MarkupPolygon *polygon = [[MarkupPolygon alloc] initWithMap:_mapView feature:feature];
            if([feature.featureId isEqualToString: @"draft"]){
                [_markupDraftShapes addObject:polygon];
            }else{
                [_markupShapes setValue:polygon forKey:feature.featureId];
            }
        } else if(currentType == text) {
            MarkupText *text = [[MarkupText alloc] initWithMap:_mapView feature:feature];
            if([feature.featureId isEqualToString: @"draft"]){
                [_markupDraftShapes addObject:text];
            }else{
                [_markupShapes setValue:text forKey:feature.featureId];
            }
        }
    });
}

-(void)removeFeatureFromMap:(NSString*) featureId {
    
    NSString* lookupString = [NSString stringWithFormat:@"%@",featureId];
    
    if([_markupShapes objectForKey: lookupString] != nil ){
    
        dispatch_async(dispatch_get_main_queue(), ^{
            [[_markupShapes objectForKey:lookupString] removeFromMap];
            [_markupShapes removeObjectForKey:lookupString];
        });
    }
}

-(void)clearMapOfFeature{

    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSArray* keys = _markupShapes.allKeys;
        for(NSString* key in keys){
            
            [[_markupShapes objectForKey:key]removeFromMap];
        }
        [_markupShapes removeAllObjects];
    });
}

-(void)clearMapOfDraftFeatures{

    dispatch_async(dispatch_get_main_queue(), ^{
        for(int i = 0; i < _markupDraftShapes.count; i++){
            [[_markupDraftShapes objectAtIndex:i] removeFromMap];
        }
        [_markupDraftShapes removeAllObjects];
    });
}

-(void)resetMapFeatures{
    [self clearMapOfFeature];
}

-(void)checkAndEnableMarkupTools{
    CollabroomPayload* activeCollabroom = [_dataManager getActiveCollabroomPayload];
    NSNumber* userId =[_dataManager getUserId];
    if([activeCollabroom doIHaveMarkupPermission:userId]){
        _editMapButton.hidden = false;
    }else{
        _editMapButton.hidden = true;
        
        if(_editMapPanelOpen){
            [self ToggleEditMap];
        }
    }
}

-(void) addMarkupUpdateFromServer :(NSNotification *)notification{
    
    [self checkAndEnableMarkupTools];
    
    if(_currentShape == nil && !markupProcessing) {
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queue, ^{
            
            if(markupProcessing == false){
                markupProcessing = true;
			  
			  //if room switched or first load then init map with local storage
			  if(_currentCollabRoomId == nil || _currentCollabRoomId != [_dataManager getSelectedCollabroomId]){
				  [self redrawLocalMapFeatures];
				  _currentCollabRoomId = [_dataManager getSelectedCollabroomId];
			  }
                
                //if this function was called from restclient receiving new data
                if([notification.name isEqualToString:@"markupFeaturesUpdateReceived"]){
				 
				//Set to true if we modified a fireline
				//This is so we don't refresh the tile layer if we didn't add or delete any firelines
				bool refreshTileLayer = false;
                    
                    //_mapView.mapType =  [[[notification userInfo] valueForKey:@"mapType"] intValue];
                    
                    NSString* jsonString =  [[notification userInfo] valueForKey:@"markupFeaturesJson"];
                    NSError* error = nil;
                    MarkupMessage *message = [[MarkupMessage alloc] initWithString:jsonString error:&error];
                    
				 
                    for(MarkupFeature* feature in message.features){
					
					//If this feature is a fireline, add it to the features array
                        	if (feature.dashStyle != nil){
						[_firelineFeatures addFeature:feature];
						refreshTileLayer = true;
                        	}
					[self addFeatureToMap:feature];
				}

				for(NSString* featureId in message.deletedFeature){
					//In case this is a fireline, try removing it from the fireline list
					if([_firelineFeatures deleteFeatureWithId:featureId] == 1)
						refreshTileLayer = true;
					
					[self removeFeatureFromMap:featureId];
                    }
				 
                    [self clearMapOfDraftFeatures];
				 
				 
				//Tell tile layer to redraw, but only if we added or deleted at least one fireline
				 if(refreshTileLayer && _tileLayer != nil) {
					dispatch_async(dispatch_get_main_queue(), ^{
						[_tileLayer clearTileCache];
					 });
				 }
                }
			  

			  
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[self tableView] reloadData];
                    [self checkIosVersionThenWfsUpdate];
                });
            }
            markupProcessing = false;
        });
    }
}

-(void)redrawLocalMapFeatures{
    [self clearMapOfFeature];
    [self clearMapOfDraftFeatures];
    [self clearGeneralMessageSymbolsFromMap];
    [self clearDamageReportSymbolsFromMap];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_mapView clear];
        
        if(_tileLayer == NULL)
        {
            _tileLayer = [[MarkupTileLayer alloc] init];
			_tileLayer.tileSize = 512;
			_tileLayer.map = _mapView;
		    	//Not necessary: defaults to true
			//[_tileLayer setFadeIn:true];
	    }
	    else
	    {
		    //This call appears to be required after calling [_mapView clear]
		    _tileLayer.map = _mapView;
		    
		    //Tell tileLayer to redraw tiles
		    [_tileLayer clearTileCache];
	    }
    });
    
    for(MarkupFeature* feature in [_dataManager getAllNonFirelinesForCollabRoomId:[_dataManager getSelectedCollabroomId]]){
        [self addFeatureToMap:feature];
    }
	
	
	
    [self addFirelinesToMap:[_dataManager getAllFirelinesForCollabRoomId:[_dataManager getSelectedCollabroomId]]];
    
    if([_dataManager getTrackingLayerEnabled:NSLocalizedString(@"SCOUT Field Reports",nil)]){
        [self addAllGeneralMessageSymbolsToMap];
    }
    if([_dataManager getTrackingLayerEnabled:NSLocalizedString(@"SCOUT Damage Surveys",nil)]){
        [self addAllDamageReportSymbolsToMap];
    }
}

-(void)trackingLayerWasToggled:(NSNotification *)notification{
    
    int isOn = [[[notification userInfo] valueForKey:@"isOn"] intValue];
    int layerIndex = [[[notification userInfo] valueForKey:@"indexOfToggledLayer"] intValue];
    
    TrackingLayerPayload* trackingLayerToCompare = [[ActiveWfsLayerManager getTrackingLayers] objectAtIndex:layerIndex ];
    
    if([trackingLayerToCompare.displayname isEqualToString:NSLocalizedString(@"SCOUT Field Reports",nil)]){
        if(isOn == 1){
            [self addAllGeneralMessageSymbolsToMap];
        }else{
            [self clearGeneralMessageSymbolsFromMap];
        }
    }else if([trackingLayerToCompare.displayname isEqualToString:NSLocalizedString(@"SCOUT Damage Surveys",nil)]){
        if(isOn == 1){
            [self addAllDamageReportSymbolsToMap];
        }else{
            [self clearDamageReportSymbolsFromMap];
        }
    }
}

-(void)clearGeneralMessageSymbolsFromMap{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSArray* keys = _generalMessageSymbols.allKeys;
        for(NSString* key in keys){
            [[_generalMessageSymbols objectForKey:key] removeFromMap];
        }
        [_generalMessageSymbols removeAllObjects];
    });
}

-(void)GeneralMessageUpdateRecieved:(NSNotification *)notification{
    
    NSString* jsonString = [[notification userInfo] valueForKey:@"generalMessageJson"];
    NSError* error = nil;
    SimpleReportMessage *message = [[SimpleReportMessage alloc] initWithString:jsonString error:&error];
    
    for(SimpleReportPayload* payload in message.reports){
        [payload parse];
        [self addGeneralMessageSymbolToMap:payload];
    }
}

-(void)addAllGeneralMessageSymbolsToMap{
    for(SimpleReportPayload* payload in [_dataManager getAllSimpleReportsForIncidentId:[_dataManager getActiveIncidentId]]){
        [self addGeneralMessageSymbolToMap:payload];
    }
}

-(void)addGeneralMessageSymbolToMap:(SimpleReportPayload*)payload{
    
    if([_dataManager getTrackingLayerEnabled:NSLocalizedString(@"SCOUT Field Reports",nil)]){
    
        MarkupFeature *feature = [[MarkupFeature alloc]init];
        feature.type = @"Field Report";
        feature.graphic = @"images/drawmenu/markers/helispot.png";
        feature.username = payload.messageData.user;
        feature.photoPath = payload.messageData.fullpath;
        feature.reportTypeAndId = [[Enums formTypeEnumToStringAbbrev:SR] stringByAppendingFormat:@"%@%@",@"~", payload.id];
        feature.seqtime = payload.seqtime;
        
        NSString* datestring = [[Utils getDateFormatter] stringFromDate:[NSDate dateWithTimeIntervalSince1970:[payload.seqtime longValue]/1000.0]];
        
        feature.featureattributes = [@"Field Report" stringByAppendingFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@",
                                     @"\n",NSLocalizedString(@"User:",nil),payload.messageData.user,
                                     @"\n",NSLocalizedString(@"Please Forward Information to:",nil),@":",payload.messageData.category,
                                     @"\n",NSLocalizedString(@"Description",nil),@":",payload.messageData.msgDescription,
                                     @"\n",
                                     payload.messageData.latitude,@" , ",payload.messageData.longitude,
                                     @"\n", datestring
                                     ];
        
        NSDate* date = [NSDate dateWithTimeIntervalSince1970:[payload.seqtime longLongValue]/1000.0];
        feature.lastupdate = [[Utils getDateFormatter] stringFromDate:date];
        
        feature.geometryFiltered =[NSArray arrayWithObjects:
                                   [NSArray arrayWithObjects:payload.messageData.latitude , payload.messageData.longitude ,nil],
                                   nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            MarkupReportSymbol *symbol = [[MarkupReportSymbol alloc] initWithMap:_mapView feature:feature];
            [_generalMessageSymbols setValue:symbol forKey:[@"sr" stringByAppendingString:[feature.seqtime stringValue]]];
        });
    }
}

-(void)clearDamageReportSymbolsFromMap{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSArray* keys = _damageReportSymbols.allKeys;
        for(NSString* key in keys){
            [[_damageReportSymbols objectForKey:key] removeFromMap];
        }
        [_damageReportSymbols removeAllObjects];
    });
}

-(void)DamageReportUpdateRecieved:(NSNotification *)notification{
    
    NSString* jsonString = [[notification userInfo] valueForKey:@"damageReportJson"];
    NSError* error = nil;
    DamageReportMessage *message = [[DamageReportMessage alloc] initWithString:jsonString error:&error];
    
    for(DamageReportPayload* payload in message.reports){
        [payload parse];
        [self addDamageReportSymbolToMap:payload];
    }
}

-(void)addAllDamageReportSymbolsToMap{
    for(DamageReportPayload* payload in [_dataManager getAllDamageReportsForIncidentId:[_dataManager getActiveIncidentId]]){
        [self addDamageReportSymbolToMap:payload];
    }
}


-(void)addDamageReportSymbolToMap:(DamageReportPayload*)payload{

    if([_dataManager getTrackingLayerEnabled:NSLocalizedString(@"SCOUT Damage Surveys",nil)]){
    
        MarkupFeature *feature = [[MarkupFeature alloc]init];
        feature.type = @"Damage Report";
        feature.graphic = @"images/drawmenu/markers/helispot.png";
        feature.username = payload.messageData.user;
        feature.photoPath = payload.messageData.drDfullPath;
        feature.reportTypeAndId = [[Enums formTypeEnumToStringAbbrev:DR] stringByAppendingFormat:@"%@%@",@"~", payload.id];
        feature.seqtime = payload.seqtime;
        
        NSString* datestring = [[Utils getDateFormatter] stringFromDate:[NSDate dateWithTimeIntervalSince1970:[payload.seqtime longValue]/1000.0]];
        
        feature.featureattributes = [@"Damage Report" stringByAppendingFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@",
                                     @"\n",NSLocalizedString(@"User:",nil),payload.messageData.user,
                                     @"\n",NSLocalizedString(@"Name",nil),@":",payload.messageData.drAownerFirstName, @" ", payload.messageData.drAownerLastName,
                                     @"\n",NSLocalizedString(@"Address",nil),@":",payload.messageData.drBpropertyAddress,
                                     @"\n",NSLocalizedString(@"City",nil),@":",payload.messageData.drBpropertyCity,
                                     @"\n",NSLocalizedString(@"Zip Code",nil),@":",payload.messageData.drBpropertyZipCode,
                                     @"\n",
                                     payload.messageData.drBpropertyLatitude,@" , ",payload.messageData.drBpropertyLongitude,
                                     @"\n", datestring
                                     ];
        
        NSDate* date = [NSDate dateWithTimeIntervalSince1970:[payload.seqtime longLongValue]/1000.0];
        feature.lastupdate = [[Utils getDateFormatter] stringFromDate:date];
        
        feature.geometryFiltered =[NSArray arrayWithObjects:
                                   [NSArray arrayWithObjects:payload.messageData.drBpropertyLatitude , payload.messageData.drBpropertyLongitude ,nil],
                                   nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            MarkupReportSymbol *symbol = [[MarkupReportSymbol alloc] initWithMap:_mapView feature:feature];
            [_damageReportSymbols setValue:symbol forKey:[@"dr" stringByAppendingString:[feature.seqtime stringValue]]];
        });
    }
}

-(UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker{

    ReportInfoWindow *infoWindow;
    if([_dataManager isIpad]){
        infoWindow= [[[NSBundle mainBundle] loadNibNamed:@"ReportInfoWindow" owner:self options:nil]objectAtIndex:0];
    }else{
        infoWindow= [[[NSBundle mainBundle] loadNibNamed:@"ReportInfoWindowSmall" owner:self options:nil]objectAtIndex:0];
    }
    
    infoWindow.label1.text = marker.snippet;
    infoWindow.mapview = _mapView;
    infoWindow.marker = marker;
    
    if([marker.title isEqualToString:@"marker"]){
        [infoWindow setupImage:marker.title];
        [self setOpenReportButtonVisible:false];
    }else if([marker.title isEqualToString:NSLocalizedString(@"Location", nil)]) {
         marker.snippet = [NSString stringWithFormat:@"%f%@%f", marker.position.latitude, @" , " , marker.position.longitude];
        [self setOpenReportButtonVisible:false];
        return nil; //uses default GMS info windows
    }else{
        NSArray* splitTitle = [marker.title componentsSeparatedByString: @"~"];
        if(splitTitle.count <= 1){  //not a report window
            
            [infoWindow setupImage: @"marker"];
            NSString *testString = marker.snippet;
            infoWindow.label1.text = marker.snippet;
            [self setOpenReportButtonVisible:false];
            
        }else{  //it is a report window
            infoWindow.reportType = splitTitle[0];
            infoWindow.reportId = splitTitle[1];
            [infoWindow setupImage:splitTitle[2]];
            
            [self setOpenReportButtonVisible:true];
        }
    }
    _currentReportWindow = infoWindow;

    return infoWindow;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    
    return view;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_markupShapes count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
	cell.backgroundColor = [UIColor clearColor];
	if(_markupShapes.count > 0) {
		MarkupBaseShape* shape;
		
		shape = [[_markupShapes allValues] objectAtIndex:indexPath.row];
		
		UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressCell:)];
		[cell addGestureRecognizer:longPressGesture];
		
		UILabel *label = (UILabel *)[cell.contentView viewWithTag:10];
		
		NSString* datestring = [[Utils getDateFormatter] stringFromDate:[NSDate dateWithTimeIntervalSince1970:[shape.feature.seqtime longValue]]];
		
		// Luis's truncated text fix: have to specify paragraph line break mode
		NSMutableParagraphStyle *timestampParagraphStyle = [[NSMutableParagraphStyle alloc] init];
		timestampParagraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
		NSDictionary *timestampAttributes = @{NSParagraphStyleAttributeName: timestampParagraphStyle};
		NSString *timestampString = [NSString stringWithFormat:@"%@%@%@", datestring, @" - ", shape.feature.username];
		label.attributedText = [[NSMutableAttributedString alloc] initWithString:timestampString attributes:timestampAttributes];
		
		// Old method of setting the label's text
		//label.text = [NSString stringWithFormat:@"%@%@%@", datestring, @" - ", shape.feature.username];
		
		UILabel *timeLabel = (UILabel *)[cell.contentView viewWithTag:20];
		timeLabel.text = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"Type: ",nil), shape.feature.type];
	}
	
	return cell;
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIView *selectedView = [[UIView alloc]init];
    selectedView.backgroundColor = [UIColor colorWithRed:0.1953125 green:0.5 blue:0.609375 alpha:1.0];
    
    if(indexPath.row >= _markupShapes.count){
        return indexPath;
    }
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selectedBackgroundView = selectedView;
    cell.backgroundColor = [UIColor clearColor];
    
    MarkupBaseShape* shape = [[_markupShapes allValues] objectAtIndex:indexPath.row];
    MarkupType type = [Enums convertToMarkupTypeFromString:shape.feature.type];

    if(type == segment || type == rectangle || type == polygon || type == circle || type == text) {
        GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithPath:[shape getPath]];
        GMSCameraUpdate *update = [GMSCameraUpdate fitBounds:bounds withPadding:50.f];
        
        [_mapView animateWithCameraUpdate:update];
    }else{
        CLLocationCoordinate2D positionCoordinate;
        [[shape.points objectAtIndex:0] getValue:&positionCoordinate];
        
        [_mapView animateToLocation:positionCoordinate];
        [_mapView animateToZoom:mapZoomLevel];
    }

    _mapView.selectedMarker = nil;
    [self setOpenReportButtonVisible:false];
    
    return indexPath;
}

- (void)longPressCell:(UILongPressGestureRecognizer *)gesture
{

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

}

-(void)checkIosVersionThenWfsUpdate
{
#if !(TARGET_IPHONE_SIMULATOR)
    
//         dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);dispatch_async(queue, ^{
             [self updateWfsLayers];
//         });
#else
          dispatch_async(dispatch_get_main_queue(), ^{
              [self updateWfsLayers];});
#endif
}

- (void)updateWfsLayers{
    
        NSMutableArray* wfsFeatures = [ActiveWfsLayerManager GetAllActiveFeatures];
        
    //clear old markers
//    for (GMSMarker *currentMarker in _wfsMarkers)
    for(int i = 0; i < _wfsMarkers.count;i++)
    {
        GMSMarker* marker = [_wfsMarkers objectAtIndex:i];
        marker.map = nil;
    }
    [_wfsMarkers removeAllObjects];

    for ( WfsFeature *currentFeature in wfsFeatures)
    {
    CLLocationCoordinate2D markerLocation = CLLocationCoordinate2DMake([currentFeature.latitude doubleValue],[currentFeature.longitude doubleValue]);
    GMSMarker *marker = [GMSMarker markerWithPosition: markerLocation];
    marker.appearAnimation = kGMSMarkerAnimationNone;
        
        UIImage* image;
        
    if([currentFeature.age integerValue] > 1440){
         image = [UIImage imageNamed:@"mdt_dot_stale.png"];
        marker.icon = image;
    }else if([currentFeature.speed integerValue] > 0){
        image = [UIImage imageNamed:@"mdt_dot_directional.png"];
        
        
        //rotate image to match course. this could be moved into the utils script as a more general purpose image rotating tool
        CGSize size = image.size;
        
        UIGraphicsBeginImageContext(size);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(context ,0.5f * image.size.width, 0.5 * image.size.height);
        CGContextRotateCTM(context, [currentFeature.course doubleValue] * M_PI/180);
        [ image drawInRect:(CGRect){ { -size.width * 0.5f, -size.height * 0.5f }, size } ] ;
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        marker.icon = newImage;
        
    }else{
        image = [UIImage imageNamed:@"mdt_dot.png"];
        marker.icon = image;
    }
    
    marker.map = _mapView;
    marker.title = @"mdt_dot_directional.png";
        
    NSString* windowString = @"";
        
    for (NSString* key in currentFeature.propertiesDictionary) {
        
        
        if([key isEqualToString:@"properties"]){
            
            NSMutableDictionary* propertiesDictionary = [currentFeature.propertiesDictionary objectForKey:key];
            
            for (NSString* propKey in propertiesDictionary) {
                
                NSObject* propValue = [propertiesDictionary objectForKey:propKey];
                
                if([propValue isKindOfClass:[NSString class]]){
                    windowString = [windowString stringByAppendingString:propKey];
                    windowString = [windowString stringByAppendingString:@" : "];
                    if(propValue == nil){
                        windowString = [windowString stringByAppendingString:@"n/a"];
                    }else{
                        windowString = [windowString stringByAppendingString:propValue];
                    }
                    windowString = [windowString stringByAppendingString:@"\n"];
                }
            }
            
        }else if([key isEqualToString:@"geometry"]){
            NSArray* coordinate = currentFeature.propertiesDictionary[@"geometry"][@"coordinates"];
            NSNumber *lat = [NSNumber numberWithDouble:[coordinate[0] doubleValue]];
            NSNumber *lon = [NSNumber numberWithDouble:[coordinate[1] doubleValue]];
            
            windowString = [windowString stringByAppendingString:[lat stringValue]];
            windowString = [windowString stringByAppendingString:@" , "];
            windowString = [windowString stringByAppendingString:[lon stringValue]];
            windowString = [windowString stringByAppendingString:@"\n"];
            
        }else{
            NSObject* value = [currentFeature.propertiesDictionary objectForKey:key];
            
            if([value isKindOfClass:[NSString class]]){
                windowString = [windowString stringByAppendingString:key];
                windowString = [windowString stringByAppendingString:@" : "];
                if(value == nil){
                    windowString = [windowString stringByAppendingString:@"n/a"];
                }else{
                    windowString = [windowString stringByAppendingString:value];
                }
                windowString = [windowString stringByAppendingString:@"\n"];
            }
            
        }
    }
        
    marker.snippet = windowString;
        
    [_wfsMarkers addObject:marker];
    }
}

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    
    if(_mapEditView.CurrentView == TypeSelectView){
    
        _myCustomMarker.map = _mapView;
        _myCustomMarker.position = coordinate;
        _myCustomMarker.title = NSLocalizedString(@"Location", nil);
        
        self.dataManager.mapSelectedLatitude =coordinate.latitude;
        self.dataManager.mapSelectedLongitude =coordinate.longitude;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"mapCustomLocationChanged" object:nil];
    
    }else if(_editMapPanelOpen){
        [_mapEditView MapDidTapAtCoordinate:coordinate];
    }
    
    [self setOpenReportButtonVisible:false];
    
//    [self.navigationController popViewControllerAnimated:YES];
    
}

-(void)mapView:(GMSMapView *)mapView didDragMarker:(GMSMarker *)marker{
    if(_editMapPanelOpen){
        [_mapEditView MapViewMarkerDidDrag:marker];
    }

}

-(void)setOpenReportButtonVisible:(bool)isVisible{
    
    if(isVisible){
        [_gotoReportButton setHidden:FALSE];
        [_gotoReportButton setEnabled:TRUE];
    }else{
        [_gotoReportButton setHidden:TRUE];
        [_gotoReportButton setEnabled:FALSE];
    }
}

-(void)GotoReport{

    if(_currentReportWindow!=nil){
        if([_dataManager isIpad]){
            
            NSMutableDictionary* reportInfo = [[NSMutableDictionary alloc]init];
            [reportInfo setObject:_currentReportWindow.reportId forKey:@"reportId"];
            [reportInfo setObject:_currentReportWindow.reportType forKey:@"reportType"];
            
            NSNotification *GotoReportDetailViewNotification = [NSNotification notificationWithName:@"GotoReportDetailView" object:reportInfo];
            [[NSNotificationCenter defaultCenter] postNotification:GotoReportDetailViewNotification];
            
//            if(myPopOver != nil){ //close fullscreen map if open
//               [myPopOver dismissPopoverAnimated:YES];
//               myPopOver = nil;
//            }
            
        }else if([_currentReportWindow.reportType isEqualToString:[Enums formTypeEnumToStringAbbrev:SR]]){
            NSMutableArray *generalMessages = [_dataManager getAllSimpleReportsForIncidentId:[_dataManager getActiveIncidentId]];
            
            for(int i = 0; i < generalMessages.count;i++){
                SimpleReportPayload* payload = [generalMessages objectAtIndex:i];
                
                if([_currentReportWindow.reportId isEqualToString: [payload.id stringValue]]){
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
                    SimpleReportDetailViewController *detailViewController = [storyboard instantiateViewControllerWithIdentifier:@"GeneralMessageDetailSceneID"];
                    detailViewController.payload = payload;
                    detailViewController.hideEditControls = YES;
                    
                    [self.navigationController pushViewController: detailViewController animated:YES];
                }
            }
        }else if([_currentReportWindow.reportType isEqualToString:[Enums formTypeEnumToStringAbbrev:DR]]){
            NSMutableArray *damageReports = [_dataManager getAllDamageReportsForIncidentId:[_dataManager getActiveIncidentId]];
            
            for(int i = 0; i < damageReports.count;i++){
                DamageReportPayload* payload = [damageReports objectAtIndex:i];
                
                if([_currentReportWindow.reportId isEqualToString: [payload.id stringValue]]){
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
                    DamageReportDetailViewController *detailViewController = [storyboard instantiateViewControllerWithIdentifier:@"DamageReportDetailSceneID"];
                    detailViewController.payload = payload;
                    detailViewController.hideEditControls = YES;
                    
                    [self.navigationController pushViewController: detailViewController animated:YES];
                }
            }
        }

    }
}

-(void)zoomToPositionOnMapOpen:(double)lat : (double) lon{

    CLLocationCoordinate2D positionCoordinate;
    positionCoordinate.latitude=lat;
    positionCoordinate.longitude=lon;
    
    _zoomingToReport = true;
    _positionToZoomTo = positionCoordinate;
}

-(void)SetMapPosition:(NSNotification *)notification{
    
    CLLocationCoordinate2D positionCoordinate;
    positionCoordinate.latitude=[[[notification userInfo] valueForKey:@"lat"] doubleValue];
    positionCoordinate.longitude=[[[notification userInfo] valueForKey:@"lon"] doubleValue];
    
    
    
    [_mapView animateToLocation:positionCoordinate];
    [_mapView animateToZoom:mapZoomLevel];


_mapView.selectedMarker = nil;
[self setOpenReportButtonVisible:false];

}

-(void)SetMapCustomMarkerPosition:(NSNotification *)notification{
    
    CLLocationCoordinate2D positionCoordinate;
    positionCoordinate.latitude=[[[notification userInfo] valueForKey:@"lat"] doubleValue];
    positionCoordinate.longitude=[[[notification userInfo] valueForKey:@"lon"] doubleValue];
    
    [_myCustomMarker setPosition:positionCoordinate];
}

- (void) updateTitle:(NSString *)title {
    self.title = title;
}

-(void)setPopoverButtons{
//    UIImage *image = [UIImage imageNamed:@"exit_fullscreen_button.png"];
//    [_fullscreenButton setImage:image forState:UIControlStateNormal];
    
    [_extendMapButton setHidden:TRUE];
    [_editMapButton setHidden:TRUE];
    _editMapPanelOpen = TRUE;
}

-(void)recieveMapType:(NSNotification *)notification{
    _mapView.mapType =  [[[notification userInfo] valueForKey:@"mapType"] intValue];
    _mapView.trafficEnabled = [[[notification userInfo] valueForKey:@"trafficDisplay"] boolValue];
    _mapView.indoorEnabled = [[[notification userInfo] valueForKey:@"indoorDisplay"] boolValue];
}

- (GMSMarker*)getCustomMarker{
    return self.myCustomMarker;
}

-(void)setUiViewControllerToReturnTo:(UIViewController*)controller{
    self.previousViewToReturnTo = controller;
}

-(void) setCustomSymbol:(NSString*)imageName{
    [_myCustomMarker setIcon:[UIImage imageNamed:imageName]];
}

-(void) hideCustomMarker{
    _myCustomMarker.map = nil;
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    if(_editMapPanelOpen){
        [Utils AdjustViewForKeyboard:self.view :true: _originalFrame:aNotification];
    }
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    if(_editMapPanelOpen){
        [Utils AdjustViewForKeyboard:self.view :FALSE:_originalFrame :aNotification];
    }
}

-(void)refreshButtonPressed{
    [_dataManager requestMarkupFeaturesRepeatedEvery:[[DataManager getMapUpdateFrequencyFromSettings] intValue] immediate:YES];
}

-(void)refreshView{
    [self redrawLocalMapFeatures];
}

-(void)MapSettingsBarButtonPressed{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    UIViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"MapSettingsViewControllerID"];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)startCollabLoadingSpinner{
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        _mapMarkupLoadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        [_mapMarkupLoadingIndicator startAnimating];
    });
    
}

-(void)stopCollabLoadingSpinner{
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [_mapMarkupLoadingIndicator stopAnimating];
    });
    
}

@end
