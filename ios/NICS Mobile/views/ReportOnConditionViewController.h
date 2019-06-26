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
//  ReportOnConditionViewController.h
//  SCOUT Mobile
//

#import "DataManager.h"
#import "Fields/TextFieldDropdownController.h"
#import "Fields/CheckBoxTableViewController.h"
#import "Fields/StringPickerViewController.h"
#import "Fields/DateTimePickerController.h"


@interface ReportOnConditionViewController : UIViewController <UISplitViewControllerDelegate, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>


// Static function to set the viewing mode for ReportOnConditionViewController
// true - loads the current incident's latest ROC and displays it
// false - shows the blank form for creating a new ROC
+ (void) setViewControllerViewingMode:(bool)mode;

// Called by viewDidLoad to set up the ROC
- (void) setupView;
// A method to call setupView on the class singleton instance
+ (void) setupInstanceView;

// Called when the user pulls the ROC form down while viewing an ROC to fetch the latest ROC from the incident
- (void) refreshRequested:(UIRefreshControl*)refreshControl;
//=============================================================================
// Info
//=============================================================================
@property DataManager *dataManager;
@property NSArray<NSString*> *allIncidentNames;
@property IncidentPayload *currentIncidentPayload;


// Holds the type of the last ROC submitted for the current incident
// one of {ROC_NONE, ROC_NON_FINAL, ROC_FINAL}
@property int lastIncidentReportType;
// Holds the type of the current ROC
// one of {ROC_NEW, ROC_UPDATE, ROC_FINAL}
@property int currentReportType;
// Whether or not the new ROC form will create a new incident on submission
@property bool creatingNewIncident;

// Whether or not the request for location-based weather data was successful
@property bool successfullyGotAllWeatherData;

// The last ROC that was submitted for this incident
@property ReportOnConditionData *lastRocData;

@property IBOutlet UIScrollView *topmostScrollView;

//=============================================================================
// Section Headers / Views
//=============================================================================
@property IBOutlet UIView *incidentInfoHeaderView;
@property IBOutlet UIImageView *incidentInfoHeaderArrowImage;
@property IBOutlet UIView *incidentInfoContentView;
@property IBOutlet UIImageView *incidentInfoHeaderErrorImage;

@property IBOutlet UIView *rocIncidentInfoHeaderView;
@property IBOutlet UIImageView *rocIncidentInfoHeaderArrowImage;
@property IBOutlet UIView *rocIncidentInfoContentView;
@property IBOutlet UIImageView *rocIncidentInfoHeaderErrorImage;

@property IBOutlet UIView *vegFireIncidentScopeHeaderView;
@property IBOutlet UIImageView *vegFireIncidentScopeHeaderArrowImage;
@property IBOutlet UIView *vegFireIncidentScopeContentView;
@property IBOutlet UIImageView *vegFireIncidentScopeHeaderErrorImage;

@property IBOutlet UIView *weatherInfoHeaderView;
@property IBOutlet UIImageView *weatherInfoHeaderArrowImage;
@property IBOutlet UIView *weatherInfoContentView;
@property IBOutlet UIImageView *weatherInfoHeaderErrorImage;

@property IBOutlet UIView *threatsEvacsHeaderView;
@property IBOutlet UIImageView *threatsEvacsHeaderArrowImage;
@property IBOutlet UIView *threatsEvacsContentView;
@property IBOutlet UIImageView *threatsEvacsHeaderErrorImage;

@property IBOutlet UIView *resourceCommitmentHeaderView;
@property IBOutlet UIImageView *resourceCommitmentHeaderArrowImage;
@property IBOutlet UIView *resourceCommitmentContentView;
@property IBOutlet UIImageView *resourceCommitmentHeaderErrorImage;

@property IBOutlet UIView *otherInfoHeaderView;
@property IBOutlet UIImageView *otherInfoHeaderArrowImage;
@property IBOutlet UIView *otherInfoContentView;
@property IBOutlet UIImageView *otherInfoHeaderErrorImage;

@property IBOutlet UIView *emailHeaderView;
@property IBOutlet UIImageView *emailHeaderArrowImage;
@property IBOutlet UIView *emailContentView;
@property IBOutlet UIImageView *emailHeaderErrorImage;
//=============================================================================

//=============================================================================
// Section Variables
//=============================================================================
//---------------------------------------------------------------------------
// ROC Form Info Fields
//---------------------------------------------------------------------------
@property IBOutlet UITextView *incidentNameLabelTextView;
@property IBOutlet UITextField *incidentNameTextField;
@property IBOutlet UITextView *reportTypeLabelTextView;
@property IBOutlet UITextField *reportTypeTextField;
//---------------------------------------------------------------------------
// Incident Info Fields
//---------------------------------------------------------------------------
@property IBOutlet UITextField *incidentNumberTextField;
@property IBOutlet UITableView *incidentTypeTableView;
@property IBOutlet UITextField *incidentLatitudeDegreesTextField;
@property IBOutlet UITextField *incidentLatitudeMinutesTextField;
@property IBOutlet UITextField *incidentLatitudeMinutesFractionTextField;
@property IBOutlet UITextField *incidentLongitudeDegreesTextField;
@property IBOutlet UITextField *incidentLongitudeMinutesTextField;
@property IBOutlet UITextField *incidentLongitudeMinutesFractionTextField;

@property IBOutlet UIButton *incidentLocateButton;
@property IBOutlet UITextField *incidentStateField;
//---------------------------------------------------------------------------
// ROC Incident Info Fields
//---------------------------------------------------------------------------
@property IBOutlet UITextField *rocInitialCountyTextField;
@property IBOutlet UITextField *rocAdditionalCountiesTextField;
@property IBOutlet UITextField *rocLocationTextField;
@property IBOutlet UITextField *rocStreetTextField;
@property IBOutlet UITextField *rocCrossStreetTextField;
@property IBOutlet UITextField *rocNearestCommunityTextField;
@property IBOutlet UITextField *rocDistanceFromNearestCommunityTextField;
@property IBOutlet UITextField *rocDirectionFromNearestCommunityTextField;
@property IBOutlet UITextField *rocDPATextField;
@property IBOutlet UITextField *rocOwnershipTextField;
@property IBOutlet UITextField *rocJurisdictionTextField;
@property IBOutlet UITextField *rocStartDateTextField;
@property IBOutlet UITextField *rocStartTimeTextField;
//---------------------------------------------------------------------------
// Vegetation Fire Incident Scope Fields
//---------------------------------------------------------------------------
@property IBOutlet UITextField *vegFireAcreageTextField;
@property IBOutlet UITextField *vegFireSpreadRateTextField;
@property IBOutlet UITextView *vegFireFuelTypeLabelTextView;
// Checkboxes
@property IBOutlet UIButton *vegFireFuelTypeGrassCheckbox;
@property IBOutlet UIButton *vegFireFuelTypeBrushCheckbox;
@property IBOutlet UIButton *vegFireFuelTypeTimberCheckbox;
@property IBOutlet UIButton *vegFireFuelTypeOakWoodlandCheckbox;
@property IBOutlet UIButton *vegFireFuelTypeOtherCheckbox;

@property IBOutlet UIView *vegFireFuelTypesView;
@property IBOutlet UIView *vegFireOtherFuelTypeView;

@property IBOutlet UITextField *vegFireOtherFuelTypeTextField;
@property IBOutlet UITextField *vegFirePercentContainedTextField;
//---------------------------------------------------------------------------
// Weather Information Fields
//---------------------------------------------------------------------------
@property IBOutlet UITextField *weatherTemperatureTextField;
@property IBOutlet UITextField *weatherHumidityTextField;
@property IBOutlet UITextField *weatherWindSpeedTextField;
@property IBOutlet UITextField *weatherWindDirectionTextField;
@property IBOutlet UITextField *weatherGustsTextField;
//---------------------------------------------------------------------------
// Threats & Evacuations Fields
//---------------------------------------------------------------------------
@property IBOutlet UITextField *threatsEvacsTextField;
@property IBOutlet UITextView *threatsEvacsInfoLabelTextView;
@property IBOutlet UIStackView *threatsEvacsInfoListStackView;
@property IBOutlet UIButton *threatsEvacsAddButton;
@property IBOutlet NSLayoutConstraint *threatsEvacsListHeightConstraint;

@property IBOutlet UITextField *threatsStructuresTextField;
@property IBOutlet UITextView *threatsStructuresInfoLabelTextView;
@property IBOutlet UIStackView *threatsStructuresInfoListStackView;
@property IBOutlet UIButton *threatsStructuresAddButton;
@property IBOutlet NSLayoutConstraint *threatsStructuresListHeightConstraint;

@property IBOutlet UITextField *threatsInfrastructureTextField;
@property IBOutlet UITextView *threatsInfrastructureInfoLabelTextView;
@property IBOutlet UIStackView *threatsInfrastructureInfoListStackView;
@property IBOutlet UIButton *threatsInfrastructureAddButton;
@property IBOutlet NSLayoutConstraint *threatsInfrastructureListHeightConstraint;

//---------------------------------------------------------------------------
// Resource Commitment Fields
//---------------------------------------------------------------------------
@property IBOutlet UITextField *calFireIncidentTextField;
// Checkboxes
@property IBOutlet UIButton *calFireResourcesNoneCheckbox;
@property IBOutlet UIButton *calFireResourcesAirCheckbox;
@property IBOutlet UIButton *calFireResourcesGroundCheckbox;
@property IBOutlet UIButton *calFireResourcesAirAndGroundCheckbox;
@property IBOutlet UIButton *calFireResourcesAirAndGroundAugmentedCheckbox;
@property IBOutlet UIButton *calFireResourcesAgencyRepOrderedCheckbox;
@property IBOutlet UIButton *calFireResourcesAgencyRepAssignedCheckbox;
@property IBOutlet UIButton *calFireResourcesContinuedCheckbox;
@property IBOutlet UIButton *calFireResourcesSignificantAugmentationCheckbox;
@property IBOutlet UIButton *calFireResourcesVlatOrderCheckbox;
@property IBOutlet UIButton *calFireResourcesVlatAssignedCheckbox;
@property IBOutlet UIButton *calFireResourcesNoDivertCheckbox;
@property IBOutlet UIButton *calFireResourcesLatAssignedCheckbox;
@property IBOutlet UIButton *calFireResourcesAllReleasedCheckbox;

// Checkbox Views
@property IBOutlet UIView *calFireResourcesNoneCheckboxView;
@property IBOutlet UIView *calFireResourcesAirCheckboxView;
@property IBOutlet UIView *calFireResourcesGroundCheckboxView;
@property IBOutlet UIView *calFireResourcesAirAndGroundCheckboxView;
@property IBOutlet UIView *calFireResourcesAirAndGroundAugmentedCheckboxView;
@property IBOutlet UIView *calFireResourcesAgencyRepOrderedCheckboxView;
@property IBOutlet UIView *calFireResourcesAgencyRepAssignedCheckboxView;
@property IBOutlet UIView *calFireResourcesContinuedCheckboxView;
@property IBOutlet UIView *calFireResourcesSignificantAugmentationCheckboxView;
@property IBOutlet UIView *calFireResourcesVlatOrderCheckboxView;
@property IBOutlet UIView *calFireResourcesVlatAssignedCheckboxView;
@property IBOutlet UIView *calFireResourcesNoDivertCheckboxView;
@property IBOutlet UIView *calFireResourcesLatAssignedCheckboxView;
@property IBOutlet UIView *calFireResourcesAllReleasedCheckboxView;


//---------------------------------------------------------------------------
// Other Significant Info Fields
//---------------------------------------------------------------------------
@property IBOutlet UIStackView *otherInfoListStackView;
@property IBOutlet UIButton *otherInfoAddButton;
@property IBOutlet NSLayoutConstraint *otherInfoListHeightConstraint;
//---------------------------------------------------------------------------
// Email Fields
//---------------------------------------------------------------------------
@property IBOutlet UITextField *emailTextField;
//---------------------------------------------------------------------------
//=============================================================================


//=============================================================================
// Form Field View Controllers
// This section holds explicit references to specific view controllers
//=============================================================================
@property CheckBoxTableViewController *incidentTypeViewController;
//=============================================================================



//=============================================================================
// Form Logic Methods
// These methods define the conditionality and behavior of the form
// as it is being filled out
//=============================================================================

// Clears the textfield and sets it to the string, if the string is not "(null") or "null"
- (bool) setFieldTextIfValid:(UITextField*)textField asValue:(NSString*)str;

// Populates the form fields with values from a NSDictionary
- (void) setLocationBasedDataFields:(NSDictionary*)data;

// Called when the user taps the incident locate button
// This is responsible for making a request to the SCOUT server and
// retrieving location-based data (weather and jurisdiction info)
- (IBAction) incidentLocateButtonPressed;

// Called when one of the location fields has been editted
// This is responsible for making the same request to the SCOUT server
// as incidentLocateButtonPressed
- (void) incidentLocationChanged;

// Called when the incident name field is changed
// This method is responsible for determining if the incidentName pertains to
// an existing, or a new incident
// This method then retrieves incident info (if applicable), and shows the
// report type text field.
- (void) incidentNameChanged;

// Called when the ROC Report Type field is changed
// This method is responsible for showing all of the applicable fields for the given report type
// This method should set up the field behaviors as well
// (Including setting up auto-complete fields, dropdown text fields, etc...)
- (void) reportTypeChanged;

// Populates the form with all ROC data from the parameter "data"
// Locks all fields to make it read-only
- (void) setFormToViewRocData:(ReportOnConditionData*)data;

// This hides / shows the appropriate fields depending on the report type
- (void) setupFormForReportType;

// This makes all UI fields read-only
- (void) makeAllFieldsReadOnly;

// This is called when the incident type is changed
// If the user selects / deselects vegetation fire
// the veg. fire and the Threats & Evacs fields are set to required or not required
- (void) incidentTypeChanged;

// Called when the user select an option for Evacuations, sets up the fields with the correct autocomplete options
- (void) evacuationsSpinnerChanged;

@property NSArray *evacuationsAutocompleteOptions;

// Called when the user selects an option for Structure Threats, sets up the fields with the correct autocomplete options
- (void) structureThreatsSpinnerChanged;

@property NSArray *structureThreatsAutocompleteOptions;


// Called when the user selects an option for Infrastructure Threats, sets up the fields with the correct autocomplete options
- (void) infrastructureThreatsSpinnerChanged;

@property NSArray *infrastructureThreatsAutocompleteOptions;


// The other info suggestions array
@property NSArray *otherInfoAutocompleteOptions;


//=============================================================================
// Helper methods that set up fields
//=============================================================================


// Enters the incident's information into the form and
- (void) setupFormForIncident:(IncidentPayload*)incident;


// sets all of the incident-related fields as read-only
// (except for incident name,
// as this method is called while editing incident name, so interfering with that
// kicks the user out of editing the field, so we don't want to do that)
- (void) makeIncidentFieldsReadOnly;


- (void) makeStringPickerTextField:(UITextField *)textField
				   withOptions:(NSArray*)options
					andTitle:(NSString*)title;

- (void) makeDatePicker:(UITextField*)textField;
- (void) makeTimePicker:(UITextField*)textField;


// Adds an autocomplete-textField and a delete button to the stackview
- (void) textFieldListAddButtonPressedForStackView:(UIStackView*)stackView
							    withOptions:(NSArray*)options
							 withConstraint:(NSLayoutConstraint*)constraint
						  withDeleteSelector:(SEL)deleteSelector
					  withAutocompleteOptions:(NSArray*)autocompleteOptions;

// Removes a child view from the stackview, and decreases the size of the stackview
- (void) textFieldListDeleteButtonPressed:(UIButton*)button forStackView:(UIStackView*)stackView withConstraint:(NSLayoutConstraint*)constraint;


- (IBAction) threatsEvacsAddButtonPressed;
- (void) threatsEvacsDeleteButtonPressed:(UIButton*)button;

- (IBAction) threatsStructuresAddButtonPressed;
- (void) threatsStructuresDeleteButtonPressed:(UIButton*)button;

- (IBAction) threatsInfrastructureAddButtonPressed;
- (void) threatsInfrastructureDeleteButtonPressed:(UIButton*)button;


- (IBAction) otherInfoAddButtonPressed;
- (void) otherInfoDeleteButtonPressed:(UIButton*)button;

// If "hidden" is set to true, this hides all form sections
// otherwise, this shows all form sections
- (void) hideAllFormSections:(bool)hidden;

- (void) makeCheckbox:(UIButton*)button;
- (void) checkBoxTapped:(id) obj;

// A variant of make Checkbox for the "Other Fuel Types" checkbox
// This checkbox shows / hide the "Other Fuel Type" text field
// that the user must then fill
- (void) makeOtherFuelTypeCheckbox:(UIButton*)button;
- (void) otherFuelTypeCheckboxTapped:(id) obj;

// This method clears a textfield list stackview, and sets the the autocomplete array that
// textFields in the stackview use for autocompletion
- (void) setupTextFieldList:(UIStackView*)stackView
		    withTextField:(UITextField*)textField
		 heightConstraint:(NSLayoutConstraint*)constraint
			   addButton:(UIButton*)button
			  yesOptions:(NSArray*)yesOptions
		 mitigatedOptions:(NSArray*)mitigatedOptions;

// Checks if the field's delegate is in our delegates array, if so, remove it.
- (void) cleanUpDelegateForTextField:(UITextField*)textField;
- (void) cleanUpDelegateForTableView:(UITableView*)tableView;


// Removes all child view from the stack view:
- (void) clearTextFieldListStackView:(UIStackView*)stackView withHeightConstraint:(NSLayoutConstraint*)constraint;

// Clears all of the UI textFields, tables, etc... for a fresh, empty form
- (void) clearAllFormFields;

// Keeping strong references to each delegate so they don't get garbage collected
@property NSMutableArray *delegatesArray;
- (void) makeAutocompleteTextField:(UITextField*)textField withOptions:(NSArray*)options;

// Makes the textField clear the bordercolor and border when modified to hide the error outline
- (void) makeTextFieldClearErrorWhenChanged:(UITextField*)textField;

// Sets the placeholder text to "required" for required fields
// NOTE - this method doesn't actually mark the text field as required for form validation
// The validation logic is in the method areFormFieldsValid
- (void) makeTextFieldRequired:(UITextField*)textField required:(bool)required;

// Does a regular expression pattern match to verify that string represents a valid double
- (bool) isValidDouble:(NSString*)string;
// Does a regular expression pattern match to verify that string represents a valid integer
- (bool) isValidInt:(NSString*)string;

// Returns true if the string contains only whitespace
- (bool) isStringEmpty:(NSString*)string;

//=============================================================================


@property IBOutlet UIButton *submitButton;
@property IBOutlet UIButton *cancelButton;
// We modify the height of this constraint to make the button view section go away
// and have the scroll view resize to fill the screen
@property IBOutlet NSLayoutConstraint *rocButtonsViewHeightConstraint;


- (void) setFormToViewRocForIncident:(IncidentPayload *)incident;




// Returns if a desired latlong is valid
- (bool) isValidLatLongLatDeg:(int)latDeg LatMin:(double)latMin LonDeg:(int)lonDeg LonMin:(double)lonMin;






// Hides all error views
- (void) hideAllErrors;

// Shows all error views (for testing purposes)
- (void) showAllErrors;

// Adds a red border to a field, indicating a validation error
- (void) showViewError:(UIView*)view;



// Removes the red border from a field, to clear the validation error
- (void) clearViewError:(UIView*)view;


// Checks to make sure all required form fields are filled out and that the
// form is ready for submission
// Returns true if all required fields are filled and all entered data is valid
// Returns false if some input is malformed or a required field is missing
// 		If it returns false, this method also shows an error on the missing / malformed fields,
// 		and shows an error on the section itself
- (bool) areFormFieldsValid;

// Reads all form UI fields and populates a ReportOnConditionData object
// This method provides no data validation for fields
- (ReportOnConditionData*) formToRocData;

- (IBAction)submitReportButtonPressed:(UIButton *)button;

// TODO - implement this:
- (IBAction)cancelButtonPressed:(UIButton *)button;
// TODO - implement this:
- (void)cancelTabletButtonPressed;


// Builds a UITapGestureRecognizer for use on each section
- (UITapGestureRecognizer*) newTapRecognizer;
// Called each time a section header is clicked
// Is responsible for toggling the visibility of the appropriate section
// and collapsing all other sections
- (void) toggleCollapsibleSection:(UIGestureRecognizer*)sender;

// Hides all textfield dropdown lists
// doesn't hide the dropdown list of textField
- (void) hideAllDropdownListsExcept:(UITextField*)textField;

// Collapses all report sections
- (void) collapseAllSections;


@end

