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
/**
 *
 */
//
//  ReportOnConditionViewController.m
//  SCOUT Mobile
//
//  Created by Luis Gutierrez on 2/8/19.
//  Copyright © 2019 MIT Lincoln Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReportOnConditionViewController.h"
#import "IncidentCanvasUIViewController.h"


const int ID_SECTION_INCIDENT_INFO = 0;
const int ID_SECTION_ROC_INFO = 1;
const int ID_SECTION_VEG_FIRE = 2;
const int ID_SECTION_WEATHER_INFO = 3;
const int ID_SECTION_THREATS = 4;
const int ID_SECTION_RESOURCES = 5;
const int ID_SECTION_OTHER_INFO = 6;
const int ID_SECTION_EMAIL = 7;


const int ROC_NONE = 0;
const int ROC_NON_FINAL = 1;


const int ROC_NEW = 2;
const int ROC_UPDATE = 3;
const int ROC_FINAL = 4;


// Whether or not the ROCViewController should view an "ROC"
// true - loads the current incident's latest ROC and displays it
// false - shows the blank form for creating a new ROC
static bool viewingMode;
static ReportOnConditionViewController *instance;

@implementation ReportOnConditionViewController

// Static function to set the viewing mode for ReportOnConditionViewController
// true - loads the current incident's latest ROC and displays it
// false - shows the blank form for creating a new ROC
+ (void) setViewControllerViewingMode:(bool)mode
{
	viewingMode = mode;
}

// sets all of the incident-related fields as read-only
// (except for incident name,
// as this method is called while editing incident name, so interfering with that
// kicks the user out of editing the field, so we don't want to do that)
- (void) makeIncidentFieldsReadOnly
{
	// Don't lock incident name, for reasons stated above
	//[_incidentNameTextField setEnabled:false];
	[_incidentLocateButton setEnabled:false];
	[_incidentLocateButton setHidden:true];
	[_incidentNumberTextField setEnabled:false];
	[_incidentLongitudeDegreesTextField setEnabled:false];
	[_incidentLongitudeMinutesTextField setEnabled:false];
	[_incidentLongitudeMinutesFractionTextField setEnabled:false];
	[_incidentLatitudeDegreesTextField setEnabled:false];
	[_incidentLatitudeMinutesTextField setEnabled:false];
	[_incidentLatitudeMinutesFractionTextField setEnabled:false];
	[_incidentStateField setEnabled:false];
}

// Enters the incident's information into the form and
// sets all of the fields as read-only
- (void) setupFormForIncident:(IncidentPayload*)incident
{
	if(incident == nil)
		return;
	
	//------------------------------------------------------------------------------------------
	// Incident Name
	//------------------------------------------------------------------------------------------
	NSLog(@"ROC - setupFormForIncident - set incident name as \"%@\"",[incident incidentname]);
	[_incidentNameTextField setText:[incident incidentname]];
	
	//------------------------------------------------------------------------------------------
	// Incident Number
	//------------------------------------------------------------------------------------------
	NSLog(@"ROC - setupFormForIncident - incident has number: \"%@\"",incident.incidentnumber);
	if(incident.incidentnumber != nil)
	{
		[_incidentNumberTextField setText:[incident incidentnumber]];
	}
	else
	{
		[_incidentNumberTextField setText:@""];
	}
	
	//------------------------------------------------------------------------------------------
	// Incident Types
	//------------------------------------------------------------------------------------------
	NSMutableArray<NSString*> *incidentTypes = [NSMutableArray<NSString*> new];
	
	for(IncidentTypePayload *incidentType in incident.incidentTypes)
	{
		if(incidentType.incidentTypeName != nil)
		{
			[incidentTypes addObject:incidentType.incidentTypeName];
		}
	}
	[_incidentTypeViewController setSelectedOptions:incidentTypes];
	
	for(NSString *type in incidentTypes)
	{
		NSLog(@"ROC - setupFormForIncident - set incident type \"%@\"",type);
	}

	
	//------------------------------------------------------------------------------------------
	// Incident Location
	//------------------------------------------------------------------------------------------
	double latitude = [[incident lat] doubleValue];
	double longitude = [[incident lon] doubleValue];
	
	// Insert the location we just computed into the UI text fields
	[_incidentLatitudeDegreesTextField setText:[self getDegreeAsString:latitude]];
	[_incidentLatitudeMinutesTextField setText:[self getMinutesIntegerAsString:latitude]];
	[_incidentLatitudeMinutesFractionTextField setText:[self getMinutesFractionAsString:latitude]];
	// NOTE - we multiply the value by -1 because the UI has a hardcoded "-" sign in front of it
	// (all longitudes in california are in the -120 range, and the client doesn't want users to have to manually enter the "-" sign)
	[_incidentLongitudeDegreesTextField setText:[self getDegreeAsString:-1 * longitude]];
	[_incidentLongitudeMinutesTextField setText:[self getMinutesIntegerAsString:longitude]];
	[_incidentLongitudeMinutesFractionTextField setText:[self getMinutesFractionAsString:longitude]];
	
	NSLog(@"ROC - setupFormForIncident - set lat/long as (%@, %@)",[incident lat], [incident lon]);
	
	//------------------------------------------------------------------------------------------
	// Incident State
	//------------------------------------------------------------------------------------------
	// TODO - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// TODO - incident state is not available to incident payload, but it might be embedded in the incident name:
	// TODO - For example: "CA TAB Test incident", the first two characters are "CA"
	// TODO - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// TODO - In the future, this should be added to incident payload,
	// TODO - or removed from the ROC form if it is not required to create an incident
	// TODO - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// Get the first three characters of the string:
	NSString *incidentName = [incident incidentname];
	NSString *incidentNamePrefix = [incidentName substringToIndex:2];

	NSLog(@"ROC - setupFormForIncident - incident prefix is: \"%@\"",incidentNamePrefix);

	if([incidentNamePrefix isEqualToString:@"CA "])
	{
		NSLog(@"ROC - setupFormForIncident - set state as \"CA\"");
		[_incidentStateField setText:@"CA"];
	}

}


// Called when the incident name field is changed
// This method is responsible for determining if the incidentName pertains to
// an existing, or a new incident
// This method then retrieves incident info (if applicable), and shows the
// report type text field.
- (void) incidentNameChanged
{
	// Make sure the report type fields start off as hidden:
	[_reportTypeLabelTextView setHidden:true];
	[_reportTypeTextField setHidden:true];

	// If the incident name changes, we want to:
	// clear the form
	[self clearAllFormFields];
	// hide all of the sections and collapse all sections
	[self hideAllFormSections:true];
	[self collapseAllSections];
	[self hideAllDropdownListsExcept:_incidentNameTextField];
	// clear the selected report type
	[_reportTypeTextField setText:@""];
	
	_lastRocData = nil;
	
	//-----------------------------------------------------------
	// Checking if the incidentName matches an existing incident
	// if so, pull that incident's data
	// otherwise, set the form up for creating a new incident
	//-----------------------------------------------------------
	
	NSLog(@"Incident name changed: %@",[_incidentNameTextField text]);
	NSString *incidentName = [_incidentNameTextField text];
	
	// Try getting the incident from the list of incidents
	
	_currentIncidentPayload = [[_dataManager getIncidentsList] objectForKey:incidentName];
	
	
	if(_currentIncidentPayload != nil)
	{
		_creatingNewIncident = false;
		
		// Instruct datamanager to pull the latest ROCs from the server for this incident
		[_dataManager requestLatestReportOnConditionForIncident:_currentIncidentPayload.incidentname];
		
		// Pulling the incident's latest ROC:
		_lastRocData = [_dataManager getLastReportOnConditionForIncidentId:[_currentIncidentPayload incidentid]];
		
		if(_lastRocData == nil)
		{
			_lastIncidentReportType = ROC_NONE;
		}
		else if([_lastRocData.reportType isEqualToString:@"NEW"])
		{
			_lastIncidentReportType = ROC_NEW;
		}
		else if([_lastRocData.reportType isEqualToString:@"UPDATE"])
		{
			_lastIncidentReportType = ROC_UPDATE;
		}
		else if([_lastRocData.reportType isEqualToString:@"FINAL"])
		{
			_lastIncidentReportType = ROC_FINAL;
		}
	}
	// If the name is a valid incident name (e.g. not all whitespace)
	else if(![self isStringEmpty:incidentName])
	{
		_creatingNewIncident = true;
		_currentIncidentPayload = nil;
		_lastIncidentReportType = ROC_NONE;
	}
	else
	{
		_creatingNewIncident = true;
		_currentIncidentPayload = nil;
		_lastIncidentReportType = ROC_NONE;
		return;
	}
	
	
	//-----------------------------------------------------------
	// If the incident exists, filling the UI fields for it
	// and making them read-only
	//-----------------------------------------------------------
	
	if(_currentIncidentPayload != nil)
	{
		[self setupFormForIncident:_currentIncidentPayload];
		[self makeIncidentFieldsReadOnly];
		// Leave incident name as editable
	}
	// Otherwise, leave the fields as editable
	else
	{
		
		[_incidentLocateButton setEnabled:true];
		[_incidentLocateButton setHidden:false];
		[_incidentNumberTextField setEnabled:true];
		[_incidentNameTextField setEnabled:true];
		[_incidentLongitudeDegreesTextField setEnabled:true];
		[_incidentLongitudeMinutesTextField setEnabled:true];
		[_incidentLongitudeMinutesFractionTextField setEnabled:true];
		[_incidentLatitudeDegreesTextField setEnabled:true];
		[_incidentLatitudeMinutesTextField setEnabled:true];
		[_incidentLatitudeMinutesFractionTextField setEnabled:true];
		[_incidentStateField setEnabled:true];
	}

	//-----------------------------------------------------------
	// Setting the available report type options for report type:
	//-----------------------------------------------------------
	
	NSArray *reportTypesROCNone = @[@"NEW"];
	NSArray *reportTypesROCNONFinal = @[@"UPDATE",@"FINAL"];
	NSArray *reportTypes = nil;
	
	
	if(_lastIncidentReportType == ROC_NONE)
	{
		reportTypes = reportTypesROCNone;
	}
	else if(_lastIncidentReportType == ROC_NEW || _lastIncidentReportType == ROC_UPDATE)
	{
		reportTypes = reportTypesROCNONFinal;
	}
	else if(_lastIncidentReportType == ROC_FINAL)
	{
		// If the incident has a FINAL ROC, no other ROCs can be created,
		// so show an error message indicating that:
		[_reportTypeLabelTextView setHidden:false];
		NSString *errorMessage = [NSString stringWithFormat:@"Unable to create ROC.\nA FINAL ROC has already been submitted for this incident."];
		[_reportTypeLabelTextView setText:errorMessage];
		return;
	}

	
	// Show the report type spinner and label
	// Because the label may have been re-used for an error message, reassign the original text
	[_reportTypeLabelTextView setText:@"Report Type:"];
	[_reportTypeLabelTextView setHidden:false];
	[_reportTypeTextField setHidden:false];
	
	// Set the fields for the report type spinner:
	[self makeStringPickerTextField:_reportTypeTextField withOptions:reportTypes andTitle:@"Report type:"];
}


// Converts "Decimal Degrees" to "Degree Decimal-Minutes"
// This function returns the integer "Degrees" portion of "DDM"
- (int) getDegree:(double) degrees
{
	// We want to round towards 0
	if(degrees < 0)
	{
		return (int) ceil(degrees);
	}
	
	return (int) floor(degrees);
}

// Converts "Decimal Degrees" to "Degree Decimal-Minutes"
// This function returns the double "Decimal-Minutes" integer portion of "DDM"
- (int) getMinutesInteger:(double) degrees
{
	return (int) floor(60.0 * fabs(degrees - [self getDegree:degrees]));
}

// Converts "Decimal Degrees" to "Degree Decimal-Minutes"
// This function returns the double "Decimal-Minutes" fractional portion of "DDM"
- (double) getMinutesFraction:(double) degrees
{
	return fmod(60.0 * fabs(degrees - [self getDegree:degrees]),1.0);
}


// Converts Degrees Decimal-Minutes into Decimal Degrees
- (double) toDecimalDegrees:(int)degrees minutes:(double)minutes
{
	return degrees + (degrees >= 0 ? 1 : -1) * (minutes / 60.0);
}



// Converts "Decimal Degrees" to "Degree Decimal-Minutes"
// returns the degree portion as a string
- (NSString*) getDegreeAsString:(double) degrees
{
	return [NSString stringWithFormat:@"%d", [self getDegree:degrees]];
}


// Converts "Decimal Degrees" to "Degree Decimal-Minutes"
// returns the whole number of the minutes portion as a string
- (NSString*) getMinutesIntegerAsString:(double) degrees
{
	return [NSString stringWithFormat:@"%d", [self getMinutesInteger:degrees]];
}


// Converts "Decimal Degrees" to "Degree Decimal-Minutes"
// returns the fraction of the minutes portion as a string
- (NSString*) getMinutesFractionAsString:(double) degrees
{
	return [self stringGetFraction:[NSString stringWithFormat:@"%f", [self getMinutesFraction:degrees]]];
}




// Takes a string representing a fraction and returns only the portion to the right of the last decimal point
// i.e.: takes the string: "0.12345" and returns "12345"
- (NSString*) stringGetFraction:(NSString*)str
{
	if(str == nil)
		return @"0";
	
	// Get the index of the decimal point, if it exists:
	NSRange lastDecimalPointIndex = [str rangeOfString:@"." options:NSBackwardsSearch];
	
	
	// If the decimal point was not found:
	if(lastDecimalPointIndex.location == NSNotFound || (lastDecimalPointIndex.location + lastDecimalPointIndex.length > str.length))
	{
		// This means the string passed represents a whole number, making the fractional part = 0
		// Return the fractional part of a whole number, which is always "0"
		return @"0";
	}
	
	// If the decimal point index is the last character in the string, that means we have a string like "123."
	if(lastDecimalPointIndex.location == [str length] - 1)
	{
		// That makes the number a whole number (i.e. "2."), making the fractional part = 0
		// Return the fractional part of a whole number, which is always "0"
		return @"0";
	}
	
	unsigned long start = lastDecimalPointIndex.location + 1;
	unsigned long end = [str length];
	
	// We want to truncate to 4 decimal places
	if(end > start + 4)
	{
		end = start + 4;
	}
	
	// Return the substring to the right of the decimal point, but no more than 4 digits
	// (we want to truncate to 4 digits
	return [str substringWithRange:NSMakeRange(start, end - start)];
}

// Returns if a desired latlong is valid
- (bool) isValidLatLongLatDeg:(int)latDeg LatMin:(double)latMin LonDeg:(int)lonDeg LonMin:(double)lonMin
{
	// latitude degrees in [-89,89]
	if(latDeg <= -90 || latDeg >= 90)
		return false;
	// latitude minutes in [0, 60)
	if(latMin < 0.0 || latMin >= 60.0)
		return false;
	// longitude degrees in [-179, 179]
	if(lonDeg <= -180.0 || lonDeg >= 180.0)
		return false;
	// longitude minutes in [0, 60)
	if(lonMin < 0.0 || lonMin >= 60.0)
		return false;
	
	return true;
}

// Clears the textfield and sets it to the value, if the string is not "(null") or "null"
// Returns if the value was valid and assigned
- (bool) setFieldTextIfValid:(UITextField*)textField asValue:(id)val
{
	[textField setText:@""];
	
	if(val == nil)
	{
		NSLog(@"ROC - The value itself is nil");
		return false;
	}
	
	
	// If it's a string, make sure it's not null or "(null)"
	if([val isKindOfClass:[NSString class]])
	{
		NSString *str = (NSString*)val;
		
		if([str isEqualToString:@"(null)"])
		{
			NSLog(@"ROC - The string is (null)!");
			return false;
		}
		
		if([str isEqualToString:@"null"])
		{
			NSLog(@"ROC - The string is null");
			return false;
		}
		
		NSLog(@"ROC - The value was set as %@",str);
		
		[textField setText:str];
	}
	// If it's a number, set it as the
	else if([val isKindOfClass:[NSNumber class]])
	{
		
		NSString *formattedString = [NSString stringWithFormat:@"%f", [val doubleValue]];
		
		// If for some reason it failed to yield a valid string, stop.
		if(formattedString == nil)
		{
			NSLog(@"ROC - The number failed to convert to a string.");
			return false;
		}
		
		// Apparently there's no easy way to do this, so I'll do it manually.
		// Removing all trailing 0's
		while([formattedString characterAtIndex:([formattedString length] - 1)] == '0')
		{
			formattedString = [formattedString substringToIndex:([formattedString length] - 1)];
		}
		
		// If we removed all trailing 0's, and we have a decimal point as the last character
		// remove the decimal point
		if([formattedString characterAtIndex:([formattedString length] - 1)] == '.')
		{
			formattedString = [formattedString substringToIndex:([formattedString length] - 1)];
		}
		
		NSLog(@"ROC - The value was set as %@",formattedString);
		
		[textField setText:formattedString];
	}
	
	return true;
}


// Populates the form fields with values from a NSDictionary
- (void) setLocationBasedDataFields:(NSDictionary*)data
{
	_successfullyGotAllWeatherData = false;

	if(data != nil)
	{
		_successfullyGotAllWeatherData = true;
		
		if(![self setFieldTextIfValid:_rocLocationTextField asValue:data[@"location"]])
			_successfullyGotAllWeatherData = false;
		if(![self setFieldTextIfValid:_rocInitialCountyTextField asValue:data[@"county"]])
			_successfullyGotAllWeatherData = false;
		if(![self setFieldTextIfValid:_incidentStateField asValue:data[@"state"]])
			_successfullyGotAllWeatherData = false;
		if(![self setFieldTextIfValid:_rocOwnershipTextField asValue:data[@"sra"]])
			_successfullyGotAllWeatherData = false;
		if(![self setFieldTextIfValid:_rocDPATextField asValue:data[@"dpa"]])
			_successfullyGotAllWeatherData = false;
		if(![self setFieldTextIfValid:_rocJurisdictionTextField asValue:data[@"jurisdiction"]])
			_successfullyGotAllWeatherData = false;
		
		if(![self setFieldTextIfValid:_weatherTemperatureTextField asValue:data[@"temperature"]])
			_successfullyGotAllWeatherData = false;
		if(![self setFieldTextIfValid:_weatherHumidityTextField asValue:data[@"relHumidity"]])
			_successfullyGotAllWeatherData = false;
		if(![self setFieldTextIfValid:_weatherWindSpeedTextField asValue:data[@"windSpeed"]])
			_successfullyGotAllWeatherData = false;
		if(![self setFieldTextIfValid:_weatherWindDirectionTextField asValue:data[@"windDirection"]])
			_successfullyGotAllWeatherData = false;
		// TODO - Add this
		//if(![self setFieldTextIfValid:_weatherGustsTextField asValue:locationData[@"windGusts"]];
	}
}

// Called when the user taps the incident locate button
// This is responsible for making a request to the SCOUT server and
// retrieving location-based data (weather and jurisdiction info)
- (void) incidentLocateButtonPressed
{
	// Get the device's latest coordinates
	double latitude = _dataManager.currentLocation.coordinate.latitude;
	double longitude = _dataManager.currentLocation.coordinate.longitude;
	
	// Insert the location we just computed into the UI text fields
	[_incidentLatitudeDegreesTextField setText:[self getDegreeAsString:latitude]];
	[_incidentLatitudeMinutesTextField setText:[self getMinutesIntegerAsString:latitude]];
	[_incidentLatitudeMinutesFractionTextField setText:[self getMinutesFractionAsString:latitude]];
	// NOTE - we multiply the value by -1 because the UI has a hardcoded "-" sign in front of it
	// (all longitudes in california are in the -120 range, and the client doesn't want users to have to manually enter the "-" sign)
	[_incidentLongitudeDegreesTextField setText:[self getDegreeAsString:-1 * longitude]];
	[_incidentLongitudeMinutesTextField setText:[self getMinutesIntegerAsString:longitude]];
	[_incidentLongitudeMinutesFractionTextField setText:[self getMinutesFractionAsString:longitude]];
	
	// Make the request to get location-based data for these coordinates
	_successfullyGotAllWeatherData = false;
	NSDictionary *locationData = [RestClient getLocationBasedDataForLatitude:latitude andLongitude:longitude];
	[self setLocationBasedDataFields:locationData];
	
	NSLog(@"ROC - Should be pulling Location-based data");
}


// Called when one of the location fields has been editted
// This is responsible for making the same request to the SCOUT server
// as incidentLocateButtonPressed
- (void) incidentLocationChanged
{
	// Ensure they are all valid numbers first:
	if(![self isValidInt:[_incidentLatitudeDegreesTextField text]])
	{
		NSLog(@"ROC - incidentLocationChanged - latitude degrees is not a valid int.");
		return;
	}
	if(![self isValidInt:[_incidentLatitudeMinutesTextField text]])
	{
		NSLog(@"ROC - incidentLocationChanged - latitude minutes is not a valid int.");
		return;
	}
	if(![self isValidInt:[_incidentLatitudeMinutesFractionTextField text]])
	{
		NSLog(@"ROC - incidentLocationChanged - latitude minutes fraction is not a valid int.");
		return;
	}
	if(![self isValidInt:[_incidentLongitudeDegreesTextField text]])
	{
		NSLog(@"ROC - incidentLocationChanged - longitude degrees is not a valid int.");
		return;
	}
	if(![self isValidInt:[_incidentLongitudeMinutesTextField text]])
	{
		NSLog(@"ROC - incidentLocationChanged - longitude minutes is not a valid int.");
		return;
	}
	if(![self isValidInt:[_incidentLongitudeMinutesFractionTextField text]])
	{
		NSLog(@"ROC - incidentLocationChanged - longitude minutes fraction is not a valid int.");
		return;
	}

	// Parse the location from the textfields
	int latDeg = (int) [[_incidentLatitudeDegreesTextField text] doubleValue];
	double latMinWhole = [[_incidentLatitudeMinutesTextField text] doubleValue];
	double latMinFraction = [[NSString stringWithFormat:@"0.%@",[_incidentLatitudeMinutesFractionTextField text]] doubleValue];
	double latMin = latMinWhole + latMinFraction;
	
	// NOTE - we multiply the value by -1 because the UI has a hardcoded "-" sign in front of it
	// (all longitudes in california are in the -120 range, and the client doesn't want users to have to manually enter the "-" sign)
	int lonDeg = -1 * (int) [[_incidentLongitudeDegreesTextField text] doubleValue];
	double lonMinWhole = [[_incidentLongitudeMinutesTextField text] doubleValue];
	double lonMinFraction = [[NSString stringWithFormat:@"0.%@",[_incidentLongitudeMinutesFractionTextField text]] doubleValue];
	double lonMin = lonMinWhole + lonMinFraction;

	// Verify that these are valid coordiantes
	if(![self isValidLatLongLatDeg:latDeg LatMin:latMin LonDeg:lonDeg LonMin:lonMin])
	{
		NSLog(@"ROC - incidentLocationChanged - values do nor represent a valid lat long.");
		return;
	}

	// Convert them to Decimal Degrees
	double latitude = [self toDecimalDegrees:latDeg minutes:latMin];
	double longitude = [self toDecimalDegrees:lonDeg minutes:lonMin];

	// Make the request to get location-based data for these coordinates
	_successfullyGotAllWeatherData = false;
	NSDictionary *locationData = [RestClient getLocationBasedDataForLatitude:latitude andLongitude:longitude];
	[self setLocationBasedDataFields:locationData];
	

	// TODO - Make the incident location text fields call this when modified
}

// Removes all child view from the stack view:
- (void) clearTextFieldListStackView:(UIStackView*)stackView withHeightConstraint:(NSLayoutConstraint*)constraint
{
	for(UIView *child1 in [stackView arrangedSubviews])
	{
		// Find the textview and remove the delegate:
		for(UIView *child2 in [child1 subviews])
		{
			// If it's a TextField, clean up its delegate before we delete it
			if([child2 class] == [UITextField class])
			{
				[self cleanUpDelegateForTextField:((UITextField*)child2)];
			}
		}
		// Decrease the height of the list
		constraint.constant -= 45;
		[stackView removeArrangedSubview:child1];
	}
}


// This method clears a textfield list stackview, and sets the the autocomplete array that
// textFields in the stackview use for autocompletion
- (void) setupTextFieldList:(UIStackView*)stackView
		    withTextField:(UITextField*)textField
		 heightConstraint:(NSLayoutConstraint*)constraint
			   addButton:(UIButton*)button
			  yesOptions:(NSArray*)yesOptions
		 mitigatedOptions:(NSArray*)mitigatedOptions
{
	// Remove all text box entry fields:
	[self clearTextFieldListStackView:stackView withHeightConstraint:constraint];
	
	
	NSArray *newArray = nil;
	
	// Set the autocomplete options
	if([[textField text] isEqualToString:@"Yes"])
	{
		// Copy the options we want to store:
		newArray = [NSArray<NSString*> arrayWithArray:yesOptions];
		
		// Show the fields:
		[stackView setHidden:false];
		[button setHidden:false];
	}
	else if([[textField text] isEqualToString:@"Mitigated"])
	{
		// Updating the destArray pointer to point to mitigatedOptions
		newArray = [NSArray<NSString*> arrayWithArray:mitigatedOptions];

		// Show the fields:
		[stackView setHidden:false];
		[button setHidden:false];
	}
	else
	{
		// Updating the destArray pointer to point to nil (no autocomplete suggestions)
		newArray = nil;
		
		// Hide the fields:
		[stackView setHidden:true];
		[button setHidden:true];
	}
	
	
	
	// We don't know which destination array to store the new options in
	// Check which stackview it is to know which array to store newArray as
	if(stackView == _threatsEvacsInfoListStackView)
	{
		_evacuationsAutocompleteOptions = newArray;
	}
	else if(stackView == _threatsStructuresInfoListStackView)
	{
		_structureThreatsAutocompleteOptions = newArray;
	}
	else if(stackView == _threatsInfrastructureInfoListStackView)
	{
		_infrastructureThreatsAutocompleteOptions = newArray;
	}
}


// This is called when the incident type is changed
// If the user selects / deselects vegetation fire
// the veg. fire and the Threats & Evacs fields are set to required or not required
- (void) incidentTypeChanged
{
	if(_incidentTypeViewController == nil)
		return;
	
	NSArray *incidentTypes = [_incidentTypeViewController getSelectedOptions];
	
	// If the incident type contains wildland fire:
	bool isVegFireIncident = [incidentTypes containsObject:@"Fire (Wildland)"];
	
	[self makeTextFieldRequired:_vegFireAcreageTextField required:isVegFireIncident];
	[self makeTextFieldRequired:_vegFireSpreadRateTextField required:isVegFireIncident];
	[self makeTextFieldRequired:_vegFirePercentContainedTextField required:isVegFireIncident];

	[self makeTextFieldRequired:_threatsEvacsTextField required:isVegFireIncident];
	[self makeTextFieldRequired:_threatsStructuresTextField required:isVegFireIncident];
	[self makeTextFieldRequired:_threatsInfrastructureTextField required:isVegFireIncident];
	
	// Clear the errors on all of these fields
	[self clearViewError:_vegFireAcreageTextField];
	[self clearViewError:_vegFireSpreadRateTextField];
	[self clearViewError:_vegFirePercentContainedTextField];
	[self clearViewError:_threatsEvacsTextField];
	[self clearViewError:_threatsStructuresTextField];
	[self clearViewError:_threatsInfrastructureTextField];
}


// Called when the user select an option for Evacuations, sets up the fields with the correct autocomplete options
- (void) evacuationsSpinnerChanged
{
	NSArray *yesOptions =
	@[
		@"Evacuation orders in place",
		@"Evacuation center has been established",
		@"Evacuation warnings have been lifted",
		@"Evacuations orders remain in place",
		@"Mandatory evacuations are currently underway"
	];
	
	NSArray *mitigatedOptions =
	@[
		@"Evacuation warnings have been lifted"
	];
	
	
	[self setupTextFieldList:_threatsEvacsInfoListStackView
			 withTextField:_threatsEvacsTextField
		   heightConstraint:_threatsEvacsListHeightConstraint
				addButton:_threatsEvacsAddButton
			    yesOptions:yesOptions
		   mitigatedOptions:mitigatedOptions];
}


// Called when the user selects an option for Structure Threats, sets up the fields with the correct autocomplete options
- (void) structureThreatsSpinnerChanged
{
	NSArray *yesOptions =
	@[
		@"Structures threatened",
		@"Continued threat to structures",
		@"Immediate structure threat, evacuations in place",
		@"Damage inspection is ongoing ",
		@"Inspections are underway to identify damage to critical infrastructure and structures"
	];
	
	NSArray *mitigatedOptions =
	@[
		@"Structure threat mitigated",
		@"Damage inspection is ongoing ",
		@"Inspections are underway to identify damage to critical infrastructure and structures",
		@"All threats mitigated"
	];
	
	
	[self setupTextFieldList:_threatsStructuresInfoListStackView
			 withTextField:_threatsStructuresTextField
		   heightConstraint:_threatsStructuresListHeightConstraint
				addButton:_threatsStructuresAddButton
			    yesOptions:yesOptions
		   mitigatedOptions:mitigatedOptions];
}


// Called when the user selects an option for Infrastructure Threats, sets up the fields with the correct autocomplete options
- (void) infrastructureThreatsSpinnerChanged
{
	NSArray *yesOptions =
	@[
		@"Immediate structure threat, evacuations in place",
		@"Damage inspection is ongoing ",
		@"Inspections are underway to identify damage to critical infrastructure and structures",
		@"Major power transmission lines threatened",
		@"Road closures in the area"
	];
	
	NSArray *mitigatedOptions =
	@[
		@"Damage inspection is ongoing ",
		@"Inspections are underway to identify damage to critical infrastructure and structures",
		@"All road closures have been lifted",
		@"All threats mitigated"
	];
	
	
	[self setupTextFieldList:_threatsInfrastructureInfoListStackView
			 withTextField:_threatsInfrastructureTextField
		   heightConstraint:_threatsInfrastructureListHeightConstraint
				addButton:_threatsInfrastructureAddButton
			    yesOptions:yesOptions
		   mitigatedOptions:mitigatedOptions];
}

// This makes all UI fields read-only
- (void) makeAllFieldsReadOnly
{
	//---------------------------------------------------------------------------
	// ROC Form Info Fields
	//---------------------------------------------------------------------------
	[_incidentNameTextField setEnabled:false];
	[_reportTypeTextField setEnabled:false];
	//---------------------------------------------------------------------------
	// Incident Info Fields
	//---------------------------------------------------------------------------
	[_incidentNumberTextField setEnabled:false];
	[_incidentTypeViewController setCheckboxesEnabled:false];

	[_incidentLatitudeDegreesTextField setEnabled:false];
	[_incidentLatitudeMinutesTextField setEnabled:false];
	[_incidentLatitudeMinutesFractionTextField setEnabled:false];
	[_incidentLongitudeDegreesTextField setEnabled:false];
	[_incidentLongitudeMinutesTextField setEnabled:false];
	[_incidentLongitudeMinutesFractionTextField setEnabled:false];
	[_incidentLocateButton setEnabled:false];
	[_incidentStateField setEnabled:false];
	//---------------------------------------------------------------------------
	// ROC Incident Info Fields
	//---------------------------------------------------------------------------
	[_rocInitialCountyTextField setEnabled:false];
	[_rocAdditionalCountiesTextField setEnabled:false];
	[_rocLocationTextField setEnabled:false];
	[_rocStreetTextField setEnabled:false];
	[_rocCrossStreetTextField setEnabled:false];
	[_rocNearestCommunityTextField setEnabled:false];
	[_rocDistanceFromNearestCommunityTextField setEnabled:false];
	[_rocDirectionFromNearestCommunityTextField setEnabled:false];
	[_rocDPATextField setEnabled:false];
	[_rocOwnershipTextField setEnabled:false];
	[_rocJurisdictionTextField setEnabled:false];
	[_rocStartDateTextField setEnabled:false];
	[_rocStartTimeTextField setEnabled:false];
	//---------------------------------------------------------------------------
	// Vegetation Fire Incident Scope Fields
	//---------------------------------------------------------------------------
	[_vegFireAcreageTextField setEnabled:false];
	[_vegFireSpreadRateTextField setEnabled:false];
	// Checkboxes
	[_vegFireFuelTypeGrassCheckbox setEnabled:false];
	[_vegFireFuelTypeBrushCheckbox setEnabled:false];
	[_vegFireFuelTypeTimberCheckbox setEnabled:false];
	[_vegFireFuelTypeOakWoodlandCheckbox setEnabled:false];
	[_vegFireFuelTypeOtherCheckbox setEnabled:false];
	
	[_vegFireOtherFuelTypeTextField setEnabled:false];
	[_vegFirePercentContainedTextField setEnabled:false];
	//---------------------------------------------------------------------------
	// Weather Information Fields
	//---------------------------------------------------------------------------
	[_weatherTemperatureTextField setEnabled:false];
	[_weatherHumidityTextField setEnabled:false];
	[_weatherWindSpeedTextField setEnabled:false];
	[_weatherWindDirectionTextField setEnabled:false];
	[_weatherGustsTextField setEnabled:false];
	//---------------------------------------------------------------------------
	// Threats & Evacuations Fields
	//---------------------------------------------------------------------------
	[_threatsEvacsTextField setEnabled:false];
	[_threatsEvacsAddButton setEnabled:false];
	
	[_threatsStructuresTextField setEnabled:false];
	[_threatsStructuresAddButton setEnabled:false];
	
	[_threatsInfrastructureTextField setEnabled:false];
	[_threatsInfrastructureAddButton setEnabled:false];
	
	//---------------------------------------------------------------------------
	// Resource Commitment Fields
	//---------------------------------------------------------------------------
	[_calFireIncidentTextField setEnabled:false];
	// Checkboxes
	[_calFireResourcesNoneCheckbox setEnabled:false];
	[_calFireResourcesAirCheckbox setEnabled:false];
	[_calFireResourcesGroundCheckbox setEnabled:false];
	[_calFireResourcesAirAndGroundCheckbox setEnabled:false];
	[_calFireResourcesAirAndGroundAugmentedCheckbox setEnabled:false];
	[_calFireResourcesAgencyRepOrderedCheckbox setEnabled:false];
	[_calFireResourcesAgencyRepAssignedCheckbox setEnabled:false];
	[_calFireResourcesContinuedCheckbox setEnabled:false];
	[_calFireResourcesSignificantAugmentationCheckbox setEnabled:false];
	[_calFireResourcesVlatOrderCheckbox setEnabled:false];
	[_calFireResourcesVlatAssignedCheckbox setEnabled:false];
	[_calFireResourcesNoDivertCheckbox setEnabled:false];
	[_calFireResourcesLatAssignedCheckbox setEnabled:false];
	[_calFireResourcesAllReleasedCheckbox setEnabled:false];
	
	//---------------------------------------------------------------------------
	// Other Significant Info Fields
	//---------------------------------------------------------------------------
	[_otherInfoAddButton setEnabled:false];
	//---------------------------------------------------------------------------
	// Email Fields
	//---------------------------------------------------------------------------
	[_emailTextField setEnabled:false];
	//---------------------------------------------------------------------------
}


// This hides / shows the appropriate fields depending on the report type
- (void) setupFormForReportType
{
	//========================================================================
	// Make the section headers hide / unhide their sections:
	//========================================================================
	
	_incidentInfoHeaderView.tag = ID_SECTION_INCIDENT_INFO;
	[_incidentInfoHeaderView addGestureRecognizer:[self newTapRecognizer]];
	_rocIncidentInfoHeaderView.tag = ID_SECTION_ROC_INFO;
	[_rocIncidentInfoHeaderView addGestureRecognizer:[self newTapRecognizer]];
	_vegFireIncidentScopeHeaderView.tag = ID_SECTION_VEG_FIRE;
	[_vegFireIncidentScopeHeaderView addGestureRecognizer:[self newTapRecognizer]];
	_weatherInfoHeaderView.tag = ID_SECTION_WEATHER_INFO;
	[_weatherInfoHeaderView addGestureRecognizer:[self newTapRecognizer]];
	_threatsEvacsHeaderView.tag = ID_SECTION_THREATS;
	[_threatsEvacsHeaderView addGestureRecognizer:[self newTapRecognizer]];
	_resourceCommitmentHeaderView.tag = ID_SECTION_RESOURCES;
	[_resourceCommitmentHeaderView addGestureRecognizer:[self newTapRecognizer]];
	_otherInfoHeaderView.tag = ID_SECTION_OTHER_INFO;
	[_otherInfoHeaderView addGestureRecognizer:[self newTapRecognizer]];
	_emailHeaderView.tag = ID_SECTION_EMAIL;
	[_emailHeaderView addGestureRecognizer:[self newTapRecognizer]];
	
	//========================================================================
	// Setting up autocomplete value arrays:
	//========================================================================
	// All counties in California
	NSArray *countiesArr = @[@"Alameda",@"Alpine",@"Amador",@"Butte",@"Calaveras",
						@"Colusa",@"Contra Costa",@"Del Norte",@"El Dorado",
						@"Fresno",@"Glenn",@"Humboldt",@"Imperial",@"Inyo",
						@"Kern",@"Kings",@"Lake",@"Lassen",@"Los Angeles",
						@"Madera",@"Marin",@"Mariposa",@"Mendocino",@"Merced",
						@"Modoc",@"Mono",@"Monterey",@"Napa",@"Nevada",@"Orange",
						@"Placer",@"Plumas",@"Riverside",@"Sacramento",
						@"San Benito",@"San Bernardino",@"San Diego",
						@"San Francisco",@"San Joaquin",@"San Luis Obispo",
						@"San Mateo",@"Santa Barbara",@"Santa Clara",@"Santa Cruz",
						@"Shasta",@"Sierra",@"Siskiyou",@"Solano",@"Sonoma",
						@"Stanislaus",@"Sutter",@"Tehama",@"Trinity",@"Tulare",
						@"Tuolumne",@"Ventura",@"Yolo",@"Yuba"];
	// All incident types
	NSArray *incidentTypeOptionsArr = @[@"Aircraft Accident",@"Timber",
								 @"Oak Woodland",@"Blizzard",@"Civil Unrest",
								 @"Earthquake",@"Fire (Structure)",@"Fire (Wildland)",
								 @"Flood",@"Hazardous Materials",@"Hurricane",
								 @"Mass Casualty",@"Nuclear Accident",@"Oil Spill",
								 @"Planned Event",@"Public Health / Medical Emergency",
								 @"Search and Rescue",@"Terrorist Threat / Attack",
								 @"Tornado",@"Tropical Storm",@"Tsunami"];
	// DPA options
	NSArray *dpaOptionsArr = @[@"State",@"Federal",@"Local",@"State/Federal",
						  @"State/Local",@"State/Federal/Local"];
	
	// Ownership options
	NSArray *ownershipOptionsArr = @[@"SRA",@"FRA",@"LRA",@"FRA / SRA",@"FRA / LRA",
							   @"SRA / LRA",@"SRA / FRA",@"LRA / SRA",@"LRA / FRA",@"DOD"];
	
	// Rate of Spread options
	NSArray *rateOfSpreadOptionsArr = @[@"Slow rate of spread",@"Moderate rate of spread",
								 @"Dangerous rate of spread",@"Critical rate of spread",
								 @"Forward spread has been stopped"];
	NSArray *rateOfSpreadOptionsArrFinal = @[@"Forward spread has been stopped"];

	// Wind Direction options
	NSArray *windDirectionOptionsArr = @[@"N",@"NNE",@"NE",@"ENE",@"E",@"ESE",
								  @"SE",@"SSE",@"S",@"SSW",@"SW",@"WSW",
								  @"W",@"WNW",@"NW",@"NNW"];
	// CAL FIRE Incident options
	NSArray *calFireIncidentOptions = @[@"Yes",@"No"];
	//========================================================================
	//---------------------------------------------------------------------------
	// ROC Form Info Fields
	//---------------------------------------------------------------------------
	// All setup for incidentName and reportType fields is done in viewDidLoad
	//---------------------------------------------------------------------------
	// Incident Info Fields
	//---------------------------------------------------------------------------
	// Setting up the Checkbox tableView
	CheckBoxTableViewController *tableViewController = [[CheckBoxTableViewController alloc] initForTableView:_incidentTypeTableView withOptions:incidentTypeOptionsArr withSelector:@selector(incidentTypeChanged) andTarget:self];
	
	[self cleanUpDelegateForTableView:_incidentTypeTableView];
	_incidentTypeViewController = tableViewController;
	[_incidentTypeTableView setDelegate:tableViewController];
	[_delegatesArray addObject:tableViewController];
	// Marking required fields
	[self makeTextFieldRequired:_incidentLatitudeDegreesTextField required:true];
	[self makeTextFieldRequired:_incidentLatitudeMinutesTextField required:true];
	[self makeTextFieldRequired:_incidentLatitudeMinutesFractionTextField required:true];
	[self makeTextFieldRequired:_incidentLongitudeDegreesTextField required:true];
	[self makeTextFieldRequired:_incidentLongitudeMinutesTextField required:true];
	[self makeTextFieldRequired:_incidentLongitudeMinutesFractionTextField required:true];
	[self makeTextFieldRequired:_incidentStateField required:true];
	
	
	// Setting the location fields to request data when they are changed:
	[_incidentLatitudeDegreesTextField addTarget:self action:@selector(incidentLocationChanged)
						   forControlEvents:UIControlEventEditingDidEnd];
	[_incidentLatitudeMinutesTextField addTarget:self action:@selector(incidentLocationChanged)
						   forControlEvents:UIControlEventEditingDidEnd];
	[_incidentLatitudeMinutesFractionTextField addTarget:self action:@selector(incidentLocationChanged)
								  forControlEvents:UIControlEventEditingDidEnd];
	[_incidentLongitudeDegreesTextField addTarget:self action:@selector(incidentLocationChanged)
						   forControlEvents:UIControlEventEditingDidEnd];
	[_incidentLongitudeMinutesTextField addTarget:self action:@selector(incidentLocationChanged)
						    forControlEvents:UIControlEventEditingDidEnd];
	[_incidentLongitudeMinutesFractionTextField addTarget:self action:@selector(incidentLocationChanged)
						    forControlEvents:UIControlEventEditingDidEnd];

	
	// Setting fields to clear their errors when modified
	[self makeTextFieldClearErrorWhenChanged:_incidentNumberTextField];
	[self makeTextFieldClearErrorWhenChanged:_incidentLatitudeDegreesTextField];
	[self makeTextFieldClearErrorWhenChanged:_incidentLatitudeMinutesTextField];
	[self makeTextFieldClearErrorWhenChanged:_incidentLatitudeMinutesFractionTextField];
	[self makeTextFieldClearErrorWhenChanged:_incidentLongitudeDegreesTextField];
	[self makeTextFieldClearErrorWhenChanged:_incidentLongitudeMinutesTextField];
	[self makeTextFieldClearErrorWhenChanged:_incidentLongitudeMinutesFractionTextField];
	[self makeTextFieldClearErrorWhenChanged:_incidentStateField];
	//---------------------------------------------------------------------------
	// ROC Incident Info Fields
	//---------------------------------------------------------------------------
	[self makeStringPickerTextField:_rocInitialCountyTextField withOptions:countiesArr andTitle:@"Initial County:"];
	[self makeStringPickerTextField:_rocDPATextField withOptions:dpaOptionsArr andTitle:@"DPA:"];
	[self makeStringPickerTextField:_rocOwnershipTextField withOptions:ownershipOptionsArr andTitle:@"Ownership:"];
	[self makeDatePicker:_rocStartDateTextField];
	[self makeTimePicker: _rocStartTimeTextField];
	// Marking required fields
	[self makeTextFieldRequired:_rocInitialCountyTextField required:true];
	[self makeTextFieldRequired:_rocLocationTextField required:true];
	[self makeTextFieldRequired:_rocStreetTextField required:true];
	[self makeTextFieldRequired:_rocCrossStreetTextField required:true];
	[self makeTextFieldRequired:_rocNearestCommunityTextField required:true];
	[self makeTextFieldRequired:_rocDistanceFromNearestCommunityTextField required:true];
	[self makeTextFieldRequired:_rocDirectionFromNearestCommunityTextField required:true];
	[self makeTextFieldRequired:_rocDPATextField required:true];
	[self makeTextFieldRequired:_rocOwnershipTextField required:true];
	[self makeTextFieldRequired:_rocJurisdictionTextField required:true];
	[self makeTextFieldRequired:_rocStartDateTextField required:true];
	[self makeTextFieldRequired:_rocStartTimeTextField required:true];
	// Setting fields to clear their errors when modified
	[self makeTextFieldClearErrorWhenChanged:_rocInitialCountyTextField];
	[self makeTextFieldClearErrorWhenChanged:_rocAdditionalCountiesTextField];
	[self makeTextFieldClearErrorWhenChanged:_rocLocationTextField];
	[self makeTextFieldClearErrorWhenChanged:_rocStreetTextField];
	[self makeTextFieldClearErrorWhenChanged:_rocCrossStreetTextField];
	[self makeTextFieldClearErrorWhenChanged:_rocNearestCommunityTextField];
	[self makeTextFieldClearErrorWhenChanged:_rocDistanceFromNearestCommunityTextField];
	[self makeTextFieldClearErrorWhenChanged:_rocDirectionFromNearestCommunityTextField];
	[self makeTextFieldClearErrorWhenChanged:_rocDPATextField];
	[self makeTextFieldClearErrorWhenChanged:_rocOwnershipTextField];
	[self makeTextFieldClearErrorWhenChanged:_rocJurisdictionTextField];
	[self makeTextFieldClearErrorWhenChanged:_rocStartDateTextField];
	[self makeTextFieldClearErrorWhenChanged:_rocStartTimeTextField];
	//---------------------------------------------------------------------------
	// Vegetation Fire Incident Scope Fields
	//---------------------------------------------------------------------------
	if(_currentReportType != ROC_FINAL)
	{
		[self makeStringPickerTextField:_vegFireSpreadRateTextField withOptions:rateOfSpreadOptionsArr andTitle:@"Rate of Spread:"];
	}
	else
	{
		[self makeStringPickerTextField:_vegFireSpreadRateTextField withOptions:rateOfSpreadOptionsArrFinal andTitle:@"Rate of Spread:"];
	}
	[self makeCheckbox:_vegFireFuelTypeGrassCheckbox];
	[self makeCheckbox:_vegFireFuelTypeBrushCheckbox];
	[self makeCheckbox:_vegFireFuelTypeTimberCheckbox];
	[self makeCheckbox:_vegFireFuelTypeOakWoodlandCheckbox];
	[self makeOtherFuelTypeCheckbox:_vegFireFuelTypeOtherCheckbox];
	// Marking required fields
	// By default, these fields are not required
	// If the incident type changes to vegetation fire, these are set as required
	[self makeTextFieldRequired:_vegFireAcreageTextField required:false];
	[self makeTextFieldRequired:_vegFireSpreadRateTextField required:false];
	[self makeTextFieldRequired:_vegFirePercentContainedTextField required:false];
	// Setting fields to clear their errors when modified
	[self makeTextFieldClearErrorWhenChanged:_vegFireAcreageTextField];
	[self makeTextFieldClearErrorWhenChanged:_vegFireSpreadRateTextField];
	[self makeTextFieldClearErrorWhenChanged:_vegFirePercentContainedTextField];
	//---------------------------------------------------------------------------
	// Weather Information Fields
	//---------------------------------------------------------------------------
	[self makeStringPickerTextField:_weatherWindDirectionTextField withOptions:windDirectionOptionsArr andTitle:@"Wind Direction:"];
	// Marking required fields
		// no required fields
	// Setting fields to clear their errors when modified
	[self makeTextFieldClearErrorWhenChanged:_weatherTemperatureTextField];
	[self makeTextFieldClearErrorWhenChanged:_weatherHumidityTextField];
	[self makeTextFieldClearErrorWhenChanged:_weatherWindSpeedTextField];
	[self makeTextFieldClearErrorWhenChanged:_weatherWindDirectionTextField];
	[self makeTextFieldClearErrorWhenChanged:_weatherGustsTextField];
	//---------------------------------------------------------------------------
	// Threats & Evacuations Fields
	//---------------------------------------------------------------------------
		// done below in this same function
	// Marking required fields
	// By default, these fields are not required
	// If the incident type changes to vegetation fire, these are set as required
	[self makeTextFieldRequired:_threatsEvacsTextField required:false];
	[self makeTextFieldRequired:_threatsStructuresTextField required:false];
	[self makeTextFieldRequired:_threatsInfrastructureTextField required:false];
	// Setting fields to clear their errors when modified
	[self makeTextFieldClearErrorWhenChanged:_threatsEvacsTextField];
	[self makeTextFieldClearErrorWhenChanged:_threatsStructuresTextField];
	[self makeTextFieldClearErrorWhenChanged:_threatsInfrastructureTextField];
	//---------------------------------------------------------------------------
	// Resource Commitment Fields
	//---------------------------------------------------------------------------
	[self makeStringPickerTextField:_calFireIncidentTextField withOptions:calFireIncidentOptions andTitle:@"Is this a CAL FIRE incident?"];
	[self makeCheckbox:_calFireResourcesNoneCheckbox];
	[self makeCheckbox:_calFireResourcesAirCheckbox];
	[self makeCheckbox:_calFireResourcesGroundCheckbox];
	[self makeCheckbox:_calFireResourcesAirAndGroundCheckbox];
	[self makeCheckbox:_calFireResourcesAirAndGroundAugmentedCheckbox];
	[self makeCheckbox:_calFireResourcesAgencyRepOrderedCheckbox];
	[self makeCheckbox:_calFireResourcesAgencyRepAssignedCheckbox];
	[self makeCheckbox:_calFireResourcesContinuedCheckbox];
	[self makeCheckbox:_calFireResourcesSignificantAugmentationCheckbox];
	[self makeCheckbox:_calFireResourcesVlatOrderCheckbox];
	[self makeCheckbox:_calFireResourcesVlatAssignedCheckbox];
	[self makeCheckbox:_calFireResourcesNoDivertCheckbox];
	[self makeCheckbox:_calFireResourcesLatAssignedCheckbox];
	[self makeCheckbox:_calFireResourcesAllReleasedCheckbox];
	// Marking required fields
	[self makeTextFieldRequired:_calFireIncidentTextField required:true];
	// Setting fields to clear their errors when modified
	[self makeTextFieldClearErrorWhenChanged:_calFireIncidentTextField];
	//---------------------------------------------------------------------------
	// Other Significant Info Fields
	//---------------------------------------------------------------------------
	// nothing to do for other significant info fields
	//---------------------------------------------------------------------------
	// Email Fields
	//---------------------------------------------------------------------------
	// nothing to do for email fields
	//---------------------------------------------------------------------------

	//==========================================================================
	//==========================================================================
	// Unhiding and setting up more involved field behaviors
	//==========================================================================
	//==========================================================================
	
	// Show all of the sections:
	[self hideAllFormSections:false];
	[self collapseAllSections];
	[self hideAllDropdownListsExcept:nil];
	
	//----------------------------------------------------------------------------
	// Hiding weather info for UPDATE or FINAL forms
	//----------------------------------------------------------------------------
	// NOTE - (4-25-2019) - Change in requirements, they want to see the weather
	// section on all form types
	/*if(_currentReportType == ROC_UPDATE || _currentReportType == ROC_FINAL)
	{
		[_weatherInfoHeaderView setHidden:true];
		[_weatherInfoContentView setHidden:true];
	}*/
	//----------------------------------------------------------------------------
	// Setting up the threats & evacs spinners to have the correct options
	//----------------------------------------------------------------------------
	
	// Threats options
	NSArray *threatsOptionsArrNonFinal = @[@"Yes",@"No",@"Mitigated"];
	NSArray *threatsOptionsArrFinal = @[@"No",@"Mitiged"];
	
	NSArray *threatOptionsArr = nil;
	
	if(_currentReportType == ROC_FINAL)
	{
		threatOptionsArr = threatsOptionsArrFinal;
	}
	else
	{
		threatOptionsArr = threatsOptionsArrNonFinal;
	}
	[self makeStringPickerTextField:_threatsEvacsTextField withOptions:threatOptionsArr andTitle:@"Evacuations:"];
	[self makeStringPickerTextField:_threatsStructuresTextField withOptions:threatOptionsArr andTitle:@"Structure Threats:"];
	[self makeStringPickerTextField:_threatsInfrastructureTextField withOptions:threatOptionsArr andTitle:@"Infrastructure Threats:"];
	
	//----------------------------------------------------------------------------
	// Setting up the threats & evacs textfields to have the correct suggestions
	//----------------------------------------------------------------------------
	
	[_threatsEvacsTextField addTarget:self
						  action:@selector(evacuationsSpinnerChanged)
				  forControlEvents:UIControlEventEditingDidEnd];
	
	[_threatsStructuresTextField addTarget:self
						  action:@selector(structureThreatsSpinnerChanged)
				  forControlEvents:UIControlEventEditingDidEnd];
	
	[_threatsInfrastructureTextField addTarget:self
						  action:@selector(infrastructureThreatsSpinnerChanged)
				  forControlEvents:UIControlEventEditingDidEnd];
	
	// The add button and stack views should be hidden at the beginning
	[_threatsEvacsInfoListStackView setHidden:true];
	[_threatsEvacsAddButton setHidden:true];
	[_threatsStructuresInfoListStackView setHidden:true];
	[_threatsStructuresAddButton setHidden:true];
	[_threatsInfrastructureInfoListStackView setHidden:true];
	[_threatsInfrastructureAddButton setHidden:true];
	
	//----------------------------------------------------------------------------
	// Setting up the other info textfields to have the correct suggestions
	//----------------------------------------------------------------------------
	
	if(_currentReportType != ROC_FINAL)
	{
		_otherInfoAutocompleteOptions =
  		@[
			@"Continued construction and improving control lines",
			@"Extensive mop up in oak woodlands",
			@"Crews are improving control lines",
			@"Ground resources continue to mop-up and strengthen control line",
			@"Suppression repair is under way",
			@"Fire is in remote location with difficult access",
			@"Access and terrain continue to hamper control efforts",
			@"Short range spotting causing erratic fire behavior",
			@"Medium range spotting observed",
			@"Long range spotting observed",
			@"Fire has spotted and is well established",
			@"Erratic winds, record high temperatures and low humidity are influencing fuels resulting in extreme fire behavior",
			@"Red Flag warning in effect in area",
			@"Minimal fire behavior observed",
			@"CAL FIRE and USFS in unified command",
			@"CAL FIRE Type 1 Incident Management Team ordered",
			@"Incident Management Team ordered",
			@"FMAG application initiated",
			@"FMAG has been submitted",
			@"FMAG application approved",
			@"No updated 209 data at time of report",
			@"CAL FIRE Mission Tasking has been approved"
		];
	}
	else
	{
		_otherInfoAutocompleteOptions = nil;
	}
	
	//----------------------------------------------------------------------------
	// Hiding the fuel types for FINAL ROC
	//----------------------------------------------------------------------------

	if(_currentReportType == ROC_FINAL)
	{
		[_vegFireFuelTypesView setHidden:true];
	}
	else
	{
		[_vegFireFuelTypesView setHidden:false];
	}
	
	// The other fuel type should always be hidden
	// Enabling the "Other Fuel Type" checkbox should display these
	[_vegFireOtherFuelTypeView setHidden:true];

	
	//----------------------------------------------------------------------------
	// Changing the Resource Commitment Section
	//----------------------------------------------------------------------------
	
	// By default, hide them all:
	[_calFireResourcesNoneCheckboxView setHidden:true];
	[_calFireResourcesAirCheckboxView setHidden:true];
	[_calFireResourcesGroundCheckboxView setHidden:true];
	[_calFireResourcesAirAndGroundCheckboxView setHidden:true];
	[_calFireResourcesAirAndGroundAugmentedCheckboxView setHidden:true];
	[_calFireResourcesAgencyRepOrderedCheckboxView setHidden:true];
	[_calFireResourcesAgencyRepAssignedCheckboxView setHidden:true];
	[_calFireResourcesSignificantAugmentationCheckboxView setHidden:true];
	[_calFireResourcesContinuedCheckboxView setHidden:true];
	[_calFireResourcesVlatOrderCheckboxView setHidden:true];
	[_calFireResourcesVlatAssignedCheckboxView setHidden:true];
	[_calFireResourcesNoDivertCheckboxView setHidden:true];
	[_calFireResourcesLatAssignedCheckboxView setHidden:true];
	[_calFireResourcesAllReleasedCheckboxView setHidden:true];
	
	
	// If NEW or UPDATE, most should be visible:
	if(_currentReportType == ROC_NEW || _currentReportType == ROC_UPDATE)
	{
		// Show most of the fields (except "all released" and "continued...")
		[_calFireResourcesNoneCheckboxView setHidden:false];
		[_calFireResourcesAirCheckboxView setHidden:false];
		[_calFireResourcesGroundCheckboxView setHidden:false];
		[_calFireResourcesAirAndGroundCheckboxView setHidden:false];
		[_calFireResourcesAirAndGroundAugmentedCheckboxView setHidden:false];
		[_calFireResourcesAgencyRepOrderedCheckboxView setHidden:false];
		[_calFireResourcesAgencyRepAssignedCheckboxView setHidden:false];
		[_calFireResourcesSignificantAugmentationCheckboxView setHidden:false];
		[_calFireResourcesVlatOrderCheckboxView setHidden:false];
		[_calFireResourcesVlatAssignedCheckboxView setHidden:false];
		[_calFireResourcesNoDivertCheckboxView setHidden:false];
		[_calFireResourcesLatAssignedCheckboxView setHidden:false];

		
		// If UPDATE, show an additional one:
		if(_currentReportType == ROC_UPDATE)
		{
			[_calFireResourcesContinuedCheckboxView setHidden:false];
		}
	}
	else
	{
		// If FINAL, only show one.
		[_calFireResourcesAllReleasedCheckboxView setHidden:false];
	}
}


- (void) clearAllFormFields
{
	
	//---------------------------------------------------------------------------
	// ROC Form Info Fields
	//---------------------------------------------------------------------------
	// This is called after the report type is changed
	// This method should not clear incident name and report type.
	//---------------------------------------------------------------------------
	// Incident Info Fields
	//---------------------------------------------------------------------------
	[_incidentNumberTextField setText:@""];

	// Clearing the incident type:
	[_incidentTypeViewController deselectAllCheckboxes];
	
	[_incidentLatitudeDegreesTextField setText:@""];
	[_incidentLatitudeMinutesTextField setText:@""];
	[_incidentLatitudeMinutesFractionTextField setText:@""];
	[_incidentLongitudeDegreesTextField setText:@""];
	[_incidentLongitudeMinutesTextField setText:@""];
	[_incidentLongitudeMinutesFractionTextField setText:@""];
	[_incidentStateField setText:@""];
	//---------------------------------------------------------------------------
	// ROC Incident Info Fields
	//---------------------------------------------------------------------------
	[_rocInitialCountyTextField setText:@""];
	[_rocAdditionalCountiesTextField setText:@""];
	[_rocLocationTextField setText:@""];
	[_rocStreetTextField setText:@""];
	[_rocCrossStreetTextField setText:@""];
	[_rocNearestCommunityTextField setText:@""];
	[_rocDistanceFromNearestCommunityTextField setText:@""];
	[_rocDirectionFromNearestCommunityTextField setText:@""];
	[_rocDPATextField setText:@""];
	[_rocOwnershipTextField setText:@""];
	[_rocJurisdictionTextField setText:@""];
	[_rocStartDateTextField setText:@""];
	[_rocStartTimeTextField setText:@""];
	//---------------------------------------------------------------------------
	// Vegetation Fire Incident Scope Fields
	//---------------------------------------------------------------------------
	[_vegFireAcreageTextField setText:@""];
	[_vegFireSpreadRateTextField setText:@""];
	// Checkboxes
	[_vegFireFuelTypeGrassCheckbox  setSelected:false];
	[_vegFireFuelTypeBrushCheckbox  setSelected:false];
	[_vegFireFuelTypeTimberCheckbox  setSelected:false];
	[_vegFireFuelTypeOakWoodlandCheckbox  setSelected:false];
	[_vegFireFuelTypeOtherCheckbox  setSelected:false];
	[_vegFireOtherFuelTypeTextField setText:@""];
	[_vegFirePercentContainedTextField setText:@""];
	//---------------------------------------------------------------------------
	// Weather Information Fields
	//---------------------------------------------------------------------------
	[_weatherTemperatureTextField setText:@""];
	[_weatherHumidityTextField setText:@""];
	[_weatherWindSpeedTextField setText:@""];
	[_weatherWindDirectionTextField setText:@""];
	[_weatherGustsTextField setText:@""];
	//---------------------------------------------------------------------------
	// Threats & Evacuations Fields
	//---------------------------------------------------------------------------
	[_threatsEvacsTextField setText:@""];
	[self clearTextFieldListStackView:_threatsEvacsInfoListStackView withHeightConstraint:_threatsEvacsListHeightConstraint];
	[_threatsStructuresTextField setText:@""];
	[self clearTextFieldListStackView:_threatsStructuresInfoListStackView withHeightConstraint:_threatsStructuresListHeightConstraint];
	[_threatsInfrastructureTextField setText:@""];
	[self clearTextFieldListStackView:_threatsInfrastructureInfoListStackView withHeightConstraint:_threatsInfrastructureListHeightConstraint];
	
	//---------------------------------------------------------------------------
	// Resource Commitment Fields
	//---------------------------------------------------------------------------
	[_calFireIncidentTextField setText:@""];
	// Checkboxes
	[_calFireResourcesNoneCheckbox  setSelected:false];
	[_calFireResourcesAirCheckbox  setSelected:false];
	[_calFireResourcesGroundCheckbox  setSelected:false];
	[_calFireResourcesAirAndGroundCheckbox  setSelected:false];
	[_calFireResourcesAirAndGroundAugmentedCheckbox  setSelected:false];
	[_calFireResourcesAgencyRepOrderedCheckbox  setSelected:false];
	[_calFireResourcesAgencyRepAssignedCheckbox  setSelected:false];
	[_calFireResourcesContinuedCheckbox  setSelected:false];
	[_calFireResourcesSignificantAugmentationCheckbox  setSelected:false];
	[_calFireResourcesVlatOrderCheckbox  setSelected:false];
	[_calFireResourcesVlatAssignedCheckbox  setSelected:false];
	[_calFireResourcesNoDivertCheckbox  setSelected:false];
	[_calFireResourcesLatAssignedCheckbox  setSelected:false];
	[_calFireResourcesAllReleasedCheckbox  setSelected:false];

	//---------------------------------------------------------------------------
	// Other Significant Info Fields
	//---------------------------------------------------------------------------
	[self clearTextFieldListStackView:_otherInfoListStackView withHeightConstraint:_otherInfoListHeightConstraint];
	
	//---------------------------------------------------------------------------
	// Email Fields
	//---------------------------------------------------------------------------
	[_emailTextField setText:@""];
	
	//---------------------------------------------------------------------------
}

- (void) reportTypeChanged
{
	NSLog(@"ROC Report type changed: %@",[_reportTypeTextField text]);
	
	NSString *reportType = [_reportTypeTextField text];
	
	if([reportType isEqualToString:@"NEW"])
	{
		_currentReportType = ROC_NEW;
	}
	else if([reportType isEqualToString:@"UPDATE"])
	{
		_currentReportType = ROC_UPDATE;
	}
	else if([reportType isEqualToString:@"FINAL"])
	{
		_currentReportType = ROC_FINAL;
	}
	else
	{
		// If unknown report type, don't do anything
		_currentReportType = ROC_NONE;
		return;
	}
	
	[self collapseAllSections];
	[self hideAllDropdownListsExcept:nil];
	[self clearAllFormFields];
	[self setupFormForReportType];

	//----------------------------------------------------------------------------
	// If we are NOT creating a new incident, make the incident info fields read-only:
	// else, make sure they are enabled
	//----------------------------------------------------------------------------
	
	
	[_incidentNumberTextField setEnabled:_creatingNewIncident];
	[_incidentLatitudeDegreesTextField setEnabled:_creatingNewIncident];
	[_incidentLatitudeMinutesTextField setEnabled:_creatingNewIncident];
	[_incidentLatitudeMinutesFractionTextField setEnabled:_creatingNewIncident];
	[_incidentLongitudeDegreesTextField setEnabled:_creatingNewIncident];
	[_incidentLongitudeMinutesTextField setEnabled:_creatingNewIncident];
	[_incidentLongitudeMinutesFractionTextField setEnabled:_creatingNewIncident];
	[_incidentStateField setEnabled:_creatingNewIncident];
	
	// Hide the incident locate button
	[_incidentLocateButton setHidden:!_creatingNewIncident];
	
	
	// Disabling the incident type checkboxes:
	_incidentTypeViewController.checkboxesEnabled = _creatingNewIncident;
	
	//----------------------------------------------------------------------------
	// If NEW, autopopulate start date with current date
	//----------------------------------------------------------------------------

	if(_currentReportType == ROC_NEW)
	{
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"MM/dd/yyyy"];
		[_rocStartDateTextField setText:[dateFormatter stringFromDate:[NSDate date]]];
	}
	
	//----------------------------------------------------------------------------
	// Populating the Email Text View
	//----------------------------------------------------------------------------
	[_emailTextField setText:[_dataManager getUsername]];
	
	//========================================================================
	// If we're already in an incident, set up the ROC form for that incident:
	//========================================================================
	if(_currentIncidentPayload != nil)
	{
		[self setupFormForIncident:_currentIncidentPayload];
	}
	
	//----------------------------------------------------------------------------
	// If we have incident location, autopopulate location fields:
	//----------------------------------------------------------------------------
	[self incidentLocationChanged];
	
	//----------------------------------------------------------------------------
	// If we have a previous ROC, autopopulate the fields that should carry over:
	//----------------------------------------------------------------------------
	
	if(_lastRocData != nil)
	{
		// Additional Affected Counties
		[_rocAdditionalCountiesTextField setText:_lastRocData.additionalAffectedCounties];
		
		// Fuel Type Checkboxes
		if([_lastRocData.fuelTypes containsObject:@"Grass"])
		{
			[_vegFireFuelTypeGrassCheckbox setSelected:true];
		}
		if([_lastRocData.fuelTypes containsObject:@"Brush"])
		{
			[_vegFireFuelTypeBrushCheckbox setSelected:true];
		}
		if([_lastRocData.fuelTypes containsObject:@"Timber"])
		{
			[_vegFireFuelTypeTimberCheckbox setSelected:true];
		}
		if([_lastRocData.fuelTypes containsObject:@"Oak Woodland"])
		{
			[_vegFireFuelTypeOakWoodlandCheckbox setSelected:true];
		}
		if([_lastRocData.fuelTypes containsObject:@"Other"])
		{
			[_vegFireFuelTypeOtherCheckbox setSelected:true];
			[_vegFireOtherFuelTypeTextField setText:_lastRocData.otherFuelTypes];
			[_vegFireOtherFuelTypeView setHidden:false];
		}
	}
}


// Populates the form with all ROC data from the parameter "data"
// Locks all fields to make it read-only
- (void) setFormToViewRocData:(ReportOnConditionData*)data
{
	NSLog(@"ROC - viewROC 1");
	NSLog(@"ROC - about to set form to view the roc paylod: %@",[data toSqlJson]);
	
	_currentReportType = ROC_NONE;
	
	if([data.reportType isEqualToString:@"NEW"])
	{
		_currentReportType = ROC_NEW;
	}
	else if([data.reportType isEqualToString:@"UPDATE"])
	{
		_currentReportType = ROC_UPDATE;
	}
	else if([data.reportType isEqualToString:@"FINAL"])
	{
		_currentReportType = ROC_FINAL;
	}
	
	// the incident name and report type fields:
	[_incidentNameLabelTextView setHidden:false];
	[_incidentNameTextField setHidden:false];
	[_reportTypeLabelTextView setHidden:false];
	[_reportTypeTextField setHidden:false];
	
	// Setting up the form for the current report type & disabling all fields
	[self setupFormForReportType];
	[self makeAllFieldsReadOnly];
	
	
	//=============================================================================
	// Section Variables
	// The following section sets the UI fields to display the ROC data in "data"
	//=============================================================================
	//---------------------------------------------------------------------------
	// ROC Form Info Fields
	//---------------------------------------------------------------------------
	[_incidentNameTextField setText:data.incidentname];
	[_reportTypeTextField setText:data.reportType];
	//---------------------------------------------------------------------------
	// Incident Info Fields
	//---------------------------------------------------------------------------
	// Incident number comes from the incident payload
	[_incidentNumberTextField setText:_currentIncidentPayload.incidentnumber];
	[_incidentTypeViewController setSelectedOptions:data.incidentTypes];
	
	double latitude = data.latitude;
	double longitude = data.longitude;
	
	[_incidentLatitudeDegreesTextField setText:[self getDegreeAsString:latitude]];
	[_incidentLatitudeMinutesTextField setText:[self getMinutesIntegerAsString:latitude]];
	[_incidentLatitudeMinutesFractionTextField setText:[self getMinutesFractionAsString:latitude]];
	// NOTE - we multiply the value by -1 because the UI has a hardcoded "-" sign in front of it
	// (all longitudes in california are in the -120 range, and the client doesn't want users to have to manually enter the "-" sign)
	[_incidentLongitudeDegreesTextField setText:[self getDegreeAsString:-1 * longitude]];
	[_incidentLongitudeMinutesTextField setText:[self getMinutesIntegerAsString:longitude]];
	[_incidentLongitudeMinutesFractionTextField setText:[self getMinutesFractionAsString:longitude]];
	
	[_incidentLocateButton setHidden:true];
	[_incidentStateField setText:data.incidentState];
	
	//---------------------------------------------------------------------------
	// ROC Incident Info Fields
	//---------------------------------------------------------------------------
	[_rocInitialCountyTextField setText:data.county];
	[_rocAdditionalCountiesTextField setText:data.additionalAffectedCounties];
	[_rocLocationTextField setText:data.location];
	[_rocStreetTextField setText:data.street];
	[_rocCrossStreetTextField setText:data.crossStreet];
	[_rocNearestCommunityTextField setText:data.nearestCommunity];
	[_rocDistanceFromNearestCommunityTextField setText:data.milesFromNearestCommunity];
	[_rocDirectionFromNearestCommunityTextField setText:data.directionFromNearestCommonity];
	[_rocDPATextField setText:data.dpa];
	[_rocOwnershipTextField setText:data.ownership];
	[_rocJurisdictionTextField setText:data.jurisdiction];
	
	// Create Date formatters for the start date and time
	NSDateFormatter *startDateFormatter = [NSDateFormatter new];
	[startDateFormatter setDateFormat:@"MM/dd/yyyy"];
	[_rocStartDateTextField setText:[startDateFormatter stringFromDate:data.startDate]];

	NSDateFormatter *startTimeFormatter = [NSDateFormatter new];
	[startTimeFormatter setDateFormat:@"HHmm"];
	[_rocStartTimeTextField setText:[startTimeFormatter stringFromDate:data.startTime]];

	//---------------------------------------------------------------------------
	// Vegetation Fire Incident Scope Fields
	//---------------------------------------------------------------------------
	[_vegFireAcreageTextField setText:data.acreage];
	[_vegFireSpreadRateTextField setText:data.spreadRate];
	
	NSLog(@"ROC - viewROC 2");

	
	
	NSArray<NSString*> *checkBoxStrings = @[@"Grass",@"Brush",@"Timber",@"Oak Woodland",@"Other"];
	NSArray<UIButton*> *checkBoxButtons = @[_vegFireFuelTypeGrassCheckbox, _vegFireFuelTypeBrushCheckbox, _vegFireFuelTypeTimberCheckbox, _vegFireFuelTypeOakWoodlandCheckbox, _vegFireFuelTypeOtherCheckbox];
	
	// If the data.fuel types contains the string, set the checkbox as selected:
	for(int i = 0; i < [checkBoxButtons count]; i++)
	{
		bool isSelected = [data.fuelTypes containsObject:[checkBoxStrings objectAtIndex:i]];
		[[checkBoxButtons objectAtIndex:i] setSelected:isSelected];
	}
	
	NSLog(@"ROC - viewROC 3");

	// Set the text of the other fuel type box,
	// this doesn't necessarily mean that we're going to show it, however
	[_vegFireOtherFuelTypeTextField setText:data.otherFuelTypes];

	// If "other" is selected, show the other fuel type fields
	if([_vegFireFuelTypeOtherCheckbox isSelected])
	{
		[_vegFireOtherFuelTypeView setHidden:false];
	}
	// otherwise, hide them
	else
	{
		[_vegFireOtherFuelTypeView setHidden:true];
	}
	
	
	[_vegFirePercentContainedTextField setText:data.percentContained];
	
	//---------------------------------------------------------------------------
	// Weather Information Fields
	//---------------------------------------------------------------------------
	[_weatherTemperatureTextField setText:data.temperature];
	[_weatherHumidityTextField setText:data.relHumidity];
	[_weatherWindSpeedTextField setText:data.windSpeed];
	[_weatherWindDirectionTextField setText:data.windDirection];
	[_weatherGustsTextField setText:data.windGusts];
	
	//---------------------------------------------------------------------------
	// Threats & Evacuations Fields
	// &
	// Other Significant Info Fields
	// (Handling these sections together to minimize code)
	//---------------------------------------------------------------------------
	[_threatsEvacsTextField setText:data.evacuations];
	[_threatsStructuresTextField setText:data.structureThreats];
	[_threatsInfrastructureTextField setText:data.infrastructureThreats];
	
	NSLog(@"ROC - viewROC 4");

		NSArray<UIStackView*> *stackViewsList = @[_threatsEvacsInfoListStackView,
									  _threatsStructuresInfoListStackView,
									  _threatsInfrastructureInfoListStackView,
									  _otherInfoListStackView];
	
	NSArray<NSArray<NSString*>*> *stackViewValuesList = @[data.evacuationsInProgress,
											    data.structureThreatsInProgress,
											    data.infrastructureThreatsInProgress,
											    data.otherThreatsAndEvacuationsInProgress];
	
	
	for(int i = 0; i < [stackViewsList count]; i++)
	{
		
		if([[stackViewValuesList objectAtIndex:i] count] > 0)
		{
			[[stackViewsList objectAtIndex:i] setHidden:false];
		}
		else
		{
			[[stackViewsList objectAtIndex:i] setHidden:true];
		}
	}
	
	NSLog(@"ROC - viewROC 5");

	
	//---------------------------------------------------
	// Adding the right amount of text boxes per section
	//---------------------------------------------------
	for(int i = 0; i < [data.evacuationsInProgress count]; i++)
	{
		[self threatsEvacsAddButtonPressed];
	}
	for(int i = 0; i < [data.structureThreatsInProgress count]; i++)
	{
		[self threatsStructuresAddButtonPressed];
	}
	for(int i = 0; i < [data.infrastructureThreatsInProgress count]; i++)
	{
		[self threatsInfrastructureAddButtonPressed];
	}
	for(int i = 0; i < [data.otherThreatsAndEvacuationsInProgress count]; i++)
	{
		[self otherInfoAddButtonPressed];
	}
	
	NSLog(@"ROC - viewROC 6");

	//---------------------------------------------------
	// Iterate through all sections
	// setting the UITextFields and hiding the "delete"
	// buttons
	//---------------------------------------------------

	for(int i = 0; i < [stackViewsList count]; i++)
	{
		UIStackView *stackView = [stackViewsList objectAtIndex:i];
		NSArray<NSString*> *stringValues = [stackViewValuesList objectAtIndex:i];
		
		// Only iterate through whichever we have fewer of, subviews or strings:
		int a = (int) [[stackView arrangedSubviews] count];
		int b = (int) [stringValues count];
		int jIterations = a < b ? a : b;
		
		for(int j = 0; j < jIterations; j++)
		{
			UIView *view = [[stackView arrangedSubviews] objectAtIndex:j];
			// Get the string value that we want to set
			NSString *stringValue = [stringValues objectAtIndex:j];
			
			// Iterating through the subview until we find the textiew and delete button
			for(UIView *subview in [view subviews])
			{
				// If we found the textview, set the contents
				if([subview isKindOfClass:[UITextField class]])
				{
					UITextField *textField = (UITextField*)subview;
					// TODO - auto-resize the text
					// or autoresize the height of the textfield to make it fit.
					//[textField resize]
					textField.adjustsFontSizeToFitWidth = true;
					[textField setMinimumFontSize:2];
					[textField setText:stringValue];
					[textField setEnabled:false];
				}
				// If we found the delete button, hide the button
				if([subview isKindOfClass:[UIButton class]])
				{
					UIButton *deleteButton = (UIButton*) subview;
					[deleteButton setEnabled:false];
				}
			}
		}
	}
	
	NSLog(@"ROC - viewROC 7");

	
	// FIXME - there is an index out of bounds exception (Attempted to get index 6 from an array with 6 elements)
	
	//---------------------------------------------------------------------------
	// Resource Commitment Fields
	//---------------------------------------------------------------------------
	[_calFireIncidentTextField setText:data.calfireIncident];
	
	
	NSArray<UIButton*> *resourceCheckBoxButtons = @[_calFireResourcesNoneCheckbox,
									 _calFireResourcesAirCheckbox,
									 _calFireResourcesGroundCheckbox,
									 _calFireResourcesAirAndGroundCheckbox,
									 _calFireResourcesAirAndGroundAugmentedCheckbox,
									 _calFireResourcesAgencyRepOrderedCheckbox,
									 _calFireResourcesAgencyRepAssignedCheckbox,
									 _calFireResourcesContinuedCheckbox,
									 _calFireResourcesSignificantAugmentationCheckbox,
									 _calFireResourcesVlatOrderCheckbox,
									 _calFireResourcesVlatAssignedCheckbox,
									 _calFireResourcesNoDivertCheckbox,
									 _calFireResourcesLatAssignedCheckbox,
									 _calFireResourcesAllReleasedCheckbox];
	
	NSArray<NSString*> *resourcesStrings = @[@"No CAL FIRE resources assigned",
								    @"CAL FIRE air resources assigned",
								    @"CAL FIRE ground resources assigned",
								    @"CAL FIRE air and ground resources assigned",
								    @"CAL FIRE air and ground resources augmented",
								    @"CAL FIRE Agency Rep ordered",
								    @"CAL FIRE Agency Rep assigned",
								    @"Continued commitment of CAL FIRE air and ground resources",
								    @"Significant augmentation of resources",
								    @"Very Large Air Tanker (VLAT) on order",
								    @"Very Large Air Tanker (VLAT) assigned",
								    @"No divert on Air Tankers for life safety",
								    @"Large Air Tanker (LAT) assigned",
								    @"All CAL FIRE air and ground resources released"];
	
	for(int i = 0; i < [resourceCheckBoxButtons count]; i++)
	{
		bool isSelected = [data.resourcesAssigned containsObject:[resourcesStrings objectAtIndex:i]];
		[[resourceCheckBoxButtons objectAtIndex:i] setSelected:isSelected];
	}
	
	NSLog(@"ROC - viewROC 8");
	
	//---------------------------------------------------------------------------
	// Email Fields
	//---------------------------------------------------------------------------
	[_emailTextField setText:data.email];
	NSLog(@"ROC - viewROC finished");

}

- (void) setFormToViewRocForIncident:(IncidentPayload *)incident
{
	[_incidentNameTextField setHidden:false];
	[_incidentNameLabelTextView setHidden:false];
	[_reportTypeTextField setHidden:false];
	[_reportTypeLabelTextView setHidden:false];
	
	// Hide the submit and cancel buttons
	[_cancelButton setHidden:true];
	[_submitButton setHidden:true];
	
	
	// Set the height of the button view to 0
	// This completely hides the button view, so that the scroll view
	// containing the actual ROC form
	// expands to take up the whole screen
	[_rocButtonsViewHeightConstraint setConstant:0];
	
	NSString *errorString = @"";
	bool error = false;
	_currentIncidentPayload = incident;
	ReportOnConditionData *latestIncidentROC = nil;
	
	if(_currentIncidentPayload == nil)
	{
		error = true;
		errorString = @"You must first join an incident to view ROC data.";
	}
	else
	{
		latestIncidentROC = [_dataManager getLastReportOnConditionForIncidentId:[incident incidentid]];
	}
	
	if(latestIncidentROC == nil)
	{
		error = true;
		errorString = [NSString stringWithFormat:@"No ROC data found for incident: %@.", [incident incidentname]];
	}
	
	if(error == true)
	{
		// Set the error message in the incidentname label
		[_incidentNameLabelTextView setText:errorString];
		
		// Hide the incidentname and report type fields:
		[_incidentNameTextField setHidden:true];
		[_reportTypeLabelTextView setHidden:true];
		[_reportTypeTextField setHidden:true];
		
		// Hiding all of the other sections and headers:
		[self hideAllFormSections:true];
		[self collapseAllSections];
		[self hideAllDropdownListsExcept:nil];
		return;
	}
	
	
	[self setFormToViewRocData:latestIncidentROC];
}

- (void) viewDidAppear:(BOOL) animated
{
	//========================================================================
	// If we're in viewing mode, set that up
	//========================================================================
	
	if(viewingMode == true)
	{
		// Before we do ANYTHING, we want to request ROCs from the server
		// Without this call, the latest ROC from the incident might not be available to the user
		
		// Verify that we have the current incident
		// Note: we're reaching into [DataManager getInstance] just in case our datamanager instance is nil
		// (this was happening randomly)
		_currentIncidentPayload = [[DataManager getInstance] currentIncident];
		NSLog(@"ROC - view ROC view ROC Getting ROCs for incident 1... incident payload: %@, incident number: %@",_currentIncidentPayload, [_currentIncidentPayload incidentid]);
		[RestClient getReportOnConditionsForIncidentId:[_currentIncidentPayload incidentid] offset:@0 limit:@0 completion:^(BOOL successful) {}];
	
		[self setFormToViewRocForIncident:_currentIncidentPayload];
		return;
	}

}

// A method to call setupView on the class singleton instance
+ (void) setupInstanceView
{
	if(instance == nil)
		return;
	
	[instance setupView];
}

// Called when the user pulls the ROC form down while viewing an ROC to fetch the latest ROC from the incident
- (void) refreshRequested:(UIRefreshControl*)refreshControl
{
	refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..." attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
	
	// Run this in the background:
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
	{
		[RestClient getReportOnConditionsForIncidentId:[_currentIncidentPayload incidentid] offset:@0 limit:@0 completion:^(BOOL successful)
		{
			// Sometimes the request finishes quickly, so wait for 1 second to clearly indicate to the user that their request to refresh data was processed
			[NSThread sleepForTimeInterval:0.5];
			
			// Once the RestClient is finished retrieving ROCs, call this...
			// Because this modifies UI elements, we need to run this code on the main queue:
			dispatch_async(dispatch_get_main_queue(), ^
			{
				
				// If RestClient was successful in retrieving ROCs:
				if(successful)
				{
					// Update the refresh view with the current date / time
					NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
					[formatter setDateFormat:@"MMM d, h:mm a"];
					NSString *lastUpdate = [NSString stringWithFormat:@"Last updated on %@", [formatter stringFromDate:[NSDate date]]];
					refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdate attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
				}
				[refreshControl endRefreshing];
				
				
				// Pull the latest ROC from the view
				[self setFormToViewRocForIncident:[[DataManager getInstance] currentIncident]];
			});
		}];
	});
}

// Called by viewDidLoad to set up the ROC
- (void) setupView
{
	_creatingNewIncident = false;
	_lastRocData = nil;
	
	// Allocating the array we're going to use to hold strong references to field delegates
	// (This is so they aren't garbage collected, "field.delegate = delegate" is only a weak reference)
	_delegatesArray = [[NSMutableArray alloc] init];
	
	//========================================================================
	// Getting required data from the data manager
	//========================================================================
	_dataManager = [DataManager getInstance];
	_allIncidentNames = [_dataManager getIncidentNamesList];
	_currentIncidentPayload = [_dataManager currentIncident];
	_successfullyGotAllWeatherData = false;

	//========================================================================
	// Setting up the scroll view so that it refreshes when the user pulls down
	//========================================================================
	UIRefreshControl *refreshControl = [UIRefreshControl new];
	[refreshControl addTarget:self action:@selector(refreshRequested:) forControlEvents:UIControlEventValueChanged];
	[refreshControl setTintColor:[UIColor whiteColor]];
	// Only add the refreshControl to the scroll view if we're in viewing mode.
	// (Only allow the user to refresh in view mode)

	
	//========================================================================
	// Hiding all of the form fields
	//========================================================================
	
	// Hiding the report type section:
	[_reportTypeLabelTextView setHidden:true];
	[_reportTypeTextField setHidden:true];
	
	// Hiding all sections and headers:
	[self hideAllFormSections:true];
	[self collapseAllSections];
	[self hideAllDropdownListsExcept:nil];
	[self hideAllErrors];
	
	//========================================================================
	// If we're in viewing mode,
	// hide all of the fields... then stop
	// Let viewDidAppear finish setting everything up
	//========================================================================
	
	if(viewingMode == true)
	{
		[_incidentNameTextField setHidden:true];
		[_incidentNameLabelTextView setHidden:true];
		[_reportTypeTextField setHidden:true];
		[_reportTypeLabelTextView setHidden:true];
		// Now we add the refreshcontrol to the scrollview
		[_topmostScrollView addSubview:refreshControl];
		return;
	}
	
	
	//========================================================================
	// Setting the incidentName logic
	//========================================================================
	
	// Adding the incident names as autocomplete entries for the text field
	[self makeAutocompleteTextField:_incidentNameTextField withOptions:_allIncidentNames];
	
	[_incidentNameTextField addTarget:self action:@selector(incidentNameChanged) forControlEvents:UIControlEventEditingChanged];
	[self makeTextFieldClearErrorWhenChanged:_incidentNameTextField];
	[self makeTextFieldRequired:_incidentNameTextField required:true];
	
	
	//========================================================================
	// Setting the reportType logic
	//========================================================================
	// reportTypeChanged finishes setting up the form
	[_reportTypeTextField addTarget:self action:@selector(reportTypeChanged) forControlEvents:UIControlEventEditingDidEnd];
	[self makeTextFieldRequired:_reportTypeTextField required:true];
	
	//========================================================================
	// If we're already in an incident, set up the ROC form for that incident:
	//========================================================================
	if(_currentIncidentPayload != nil)
	{
		NSLog(@"ROC - view ROC Getting ROCs for incident 2... incident payload: %@, incident number: %@",_currentIncidentPayload, [_currentIncidentPayload incidentid]);
		// First request the latest ROCs for the current incident
		// We need this so we can safely determine what report types to make available
		[RestClient getReportOnConditionsForIncidentId:[_currentIncidentPayload incidentid] offset:@0 limit:@0 completion:^(BOOL successful) {}];

		
		[_incidentNameTextField setText:_currentIncidentPayload.incidentname];
		// and lock incidentname, too
		[_incidentNameTextField setEnabled:false];
		
		// Call the method that finishes setting up the rest of the form based on the incident name
		[self incidentNameChanged];
	}

}

- (void) viewDidLoad
{
	[super viewDidLoad];
	instance = self;
	[self setupView];
}


// If "hidden" is set to true, this hides all form sections
// otherwise, this shows all form sections
- (void) hideAllFormSections:(bool)hidden
{
	[_incidentInfoHeaderView setHidden:hidden];
	[_rocIncidentInfoHeaderView setHidden:hidden];
	[_vegFireIncidentScopeHeaderView setHidden:hidden];
	[_weatherInfoHeaderView setHidden:hidden];
	[_threatsEvacsHeaderView setHidden:hidden];
	[_resourceCommitmentHeaderView setHidden:hidden];
	[_otherInfoHeaderView setHidden:hidden];
	[_emailHeaderView setHidden:hidden];
}



// Builds a UITapGestureRecognizer for use on each section
- (UITapGestureRecognizer*) newTapRecognizer
{
	return [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleCollapsibleSection:)];
}

// Called each time a section header is clicked
// Is responsible for toggling the visibility of the appropriate section
// and collapsing all other sections
- (void) toggleCollapsibleSection:(UIGestureRecognizer*)sender
{
	UIView *header = [sender view];
	UIView *section = nil;
	UIImageView *headerArrowImage = nil;
	int section_id = (int) header.tag;
	
	
	if(section_id == ID_SECTION_INCIDENT_INFO)
	{
		section = _incidentInfoContentView;
		headerArrowImage = _incidentInfoHeaderArrowImage;
	}
	else if(section_id == ID_SECTION_ROC_INFO)
	{
		section = _rocIncidentInfoContentView;
		headerArrowImage = _rocIncidentInfoHeaderArrowImage;
	}
	else if(section_id == ID_SECTION_VEG_FIRE)
	{
		section = _vegFireIncidentScopeContentView;
		headerArrowImage = _vegFireIncidentScopeHeaderArrowImage;
	}
	else if(section_id == ID_SECTION_WEATHER_INFO)
	{
		section = _weatherInfoContentView;
		headerArrowImage = _weatherInfoHeaderArrowImage;
	}
	else if(section_id == ID_SECTION_THREATS)
	{
		section = _threatsEvacsContentView;
		headerArrowImage = _threatsEvacsHeaderArrowImage;
	}
	else if(section_id == ID_SECTION_RESOURCES)
	{
		section = _resourceCommitmentContentView;
		headerArrowImage = _resourceCommitmentHeaderArrowImage;
	}
	else if(section_id == ID_SECTION_OTHER_INFO)
	{
		section = _otherInfoContentView;
		headerArrowImage = _otherInfoHeaderArrowImage;
	}
	else if(section_id == ID_SECTION_EMAIL)
	{
		section = _emailContentView;
		headerArrowImage = _emailHeaderArrowImage;
	}
	else
	{
		return;
	}
	
	
	// Also, hide the keyboard
	[self.view endEditing:true];
	
	
	// If the section is hidden, expand it
	BOOL expand = [section isHidden];
	
	
	
	
	//[self collapseAllSections];
	[self hideAllDropdownListsExcept:nil];
	
	if(expand)
	{
		[section setHidden:false];
		[headerArrowImage setImage:[UIImage imageNamed:@"up_arrow_transparent"]];
	}
	else
	{
		[section setHidden:true];
		[headerArrowImage setImage:[UIImage imageNamed:@"down_arrow_transparent"]];
	}
	
}


// Sets up a button to be a checkbox.
- (void) makeCheckbox:(UIButton*)button
{
	[button addTarget:self action:@selector(checkBoxTapped:) forControlEvents:UIControlEventTouchUpInside];
	[button setBackgroundImage:[UIImage imageNamed:@"checkbox"] forState:UIControlStateNormal];
	[button setBackgroundImage:[UIImage imageNamed:@"checkbox_checked"] forState:UIControlStateSelected];
	[button setBackgroundImage:[UIImage imageNamed:@"checkbox_checked"] forState:UIControlStateHighlighted];
	[button setBackgroundImage:[UIImage imageNamed:@"checkbox_checked"] forState:(UIControlStateDisabled | UIControlStateSelected)];
//	[button setBackgroundImage:[UIImage imageNamed:@"checkbox"] forState:UIControlStateDisabled];
	
	[button setSelected:false];
}

- (void) checkBoxTapped:(id) obj
{
	NSLog(@"ROC Checkbox tapped!");
	UIButton *checkbox = obj;
	[checkbox setSelected:![checkbox isSelected]];
	// Clear the error view, if set:
	[self clearViewError:checkbox];
}


- (void) makeOtherFuelTypeCheckbox:(UIButton*)button
{
	[self makeCheckbox:button];
	
	[button addTarget:self action:@selector(otherFuelTypeCheckboxTapped:) forControlEvents:UIControlEventTouchUpInside];
	
	// Hide the other fuel types box to start:
	[_vegFireOtherFuelTypeView setHidden:![button isSelected]];
}

- (void) otherFuelTypeCheckboxTapped:(id) obj
{
	// checkBoxTapped is also called as a target
	// so this method doesn't have to toggle whether the other fuel type checkbox is selected
	
	UIButton *checkbox = obj;
	// Toggle the visibility of the "other fuel type" field
	[_vegFireOtherFuelTypeView setHidden:![checkbox isSelected]];
	// Hide the other fuel type error:
	[self clearViewError:_vegFireOtherFuelTypeTextField];
}


// Makes the textField clear the bordercolor and border when modified to hide the error outline
- (void) makeTextFieldClearErrorWhenChanged:(UITextField*)textField
{
	[textField addTarget:self action:@selector(clearViewError:) forControlEvents:UIControlEventEditingChanged];
}

// Sets the placeholder text to "required" for required fields
// NOTE - this method doesn't actually mark the text field as required for form validation
// The validation logic is in the method areFormFieldsValid
- (void) makeTextFieldRequired:(UITextField*)textField required:(bool)required
{
	if(required)
	{
		textField.placeholder = @"required";
	}
	else
	{
		textField.placeholder = @"";
	}
	
	// NOTE - To change the placeholder text color:
	//[textField setValue:[UIColor colorWithWhite:0.3 alpha:1.0] forKeyPath:@"_placeholderLabel.textColor"];
}

// Collapses all report sections
- (void) collapseAllSections
{
	// Collapsing the views
	[_incidentInfoContentView setHidden:true];
	[_rocIncidentInfoContentView setHidden:true];
	[_vegFireIncidentScopeContentView setHidden:true];
	[_weatherInfoContentView setHidden:true];
	[_threatsEvacsContentView setHidden:true];
	[_resourceCommitmentContentView setHidden:true];
	[_otherInfoContentView setHidden:true];
	[_emailContentView setHidden:true];
	

	// Setting the icon to be the collapsed icon
	[_incidentInfoHeaderArrowImage setImage:[UIImage imageNamed:@"down_arrow_transparent"]];
	[_rocIncidentInfoHeaderArrowImage setImage:[UIImage imageNamed:@"down_arrow_transparent"]];
	[_vegFireIncidentScopeHeaderArrowImage setImage:[UIImage imageNamed:@"down_arrow_transparent"]];
	[_weatherInfoHeaderArrowImage setImage:[UIImage imageNamed:@"down_arrow_transparent"]];
	[_threatsEvacsHeaderArrowImage setImage:[UIImage imageNamed:@"down_arrow_transparent"]];
	[_resourceCommitmentHeaderArrowImage setImage:[UIImage imageNamed:@"down_arrow_transparent"]];
	[_otherInfoHeaderArrowImage setImage:[UIImage imageNamed:@"down_arrow_transparent"]];
	[_emailHeaderArrowImage setImage:[UIImage imageNamed:@"down_arrow_transparent"]];
}


// Hides all textfield dropdown lists
// doesn't hide the dropdown list of textField
- (void) hideAllDropdownListsExcept:(UITextField*)textField
{
	// Hiding all tableviews
	for(NSObject *obj in _delegatesArray)
	{
		if([obj class] == [TextFieldDropdownController class])
		{
			TextFieldDropdownController *textFieldController = (TextFieldDropdownController *)obj;
			
			// Don't hide the dropdown menu of the textField
			// whose dropdowncontroller we want to keep visible
			if(textFieldController.textField == textField)
				continue;
			
			[textFieldController hideDropDownMenu];
		}
	}
}



// Adds an autocomplete-textField and a delete button to the stackview
- (void) textFieldListAddButtonPressedForStackView:(UIStackView*)stackView
							    withOptions:(NSArray*)options
							 withConstraint:(NSLayoutConstraint*)constraint
						  withDeleteSelector:(SEL)deleteSelector
					  withAutocompleteOptions:(NSArray*)autocompleteOptions
{
	
	
	
	
	
	
	// Getting the stackview width:
	float superviewWidth = [stackView bounds].size.width;
	// Calculating the textview width
	CGRect buttonRect = CGRectMake(0,0,34.0,33.0);
	// Calculating textview_width: (15 = padding)
	CGRect textViewRect = CGRectMake(5, 0, (superviewWidth - (buttonRect.size.height + 15)), 35);
	// Calculating button_offset: ( 5 = padding)
	buttonRect.origin.x = textViewRect.origin.x + textViewRect.size.width + 5;
	// Calculating the container view bounds:
	CGRect newViewRect = CGRectMake(0.0, 0.0, superviewWidth, 35.0);
	
	//-------------------------------------------------------------------------
	// Creating the text view
	//-------------------------------------------------------------------------
	UITextField *newTextField = [[UITextField alloc] initWithFrame:textViewRect];
	[newTextField setAccessibilityHint:@"Hint text"];
	
	newTextField.layer.cornerRadius = 5;
	[newTextField setBackgroundColor:[UIColor whiteColor]];
	[newTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
	
	[self makeTextFieldRequired:newTextField required:true];
	[self makeTextFieldClearErrorWhenChanged:newTextField];
	
	//-------------------------------------------------------------------------
	// Creating the remove button
	//-------------------------------------------------------------------------
	UIButton *newButton = [[UIButton alloc] initWithFrame:buttonRect];
	[newButton setImage:[UIImage imageNamed:@"cross_symbol"] forState:UIControlStateNormal];
	[newButton setBackgroundColor:[UIColor colorWithRed:0.451 green:0.451 blue:0.451 alpha:1.0]];
	[newButton addTarget:self action:deleteSelector forControlEvents:UIControlEventTouchUpInside];

	//-------------------------------------------------------------------------
	// Creating the container view
	//-------------------------------------------------------------------------
	UIView *newView = [[UIView alloc] initWithFrame:newViewRect];
	//-------------------------------------------------------------------------
	
	// Adding the text and buttons to the new view:
	[newView addSubview:newTextField];
	[newView addSubview:newButton];
	
	// Adding the new view to the stackview:
	[stackView addArrangedSubview:newView];
	
	// Increasing the size of the box:
	constraint.constant += 45;
	
	// If the autocomplete options array is specified:
	// set up the autocomplete for the textView:
	if(autocompleteOptions != nil)
	{
		[self makeAutocompleteTextField:newTextField withOptions:autocompleteOptions];
	}
}

// Removes a child view from the stackview, and decreases the size of the stackview
- (void) textFieldListDeleteButtonPressed:(UIButton*)button forStackView:(UIStackView*)stackView withConstraint:(NSLayoutConstraint*)constraint
{
	// Get the view to remove from the StackView
	UIView *superview = button.superview;
	
	// Check if any of the textfields have a delegate that we need to remove
	for(UIView *view in [superview subviews])
	{
		// If the view is a textField, remove its delegate from our array
		if([view class] == [UITextField class])
		{
			UITextField *tf = (UITextField*) view;
			[_delegatesArray removeObject:tf.delegate];
		}
		[view removeFromSuperview];
	}
	
	// Remove the view from the stackview:
	[stackView removeArrangedSubview:superview];
	
	// Decrementing the stackview size:
	constraint.constant -= 45;
}


// Adds a new Evacuation textField
- (IBAction) threatsEvacsAddButtonPressed
{
	[self 	textFieldListAddButtonPressedForStackView:_threatsEvacsInfoListStackView
			withOptions:nil
			withConstraint:_threatsEvacsListHeightConstraint
			withDeleteSelector:@selector(threatsEvacsDeleteButtonPressed:)
	 		withAutocompleteOptions:_evacuationsAutocompleteOptions];
}

// Removes an Evacuation textField
- (void) threatsEvacsDeleteButtonPressed:(UIButton*)button
{
	[self 	textFieldListDeleteButtonPressed:button
			forStackView:_threatsEvacsInfoListStackView
			withConstraint:_threatsEvacsListHeightConstraint];
}


// Adds a new Structures textField
- (IBAction) threatsStructuresAddButtonPressed
{
	[self 	textFieldListAddButtonPressedForStackView:_threatsStructuresInfoListStackView
			withOptions:nil
			withConstraint:_threatsStructuresListHeightConstraint
			withDeleteSelector:@selector(threatsStructuresDeleteButtonPressed:)
	 		withAutocompleteOptions:_structureThreatsAutocompleteOptions];
}

// Removes an Structures textField
- (void) threatsStructuresDeleteButtonPressed:(UIButton*)button
{
	[self 	textFieldListDeleteButtonPressed:button
			forStackView:_threatsStructuresInfoListStackView
			withConstraint:_threatsStructuresListHeightConstraint];
}

// Adds a new Infrastructure textField
- (IBAction) threatsInfrastructureAddButtonPressed
{
	[self 	textFieldListAddButtonPressedForStackView:_threatsInfrastructureInfoListStackView
			withOptions:nil
			withConstraint:_threatsInfrastructureListHeightConstraint
			withDeleteSelector:@selector(threatsInfrastructureDeleteButtonPressed:)
			withAutocompleteOptions:_infrastructureThreatsAutocompleteOptions];
}

// Removes an Infrastructure textField
- (void) threatsInfrastructureDeleteButtonPressed:(UIButton*)button
{
	[self 	textFieldListDeleteButtonPressed:button
			forStackView:_threatsInfrastructureInfoListStackView
			withConstraint:_threatsInfrastructureListHeightConstraint];
}

// Adds a new Other info textField
- (IBAction) otherInfoAddButtonPressed
{
	[self 	textFieldListAddButtonPressedForStackView:_otherInfoListStackView
			withOptions:nil
			withConstraint:_otherInfoListHeightConstraint
			withDeleteSelector:@selector(otherInfoDeleteButtonPressed:)
	 		withAutocompleteOptions:_otherInfoAutocompleteOptions];
}

// Removes an Other Info textField
- (void) otherInfoDeleteButtonPressed:(UIButton*)button
{
	[self 	textFieldListDeleteButtonPressed:button
			forStackView:_otherInfoListStackView
			withConstraint:_otherInfoListHeightConstraint];
}


// Shows all error views (for testing purposes)
- (void) showAllErrors
{
	//============================================================
	// Hide the section header errors:
	//============================================================
	[_incidentInfoHeaderErrorImage setHidden:false];
	[_rocIncidentInfoHeaderErrorImage setHidden:false];
	[_vegFireIncidentScopeHeaderErrorImage setHidden:false];
	[_weatherInfoHeaderErrorImage setHidden:false];
	[_threatsEvacsHeaderErrorImage setHidden:false];
	[_resourceCommitmentHeaderErrorImage setHidden:false];
	[_otherInfoHeaderErrorImage setHidden:false];
	[_emailHeaderErrorImage setHidden:false];
	
	//============================================================
	// Hide the errors of each individual field:
	//============================================================
	//---------------------------------------------------------------------------
	// ROC Form Info Fields
	//---------------------------------------------------------------------------
	[self showViewError:_incidentNameTextField];
	[self showViewError:_reportTypeTextField];
	//---------------------------------------------------------------------------
	// Incident Info Fields
	//---------------------------------------------------------------------------
	[self showViewError:_incidentNumberTextField];
	[self showViewError:_incidentTypeTableView];
	[self showViewError:_incidentLatitudeDegreesTextField];
	[self showViewError:_incidentLatitudeMinutesTextField];
	[self showViewError:_incidentLatitudeMinutesFractionTextField];
	[self showViewError:_incidentLongitudeDegreesTextField];
	[self showViewError:_incidentLongitudeMinutesTextField];
	[self showViewError:_incidentLongitudeMinutesFractionTextField];
	[self showViewError:_incidentStateField];
	//---------------------------------------------------------------------------
	// ROC Incident Info Fields
	//---------------------------------------------------------------------------
	[self showViewError:_rocInitialCountyTextField];
	[self showViewError:_rocAdditionalCountiesTextField];
	[self showViewError:_rocLocationTextField];
	[self showViewError:_rocStreetTextField];
	[self showViewError:_rocCrossStreetTextField];
	[self showViewError:_rocNearestCommunityTextField];
	[self showViewError:_rocDistanceFromNearestCommunityTextField];
	[self showViewError:_rocDirectionFromNearestCommunityTextField];
	[self showViewError:_rocDPATextField];
	[self showViewError:_rocOwnershipTextField];
	[self showViewError:_rocJurisdictionTextField];
	[self showViewError:_rocStartDateTextField];
	[self showViewError:_rocStartTimeTextField];
	//---------------------------------------------------------------------------
	// Vegetation Fire Incident Scope Fields
	//---------------------------------------------------------------------------
	[self showViewError:_vegFireAcreageTextField];
	[self showViewError:_vegFireSpreadRateTextField];
	// Checkboxes
	[self showViewError:_vegFireFuelTypeGrassCheckbox];
	[self showViewError:_vegFireFuelTypeBrushCheckbox];
	[self showViewError:_vegFireFuelTypeTimberCheckbox];
	[self showViewError:_vegFireFuelTypeOakWoodlandCheckbox];
	[self showViewError:_vegFireFuelTypeOtherCheckbox];
	[self showViewError:_vegFireFuelTypesView];
	[self showViewError:_vegFireOtherFuelTypeTextField];
	[self showViewError:_vegFirePercentContainedTextField];
	//---------------------------------------------------------------------------
	// Weather Information Fields
	//---------------------------------------------------------------------------
	[self showViewError:_weatherTemperatureTextField];
	[self showViewError:_weatherHumidityTextField];
	[self showViewError:_weatherWindSpeedTextField];
	[self showViewError:_weatherWindDirectionTextField];
	[self showViewError:_weatherGustsTextField];
	//---------------------------------------------------------------------------
	// Threats & Evacuations Fields
	//---------------------------------------------------------------------------
	[self showViewError:_threatsEvacsTextField];
	// TODO - what error views should be shown?
	//[self showViewError:_threatsEvacsInfoListStackView];
	[self showViewError:_threatsEvacsInfoLabelTextView];
	
	[self showViewError:_threatsStructuresTextField];
	//[self showViewError:_threatsStructuresInfoListStackView];
	[self showViewError:_threatsStructuresInfoLabelTextView];
	
	[self showViewError:_threatsInfrastructureTextField];
	//[self showViewError:_threatsInfrastructureInfoListStackView];
	[self showViewError:_threatsInfrastructureInfoLabelTextView];
	//---------------------------------------------------------------------------
	// Resource Commitment Fields
	//---------------------------------------------------------------------------
	[self showViewError:_calFireIncidentTextField];
	// Checkboxes
	[self showViewError:_calFireResourcesNoneCheckbox];
	[self showViewError:_calFireResourcesAirCheckbox];
	[self showViewError:_calFireResourcesGroundCheckbox];
	[self showViewError:_calFireResourcesAirAndGroundCheckbox];
	[self showViewError:_calFireResourcesAirAndGroundAugmentedCheckbox];
	[self showViewError:_calFireResourcesAgencyRepOrderedCheckbox];
	[self showViewError:_calFireResourcesAgencyRepAssignedCheckbox];
	[self showViewError:_calFireResourcesContinuedCheckbox];
	[self showViewError:_calFireResourcesSignificantAugmentationCheckbox];
	[self showViewError:_calFireResourcesVlatOrderCheckbox];
	[self showViewError:_calFireResourcesVlatAssignedCheckbox];
	[self showViewError:_calFireResourcesNoDivertCheckbox];
	[self showViewError:_calFireResourcesLatAssignedCheckbox];
	[self showViewError:_calFireResourcesAllReleasedCheckbox];
	//---------------------------------------------------------------------------
	// Other Significant Info Fields
	//---------------------------------------------------------------------------
	//[self showViewError:_otherInfoListStackView];
	
	//---------------------------------------------------------------------------
	// Email Fields
	//---------------------------------------------------------------------------
	[self showViewError:_emailTextField];
	//---------------------------------------------------------------------------

	NSArray<UIStackView*> *stackViewList = @[_threatsEvacsInfoListStackView,
									_threatsStructuresInfoListStackView,
									_threatsInfrastructureInfoListStackView,
									_otherInfoListStackView];
	
	for(int i = 0; i < [stackViewList count]; i++)
	{
		for(UIView *view in [[stackViewList objectAtIndex:i] arrangedSubviews])
		{
			// Iterating through the subview until we find the textiew
			for(UIView *subview in [view subviews])
			{
				// If we found a textview:
				if([subview isKindOfClass:[UITextField class]])
				{
					// Clear the view's error:
					[self showViewError:subview];
				}
			}
		}
	}
	
}



// Hides all error views
- (void) hideAllErrors
{
	//============================================================
	// Hide the section header errors:
	//============================================================
	[_incidentInfoHeaderErrorImage setHidden:true];
	[_rocIncidentInfoHeaderErrorImage setHidden:true];
	[_vegFireIncidentScopeHeaderErrorImage setHidden:true];
	[_weatherInfoHeaderErrorImage setHidden:true];
	[_threatsEvacsHeaderErrorImage setHidden:true];
	[_resourceCommitmentHeaderErrorImage setHidden:true];
	[_otherInfoHeaderErrorImage setHidden:true];
	[_emailHeaderErrorImage setHidden:true];
	
	//============================================================
	// Hide the errors of each individual field:
	//============================================================
	//---------------------------------------------------------------------------
	// ROC Form Info Fields
	//---------------------------------------------------------------------------
	[self clearViewError:_incidentNameTextField];
	[self clearViewError:_reportTypeTextField];
	//---------------------------------------------------------------------------
	// Incident Info Fields
	//---------------------------------------------------------------------------
	[self clearViewError:_incidentNumberTextField];
	[self clearViewError:_incidentTypeTableView];
	[self clearViewError:_incidentLatitudeDegreesTextField];
	[self clearViewError:_incidentLatitudeMinutesTextField];
	[self clearViewError:_incidentLatitudeMinutesFractionTextField];
	[self clearViewError:_incidentLongitudeDegreesTextField];
	[self clearViewError:_incidentLongitudeMinutesTextField];
	[self clearViewError:_incidentLongitudeMinutesFractionTextField];
	[self clearViewError:_incidentStateField];
	//---------------------------------------------------------------------------
	// ROC Incident Info Fields
	//---------------------------------------------------------------------------
	[self clearViewError:_rocInitialCountyTextField];
	[self clearViewError:_rocAdditionalCountiesTextField];
	[self clearViewError:_rocLocationTextField];
	[self clearViewError:_rocStreetTextField];
	[self clearViewError:_rocCrossStreetTextField];
	[self clearViewError:_rocNearestCommunityTextField];
	[self clearViewError:_rocDistanceFromNearestCommunityTextField];
	[self clearViewError:_rocDirectionFromNearestCommunityTextField];
	[self clearViewError:_rocDPATextField];
	[self clearViewError:_rocOwnershipTextField];
	[self clearViewError:_rocJurisdictionTextField];
	[self clearViewError:_rocStartDateTextField];
	[self clearViewError:_rocStartTimeTextField];
	//---------------------------------------------------------------------------
	// Vegetation Fire Incident Scope Fields
	//---------------------------------------------------------------------------
	[self clearViewError:_vegFireAcreageTextField];
	[self clearViewError:_vegFireSpreadRateTextField];
	// Checkboxes
	[self clearViewError:_vegFireFuelTypeGrassCheckbox];
	[self clearViewError:_vegFireFuelTypeBrushCheckbox];
	[self clearViewError:_vegFireFuelTypeTimberCheckbox];
	[self clearViewError:_vegFireFuelTypeOakWoodlandCheckbox];
	[self clearViewError:_vegFireFuelTypeOtherCheckbox];
	[self clearViewError:_vegFireFuelTypesView];
	[self clearViewError:_vegFireOtherFuelTypeTextField];
	[self clearViewError:_vegFirePercentContainedTextField];
	//---------------------------------------------------------------------------
	// Weather Information Fields
	//---------------------------------------------------------------------------
	[self clearViewError:_weatherTemperatureTextField];
	[self clearViewError:_weatherHumidityTextField];
	[self clearViewError:_weatherWindSpeedTextField];
	[self clearViewError:_weatherWindDirectionTextField];
	[self clearViewError:_weatherGustsTextField];
	//---------------------------------------------------------------------------
	// Threats & Evacuations Fields
	//---------------------------------------------------------------------------
	[self clearViewError:_threatsEvacsTextField];
	// TODO - what error views should be shown?
	//[self clearViewError:_threatsEvacsInfoListStackView];
	[self clearViewError:_threatsEvacsInfoLabelTextView];
	
	[self clearViewError:_threatsStructuresTextField];
	//[self clearViewError:_threatsStructuresInfoListStackView];
	[self clearViewError:_threatsStructuresInfoLabelTextView];
	
	[self clearViewError:_threatsInfrastructureTextField];
	//[self clearViewError:_threatsInfrastructureInfoListStackView];
	[self clearViewError:_threatsInfrastructureInfoLabelTextView];
	//---------------------------------------------------------------------------
	// Resource Commitment Fields
	//---------------------------------------------------------------------------
	[self clearViewError:_calFireIncidentTextField];
	// Checkboxes
	[self clearViewError:_calFireResourcesNoneCheckbox];
	[self clearViewError:_calFireResourcesAirCheckbox];
	[self clearViewError:_calFireResourcesGroundCheckbox];
	[self clearViewError:_calFireResourcesAirAndGroundCheckbox];
	[self clearViewError:_calFireResourcesAirAndGroundAugmentedCheckbox];
	[self clearViewError:_calFireResourcesAgencyRepOrderedCheckbox];
	[self clearViewError:_calFireResourcesAgencyRepAssignedCheckbox];
	[self clearViewError:_calFireResourcesContinuedCheckbox];
	[self clearViewError:_calFireResourcesSignificantAugmentationCheckbox];
	[self clearViewError:_calFireResourcesVlatOrderCheckbox];
	[self clearViewError:_calFireResourcesVlatAssignedCheckbox];
	[self clearViewError:_calFireResourcesNoDivertCheckbox];
	[self clearViewError:_calFireResourcesLatAssignedCheckbox];
	[self clearViewError:_calFireResourcesAllReleasedCheckbox];
	//---------------------------------------------------------------------------
	// Other Significant Info Fields
	//---------------------------------------------------------------------------
	//[self clearViewError:_otherInfoListStackView];
	
	//---------------------------------------------------------------------------
	// Email Fields
	//---------------------------------------------------------------------------
	[self clearViewError:_emailTextField];
	//---------------------------------------------------------------------------
	
	NSArray<UIStackView*> *stackViewList = @[_threatsEvacsInfoListStackView,
									_threatsStructuresInfoListStackView,
									_threatsInfrastructureInfoListStackView,
									_otherInfoListStackView];
	
	
	for(int i = 0; i < [stackViewList count]; i++)
	{
		for(UIView *view in [[stackViewList objectAtIndex:i] arrangedSubviews])
		{
			// Iterating through the subview until we find the textiew
			for(UIView *subview in [view subviews])
			{
				// If we found a textview:
				if([subview isKindOfClass:[UITextField class]])
				{
					// Clear the view's error:
					[self clearViewError:subview];
				}
			}
		}
	}
}


- (void) clearViewError:(UIView*)view
{
	if(view == nil)
		return;
	
	view.layer.borderColor = UIColor.clearColor.CGColor;
	view.layer.borderWidth = 0.0f;
}

- (void) showViewError:(UIView*)view
{
	if(view == nil)
		return;
	
	view.layer.borderColor = UIColor.redColor.CGColor;
	view.layer.borderWidth = 2.0f;
}


// Does a regular expression pattern match to verify that string represents a valid double
- (bool) isValidDouble:(NSString*)string
{
	NSPredicate *predicate;
	predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES '^[-+]?[0-9]*\.?[0-9]+$'"];
	return [predicate evaluateWithObject:string];
}

// Does a regular expression pattern match to verify that string represents a valid integer
- (bool) isValidInt:(NSString*)string
{
	NSPredicate *predicate;
	predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES '^[-+]?[0-9]+$'"];
	return [predicate evaluateWithObject:string];
}

// Returns true if the string contains only whitespace
- (bool) isStringEmpty:(NSString*)string
{
	return [[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] < 1;
}

// Checks to make sure all required form fields are filled out and that the
// form is ready for submission
// Returns true if all required fields are filled and all entered data is valid
// Returns false if some input is malformed or a required field is missing
// 		If it returns false, this method also shows an error on the missing / malformed fields,
// 		and shows an error on the section itself
- (bool) areFormFieldsValid
{
	[self hideAllErrors];
	
	
	bool isFormValid = true;
	
	
	//-------------------------------------------------------------------------------------------------
	//-------------------------------------------------------------------------------------------------
	// Performing form data validation
	// (Ensuring all required fields are filled in and that filled in fields have valid data)
	//-------------------------------------------------------------------------------------------------
	//-------------------------------------------------------------------------------------------------
	//================================================
	// ROC Form Info Fields
	//================================================
	//--------------------------------
	// _incidentNameTextField
	// must not be empty, and must not be all whitespace
	// TODO - Are there additional requirements for incident name?
	//--------------------------------
	if([self isStringEmpty:[_incidentNameTextField text]])
	{
		[self showViewError:_incidentNameTextField];
		isFormValid = false;
	}
	
	//--------------------------------
	// _reportTypeTextField
	// Must be one of "NEW", "UPDATE", or "FINAL"
	//--------------------------------
	if(![@[@"NEW",@"UPDATE",@"FINAL"] containsObject:[_reportTypeTextField text]])
	{
		[self showViewError:_reportTypeTextField];
		isFormValid = false;
	}
	
	//================================================
	// Incident Info Fields
	//================================================
	bool isIncidentInfoValid = true;
	
	// Only validate this section if creating a new incident
	// Otherwise, these fields were autopopulated from incident details and not user-entered
	if(_creatingNewIncident)
	{
		//--------------------------------
		// _incidentNumberTextField
		// not required, no validation
		//--------------------------------
		
		//--------------------------------
		// incident type
		// at least one incident type is required
		//--------------------------------
		if([[_incidentTypeViewController getSelectedOptions] count] == 0)
		{
			[self showViewError:_incidentTypeTableView];
			isIncidentInfoValid = false;
			isFormValid = false;
		}
		
		//--------------------------------
		// location
		// lat / long all required:
		// lat degrees in [-89, 89]
		// lat minutes in [0, 60)
		// lon degrees in [-179, 179]
		// lon minutes in [0, 60)
		//--------------------------------
		//------------------
		// Latitude Degrees:
		//------------------
		if(![self isValidInt:[_incidentLatitudeDegreesTextField text]])
		{
			[self showViewError:_incidentLatitudeDegreesTextField];
			isIncidentInfoValid = false;
			isFormValid = false;
		}
		else
		{
			int latDeg = (int) [[_incidentLatitudeDegreesTextField text] doubleValue];
			if(latDeg < -89 || latDeg > 89)
			{
				[self showViewError:_incidentLatitudeDegreesTextField];
				isIncidentInfoValid = false;
				isFormValid = false;
			}
		}
		//------------------
		// Latitude Minutes:
		//------------------
		
		// Whole portion
		if(![self isValidInt:[_incidentLatitudeMinutesTextField text]])
		{
			[self showViewError:_incidentLatitudeMinutesTextField];
			isIncidentInfoValid = false;
			isFormValid = false;
		}
		else
		{
			int latMin = [[_incidentLatitudeMinutesTextField text] intValue];

			if(latMin < 0 || latMin >= 60)
			{
				[self showViewError:_incidentLatitudeMinutesTextField];
				isIncidentInfoValid = false;
				isFormValid = false;
			}
		}
		
		// Fraction portion
		//------------------
		// Latitude Minutes (fraction portion):
		// Can be any positive integer (any integer with an added decimal on the left is a valid double)
		// i.e. "12934142" with an added decimal becomes "0.12934142", which is valid
		//------------------
		if(![self isValidInt:[_incidentLatitudeMinutesFractionTextField text]])
		{
			[self showViewError:_incidentLatitudeMinutesFractionTextField];
			isIncidentInfoValid = false;
			isFormValid = false;
		}
		else
		{
			int latMinFraction = [[_incidentLatitudeMinutesFractionTextField text] intValue];
			if(latMinFraction < 0)
			{
				[self showViewError:_incidentLatitudeMinutesFractionTextField];
				isIncidentInfoValid = false;
				isFormValid = false;
			}
		}
		
		//------------------
		// Longitude Degrees:
		//------------------
		if(![self isValidInt:[_incidentLongitudeDegreesTextField text]])
		{
			[self showViewError:_incidentLongitudeDegreesTextField];
			isIncidentInfoValid = false;
			isFormValid = false;
		}
		else
		{
			int lonDeg = (int) [[_incidentLongitudeDegreesTextField text] doubleValue];
			if(lonDeg < -179 || lonDeg > 179)
			{
				[self showViewError:_incidentLongitudeDegreesTextField];
				isIncidentInfoValid = false;
				isFormValid = false;
			}
		}
		//------------------
		// Longitude Minutes:
		//------------------
		
		// Whole portion
		if(![self isValidInt:[_incidentLongitudeMinutesTextField text]])
		{
			[self showViewError:_incidentLongitudeMinutesTextField];
			isIncidentInfoValid = false;
			isFormValid = false;
		}
		else
		{
			int lonMin = [[_incidentLongitudeMinutesTextField text] intValue];
			
			if(lonMin < 0 || lonMin >= 60)
			{
				[self showViewError:_incidentLongitudeMinutesTextField];
				isIncidentInfoValid = false;
				isFormValid = false;
			}
		}
		
		// Fraction portion
		//------------------
		// Longitude Minutes (fraction portion):
		// Can be any positive integer (any integer with an added decimal on the left is a valid double)
		// i.e. "12934142" with an added decimal becomes "0.12934142", which is valid
		//------------------
		if(![self isValidInt:[_incidentLongitudeMinutesFractionTextField text]])
		{
			[self showViewError:_incidentLongitudeMinutesFractionTextField];
			isIncidentInfoValid = false;
			isFormValid = false;
		}
		else
		{
			int lonMinFraction = [[_incidentLongitudeMinutesFractionTextField text] intValue];
			if(lonMinFraction < 0)
			{
				[self showViewError:_incidentLongitudeMinutesFractionTextField];
				isIncidentInfoValid = false;
				isFormValid = false;
			}
		}
		//--------------------------------
		// _incidentStateField
		// Must not be empty or blank
		//--------------------------------
		if([self isStringEmpty:[_incidentStateField text]])
		{
			[self showViewError:_incidentStateField];
			isIncidentInfoValid = false;
			isFormValid = false;
		}
	}
	
	//-----------------------------------------------------
	//-----------------------------------------------------
	// If there was an error in the incident info section
	// show the error icon on the header
	//-----------------------------------------------------
	//-----------------------------------------------------
	if(!isIncidentInfoValid)
	{
		[_incidentInfoHeaderErrorImage setHidden:false];
	}
	
	//================================================
	// ROC Incident Info Fields
	//================================================
	
	bool isRocIncidentInfoValid = true;
	
	//--------------------------------
	// _rocInitialCountyTextField
	// Must not be empty or blank
	//--------------------------------
	if([self isStringEmpty:[_rocInitialCountyTextField text]])
	{
		[self showViewError:_rocInitialCountyTextField];
		isRocIncidentInfoValid = false;
		isFormValid = false;
	}
	
	//--------------------------------
	// _rocAdditionalCountiesTextField
	// Not required, no validation
	//--------------------------------

	//--------------------------------
	// _rocLocationTextField
	// Must not be empty or blank
	//--------------------------------
	if([self isStringEmpty:[_rocLocationTextField text]])
	{
		[self showViewError:_rocLocationTextField];
		isRocIncidentInfoValid = false;
		isFormValid = false;
	}
	
	//--------------------------------
	// _rocStreetTextField
	// Must not be empty or blank
	//--------------------------------
	if([self isStringEmpty:[_rocStreetTextField text]])
	{
		[self showViewError:_rocStreetTextField];
		isRocIncidentInfoValid = false;
		isFormValid = false;
	}
	
	//--------------------------------
	// _rocCrossStreetTextField
	// Must not be empty or blank
	//--------------------------------
	if([self isStringEmpty:[_rocCrossStreetTextField text]])
	{
		[self showViewError:_rocCrossStreetTextField];
		isRocIncidentInfoValid = false;
		isFormValid = false;
	}
	
	//--------------------------------
	// _rocNearestCommunityTextField
	// Must not be empty or blank
	//--------------------------------
	if([self isStringEmpty:[_rocNearestCommunityTextField text]])
	{
		[self showViewError:_rocNearestCommunityTextField];
		isRocIncidentInfoValid = false;
		isFormValid = false;
	}
	
	//--------------------------------
	// _rocDistanceFromNearestCommunityTextField
	// Must not be empty or blank
	//--------------------------------
	if([self isStringEmpty:[_rocDistanceFromNearestCommunityTextField text]])
	{
		[self showViewError:_rocDistanceFromNearestCommunityTextField];
		isRocIncidentInfoValid = false;
		isFormValid = false;
	}
	
	//--------------------------------
	// _rocDirectionFromNearestCommunityTextField
	// Must not be empty or blank
	//--------------------------------
	if([self isStringEmpty:[_rocDirectionFromNearestCommunityTextField text]])
	{
		[self showViewError:_rocDirectionFromNearestCommunityTextField];
		isRocIncidentInfoValid = false;
		isFormValid = false;
	}

	//--------------------------------
	// _rocDPATextField
	// Must not be empty or blank
	//--------------------------------
	if([self isStringEmpty:[_rocDPATextField text]])
	{
		[self showViewError:_rocDPATextField];
		isRocIncidentInfoValid = false;
		isFormValid = false;
	}
	
	//--------------------------------
	// _rocOwnershipTextField
	// Must not be empty or blank
	//--------------------------------
	if([self isStringEmpty:[_rocOwnershipTextField text]])
	{
		[self showViewError:_rocOwnershipTextField];
		isRocIncidentInfoValid = false;
		isFormValid = false;
	}

	//--------------------------------
	// _rocJurisdictionTextField
	// Must not be empty or blank
	//--------------------------------
	if([self isStringEmpty:[_rocJurisdictionTextField text]])
	{
		[self showViewError:_rocJurisdictionTextField];
		isRocIncidentInfoValid = false;
		isFormValid = false;
	}

	
	if(_currentReportType == ROC_NEW)
	{
		//--------------------------------
		// _rocStartDateTextField
		// Required if report type is NEW
		//--------------------------------
		if([self isStringEmpty:[_rocStartDateTextField text]])
		{
			[self showViewError:_rocStartDateTextField];
			isRocIncidentInfoValid = false;
			isFormValid = false;
		}
		
		//--------------------------------
		// _rocStartTimeTextField
		// Required if report type is NEW
		//--------------------------------
		if([self isStringEmpty:[_rocStartTimeTextField text]])
		{
			[self showViewError:_rocStartTimeTextField];
			isRocIncidentInfoValid = false;
			isFormValid = false;
		}
	}
	
	
	//-----------------------------------------------------
	//-----------------------------------------------------
	// If there was an error in the roc incident info section
	// show the error icon on the header
	//-----------------------------------------------------
	//-----------------------------------------------------
	if(!isRocIncidentInfoValid)
	{
		[_rocIncidentInfoHeaderErrorImage setHidden:false];
	}

	
	//================================================
	// Vegetation Fire Incident Scope Fields
	//================================================
	
	bool isVegFireInfoValid = true;
	
	bool vegFireFieldsRequired = false;
	
	// All of the fields are required IFF the incident is a Vegetation Fire
	if([[_incidentTypeViewController getSelectedOptions] containsObject:@"Fire (Wildland)"])
	{
		vegFireFieldsRequired = true;
	}
	
	
	//--------------------------------
	// _vegFireAcreageTextField
	// Required if vegFireFieldsRequired
	// If the fields are not empty, validate them to make sure the info is valid
	//--------------------------------

	// if it's required or the field is not empty, we must validate
	if(vegFireFieldsRequired || ![self isStringEmpty:[_vegFireAcreageTextField text]])
	{
		// Try to read it as double (it defaults to 0 if invalid)
		double acreage = [[_vegFireAcreageTextField text] doubleValue];
		
		// If it's not a valid double, or it's negative, then show an error
		if(![self isValidDouble:[_vegFireAcreageTextField text]] || acreage < 0.0)
		{
			[self showViewError:_vegFireAcreageTextField];
			isFormValid = false;
			isVegFireInfoValid = false;
		}
	}
	
	
	//--------------------------------
	// _vegFireSpreadRateTextField
	// Required if vegFireFieldsRequired
	//--------------------------------
	
	if(vegFireFieldsRequired)
	{
		if([self isStringEmpty:[_vegFireSpreadRateTextField text]])
		{
			[self showViewError:_vegFireSpreadRateTextField];
			isFormValid = false;
			isVegFireInfoValid = false;
		}
	}
	
	//--------------------------------
	// Vegetation Fire Fuel Types
	// If vegFireFieldsRequired, then at least ONE fuel type must be selected
	// if other is selected, the other fuel type textbox must not be empty
	//--------------------------------
	
	if(vegFireFieldsRequired)
	{
		do
		{
			// If any of the checkboxes are checked, then we're okay to proceed
			if([_vegFireFuelTypeGrassCheckbox isSelected])
			{
				break;
			}
			else if([_vegFireFuelTypeBrushCheckbox isSelected])
			{
				break;
			}
			else if([_vegFireFuelTypeTimberCheckbox isSelected])
			{
				break;
			}
			else if([_vegFireFuelTypeOakWoodlandCheckbox isSelected])
			{
				break;
			}
			else if([_vegFireFuelTypeOtherCheckbox isSelected])
			{
				break;
			}
			
			[self showViewError:_vegFireFuelTypesView];
			// If none of them are checked, we have an error
			isFormValid = false;
			isVegFireInfoValid = false;
		}
		while(false);
	}
	
	// If the "other fuel type" checkbox is selected, the other text box must not be empty
	if([_vegFireFuelTypeOtherCheckbox isSelected])
	{
		if([self isStringEmpty:[_vegFireOtherFuelTypeTextField text]])
		{
			[self showViewError:_vegFireOtherFuelTypeTextField];
			isFormValid = false;
			isVegFireInfoValid = false;
		}
	}
	
	
	//--------------------------------
	// _vegFirePercentContainedTextField
	// Required if vegFireFieldsRequired
	// If the fields are not empty, validate them to make sure the info is valid
	//--------------------------------
	
	// if it's required or the field is not empty, we must validate
	if(vegFireFieldsRequired || ![self isStringEmpty:[_vegFirePercentContainedTextField text]])
	{
		// Try to read it as double (it defaults to 0 if invalid)
		double percentContained = [[_vegFirePercentContainedTextField text] doubleValue];
		
		// If it's not a valid double, or it's negative, or > 100, then show an error
		if(![self isValidDouble:[_vegFirePercentContainedTextField text]] || percentContained < 0.0 || percentContained > 100.0)
		{
			[self showViewError:_vegFirePercentContainedTextField];
			isFormValid = false;
			isVegFireInfoValid = false;
		}
	}
	
	//-----------------------------------------------------
	//-----------------------------------------------------
	// If there was an error in the vegetation fire section
	// show the error icon on the header
	//-----------------------------------------------------
	//-----------------------------------------------------
	if(!isVegFireInfoValid)
	{
		[_vegFireIncidentScopeHeaderErrorImage setHidden:false];
	}
	
	//================================================
	// Weather Information Fields
	//================================================
	bool isWeatherInfoValid = true;
	
	
	//--------------------------------
	// _weatherTemperatureTextField
	// Should be a double, not required
	// if not empty, make sure it's a valid number
	//--------------------------------
	if(![self isStringEmpty:[_weatherTemperatureTextField text]])
	{
		if(![self isValidDouble:[_weatherTemperatureTextField text]])
		{
			[self showViewError:_weatherTemperatureTextField];
			isFormValid = false;
			isWeatherInfoValid = false;
		}
	}
	
	//--------------------------------
	// _weatherHumidityTextField
	// Should be a double, not required
	// if not empty, make sure it's a valid number
	// Relative Humidity should be >= 0.0
	//--------------------------------
	if(![self isStringEmpty:[_weatherHumidityTextField text]])
	{
		// Try to read it as a double (it defaults to 0 if invalid)
		double humidity = [[_weatherHumidityTextField text] doubleValue];
		
		// If it's not a valid double, or it's negative, then show an error
		if(![self isValidDouble:[_weatherHumidityTextField text]] || humidity < 0.0)
		{
			[self showViewError:_weatherHumidityTextField];
			isFormValid = false;
			isWeatherInfoValid = false;
		}
	}
	
	//--------------------------------
	// _weatherWindSpeedTextField
	// Should be a double, not required
	// if not empty, make sure it's a valid number
	// Wind speed should be >= 0.0
	//--------------------------------
	if(![self isStringEmpty:[_weatherWindSpeedTextField text]])
	{
		// Try to read it as a double (it defaults to 0 if invalid)
		double windSpeed = [[_weatherWindSpeedTextField text] doubleValue];
		
		// If it's not a valid double, or it's negative, then show an error
		if(![self isValidDouble:[_weatherWindSpeedTextField text]] || windSpeed < 0.0)
		{
			[self showViewError:_weatherWindSpeedTextField];
			isFormValid = false;
			isWeatherInfoValid = false;
		}
	}
	
	//--------------------------------
	// _weatherWindDirectionTextField
	// no requirements
	//--------------------------------
	
	
	//--------------------------------
	// _weatherGustsTextField
	// Should be a double, not required
	// if not empty, make sure it's a valid number
	// Wind gusts should be >= 0.0
	//--------------------------------
	
	if(![self isStringEmpty:[_weatherGustsTextField text]])
	{
		// Try to read it as a double (it defaults to 0 if invalid)
		double windGusts = [[_weatherGustsTextField text] doubleValue];
		
		// If it's not a valid double, or it's negative, then show an error
		if(![self isValidDouble:[_weatherGustsTextField text]] || windGusts < 0.0)
		{
			[self showViewError:_weatherGustsTextField];
			isFormValid = false;
			isWeatherInfoValid = false;
		}
	}
	
	//-----------------------------------------------------
	//-----------------------------------------------------
	// If there was an error in the weather info section
	// show the error icon on the header
	//-----------------------------------------------------
	//-----------------------------------------------------
	if(!isWeatherInfoValid)
	{
		[_weatherInfoHeaderErrorImage setHidden:false];
	}
	
	//================================================
	// Threats & Evacuations Fields
	// AND
	// Other Significant Info Fields
	// (I'm combining the two to minimize code)
	//================================================
	
	bool isThreatsInfoValid = true;
	bool isOtherInfoValid = true;
	
	// All of the fields are required IFF the incident is a Vegetation Fire
	// (we read vegFireFieldsRequired, which is set above)
	
	//--------------------------------
	// _threatsEvacsTextField
	// Required if vegFireFieldsRequired == true
	//--------------------------------
	if([self isStringEmpty:[_threatsEvacsTextField text]] && vegFireFieldsRequired)
	{
		[self showViewError:_threatsEvacsTextField];
		isFormValid = false;
		isThreatsInfoValid = false;
	}
	
	//--------------------------------
	// _threatsEvacsInfoListStackView
	// At least one textview is required if
	// _threatsEvacsTextField is "Yes" or "Mitigated"
	//--------------------------------
	if([[_threatsEvacsTextField text] isEqualToString:@"Yes"] || [[_threatsEvacsTextField text] isEqualToString:@"Mitigated"])
	{
		if([[_threatsEvacsInfoListStackView subviews] count] == 0)
		{
			// TODO - what error field should be shown?!
			[self showViewError:_threatsEvacsInfoLabelTextView];
			isThreatsInfoValid = false;
			isFormValid = false;
		}
	}

	//--------------------------------
	// _threatsStructuresTextField
	// Required if vegFireFieldsRequired == true
	//--------------------------------
	if([self isStringEmpty:[_threatsStructuresTextField text]] && vegFireFieldsRequired)
	{
		[self showViewError:_threatsStructuresTextField];
		isFormValid = false;
		isThreatsInfoValid = false;
	}
	//--------------------------------
	// _threatsStructuresInfoListStackView
	// At least one textview is required if
	// _threatsEvacsTextField is "Yes" or "Mitigated"
	//--------------------------------
	if([[_threatsStructuresTextField text] isEqualToString:@"Yes"] || [[_threatsStructuresTextField text] isEqualToString:@"Mitigated"])
	{
		if([[_threatsStructuresInfoListStackView subviews] count] == 0)
		{
			// TODO - what error field should be shown?!
			[self showViewError:_threatsStructuresInfoLabelTextView];
			isThreatsInfoValid = false;
			isFormValid = false;
		}
	}
	
	//--------------------------------
	// _threatsInfrastructureTextField
	// Required if vegFireFieldsRequired == true
	//--------------------------------
	if([self isStringEmpty:[_threatsInfrastructureTextField text]] && vegFireFieldsRequired)
	{
		[self showViewError:_threatsInfrastructureTextField];
		isFormValid = false;
		isThreatsInfoValid = false;
	}
	//--------------------------------
	// _threatsInfrastructureInfoListStackView
	// At least one textview is required if
	// _threatsEvacsTextField is "Yes" or "Mitigated"
	//--------------------------------
	if([[_threatsInfrastructureTextField text] isEqualToString:@"Yes"] || [[_threatsInfrastructureTextField text] isEqualToString:@"Mitigated"])
	{
		if([[_threatsInfrastructureInfoListStackView subviews] count] == 0)
		{
			// TODO - what error field should be shown?!
			[self showViewError:_threatsInfrastructureInfoLabelTextView];
			isThreatsInfoValid = false;
			isFormValid = false;
		}
	}
	
	
	// Validating all four stackviewlists at once (to minimize code)
	UIStackView *stackViewList[] =
	{
		_threatsEvacsInfoListStackView,
		_threatsStructuresInfoListStackView,
		_threatsInfrastructureInfoListStackView,
		_otherInfoListStackView
	};
	
	
	for(int i = 0; i < 4; i++)
	{
		// If a textview in a stackview is empty, show an error on it
		for(UIView *view in [stackViewList[i] arrangedSubviews])
		{
			// Iterating through the subview until we find the textiew
			for(UIView *subview in [view subviews])
			{
				// If we found a textview:
				if([subview isKindOfClass:[UITextField class]])
				{
					UITextView *textView = (UITextView*)subview;
					
					// If the textview is empty, show an error
					if([self isStringEmpty:[textView text]])
					{
						[self showViewError:textView];
						
						isFormValid = false;
						
						// The first three apply to the threats section
						if(i < 3)
						{
							isThreatsInfoValid = false;
						}
						// The last one applies to the other info section
						else
						{
							isOtherInfoValid = false;
						}
					}
				}
			}
		}
	}
	
	
	//-----------------------------------------------------
	//-----------------------------------------------------
	// If there was an error in the threats & evacs section
	// show the error icon on the header
	//-----------------------------------------------------
	//-----------------------------------------------------
	if(!isThreatsInfoValid)
	{
		[_threatsEvacsHeaderErrorImage setHidden:false];
	}
	
	//-----------------------------------------------------
	//-----------------------------------------------------
	// If there was an error in the other significant info section
	// show the error icon on the header
	//-----------------------------------------------------
	//-----------------------------------------------------
	if(!isOtherInfoValid)
	{
		[_otherInfoHeaderErrorImage setHidden:false];
	}
	
	
	//================================================
	// Resource Commitment Fields
	//================================================
	bool isResourcesInfoValid = true;
	
	//--------------------------------
	// _calFireIncidentTextField
	// Required
	//--------------------------------
	if([self isStringEmpty:[_calFireIncidentTextField text]])
	{
		[self showViewError:_calFireIncidentTextField];
		isFormValid = false;
		isResourcesInfoValid = false;
	}
	
	//--------------------------------
	// Resources Assigned Checkbox
	// no validation to be performed
	// (the checkboxes are not required)
	//--------------------------------
	
	//-----------------------------------------------------
	//-----------------------------------------------------
	// If there was an error in the resources assigned section
	// show the error icon on the header
	//-----------------------------------------------------
	//-----------------------------------------------------
	if(!isResourcesInfoValid)
	{
		[_resourceCommitmentHeaderErrorImage setHidden:false];
	}
	
	//================================================
	// Other Significant Info Fields
	//================================================
	// This section is validated alongside the Threats & Evacs section

	//================================================
	// Email Fields
	//================================================
	// no validation required here
	//================================================
	
	//-------------------------------------------------------------------------------------------------
	//-------------------------------------------------------------------------------------------------
	
	
	return isFormValid;
}

// Reads all form UI fields and populates a ReportOnConditionData object
// This method provides no data validation for fields
- (ReportOnConditionData*) formToRocData
{
	ReportOnConditionData *data = [ReportOnConditionData new];
	
	//================================================
	// Form metadata fields:
	//================================================
	
	// Set the current time as the creation time
	data.datecreated = [NSDate date];
	
	// Default the send status as waiting to send
	data.sendStatus = WAITING_TO_SEND;
	
	// If the current incident payload does not exist, this roc will create a new incident
	if(_currentIncidentPayload != nil)
	{
		data.isForNewIncident = false;
		data.incidentid = [_currentIncidentPayload.incidentid longValue];
	}
	else
	{
		data.isForNewIncident = true;
		data.incidentid = -1;
	}
	
	data.weatherDataAvailable = _successfullyGotAllWeatherData;
	
	//================================================
	// ROC Form Info Fields
	//================================================
	
	data.reportType = @"";
	
	if(_currentReportType == ROC_NEW)
	{
		data.reportType = @"NEW";
	}
	else if(_currentReportType == ROC_UPDATE)
	{
		data.reportType = @"UPDATE";
	}
	else if(_currentReportType == ROC_FINAL)
	{
		data.reportType = @"FINAL";
	}
	
	
	// Special incident name logic:
	// If we're creating a new incident, carefully format the incident name:
	// The incident name should be prefixed with the user's "org state" and "org prefix"
	// i.e. Taborda's org state is "CA"
	// Taborda's org prefix is "TAB"
	// Therefore, incidents created by users in the Taborda org should be prefixed with "CA
	if(data.isForNewIncident)
	{
		NSString *orgPrefix = @"";
		NSString *statePrefix = @"";
		
		OrganizationPayload *orgPayload = _dataManager.orgData;
		
		if(orgPayload != nil)
		{
			orgPrefix = [NSString stringWithFormat:@"%@ ", orgPayload.prefix];
			statePrefix = [NSString stringWithFormat:@"%@ ", orgPayload.state];
		}
		
		// Add the prefixes to the incident anme:
		data.incidentname = [NSString stringWithFormat:@"%@%@%@", statePrefix, orgPrefix, [_incidentNameTextField text]];
	}
	// If it's not creating a new incident, the incident name should already have the prefixes
	else
	{
		data.incidentname = [_incidentNameTextField text];
	}
	
	//================================================
	// Incident Info Fields
	//================================================

	// Creating the incidentTypes array
	NSMutableArray<NSString*> *incidentTypes = [NSMutableArray<NSString*> new];
	NSArray *selectedIncidentTypes = [_incidentTypeViewController getSelectedOptions];
	
	// Iterate through the selected Incident Types, adding them to the array
	for(id obj in selectedIncidentTypes)
	{
		if(obj == nil)
			continue;
		
		if([obj isKindOfClass:[NSString class]])
		{
			[incidentTypes addObject:(NSString*)obj];
		}
	}
	data.incidentTypes = incidentTypes;
	
	
	// Parse the location from the textfields
	int latDeg = (int) [[_incidentLatitudeDegreesTextField text] doubleValue];
	double latMinWhole = [[_incidentLatitudeMinutesTextField text] doubleValue];
	double latMinFraction = [[NSString stringWithFormat:@"0.%@",[_incidentLatitudeMinutesFractionTextField text]] doubleValue];
	double latMin = latMinWhole + latMinFraction;
	
	// NOTE - we multiply the value by -1 because the UI has a hardcoded "-" sign in front of it
	// (all longitudes in california are in the -120 range, and the client doesn't want users to have to manually enter the "-" sign)
	int lonDeg = -1 * (int) [[_incidentLongitudeDegreesTextField text] doubleValue];
	double lonMinWhole = [[_incidentLongitudeMinutesTextField text] doubleValue];
	double lonMinFraction = [[NSString stringWithFormat:@"0.%@",[_incidentLongitudeMinutesFractionTextField text]] doubleValue];
	double lonMin = lonMinWhole + lonMinFraction;
		
	// Convert them to Decimal Degrees
	double latitude = [self toDecimalDegrees:latDeg minutes:latMin];
	double longitude = [self toDecimalDegrees:lonDeg minutes:lonMin];
	
	data.latitude = latitude;
	data.longitude = longitude;
	data.incidentState = [_incidentStateField text];
	data.incidentnumber = [_incidentNumberTextField text];
	
	//================================================
	// ROC Incident Info Fields
	//================================================
	data.county = [_rocInitialCountyTextField text];
	data.additionalAffectedCounties = [_rocAdditionalCountiesTextField text];
	data.location = [_rocLocationTextField text];
	data.street = [_rocStreetTextField text];
	data.crossStreet = [_rocCrossStreetTextField text];
	data.nearestCommunity = [_rocNearestCommunityTextField text];
	data.milesFromNearestCommunity = [_rocDistanceFromNearestCommunityTextField text];
	data.directionFromNearestCommonity = [_rocDirectionFromNearestCommunityTextField text];
	data.dpa = [_rocDPATextField text];
	data.ownership = [_rocOwnershipTextField text];
	data.jurisdiction = [_rocJurisdictionTextField text];
	
	// Parsing the start date and time:
	NSDateFormatter *startDateFormatter = [NSDateFormatter new];
	[startDateFormatter setDateFormat:@"MM/dd/yyyy"];
	data.startDate = [startDateFormatter dateFromString:[_rocStartDateTextField text]];
	// If unable to parse, default to current date & time
	if(data.startDate == nil)
	{
		data.startDate = [NSDate date];
	}

	NSDateFormatter *startTimeFormatter = [NSDateFormatter new];
	[startTimeFormatter setDateFormat:@"HHmm"];
	data.startTime = [startTimeFormatter dateFromString:[_rocStartTimeTextField text]];
	// If unable to parse, default to current date & time
	if(data.startTime == nil)
	{
		data.startTime = [NSDate date];
	}
	
	//================================================
	// Vegetation Fire Incident Scope Fields
	//================================================
	data.acreage = [_vegFireAcreageTextField text];
	data.spreadRate = [_vegFireSpreadRateTextField text];
	
	NSMutableArray<NSString*> *fuelTypes = [NSMutableArray<NSString*> new];
	if([_vegFireFuelTypeGrassCheckbox isSelected])
	{
		[fuelTypes addObject:@"Grass"];
	}
	if([_vegFireFuelTypeBrushCheckbox isSelected])
	{
		[fuelTypes addObject:@"Brush"];
	}
	if([_vegFireFuelTypeTimberCheckbox isSelected])
	{
		[fuelTypes addObject:@"Timber"];
	}
	if([_vegFireFuelTypeOakWoodlandCheckbox isSelected])
	{
		[fuelTypes addObject:@"Oak Woodland"];
	}
	if([_vegFireFuelTypeOtherCheckbox isSelected])
	{
		[fuelTypes addObject:@"Other"];
		data.otherFuelTypes = [_vegFireOtherFuelTypeTextField text];
	}
	else
	{
		data.otherFuelTypes = @"";
	}
	
	data.fuelTypes = fuelTypes;
	
	data.percentContained = [_vegFirePercentContainedTextField text];
	
	//================================================
	// Weather Information Fields
	//================================================
	data.temperature = [_weatherTemperatureTextField text];
	data.relHumidity = [_weatherHumidityTextField text];
	data.windSpeed = [_weatherWindSpeedTextField text];
	data.windDirection = [_weatherWindDirectionTextField text];
	data.windGusts = [_weatherGustsTextField text];
	
	//================================================
	// Threats & Evacuations Fields
	// &
	// Other Significant Info Fields
	// (combining the two sections because they share code that handles them)
	//================================================
	data.evacuations = [_threatsEvacsTextField text];
	data.structureThreats = [_threatsStructuresTextField text];
	data.infrastructureThreats = [_threatsInfrastructureTextField text];
	// This field was removed from the UI
	//data.otherThreatsAndEvacuations =
	
	
	// To populate the data for "Threats & Evacs" / "Other Significant info"
	// We're going to iterate over all four and build up the string arrays
	NSArray<UIStackView*> *stackViewList = [NSArray<UIStackView*>
									arrayWithObjects:
									_threatsEvacsInfoListStackView,
									_threatsStructuresInfoListStackView,
									_threatsInfrastructureInfoListStackView,
									_otherInfoListStackView,
									nil];
	
	NSArray<NSString*> *objectKeyNames = [NSArray<NSString*>
									arrayWithObjects:
									@"evacuationsInProgress",
									@"structureThreatsInProgress",
									@"infrastructureThreatsInProgress",
									@"otherThreatsAndEvacuationsInProgress",
									nil];
	
	
	
	for(int i = 0; i < [objectKeyNames count]; i++)
	{
		NSMutableArray<NSString*> *resultValues = [NSMutableArray<NSString*> new];
		
		
		// Iterate over each of the textviews in each of the stackviews:
		for(UIView *containerView in [stackViewList[i] arrangedSubviews])
		{
			// One of the subviews will be a UITextField
			for(UIView *subview in [containerView subviews])
			{
				if([subview isKindOfClass:[UITextField class]])
				{
					UITextField *textField = (UITextField*)subview;
					// We found the text field, add its contents to our list
					[resultValues addObject:[textField text]];
				}
			}
		}
		
		
		// After building the array, assign it to the ROC data object:
		[data setValue:resultValues forKey:[objectKeyNames objectAtIndex:i]];
	}
	
	
	//================================================
	// Resource Commitment Fields
	//================================================
	
	data.calfireIncident = [_calFireIncidentTextField text];
	
	// Iterate over all resources checkboxes and add the text of selected buttons to an array
	NSMutableArray<NSString*> *resourcesAssigned = [NSMutableArray<NSString*> new];
	
	NSArray<UIButton*> *resourcesButtons = @[_calFireResourcesNoneCheckbox,
									_calFireResourcesAirCheckbox,
									_calFireResourcesGroundCheckbox,
									_calFireResourcesAirAndGroundCheckbox,
									_calFireResourcesAirAndGroundAugmentedCheckbox,
									_calFireResourcesAgencyRepOrderedCheckbox,
									_calFireResourcesAgencyRepAssignedCheckbox,
									_calFireResourcesContinuedCheckbox,
									_calFireResourcesSignificantAugmentationCheckbox,
									_calFireResourcesVlatOrderCheckbox,
									_calFireResourcesVlatAssignedCheckbox,
									_calFireResourcesNoDivertCheckbox,
									_calFireResourcesLatAssignedCheckbox,
									_calFireResourcesAllReleasedCheckbox];
	
	NSArray<NSString*> *resourcesNames = @[@"No CAL FIRE resources assigned",
								   @"CAL FIRE air resources assigned",
								   @"CAL FIRE ground resources assigned",
								   @"CAL FIRE air and ground resources assigned",
								   @"CAL FIRE air and ground resources augmented",
								   @"CAL FIRE Agency Rep ordered",
								   @"CAL FIRE Agency Rep assigned",
								   @"Continued commitment of CAL FIRE air and ground resources",
								   @"Significant augmentation of resources",
								   @"Very Large Air Tanker (VLAT) on order",
								   @"Very Large Air Tanker (VLAT) assigned",
								   @"No divert on Air Tankers for life safety",
								   @"Large Air Tanker (LAT) assigned",
								   @"All CAL FIRE air and ground resources released"];

	
	for(int i = 0; i < [resourcesButtons count]; i++)
	{
		if([resourcesButtons objectAtIndex:i] != nil)
		{
			if([[resourcesButtons objectAtIndex:i] isSelected])
			{
				[resourcesAssigned addObject:[resourcesNames objectAtIndex:i]];
			}
		}
	}
	
	data.resourcesAssigned = resourcesAssigned;
	
	//================================================
	// Email Fields
	//================================================
	data.email = [_emailTextField text];
	
	return data;
}

- (IBAction)submitReportButtonPressed:(UIButton *)button
{
	//[self hideAllErrors];
	bool formValid = [self areFormFieldsValid];
	
	if(!formValid)
		return;
	
	ReportOnConditionData *formRocData = [self formToRocData];
	formRocData.sendStatus = WAITING_TO_SEND;
	
	// Add the ROC to the store & forward table, NOTE: this dispatches
	// the RestClient to push ROCs to the server, no additional calls are required here.
	[_dataManager addReportOnConditionToStoreAndForward:formRocData];
	
	// Take the user back to the previous screen
	[self cancelButtonPressed:nil];
}


- (IBAction)cancelButtonPressed:(UIButton *)button
{
	// If we're on iPad, take them back to the view scene
	if([_dataManager isIpad])
	{
		[IncidentCanvasUIViewController goToReportOnConditionAction];
		return;
	}
	
	[self.navigationController popViewControllerAnimated:YES];
}


// Sets up a textfield to be an autocomplete text field
// This method creates a delegate for the text field, and adds it to our
// list of delegates
// (We keep a list of delegates so that we have a strong reference to each
// delegate, otherwise they will be garbage collected)
// (UIViews keep weak references to delegates to avoid reference cycles)
- (void) makeAutocompleteTextField:(UITextField*)textField withOptions:(NSArray*)options
{
	// Creating a new delegate for the textFiel
	TextFieldDropdownController *dropdownController = [[TextFieldDropdownController alloc] initForTextField:textField withOptions:options];
	
	// Clean up the textField's previous delegate, if it exists
	[self cleanUpDelegateForTextField:textField];
	
	// Assigning the delegate
	[textField setDelegate:dropdownController];
	
	// Holding a strong reference to the delegate to avoid garbage collection
	[_delegatesArray addObject:dropdownController];
}

// Sets up a textField to be a date picker field
// This method creates a delegate for the text field, and adds it to our
// list of deleges
// (We keep a list of delegates so that we have a strong reference to each
// delegate, otherwise they will be garbage collected)
// (UIViews keep weak references to delegates to avoid reference cycles)
- (void) makeDatePicker:(UITextField*)textField
{
	// Create the controller
	DateTimePickerController *controller = [[DateTimePickerController alloc] initForTextField:textField andView:self isTime:false];
	
	// Clean up the textField's previous delegate, if it exists
	[self cleanUpDelegateForTextField:textField];
	
	// Assign the delegate
	[textField setDelegate:controller];

	// Hold a reference to the view controller
	[_delegatesArray addObject:controller];
}

- (void) makeTimePicker:(UITextField*)textField
{
	// Create the controller
	DateTimePickerController *controller = [[DateTimePickerController alloc] initForTextField:textField andView:self isTime:true];
	
	// Clean up the textField's previous delegate, if it exists
	[self cleanUpDelegateForTextField:textField];
	
	// Assign the delegate
	[textField setDelegate:controller];
	
	// Hold a reference to the view controller
	[_delegatesArray addObject:controller];
}


// Checks if the field's delegate is in our delegates array, if so, remove it.
- (void) cleanUpDelegateForTextField:(UITextField*)textField
{
	if([textField delegate] == nil)
		return;
	
	[_delegatesArray removeObject:[textField delegate]];
}

- (void) cleanUpDelegateForTableView:(UITableView *)tableView
{
	if([tableView delegate] == nil)
	return;
	
	[_delegatesArray removeObject:[tableView delegate]];
}

- (void) makeStringPickerTextField:(UITextField *)textField
				   withOptions:(NSArray*)options
					andTitle:(NSString*)title
{
	// Create the controller
	StringPickerViewController *viewController = [[StringPickerViewController alloc] initForTextField:textField withOptions:options viewController:self withTitle:title];
	
	// Clean up the textField's previous delegate, if it exists
	[self cleanUpDelegateForTextField:textField];
	
	// Assign the textField's delegate:
	[textField setDelegate:viewController];
	
	// Hold a reference to the view controller:
	[_delegatesArray addObject:viewController];
}

@end












































