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

#import "ReportPayload.h"

@protocol ReportOnConditionData
@end


@interface ReportOnConditionData : NSObject

// This class defines how we hold the Report On Condition (ROC) form data.
// This class is passed around inside the application as a container.
// This class also contains the code for converting the object to a server payload to submit an ROC, as well as the code for translating a server payload back into an object.

// Report metadata
// This is data not sent to the server, but used locally to manage db
@property int sendStatus;
// Whether or not posting this ROC will create a new incident
@property bool isForNewIncident;
// FIXME - Are these needed? - If so, What data type should this be?
//- @property <Optional> transient ReportSendStatus sendStatus = ReportSendStatus.SENT;
//- @property transient boolean isNew = false;
//- @property transient int id;

@property long incidentid;
@property NSString *incidentname;
@property NSString *incidentnumber;
@property NSDate *datecreated;

@property NSString *reportType;
@property NSString *county;
@property NSString *additionalAffectedCounties;
@property NSDate *startDate;
@property NSDate *startTime;
@property NSString *location;

@property NSString *street;
@property NSString *crossStreet;
@property NSString *nearestCommunity;
@property NSString *milesFromNearestCommunity;
@property NSString *directionFromNearestCommonity;

@property NSString *dpa;
@property NSString *ownership;
@property NSString *jurisdiction;
@property NSMutableArray<NSString*> *incidentTypes;
@property NSString *incidentState;
// FIXME - this really should be a number, but webapp allows any text as input, so we are forced to treat this as a NSString *to handle extraneous text
@property NSString *acreage;
@property NSString *spreadRate;
@property NSMutableArray<NSString*> *fuelTypes;
@property NSString *otherFuelTypes;
// FIXME - this really should be a number, but webapp allows any text as input, so we are forced to treat this as a NSString *to handle extraneous text
@property NSString *percentContained;
// FIXME - this really should be a number, but webapp allows any text as input, so we are forced to treat this as a NSString *to handle extraneous text
@property NSString *temperature;
// FIXME - this really should be a number, but webapp allows any text as input, so we are forced to treat this as a NSString *to handle extraneous text
@property NSString *relHumidity;
// FIXME - this really should be a number, but webapp allows any text as input, so we are forced to treat this as a NSString *to handle extraneous text
@property NSString *windSpeed;
// FIXME - this really should be a number, but webapp allows any text as input, so we are forced to treat this as a NSString *to handle extraneous text
@property NSString *windDirection;
// FIXME - this really should be a number, but webapp allows any text as input, so we are forced to treat this as a NSString *to handle extraneous text
@property NSString *windGusts;
@property NSString *evacuations;
@property NSMutableArray<NSString*> *evacuationsInProgress;
@property NSString *structureThreats;
@property NSMutableArray<NSString*> *structureThreatsInProgress;
@property NSString *infrastructureThreats;
@property NSMutableArray<NSString*> *infrastructureThreatsInProgress;
@property NSString *otherThreatsAndEvacuations;
@property NSMutableArray<NSString*> *otherThreatsAndEvacuationsInProgress;
@property NSString *calfireIncident;
@property NSMutableArray<NSString*> *resourcesAssigned;
@property NSString *email;
@property double latitude;
@property double longitude;
@property bool weatherDataAvailable;

// Converts an NSDictionary payload to a ReportOnConditionData instance
// This method is used to parse the response from the server and create the ReportOnConditionData object
+ (ReportOnConditionData *)fromServerPayload:(NSDictionary *) payload;

// Reads a message payload from the server that contains multiple ROCs
// Generates an array of ReportOnConditionData objects
+ (NSMutableArray<ReportOnConditionData> *) multipleFromServerPayload:(NSDictionary *) payload;

// Creates a payload from this object that can be sent to the server to submit an ROC
// NOTE - This is for submitting an ROC WITHOUT creating an incident
// NOTE - Submitting an ROC AND creating an incident is handled by toServerIncidentPayload
- (NSMutableDictionary *) reportToServerPayload:(long) usersessionid;


// Creates a payload from this object that can be sent to the server to submit an ROC
// NOTE - This is for submitting an ROC AND creating an incident
- (NSMutableDictionary *) reportToServerIncidentPayload:(long) usersessionid;


// Creates a payload that can be sent to the server
// If this ROC is for a new incident, the incident data must be sent to the server as well,
// 		to do so, this calls reportToServerIncidentPayload
// If this ROC is for an existing incident, only the ROC is sent to the server,
//		to do so, this calls reportToServerPayload
- (NSMutableDictionary *) toServerPayload:(long) usersessionid;



// Converts this ReportOnConditionData into a json string to be stored in the sql db
// Columns:
// sendStatus - int
// incidentID - int
// incidentName - String
// createdUTC - int
// json - String
- (NSString *) toSqlJson;

// Restores a ReportOnConditionData object from a json String stored in the sql db
// Columns:oh
// sendStatus - int
// incidentID - int
// incidentName - String
// createdUTC - int
// json - String
+ (ReportOnConditionData*) fromSqlJson:(NSString*)jsonString;


// Turns the object into the schema that will be stored in the local SQlite db
- (NSDictionary *) toSqlMapping;

// Creates a ReportOnConditionData object from a sql mapping
+ (ReportOnConditionData *) fromSqlMapping:(NSDictionary*)data;


//------------------------------------------------------
// ROC JSON Helper Methods
// These methods contain conversions to and from json
// that are ROC-specific
//------------------------------------------------------

// Converts incident type id to string
+ (NSString*) incidentTypeIdToString:(int)incidentType;
// Converts incident type string to id
+ (int) incidentTypeStringToId:(NSString*)incidentType;

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
+ (NSObject*) createIncidentTypePayload:(ReportOnConditionData*)data;


// Parses array located at obj[str] and returns the NSMutableArray* populated with the values
// Returns null if the array is not found in the object, otherwise, always returns an array
// NOTE - Due to peculiarities with the server:
// If the array is empty, the array value will be null
// If the array has one value, the array value will be the single string
// If the array has more than one value, the array value will be a JSON array containing strings
+ (NSMutableArray<NSString*>*) parseStringArrayFromJson:(NSDictionary*)dict withName:(NSString*)name;

//------------------------------------------------------

//------------------------------------------------------
// JSON NSDictionary helper methods
// These methods should be used instead of the default
// NSDictionary methods, they provide better default behavior
//------------------------------------------------------
// Returns the NSDictionary "name" in dict
// Returns null if not found, or the dict[name] is not an NSDictionary
+ (NSMutableDictionary*) jsonGetDictionary:(NSDictionary*)dict withName:(NSString*)name;

// Returns the NSString "name" in dict
// Returns null if not found, or the dict[name] is not an NSString
+ (NSString*) jsonGetString:(NSDictionary*)dict withName:(NSString*)name;
   
// Returns the double "name" in dict
// Returns 0 if not found
+ (double) jsonGetDouble:(NSDictionary*)dict withName:(NSString*)name;

// Returns the int "name" in dict
// if the number is not an int, it will truncate
// Returns 0 if not found
+ (int) jsonGetInt:(NSDictionary*)dict withName:(NSString*)name;

// Returns the long "name" in dict
// if the number is not a long, it will truncate
// Returns 0 if not found
+ (long) jsonGetLong:(NSDictionary*)dict withName:(NSString*)name;

// Returns the NSArray "name" in dict
// Returns null if not found, or the dict[name] is not an NSArray
+ (NSMutableArray*) jsonGetArray:(NSDictionary*) dict withName:(NSString*)name;

// Returns the bool "name" in dict
// Returns false if not found, or the dict[name] is not a bool
+ (bool) jsonGetBool:(NSDictionary*)dict withName:(NSString*)name;

// Returns a NSDictionary by converting the json String "name" in dict to an NSDictionary
// Returns nil if not found, or dict[name] could not be converted to an NSDictionary
+ (NSMutableDictionary*) jsonGetDictionaryFromJsonString:(NSDictionary*)dict withName:(NSString*)name;
//------------------------------------------------------
// These methods are the same as above, but allow you to
// specify a value to default to if the desired value isn't found
//------------------------------------------------------
// Returns the NSDictionary "name" in dict
// Returns defaultValue if not found, or the dict[name] is not an NSDictionary
+ (NSMutableDictionary*) jsonGetDictionary:(NSDictionary*)dict withName:(NSString*)name defaultTo:(NSMutableDictionary*)defaultValue;

// Returns the NSString "name" in dict
// Returns defaultValue if not found, or the dict[name] is not an NSString
+ (NSString*) jsonGetString:(NSDictionary*) dict withName:(NSString*)name defaultTo:(NSString*)defaultValue;

// Returns the double "name" in dict
// Returns defaultValue if not found
+ (double) jsonGetDouble:(NSDictionary*) dict withName:(NSString*)name defaultTo:(double)defaultValue;

// Returns the int "name" in dict
// if the number is not an int, it will truncate
// Returns defaultValue if not found
+ (int) jsonGetInt:(NSDictionary*) dict withName:(NSString*)name defaultTo:(int)defaultValue;

// Returns the long "name" in dict
// if the number is not a long, it will truncate
// Returns defaultValue if not found
+ (long) jsonGetLong:(NSDictionary*) dict withName:(NSString*)name defaultTo:(long)defaultValue;

// Returns the NSArray "name" in dict
// Returns defaultValue if not found, or the dict[name] is not an NSArray
+ (NSMutableArray*) jsonGetArray:(NSDictionary*) dict withName:(NSString*)name defaultTo:(NSMutableArray*)defaultValue;

// Returns the bool "name" in dict
// Returns defaultValue if not found, or the dict[name] is not a bool
+ (bool) jsonGetBool:(NSDictionary*) dict withName:(NSString*)name defaultTo:(bool)defaultValue;

// Returns a NSDictionary by converting the json String "name" in dict to an NSDictionary
// Returns defaultValue if not found, or dict[name] could not be converted to an NSDictionary
+ (NSMutableDictionary*) jsonGetDictionaryFromJsonString:(NSDictionary*)dict withName:(NSString*)name defaultTo:(NSMutableDictionary*)defaultValue;
//------------------------------------------------------

//------------------------------------------------------
// Sets the NSDictionary dict's field under "name" as NSDictionary value
+ (void) jsonSetDictionary:(NSDictionary*)dict withName:(NSString*)name asDictionary:(NSDictionary*)value;

// Sets the NSDictionary dict's field under "name" as NSString value
+ (void) jsonSetString:(NSDictionary*)dict withName:(NSString*)name asString:(NSString*)value;

// Sets the NSDictionary dict's field under "name" as double value
+ (void) jsonSetDouble:(NSDictionary*)dict withName:(NSString*)name asDouble:(double)value;

// Sets the NSDictionary dict's field under "name" as int value
+ (void) jsonSetInt:(NSDictionary*)dict withName:(NSString*)name asInt:(int)value;

// Sets the NSDictionary dict's field under "name" as long value
+ (void) jsonSetLong:(NSDictionary*)dict withName:(NSString*)name asLong:(long)value;

// Sets the NSDictionary dict's field under "name" as array value
+ (void) jsonSetArray:(NSDictionary*)dict withName:(NSString*)name asArray:(NSArray*)value;

// Sets the NSDictionary dict's field under "name" as bool valuej
+ (void) jsonSetBool:(NSDictionary*)dict withName:(NSString*)name asBool:(bool)value;

// Sets the NSDictionary dict's field under "name" as the NSDictionary converted to a JSON String
+ (void) jsonSetDictionaryAsJsonString:(NSDictionary*)dict withName:(NSString*)name asDictionary:(NSDictionary*)value;
//------------------------------------------------------

// Converts an NSDictionary to a NSString* json String
// Returns nil if it encountered an error
+ (NSString*) jsonDictionaryToJsonString:(NSDictionary*)dict;
// Converts a NSString* containing a jsonString to a NSMutableDictionary
// Returns nil if it encountered an error
+ (NSMutableDictionary*) jsonDictionaryFromJsonString:(NSString*)str;

// Safely removes all null values in a json string
// The default JSON parser replaces null values with the string "null"
// Instead, we want null values to be replaced by the empty string ""
+ (NSString*) jsonSafelyRemoveNullValuesFromJsonString:(NSString*)str;


@end

