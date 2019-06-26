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
//  ReportOnConditionData.h
//
//
//  Created by Luis Gutierrez on 4/16/19.
//

#import <Foundation/Foundation.h>
#import "ReportOnConditionData.h"

@implementation ReportOnConditionData



// Converts an NSDictionary payload to a ReportOnConditionData instance
// This method is used to parse the response from the server and create the ReportOnConditionData object
+ (ReportOnConditionData *)fromServerPayload:(NSDictionary *) payload
{
	ReportOnConditionData *rocData = [ReportOnConditionData new];
	
	@try
	{
		// Getting the message payload from the outermost payload
		NSMutableDictionary *messagePayload = [self jsonGetDictionaryFromJsonString:payload withName:@"message"];
		
		
		// Getting the roc payload from the message payload
		NSMutableDictionary *rocPayload = [self jsonGetDictionary:messagePayload withName:@"report"];
		
		//================================================
		// Form metadata fields:
		//================================================
		
		rocData.incidentid = [self jsonGetInt:payload withName:@"incidentid"];
	
		NSDateFormatter *serverSchemaDateFormatter = [NSDateFormatter new];
		[serverSchemaDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
		rocData.datecreated = [serverSchemaDateFormatter dateFromString:[self jsonGetString:messagePayload withName:@"datecreated"]];
		
		//================================================
		// ROC Form Info Fields
		//================================================
		rocData.incidentname = [self jsonGetString:payload withName:@"incidentname"];
		rocData.reportType = [self jsonGetString:rocPayload withName:@"reportType"];
		
		//================================================
		// Incident Info Fields
		//================================================
		rocData.incidentTypes = [self getIncidentTypesArrayFromJson:[self jsonGetDictionary:rocPayload withName:@"incidentTypes"]];
		
		rocData.latitude = [self jsonGetDouble:rocPayload withName:@"latitudeAtROCSubmission"];
		rocData.longitude = [self jsonGetDouble:rocPayload withName:@"longitudeAtROCSubmission"];
		
		// Not all server ROCs have an incidentState yet, we have to allow for that
		// Default to the empty string @"", if the payload doesn't have incidentState
		rocData.incidentState = [self jsonGetString:rocPayload withName:@"incidentState" defaultTo:@""];
		
		//================================================
		// ROC Incident Info Fields
		//================================================
		
		rocData.county = [self jsonGetString:rocPayload withName:@"county"];
		rocData.additionalAffectedCounties = [self jsonGetString:rocPayload withName:@"additionalAffectedCounties"];
		rocData.location = [self jsonGetString:rocPayload withName:@"location"];
		rocData.street = [self jsonGetString:rocPayload withName:@"street"];
		rocData.crossStreet = [self jsonGetString:rocPayload withName:@"crossStreet"];
		rocData.nearestCommunity = [self jsonGetString:rocPayload withName:@"nearestCommunity"];
		rocData.milesFromNearestCommunity = [self jsonGetString:rocPayload withName:@"milesFromNearestCommunity"];
		rocData.directionFromNearestCommonity = [self jsonGetString:rocPayload withName:@"directionFromNearestCommunity"];
		rocData.dpa = [self jsonGetString:rocPayload withName:@"dpa"];
		// not a bug, the json schema reuses "sra" as the ownership field
		rocData.ownership = [self jsonGetString:rocPayload withName:@"sra"];
		rocData.jurisdiction = [self jsonGetString:rocPayload withName:@"jurisdiction"];
		
		// Pare the start date and times to date objects
		// Use a different dateformatter from above
		NSDateFormatter *serverReportSchemaDateFormatter = [NSDateFormatter new];
		[serverReportSchemaDateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
		rocData.startDate = [serverReportSchemaDateFormatter dateFromString:[self jsonGetString:rocPayload withName:@"date"]];
		rocData.startTime = [serverReportSchemaDateFormatter dateFromString:[self jsonGetString:rocPayload withName:@"starttime"]];
		
		//================================================
		// Vegetation Fire Incident Scope Fields
		//================================================
		rocData.acreage = [self jsonGetString:rocPayload withName:@"scope"];
		rocData.spreadRate = [self jsonGetString:rocPayload withName:@"spreadRate"];
		
		rocData.fuelTypes = [self parseStringArrayFromJson:rocPayload withName:@"fuelTypes"];
		rocData.otherFuelTypes = [self jsonGetString:rocPayload withName:@"otherFuelTypes"];
		rocData.percentContained = [self jsonGetString:rocPayload withName:@"percentContained"];

		//================================================
		// Weather Information Fields
		//================================================
		
		rocData.temperature = [self jsonGetString:rocPayload withName:@"temperature"];
		rocData.relHumidity = [self jsonGetString:rocPayload withName:@"relHumidity"];
		rocData.windSpeed = [self jsonGetString:rocPayload withName:@"windSpeed"];
		rocData.windDirection = [self jsonGetString:rocPayload withName:@"windDirection"];

		// FIXME - add this once windgusts are part of the payload
		//rocData.windGusts = [self jsonGetString:rocPayload withName:@"windGusts"];
		rocData.windGusts = @"";
		
		//================================================
		// Threats & Evacuations Fields
		//================================================

		rocData.evacuations = [self jsonGetString:rocPayload withName:@"evacuations"];
		rocData.evacuationsInProgress = [self parseStringArrayFromJson:[self jsonGetDictionary:rocPayload withName:@"evacuationsInProgress"] withName:@"evacuations"];

		rocData.structureThreats = [self jsonGetString:rocPayload withName:@"structuresThreat"];
		rocData.structureThreatsInProgress = [self parseStringArrayFromJson:[self jsonGetDictionary:rocPayload withName:@"structuresThreatInProgress"] withName:@"structuresThreat"];
		
		rocData.infrastructureThreats = [self jsonGetString:rocPayload withName:@"infrastructuresThreat"];
		rocData.infrastructureThreatsInProgress = [self parseStringArrayFromJson:[self jsonGetDictionary:rocPayload withName:@"infrastructuresThreatInProgress"] withName:@"infrastructuresThreat"];
		
		//================================================
		// Resource Commitment Fields
		//================================================

		rocData.calfireIncident = [self jsonGetString:rocPayload withName:@"calfireIncident"];
		rocData.resourcesAssigned = [self parseStringArrayFromJson:[self jsonGetDictionary:rocPayload withName:@"resourcesAssigned"] withName:@"resourcesAssigned"];
		
		//================================================
		// Other Significant Info Fields
		//================================================

		// Field removed from form
		//rocData.otherThreatsAndEvacuations = [self jsonGetString:rocPayload withName:@"otherThreatsAndEvacuations"];
		rocData.otherThreatsAndEvacuationsInProgress = [self parseStringArrayFromJson:[self jsonGetDictionary:rocPayload withName:@"otherThreatsAndEvacuationsInProgress"] withName:@"otherThreatsAndEvacuations"];
		
		//================================================
		// Email Fields
		//================================================

		rocData.email = [self jsonGetString:rocPayload withName:@"email"];
		
		//================================================
		// Other Fields
		//================================================

		rocData.weatherDataAvailable = [self jsonGetBool:rocPayload withName:@"weatherDataAvailable"];
		
		NSLog(@"ROC - parsed report from server JSON.");

		return rocData;
	}
	@catch (NSException *e)
	{
		NSLog(@"ROC - Unable to parse individual ROC from server. Exception: %@", e);
		return nil;
	}
	@finally
	{
		
	}
	
	return rocData;
}

// Reads a message payload from the server that contains multiple ROCs
// Generates an array of ReportOnConditionData objects
+ (NSMutableArray<ReportOnConditionData> *) multipleFromServerPayload:(NSDictionary *)payload
{
	@try
	{
		NSMutableArray<ReportOnConditionData> *rocData = [NSMutableArray<ReportOnConditionData> new];
		
		int count = [ReportOnConditionData jsonGetInt:payload withName:@"count"];
		
		NSMutableArray *payloadArray = [ReportOnConditionData jsonGetArray:payload withName:@"reports"];
		
		NSLog(@"About to parse %d ROCs from server. Payload: %@",count,payloadArray);
		
		for(int i = 0; i < count; i++)
		{
			// If we fail to parse one roc, catch inside the loop so we can still try and parse the rest
			@try
			{
				NSMutableDictionary*singleReportDictionary = [payloadArray objectAtIndex:i];
				
				NSLog(@"ROCDB - parsing single ROC from dictionary: %@",singleReportDictionary);
				
				ReportOnConditionData *reportData = [ReportOnConditionData fromServerPayload:singleReportDictionary];
				
				NSLog(@"ROCDB - parsed the following ROC: %@",[reportData toSqlJson]);
				
				[rocData addObject:reportData];
			}
			@catch (NSException *e)
			{
				NSLog(@"ROC - Unable to parse ROC in array from server. Exception %@",e);
			}
			@finally
			{
				
			}
		}
		return rocData;
	}
	@catch (NSException *e)
	{
		NSLog(@"ROC - Unable to parse ROC message from server. Exception: %@", e);
	}
	@finally
	{
		
	}
	
	
	return nil;
}





// Creates a payload from this object that can be sent to the server to submit an ROC
// NOTE - This is for submitting an ROC WITHOUT creating an incident
// NOTE - Submitting an ROC AND creating an incident is handled by toServerIncidentPayload
- (NSMutableDictionary *) reportToServerPayload:(long) usersessionid
{
	@try
	{
		NSMutableDictionary *payload = [NSMutableDictionary new];
		NSMutableDictionary *messagePayload = [NSMutableDictionary new];
		NSMutableDictionary *rocPayload = [NSMutableDictionary new];
		
		//================================================
		// Form metadata fields:
		//================================================
		[ReportOnConditionData jsonSetLong:payload withName:@"incidentid" asLong:_incidentid];
		
		//================================================
		// ROC Form Info Fields
		//================================================
		[ReportOnConditionData jsonSetString:payload withName:@"incidentname" asString:_incidentname];
		[ReportOnConditionData jsonSetString:rocPayload withName:@"reportType" asString:_reportType];
		
		//================================================
		// Incident Info Fields
		//================================================
		
		NSObject *incidentType = [ReportOnConditionData createIncidentTypePayload:self];
		if([incidentType isKindOfClass:[NSDictionary class]])
		{
			[ReportOnConditionData jsonSetDictionary:rocPayload withName:@"incidentTypes" asDictionary:(NSDictionary*)incidentType];
		}
		else if([incidentType isKindOfClass:[NSArray class]])
		{
			[ReportOnConditionData jsonSetArray:rocPayload withName:@"incidentTypes" asArray:(NSArray*)incidentType];
		}
		
		[ReportOnConditionData jsonSetDouble:rocPayload withName:@"latitudeAtROCSubmission" asDouble:_latitude];
		[ReportOnConditionData jsonSetDouble:rocPayload withName:@"longitudeAtROCSubmission" asDouble:_longitude];
		[ReportOnConditionData jsonSetString:rocPayload withName:@"incidentState" asString:_incidentState];
		
		//================================================
		// ROC Incident Info Fields
		//================================================
		[ReportOnConditionData jsonSetString:rocPayload withName:@"county" asString:_county];
		[ReportOnConditionData jsonSetString:rocPayload withName:@"additionalAffectedCounties" asString:_additionalAffectedCounties];
		[ReportOnConditionData jsonSetString:rocPayload withName:@"location" asString:_location];
		
		[ReportOnConditionData jsonSetString:rocPayload withName:@"street" asString:_street];
		[ReportOnConditionData jsonSetString:rocPayload withName:@"crossStreet" asString:_crossStreet];
		[ReportOnConditionData jsonSetString:rocPayload withName:@"nearestCommunity" asString:_nearestCommunity];
		[ReportOnConditionData jsonSetString:rocPayload withName:@"milesFromNearestCommunity" asString:_milesFromNearestCommunity];
		[ReportOnConditionData jsonSetString:rocPayload withName:@"directionFromNearestCommunity" asString:_directionFromNearestCommonity];

		[ReportOnConditionData jsonSetString:rocPayload withName:@"dpa" asString:_dpa];
		// not a bug, the json schema reuses "sra" as ownership field
		[ReportOnConditionData jsonSetString:rocPayload withName:@"sra" asString:_ownership];
		[ReportOnConditionData jsonSetString:rocPayload withName:@"jurisdiction" asString:_jurisdiction];
		
		// Parse the string to  Date object
		NSDateFormatter *reportDateFormatter = [NSDateFormatter new];
		[reportDateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
		
		[ReportOnConditionData jsonSetString:rocPayload withName:@"date" asString:[reportDateFormatter stringFromDate:_startDate]];
		[ReportOnConditionData jsonSetString:rocPayload withName:@"starttime" asString:[reportDateFormatter stringFromDate:_startTime]];
		
		//================================================
		// Vegetation Fire Incident Scope Fields
		//================================================
		[ReportOnConditionData jsonSetString:rocPayload withName:@"scope" asString:_acreage];
		[ReportOnConditionData jsonSetString:rocPayload withName:@"spreadRate" asString:_spreadRate];
		[ReportOnConditionData jsonSetArray:rocPayload withName:@"fuelTypes" asArray:_fuelTypes];
		[ReportOnConditionData jsonSetString:rocPayload withName:@"otherFuelTypes" asString:_otherFuelTypes];
		[ReportOnConditionData jsonSetString:rocPayload withName:@"percentContained" asString:_percentContained];
		
		//================================================
		// Weather Information Fields
		//================================================
		[ReportOnConditionData jsonSetString:rocPayload withName:@"temperature" asString:_temperature];
		[ReportOnConditionData jsonSetString:rocPayload withName:@"relHumidity" asString:_relHumidity];
		[ReportOnConditionData jsonSetString:rocPayload withName:@"windSpeed" asString:_windSpeed];
		[ReportOnConditionData jsonSetString:rocPayload withName:@"windDirection" asString:_windDirection];

		// TODO - Wind Gusts needs to be added to json schema
		//[ReportOnConditionData jsonSetString:rocPayload withName:@"windGusts" asString:_windGusts];

		//================================================
		// Threats & Evacuations Fields
		//================================================
		[ReportOnConditionData jsonSetString:rocPayload withName:@"evacuations" asString:_evacuations];
		NSMutableDictionary *evacuations = [NSMutableDictionary new];
		[ReportOnConditionData jsonSetArray:evacuations withName:@"evacuations" asArray:_evacuationsInProgress];
		[ReportOnConditionData jsonSetDictionary:rocPayload withName:@"evacuationsInProgress" asDictionary:evacuations];

		
		[ReportOnConditionData jsonSetString:rocPayload withName:@"structuresThreat" asString:_structureThreats];
		NSMutableDictionary *structureThreats = [NSMutableDictionary new];
		[ReportOnConditionData jsonSetArray:structureThreats withName:@"structuresThreat" asArray:_structureThreatsInProgress];
		[ReportOnConditionData jsonSetDictionary:rocPayload withName:@"structuresThreatInProgress" asDictionary:structureThreats];

		
		[ReportOnConditionData jsonSetString:rocPayload withName:@"infrastructuresThreat" asString:_infrastructureThreats];
		NSMutableDictionary *infrastructureThreats = [NSMutableDictionary new];
		[ReportOnConditionData jsonSetArray:infrastructureThreats withName:@"infrastructuresThreat" asArray:_infrastructureThreatsInProgress];
		[ReportOnConditionData jsonSetDictionary:rocPayload withName:@"infrastructuresThreatInProgress" asDictionary:infrastructureThreats];
		
		//================================================
		// Resource Commitment Fields
		//================================================
		[ReportOnConditionData jsonSetString:rocPayload withName:@"calfireIncident" asString:_calfireIncident];
		NSMutableDictionary *resourcesAssigned = [NSMutableDictionary new];
		[ReportOnConditionData jsonSetArray:resourcesAssigned withName:@"resourcesAssigned" asArray:_resourcesAssigned];
		[ReportOnConditionData jsonSetDictionary:rocPayload withName:@"resourcesAssigned" asDictionary:resourcesAssigned];
		
		//================================================
		// Other Significant Info Fields
		//================================================
		// Field not used by UI
		//[ReportOnConditionData jsonSetString:rocPayload withName:@"otherThreatsAndEvacuations" asString:_otherThreatsAndEvacs];
		NSMutableDictionary *otherInfo = [NSMutableDictionary new];
		[ReportOnConditionData jsonSetArray:otherInfo withName:@"otherThreatsAndEvacuations" asArray:_otherThreatsAndEvacuationsInProgress];
		[ReportOnConditionData jsonSetDictionary:rocPayload withName:@"otherThreatsAndEvacuationsInProgress" asDictionary:otherInfo];
		
		//================================================
		// Email Fields
		//================================================
		[ReportOnConditionData jsonSetString:rocPayload withName:@"email" asString:_email];
		
		//================================================
		// Other Fields
		//================================================
		[ReportOnConditionData jsonSetBool:rocPayload withName:@"weatherDataAvailable" asBool:_weatherDataAvailable];
		[ReportOnConditionData jsonSetBool:rocPayload withName:@"simplifiedEmail" asBool:true];
		[ReportOnConditionData jsonSetString:rocPayload withName:@"reportBy" asString:_email];
		[ReportOnConditionData jsonSetString:rocPayload withName:@"comments" asString:@""];
		[ReportOnConditionData jsonSetString:rocPayload withName:@"rocDisplayName" asString:@""];
		
		//--------------------------------------------
		// Building the final payload:
		//--------------------------------------------
		[ReportOnConditionData jsonSetDictionary:messagePayload withName:@"report" asDictionary:rocPayload];
		
		NSDateFormatter *payloadDateFormatter = [NSDateFormatter new];
		[payloadDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
		[ReportOnConditionData jsonSetString:messagePayload withName:@"datecreated" asString:[payloadDateFormatter stringFromDate:_datecreated]];
		[ReportOnConditionData jsonSetInt:messagePayload withName:@"seqtime" asInt:(int) [_datecreated timeIntervalSince1970]];

		// TODO - Should this be set?
		// [ReportOnConditionData jsonSetInt:payload withName:@"workspaceid" asInt:1];
		
		// FIXME - formtypeid must be 1 for the ROC to show up in the webapp
		// Documentation says ROC formtypeid should be 7, but I think the webapp / emapi are programmed to use 1
		[ReportOnConditionData jsonSetInt:payload withName:@"formtypeid" asInt:1];
		[ReportOnConditionData jsonSetLong:payload withName:@"usersessionid" asLong:usersessionid];
		[ReportOnConditionData jsonSetBool:payload withName:@"distributed" asBool:false];
		
		// Placing the message as a JSON string into the payload:
		NSString *msgString = [ReportOnConditionData jsonDictionaryToJsonString:messagePayload];
		[ReportOnConditionData jsonSetString:payload withName:@"message" asString:msgString];
		
		
		return payload;
	}
	@catch (NSException *e)
	{
		NSLog(@"ROC - Unable to create server payload from ROC data object. Exception: %@",e);
	}
	@finally
	{
		
	}
	
	return nil;
}


// Creates a payload from this object that can be sent to the server to submit an ROC
// NOTE - This is for submitting an ROC AND creating an incident
- (NSMutableDictionary *) reportToServerIncidentPayload:(long) usersessionid
{
	@try
	{
		NSMutableDictionary *payload = [self reportToServerPayload:usersessionid];
		
		// Creating the incident payload:
		NSMutableDictionary *incidentPayload = [NSMutableDictionary new];
		[ReportOnConditionData jsonSetLong:incidentPayload withName:@"usersessionid" asLong:usersessionid];
		
		// TODO - is hardcoding the value of 1 for workspace id okay?
		[ReportOnConditionData jsonSetInt:incidentPayload withName:@"workspaceid" asInt:1];
		// TODO - if it should be set to nil, is it needed?
		//[ReportOnConditionData jsonSetDictionary:incidentPayload withName:@"usersession" asDictionary:nil];
		[ReportOnConditionData jsonSetString:incidentPayload withName:@"incidentname" asString:_incidentname];
		[ReportOnConditionData jsonSetDouble:incidentPayload withName:@"lat" asDouble:_latitude];
		[ReportOnConditionData jsonSetDouble:incidentPayload withName:@"lon" asDouble:_longitude];
		[ReportOnConditionData jsonSetString:incidentPayload withName:@"incidentnumber" asString:_incidentnumber];
		
		[ReportOnConditionData jsonSetBool:incidentPayload withName:@"active" asBool:true];
		[ReportOnConditionData jsonSetString:incidentPayload withName:@"folder" asString:@""];
		[ReportOnConditionData jsonSetString:incidentPayload withName:@"description" asString:@""];
		// TODO - if it should be set to nil, is it needed?
		//[ReportOnConditionData jsonSetDictionary:incidentPayload withName:@"bounds" asDictionary:nil];
		
		// Adding the incident types array:
		NSMutableArray *incidentTypesArray = [NSMutableArray new];
		
		
		for(NSString *incidentType in _incidentTypes)
		{
			if(incidentType == nil)
				continue;
			
			// Setting "incidenttypeid" as the this incident type's id
			int incidentTypeId = [ReportOnConditionData incidentTypeStringToId:incidentType];
			
			// Don't add invalid incident types
			if(incidentTypeId == -1)
				continue;
			
			NSMutableDictionary *incidentTypeObj = [NSMutableDictionary new];
			[ReportOnConditionData jsonSetInt:incidentTypeObj withName:@"incidenttypeid" asInt:incidentTypeId];
			[incidentTypesArray addObject:incidentTypeObj];
		}
		
		[ReportOnConditionData jsonSetArray:incidentPayload withName:@"incidentIncidenttypes" asArray:incidentTypesArray];
		
		
		// Adding the incident payload to the entire payload
		[ReportOnConditionData jsonSetDictionary:payload withName:@"incident" asDictionary:incidentPayload];
		return payload;
	}
	@catch (NSException *e)
	{
		NSLog(@"ROC - Unable to create server incident payload from ROC data object. Exception: %@",e);
	}
	@finally
	{
		
	}
	
	return nil;
}


// Creates a payload that can be sent to the server
// If this ROC is for a new incident, the incident data must be sent to the server as well,
// 		to do so, this calls reportToServerIncidentPayload
// If this ROC is for an existing incident, only the ROC is sent to the server,
//		to do so, this calls reportToServerPayload
- (NSMutableDictionary *) toServerPayload:(long) usersessionid
{
	if(_isForNewIncident)
	{
		return [self reportToServerIncidentPayload:usersessionid];
	}
	else
	{
		return [self reportToServerPayload:usersessionid];
	}
}


// Converts this ReportOnConditionData into a json string to be stored in the sql db
- (NSString *) toSqlJson
{
	// Building an NSMutableDictionary to serialize:
	NSMutableDictionary *dict = [NSMutableDictionary new];
	
	// Building an NSDateFormatter to reuse to serialize dates
	NSDateFormatter *dateFormatter = [NSDateFormatter new];
	[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
	
	// Metadata
	[ReportOnConditionData jsonSetBool:dict withName:@"isForNewIncident" asBool:_isForNewIncident];

	// Actual ROC data
	[ReportOnConditionData jsonSetLong:dict withName:@"incidentid" asLong:_incidentid];
	[ReportOnConditionData jsonSetString:dict withName:@"incidentname" asString:_incidentname];
	[ReportOnConditionData jsonSetString:dict withName:@"incidentnumber" asString:_incidentnumber];
	[ReportOnConditionData jsonSetString:dict withName:@"datecreated" asString:[dateFormatter stringFromDate:_datecreated]];
	
	[ReportOnConditionData jsonSetString:dict withName:@"reportType" asString:_reportType];
	[ReportOnConditionData jsonSetString:dict withName:@"county" asString:_county];
	[ReportOnConditionData jsonSetString:dict withName:@"additionalAffectedCounties" asString:_additionalAffectedCounties];
	[ReportOnConditionData jsonSetString:dict withName:@"startDate" asString:[dateFormatter stringFromDate:_startDate]];
	[ReportOnConditionData jsonSetString:dict withName:@"startTime" asString:[dateFormatter stringFromDate:_startTime]];
	[ReportOnConditionData jsonSetString:dict withName:@"location" asString:_location];
	[ReportOnConditionData jsonSetString:dict withName:@"street" asString:_street];
	[ReportOnConditionData jsonSetString:dict withName:@"crossStreet" asString:_crossStreet];
	[ReportOnConditionData jsonSetString:dict withName:@"nearestCommunity" asString:_nearestCommunity];
	[ReportOnConditionData jsonSetString:dict withName:@"milesFromNearestCommunity" asString:_milesFromNearestCommunity];
	[ReportOnConditionData jsonSetString:dict withName:@"directionFromNearestCommunity" asString:_directionFromNearestCommonity];
	[ReportOnConditionData jsonSetString:dict withName:@"dpa" asString:_dpa];
	[ReportOnConditionData jsonSetString:dict withName:@"ownership" asString:_ownership];
	[ReportOnConditionData jsonSetString:dict withName:@"jurisdiction" asString:_jurisdiction];
	[ReportOnConditionData jsonSetArray:dict withName:@"incidentTypes" asArray:_incidentTypes];
	[ReportOnConditionData jsonSetString:dict withName:@"incidentState" asString:_incidentState];
	[ReportOnConditionData jsonSetString:dict withName:@"acreage" asString:_acreage];
	[ReportOnConditionData jsonSetString:dict withName:@"spreadRate" asString:_spreadRate];
	[ReportOnConditionData jsonSetArray:dict withName:@"fuelTypes" asArray:_fuelTypes];
	[ReportOnConditionData jsonSetString:dict withName:@"otherFuelTypes" asString:_otherFuelTypes];
	[ReportOnConditionData jsonSetString:dict withName:@"percentContained" asString:_percentContained];
	[ReportOnConditionData jsonSetString:dict withName:@"temperature" asString:_temperature];
	[ReportOnConditionData jsonSetString:dict withName:@"relHumidity" asString:_relHumidity];
	[ReportOnConditionData jsonSetString:dict withName:@"windSpeed" asString:_windSpeed];
	[ReportOnConditionData jsonSetString:dict withName:@"windDirection" asString:_windDirection];
	[ReportOnConditionData jsonSetString:dict withName:@"windGusts" asString:_windGusts];
	[ReportOnConditionData jsonSetString:dict withName:@"evacuations" asString:_evacuations];
	[ReportOnConditionData jsonSetArray:dict withName:@"evacuationsInProgress" asArray:_evacuationsInProgress];
	[ReportOnConditionData jsonSetString:dict withName:@"structureThreats" asString:_structureThreats];
	[ReportOnConditionData jsonSetArray:dict withName:@"structureThreatsInProgress" asArray:_structureThreatsInProgress];
	[ReportOnConditionData jsonSetString:dict withName:@"infrastructureThreats" asString:_infrastructureThreats];
	[ReportOnConditionData jsonSetArray:dict withName:@"infrastructureThreatsInProgress" asArray:_infrastructureThreatsInProgress];
	[ReportOnConditionData jsonSetString:dict withName:@"otherThreatsAndEvacuations" asString:_otherThreatsAndEvacuations];
	[ReportOnConditionData jsonSetArray:dict withName:@"otherThreatsAndEvacuationsInProgress" asArray:_otherThreatsAndEvacuationsInProgress];
	[ReportOnConditionData jsonSetString:dict withName:@"calfireIncident" asString:_calfireIncident];
	[ReportOnConditionData jsonSetArray:dict withName:@"resourcesAssigned" asArray:_resourcesAssigned];
	[ReportOnConditionData jsonSetString:dict withName:@"email" asString:_email];
	[ReportOnConditionData jsonSetDouble:dict withName:@"latitude" asDouble:_latitude];
	[ReportOnConditionData jsonSetDouble:dict withName:@"longitude" asDouble:_longitude];
	[ReportOnConditionData jsonSetBool:dict withName:@"weatherDataAvailable" asBool:_weatherDataAvailable];
	
	// Convert it to a json string and return it
	return [ReportOnConditionData jsonDictionaryToJsonString:dict];
}

// Restores a ReportOnConditionData object from a json String stored in the sql db
+ (ReportOnConditionData*) fromSqlJson:(NSString*)jsonString
{
	// Assuming we've got a valid json string, convert it to an NSMutableDictionary
	NSMutableDictionary *dict = [ReportOnConditionData jsonDictionaryFromJsonString:jsonString];
	
	// Building an NSDateFormatter to reuse to deserialize dates
	NSDateFormatter *dateFormatter = [NSDateFormatter new];
	[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
	
	// Create the new ReportOnConditionData and build it from the Dictionary
	ReportOnConditionData *rocData = [ReportOnConditionData new];
	
	// Metadata
	rocData.isForNewIncident = [ReportOnConditionData jsonGetBool:dict withName:@"isForNewIncident" defaultTo:false];
	
	// Actual ROC data
	rocData.incidentid = [ReportOnConditionData jsonGetLong:dict withName:@"incidentid" defaultTo:-1];
	rocData.incidentname = [ReportOnConditionData jsonGetString:dict withName:@"incidentname" defaultTo:@""];
	rocData.incidentnumber = [ReportOnConditionData jsonGetString:dict withName:@"incidentnumber" defaultTo:@""];
	rocData.datecreated = [dateFormatter dateFromString:[ReportOnConditionData jsonGetString:dict withName:@"datecreated" defaultTo:@"1970-01-01T01:23:45.678Z"]];
	rocData.reportType = [ReportOnConditionData jsonGetString:dict withName:@"reportType" defaultTo:@""];
	rocData.county = [ReportOnConditionData jsonGetString:dict withName:@"county" defaultTo:@""];
	rocData.additionalAffectedCounties = [ReportOnConditionData jsonGetString:dict withName:@"additionalAffectedCounties" defaultTo:@""];
	rocData.startDate = [dateFormatter dateFromString:[ReportOnConditionData jsonGetString:dict withName:@"startDate" defaultTo:@"1970-01-01T01:23:45.678Z"]];
	rocData.startTime =  [dateFormatter dateFromString:[ReportOnConditionData jsonGetString:dict withName:@"startTime" defaultTo:@"1970-01-01T01:23:45.678Z"]];
	rocData.location = [ReportOnConditionData jsonGetString:dict withName:@"location" defaultTo:@""];
	rocData.street = [ReportOnConditionData jsonGetString:dict withName:@"street" defaultTo:@""];
	rocData.crossStreet = [ReportOnConditionData jsonGetString:dict withName:@"crossStreet" defaultTo:@""];
	rocData.nearestCommunity = [ReportOnConditionData jsonGetString:dict withName:@"nearestCommunity" defaultTo:@""];
	rocData.milesFromNearestCommunity = [ReportOnConditionData jsonGetString:dict withName:@"milesFromNearestCommunity" defaultTo:@""];
	rocData.directionFromNearestCommonity = [ReportOnConditionData jsonGetString:dict withName:@"directionFromNearestCommunity" defaultTo:@""];
	rocData.dpa = [ReportOnConditionData jsonGetString:dict withName:@"dpa" defaultTo:@""];
	rocData.ownership = [ReportOnConditionData jsonGetString:dict withName:@"ownership" defaultTo:@""];
	rocData.jurisdiction = [ReportOnConditionData jsonGetString:dict withName:@"jurisdiction" defaultTo:@""];
	rocData.incidentTypes = [ReportOnConditionData jsonGetArray:dict withName:@"incidentTypes" defaultTo:[NSMutableArray<NSString*> new]];
	rocData.incidentState = [ReportOnConditionData jsonGetString:dict withName:@"incidentState" defaultTo:@""];
	rocData.acreage = [ReportOnConditionData jsonGetString:dict withName:@"acreage" defaultTo:@""];
	rocData.spreadRate = [ReportOnConditionData jsonGetString:dict withName:@"spreadRate" defaultTo:@""];
	rocData.fuelTypes = [ReportOnConditionData jsonGetArray:dict withName:@"fuelTypes" defaultTo:[NSMutableArray<NSString*> new]];
	rocData.otherFuelTypes = [ReportOnConditionData jsonGetString:dict withName:@"otherFuelTypes" defaultTo:@""];
	rocData.percentContained = [ReportOnConditionData jsonGetString:dict withName:@"percentContained" defaultTo:@""];
	rocData.temperature = [ReportOnConditionData jsonGetString:dict withName:@"temperature" defaultTo:@""];
	rocData.relHumidity = [ReportOnConditionData jsonGetString:dict withName:@"relHumidity" defaultTo:@""];
	rocData.windSpeed = [ReportOnConditionData jsonGetString:dict withName:@"windSpeed" defaultTo:@""];
	rocData.windDirection = [ReportOnConditionData jsonGetString:dict withName:@"windDirection" defaultTo:@""];
	rocData.windGusts = [ReportOnConditionData jsonGetString:dict withName:@"windGusts" defaultTo:@""];
	rocData.evacuations = [ReportOnConditionData jsonGetString:dict withName:@"evacuations" defaultTo:@""];
	rocData.evacuationsInProgress = [ReportOnConditionData jsonGetArray:dict withName:@"evacuationsInProgress" defaultTo:[NSMutableArray<NSString*> new]];
	rocData.structureThreats = [ReportOnConditionData jsonGetString:dict withName:@"structureThreats" defaultTo:@""];
	rocData.structureThreatsInProgress = [ReportOnConditionData jsonGetArray:dict withName:@"structureThreatsInProgress" defaultTo:[NSMutableArray<NSString*> new]];
	rocData.infrastructureThreats = [ReportOnConditionData jsonGetString:dict withName:@"infrastructureThreats" defaultTo:@""];
	rocData.infrastructureThreatsInProgress = [ReportOnConditionData jsonGetArray:dict withName:@"infrastructureThreatsInProgress" defaultTo:[NSMutableArray<NSString*> new]];
	rocData.otherThreatsAndEvacuations = [ReportOnConditionData jsonGetString:dict withName:@"otherThreatsAndEvacuations" defaultTo:@""];
	rocData.otherThreatsAndEvacuationsInProgress = [ReportOnConditionData jsonGetArray:dict withName:@"otherThreatsAndEvacuationsInProgress" defaultTo:[NSMutableArray<NSString*> new]];
	rocData.calfireIncident = [ReportOnConditionData jsonGetString:dict withName:@"calfireIncident" defaultTo:@""];
	rocData.resourcesAssigned = [ReportOnConditionData jsonGetArray:dict withName:@"resourcesAssigned" defaultTo:[NSMutableArray<NSString*> new]];
	rocData.email = [ReportOnConditionData jsonGetString:dict withName:@"email" defaultTo:@""];
	rocData.latitude = [ReportOnConditionData jsonGetDouble:dict withName:@"latitude" defaultTo:0];
	rocData.longitude = [ReportOnConditionData jsonGetDouble:dict withName:@"longitude" defaultTo:0];
	rocData.weatherDataAvailable = [ReportOnConditionData jsonGetBool:dict withName:@"weatherDataAvailable" defaultTo:false];

	return rocData;
}


// Turns the object into the schema that will be stored in the local SQlite db
// Columns:
// sendStatus - int
// incidentID - int
// incidentName - String
// createdUTC - int
// json - String
- (NSDictionary *) toSqlMapping
{
	// Build the database entry:
	NSMutableDictionary *dbEntry = [NSMutableDictionary new];
	
	// send status
	[dbEntry setObject:[NSNumber numberWithInt:_sendStatus] forKey:@"status"];
	// incident id
	[dbEntry setObject:[NSNumber numberWithLong:_incidentid] forKey:@"incidentID"];
	// incident name
	[dbEntry setObject:_incidentname forKey:@"incidentName"];
	// date created (seconds from 1/1/1970)
	[dbEntry setObject:[NSNumber numberWithLong:[_datecreated timeIntervalSince1970]] forKey:@"createdUTC"];
	// the ReportOnConditionData as a json string
	[dbEntry setObject:[self toSqlJson] forKey:@"json"];
	
	return dbEntry;
}

// Creates a ReportOnConditionData object from a sql mapping
// Columns:
// sendStatus - int
// incidentID - int
// incidentName - String
// createdUTC - int
// json - String
+ (ReportOnConditionData *) fromSqlMapping:(NSDictionary*)data
{
	// Retrieving the json:
	NSString *jsonString = data[@"json"];
	
	NSLog(@"ROC - about to parse ROC from sql mapping: %@",jsonString);
	
	// Building the object again
	ReportOnConditionData *rocData = [ReportOnConditionData fromSqlJson:jsonString];
	
	// If we failed to get the rocData, return nil
	if(rocData == nil)
		return nil;
	
	// Updating the value for send status
	NSNumber *sendStatus = data[@"status"];
	rocData.sendStatus = [sendStatus intValue];
	
	return rocData;
}


//------------------------------------------------------
// ROC JSON Helper Methods
// These methods contain conversions to and from json
// that are ROC-specific
//------------------------------------------------------

// Converts incident type id to string
+ (NSString*) incidentTypeIdToString:(int)incidentType
{
	switch(incidentType)
	{
		case 1:
			return @"Fire (Wildland)";
		case 2:
			return @"Mass Casualty";
		case 3:
			return @"Search and Rescue";
		case 4:
			return @"Terrorist Threat / Attack";
		case 5:
			return @"Fire (Structure)";
		case 6:
			return @"Hazardous Materials";
		case 7:
			return @"Blizzard";
		case 8:
			return @"Hurricane";
		case 9:
			return @"Earthquake";
		case 10:
			return @"Nuclear Accident";
		case 11:
			return @"Oil Spill";
		case 12:
			return @"Planned Event";
		case 13:
			return @"Public Health / Medical Emergency";
		case 14:
			return @"Tornado";
		case 15:
			return @"Tropical Storm";
		case 16:
			return @"Tsunami";
		case 17:
			return @"Aircraft Accident";
		case 18:
			return @"Civil Unrest";
		case 19:
			return @"Flood";
		// TODO - Add once we add Vegetation Fire incident type.
		/*			case 20:
			return @"Vegetation Fire";*/
		default:
			return nil;
	}
}

// Converts incident type string to id
+ (int) incidentTypeStringToId:(NSString*)incidentType
{
	// Iterate through all IDs until we find one that matches
	for(int i = 0; i < 22; i++)
	{
		NSString *val = [ReportOnConditionData incidentTypeIdToString:i];
		
		if(val == nil)
		{
			continue;
		}
		
		if([val isEqualToString:incidentType])
		{
			return i;
		}
	}
	return -1;
}


// Parses the incidentTypes field from a ROC server payload,
// converts the ids to strings and returns an array of human-readable strings
// This method handles the following logic (the format the data is sent by the
// server depends on the number of incident types)
//
// If there are no incident types, returns an empty NSMutableArray
//
// empty:
//"incidentTypes": []
//
// one:
// "incidentTypes": { "incidenttype": 12 }
//
// multiple:
// "incidentTypes": { "incidenttype": [17,7,18,9,5,1] }
//
// Not sure why the server payload varies so much, but we have to deal with it
+ (NSMutableArray<NSString*>*) getIncidentTypesArrayFromJson:(NSDictionary*)dict;
{
	NSMutableArray<NSString*> *array = [NSMutableArray<NSString*> new];
	
	if(dict == nil)
		return array;
	
	// TODO - handle the above logic.
	NSString *fieldName = @"incidenttype";
	
	
	NSLog(@"ROC - Reading string: %@",fieldName);
	NSLog(@"ROC - Get string returns: %@",[ReportOnConditionData jsonGetString:dict withName:fieldName]);
	NSLog(@"ROC - Get array returns: %@",[ReportOnConditionData jsonGetArray:dict withName:fieldName]);
	
	// Try reading it as an array:
	NSMutableArray *jsonArray = [ReportOnConditionData jsonGetArray:dict withName:fieldName];
	// Try reading it as an int:
	int numberValue = [ReportOnConditionData jsonGetInt:dict withName:fieldName defaultTo:-1];
	
	
	// If it was an array
	if(jsonArray != nil)
	{
		int itemCount = (int) [jsonArray count];
		
		for(int i = 0; i < itemCount; i++)
		{
			NSObject *obj = [jsonArray objectAtIndex:i];
			
			if([obj isKindOfClass:[NSNumber class]])
			{
				NSNumber *num = (NSNumber*)obj;
				
				// Convert the integer to the incident type string
				NSString *incidentType = [ReportOnConditionData incidentTypeIdToString:[num intValue]];
				
				// Sanitize the input, make sure we only have valid incident types
				if(incidentType != nil)
				{
					[array addObject:incidentType];
				}
			}
			
			[array addObject:[jsonArray objectAtIndex:i]];
		}
	}
	// If it was an int:
	else if(numberValue != -1)
	{
		// If it was an int, get the Incident Type string for that int
		NSString *incidentType = [ReportOnConditionData incidentTypeIdToString:numberValue];
		
		// Sanitize the input, make sure we only have valid incident types
		if(incidentType != nil)
		{
			[array addObject:incidentType];
		}
	}
	
	return array;
}



// Creates the incident types payload as required by the server
//
// empty:
//"incidentTypes": []
//
// one:
// "incidentTypes": { "incidenttype": 12 }
//
// multiple:
// "incidentTypes": { "incidenttype": [17,7,18,9,5,1] }
//
+ (NSObject*) createIncidentTypePayload:(ReportOnConditionData*)data
{
	
	// If one element, return an object with that value
	if(data.incidentTypes != nil && [data.incidentTypes count] == 1)
	{
		// Get the id associated with that value
		NSString *incidentTypeString = [data.incidentTypes objectAtIndex:0];
		int incidentTypeId = [ReportOnConditionData incidentTypeStringToId:incidentTypeString];
		
		// If it was a valid id, add it:
		if(incidentTypeId != -1)
		{
			NSMutableDictionary *dict = [NSMutableDictionary new];
			[ReportOnConditionData jsonSetInt:dict withName:@"incidenttype" asInt:incidentTypeId];
			return dict;
		}
	}
	// If there is more than one element, return an object containing an array of values
	else if(data.incidentTypes != nil && [data.incidentTypes count] > 1)
	{
		// Create the array where we will store the int values
		NSMutableArray<NSNumber*> * array = [NSMutableArray<NSNumber*> new];
		
		// Iterate through all strings
		for(NSString* incidentTypeString in data.incidentTypes)
		{
			// Get the id for this string
			int incidentTypeId = [ReportOnConditionData incidentTypeStringToId:incidentTypeString];
			
			// If it is a valid id, add it:
			if(incidentTypeId != -1)
			{
				[array addObject:[NSNumber numberWithInt:incidentTypeId]];
			}
		}
		
		// If we added more than one valid incident type
		if([array count] > 0)
		{
			// Set this array as the value of the object
			NSMutableDictionary *dict = [NSMutableDictionary new];
			[ReportOnConditionData jsonSetArray:dict withName:@"incidenttype" asArray:array];
			return dict;
		}
	}
	
	// If we got here, there were no valid incident types, so return an empty array
	return [NSMutableArray new];
}



// Parses array located at obj[str] and returns the NSMutableArray* populated with the values
// Returns null if the array is not found in the object, otherwise, always returns an array
// NOTE - Due to peculiarities with the server:
// If the array is empty, the array value will be null
// If the array has one value, the array value will be the single string
// If the array has more than one value, the array value will be a JSON array containing strings
+ (NSMutableArray<NSString*>*) parseStringArrayFromJson:(NSDictionary*)dict withName:(NSString*)name
{
	if(dict == nil)
		return nil;
	
	NSMutableArray<NSString*> *array = [NSMutableArray<NSString*> new];
	
	NSLog(@"ROC - Reading string: %@",name);
	NSLog(@"ROC - Get string returns: %@",[ReportOnConditionData jsonGetString:dict withName:name]);
	NSLog(@"ROC - Get array returns: %@",[ReportOnConditionData jsonGetArray:dict withName:name]);

	// Try reading an array first:
	if([ReportOnConditionData jsonGetArray:dict withName:name] != nil)
	{
		NSMutableArray *jsonArray = [ReportOnConditionData jsonGetArray:dict withName:name];
		
		int itemCount = (int) [jsonArray count];
		
		for(int i = 0; i < itemCount; i++)
		{
			[array addObject:[jsonArray objectAtIndex:i]];
		}
	}
	// The object was not an array, check if it's a string
	else if([ReportOnConditionData jsonGetString:dict withName:name] != nil)
	{
		// If it was a string, add that one string to the list
		[array addObject:[ReportOnConditionData jsonGetString:dict withName:name]];
	}
	// The object was neither a string, nor an array, return nil
	else
	{
		array = nil;
	}
	
	return array;
}



//------------------------------------------------------
// JSON NSDictionary helper methods
// These methods should be used instead of the default
// NSDictionary methods, they provide better default behavior
//------------------------------------------------------

// Returns the NSDictionary "name" in dict
// Returns defaultValue if not found, or the dict[name] is not an NSDictionary
+ (NSMutableDictionary*) jsonGetDictionary:(NSDictionary*)dict withName:(NSString*)name defaultTo:(NSMutableDictionary*)defaultValue
{
	if(dict == nil || name == nil)
		return defaultValue;
	
	id obj = dict[name];
	
	if(obj != nil && [obj isKindOfClass:[NSDictionary class]])
	{
		// We now know it's an NSDictionary
		// If it is not an NSMutableDictionary, make a mutable copy of it
		if(![obj isKindOfClass:[NSMutableDictionary class]])
		{
			NSDictionary *dictionary = obj;
			obj = [dictionary mutableCopy];
		}
		return (NSMutableDictionary*)obj;
	}
	
	return defaultValue;
}


// Returns the NSString "name" in dict
// Returns defaultValue if not found, or the dict[name] is not an NSString
+ (NSString*) jsonGetString:(NSDictionary*) dict withName:(NSString*)name defaultTo:(NSString*)defaultValue
{
	if(dict == nil || name == nil)
		return defaultValue;
	
	id obj = dict[name];
	
	if(obj != nil && [obj isKindOfClass:[NSString class]])
	{
		return (NSString*)obj;
	}
	
	return defaultValue;
}

// Returns the double "name" in dict
// Returns defaultValue if not found
+ (double) jsonGetDouble:(NSDictionary*) dict withName:(NSString*)name defaultTo:(double)defaultValue
{
	if(dict == nil || name == nil)
		return defaultValue;
	
	id obj = dict[name];
	
	if(obj != nil && [obj isKindOfClass:[NSNumber class]])
	{
		return (double) [obj doubleValue];
	}
	
	return defaultValue;
}
// Returns the int "name" in dict
// if the number is not an int, it will truncate
// Returns defaultValue if not found
+ (int) jsonGetInt:(NSDictionary*) dict withName:(NSString*)name defaultTo:(int)defaultValue
{
	if(dict == nil || name == nil)
		return defaultValue;
	
	id obj = dict[name];
	
	if(obj != nil && [obj isKindOfClass:[NSNumber class]])
	{
		return (int) [obj intValue];
	}
	
	return defaultValue;
}

// Returns the long "name" in dict
// if the number is not a long, it will truncate
// Returns defaultValue if not found
+ (long) jsonGetLong:(NSDictionary*) dict withName:(NSString*)name defaultTo:(long)defaultValue
{
	if(dict == nil || name == nil)
		return defaultValue;
	
	id obj = dict[name];
	
	if(obj != nil && [obj isKindOfClass:[NSNumber class]])
	{
		return (long) [obj longValue];
	}
	
	return defaultValue;
}

// Returns the NSArray "name" in dict
// Returns defaultValue if not found, or the dict[name] is not an NSArray
+ (NSMutableArray*) jsonGetArray:(NSDictionary*) dict withName:(NSString*)name defaultTo:(NSMutableArray*)defaultValue
{
	if(dict == nil || name == nil)
		return defaultValue;
	
	id obj = dict[name];
	
	if(obj != nil && [obj isKindOfClass:[NSArray class]])
	{
		// We now know it's an NSArray
		// If it is not an NSMutableArray, make a mutable copy of it
		if(![obj isKindOfClass:[NSMutableArray class]])
		{
			NSArray *array = obj;
			obj = [array mutableCopy];
		}
		return (NSMutableArray*)obj;
	}
	
	return defaultValue;
}

// Returns the bool "name" in dict
// Returns defaultValue if not found, or the dict[name] is not a bool
+ (bool) jsonGetBool:(NSDictionary*) dict withName:(NSString*)name defaultTo:(bool)defaultValue
{
	if(dict == nil || name == nil)
		return defaultValue;
	
	id obj = dict[name];
	
	if(obj != nil && [obj isKindOfClass:[NSNumber class]])
	{
		return (bool) [obj intValue];
	}
	return defaultValue;
}

// Returns a NSDictionary by converting the json String "name" in dict to an NSDictionary
// Returns defaultValue if not found, or dict[name] could not be converted to an NSDictionary
+ (NSMutableDictionary*) jsonGetDictionaryFromJsonString:(NSDictionary*)dict withName:(NSString*)name defaultTo:(NSMutableDictionary*)defaultValue
{
	if(dict == nil || name == nil)
		return defaultValue;
	
	// Getting the String from the dictionary
	NSString *jsonString = [ReportOnConditionData jsonGetString:dict withName:name];
	
	if(jsonString == nil)
	{
		return defaultValue;
	}

	NSMutableDictionary *dictionary = [ReportOnConditionData jsonDictionaryFromJsonString:jsonString];
	
	if(dictionary == nil)
	{
		return defaultValue;
	}
	
	return dictionary;
}


//------------------------------------------------------
// These methods are the same as above, but allow you to
// specify a value to default to if the desired value isn't found
//------------------------------------------------------

// Returns the NSDictionary "name" in dict
// Returns null if not found, or the dict[name] is not an NSDictionary
+ (NSMutableDictionary*) jsonGetDictionary:(NSDictionary*)dict withName:(NSString*)name
{
	return [ReportOnConditionData jsonGetDictionary:dict withName:name defaultTo:nil];
}

// Returns the NSString "name" in dict
// Returns null if not found, or the dict[name] is not an NSString
+ (NSString*) jsonGetString:(NSDictionary*)dict withName:(NSString*)name
{
	return [ReportOnConditionData jsonGetString:dict withName:name defaultTo:nil];
}

// Returns the double "name" in dict
// Returns 0 if not found, or if dict / name are nil
+ (double) jsonGetDouble:(NSDictionary*)dict withName:(NSString*)name
{
	return [ReportOnConditionData jsonGetDouble:dict withName:name defaultTo:0];
}

// Returns the int "name" in dict
// if the number is not an int, it will truncate
// Returns 0 if not found, or if dict / name are nil
+ (int) jsonGetInt:(NSDictionary*)dict withName:(NSString*)name
{
	return [ReportOnConditionData jsonGetInt:dict withName:name defaultTo:0];
}

// Returns the long "name" in dict
// if the number is not a long, it will truncate
// Returns 0 if not found, or if dict / name are nil
+ (long) jsonGetLong:(NSDictionary*)dict withName:(NSString*)name
{
	return [ReportOnConditionData jsonGetLong:dict withName:name defaultTo:0];
}

// Returns the NSArray "name" in dict
// Returns null if not found, or the dict[name] is not an NSArray
+ (NSArray*) jsonGetArray:(NSDictionary*)dict withName:(NSString*)name
{
	return [ReportOnConditionData jsonGetArray:dict withName:name defaultTo:nil];
}


// Returns the bool "name" in dict
// Returns false if not found, or the dict[name] is not a bool, or if dict / name are nil
+ (bool) jsonGetBool:(NSDictionary*)dict withName:(NSString*)name
{
	return [ReportOnConditionData jsonGetBool:dict withName:name defaultTo:nil];
}


// Returns a NSDictionary by converting the String "name" in dict
// Returns nil if not found, or dict[name] could not be converted to an NSDictionary
+ (NSMutableDictionary*) jsonGetDictionaryFromJsonString:(NSDictionary*)dict withName:(NSString*)name
{
	return [ReportOnConditionData jsonGetDictionaryFromJsonString:dict withName:name defaultTo:nil];
}


//------------------------------------------------------
// Sets the NSDictionary dict's field under "name" as NSDictionary value
+ (void) jsonSetDictionary:(NSMutableDictionary*)dict withName:(NSString*)name asDictionary:(NSDictionary*)value
{
	if(dict == nil || value == nil)
		return;
	
	dict[name] = value;
}

// Sets the NSDictionary dict's field under "name" as NSString value
+ (void) jsonSetString:(NSMutableDictionary*)dict withName:(NSString*)name asString:(NSString*)value
{
	if(dict == nil)
		return;
	dict[name] = value;
}

// Sets the NSDictionary dict's field under "name" as double value
+ (void) jsonSetDouble:(NSMutableDictionary*)dict withName:(NSString*)name asDouble:(double)value
{
	if(dict == nil)
		return;
	dict[name] = [NSNumber numberWithDouble:value];
}

// Sets the NSDictionary dict's field under "name" as int value
+ (void) jsonSetInt:(NSMutableDictionary*)dict withName:(NSString*)name asInt:(int)value
{
	if(dict == nil)
		return;
	dict[name] = [NSNumber numberWithInt:value];
}

// Sets the NSDictionary dict's field under "name" as long value
+ (void) jsonSetLong:(NSMutableDictionary*)dict withName:(NSString*)name asLong:(long)value
{
	if(dict == nil)
		return;
	dict[name] = [NSNumber numberWithLong:value];
}


// Sets the NSDictionary dict's field under "name" as array value
+ (void) jsonSetArray:(NSMutableDictionary*)dict withName:(NSString*)name asArray:(NSArray*)value
{
	if(dict == nil || value == nil)
		return;
	dict[name] = value;
}

// Sets the NSDictionary dict's field under "name" as bool value
+ (void) jsonSetBool:(NSMutableDictionary*)dict withName:(NSString*)name asBool:(bool)value
{
	if(dict == nil)
		return;
	dict[name] = [NSNumber numberWithBool:value];
}

// Sets the NSDictionary dict's field under "name" as the NSDictionary converted to a JSON String
+ (void) jsonSetDictionaryAsJsonString:(NSDictionary*)dict withName:(NSString*)name asDictionary:(NSDictionary*)value
{
	if(dict == nil || value == nil)
		return;
	
	NSString *jsonString = [ReportOnConditionData jsonDictionaryToJsonString:value];

	// Put the string in dict
	[ReportOnConditionData jsonSetString:dict withName:name asString:jsonString];
}
//------------------------------------------------------

// Converts an NSDictionary to a NSString* json String
// Returns nil if it encountered an error
+ (NSString*) jsonDictionaryToJsonString:(NSDictionary*)dict
{
	if(dict == nil)
		return nil;
	
	NSError *error = nil;
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
	
	if(error != nil)
	{
		NSLog(@"ROC - Encountered error converting dictionary to json string. Error: \"%@\"",error);
	}
	
	if(jsonData == nil)
	{
		NSLog(@"ROC - Unable to get NSData from NSDictionary \"%@\"",dict);
		return nil;
	}
	
	// Converting the data to a string
	NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
	
	if(jsonString == nil)
	{
		NSLog(@"ROC - Unable to get NSString from NSData.");
		return nil;
	}
	
	return jsonString;
}

// Safely removes all null values in a json string
// The default JSON parser replaces null values with the string "null"
// Instead, we want null values to be replaced by the empty string ""
+ (NSString*) jsonSafelyRemoveNullValuesFromJsonString:(NSString*)str
{
	NSString *result = nil;

	// Replacing all instances of "null" with empty quotes.
	// JSONSerialization cnoverts null json values to the string "<null>", and we don't want that.
	
	// I will be using the following strategy:
	// Because the payload values may contain json strings themselves...
	// those json-encoded strings may have the value null with escaped characters
	// i.e., the payload string may be:
	// {"status":null}
	// OR the payload string may be:
	// {"message": "{\"status\":null}"
	//
	// To properly replace null while maintainig valid json...
	// I must replace escaped ones first by replacing:
	// \":null
	// WITH:
	// \":\"\"
	result = [str stringByReplacingOccurrencesOfString:@"\\\":null" withString:@"\\\":\\\"\\\""];
	
	// then, I can handle non-escaped ones by replacing:
	// null
	// WITH:
	// ""
	result = [result stringByReplacingOccurrencesOfString:@"null" withString:@"\"\""];
	
	return result;
}

// Converts a NSString* containing a jsonString to a NSMutableDictionary
// Returns nil if it encountered an error
+ (NSMutableDictionary*) jsonDictionaryFromJsonString:(NSString*)str
{
	if(str == nil)
	{
		NSLog(@"ROC - Unable to get NSDictionary from string %@. String not found in dictionary.",str);
		return nil;
	}

	str = [ReportOnConditionData jsonSafelyRemoveNullValuesFromJsonString:str];
	
	// Converting the string to an NSDictionary
	NSData *jsonStringData = [str dataUsingEncoding:NSUTF8StringEncoding];
	NSError *error = nil;
	NSMutableDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:jsonStringData options:0 error:&error];
	
	if(error != nil)
	{
		NSLog(@"ROC - Encountered error converting json string to dictionary. Error: \"%@\"",error);
	}

	
	// Instead of checking the error value, check the return value
	if(dictionary == nil || ![dictionary isKindOfClass:[NSDictionary class]])
	{
		NSLog(@"ROC - Unable to get NSDictionary from json string: \"%@\"",str);
		
		// TODO -  Should I throw an exception?
		//NSException *e = [NSException exceptionWithName:@"InvalidJSONException" reason:@"NSJSONSerialization failed to deserialize the message JSON." userInfo:nil];
		//@throw e;
		return nil;
	}
	
	return dictionary;
}




@end
