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
//  RestClient.m
//  nics_iOS
//
//

#import "RestClient.h"

@implementation RestClient

static BOOL firstRun = YES;

static BOOL receivingSimpleReports = NO;
static BOOL receivingReportOnConditions = NO;
static BOOL receivingDamageReports = NO;
static BOOL receivingFieldReports = NO;
static BOOL receivingResourceRequests = NO;
static BOOL receivingWeatherReports = NO;
static BOOL receivingChatMessages = NO;
static BOOL receivingMapMarkupFeatures = NO;
static BOOL receivingWfsFeatures = NO;
static BOOL sendingSimpleReports = NO;
static BOOL sendingFieldReports = NO;
static BOOL sendingDamageReports = NO;
static BOOL sendingResourceRequests = NO;
static BOOL sendingWeatherReports = NO;
static BOOL sendingChatMessages = NO;
static BOOL sendingMDTs = NO;
static BOOL sendingMapFeature = NO;
//static BOOL sendingMapMarkupFeatures = NO;

static NSString* authValue;
static NSString* BASE_URL = nil;
static NSNotificationCenter *notificationCenter;
static DataManager *dataManager;
static openAmAuth *myOpenAmAuth;
static MultipartPostQueue* mMultipartPostQueue;

+ (void) initialize {
	
	notificationCenter = [NSNotificationCenter defaultCenter];
	dataManager = [DataManager getInstance];
	mMultipartPostQueue = [MultipartPostQueue getInstance];
	myOpenAmAuth = [[openAmAuth alloc] init];
}

+ (NSString *) synchronousGetFromUrl:(NSString *)url statusCode:(NSInteger *)statusCode {
	
	NSLog([@"Get: " stringByAppendingString:url]);
	return [myOpenAmAuth synchronousGetFromUrl:url statusCode:statusCode];
}

+ (NSString *) synchronousPostToUrl:(NSString *)url postData:(NSData *)postData length:(NSUInteger)length statusCode:(NSInteger *)statusCode {
	
	NSLog([@"Post: " stringByAppendingString:url]);
	return [myOpenAmAuth synchronousPostToUrl:url postData:postData length:length statusCode:statusCode];
}

+ (NSURLConnection *) synchronousMultipartPostToUrl:(NSString *)url postData:(NSData *)postData imageName:(NSString *)imageName requestParams:(NSMutableDictionary *)requestParams statusCode:(NSInteger *)statusCode {
	
	NSLog([@"Multipart Post: " stringByAppendingString:url]);
	return [myOpenAmAuth synchronousMultipartPostToUrl:url postData:postData imageName:imageName requestParams:requestParams statusCode:statusCode];
}

//initializes auth type
//logs user in
+(void) loginUser:(NSString*)username password:(NSString*) password completion:(void (^)(BOOL successful,NSString* msg)) completion {
	NSLog(@"Attempting to log-in");
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
	dispatch_async(queue, ^{
		
		bool authenticated = [myOpenAmAuth setupAuth:username :password];
		
		if(!authenticated){
			if([myOpenAmAuth.OpenAmResponse isEqualToString:@""]){
				completion(false,NSLocalizedString(@"Could not find server: Make sure device has an internet connection.", nil));
			}else{
				completion(false,myOpenAmAuth.OpenAmResponse);
			}
			return;
		}
		
		LoginPayload *payload = [[LoginPayload alloc] init];
		payload.username = username;
		NSString *jsonString = [payload toJSONString];
		NSData *postData = [NSData dataWithBytes:[jsonString UTF8String] length:[jsonString length]];
		
		NSInteger statusCode = -1;
		NSString* loginResult = [self synchronousPostToUrl:@"login" postData:postData length:[jsonString length] statusCode:&statusCode];
		
		if(statusCode == 412) {
			NSLog(@"User already logged in...");
			[self logoutUser: username];
			[self loginUser:username password:password completion:completion];
			
		}else if(statusCode == 204){
			NSLog(@"NICS6 usersession not cleared...");
			[self logoutUser: username];
			[self loginUser:username password:password completion:completion];
			
			
		} else if(statusCode == 200 || statusCode == 201){
			NSLog(@"Successfully logged in...");
			LoginMessage *loginResultMessage = [[LoginMessage alloc] initWithString:loginResult error:nil];
			
			LoginPayload *payload = [loginResultMessage.logins objectAtIndex:0];
			payload.workspaceId = [dataManager getActiveWorkspaceId];
			
			//L: this sets the userSessionId
			[dataManager setLoginSessionData:payload];
			[dataManager setUserName:payload.username];
			[self getAllIncidentsForUserId: payload.userId];
			[self getUserDataById: payload.userId];
			[self getUserOrgs: payload.userId];
			[self getWFSDataLayers];
			
			// Store this login session's credentials
			dataManager.curSessionUsername = username;
			dataManager.curSessionPassword = password;
			
			NSString *currentRoomName = [dataManager getSelectedCollabroomName];
			NSString *currentIncidentName = [dataManager getActiveIncidentName];
			
			if(currentIncidentName != nil){
				IncidentPayload* selectedIncident = [[dataManager getIncidentsList] objectForKey:currentIncidentName];
				
				if(selectedIncident != nil){
					[dataManager requestCollabroomsForIncident:selectedIncident];
				}
			}
			dataManager.isLoggedIn = true;
			
			completion(true,NSLocalizedString(@"Success", nil));
		}else{
			NSLog(@"Unhandled login status response code: %ld",statusCode);
			completion(false, [NSString stringWithFormat: @"%ld", statusCode] );
		}
		
	});
}

+(NSString *) logoutUser:(NSString *)username {
	NSLog(@"Logging out user...");
	NSURL* postUrl = [NSURL URLWithString:[NSString stringWithFormat: @"%@%@%@", BASE_URL, @"login/", username]];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:postUrl];
	
	[request setValue:myOpenAmAuth.AuthValue forHTTPHeaderField:@"Authorization"];
	
	[request setHTTPMethod:@"DELETE"];
	
	NSHTTPURLResponse *response = nil;
	NSError *error = nil;
	NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	
	dataManager.isLoggedIn = false;
	
	NSLog(@"USIDDEFECT, logoutuser URL: %@",[NSString stringWithFormat: @"%@%@%@", BASE_URL, @"login/", username]);
	NSLog(@"USIDDEFECT, logoutuser HTTPMethod: %@",@"DELETE");	
	NSLog(@"USIDDEFECT, logoutuser HeaderValue: %@%@",@"Authorization: ",myOpenAmAuth.AuthValue);
	
	return [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
}

+(void) getUserDataById:(NSNumber *)userId {
	NSInteger statusCode = -1;
	
	NSString* json = [self synchronousGetFromUrl:[NSString stringWithFormat:@"%@%@%@%@", @"users/", [dataManager getActiveWorkspaceId], @"/", userId] statusCode:&statusCode];
	NSError* error = nil;
	
	UserMessage *message = [[UserMessage alloc] initWithString:json error:&error];
	UserPayload *userData = [message.users objectAtIndex:0];
	
	if(dataManager == nil){
		dataManager = [DataManager getInstance];
	}
	
	dataManager.userData = userData;
	
	json = [self synchronousGetFromUrl:[NSString stringWithFormat:@"%@%@%@%@", @"orgs/", [dataManager getActiveWorkspaceId], @"?userId=", userId] statusCode:&statusCode];
	OrganizationMessage *orgMessage = [[OrganizationMessage alloc] initWithString:json error:&error];
	if( [orgMessage.organizations objectAtIndex:0] != nil){
		[dataManager setOrgData: orgMessage.organizations[0]];
	}
}


+(void) getUserCollabroomsForIncidentId:(NSNumber *)incidentId userId:(NSNumber *)userId {
	
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
	dispatch_async(queue, ^{
		NSInteger statusCode = -1;
		
		NSString* json = [self synchronousGetFromUrl:[NSString stringWithFormat:@"%@%@%@%@", @"collab/", incidentId, @"/rooms/", userId] statusCode:&statusCode];
		NSError* error = nil;
		
		CollaborationRoomMessage *message = [[CollaborationRoomMessage alloc] initWithString:json error:&error];
		
		if(message != nil) {
			for(CollabroomPayload *payload in message.results) {
				[dataManager addCollabroom:payload];
			}
		}
	});
}

+(void) getActiveAssignmentForUser:(NSString *)username userId:(NSNumber *)userId activeOnly:(BOOL) activeOnly completion:(void (^)(BOOL successful)) completion {
	
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
	dispatch_async(queue, ^{
		NSInteger statusCode = -1;
		
		NSString* json = [self synchronousGetFromUrl:[NSString stringWithFormat:@"%@%@%@%s", @"assignments/?username=", username, @"&activeOnly=", activeOnly ? "true" : "false"] statusCode:&statusCode];
		NSError* error = nil;
		
		AssignmentMessage *message = [[AssignmentMessage alloc] initWithString:json error:&error];
		[message parse];
		
		AssignmentPayload *currentAssignment = nil;
		if(message.count == 1) {
			currentAssignment = [message.taskingAssignmentsList firstObject];
			BOOL isCurrent = [dataManager.currentAssignment isEqual: currentAssignment];
			
			NSNumber* incidentId = currentAssignment.phiUnit.incidentId;
			if(!isCurrent) {
				[self getIncidentForId:incidentId isWorkingMap:NO userId:userId sendAssignmentUpdate:YES];
			} else {
				[self getIncidentForId:incidentId isWorkingMap:NO userId:userId sendAssignmentUpdate:NO];
			}
		} else {
			currentAssignment = [[AssignmentPayload alloc] init];
			
			if(firstRun || ((![dataManager.currentAssignment isNil] && ![currentAssignment isNil]) && !([dataManager.currentAssignment.phiOperationalPeriod isEqual:currentAssignment.phiOperationalPeriod]))) {
				[self getIncidentForId:@-1 isWorkingMap:YES userId:userId sendAssignmentUpdate: YES];
				firstRun = NO;
			} else {
				[self getIncidentForId:@-1 isWorkingMap:NO userId:userId sendAssignmentUpdate: NO];
			}
		}
		
		dataManager.currentAssignment = currentAssignment;
		
		completion(true);
	});
}

+(void) getCollabroomsForIncident:(IncidentPayload*)incident offset:(NSNumber *)offset limit:(NSNumber *)limit completion:(void (^)(BOOL))completion{
	
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
	dispatch_async(queue, ^{
		
		NSInteger statusCode = -1;
		
		NSString* json = [self synchronousGetFromUrl:[NSString stringWithFormat:@"%@%@%@%@", @"collabroom/", incident.incidentid,@"?userId=",[dataManager getUserId]] statusCode:&statusCode];
		NSError* error = nil;
		
		CollaborationRoomMessage *message =  [[CollaborationRoomMessage alloc] initWithString:json error:&error];
		
		[dataManager clearCollabRoomList];
		
		if(message != nil && statusCode == 200) {
			
			for(CollabroomPayload *payload in message.results) {
				payload.name = [payload.name stringByReplacingOccurrencesOfString: [incident.incidentname stringByAppendingString:@"-"] withString:@""];    //pull incident name out of collab name in case it is there
				[dataManager addCollabroom:payload];
			}
			completion(YES);
		}else{
			completion(NO);
		}
	});
}

+(void) getAllIncidentsForUserId:(NSNumber *)userId {
	NSInteger statusCode = -1;
	
	NSString* json = [self synchronousGetFromUrl:[NSString stringWithFormat:@"%@%@%@%@", @"incidents/", [dataManager getActiveWorkspaceId], @"/?accessibleByUserId=", userId] statusCode:&statusCode];
	NSError* error = nil;
	
	NSLog(@"Incidents - Got the following incident payload: \"%@\"",json);
	
	IncidentMessage *message = [[IncidentMessage alloc] initWithString:json error:&error];
	
	if(message != nil && statusCode == 200) {
		NSMutableDictionary *incidentsList = [NSMutableDictionary new];
		
		for(IncidentPayload *payload in message.incidents) {
			
			if(payload.incidentnumber != nil)
				NSLog(@"Incident - \"%@\" has number - \"%@\"",payload.incidentname,payload.incidentnumber);

			[incidentsList setObject:payload forKey:payload.incidentname];
		}
		dataManager.incidentsList = incidentsList;
	}
}

+(void) getIncidentForId:(NSNumber *)incidentId isWorkingMap:(BOOL) isWorkingMap userId:(NSNumber *)userId sendAssignmentUpdate:(BOOL) sendAssignmentUpdate {
	NSInteger statusCode = -1;
	NSString* json = [self synchronousGetFromUrl:[NSString stringWithFormat:@"%@%@%@%@", @"incidents/", [dataManager getActiveWorkspaceId], @"/", incidentId] statusCode:&statusCode];
	NSError* error = nil;
	
	IncidentMessage *message = [[IncidentMessage alloc] initWithString:json error:&error];
	
	IncidentPayload *incident = [message.incidents objectAtIndex:0];
	
	NSNumber *collabRoomId = @-1;
	NSString *collabRoomName = @"";
	
	if(isWorkingMap) {
		for(CollabroomPayload *payload in incident.collabrooms) {
			if([payload.name rangeOfString:@"WorkingMap"].location != NSNotFound) {
				collabRoomId = payload.collabRoomId;
				collabRoomName = payload.name;
				payload.incidentid = incidentId;
				
				[dataManager addCollabroom:payload];
				
				if(sendAssignmentUpdate) {
					[dataManager setCurrentIncident:incident collabRoomId:collabRoomId collabRoomName: collabRoomName];
					[dataManager setSelectedCollabRoomId:collabRoomId collabRoomName:collabRoomName];
				}
			} else {
				[dataManager addCollabroom:payload];
			}
		}
	} else {
		collabRoomName = [dataManager getActiveCollabroomName];
	}
	[dataManager setCurrentIncident:incident collabRoomId:collabRoomId collabRoomName: collabRoomName];
	
	if(sendAssignmentUpdate && !isWorkingMap) {
		[dataManager clearCollabRoomList];
	}
	
	//            [self getUserCollabroomsForIncidentId: incidentId userId:userId];
	
	if(sendAssignmentUpdate) {
		dispatch_async(dispatch_get_main_queue(), ^{
			NSNotification *activeAssignmentReceivedNotification = [NSNotification notificationWithName:@"assignmentUpdateReceived" object:message];
			[notificationCenter postNotification:activeAssignmentReceivedNotification];
		});
	}
}


+(void) getSimpleReportsForIncidentId:(NSNumber *)incidentId offset:(NSNumber *)offset limit:(NSNumber *)limit completion:(void (^)(BOOL))completion{
	if(!receivingSimpleReports && ![incidentId  isEqual: @-1]) {
		receivingSimpleReports = YES;
		dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
		dispatch_async(queue, ^{
			NSInteger statusCode = -1;
			
			NSString* json = [self synchronousGetFromUrl:[NSString stringWithFormat:@"%@%@%@%lld%@%ld", @"reports/",
												 incidentId, @"/SR?sortOrder=desc&fromDate=", [[dataManager getLastSimpleReportTimestampForIncidentId:incidentId] longLongValue] + 1, @"&incidentId=", [incidentId longValue]] statusCode:&statusCode];
			NSError* error = nil;
			
			SimpleReportMessage *message = [[SimpleReportMessage alloc] initWithString:json error:&error];
			[message parse];
			
			if([message.reports count] > 0) {
				[dataManager addSimpleReportsToHistory:message.reports];
				
				NSMutableArray* Reports = [dataManager getAllSimpleReportsFromStoreAndForward];
				for(SimpleReportPayload *payload in Reports) {
					if([payload.status isEqualToNumber:@(SENT)]) {
						[dataManager deleteSimpleReportFromStoreAndForward:payload];
					}
				}
				
				dispatch_async(dispatch_get_main_queue(), ^{
					
					NSDictionary *simpleReportMessageDictionary = [NSDictionary dictionaryWithObjectsAndKeys:json,@"generalMessageJson", nil];
					NSNotification *simpleReportsReceivedNotification = [NSNotification notificationWithName:@"simpleReportsUpdateReceived" object:self userInfo:simpleReportMessageDictionary];
					[notificationCenter postNotification:simpleReportsReceivedNotification];
				});
			}else{
				NSNotification *simpleReportsReceivedNotification = [NSNotification notificationWithName:@"GeneralMessagesPolledNothing" object:self];
				[notificationCenter postNotification:simpleReportsReceivedNotification];
			}
			
			receivingSimpleReports = NO;
			completion(YES);
		});
	}
}

+(void) postSimpleReports {
	NSMutableArray* simpleReports = [dataManager getAllSimpleReportsFromStoreAndForward];
	
	for(SimpleReportPayload *payload in simpleReports) {
		if([payload.isDraft isEqual:@0] && [payload.status isEqualToNumber:@(WAITING_TO_SEND)]) {
			[mMultipartPostQueue addPayloadToSendQueue:payload];
			break;
		}
	}
}

+ (void) getReportOnConditionsForIncidentId:(NSNumber *)incidentId offset:(NSNumber *)offset limit:(NSNumber *)limit completion:(void (^)(BOOL successful)) completion
{
	NSLog(@"ROC - RestClient - getReportOnConditionsForIncidentId: %@",incidentId);
	
	if(incidentId == nil)
	{
		NSLog(@"Warning - RestClient - getReportOnConditionsForIncidentId called for nil incident ID.");
		completion(NO);
		return;
	}
	
	
	if(!receivingReportOnConditions && ![incidentId  isEqual: @-1])
	{
		NSLog(@"ROC - RestClient - not currently requesting ROCs, initiating a new request");
		
		receivingReportOnConditions = YES;
		
		dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
		dispatch_async(queue, ^{
			NSInteger statusCode = -1;
			
			// TODO - The following url should contain the parameter "fromDate=###" where ### is the timestamp of the last ROC we have cached on the app.
			// Like this:
			// NSString *url = [NSString stringWithFormat:@"reports/%@/ROC?sortOrder=desc&fromDate=%lld",incidentId,([[dataManager getLastReportOnConditionTimestampForIncidentId:incidentId] longLongValue])];

			// This instructs the server to only respond with the latest ROCs
			// HOWEVER, the server seems to use the column "seqtime" for that comparison, and that column is "0" for all ROCs, therefore
			// passing any value > 0 returns no ROCs
			// So we must use the following request URL to obtain all of the ROCs:
			NSString *url = [NSString stringWithFormat:@"reports/%@/ROC?sortOrder=desc",incidentId];

			
			
			NSLog(@"About to request ROCs from URL: \"%@\"",url);
			NSString* jsonString = [self synchronousGetFromUrl:url statusCode:&statusCode];
			
			NSLog(@"ROC - getROCsForIncident - Got json string: %@",jsonString);
	
			NSError* error = nil;
			
			// Converting json to an NSDictionary
			NSMutableDictionary *serverPayload = [ReportOnConditionData jsonDictionaryFromJsonString:jsonString];
			
			NSLog(@"ROC - getROCsForIncident - Converted ROC json string to dictionary: %@",serverPayload);
			
			// Instead of checking the error value, check the return value
			if(serverPayload != nil && [serverPayload isKindOfClass:[NSDictionary class]])
			{
				NSLog(@"ROC - getROCsForIncident - dictionary is not nil, and is a dictionary.");
				// Confirming the message is okay:
				if([[ReportOnConditionData jsonGetString:serverPayload withName:@"message"] isEqualToString:@"ok"])
				{
					
					// Parsing the dictionary to a list of ReportOnConditionData
					NSArray<ReportOnConditionData> *reports = [ReportOnConditionData multipleFromServerPayload:serverPayload];
					
					// Adding all inbound ROCs to the server
					[dataManager addReportOnConditionsToHistory:reports];
					
					// Removing all sent ROCs from the store and forward table
					NSArray<ReportOnConditionData> *outboundROCs = [dataManager getAllReportOnConditionsFromStoreAndForward];
					
					for(ReportOnConditionData *roc in outboundROCs)
					{
						// If the roc has been sent, remove it.
						if(roc.sendStatus == SENT)
						{
							[dataManager deleteReportOnConditionFromStoreAndForward:roc];
						}
					}
				}
			}
			
			
			receivingReportOnConditions = NO;
			completion(YES);
		});
	}
	completion(NO);
}


+ (void) postReportOnCondition:(ReportOnConditionData*)rocData
{
	int userSessionId = [[dataManager getUserSessionId] intValue];
	
	NSMutableDictionary *rocPayload = [rocData toServerPayload:userSessionId];
	
	// If it has already been sent, we shouldn't process it again...
	// remove it from the sendqueue
	if(rocData.sendStatus == SENT)
	{
		[dataManager deleteReportOnConditionFromStoreAndForward:rocData];
	}
	
	// If the ROC will create a new incident, the request url is different
	NSString *url = @"";
	
	if(rocData.isForNewIncident)
	{
		int orgId = [[dataManager.orgData orgId] intValue];
		url = [NSString stringWithFormat:@"reports/%d/IncidentAndROC",orgId];
	}
	else
	{
		long incidentId = rocData.incidentid;
		url = [NSString stringWithFormat:@"reports/%ld/ROC",incidentId];
	}
	
	NSInteger statusCode = -1;
	
	// Converting the Dictionary to json data
	NSError *error = nil;
	NSData *jsonPayloadData = [NSJSONSerialization dataWithJSONObject:rocPayload options:0 error:&error];
	
	if(jsonPayloadData != nil)
	{
		NSLog(@"PostReportOnCondition - posted payload.");
		NSString *response = [RestClient synchronousPostToUrl:url postData:jsonPayloadData length:[jsonPayloadData length] statusCode:&statusCode];
		NSLog(@"PostReportOnCondition - response: %@",response);
		
		NSDictionary *responseDictionary = [ReportOnConditionData jsonDictionaryFromJsonString:response];
		
		
		
		rocData.sendStatus = SENT;
		
		if([ReportOnConditionData jsonGetInt:responseDictionary withName:@"status" defaultTo:-1] == 200)
		{
			NSLog(@"PostReportOnCondition - Got success message, payload added to history table");
			// If the report successfully posted, add it to our history queue
			[dataManager addReportOnConditionToHistory:rocData];
			
			// If the report posted successfully, it may have created a new incident, so we need to refresh our list of incidents:
			[RestClient getAllIncidentsForUserId:[dataManager getUserId]];
		}
	}
	else
	{
		NSLog(@"PostReportOnCondition - Failed to convert payload to json.");
	}
	
	// Now that we've sent it, remove the payload from the store and forward queue
	NSLog(@"PostReportOnCondition - Removing payload from store and forward table");
	// Whether we succeeded or not,
	// either remove the sent report, or remove the faulty report from the store and forward table
	[dataManager deleteReportOnConditionFromStoreAndForward:rocData];
	
	// Try to post another ROC
	[self postReportOnConditions];
}

+ (void)postReportOnConditions
{
	NSMutableArray<ReportOnConditionData>* rocs = [dataManager getAllReportOnConditionsFromStoreAndForward];
	NSLog(@"=============================================================================");
	NSLog(@"ROC - postReportOnConditions - got %lu payloads from store and forward, printing payloads...", [rocs count]);
	NSLog(@"=============================================================================");

	for(ReportOnConditionData *data in rocs)
	{
		NSString *sendStatus = @"UNKNOWN_SEND_STATUS";
		
		if(data.sendStatus == WAITING_TO_SEND)
		{
			sendStatus = @"WAITING_TO_SEND";
		}
		else if(data.sendStatus == SENT)
		{
			sendStatus = @"SENT";
		}
		
		NSLog(@"ROC - postReportOnConditions - got payload from store and forward: %@, %f, %@", data.incidentname, [data.datecreated timeIntervalSince1970], sendStatus);
	}
	
	NSLog(@"ROC - postReportOnConditions - finished printing all payloads.");
	
	
	for(ReportOnConditionData *data in rocs)
	{
		if(data.sendStatus == WAITING_TO_SEND)
		{
			// Remove the payload from the store and forward table
			[dataManager deleteReportOnConditionFromStoreAndForward:data];
			
			NSLog(@"ROC - RestClient - postReportOnConditions - updating the send status for payload \"%@\".",data.incidentname);

			// set the send status as having been sent
			data.sendStatus = SENT;
			
			NSLog(@"ROC - RestClient - postReportOnConditions - adding payload for \"%@\" back to store & forward with updated send status.",data.incidentname);

			// and re-add it to the store and forward table again with the updated send status
			[dataManager addReportOnConditionToStoreAndForward:data];
			
			NSLog(@"ROC - RestClient - postReportOnCondition - about to post ROC for payload \"%@\".",data.incidentname);
			[self postReportOnCondition:data];
			
			
			/*NSLog(@"ROC - RestClient - postReportOnConditions - removing payload from store & forward.");
			
			
			NSLog(@"ROC - RestClient - postReportOnConditions - Got an ROC payload message from store and forward table, adding it to send queue. (Incident: %@, creationDate: %@",data.incidentname, data.datecreated);
			
			data.sendStatus = WAITING_TO_SEND;*/
			
			//[mMultipartPostQueue addPayloadToSendQueue:data];
			// Why are we only adding one to the send queue before breaking?
			// I just followed the algorithm that SimpleReports use
			
			// Only post 1 at a time, this method will be called again after we succeed or fail to post it
			// ... which will send the rest of them.
			break;
		}
	}
	
	NSLog(@"=============================================================================");
	NSLog(@"ROC - RestClient - postReportOnCondition - finished method.");
	NSLog(@"=============================================================================");

}


+(void) getFieldReportsForIncidentId:(NSNumber *)incidentId offset:(NSNumber *)offset limit:(NSNumber *)limit completion:(void (^)(BOOL))completion{
	if(!receivingFieldReports && ![incidentId  isEqual: @-1]) {
		receivingFieldReports = YES;
		dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
		dispatch_async(queue, ^{
			NSInteger statusCode = -1;
			
			NSString* json = [self synchronousGetFromUrl:[NSString stringWithFormat:@"%@%@%@%lld%@%ld", @"reports/", [dataManager getActiveWorkspaceId], @"/FR?sortOrder=desc&fromDate=", [[dataManager getLastFieldReportTimestampForIncidentId:incidentId] longLongValue] + 1, @"&incidentId=", [incidentId longValue]] statusCode:&statusCode];
			NSError* error = nil;
			
			FieldReportMessage *message = [[FieldReportMessage alloc] initWithString:json error:&error];
			[message parse];
			
			if([message.reports count] > 0) {
				[dataManager addFieldReportsToHistory:message.reports];
				
				NSMutableArray* Reports = [dataManager getAllFieldReportsFromStoreAndForward];
				for(FieldReportPayload *payload in Reports) {
					if([payload.status isEqualToNumber:@(SENT)]) {
						[dataManager deleteFieldReportFromStoreAndForward:payload];
					}
				}
				
				dispatch_async(dispatch_get_main_queue(), ^{
					NSNotification *fieldReportsReceivedNotification = [NSNotification notificationWithName:@"fieldReportsUpdateReceived" object:message];
					[notificationCenter postNotification:fieldReportsReceivedNotification];
				});
			}else{
				NSNotification *fieldReportsReceivedNotification = [NSNotification notificationWithName:@"FieldReportsPolledNothing" object:self];
				[notificationCenter postNotification:fieldReportsReceivedNotification];
			}
			
			receivingFieldReports = NO;
			completion(YES);
		});
	}
}

+(void) postFieldReports {
	if(!sendingFieldReports) {
		sendingFieldReports = YES;
		NSMutableArray* fieldReports = [dataManager getAllFieldReportsFromStoreAndForward];
		
		for(FieldReportPayload *payload in fieldReports) {
			if([payload.isDraft isEqual:@0] && [payload.status isEqualToNumber:@(WAITING_TO_SEND)]) {
				NSString *jsonString = [payload toJSONStringPost];
				NSData *postData = [NSData dataWithBytes:[jsonString UTF8String] length:[jsonString length]];
				
				dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
				dispatch_async(queue, ^{
					
					NSInteger statusCode = -1;
					NSString* result = [self synchronousPostToUrl:[NSString stringWithFormat:@"%@%@%@", @"reports/", [dataManager getActiveWorkspaceId],  @"/FR"] postData:postData length:[jsonString length] statusCode:&statusCode];
					
					if(statusCode == 200 || statusCode == 201) {
						[dataManager deleteFieldReportFromStoreAndForward:payload];
						[payload setStatus:[NSNumber numberWithInt:SENT]];
						[payload setProgress:[NSNumber numberWithDouble:100]];
						[dataManager addFieldReportToStoreAndForward:payload];
						
						[dataManager requestFieldReportsRepeatedEvery:[DataManager getReportsUpdateFrequencyFromSettings] immediate:YES];
					} else {
						NSLog(@"%@%@", @"Failed to send Field Report...\n", result);
					}
				});
			}
		}
		sendingFieldReports = NO;
	}
}


+(void) getDamageReportsForIncidentId:(NSNumber *)incidentId offset:(NSNumber *)offset limit:(NSNumber *)limit completion:(void (^)(BOOL))completion {
	if(!receivingDamageReports && ![incidentId  isEqual: @-1]) {
		receivingDamageReports = YES;
		dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
		dispatch_async(queue, ^{
			NSInteger statusCode = -1;
			
			NSString* json = [self synchronousGetFromUrl:[NSString stringWithFormat:@"%@%@%@%lld%@%ld", @"reports/", [dataManager getActiveIncidentId], @"/DMGRPT?sortOrder=desc&fromDate=", [[dataManager getLastDamageReportTimestampForIncidentId:incidentId] longLongValue] + 1, @"&incidentId=", [incidentId longValue]] statusCode:&statusCode];
			NSError* error = nil;
			
			DamageReportMessage *message = [[DamageReportMessage alloc] initWithString:json error:&error];
			[message parse];
			
			if([message.reports count] > 0) {
				[dataManager addDamageReportsToHistory:message.reports];
				
				NSMutableArray* Reports = [dataManager getAllDamageReportsFromStoreAndForward];
				for(DamageReportPayload *payload in Reports) {
					if([payload.status isEqualToNumber:@(SENT)]) {
						[dataManager deleteDamageReportFromStoreAndForward:payload];
					}
				}
				
				dispatch_async(dispatch_get_main_queue(), ^{
					NSDictionary *damageReportMessageDictionary = [NSDictionary dictionaryWithObjectsAndKeys:json,@"damageReportJson", nil];
					NSNotification *DamageReportsReceivedNotification = [NSNotification notificationWithName:@"damageReportsUpdateReceived" object:self userInfo:damageReportMessageDictionary];
					[notificationCenter postNotification:DamageReportsReceivedNotification];
				});
			}else{
				NSNotification *damageReportsReceivedNotification = [NSNotification notificationWithName:@"DamageReportsPolledNothing" object:self];
				[notificationCenter postNotification:damageReportsReceivedNotification];
			}
			receivingDamageReports = NO;
			completion(YES);
		});
	}
}

+(void) postDamageReports {
	NSMutableArray* damageReports = [dataManager getAllDamageReportsFromStoreAndForward];
	
	for(DamageReportPayload *payload in damageReports) {
		if([payload.isDraft isEqual:@0] && [payload.status isEqualToNumber:@(WAITING_TO_SEND)]) {
			[mMultipartPostQueue addPayloadToSendQueue:payload];
			break;
		}
	}
}

+(void) getResourceRequestsForIncidentId:(NSNumber *)incidentId offset:(NSNumber *)offset limit:(NSNumber *)limit completion:(void (^)(BOOL))completion{
	if(!receivingResourceRequests && ![incidentId  isEqual: @-1]) {
		receivingResourceRequests = YES;
		dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
		dispatch_async(queue, ^{
			NSInteger statusCode = -1;
			
			NSString* json = [self synchronousGetFromUrl:[NSString stringWithFormat:@"%@%@%@%lld%@%ld", @"reports/", [dataManager getActiveWorkspaceId], @"/RESREQ?sortOrder=desc&fromDate=", [[dataManager getLastResourceRequestTimestampForIncidentId:incidentId] longLongValue] + 1, @"&incidentId=", [incidentId longValue]] statusCode:&statusCode];
			NSError* error = nil;
			
			ResourceRequestMessage *message = [[ResourceRequestMessage alloc] initWithString:json error:&error];
			[message parse];
			
			if([message.reports count] > 0) {
				[dataManager addResourceRequestsToHistory:message.reports];
				
				NSMutableArray* Reports = [dataManager getAllResourceRequestsFromStoreAndForward];
				for(ResourceRequestPayload *payload in Reports) {
					if([payload.status isEqualToNumber:@(SENT)]) {
						[dataManager deleteResourceRequestFromStoreAndForward:payload];
					}
				}
				
				dispatch_async(dispatch_get_main_queue(), ^{
					NSNotification *resourceRequestsReceivedNotification = [NSNotification notificationWithName:@"resourceRequestsUpdateReceived" object:message];
					[notificationCenter postNotification:resourceRequestsReceivedNotification];
				});
			}else{
				NSNotification *resourceRequestsReceivedNotification = [NSNotification notificationWithName:@"ResrouceRequestsPolledNothing" object:self];
				[notificationCenter postNotification:resourceRequestsReceivedNotification];
			}
			
			receivingResourceRequests = NO;
			completion(YES);
		});
	}
}

+(void) postResourceRequests {
	if(!sendingResourceRequests) {
		sendingResourceRequests = YES;
		NSMutableArray* resourceRequests = [dataManager getAllResourceRequestsFromStoreAndForward];
		
		for(ResourceRequestPayload *payload in resourceRequests) {
			if([payload.isDraft isEqual:@0] && [payload.status isEqualToNumber:@(WAITING_TO_SEND)]) {
				NSString *jsonString = [payload toJSONStringPost];
				NSData *postData = [NSData dataWithBytes:[jsonString UTF8String] length:[jsonString length]];
				
				dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
				dispatch_async(queue, ^{
					
					NSInteger statusCode = -1;
					NSString* result = [self synchronousPostToUrl:[NSString stringWithFormat:@"%@%@%@", @"reports/", [dataManager getActiveWorkspaceId],  @"/RESREQ"] postData:postData length:[jsonString length] statusCode:&statusCode];
					
					if(statusCode == 200 || statusCode == 201) {
						[dataManager deleteResourceRequestFromStoreAndForward:payload];
						[payload setStatus:[NSNumber numberWithInt:SENT]];
						[payload setProgress:[NSNumber numberWithDouble:100]];
						[dataManager addResourceRequestToStoreAndForward:payload];
						
						[dataManager requestResourceRequestsRepeatedEvery:[DataManager getReportsUpdateFrequencyFromSettings] immediate:YES];
					} else {
						NSLog(@"%@%@", @"Failed to send Resource Request...\n", result);
					}
				});
			}
		}
		sendingResourceRequests = NO;
	}
}

+(void) getWeatherReportsForIncidentId:(NSNumber *)incidentId offset:(NSNumber *)offset limit:(NSNumber *)limit completion:(void (^)(BOOL))completion{
	if(!receivingWeatherReports && ![incidentId  isEqual: @-1]) {
		receivingWeatherReports = YES;
		dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
		dispatch_async(queue, ^{
			NSInteger statusCode = -1;
			
			NSString* json = [self synchronousGetFromUrl:[NSString stringWithFormat:@"%@%@%@%lld", @"reports/", [dataManager getActiveIncidentId], @"/WR?sortOrder=desc&fromDate=", [[dataManager getLastWeatherReportTimestampForIncidentId:incidentId] longLongValue] + 1] statusCode:&statusCode];
			NSError* error = nil;
			
			WeatherReportMessage *message = [[WeatherReportMessage alloc] initWithString:json error:&error];
			[message parse];
			
			if([message.reports count] > 0) {
				[dataManager addWeatherReportsToHistory:message.reports];
				
				NSMutableArray* Reports = [dataManager getAllWeatherReportsFromStoreAndForward];
				for(WeatherReportPayload *payload in Reports) {
					if([payload.status isEqualToNumber:@(SENT)]) {
						[dataManager deleteWeatherReportFromStoreAndForward:payload];
					}
				}
				
				dispatch_async(dispatch_get_main_queue(), ^{
					NSNotification *weatherReportsReceivedNotification = [NSNotification notificationWithName:@"WeatherReportsUpdateReceived" object:message];
					[notificationCenter postNotification:weatherReportsReceivedNotification];
				});
			}else{
				NSNotification *weatherReportsReceivedNotification = [NSNotification notificationWithName:@"WeatherReportsPolledNothing" object:self];
				[notificationCenter postNotification:weatherReportsReceivedNotification];
			}
			
			receivingWeatherReports = NO;
			completion(YES);
		});
	}
}

+(void) postWeatherReports {
	if(!sendingWeatherReports) {
		sendingWeatherReports = YES;
		NSMutableArray* weatherReports = [dataManager getAllWeatherReportsFromStoreAndForward];
		
		for(WeatherReportPayload *payload in weatherReports) {
			if([payload.isDraft isEqual:@0] && [payload.status isEqualToNumber:@(WAITING_TO_SEND)]) {
				
				NSArray* keys = [NSArray arrayWithObjects:@"formId",
							  @"formtypeid", @"incidentid", @"incidentname",
							  @"seqnum", @"seqtime",@"usersessionid",@"message", nil];
				
				NSString *jsonString = [payload toJSONStringWithKeys:keys];
				NSData *postData = [NSData dataWithBytes:[jsonString UTF8String] length:[jsonString length]];
				
				dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
				dispatch_async(queue, ^{
					
					NSInteger statusCode = -1;
					NSString* result = [self synchronousPostToUrl:[NSString stringWithFormat:@"%@%@%@", @"reports/", [dataManager getActiveIncidentId],  @"/WR"] postData:postData length:[jsonString length] statusCode:&statusCode];
					
					if(statusCode == 200 || statusCode == 201) {
						[dataManager deleteWeatherReportFromStoreAndForward:payload];
						[payload setStatus:[NSNumber numberWithInt:SENT]];
						[payload setProgress:[NSNumber numberWithDouble:100]];
						[dataManager addWeatherReportToStoreAndForward:payload];
						
						[dataManager requestWeatherReportsRepeatedEvery:[DataManager getReportsUpdateFrequencyFromSettings] immediate:YES];
						
						dispatch_async(dispatch_get_main_queue(), ^{
							NSNotification *weatherReportsReceivedNotification = [NSNotification notificationWithName:@"WeatherReportsUpdateReceived" object:nil];
							[notificationCenter postNotification:weatherReportsReceivedNotification];
						});
						NSLog(@"%@%@", @"Successfully sent Weather Report...\n", result);
					} else {
						NSLog(@"%@%@", @"Failed to send Weather Report...\n", result);
					}
				});
			}
		}
		sendingWeatherReports = NO;
	}
}

+(void) getMarkupHistoryForCollabroomId:(NSNumber *)collabRoomId completion:(void (^)(BOOL))completion{
	if(!receivingMapMarkupFeatures && ![collabRoomId  isEqual: @-1]) {
		receivingMapMarkupFeatures = YES;
		dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
		dispatch_async(queue, ^{
			NSInteger statusCode = -1;
			long timestampOfLastFeature = [[dataManager getLastMarkupFeatureTimestampForCollabroomId:collabRoomId] longValue] + 1;
			
			NSString* json = [self synchronousGetFromUrl:[NSString stringWithFormat:@"%@%@%s%@%@%@%ld%@", @"features/collabroom/", [dataManager getSelectedCollabroomId], "?geoType=4326", @"&userId=",[dataManager getUserId],@"&fromDate=", timestampOfLastFeature , @"&dateColumn=seqtime"] statusCode:&statusCode];
			
			NSError* error = nil;
			
			MarkupMessage *message = [[MarkupMessage alloc] initWithString:json error:&error];
			
			if([message.features count] > 0 || [message.deletedFeature count] > 0 ) {
				for(MarkupFeature *feature in message.features) {
					feature.collabRoomId = [dataManager getSelectedCollabroomId];
					[feature filterGeometry];
				}
				
				MarkupPayload *payload = [[MarkupPayload alloc] init];
				payload.features = message.features;
				payload.incidentId = [dataManager getActiveIncidentId];
				
				[dataManager addMarkupFeaturesToHistory:payload.features];
				
				if(timestampOfLastFeature > 1){
					for(NSString *featureId in message.deletedFeature){
						[dataManager deleteMarkupFeatureFromReceiveTableByFeatureId:featureId];
					}
				}
				
				dispatch_async(dispatch_get_main_queue(), ^{
					
					NSDictionary *markupMessageDictionary = [NSDictionary dictionaryWithObjectsAndKeys:json,@"markupFeaturesJson", nil];
					NSNotification *markupFeaturesReceivedNotification = [NSNotification notificationWithName:@"markupFeaturesUpdateReceived" object:self userInfo:markupMessageDictionary];
					
					[notificationCenter postNotification:markupFeaturesReceivedNotification];
				});
			}
		});
		receivingMapMarkupFeatures = NO;
		completion(YES);
	}
}

+(void)postMapMarkupFeatures{
	
	if(!sendingMapFeature) {
		sendingMapFeature = YES;
		NSMutableArray* features = [dataManager getAllMarkupFeaturesFromStoreAndForward];
		
		for(MarkupFeature *feature in features) {
			
			NSArray *keys;
			
			if([feature.type isEqualToString: @"marker"]){
				keys = [NSArray arrayWithObjects:@"fillColor",
					   @"geometry", @"graphic", @"graphicHeight",
					   @"graphicWidth", @"opacity",@"strokeColor",@"strokeWidth",@"type",@"username",@"usersessionId",@"seqtime", nil];
			}else if([feature.type isEqualToString: @"circle"]){
				keys = [NSArray arrayWithObjects:@"fillColor",@"geometry",@"opacity",@"strokeColor",@"strokeWidth",@"type",@"username",@"usersessionId",@"seqtime",nil];
			}else if([feature.type isEqualToString: @"sketch"]){
				keys = [NSArray arrayWithObjects:@"fillColor",@"geometry",@"opacity",@"strokeColor",@"strokeWidth",@"type",@"username",@"usersessionId",@"seqtime",nil];
			}else if([feature.type isEqualToString: @"square"] || [feature.type isEqualToString: @"polygon"]){
				keys = [NSArray arrayWithObjects:@"fillColor",@"geometry",@"opacity",@"strokeColor",@"strokeWidth",@"type",@"username",@"usersessionId",@"seqtime",nil];
			}
			
			NSString *jsonString = [feature toJSONStringWithKeys:keys];
			
			if([feature.type isEqualToString: @"marker"]){
				jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
			}
			
			NSData *postData = [NSData dataWithBytes:[jsonString UTF8String] length:[jsonString length]];
			
			dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
			dispatch_async(queue, ^{
				
				NSInteger statusCode = -1;
				NSString* result = [self synchronousPostToUrl:[NSString stringWithFormat:@"%@%@%@", @"features/collabroom/", feature.collabRoomId,  @"?geoType=4326"] postData:postData length:[jsonString length] statusCode:&statusCode];
				
				if(statusCode == 200 || statusCode == 201) {
					NSLog(@"%@%@", @"Successfully posted Map Feature...\n", result);
					[dataManager deleteMarkupFeatureFromStoreAndForward:feature];
				} else {
					NSLog(@"%@%@", @"Failed to send Map Feature...\n", result);
				}
			});
		}
		sendingMapFeature = NO;
	}
}

+(void) getWeatherUpdateForLatitude:(double)latitude longitude:(double) longitude completion:(void (^)(BOOL successful)) completion {
	
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
	dispatch_async(queue, ^{
		NSInteger statusCode = -1;
		
		NSString* json = [self synchronousGetFromUrl:[NSString stringWithFormat:@"%@%f%@%f%@", @"http://forecast.weather.gov/MapClick.php?lat=", latitude, @"&lon=", longitude, @"&FcstType=json"] statusCode:&statusCode];
		NSError* error = nil;
		
		WeatherPayload *payload = [[WeatherPayload alloc] initWithString:json error:&error];
		if(payload != nil) {
			dispatch_async(dispatch_get_main_queue(), ^{
				NSNotification *weatherUpdateReceivedNotification = [NSNotification notificationWithName:@"weatherUpdateReceived" object:payload];
				[notificationCenter postNotification:weatherUpdateReceivedNotification]; });
		}
	});
}

+(void) getChatMessagesForCollabroomId:(NSNumber *)collabRoomId completion:(void (^)(BOOL))completion {
	if(!receivingChatMessages && ![collabRoomId  isEqual: @-1]) {
		receivingChatMessages = YES;
		dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
		dispatch_async(queue, ^{
			NSInteger statusCode = -1;
			
			double latestTimestamp = [[dataManager getLastChatMessageTimestampForCollabroomId:collabRoomId] doubleValue] + 1;
			
			NSString* json = [self synchronousGetFromUrl:[NSString stringWithFormat:@"%@%@%@%@%@", @"chatmsgs/",collabRoomId,@"?sortOrder=desc&fromDate=", [NSNumber numberWithDouble:latestTimestamp],@"&dateColumn=created"]statusCode:&statusCode];
			NSError* error = nil;
			
			NSError *jsonError;
			NSData *objectData = [json dataUsingEncoding:NSUTF8StringEncoding];
			NSDictionary *jsonDict ;
			if(objectData!=nil){
				jsonDict = [NSJSONSerialization JSONObjectWithData:objectData
												   options:NSJSONReadingMutableContainers
													error:&jsonError];
			}else{
				return;
			}
			//this should set automatically but the nics6 json format for chat is really big right now and will probably change
			//So i am setting it manually below until the format is final.
			
			ChatMessage *message = [[ChatMessage alloc] initWithString:json error:&error];
			
			NSMutableArray* chats = [jsonDict objectForKey:@"chats"];
			NSUInteger count = 0;
			
			NSUInteger forLoopCounter = 0;
			if([message.chats count] > 0) {
				for(ChatPayload *payload in message.chats) {
					
					payload.incidentId = [dataManager getActiveIncidentId];
					payload.id = payload.chatid;
					
					jsonDict = [chats objectAtIndex:forLoopCounter];
					
					payload.userId = [[[jsonDict objectForKey:@"userorg"] objectForKey:@"user"] objectForKey:@"userId"];
					payload.userOrgName = [[[jsonDict objectForKey:@"userorg"] objectForKey:@"org"] objectForKey:@"name"];
					payload.nickname = [[[jsonDict objectForKey:@"userorg"] objectForKey:@"user"] objectForKey:@"username"];
					count++;
					
					[dataManager addChatMessageToHistory:payload];
					forLoopCounter++;
				}
			}
			
			if(count > 0){
				dispatch_async(dispatch_get_main_queue(), ^{
					NSNotification *chatMessagesReceivedNotification = [NSNotification notificationWithName:@"chatMessagesUpdateReceived" object:self userInfo:nil];
					[notificationCenter postNotification:chatMessagesReceivedNotification];
				});
			}else{
				NSNotification *chatMessagesReceivedNotification = [NSNotification notificationWithName:@"chatMessagesPolledNothing" object:self userInfo:nil];
				[notificationCenter postNotification:chatMessagesReceivedNotification];
			}
			
			receivingChatMessages = NO;
			completion(YES);
		});
	}
}

+(void) postChatMessages {
	if(!sendingChatMessages) {
		sendingChatMessages = YES;
		NSMutableArray* chatMessages = [dataManager getAllChatMessagesFromStoreAndForward];
		
		for(ChatPayload *payload in chatMessages) {
			NSString *jsonString = [payload toJSONStringPost];
			NSData *postData = [NSData dataWithBytes:[jsonString UTF8String] length:[jsonString length]];
			
			dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
			dispatch_async(queue, ^{
				
				NSInteger statusCode = -1;
				NSString* result = [self synchronousPostToUrl:[NSString stringWithFormat:@"%@%@", @"chatmsgs/",[dataManager getSelectedCollabroomId]] postData:postData length:[jsonString length] statusCode:&statusCode];
				
				if(statusCode == 200 || statusCode == 201) {
					[dataManager deleteChatMessageFromStoreAndForward:payload];
					[dataManager requestChatMessagesRepeatedEvery:[DataManager getChatUpdateFrequencyFromSettings] immediate:YES];
				} else {
					NSLog(@"%@%@", @"Failed to send Chat Message...\n", result);
				}
			});
		}
		sendingChatMessages = NO;
	}
}


+(void) postMDTs: (MDTPayload*) payload {
	if(!sendingMDTs) {
		sendingMDTs = YES;
		
		//     MDTPayload *payload;
		
		NSString *jsonString = [payload toJSONStringPost];
		NSData *postData = [NSData dataWithBytes:[jsonString UTF8String] length:[jsonString length]];
		
		dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
		dispatch_async(queue, ^{
			
			NSInteger statusCode = -1;
			NSString* result = [self synchronousPostToUrl:[NSString stringWithFormat:@"%@", @"mdtracks"] postData:postData length:[jsonString length] statusCode:&statusCode];
			
			if(statusCode == 200 || statusCode == 201) {
				NSString *inStr = [NSString stringWithFormat: @"%ld", (long)statusCode];
				NSLog(@"%@%@", @"MDT sent ...\n", inStr);
			} else {
				NSLog(@"%@%@", @"Failed to send MDT Message...\n", result);
			}
		});
	}
	sendingMDTs = NO;
}

+(NSString *) deleteMarkupFeatureById:(NSString *)featureId {
	NSLog(@"Deleting markup feature...");
	NSURL* postUrl = [NSURL URLWithString:[NSString stringWithFormat: @"%@%@%@%@%@", BASE_URL, @"mapmarkups/", dataManager.getActiveWorkspaceId, @"/", featureId]];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:postUrl];
	
	[request setValue:myOpenAmAuth.AuthValue forHTTPHeaderField:@"Authorization"];
	
	[request setHTTPMethod:@"DELETE"];
	NSHTTPURLResponse *response = nil;
	NSError *error = nil;
	NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	
	return [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
}

+ (void) getWFSDataLayers{
	
	NSInteger statusCode = -1;
	
	NSString* json = [self synchronousGetFromUrl:[NSString stringWithFormat:@"%@%@%@", @"datalayer/", [dataManager getActiveWorkspaceId], @"/tracking"] statusCode:&statusCode];
	
	NSError* error = nil;
	
	TrackingLayerMessage *message = [[TrackingLayerMessage alloc] initWithString:json error:&error];
	
	if(error != nil){
		NSLog(@" error => %@ ", [error userInfo]);
	}
	
	if(message != nil){
		[ActiveWfsLayerManager setTrackingLayers:message.data];
	}
}

+ (void) getActiveWFSData{
	if(receivingWfsFeatures == NO)
	{
		receivingWfsFeatures = YES;
		__block bool failedToPull = NO;
		
		dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
		dispatch_async(queue, ^{
			
			for(int i = 0; i < [ActiveWfsLayerManager getTrackingLayers].count ; i++)
			{
				TrackingLayerPayload* currentLayer = [[ActiveWfsLayerManager getTrackingLayers] objectAtIndex:i];
				
				if([dataManager getTrackingLayerEnabled:currentLayer.displayname]){
					
					if(currentLayer.datasourceid == nil){
						[self getWfsDataForLayer : currentLayer];
					}else{
						if(currentLayer.authToken == nil){
							[self getWfsDataToken : currentLayer];
						}else{
							if(currentLayer.authToken.expires <= [[NSDate date] timeIntervalSince1970] * 1000.00){
								[self getWfsDataToken : currentLayer];
							}else{
								if(currentLayer.authToken.token != nil){
									[self getWfsDataForLayer : currentLayer];
								}
							}
						}
					}
				}
			}
			
			receivingWfsFeatures = NO;
			
			if(failedToPull == NO)
			{
				NSNotification *WfsUpdateRecievedNotification = [NSNotification notificationWithName:@"WfsUpdateRecieved" object:nil];
				[notificationCenter postNotification:WfsUpdateRecievedNotification];
			}
			
		});
	}
}

+ (void)getWfsDataForLayer: (TrackingLayerPayload*) layer{
	
	NSMutableArray *ParsedWfsFeatures = [[NSMutableArray alloc] init];
	
	NSMutableString *urlString = [[NSMutableString alloc] init];
	if([layer shouldExpectJson]){
		[urlString setString: [layer.internalurl stringByAppendingString:@"?service=WFS&outputFormat=json&version=1.1.0&request=GetFeature&srsName=EPSG:4326&typeName="]];
	}else{
		[urlString setString: [layer.internalurl stringByAppendingString:@"?service=WFS&version=1.1.0&request=GetFeature&srsName=EPSG:4326&typeName="]];
	}
	
	[urlString appendString:layer.layername];
	[urlString appendString:@"&maxFeatures=500"];
	
	if(layer.authToken != nil){
		if(layer.authToken.token != nil){
			[urlString appendString:@"&token="];
			[urlString appendString:layer.authToken.token];
		}
	}
	
	NSLog([@"Requesting wfs tracking update: " stringByAppendingString:urlString]);
	NSData *fullStringData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:urlString]];
	
	if(fullStringData == nil){
		NSLog([@"Failed to get WFS Layer: " stringByAppendingString:layer.layername]);
		return;
	}
	
	NSMutableDictionary *featureCollectiondictionary;
	
	if([layer shouldExpectJson]){
		NSError *JSONerror = nil;
		featureCollectiondictionary = [NSJSONSerialization JSONObjectWithData:fullStringData options:NSJSONReadingMutableContainers error:&JSONerror];
		
		NSArray* allFeatures = featureCollectiondictionary[@"features"];
		for ( NSDictionary *currentFeature in allFeatures)
		{
			WfsFeature* newFeature = [[WfsFeature alloc] init];
			[newFeature setupWithDictionary: currentFeature];
			
			[ParsedWfsFeatures addObject:newFeature];
			
			layer.features = ParsedWfsFeatures;
			[ActiveWfsLayerManager UpdateTrackingLayer: layer];
		}
	}else{
		WfsXmlParser *parser = [[WfsXmlParser alloc]init];
		[parser parseXml: fullStringData: layer];
		
		parser.delegate = self;
	}
}




+ (NSDictionary*) getLocationBasedDataForLatitude:(double)lat andLongitude:(double)lon
{
	NSLog(@"ROC - About to request location-based data for location: %f, %f",lat,lon);
	
	NSInteger statusCode = -1;
	
	NSString *url = [NSString stringWithFormat:@"reports/1/locationBasedData?longitude=%f&latitude=%f&CRS=EPSG:4326&searchRangeInMiles=100",lon,lat];

	
	NSLog(@"ROC - About to request location-based data from URL: \"%@\"",url);
	
	
	NSString* jsonString = [self synchronousGetFromUrl:url statusCode:&statusCode];
	
	NSError* error = nil;
	
	
	NSLog(@"ROC - got location-based data JSON: \"%@\"",jsonString);
	
	
	if(jsonString != nil)
	{
		NSData *jsonStringData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
		
		
		NSError *error = nil;
		id object = [NSJSONSerialization JSONObjectWithData:jsonStringData options:0 error:&error];
		
		// Check if json was malformed
		if(!error)
		{
			if([object isKindOfClass:[NSDictionary class]])
			{
				NSDictionary *jsonDictionary = object;
				
				
				if([jsonDictionary[@"status"] intValue] == 200)
				{
					if([jsonDictionary[@"message"] isEqualToString:@"OK"])
					{
						NSDictionary *locationDataDictionary = jsonDictionary[@"data"];

						return locationDataDictionary;
					}
				}
			}
		}
	}
	
	// If we reached this statement, there was an error somewhere above
	return nil;
}







+ (void)WfsXmlParsingComplete: (NSMutableArray*)features: (TrackingLayerPayload*)layer{
	
	
}

+ (void)getWfsDataToken : (TrackingLayerPayload*) layer{
	
	NSInteger statusCode = -1;
	
	NSString* json = [self synchronousGetFromUrl:[NSString stringWithFormat:@"%@%@%@%@", @"datalayer/", [dataManager getActiveWorkspaceId], @"/token/",layer.datasourceid] statusCode:&statusCode];
	
	NSError* error = nil;
	
	TrackingTokenPayload *token = [[TrackingTokenPayload alloc] initWithString:json error:&error];
	
	layer.authToken = token;
	[ActiveWfsLayerManager UpdateTrackingLayer: layer];
	
	if(token != nil){
		[self getWfsDataForLayer: layer];
	}else if(token == nil){
		layer.authToken = [[TrackingTokenPayload alloc]init];
		layer.authToken.token = nil;
		
		long temp =  [[NSDate date] timeIntervalSince1970] * 1000.00;
		layer.authToken.expires = temp + 120000;//set invalid token to expire in 2 minutes;
	}
	
}

+ (void)getUserOrgs:(NSNumber*) userId{
	
	NSInteger statusCode = -1;
	NSString* json = [self synchronousGetFromUrl:[NSString stringWithFormat:@"%@%@%@%@", @"orgs/", [dataManager getActiveWorkspaceId], @"?userId=", userId] statusCode:&statusCode];
	
	NSError* error = nil;
	
	OrganizationMessage *message = [[OrganizationMessage alloc] initWithString:json error:&error];
	
	//    if([message.organizations count] > 0) {
	//        for(OrganizationPayload *org in message.organizations) {
	//            org.collabRoomId = [dataManager getSelectedCollabroomId];
	//            [feature filterGeometry];
	//        }
	
	
	[dataManager setOrgData:message.organizations[0]];
	
	
	//        MarkupPayload *payload = [[MarkupPayload alloc] init];
	//        payload.features = message.features;
	//        payload.incidentId = [dataManager getActiveIncidentId];
	//
	//        [dataManager addMarkupFeaturesToHistory:payload.features];
	//    }
	
}

+ (NSString *) authValue {
	@synchronized(self) {
		return authValue;
	}
}

+ (void) setAuthValue:(NSString *)value {
	@synchronized(self) {
		authValue = value;
	}
}

+ (void)setSendingSimpleReport:(BOOL)value {
	sendingSimpleReports = value;
}

@end
