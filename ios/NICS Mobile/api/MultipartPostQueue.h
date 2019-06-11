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
//  MultipartPostQueue.h
//  NICS Mobile
//
//

#import <Foundation/Foundation.h>
#import "AssetsLibrary/AssetsLibrary.h"
#import "SimpleReportPayload.h"
#import "ReportPayload.h"
#import "RestClient.h"
#import "Enums.h"

@interface MultipartPostQueue : NSObject  <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

// If we detect that the app's login is invalid, stop future report posts
// until the login is valid again.
@property bool postingStopped;

// Repeatedly checks the server to verify that the current session ID is still active.
@property NSTimer *checkSessionIDValidityTimer;
-(void) checkSessionIDValidity:(bool) fromFR;
-(void) startCheckSessionIDValidityTimer;

// Holds a list of user session IDs we have already found to be invalid,
// so we don't prompt the user for the same invalid session twice
@property NSMutableArray *invalidSessionsHandled;
// Returns true if invalidUSIDsHandled contains usid
// If not, adds the usid to the array and returns false
-(BOOL) invalidSessionAlreadyHandled:(long)usid;



+(id) getInstance;

-(id) init;
-(void) dealloc;
- (void)postReport: (NSObject*) report;
- (void)postSimpleReport: (SimpleReportPayload*) payload;
-(void) postDamageReports: (DamageReportPayload*) payload;
- (void) checkIfMessageAccepted;
// Sends the next report in the queue
- (void) sendRemainingReports;
- (void) stopSendingReports;
- (void) resumeSendingReports;
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;

-(void)addPayloadToSendQueue:(NSObject*) payload;
-(void)addCachedReportsToSendQueue;
@end
