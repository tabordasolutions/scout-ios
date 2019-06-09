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

#import "OverviewViewControllerTablet.h"
#import "IncidentButtonBar.h"

@interface OverviewViewControllerTablet ()
@property CGFloat mapViewOriginalWidth;
@property CGFloat chatViewOriginalWidth;

@end


NSNotificationCenter *notificationCenter;

@implementation OverviewViewControllerTablet   
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	_dataManager = [DataManager getInstance];
	[IncidentButtonBar SetOverview:self];
	[_dataManager setOverviewController:self];
	
	
	
	notificationCenter = [NSNotificationCenter defaultCenter];
	_mapViewOriginalWidth = 580;
	_chatViewOriginalWidth = 444;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SetPullTimersFromOptions) name:@"DidBecomeActive" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startCollabLoadingSpinner) name:@"collabroomStartedLoading" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopCollabLoadingSpinner) name:@"collabroomFinishedLoading" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(expandMapView) name:@"expandMapView" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contractMapview) name:@"contractMapView" object:nil];
	
	[self SetPullTimersFromOptions];
	[[MultipartPostQueue getInstance] addCachedReportsToSendQueue];
	
	
	self.navigationItem.hidesBackButton = YES;
	
	[_dataManager.locationManager startUpdatingLocation];
	
	NSString *currentIncidentName = [_dataManager getActiveIncidentName];
	
	
	// Make sure our current incident is in the list of incidents:
	if(currentIncidentName != nil){
		_selectedIncident = [[_dataManager getIncidentsList] objectForKey:currentIncidentName];
		if(_selectedIncident == nil)
		{
			currentIncidentName = nil;
		}
		[_dataManager setActiveIncident:_selectedIncident];
	}
	
	if(currentIncidentName != nil){
		_selectedIncident = [[_dataManager getIncidentsList] objectForKey:currentIncidentName];
		if(_selectedIncident != nil){
			[_dataManager requestCollabroomsForIncident:_selectedIncident];
			_selectedIncident.collabrooms = [_dataManager getCollabroomPayloadArray];
			//            _selectedCollabroomList = _selectedIncident.collabrooms;
		}
		
	}
	
	NSString *currentRoomName = [_dataManager getSelectedCollabroomName];
	if(currentRoomName != nil){
		for(CollabroomPayload *collabroomPayload in _selectedIncident.collabrooms) {
			if([collabroomPayload.name isEqualToString:currentRoomName]){
				_selectedCollabroom = collabroomPayload;
				[_dataManager setSelectedCollabRoomId:collabroomPayload.collabRoomId  collabRoomName:collabroomPayload.name];
			}
		}
	}
	
	[_IncidentCanvas setHidden:FALSE];
	[IncidentCanvasUIViewController updateViewForInIncident:(_selectedIncident != nil) InRoom:(_selectedCollabroom != nil)];
	
	if(_selectedIncident == nil)
	{
		[_selectIncidentButton setTitle:NSLocalizedString(@"Select Incident", nil) forState:UIControlStateNormal];
		[_selectRoomButton setHidden:TRUE];
		[_collabroomDownArrowImage setHidden:TRUE];
		[_selectIncidentHelperLabel setHidden:false];
	}
	else
	{
		[_selectRoomButton setHidden:FALSE];
		[_collabroomDownArrowImage setHidden:FALSE];
		[_selectIncidentHelperLabel setHidden:true];
		[_selectIncidentButton setTitle:_selectedIncident.incidentname forState:UIControlStateNormal];
		
		NSNotification *IncidentSwitchedNotification = [NSNotification notificationWithName:@"IncidentSwitched" object:_selectedIncident.incidentname];
		[notificationCenter postNotification:IncidentSwitchedNotification];
		
		[_dataManager requestSimpleReportsRepeatedEvery:[[DataManager getReportsUpdateFrequencyFromSettings] intValue] immediate:YES];
		[_dataManager requestReportOnConditionsRepeatedEvery:[[DataManager getReportsUpdateFrequencyFromSettings] intValue] immediate:YES];
		[_dataManager requestDamageReportsRepeatedEvery:[[DataManager getReportsUpdateFrequencyFromSettings] intValue] immediate:YES];
		[_dataManager requestFieldReportsRepeatedEvery:[[DataManager getReportsUpdateFrequencyFromSettings] intValue] immediate:YES];
		[_dataManager requestResourceRequestsRepeatedEvery:[[DataManager getReportsUpdateFrequencyFromSettings] intValue] immediate:YES];
		[_dataManager requestMdtRepeatedEvery:[DataManager getMdtUpdateFrequencyFromSettings] immediate:YES];
		[_dataManager requestWfsUpdateRepeatedEvery:[[DataManager getWfsUpdateFrequencyFromSettings] intValue] immediate:YES];
		[_dataManager requestWeatherReportsRepeatedEvery:[[DataManager getReportsUpdateFrequencyFromSettings] intValue] immediate:YES];
	}
	
	if(_selectedCollabroom == nil)
	{
		[_selectRoomButton setTitle:NSLocalizedString(@"Select Room", nil) forState:UIControlStateNormal];
	}
	else
	{
		[_dataManager setSelectedCollabRoomId:_selectedCollabroom.collabRoomId collabRoomName:_selectedCollabroom.name];
		NSString* incidentNameReplace = [_selectedIncident.incidentname stringByAppendingString:@"-"];
		[_selectRoomButton setTitle:[_selectedCollabroom.name stringByReplacingOccurrencesOfString:incidentNameReplace withString:@""] forState:UIControlStateNormal];
		NSNotification *IncidentSwitchedNotification = [NSNotification notificationWithName:@"CollabRoomSwitched" object:_selectedIncident.incidentname];
		[notificationCenter postNotification:IncidentSwitchedNotification];
		[_dataManager requestChatMessagesRepeatedEvery:[[DataManager getChatUpdateFrequencyFromSettings] intValue] immediate:YES];
		[_dataManager requestMarkupFeaturesRepeatedEvery:[[DataManager getMapUpdateFrequencyFromSettings] intValue] immediate:YES];
	}
}

-(void)expandMapView {
	CGFloat maxWidth = self.view.layer.frame.size.width;
	self.mapViewWidth.constant = maxWidth;
	self.chatViewWidth.constant = 0;
	[self.view setNeedsLayout];
}

-(void)contractMapview {
	self.mapViewWidth.constant = _mapViewOriginalWidth;
	self.chatViewWidth.constant = _chatViewOriginalWidth;
	[self.view setNeedsLayout];
}
-(void)SetPullTimersFromOptions{
	[_dataManager requestChatMessagesRepeatedEvery:[[DataManager getChatUpdateFrequencyFromSettings] intValue] immediate:NO];
	[_dataManager requestSimpleReportsRepeatedEvery:[[DataManager getReportsUpdateFrequencyFromSettings] intValue] immediate:NO];
	[_dataManager requestReportOnConditionsRepeatedEvery:[[DataManager getReportsUpdateFrequencyFromSettings] intValue] immediate:YES];
	[_dataManager requestDamageReportsRepeatedEvery:[[DataManager getReportsUpdateFrequencyFromSettings] intValue] immediate:NO];
	[_dataManager requestFieldReportsRepeatedEvery:[[DataManager getReportsUpdateFrequencyFromSettings] intValue] immediate:NO];
	[_dataManager requestResourceRequestsRepeatedEvery:[[DataManager getReportsUpdateFrequencyFromSettings] intValue] immediate:NO];
	[_dataManager requestMarkupFeaturesRepeatedEvery:[[DataManager getMapUpdateFrequencyFromSettings] intValue] immediate:NO];
	[_dataManager requestMdtRepeatedEvery:[DataManager getMdtUpdateFrequencyFromSettings] immediate:NO];
	[_dataManager requestWfsUpdateRepeatedEvery:[[DataManager getWfsUpdateFrequencyFromSettings] intValue] immediate:NO];
	[_dataManager requestWeatherReportsRepeatedEvery:[[DataManager getReportsUpdateFrequencyFromSettings] intValue] immediate:NO];
}


// This method shows the dialog for the user to select an incident
- (IBAction)selectIncidentButtonPressed:(UIButton *)button
{
	// Create a new incident menu to clear the old one
	NSDictionary *allIncidents = _dataManager.incidentsList;
	NSArray *allIncidentNames = [allIncidents allKeys];
	
	
	// Creating tuples of the incident names and their creation dates...
	NSMutableArray *incidentNamesAndCreationDates = [NSMutableArray new];
	
	for(NSString *incidentName in allIncidentNames)
	{
		IncidentPayload *incident = [allIncidents objectForKey:incidentName];
		
		if(incident == nil)
			continue;
		[incidentNamesAndCreationDates addObject:@[incidentName, [NSNumber numberWithLongLong:incident.created]]];
	}
	
	
	// Sorting the incident names by creation date:
	[incidentNamesAndCreationDates sortUsingComparator:^NSComparisonResult(id elementA, id elementB) {
		NSNumber *creationDateA = ((NSArray*)elementA)[1];
		NSNumber *creationDateB = ((NSArray*)elementB)[1];
		return [creationDateB compare:creationDateA];
	}];
	
	
	UIAlertController *incidentNameAlertController = [UIAlertController alertControllerWithTitle:@"Select Incident" message:nil preferredStyle:UIAlertControllerStyleAlert];
	
	// Adding a "None" button at index 0
	[incidentNameAlertController addAction:[UIAlertAction actionWithTitle:@"None" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		// do something
		NSLog(@"Selected \"None\"");
		[self joinIncident:nil];
	}]];
	
	
	// Adding all incident names to the view
	
	// FIXME - For now, only pull the top 20 (the dialog slows down with too many elements)
	int namesToBringIn = 50;
	
	for(NSArray *array in incidentNamesAndCreationDates)
	{
		if(namesToBringIn <= 0)
			break;
		[incidentNameAlertController addAction:[UIAlertAction actionWithTitle:array[0] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
			// do something
			NSLog(@"Selected incident with name: \"%@\"",array[0]);
			[self joinIncident:array[0]];
		}]];
		
		namesToBringIn--;
		
		NSLog(@"Added incident to list: %@",array[0]);
	}
	
	
	//adding a cancel button
	[incidentNameAlertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		[self dismissViewControllerAnimated:YES completion:nil];
	}]];
	
	
	
	[self presentViewController:incidentNameAlertController animated:YES completion:nil];
}



- (IBAction)selectRoomButtonPressed:(UIButton *)button {
	
	NSMutableDictionary *collabrooms = [NSMutableDictionary new];
	
	for(CollabroomPayload *collabroomPayload in _selectedIncident.collabrooms) {
		[collabrooms setObject:collabroomPayload.collabRoomId forKey:collabroomPayload.name];
	}
	
	if(_selectedIncident.collabrooms != nil) {
		[_dataManager clearCollabRoomList];
		
		for(CollabroomPayload *payload in _selectedIncident.collabrooms) {
			[_dataManager addCollabroom:payload];
		}
	}
	
	NSArray * sortedCollabrooms = [[collabrooms allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
	
	_collabroomMenu = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Select Room", nil) delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
	
	NSString *replaceString = @"";
	replaceString = [_selectedIncident.incidentname stringByAppendingString:@"-"];
	
	for( NSString *title in sortedCollabrooms)  {
		[_collabroomMenu addButtonWithTitle:[title stringByReplacingOccurrencesOfString:replaceString withString:@""]];
	}
	
	[_collabroomMenu addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
	_collabroomMenu.cancelButtonIndex = [sortedCollabrooms count];
	
	
	[_collabroomMenu showInView:self.parentViewController.view];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[_dataManager.locationManager stopUpdatingLocation];
}

//fix for ghosting effect on ios7
- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
	actionSheet.backgroundColor = [UIColor whiteColor];
	for (UIView *subview in actionSheet.subviews) {
		subview.backgroundColor = [UIColor whiteColor];
	}
}




- (void) updateUIForSelectedIncidentAndCollabroom
{
	// Replace occurances of the incident name in the collabroom name
	NSString *replaceString = @"";
	

	NSNotification *IncidentSwitchedNotification = nil;
	NSNotification *CollabRoomSwitchedNotification = nil;
	
	[_IncidentCanvas setHidden:FALSE];
	[IncidentCanvasUIViewController updateViewForInIncident:(_selectedIncident != nil) InRoom:(_selectedCollabroom != nil)];
	
	
	if(_selectedIncident != nil)
	{
		//-----------------------------------
		// Updating the DataMAnager
		//-----------------------------------
		[_dataManager setActiveIncident:_selectedIncident];
		
		//-----------------------------------
		// Updating the UI View
		//-----------------------------------
		[_selectIncidentButton setTitle:_selectedIncident.incidentname forState:UIControlStateNormal];
		[_selectRoomButton setHidden:NO];
		[_collabroomDownArrowImage setHidden:NO];
		[_selectIncidentHelperLabel setHidden:YES];
		
		//-----------------------------------
		// Requesting data for the incident
		//-----------------------------------
		[_dataManager requestSimpleReportsRepeatedEvery:[[DataManager getReportsUpdateFrequencyFromSettings] intValue] immediate:YES];
		[_dataManager requestReportOnConditionsRepeatedEvery:[[DataManager getReportsUpdateFrequencyFromSettings] intValue] immediate:YES];
		[_dataManager requestDamageReportsRepeatedEvery:[[DataManager getReportsUpdateFrequencyFromSettings] intValue] immediate:YES];
		[_dataManager requestFieldReportsRepeatedEvery:[[DataManager getReportsUpdateFrequencyFromSettings] intValue] immediate:YES];
		[_dataManager requestResourceRequestsRepeatedEvery:[[DataManager getReportsUpdateFrequencyFromSettings] intValue] immediate:YES];
		[_dataManager requestMdtRepeatedEvery:[DataManager getMdtUpdateFrequencyFromSettings] immediate:YES];
		[_dataManager requestWfsUpdateRepeatedEvery:[[DataManager getWfsUpdateFrequencyFromSettings] intValue] immediate:YES];
		[_dataManager requestWeatherReportsRepeatedEvery:[[DataManager getReportsUpdateFrequencyFromSettings] intValue] immediate:YES];
		
		//-----------------------------------
		// Broadcasting a notification
		//-----------------------------------
		IncidentSwitchedNotification = [NSNotification notificationWithName:@"IncidentSwitched" object:_selectedIncident.incidentname];
		
	}
	else
	{
		//-----------------------------------
		// Updating the DataManager
		//-----------------------------------
		[_dataManager setActiveIncident:nil];
		_selectedCollabroom = nil;
		[_dataManager setSelectedCollabRoomId:@-1 collabRoomName:@"N/A"];
		
		//-----------------------------------
		// Updating the UI View
		//-----------------------------------
		[_selectRoomButton setHidden:true];
		[_collabroomDownArrowImage setHidden:TRUE];
		[_selectIncidentHelperLabel setHidden:false];
		
		[_selectIncidentButton setTitle:NSLocalizedString(@"Select Incident", nil) forState:UIControlStateNormal];
	}
	
	if(_selectedCollabroom != nil)
	{
		replaceString = [_selectedIncident.incidentname stringByAppendingString:@"-"];
		[_dataManager setSelectedCollabRoomId:_selectedCollabroom.collabRoomId collabRoomName:_selectedCollabroom.name];
		[_dataManager requestChatMessagesRepeatedEvery:[[DataManager getChatUpdateFrequencyFromSettings] intValue] immediate:YES];
		[_dataManager requestMarkupFeaturesRepeatedEvery:[[DataManager getMapUpdateFrequencyFromSettings] intValue] immediate:YES];
		
		//  [_selectRoomButton setTitle:_selectedCollabroom.name forState:UIControlStateNormal];
		[_selectRoomButton setTitle:[_selectedCollabroom.name stringByReplacingOccurrencesOfString:replaceString withString:@""] forState:UIControlStateNormal];
		CollabRoomSwitchedNotification = [NSNotification notificationWithName:@"CollabRoomSwitched" object:_selectedCollabroom.name ];
	}
	else
	{
		[_selectRoomButton setTitle:NSLocalizedString(@"Select Room", nil) forState:UIControlStateNormal];
	}
	
	if(IncidentSwitchedNotification!=nil)
	{
		[notificationCenter postNotification:IncidentSwitchedNotification];
	}
	if(CollabRoomSwitchedNotification!=nil)
	{
		[notificationCenter postNotification:CollabRoomSwitchedNotification];
	}
}



- (void) joinIncident:(NSString *)selectedIncidentName
{
	// If incidentname is nil, leave the current incident
	if(selectedIncidentName == nil)
	{
		_selectedIncident = nil;
		// Pull the latest incidents from the server
		[RestClient getAllIncidentsForUserId:[_dataManager getUserId]];
	}
	// otherwise, join the incident for that name
	else
	{
		_selectedIncident = [_dataManager.incidentsList objectForKey:selectedIncidentName];
		
		// Update the list of collabrooms, and leave the current collabroom
		[_dataManager requestCollabroomsForIncident:_selectedIncident];
		_selectedIncident.collabrooms = [_dataManager getCollabroomPayloadArray];
		[_dataManager setSelectedCollabRoomId:@-1 collabRoomName:@"N/A"];
		_selectedCollabroom = nil;
	}
	
	[self updateUIForSelectedIncidentAndCollabroom];
}


// Called when a user selects a collabroom from the UI
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex != _collabroomMenu.cancelButtonIndex)
	{
		NSString* selectedRoom = [actionSheet buttonTitleAtIndex:buttonIndex];
		
		_selectedCollabroom = [[_dataManager getCollabroomList] objectForKey:[[_dataManager getCollabroomNamesList] objectForKey:selectedRoom]];
		
		[_selectRoomButton setHidden:false];
		[_collabroomDownArrowImage setHidden:FALSE];
	}
	
	[self updateUIForSelectedIncidentAndCollabroom];
}

- (IBAction)nicsHelpButtonPressed:(id)sender {
	NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
	if(!settingsBundle) {
		NSLog(@"Could not find Settings.bundle");
	}
	
	NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Root.plist"]];
	NSDictionary *preferences = [settings objectForKey:@"Keys"];
	NSString *helpURLString = preferences[@"ScoutHelp"];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:helpURLString]];
}

-(void)startCollabLoadingSpinner{
	dispatch_async(dispatch_get_main_queue(), ^(void) {
		[_collabroomsLoadingIndicator startAnimating];
	});
	
}

-(void)stopCollabLoadingSpinner{
	dispatch_async(dispatch_get_main_queue(), ^(void) {
		[_collabroomsLoadingIndicator stopAnimating];
		_selectedIncident.collabrooms = [_dataManager getCollabroomPayloadArray];
	});
}

-(void)navigateBackToLoginScreen{
	[self.navigationController popToRootViewControllerAnimated:YES];
}

// This method is called when we receive a specific response code from the servser
// indicating the the user has logged in on a different device
// Thus, we want to notify the user and close the application.
-(void) showDuplicateLoginWarning:(BOOL) fromFR{
	
	NSLog(@"USIDDEFECT, attempting to relogin with credentials: %@, %@",[_dataManager getUsername],[_dataManager getPassword]);
	NSLog(@"USIDDEFECT, using the new method, the credentials are: %@, %@",_dataManager.curSessionUsername,_dataManager.curSessionPassword);
	
	NSString *title = @"Warning";
	NSString *message = @"You have logged into SCOUT on a different device\nYou have been logged out of this session\nPlease click Re-Login to continue using SCOUT\nYour other session will be logged out if you Re-login on this device\nOR\nPress Okay to close the application";
	
	if(fromFR)
		message = @"You have logged into SCOUT on a different device\nYou have been logged out of this session\nPlease click Re-Login to complete the Field Report submission\nYour other session will be logged out if you Re-login on this device\nOR\nPress Okay to close the application";
	
	
	UIAlertController * alert= [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
	
	UIAlertAction* reloginButton = [UIAlertAction actionWithTitle:@"Re-Login" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
		//[RestClient logoutUser:[_dataManager getUsername]];
		@try {
			[RestClient loginUser:[_dataManager getUsername] password:[_dataManager getPassword] completion:^(BOOL successful, NSString* msg) {
				// Upon completion:
				NSLog(@"USIDDEFECT, Resume Sending Reports about to be called... this must be asynchronous:");
				[[MultipartPostQueue getInstance] resumeSendingReports];
			}];
		}
		@catch (NSException *e) {
			NSLog(@"USIDDEFECT, caught exception: %@",e);
		}
		//FIXME: This won't work 100% of the time, password is only stored if "autoLogin" is true,
	}];
	
	UIAlertAction* okayButton = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
		exit(0);
	}];
	
	[alert addAction: reloginButton];
	[alert addAction:okayButton];
	
	[self presentViewController:alert animated:YES completion:nil];
}

@end
