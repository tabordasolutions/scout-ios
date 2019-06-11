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
//  ReportOnConditionTable.m
//  SCOUT Mobile
//
//  Created by Luis Gutierrez on 4/16/19.
//  Copyright © 2019 MIT Lincoln Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReportOnConditionTable.h"

@implementation ReportOnConditionTable

static NSDictionary * tableColumnsDictionary;

- (id)initWithName:(NSString *)tableName databaseQueue:(FMDatabaseQueue *) databaseQueue
{
	self = [super initWithName:tableName databaseQueue:databaseQueue];
	if (self)
	{
		tableColumnsDictionary =
			[[NSDictionary alloc] initWithObjectsAndKeys:
				// Whether the Report has been sent or it is waiting to send
				@"integer",		@"status",
				// Creation time in UTC
				@"integer",		@"createdUTC",
			 	// Incident Id (to allow us to query by incident id)
				@"integer",		@"incidentID",
				// Incident Name (to allow us to query by incident name)
			 	@"text",			@"incidentName",
			 	// The actual report data
			 	@"text",			@"json",
				nil
			];

		// Using a compound primary key:
		[self createTableFromDictionary:tableColumnsDictionary withPrimaryKey:@"(createdUTC, incidentID)"];
		
	}
	return self;
}


- (BOOL) addData:(ReportOnConditionData *) data
{
	NSLog(@"ROCDB - insert %@",[data toSqlMapping]);
	NSLog(@"ROCDB - specifically, insert %@",[ReportOnConditionData jsonDictionaryToJsonString:[data toSqlMapping]]);
	
	return [self insertRowForTableDictionary:tableColumnsDictionary dataDictionary:[data toSqlMapping]];
}

- (void) removeData:(ReportOnConditionData *) data
{
	NSString *key1;
	id value1;
	// If incident id is -1, then the payload was a "NEW" ROC that created the incident
	// Instead, query by incident name
	if(data.incidentid == -1)
	{
		key1 = @"incidentName";
		value1 = data.incidentname;
	}
	// otherwise, we have a valid incident id, just use that
	else
	{
		key1 = @"incidentID";
		value1 = [NSNumber numberWithLong:data.incidentid];
	}
	
	NSString *key2 = @"createdUTC";
	NSNumber *value2 = [NSNumber numberWithLong:[data.datecreated timeIntervalSince1970]];
	
	NSLog(@"ROC - ReportOnConditionTable - removeData - Deleting ROCs in table \"%@\" where \"%@\" = \"%@\" and \"%@\" = \"%@\"",[self tableName], key1, value1, key2, value2);
	[self deleteRowsByKey:key1 withValue:value1 andKey:key2 withValue:value2];
}

- (BOOL) addDataArray:(NSArray *) dataArray
{
	for(ReportOnConditionData *data in dataArray)
	{
		if(data != nil)
		{
			[self addData:data];
		}
	}
	return true;
}

- (NSNumber *) getLastReportOnConditionTimestampForIncidentId: (NSNumber *)incidentId {
	NSDictionary* result = [[self selectRowsByKey:@"incidentID" value:incidentId orderedBy:[NSArray arrayWithObject:@"createdUTC"] isDescending:YES] firstObject];
	
	if(result != nil) {
		return [result objectForKey:@"createdUTC"];
	} else {
		return @0;
	}
}

- (ReportOnConditionData *) getLastReportOnConditionForIncidentId: (NSNumber *)incidentId {
	NSLog(@"ROC - ROCTable - getLastReportOnConditionForIncidentId");
	NSDictionary* result = [[self selectRowsByKey:@"incidentID" value:incidentId orderedBy:[NSArray arrayWithObject:@"createdUTC"] isDescending:YES] firstObject];
	
	return [ReportOnConditionData fromSqlMapping:result];
}

- (NSMutableArray<ReportOnConditionData> *) getReportOnConditionsForIncidentId: (NSNumber *)incidentId since: (NSNumber *)timestamp {
	NSLog(@"ROC - ROCTable - getReportOnConditionsForIncidentId");
	NSDictionary *keys = [[NSDictionary alloc] initWithObjectsAndKeys:
					  incidentId,     @"incidentID = ?",
					  timestamp,      @"createdUTC >= ?",
					  nil];

	NSMutableArray *results = [self selectRowsByKeyDictionary:keys orderedBy:[NSArray arrayWithObject:@"createdUTC"] isDescending:YES];
	
	
	NSMutableArray<ReportOnConditionData> *parsedResults = [NSMutableArray<ReportOnConditionData> new];
	
	for(NSDictionary *result in results)
	{
		ReportOnConditionData *data = [ReportOnConditionData fromSqlMapping:result];
		[parsedResults addObject:data];
	}
	
	return parsedResults;
}

- (NSMutableArray<ReportOnConditionData> *) getAllReportOnConditions {
	NSLog(@"ROC - ROCTable - getAllReportOnConditions");
	NSMutableArray *results = [self selectAllRowsAndOrderedBy:[NSArray arrayWithObject:@"createdUTC"] isDescending:YES];
	
	NSMutableArray<ReportOnConditionData> *parsedResults = [NSMutableArray<ReportOnConditionData> new];
	
	for(NSDictionary *result in results) {
		ReportOnConditionData *data = [ReportOnConditionData fromSqlMapping:result];
		[parsedResults addObject:data];
	}
	
	return parsedResults;
}

@end
