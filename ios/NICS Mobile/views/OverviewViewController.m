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

#import "OverviewViewController.h"

@interface OverviewViewController ()

@end

// Used by the shared delegate to differentiate the 3 UIActionSheets
// (.tag is set after instantiation, then read in the clickedButtonAtIndex delegate)
const int TAG_REPORTS_MENU = 60;
const int TAG_INCIDENT_MENU = 50;
const int TAG_COLLABROOM_MENU = 40;

@implementation OverviewViewController
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	_dataManager = [DataManager getInstance];
	
	self.navigationItem.hidesBackButton = YES;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SetPullTimersFromOptions) name:@"DidBecomeActive" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startCollabLoadingSpinner) name:@"collabroomStartedLoading" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopCollabLoadingSpinner) name:@"collabroomFinishedLoading" object:nil];
	[self SetPullTimersFromOptions];
	[[MultipartPostQueue getInstance] addCachedReportsToSendQueue];
	
	[_dataManager.locationManager startUpdatingLocation];
	[_dataManager setOverviewController:self];
	
	_incidentContainerView.layer.borderColor = [UIColor whiteColor].CGColor;
	_incidentContainerView.layer.borderWidth = 2.0f;
	
	_roomContainerView.layer.borderColor = [UIColor whiteColor].CGColor;
	_roomContainerView.layer.borderWidth = 2.0f;
	
	_incidentMenu = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Select Incident",nil) delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
	
	_incidentMenu.tag = TAG_INCIDENT_MENU;
	
	NSMutableArray *incidentNameOptions = [NSMutableArray arrayWithArray:[[[_dataManager getIncidentsList] allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
	
	NSMutableArray *sortedIncidentNameOptions;
	// Sorting the incidents by creation date
	sortedIncidentNameOptions = [NSMutableArray arrayWithArray:[incidentNameOptions sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
		IncidentPayload *incidentA = [[_dataManager incidentsList] objectForKey:(NSString*)a];
		IncidentPayload *incidentB = [[_dataManager incidentsList] objectForKey:(NSString*)b];
		
		// Flip the order because we want to sort from newest to oldest (most recent date first)
		return [[NSNumber numberWithLongLong:[incidentB created]] compare:[NSNumber numberWithLongLong:[incidentA created]]];
	}]];
	
	// Adding "None" option to incidents list to allow the user to leave their selected incident
	[sortedIncidentNameOptions insertObject:@"None" atIndex:0];

	
	for( NSString *title in sortedIncidentNameOptions)  {
		[_incidentMenu addButtonWithTitle:title];
	}
	
	[_incidentMenu addButtonWithTitle:NSLocalizedString(@"Cancel",nil)];
	_incidentMenu.cancelButtonIndex = [sortedIncidentNameOptions count];
	
	
	NSString *currentIncidentName = [_dataManager getActiveIncidentName];
	
	
	// Make sure our current incident is in the list of incidents:
	if(currentIncidentName != nil){
		_selectedIncident = [[_dataManager getIncidentsList] objectForKey:currentIncidentName];
		if(_selectedIncident == nil)
		{
			[_dataManager setActiveIncident:nil];
			currentIncidentName = nil;
		}
	}
	
	if(currentIncidentName != nil){
		_selectedIncident = [[_dataManager getIncidentsList] objectForKey:currentIncidentName];
		[_dataManager requestCollabroomsForIncident:_selectedIncident];
		_selectedIncident.collabrooms = [_dataManager getCollabroomPayloadArray];
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
	
	// Reports button should always be visible
	// (ROC Reports do not require an active incident)
	[_ReportsButtonView setHidden:NO];

	
	if(_selectedIncident == nil) {
		[_selectIncidentButton setTitle:NSLocalizedString(@"Select Incident",nil) forState:UIControlStateNormal];
		[_selectRoomButton setHidden:TRUE];
		[_ChatButtonView setHidden:TRUE];
		[_GeneralMessageButtonView setHidden:TRUE];
	}else{
		[_selectRoomButton setHidden:FALSE];
		[_selectIncidentButton setTitle:_selectedIncident.incidentname forState:UIControlStateNormal];
		
		NSNotification *IncidentSwitchedNotification = [NSNotification notificationWithName:@"IncidentSwitched" object:_selectedIncident.incidentname];
		
		[_dataManager requestSimpleReportsRepeatedEvery:[[DataManager getReportsUpdateFrequencyFromSettings] intValue] immediate:YES];
		[_dataManager requestReportOnConditionsRepeatedEvery:[[DataManager getReportsUpdateFrequencyFromSettings] intValue] immediate:YES];
		[_dataManager requestDamageReportsRepeatedEvery:[[DataManager getReportsUpdateFrequencyFromSettings] intValue] immediate:YES];
		[_dataManager requestFieldReportsRepeatedEvery:[[DataManager getReportsUpdateFrequencyFromSettings] intValue] immediate:YES];
		[_dataManager requestResourceRequestsRepeatedEvery:[[DataManager getReportsUpdateFrequencyFromSettings] intValue] immediate:YES];
		[_dataManager requestMdtRepeatedEvery:[DataManager getMdtUpdateFrequencyFromSettings] immediate:YES];
		[_dataManager requestWfsUpdateRepeatedEvery:[[DataManager getWfsUpdateFrequencyFromSettings] intValue] immediate:YES];
	}
	
	if(_selectedCollabroom == nil){
		[_selectRoomButton setTitle:NSLocalizedString(@"Select Room",nil) forState:UIControlStateNormal];
		[_ChatButtonView setHidden:TRUE];
		[_dataManager setSelectedCollabRoomId:[NSNumber numberWithInt:-1] collabRoomName:@"N/A"];
	}else{
		
		[_dataManager setSelectedCollabRoomId:_selectedCollabroom.collabRoomId collabRoomName:_selectedCollabroom.name];
		
		NSString* incidentNameReplace = [_selectedIncident.incidentname stringByAppendingString:@"-"];
		[_selectRoomButton setTitle:[_selectedCollabroom.name stringByReplacingOccurrencesOfString:incidentNameReplace withString:@""] forState:UIControlStateNormal];
		NSNotification *CollabRoomSwitchedNotification = [NSNotification notificationWithName:@"CollabRoomSwitched" object:_selectedIncident.incidentname];
		
		[_dataManager requestChatMessagesRepeatedEvery:[[DataManager getChatUpdateFrequencyFromSettings] intValue] immediate:YES];
		[_dataManager requestMarkupFeaturesRepeatedEvery:[[DataManager getMapUpdateFrequencyFromSettings] intValue] immediate:YES];
		
		[_selectRoomButton setHidden:FALSE];
		[_ChatButtonView setHidden:FALSE];
		[_GeneralMessageButtonView setHidden:FALSE];
	}
	
	// Disabled Title
	//_ReportsMenu = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Feature Coming Soon",nil) delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
	
	_ReportsMenu = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Select a Report Type",nil) delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
	_ReportsMenu.tag = TAG_REPORTS_MENU;

	
	// Enable the following lines to access report types
	//================================================================================
	[_ReportsMenu addButtonWithTitle:NSLocalizedString(@"Report on Condition",nil)];
	//[_ReportsMenu addButtonWithTitle:NSLocalizedString(@"Damage Report",nil)];
	//[_ReportsMenu addButtonWithTitle:NSLocalizedString(@"Resource Request",nil)];
	//[_ReportsMenu addButtonWithTitle:NSLocalizedString(@"Field Report",nil)];
	//[_ReportsMenu addButtonWithTitle:NSLocalizedString(@"Weather Report",nil)];
	//================================================================================
	
	[_ReportsMenu addButtonWithTitle:NSLocalizedString(@"Cancel",nil)];
}

//gets called everytime the app is brought back to the forground regardless of what view is currently open
//do not call immediate:yes heres
-(void)SetPullTimersFromOptions{
	[_dataManager requestChatMessagesRepeatedEvery:[[DataManager getChatUpdateFrequencyFromSettings] intValue] immediate:NO];
	[_dataManager requestReportOnConditionsRepeatedEvery:[[DataManager getReportsUpdateFrequencyFromSettings]intValue] immediate:NO];
	[_dataManager requestSimpleReportsRepeatedEvery:[[DataManager getReportsUpdateFrequencyFromSettings]intValue] immediate:NO];
	[_dataManager requestDamageReportsRepeatedEvery:[[DataManager getReportsUpdateFrequencyFromSettings]intValue] immediate:NO];
	[_dataManager requestFieldReportsRepeatedEvery:[[DataManager getReportsUpdateFrequencyFromSettings]intValue] immediate:NO];
	[_dataManager requestResourceRequestsRepeatedEvery:[[DataManager getReportsUpdateFrequencyFromSettings]intValue] immediate:NO];
	[_dataManager requestMarkupFeaturesRepeatedEvery:[[DataManager getMapUpdateFrequencyFromSettings]intValue] immediate:NO];
	[_dataManager requestMdtRepeatedEvery:[DataManager getMdtUpdateFrequencyFromSettings] immediate:NO];
	[_dataManager requestWfsUpdateRepeatedEvery:[[DataManager getWfsUpdateFrequencyFromSettings]intValue] immediate:NO];
	//    [_dataManager requestActiveAssignmentRepeatedEvery:30];
}

- (IBAction)selectIncidentButtonPressed:(UIButton *)button {
	[_incidentMenu showInView:self.parentViewController.view];
}

- (IBAction)selectRoomButtonPressed:(UIButton *)button {
	NSMutableDictionary *collabrooms = [NSMutableDictionary new];
	_selectedIncident.collabrooms = _selectedIncident.collabrooms;
	
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
	
	_collabroomMenu = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Select Room",nil) delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
	_collabroomMenu.tag = TAG_COLLABROOM_MENU;
	
	NSString *replaceString = @"";
	replaceString = [_selectedIncident.incidentname stringByAppendingString:@"-"];
	
	for( NSString *title in sortedCollabrooms)  {
		[_collabroomMenu addButtonWithTitle:[title stringByReplacingOccurrencesOfString:replaceString withString:@""]];
	}
	
	[_collabroomMenu addButtonWithTitle:NSLocalizedString(@"Cancel",nil)];
	_collabroomMenu.cancelButtonIndex = [sortedCollabrooms count];
	
	[_collabroomMenu showInView:self.parentViewController.view];
}

- (IBAction)ReportsButtonPressed:(id)sender {
	[_ReportsMenu showInView:self.parentViewController.view];
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

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	[_dataManager.locationManager stopUpdatingLocation];
}

//fix for ghosting effect on ios7
- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
	actionSheet.backgroundColor = [UIColor blackColor];
	for (UIView *subview in actionSheet.subviews) {
		subview.backgroundColor = [UIColor blackColor];
	}
}

// This is the delegate that handles the _ReportsMenu, _incidentMenu, and _collanroomMenu
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	NSString *replaceString = @"";
	
	// If the actionSheet is the incident menu
	if(actionSheet.tag == TAG_INCIDENT_MENU)
	{
		// If the user pressed the "None" button, exit the current incident
		if(buttonIndex == 0)
		{
			_selectedIncident = nil;
		}
		else if(buttonIndex != _incidentMenu.cancelButtonIndex)
		{
			_selectedIncident = [[_dataManager getIncidentsList] objectForKey:[actionSheet buttonTitleAtIndex:buttonIndex]];
			[_dataManager requestCollabroomsForIncident:_selectedIncident];
			_selectedIncident.collabrooms = [_dataManager getCollabroomPayloadArray];
			[_dataManager setSelectedCollabRoomId:@-1 collabRoomName:@"N/A"];
			_selectedCollabroom = nil;
		}
	}
	// If the actionSheet is the reports menu
	else if(actionSheet.tag == TAG_REPORTS_MENU)
	{
		enum ReportTypesMenu reportType = buttonIndex;
		
		switch (buttonIndex) {
			case 0:
				[self performSegueWithIdentifier:@"segue_roc_action" sender:self];
				break;
			default:
				break;
		}
		// Unused segues:
		//[self performSegueWithIdentifier:@"segue_damage_report" sender:self];
		//[self performSegueWithIdentifier:@"segue_resource_request" sender:self];
		//[self performSegueWithIdentifier:@"segue_field_report" sender:self];
		//[self performSegueWithIdentifier:@"segue_weather_report" sender:self];
	}
	// If the actionSheet is the collabroom menu
	else if(actionSheet.tag == TAG_COLLABROOM_MENU)
	{
		replaceString = [_selectedIncident.incidentname stringByAppendingString:@"-"];
		if(buttonIndex != _collabroomMenu.cancelButtonIndex) {
			//            _selectedCollabroom = [[_dataManager getCollabroomList] objectForKey:[[_dataManager getCollabroomNamesList] objectForKey:[replaceString stringByAppendingString:[actionSheet buttonTitleAtIndex:buttonIndex]]]];
			NSString* selectedRoom = [actionSheet buttonTitleAtIndex:buttonIndex];
			_selectedCollabroom = [[_dataManager getCollabroomList] objectForKey:[[_dataManager getCollabroomNamesList] objectForKey:selectedRoom]];
		}
	}
	
	// Reports button should never be hidden
	[_ReportsButtonView setHidden:NO];
	
	if(_selectedIncident != nil)
	{
		//-----------------------------------
		// Updating the DataMAnager
		//-----------------------------------
		[_dataManager setActiveIncident:_selectedIncident];
		
		//-----------------------------------
		// Updating the UI View
		//-----------------------------------
		[_selectIncidentButton setTitle: _selectedIncident.incidentname forState:UIControlStateNormal];
		[_roomContainerView setHidden:NO];
		[_selectRoomButton setHidden:NO];
		[_GeneralMessageButtonView setHidden:NO];
		
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
		
	}
	else
	{
		//-----------------------------------
		// Updating the DataMAnager
		//-----------------------------------
		[_dataManager setActiveIncident:nil];
		_selectedCollabroom = nil;
		[_dataManager setSelectedCollabRoomId:@-1 collabRoomName:@"N/A"];

		//-----------------------------------
		// Updating the UI View
		//-----------------------------------
		[_selectIncidentButton setTitle: NSLocalizedString(@"Select Incident",nil) forState:UIControlStateNormal];
		[_ChatButtonView setHidden:TRUE];
		[_GeneralMessageButtonView setHidden:TRUE];
		//        [_roomContainerView setHidden:YES];
		[_selectRoomButton setHidden:YES];
		[_GeneralMessageButtonView setHidden:YES];
	}
	
	if(_selectedCollabroom != nil)
	{
		[_dataManager setSelectedCollabRoomId:_selectedCollabroom.collabRoomId collabRoomName:_selectedCollabroom.name];
		[_ChatButtonView setHidden:NO];
		[_MapButtonView setHidden:NO];
		NSString* abreviatedCollabRoomName = [_selectedCollabroom.name stringByReplacingOccurrencesOfString:[_selectedIncident.incidentname stringByAppendingString:@"-"] withString:@""];
		[_selectRoomButton setTitle:abreviatedCollabRoomName forState:UIControlStateNormal];
	}
	else
	{
		[_selectRoomButton setTitle: NSLocalizedString(@"Select Room",nil) forState:UIControlStateNormal];
		[_ChatButtonView setHidden:YES];
		//        [_MapButtonView setHidden:YES];
	}
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


// This method is called when we receive a specific response code from the server
// indicating the the user has logged in on a different device
// Thus, we want to notify the user and allow them to re-log-in or close the application.
-(void) showDuplicateLoginWarning:(BOOL)fromFR
{
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
	}];
		
	UIAlertAction* okayButton = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
		exit(0);
	}];
		
	[alert addAction: reloginButton];
	[alert addAction:okayButton];
	
	[self presentViewController:alert animated:YES completion:nil];
}
@end
