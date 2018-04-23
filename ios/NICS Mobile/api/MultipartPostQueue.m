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
//  MultipartPostQueue.m
//  NICS Mobile
//
//

#import "MultipartPostQueue.h"

#import "OverviewViewController.h"

@implementation MultipartPostQueue

static DataManager *dataManager;

static NSURLConnection *activeConnection;

static int RESPONSE_NONE = 0;
static int RESPONSE_OK = 1;
static int RESPONSE_FAIL = 2;

// These are assigned to RESPONSE_NONE when a connection is initialized
// As the server sends a response / data, we will set these both to the appropriate response value
static int activeConnectionReceiveResponse;
static int activeConnectionReceiveData;

// A posted simplereport / damage report will only ever be marked as sent when
// both of the above integers are equal to RESPONSE_OK


static NSMutableArray *sendQueue;
static ALAssetsLibrary *assetsLibrary;
static NSNotificationCenter *notificationCenter;

+ (id)getInstance {
	static MultipartPostQueue *instance = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		instance = [[self alloc] init];
	});
	
	return instance;
}


- (id) init {
	if (self = [super init]) {
		_postingStopped = false;
		sendQueue = [[NSMutableArray alloc]init];
		assetsLibrary = [ALAssetsLibrary new];
		notificationCenter = [NSNotificationCenter defaultCenter];
		dataManager = [DataManager getInstance];
		invalidSessionsHandled = nil;
		
		// Luis's note:
		// I disabled this. This sends previously unsent reports.
		// This should not be called until after the login is completed.
		// I moved this code to an appropriate location so that it is called
		// after the user logs in.
		//    [self addCahcedReportsToSendQueue];
		
		[self startCheckSessionIDValidityTimer];
	}
	return self;
}

-(void) postReport: (ReportPayload*) reportPayload{
	
	if(_postingStopped)
		return;
	
	NSLog(@"USIDDEFECT, postReport, report being posted to server");
	
	if(reportPayload.formtypeid == [NSNumber numberWithLong:SR]){
		NSLog(@"USIDDEFECT,      postReport report type is SR");
		[self postSimpleReport:reportPayload];
	}else if (reportPayload.formtypeid == [NSNumber numberWithLong:DR]){
		NSLog(@"USIDDEFECT,      postReport report type is SR");
		[self postDamageReports:reportPayload];
	}
}





-(void) postSimpleReport: (SimpleReportPayload*) payload{
	
	// If the field report has no image associated with it:
	NSLog(@"Full image path: %@",payload.messageData.fullpath);
	if([payload.messageData.fullpath length] == 0)
	{
		// No image supplied, use a default placeholder image.
		
		// Luis's note:
		// This is sort of an ugly hack.
		// The client requested being able to upload Field Reports without any attached images,
		// and I was unable to succesfully integrate support for posting a FR with no image,
		// so as a temporary workaround, I will make it so Field Reports with no image get uploaded
		// with a placeholder default image.
		
		// For a normal SCOUT logo
		//UIImage* placeholderImage = [UIImage imageNamed:@"SCOUT_logo"];
		// An image with "No image associated with this report" text with a faded SCOUT background
		
		UIImage* placeholderImage = [UIImage imageNamed:@"SCOUT_FR_noimage_placeholder"];
		NSData* imageContainer = UIImagePNGRepresentation(placeholderImage);
		NSString* placeholderImagePath = [[NSBundle mainBundle] resourcePath];
		Byte *buffer = (Byte*)malloc([imageContainer length]);
		[imageContainer getBytes:buffer length:[imageContainer length]];
		NSData *imageData = [NSData dataWithBytesNoCopy:buffer length:[imageContainer length] freeWhenDone:YES];
		
		if(imageData)
		{
			NSLog(@"FRIMG, successfully got image data for default image");
			// create post request params
			NSInteger statusCode = -1;
			
			NSMutableDictionary *requestParams = [NSMutableDictionary new];
			[requestParams setObject:[[UIDevice currentDevice].identifierForVendor UUIDString] forKey:@"deviceId"];
			[requestParams setObject:payload.incidentid forKey:@"incidentid"];
			[requestParams setObject:[dataManager getUserSessionId] forKey:@"usersessionid"];
			//[requestParams setObject:payload.usersessionid forKey:@"usersessionid"];
			[requestParams setObject:payload.messageData.latitude forKey:@"latitude"];
			[requestParams setObject:payload.messageData.longitude forKey:@"longitude"];
			[requestParams setObject:@0.0 forKey:@"altitude"];
			[requestParams setObject:@0.0 forKey:@"track"];
			[requestParams setObject:@0.0 forKey:@"speed"];
			[requestParams setObject:@0.0 forKey:@"accuracy"];
			[requestParams setObject:payload.messageData.msgDescription forKey:@"description"];
			[requestParams setObject:payload.messageData.category forKey:@"category"];
			[requestParams setObject:payload.seqtime forKey:@"seqtime"];
			
			activeConnection = [RestClient synchronousMultipartPostToUrl:[NSString stringWithFormat:@"%@%@%@", @"reports/", payload.incidentid,  @"/SR"] postData:imageData imageName:placeholderImagePath requestParams:requestParams statusCode:&statusCode];
			activeConnectionReceiveResponse = RESPONSE_NONE;
			activeConnectionReceiveData = RESPONSE_NONE;
			//Luis: This class is the delegate for these connections.
			[activeConnection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
			[activeConnection start];
			NSLog(@"USIDDEFECT Imageless post was just sent: Status Code: %ld",statusCode);
		}
		else
		{
			NSLog(@"FRIMG, warning, failed to get image data for default image");
			NSLog(@"USIDDEFECT Imageless post failed to send, did not get default image");
		}
		
		
		// The following code executes synchronousMultipartPostToUrl with no image
		// This method doesn't work, but should really be fixed in the future
		// Post a SR without an image
		/*NSInteger statusCode = -1;
		 
		 NSMutableDictionary *requestParams = [NSMutableDictionary new];
		 [requestParams setObject:[[UIDevice currentDevice].identifierForVendor UUIDString] forKey:@"deviceId"];
		 [requestParams setObject:payload.incidentid forKey:@"incidentid"];
		 [requestParams setObject:payload.usersessionid forKey:@"usersessionid"];
		 [requestParams setObject:payload.messageData.latitude forKey:@"latitude"];
		 [requestParams setObject:payload.messageData.longitude forKey:@"longitude"];
		 [requestParams setObject:@0.0 forKey:@"altitude"];
		 [requestParams setObject:@0.0 forKey:@"track"];
		 [requestParams setObject:@0.0 forKey:@"speed"];
		 [requestParams setObject:@0.0 forKey:@"accuracy"];
		 [requestParams setObject:payload.messageData.msgDescription forKey:@"description"];
		 [requestParams setObject:payload.messageData.category forKey:@"category"];
		 [requestParams setObject:payload.seqtime forKey:@"seqtime"];
		 
		 // Post the report without an image
		 activeConnection = [RestClient synchronousMultipartPostToUrl:[NSString stringWithFormat:@"%@%@%@", @"reports/", payload.incidentid,  @"/SR"]
		 postData:nil imageName:nil requestParams:requestParams statusCode:&statusCode];
		 
		 [activeConnection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
		 [activeConnection start];*/
		
		return;
	}
	
	
	[assetsLibrary assetForURL:[NSURL URLWithString:payload.messageData.fullpath]
				resultBlock:^(ALAsset *asset) {
					NSInteger statusCode = -1;
					
					ALAssetRepresentation *rep = [asset defaultRepresentation];
					NSNumber *length = [NSNumber numberWithLongLong:rep.size];
					
					Byte *buffer = (Byte*)malloc([length unsignedLongValue]);
					NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:[length unsignedLongValue] error:nil];
					
					NSData *imageData = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
					
					if(imageData) {
						// create post request params
						
						NSMutableDictionary *requestParams = [NSMutableDictionary new];
						[requestParams setObject:[[UIDevice currentDevice].identifierForVendor UUIDString] forKey:@"deviceId"];
						[requestParams setObject:payload.incidentid forKey:@"incidentid"];
						[requestParams setObject:[dataManager getUserSessionId] forKey:@"usersessionid"];
						//[requestParams setObject:payload.usersessionid forKey:@"usersessionid"];
						[requestParams setObject:payload.messageData.latitude forKey:@"latitude"];
						[requestParams setObject:payload.messageData.longitude forKey:@"longitude"];
						[requestParams setObject:@0.0 forKey:@"altitude"];
						[requestParams setObject:@0.0 forKey:@"track"];
						[requestParams setObject:@0.0 forKey:@"speed"];
						[requestParams setObject:@0.0 forKey:@"accuracy"];
						[requestParams setObject:payload.messageData.msgDescription forKey:@"description"];
						[requestParams setObject:payload.messageData.category forKey:@"category"];
						[requestParams setObject:payload.seqtime forKey:@"seqtime"];
						
						// If the payload did not specify an image:
						// FIXME: this leads to an invalid image being sent to the server
						//if([payload.messageData.fullpath length] == 0)
						//{
						//	   activeConnection = [RestClient synchronousMultipartPostToUrl:[NSString stringWithFormat:@"%@%@%@", @"reports/", payload.incidentid,  @"/SR"] postData:nil imageName:nil requestParams:requestParams statusCode:&statusCode];
						//}
						//else
						//{
						//   activeConnection = [RestClient synchronousMultipartPostToUrl:[NSString stringWithFormat:@"%@%@%@", @"reports/", payload.incidentid,  @"/SR"] postData:imageData imageName:payload.messageData.fullpath requestParams:requestParams statusCode:&statusCode];
						//}
						
						activeConnection = [RestClient synchronousMultipartPostToUrl:[NSString stringWithFormat:@"%@%@%@", @"reports/", payload.incidentid,  @"/SR"] postData:imageData imageName:payload.messageData.fullpath requestParams:requestParams statusCode:&statusCode];
						activeConnectionReceiveResponse = RESPONSE_NONE;
						activeConnectionReceiveData = RESPONSE_NONE;
						
						[activeConnection scheduleInRunLoop:[NSRunLoop mainRunLoop]
											   forMode:NSDefaultRunLoopMode];
						[activeConnection start];
						NSLog(@"USIDDEFECT post with image sent Status Code: %ld",statusCode);
						
					}
					
				} failureBlock:^(NSError *error) {
				}];
}

-(void) postDamageReports: (DamageReportPayload*) payload{
	[assetsLibrary assetForURL:[NSURL URLWithString:payload.messageData.drDfullPath] resultBlock:^(ALAsset *asset) {
		NSInteger statusCode = -1;
		
		ALAssetRepresentation *rep = [asset defaultRepresentation];
		NSNumber *length = [NSNumber numberWithLongLong:rep.size];
		
		Byte *buffer = (Byte*)malloc([length unsignedLongValue]);
		NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:[length unsignedLongValue] error:nil];
		
		NSData *imageData = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
		
		if(imageData) {
			NSMutableDictionary *requestParams = [NSMutableDictionary new];
			[requestParams setObject:[[UIDevice currentDevice].identifierForVendor UUIDString] forKey:@"deviceId"];
			[requestParams setObject:payload.incidentid forKey:@"incidentId"];
			//[requestParams setObject:payload.usersessionid forKey:@"usersessionid"];
			[requestParams setObject:[dataManager getUserSessionId] forKey:@"usersessionid"];
			[requestParams setObject:payload.seqtime forKey:@"seqtime"];
			[requestParams setObject:@"0" forKey:@"deviceId"];
			[requestParams setObject:payload.message forKey:@"msg"];
			
			activeConnection = [RestClient synchronousMultipartPostToUrl:[NSString stringWithFormat:@"%@%@%@", @"reports/", payload.incidentid,  @"/DMGRPT"] postData:imageData imageName:payload.messageData.drDfullPath requestParams:requestParams statusCode:&statusCode];
			activeConnectionReceiveResponse = RESPONSE_NONE;
			activeConnectionReceiveData = RESPONSE_NONE;
			
			[activeConnection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
			[activeConnection start];
		}
		
	}failureBlock:^(NSError *error) {
		
	}];
}


-(void)addPayloadToSendQueue:(ReportPayload*) payload{
	NSLog(@"USIDDEFECT, addPayloadToSendQueue");
	
	[sendQueue addObject:payload];
	
	if(sendQueue.count == 1){
		[self postReport: payload];
	}
}

- (void) stopSendingReports {
	_postingStopped = true;
}

- (void) resumeSendingReports {
	_postingStopped = false;
	NSLog(@"USIDDEFECT, Resume Sending Reports:");
	[self sendRemainingReports];
}

// Sends the next report in the queue
- (void) sendRemainingReports {
	NSLog(@"USIDDEFECT, sendRemainingReports called");
	activeConnection = nil;
	activeConnectionReceiveResponse = RESPONSE_NONE;
	activeConnectionReceiveData = RESPONSE_NONE;
	if(sendQueue.count >= 1){
		[self postReport: [sendQueue objectAtIndex:0]];
	}
}

// We call this in didReceiveResponse and didReceiveData,
// If we received an OK from both, we set the report's status to SENT
- (void) checkIfMessageAccepted {
	
	if(activeConnectionReceiveData == RESPONSE_OK && activeConnectionReceiveResponse == RESPONSE_OK) {
	
		ReportPayload* reportPayload = [sendQueue objectAtIndex:0];
		if(reportPayload != nil) {
			
			[sendQueue removeObject:reportPayload];
			
			if(reportPayload.formtypeid == [NSNumber numberWithLong:SR]) {
				
				[dataManager deleteSimpleReportFromStoreAndForward:(SimpleReportPayload*)reportPayload];
				[reportPayload setStatus: [NSNumber numberWithInt:SENT]];
				[dataManager addSimpleReportToStoreAndForward:(SimpleReportPayload*)reportPayload];
				
				[dataManager requestSimpleReportsRepeatedEvery:[[DataManager getReportsUpdateFrequencyFromSettings] intValue] immediate:YES];
			}
			else if (reportPayload.formtypeid == [NSNumber numberWithLong:DR]){
				
				[dataManager deleteDamageReportFromStoreAndForward:(DamageReportPayload*)reportPayload];
				[reportPayload setStatus: [NSNumber numberWithInt:SENT]];
				[dataManager addDamageReportToStoreAndForward:(DamageReportPayload*)reportPayload];
				
				[dataManager requestDamageReportsRepeatedEvery:[[DataManager getReportsUpdateFrequencyFromSettings] intValue] immediate:YES];
			}
		}
		NSLog(@"USIDDEFECT, success message received, sending remaining reports");
		// Send the next report
		[self sendRemainingReports];
	}
	else if(activeConnectionReceiveData == RESPONSE_FAIL || activeConnectionReceiveResponse == RESPONSE_FAIL)
	{
		NSLog(@"USIDDEFECT, failure message received, sending remaining reports");
		// Resend the failed report
		[self sendRemainingReports];
	}
	
	

	//TODO: if we want this to handle ending the connection, do it here
	//activeConnection = nil;
	// We don't really want this to terminate the connection if it hasn't received one of them yet...

}



- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	NSLog(@"USIDDEFECT, didReceiveResponse called %@",response);
	
	NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*) response;
	NSInteger statusCode = [httpResponse statusCode];
	
	NSLog(@"Received header fields: %s" , [httpResponse allHeaderFields]);
	
	NSLog(@"USIDDEFECT, didReceiveReponse: We received statusCode: %d",statusCode);
	if(statusCode == 200)
	{
		activeConnectionReceiveResponse = RESPONSE_OK;
	}
	else if(statusCode == 401)
	{
		// We don't know which session ID is invalid at this point, so:
		// If we received a 401 status code, do a check for invalid Session ID
		[self stopSendingReports];
		[self checkSessionIDValidity:true];
		
		// If we have already detected that the session is invalid don't show a duplicate notification
		// Note: If we were able to get the usid from the failed field report, use this.
		// For now, use the above code.
		//if(![self invalidSessionAlreadyHandled:usid])
		//{
		//	[(OverviewViewController*)[dataManager getOverviewController] showDuplicateLoginWarning:true];
		//	[self stopSendingReports];
		//}
		activeConnectionReceiveResponse = RESPONSE_FAIL;
	}
	else
	{
		activeConnectionReceiveResponse = RESPONSE_FAIL;
	}
	
	NSLog(@"USIDDEFECT, didReceiveReponse: checking if message accepted");
	[self checkIfMessageAccepted];
	
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
	NSLog(@"USIDDEFECT, didSendBodyData called");
	
	ReportPayload* payload =[sendQueue objectAtIndex:0];
	
	double percentage = ((double)totalBytesWritten/(double)totalBytesExpectedToWrite) * 100.0;
	
	NSLog(@"%@", [[Enums formTypeEnumToStringFull:[payload.formtypeid intValue]] stringByAppendingString: [NSString stringWithFormat:@"%f", percentage]] );
	
	[payload setProgress:[NSNumber numberWithDouble:percentage]];
	
	NSMutableDictionary *userInfo = [NSMutableDictionary new];
	[userInfo setObject:[NSNumber numberWithDouble: percentage] forKey:@"progress"];
	[userInfo setObject:payload.id forKey:@"id"];
	
	NSNotification *reportProgressNotification = [NSNotification notificationWithName: [[Enums formTypeEnumToStringAbbrev:[payload.formtypeid intValue]] stringByAppendingString:@"ReportProgressUpdateReceived"] object:nil userInfo:userInfo];
	[notificationCenter postNotification:reportProgressNotification];
}


//this system should get moved to some sort of queue to better manage multiple reports being sent at one time.
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	
	NSLog(@"USIDDEFECT, didReceiveData called");
	
	NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	ReportPayload* reportPayload = [sendQueue objectAtIndex:0];
	
	
	if(response) {
		NSLog(@"USIDDEFECT Received Response: %@",response);
		activeConnectionReceiveData = RESPONSE_OK;
	}else {
		NSLog(@"%@", [[Enums formTypeEnumToStringFull:reportPayload.formtypeid] stringByAppendingString:@" Failed to send...\n"]);
		
		activeConnectionReceiveData = RESPONSE_FAIL;
	}
	
	NSLog(@"USIDDEFECT, didReceiveData: checking if message accepted");
	[self checkIfMessageAccepted];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"USIDDEFECT, didFailWithError called");
	NSLog(@"%@",error);
	
	[self sendRemainingReports];
}

//Called when app is started to queue up any unsent reports that may have been canceled from app closing
-(void)addCahcedReportsToSendQueue{
	NSLog(@"USIDDEFECT, addCahcedReportsToSendQueue");
	NSLog(@"USIDDEFECT, addCahcedReportsToSendQueue: about to add all SRs");
	NSMutableArray* Reports = [dataManager getAllSimpleReportsFromStoreAndForward];
	NSLog(@"USIDDEFECT, addCahcedReportsToSendQueue: about to add all DRs");
	[Reports addObjectsFromArray:[dataManager getAllDamageReportsFromStoreAndForward]];
	
	NSLog(@"USIDDEFECT, addCahcedReportsToSendQueue: about to iterate through reports");
	for(ReportPayload *payload in Reports) {
		NSLog(@"Checking payload...");
		if(payload == nil)
			continue;
		NSLog(@"payload is not nil");
		if([payload.isDraft isEqual:@0] && [payload.status isEqualToNumber:@(WAITING_TO_SEND)]) {
			NSLog(@"payload is waiting to send");
			NSLog(@"USIDDEFECT, addCahcedReportsToSendQueue -> Payload is waiting to send, added to send queue");
			[self addPayloadToSendQueue:payload];
			NSLog(@"Finished adding payload to send");
		}
	}
	
	NSLog(@"Finished iterating through payloads");
	
	/*if(sendQueue.count >= 1){
	 NSLog(@"USIDDEFECT, postReport called with object at index 0");
	 [self postReport: [sendQueue objectAtIndex:0]];
	 }*/
}


-(void) checkSessionIDValidity:(bool) fromFR {
	NSLog(@"CheckSessionIDValidity called");
	if(![dataManager isLoggedIn])
	{
		return;
	}
	
	
	// Run the network request in a background thread:
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		NSInteger statusCode = -1;
		long usid = [[dataManager getUserSessionId] longValue];
		NSString *getURL = [NSString stringWithFormat:@"%@%@%@%ld",@"users/",@"1/",@"verifyActiveSession/",usid];
		
		NSString *json = [RestClient synchronousGetFromUrl:getURL statusCode:&statusCode];
		NSError* error = nil;
		
		NSLog(@"Checking validity of USID: %ld",usid);
		NSLog(@"Status Code: %d",(int)statusCode);
		NSLog(@"Response: %@",json);
		
		
		NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
		
		NSMutableDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
		
		bool sessionInvalid = false;
		// If we failed to convert the response to JSON:
		if(responseDictionary == nil)
		{
			NSLog(@"WARNING: Failed to convert validate Session response to JSON");
			sessionInvalid = true;
		}
		else
		{
			// Message format is as follows:
			//{“status”:200,“message”:“ok”,“activeSession”:false}
			//activeSession is false when it's invalid, true when valid
			NSNumber *activeSession = [responseDictionary objectForKey:@"activeSession"];
			
			NSLog(@"Active Session: %@",activeSession);
			
			if(![activeSession boolValue])
			{
				sessionInvalid = true;
			}
		}
		if(sessionInvalid == true && ![self invalidSessionAlreadyHandled:usid])
		{
			NSLog(@"WARNING: Session with usid: %ld is invalid!",usid);
			// Stop future polls:
			//[_checkSessionIDValidityTimer invalidate];
			//_checkSessionIDValidityTimer = nil;
			
			// Run showing the dialog on the main thread
			dispatch_async(dispatch_get_main_queue(), ^{
				[(OverviewViewController*)[dataManager getOverviewController] showDuplicateLoginWarning:fromFR];
			});
			// Resume polling:
			//[self startCheckSessionIDValidityTimer];
		}
	});
}

NSMutableArray *invalidSessionsHandled;

// Returns true if invalidUSIDsHandled contains usid
// If not, adds the usid to the array and returns false
-(BOOL) invalidSessionAlreadyHandled:(long)usid {
	if(_invalidSessionsHandled == nil)
	{
		_invalidSessionsHandled = [[NSMutableArray alloc] init];
	}
	
	for(NSNumber *num in _invalidSessionsHandled)
	{
		if([num longValue] == usid)
		{
			NSLog(@"USID %ld has already been handled",usid);
			return true;
		}
	}
	
	// usid was not found in the array, add it to the array.
	NSNumber *usidObj = [NSNumber numberWithLong:usid];
	[_invalidSessionsHandled addObject:usidObj];
	NSLog(@"USID %ld has not yet been handled",usid);
	return false;
}

-(void) startCheckSessionIDValidityTimer {
	if(_checkSessionIDValidityTimer != nil)
		[_checkSessionIDValidityTimer invalidate];
	_checkSessionIDValidityTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(checkSessionIDValidity:)
											userInfo:@{@"fromFR":@false} repeats:YES];
}

-(void) dealloc {
	// Stop and delete the session ID timer
	if(_checkSessionIDValidityTimer != nil)
	{
		[_checkSessionIDValidityTimer invalidate];
		_checkSessionIDValidityTimer = nil;
	}
}

@end


