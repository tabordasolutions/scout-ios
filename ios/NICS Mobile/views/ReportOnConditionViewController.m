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


//============================================================================================================================================================
//============================================================================================================================================================
// Local Helper Class Declarations
//============================================================================================================================================================
//============================================================================================================================================================


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// TextFieldDropdownController
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// This class sets up a textField for autocomplete dropdowns
// use it via makeAutocompleteTextField: withOptions:
@interface TextFieldDropdownController : NSObject <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

// Sets up the object to provide dropdown support for textField
- (id) initForTextField:(UITextField *)textField withOptions:(NSArray*)options;

@property (nonatomic) UITextField *textField;
@property (nonatomic) UITableView *dropdownMenuTableView;
// Contains all options
@property NSMutableArray *dropdownMenuOptions;
// Contains only the filtered options based on the textField's contents
@property NSMutableArray *activeDropdownMenuOptions;
@property NSLayoutConstraint *tableViewHeightConstraint;

// Filters the dropdownMenuOptions array and updates the activeDropdownMenuOptions
// Notifies the UITableView that the options have changed.
- (void) filterOptionsForText:(NSString*)text;
// Hides the dropdownmenu table view (This is used when a form section is collapsed)
- (void) hideDropDownMenu;


//--------------------------------------------------------------------------------------------------------------------------
// UITextField Delegate Methods
//--------------------------------------------------------------------------------------------------------------------------
- (void)textFieldDidBeginEditing:(UITextField *)textField;
- (void) textFieldDidEndEditing:(UITextField *)textField;
- (BOOL) textFieldShouldClear:(UITextField *)textField;
- (void)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(nonnull NSString *)string;
//--------------------------------------------------------------------------------------------------------------------------
// UITableView DataSource Methods
//--------------------------------------------------------------------------------------------------------------------------
- (NSInteger) numberOfSectionsInTableView:(UITableView *) tableView;
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger) section;
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath;
//- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath;
//--------------------------------------------------------------------------------------------------------------------------
// UITableView Delegate Methods
//--------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath;
@end

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// CheckBoxTableViewController
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


// This class is the datasource and delegate for a tableview that adds checkboxes
@interface CheckBoxTableViewController : NSObject <UITableViewDataSource, UITableViewDelegate>
// Sets up the object
- (id) initForTableView:(UITableView*)tableView withOptions:(NSArray*)options;

// Contains all options
@property NSMutableArray *tableViewOptions;
// Contains only the filtered options based on the textField's contents
@property NSMutableArray *selectedTableViewOptions;
//--------------------------------------------------------------------------------------------------------------------------
// UITableView DataSource Methods
//--------------------------------------------------------------------------------------------------------------------------
- (NSInteger) numberOfSectionsInTableView:(UITableView *) tableView;
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger) section;
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath;
//--------------------------------------------------------------------------------------------------------------------------
// UITableView Delegate Methods
//--------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath;
@end

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// StringPickerViewController
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


// This class is the datasource and delegate for a pickerview
@interface StringPickerViewController : NSObject <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>

// Holds a reference to the ReportOnConditionViewController (we use this to show the alert dialog)
@property ReportOnConditionViewController *rocViewController;
// Holds a reference to the string to update the string
@property UITextField *textField;
// Holds the list of available strings:
@property NSMutableArray *spinnerOptions;
// Holds the currently selected picker string
@property NSString *selectedPickerString;
- (id) initForTextField:(UITextField*)textField withOptions:(NSArray*)options andROCViewController:(ReportOnConditionViewController*)rocViewController;

- (void) showAlert;

//--------------------------------------------------------------------------------------------------------------------------
// UITextField Delegate Methods
//--------------------------------------------------------------------------------------------------------------------------
- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField;
//--------------------------------------------------------------------------------------------------------------------------
// UIPickerView DataSource Methods
//--------------------------------------------------------------------------------------------------------------------------
- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
//--------------------------------------------------------------------------------------------------------------------------
// UIPickerView Delegate Methods
//--------------------------------------------------------------------------------------------------------------------------
- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component;

@end

//============================================================================================================================================================
//============================================================================================================================================================


//============================================================================================================================================================
// ReportOnConditionViewController Class Definition
//============================================================================================================================================================

const int ID_SECTION1 = 0;
const int ID_SECTION2 = 1;


@implementation ReportOnConditionViewController

- (void) viewDidLoad
{
	[super viewDidLoad];
	_dataManager = [DataManager getInstance];
	
	
	//UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleCollapsibleSection:ID_SECTION1)];
	_section1HeaderView.tag = ID_SECTION1;
	[_section1HeaderView addGestureRecognizer:[self newTapRecognizer]];
	
	_section2HeaderView.tag = ID_SECTION2;
	[_section2HeaderView addGestureRecognizer:[self newTapRecognizer]];
	
	// Setting up the dropdown text
	[_dropdownTextField setDelegate:self];
	
	
	
	NSArray *arr = @[@"String Option 1",
				  @"String Option 2.",
				  @"Very very long (actually, extremely long, far too long to be considered normal) string Option 3",
				  @"String Option 4",
				  @"Yet another very extremely quite long (again, this is so long that it's not expected for strings to EVER be this long in practice) string Option 4.",
				  @"SO5."];
	
	// Allocating the delegates array to hold strong references to each delegate
	_delegatesArray = [[NSMutableArray alloc] init];
	[self makeAutocompleteTextField:_dropdownTextField withOptions:arr];
	
	
	// Setting up the Checkbox tableView
	NSArray *incidentTypes = @[@"Aircraft Accident",
						@"Wildland Fire",
						@"Timber",
						@"Oak Woodland",
						@"Blizzard",
						@"Civil Unrest",
						@"Earthquake",
						@"Fire (Structure)",
						@"Fire (Wildland)",
						@"Flood",
						@"Hazardous Materials",
						@"Hurricane",
						@"Mass Casualty",
						@"Nuclear Accident",
						@"Oil Spill",
						@"Planned Event",
						@"Public Health / Medical Emergency",
						@"Search and Rescue",
						@"Terrorist Threat / Attack",
						@"Tornado",
						@"Tropical Storm",
						@"Tsunami"];


	
	CheckBoxTableViewController *tableViewController = [[CheckBoxTableViewController alloc] initForTableView:_checkboxTableView withOptions:incidentTypes];
	[_delegatesArray addObject:tableViewController];
	
	
	//-------------------------------------------------------------------------
	
	NSArray *countiesArr = @[@"Alameda",
				  @"Alpine",
				  @"Amador",
				  @"Butte",
				  @"Calaveras",
				  @"Colusa",
				  @"Contra Costa",
				  @"Del Norte",
				  @"El Dorado",
				  @"Fresno",
				  @"Glenn",
				  @"Humboldt",
				  @"Imperial",
				  @"Inyo",
				  @"Kern",
				  @"Kings",
				  @"Lake",
				  @"Lassen",
				  @"Los Angeles",
				  @"Madera",
				  @"Marin",
				  @"Mariposa",
				  @"Mendocino",
				  @"Merced",
				  @"Modoc",
				  @"Mono",
				  @"Monterey",
				  @"Napa",
				  @"Nevada",
				  @"Orange",
				  @"Placer",
				  @"Plumas",
				  @"Riverside",
				  @"Sacramento",
				  @"San Benito",
				  @"San Bernardino",
				  @"San Diego",
				  @"San Francisco",
				  @"San Joaquin",
				  @"San Luis Obispo",
				  @"San Mateo",
				  @"Santa Barbara",
				  @"Santa Clara",
				  @"Santa Cruz",
				  @"Shasta",
				  @"Sierra",
				  @"Siskiyou",
				  @"Solano",
				  @"Sonoma",
				  @"Stanislaus",
				  @"Sutter",
				  @"Tehama",
				  @"Trinity",
				  @"Tulare",
				  @"Tuolumne",
				  @"Ventura",
				  @"Yolo",
				  @"Yuba"];
	
	[self makeStringPickerTextField:_testCountiesField withOptions:countiesArr];
	
	
	// Setting up the checkbox:
	[_testCheckbox addTarget:self action:@selector(checkBoxTapped:) forControlEvents:UIControlEventTouchUpInside];
	
	[_testCheckbox setBackgroundImage:[UIImage imageNamed:@"checkbox"] forState:UIControlStateNormal];
	[_testCheckbox setBackgroundImage:[UIImage imageNamed:@"checkbox_checked"] forState:UIControlStateSelected];
	[_testCheckbox setBackgroundImage:[UIImage imageNamed:@"checkbox_checked"] forState:UIControlStateHighlighted];
	//_testCheckbox.adjustsImageWhenHighlighted = true;
	_checkboxSelected = false;

}


- (void) checkBoxTapped:(id) obj
{
	NSLog(@"ROC Checkbox tapped!");
	_checkboxSelected = !_checkboxSelected;
	[_testCheckbox setSelected:_checkboxSelected];
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
	
	
	if(section_id == ID_SECTION1)
	{
		// --------------------------------------------------------
		// Test
		// --------------------------------------------------------
		//[self createAlertController];
		// --------------------------------------------------------
		// End Test
		// --------------------------------------------------------

		section = _section1ContentView;
		headerArrowImage = _section1HeaderArrowImage;
	}
	else if(section_id == ID_SECTION2)
	{
		// --------------------------------------------------------
		// Test
		// --------------------------------------------------------
		[self createDateAlertController];
		// --------------------------------------------------------
		// End Test
		// --------------------------------------------------------

		section = _section2ContentView;
		headerArrowImage = _section2HeaderArrowImage;
	}
	else
	{
		return;
	}
	
	
	// If the section is hidden, expand it
	BOOL expand = [section isHidden];
	
	
	[self collapseAllSections];
	
	if(expand)
	{
		[section setHidden:false];
		[headerArrowImage setImage:[UIImage imageNamed:@"up_arrow_transparent"]];
	}
	
}

// Collapses all sections
- (void) collapseAllSections
{
	// Collapsing the views
	[_section1ContentView setHidden:true];
	[_section2ContentView setHidden:true];
	
	// Hiding all tableviews
	for(NSObject *obj in _delegatesArray)
	{
		if([obj class] == [TextFieldDropdownController class])
		{
			TextFieldDropdownController *textFieldController = (TextFieldDropdownController *)obj;
			[textFieldController hideDropDownMenu];
		}
	}
	
	
	/*[_section1ContentView addConstraint:
	 [NSLayoutConstraint
	 constraintWithItem:_section1ContentView
	 attribute: NSLayoutAttributeHeight
	 relatedBy:NSLayoutRelationEqual
	 toItem:nil
	 attribute:NSLayoutAttributeNotAnAttribute
	 multiplier:1.0
	 constant:0]];*/
	
	/*[_section1ContentView addConstraint:
	 [NSLayoutConstraint
	 constraintWithItem:_section1ContentView
	 attribute: NSLayoutAttributeHeight
	 relatedBy:NSLayoutRelationEqual
	 toItem:nil
	 attribute:NSLayoutAttributeNotAnAttribute
	 multiplier:1.0
	 constant:0]];*/
	
	
	//	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.captchaView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:0]];
	
	// Setting the icon to be the collapsed icon
	[_section1HeaderArrowImage setImage:[UIImage imageNamed:@"down_arrow_transparent"]];
	[_section2HeaderArrowImage setImage:[UIImage imageNamed:@"down_arrow_transparent"]];
}


- (IBAction)testButtonPush:(UIButton *)button
{
	NSLog(@"Pushed button.");
	
	
	
	// Getting the stackview width:
	float superviewWidth = [_testStackView bounds].size.width;
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
	//	[newTextField setText:@"Test values"];
	
	/*static int x = 0;
	 if(x == 0)
	 {
	 [newTextField setBackgroundColor:[UIColor greenColor]];
	 x = 1;
	 }
	 else
	 {
	 [newTextField setBackgroundColor:[UIColor yellowColor]];
	 x = 0;
	 }*/
	newTextField.layer.cornerRadius = 5;
	[newTextField setBackgroundColor:[UIColor whiteColor]];
	[newTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
	
	//-------------------------------------------------------------------------
	// Creating the remove button
	//-------------------------------------------------------------------------
	UIButton *newButton = [[UIButton alloc] initWithFrame:buttonRect];
	
	
	[newButton setImage:[UIImage imageNamed:@"cross_symbol"] forState:UIControlStateNormal];
	[newButton setBackgroundColor:[UIColor colorWithRed:0.451 green:0.451 blue:0.451 alpha:1.0]];
	
	[newButton addTarget:self action:@selector(testButtonPush2:) forControlEvents:UIControlEventTouchUpInside];
	
	
	//UIView *view = [[UIView alloc] initWithFrame:buttonRect];
	
	// FIXME: - Don't think this is required
	//	[newButton setUserInteractionEnabled:true];
	//-------------------------------------------------------------------------
	// Creating the container view
	//-------------------------------------------------------------------------
	UIView *newView = [[UIView alloc] initWithFrame:newViewRect];
	
	//[newView setBackgroundColor:[UIColor whiteColor]];
	
	// Attempting to get the new view to be visible
	//	newView.layer.borderColor = [UIColor redColor].CGColor;
	//	newView.layer.borderWidth = 3.0f;
	//	[newView setOpaque:true];
	//	[newView setHidden:false];
	//	[newView setAlpha:1.0];
	//	[newView setBounds:newViewRect];
	//	[newView setNeedsDisplay];
	
	// FIXME: - this required?
	//	[newView setUserInteractionEnabled:true];
	//-------------------------------------------------------------------------
	
	// Adding the text and buttons to the new view:
	[newView addSubview:newTextField];
	[newView addSubview:newButton];
	
	// Adding the new view to the stackview:
	[_testStackView addArrangedSubview:newView];
	
	// Increasing the size of the box:
	_testHeightConstraint.constant += 45;
	
	
	
	// Setting up autocomplete for the textView:
	NSArray *arr = @[@"String Option 1",
				  @"String Option 2.",
				  @"Very very long (actually, extremely long, far too long to be considered normal) string Option 3",
				  @"String Option 4",
				  @"Yet another very extremely quite long (again, this is so long that it's not expected for strings to EVER be this long in practice) string Option 4.",
				  @"SO5."];
	[self makeAutocompleteTextField:newTextField withOptions:arr];
	// Resizing the text view container stackview
	//	CGRect oldBounds = [_testStackView bounds];
	//	CGRect newBounds = oldBounds;
	//	newBounds.size.height += 20;
	//	[_testStackView setBounds:newBounds];
	
	
	//_testStackView.CGRectGetHeight(CGRect rect)
	
	//[_testStackView addSubview:newTextField];
	
	// Increasing the section size:
	//	CGRect sectionContentViewRect = [_section2ContentView bounds];
	//	sectionContentViewRect.size.height += 20;
	//	sectionContentViewRect.origin.y -= 20;
	//	[_section2ContentView setBounds:sectionContentViewRect];
	
}

- (IBAction)testButtonPush2:(UIButton *)button
{
	NSLog(@"Pressed delete button.");
	
	// Remove the view from the
	UIView *superview = button.superview;
	
	// Removing the child views:
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
	
	// Remove the superview itself:
	[_testStackView removeArrangedSubview:superview];
	
	// Decrementing the stackview size:
	_testHeightConstraint.constant -= 45;
}




- (void) dateAlertControllerDoneClick
{
	NSLog(@"Clicked done, value: %@",[_testDatePicker date]);
}

- (void) dateAlertControllerCancelClick
{
	NSLog(@"Clicked cancel, value: %@",[_testDatePicker date]);
}


- (void) alertControllerDoneClick
{
	//NSLog(@"Clicked done, value: %@",[_testDatePicker date]);
}

- (void) alertControllerCancelClick
{
	//NSLog(@"Clicked cancel, value: %@",[_testDatePicker date]);
}

/*- (void) createAlertController
{
	// If the pickerView already exists: delete its delegate:
	if(_testPickerView != nil)
	{
		[_delegatesArray removeObject:_testPickerView.delegate];
	}
	
	_testAlertController = [UIAlertController alertControllerWithTitle:@"Title" message:nil preferredStyle:UIAlertControllerStyleAlert];
	
	// Adding OK button
	UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
											    handler:^(UIAlertAction * action) { [self alertControllerDoneClick];}];
	
	[_testAlertController addAction:confirmAction];
	
	// Adding Cancel button
	UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
											   handler:^(UIAlertAction * action) { [self alertControllerCancelClick];}];
	
	[_testAlertController addAction:cancelAction];
	
	
	_testPickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
	
	
	NSArray *arr = @[@"Alameda",
				  @"Alpine",
				  @"Amador",
				  @"Butte",
				  @"Calaveras",
				  @"Colusa",
				  @"Contra Costa",
				  @"Del Norte",
				  @"El Dorado",
				  @"Fresno",
				  @"Glenn",
				  @"Humboldt",
				  @"Imperial",
				  @"Inyo",
				  @"Kern",
				  @"Kings",
				  @"Lake",
				  @"Lassen",
				  @"Los Angeles",
				  @"Madera",
				  @"Marin",
				  @"Mariposa",
				  @"Mendocino",
				  @"Merced",
				  @"Modoc",
				  @"Mono",
				  @"Monterey",
				  @"Napa",
				  @"Nevada",
				  @"Orange",
				  @"Placer",
				  @"Plumas",
				  @"Riverside",
				  @"Sacramento",
				  @"San Benito",
				  @"San Bernardino",
				  @"San Diego",
				  @"San Francisco",
				  @"San Joaquin",
				  @"San Luis Obispo",
				  @"San Mateo",
				  @"Santa Barbara",
				  @"Santa Clara",
				  @"Santa Cruz",
				  @"Shasta",
				  @"Sierra",
				  @"Siskiyou",
				  @"Solano",
				  @"Sonoma",
				  @"Stanislaus",
				  @"Sutter",
				  @"Tehama",
				  @"Trinity",
				  @"Tulare",
				  @"Tuolumne",
				  @"Ventura",
				  @"Yolo",
				  @"Yuba"];
	
	[self makeStringPickerTextField:_testPickerView withOptions:arr];
//	_testPickerView = [[UIPickerView alloc]]
//	_testDatePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
	//	_testDatePicker.datePickerMode = UIDatePickerModeDateAndTime;
	//	_testDatePicker.datePickerMode = UIDatePickerModeDate;
	//	_testDatePicker.datePickerMode = UIDatePickerModeTime;
	
	
	
	[_testAlertController.view addSubview:_testPickerView];
	
	
	//-------------------------------------------------------------------------
	// Creating Constraints to resize the alertview
	//-------------------------------------------------------------------------
	
	// Making the alert be a certain height:
	NSLayoutConstraint *heightConstraint = [NSLayoutConstraint
									constraintWithItem:_testAlertController.view
									attribute:NSLayoutAttributeHeight
									relatedBy:NSLayoutRelationEqual
									toItem:nil
									attribute:NSLayoutAttributeNotAnAttribute
									multiplier:1.0f
									constant:200];
	
	NSLayoutConstraint *widthConstraint = [NSLayoutConstraint
								    constraintWithItem:_testAlertController.view
								    attribute:NSLayoutAttributeWidth
								    relatedBy:NSLayoutRelationEqual
								    toItem:nil
								    attribute:NSLayoutAttributeNotAnAttribute
								    multiplier:1.0f
								    constant:300];
	
	
	
	
	_testPickerView.translatesAutoresizingMaskIntoConstraints = false;
	//_testAlertController.view.translatesAutoresizingMaskIntoConstraints = true;
	
	
	// Creating constraints for each of the sides
	NSLayoutConstraint *pickerTopConstraint = [NSLayoutConstraint
									   constraintWithItem:_testPickerView
									   attribute:NSLayoutAttributeTop
									   relatedBy:NSLayoutRelationEqual
									   toItem:_testAlertController.view
									   attribute:NSLayoutAttributeTop
									   multiplier:1.0f
									   constant:40];
	
	NSLayoutConstraint *pickerBottomConstraint = [NSLayoutConstraint
										 constraintWithItem:_testPickerView
										 attribute:NSLayoutAttributeBottom
										 relatedBy:NSLayoutRelationEqual
										 toItem:_testAlertController.view
										 attribute:NSLayoutAttributeBottom
										 multiplier:1.0f
										 constant:-50];
	
	
	NSLayoutConstraint *pickerLeadingConstraint = [NSLayoutConstraint
										  constraintWithItem:_testPickerView
										  attribute:NSLayoutAttributeLeading
										  relatedBy:NSLayoutRelationEqual
										  toItem:_testAlertController.view
										  attribute:NSLayoutAttributeLeading
										  multiplier:1.0f
										  constant:30];
	
	NSLayoutConstraint *pickerTrailingConstraint = [NSLayoutConstraint
										   constraintWithItem:_testPickerView
										   attribute:NSLayoutAttributeTrailing
										   relatedBy:NSLayoutRelationEqual
										   toItem:_testAlertController.view
										   attribute:NSLayoutAttributeTrailing
										   multiplier:1.0f
										   constant:-30];
	
	// Adding the constraints
	[_testAlertController.view addConstraint:heightConstraint];
	[_testAlertController.view addConstraint:widthConstraint];
	// Adding constraints to the pickerview
	[_testAlertController.view addConstraint:pickerTopConstraint];
	[_testAlertController.view addConstraint:pickerBottomConstraint];
	[_testAlertController.view addConstraint:pickerLeadingConstraint];
	[_testAlertController.view addConstraint:pickerTrailingConstraint];
	
	//-------------------------------------------------------------------------
	
	[self presentViewController:_testAlertController animated:YES completion:nil];
}*/

- (void) createDateAlertController
{
	_testDateAlertController = [UIAlertController alertControllerWithTitle:@"Title" message:nil preferredStyle:UIAlertControllerStyleAlert];

	// Adding OK button
	UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
		handler:^(UIAlertAction * action) { [self dateAlertControllerDoneClick];}];
	
	[_testDateAlertController addAction:confirmAction];

	// Adding Cancel button
	UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
		handler:^(UIAlertAction * action) { [self dateAlertControllerCancelClick];}];
	
	[_testDateAlertController addAction:cancelAction];

	
	_testDatePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
	//	_testDatePicker.datePickerMode = UIDatePickerModeDateAndTime;
	//	_testDatePicker.datePickerMode = UIDatePickerModeDate;
	//	_testDatePicker.datePickerMode = UIDatePickerModeTime;

	
	// Sets the date picker to use 24 hour time format by changing the locale
	NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"];
	[_testDatePicker setLocale:locale];
	
	[_testDateAlertController.view addSubview:_testDatePicker];

	
	//-------------------------------------------------------------------------
	// Creating Constraints to resize the alertview
	//-------------------------------------------------------------------------
	
	// Making the alert be a certain height:
	NSLayoutConstraint *heightConstraint = [NSLayoutConstraint
									constraintWithItem:_testDateAlertController.view
									attribute:NSLayoutAttributeHeight
									relatedBy:NSLayoutRelationEqual
									toItem:nil
									attribute:NSLayoutAttributeNotAnAttribute
									multiplier:1.0f
									constant:200];
	
	NSLayoutConstraint *widthConstraint = [NSLayoutConstraint
									constraintWithItem:_testDateAlertController.view
									attribute:NSLayoutAttributeWidth
									relatedBy:NSLayoutRelationEqual
									toItem:nil
									attribute:NSLayoutAttributeNotAnAttribute
									multiplier:1.0f
									constant:300];
	
	
	
	
	_testDatePicker.translatesAutoresizingMaskIntoConstraints = false;
	//_testDateAlertController.view.translatesAutoresizingMaskIntoConstraints = true;
	
	
	// Creating constraints for each of the sides
	NSLayoutConstraint *pickerTopConstraint = [NSLayoutConstraint
									  constraintWithItem:_testDatePicker
									  attribute:NSLayoutAttributeTop
									  relatedBy:NSLayoutRelationEqual
									  toItem:_testDateAlertController.view
									  attribute:NSLayoutAttributeTop
									  multiplier:1.0f
									  constant:40];

	NSLayoutConstraint *pickerBottomConstraint = [NSLayoutConstraint
									   constraintWithItem:_testDatePicker
									   attribute:NSLayoutAttributeBottom
									   relatedBy:NSLayoutRelationEqual
									   toItem:_testDateAlertController.view
									   attribute:NSLayoutAttributeBottom
									   multiplier:1.0f
									   constant:-50];
	
	
	NSLayoutConstraint *pickerLeadingConstraint = [NSLayoutConstraint
									   constraintWithItem:_testDatePicker
									   attribute:NSLayoutAttributeLeading
									   relatedBy:NSLayoutRelationEqual
									   toItem:_testDateAlertController.view
									   attribute:NSLayoutAttributeLeading
									   multiplier:1.0f
									   constant:30];
	
	NSLayoutConstraint *pickerTrailingConstraint = [NSLayoutConstraint
										 constraintWithItem:_testDatePicker
										 attribute:NSLayoutAttributeTrailing
										 relatedBy:NSLayoutRelationEqual
										 toItem:_testDateAlertController.view
										 attribute:NSLayoutAttributeTrailing
										 multiplier:1.0f
										 constant:-30];

	// Adding the constraints
	[_testDateAlertController.view addConstraint:heightConstraint];
	[_testDateAlertController.view addConstraint:widthConstraint];
	// Adding constraints to the pickerview
	[_testDateAlertController.view addConstraint:pickerTopConstraint];
	[_testDateAlertController.view addConstraint:pickerBottomConstraint];
	[_testDateAlertController.view addConstraint:pickerLeadingConstraint];
	[_testDateAlertController.view addConstraint:pickerTrailingConstraint];
	//-------------------------------------------------------------------------
	
	[self presentViewController:_testDateAlertController animated:YES completion:nil];
}



- (IBAction)submitReportButtonPressed:(UIButton *)button
{
	// TODO - Do form validation, enable form error indicators
	// TODO - Submit the form
}

- (void)submitTabletReportButtonPressed
{
	// TODO - Do form validation, enable form error indicators
	// TODO - Submit the form
}

- (IBAction)cancelButtonPressed:(UIButton *)button
{
	// TODO - Show confirmation dialog and take them back to the action view
}

- (void)cancelTabletButtonPressed
{
	// TODO - Show confirmation dialog and take them back to the action view
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
	
	// Holding a strong reference to the delegate to avoid garbage collection
	[_delegatesArray addObject:dropdownController];
}


- (void) makeStringPickerTextField:(UITextField *)textField withOptions:(NSArray*)options
{
	// Create the controller
	StringPickerViewController *viewController = [[StringPickerViewController alloc] initForTextField:textField withOptions:options andROCViewController:self];
	
	// Assign the textField's delegate:
	[textField setDelegate:viewController];
	
	// Hold a reference to the view controller:
	[_delegatesArray addObject:viewController];

	
	
	//============================================================================================================================================================

	

	
	
	//============================================================================================================================================================

	
	
	
	
	// Creating a new delegate for the pickerView
//	StringPickerViewController *pickerController = [[StringPickerViewController alloc] initWithOptions:options];
	
	// Holding a strong reference to the delegate to avoid garbage collection
//	[_delegatesArray addObject:pickerController];
	
	// Assigning it to the pickerview:
//	[pickerView setDelegate:pickerController];
//	[pickerView setDataSource:pickerController];
}

@end

//============================================================================================================================================================
// Local Helper Class Definitions
//============================================================================================================================================================


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// TextFieldDropdownController
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// This is a delegate for a textfield that provides dropdown functionality
// Assign this as a delegate for a text field to add support for dropdowns.


@implementation TextFieldDropdownController

// Sets up the TextFieldDropdownController to add dropdown functionality to textField
- (id) initForTextField:(UITextField *)textField withOptions:(NSArray*)options
{
	self = [super init];
	
	
	NSLog(@"CreateWithTextField called.");
	if(textField == nil)
	{
		NSLog(@"Warning: created TextFieldDropdownController with nil textField");
		return nil;
	}
	if(options == nil)
	{
		NSLog(@"Warning: created TextFieldDropdownController with nil options array");
		return nil;
	}
	
	// Storing a reference to the textField
	_textField = textField;
	
	// Creating a Mutable copy of the options array
	_dropdownMenuOptions = [NSMutableArray arrayWithArray:options];
	_activeDropdownMenuOptions = [NSMutableArray arrayWithArray:options];
	
	// Creating the UITableView
	_dropdownMenuTableView = [[UITableView alloc] initWithFrame:CGRectZero];
	[_dropdownMenuTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"rocCellId"];
	
	[_textField setDelegate:self];
	[_dropdownMenuTableView setDelegate:self];
	[_dropdownMenuTableView setDataSource:self];
	[_dropdownMenuTableView reloadData];
	
	// Don't show it by default
	[_dropdownMenuTableView setHidden:true];
	
	//-------------------------------------------------------------------------
	// Adding the tableview to the view hierarchy:
	//-------------------------------------------------------------------------
	// The tableview should be placed above every other view
	// Otherwise, the tableview might be obstructed by other UI elements
	// (This causes a problem that if you collapse a section, the tableview is not hidden)
	UIView *parentView = _textField.superview;
	// Find the outermost scrollview, make that the parent:
	while([parentView class] != [UIScrollView class])
	{
		parentView = parentView.superview;
		if(parentView == nil)
		{
			NSLog(@"Warning: no scrollview found in ROC view hierarchy. Defaulting to parent.");
			parentView = _textField.superview;
			break;
		}
	}
	
	[parentView addSubview:_dropdownMenuTableView];
	[parentView bringSubviewToFront:_dropdownMenuTableView];
	//-------------------------------------------------------------------------
	
	
	
	//-------------------------------------------------------------------------
	// Setting up tableview constraints:
	//-------------------------------------------------------------------------
	// Don't use the tableView's frame size to resolve layout constraints
	_dropdownMenuTableView.translatesAutoresizingMaskIntoConstraints = false;
	NSLayoutConstraint *leadingConstraint = [NSLayoutConstraint
									 constraintWithItem:_dropdownMenuTableView
									 attribute:NSLayoutAttributeLeading
									 relatedBy:NSLayoutRelationEqual
									 toItem:_textField
									 attribute:NSLayoutAttributeLeading
									 multiplier:1.0f
									 constant:0];
	NSLayoutConstraint *topConstraint = [NSLayoutConstraint
								  constraintWithItem:_dropdownMenuTableView
								  attribute:NSLayoutAttributeTop
								  relatedBy:NSLayoutRelationEqual
								  toItem:_textField
								  attribute:NSLayoutAttributeBottom
								  multiplier:1.0f
								  constant:0];
	NSLayoutConstraint *trailingConstraint = [NSLayoutConstraint
									  constraintWithItem:_dropdownMenuTableView
									  attribute:NSLayoutAttributeTrailing
									  relatedBy:NSLayoutRelationEqual
									  toItem:_textField
									  attribute:NSLayoutAttributeTrailing
									  multiplier:1.0f
									  constant:0];
	// Make it 4 times taller than the default UITableViewCell height (44)
	NSLayoutConstraint *heightConstraint = [NSLayoutConstraint
									constraintWithItem:_dropdownMenuTableView
									attribute:NSLayoutAttributeHeight
									relatedBy:NSLayoutRelationEqual
									toItem:nil
									attribute:NSLayoutAttributeNotAnAttribute
									multiplier:1.0
									constant:(4 * 44)];
	// Storing the height constraint for modification:
	_tableViewHeightConstraint = heightConstraint;
	
	// Adding the constraints to the table's parent
	[parentView addConstraint:leadingConstraint];
	[parentView addConstraint:topConstraint];
	[parentView addConstraint:trailingConstraint];
	[parentView addConstraint:heightConstraint];
	//-------------------------------------------------------------------------
	
	//-------------------------------------------------------------------------
	// Styling the tableview:
	//-------------------------------------------------------------------------
	// This adds a border to the tableview
	//_dropdownMenuTableView.contentInset = UIEdgeInsetsMake(50, 0, 0, 0);
	
	//_dropdownMenuTableView.layer.borderColor = UIColor.blackColor.CGColor;
	//_dropdownMenuTableView.layer.borderWidth = 0.5;
	[_dropdownMenuTableView setBackgroundColor:[UIColor colorWithRed:0.078 green:0.137 blue:0.173 alpha:1.0]];
	_dropdownMenuTableView.layer.cornerRadius = 3;
	//-------------------------------------------------------------------------
	
	
	return self;
}

// Filters the dropdownMenuOptions array and updates the activeDropdownMenuOptions
// Notifies the UITableView that the options have changed.
- (void) filterOptionsForText:(NSString*)text
{
	// Wipe the active options array
	[_activeDropdownMenuOptions removeAllObjects];
	
	if(text != nil)
	{
		// Iterate through all options, adding them to active if they match text
		for(NSString *str in _dropdownMenuOptions)
		{
			// If the filter text is empty, or it matches
			if([text length] == 0 || [str hasPrefix:text])
			{
				[_activeDropdownMenuOptions addObject:str];
			}
		}
	}
	int numOptions = (int) [_activeDropdownMenuOptions count];
	
	// Resize the dropdown menu to show up to x options:
	int maxOptions = 4;
	
	// If there are 0 options, hide the tableview
	if(numOptions == 0)
	{
		// Reset the height:
		[_tableViewHeightConstraint setConstant:(maxOptions * 44)];
		[_dropdownMenuTableView layoutIfNeeded];
		[_dropdownMenuTableView setHidden:true];
	}
	else if(numOptions < maxOptions)
	{
		[_tableViewHeightConstraint setConstant:(numOptions * 44)];
		[_dropdownMenuTableView layoutIfNeeded];
		[_dropdownMenuTableView setHidden:false];
	}
	else
	{
		[_tableViewHeightConstraint setConstant:(maxOptions * 44)];
		[_dropdownMenuTableView layoutIfNeeded];
		[_dropdownMenuTableView setHidden:false];
	}
	
	// Tell the UITableView to refresh.
	[_dropdownMenuTableView reloadData];
}

// Hides the tableView
- (void) hideDropDownMenu
{
	[_dropdownMenuTableView setHidden:true];
}
//--------------------------------------------------------------------------------------------------------------------------
// UITextField Delegate Methods
//--------------------------------------------------------------------------------------------------------------------------
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	[_dropdownMenuTableView setHidden:false];
	[self filterOptionsForText:[textField text]];
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
	[_dropdownMenuTableView setHidden:true];
}

- (BOOL) textFieldShouldClear:(UITextField *)textField
{
	[self filterOptionsForText:@""];
	[_dropdownMenuTableView setHidden:false];
	return true;
}

- (void)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(nonnull NSString *)string
{
	// Buidling the final string that the textField will contain.
	NSString *finalString = [[textField text] stringByReplacingCharactersInRange:range withString:string];
	
	// Filter the available options:
	[self filterOptionsForText:finalString];
	
	NSLog(@"ROC changeChars: range:%@, repcement:%@",NSStringFromRange(range),string);
}
//--------------------------------------------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------------------------------------------
// UITableView DataSource Methods
//--------------------------------------------------------------------------------------------------------------------------
- (NSInteger) numberOfSectionsInTableView:(UITableView *) tableView
{
	return 1;
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [_activeDropdownMenuOptions count];
}
- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger) section
{
	// Example of how to add a header:
	//if(section == 0) return @"test";
	return nil;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
	// Used as an ID for reusable table cells.
	NSString *cellIdentifier = @"rocCellId";
	
	UITableViewCell *cell = nil;
	
	// This will attempt to dequeue a reusable cell, or create a new one (always returns a valid cell)
	cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
	
	// Style the cell:
	[[cell textLabel] setText:[_activeDropdownMenuOptions objectAtIndex:[indexPath row]]];
	[[cell textLabel] setTextColor:[UIColor whiteColor]];
	[cell setBackgroundColor:[UIColor clearColor]];
	
	return cell;
}
//--------------------------------------------------------------------------------------------------------------------------
// UITableView Delegate Methods
//--------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	NSLog(@"ROC Selected option: %@", [_activeDropdownMenuOptions objectAtIndex:[indexPath row]]);
	// Set the text view's text:
	[_textField setText: [_activeDropdownMenuOptions objectAtIndex:[indexPath row]]];
	// Deselect the tableView cell
	[tableView deselectRowAtIndexPath:indexPath animated:true];
	// Hide the tableView
	[tableView setHidden:true];
}
//--------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------
@end


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// CheckBoxTableViewController
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// This class is the datasource and delegate for a tableview that adds checkboxes
@implementation CheckBoxTableViewController
// Sets up the object
- (id) initForTableView:(UITableView*)tableView withOptions:(NSArray*)options
{
	self = [super init];

	
	[tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"rocCellId"];
	
	_tableViewOptions = [NSMutableArray arrayWithArray:options];
	
	_selectedTableViewOptions = [NSMutableArray new];

	
	[tableView setDelegate:self];
	[tableView setDataSource:self];
	[tableView reloadData];
	
	[tableView setBackgroundColor:[UIColor colorWithRed:0.078 green:0.137 blue:0.173 alpha:1.0]];

	
	return self;
}

//--------------------------------------------------------------------------------------------------------------------------
// UITableView DataSource Methods
//--------------------------------------------------------------------------------------------------------------------------
- (NSInteger) numberOfSectionsInTableView:(UITableView *) tableView
{
	return 1;
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [_tableViewOptions count];
}
- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger) section
{
	return nil;
}
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
	// Used as an ID for reusable table cells.
	NSString *cellIdentifier = @"rocCellId";
	
	UITableViewCell *cell = nil;
	
	// This will attempt to dequeue a reusable cell, or create a new one (always returns a valid cell)
	cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];

	// TODO - add a checkbox to the cell.
	
	// Style the cell:
	NSString *cellText = [_tableViewOptions objectAtIndex:[indexPath row]];
	[[cell textLabel] setText:cellText];
	[[cell textLabel] setTextColor:[UIColor whiteColor]];
	[cell setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.0]];
	
	// Getting whether or not the cell should be selected:
	
	// If the option is selected, add a checkmark
	if([_selectedTableViewOptions containsObject:cellText])
	{
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
	// Else, remove any checkmarks
	else
	{
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
	return cell;
}
//--------------------------------------------------------------------------------------------------------------------------
// UITableView Delegate Methods
//--------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	NSLog(@"ROC Selected option: %@", [_tableViewOptions objectAtIndex:[indexPath row]]);
	[tableView deselectRowAtIndexPath:indexPath animated:true];
	
	
	NSString *tappedOption = [_tableViewOptions objectAtIndex:[indexPath row]];
	
	// If the option is selected: remove it
	if([_selectedTableViewOptions containsObject:tappedOption])
	{
		[_selectedTableViewOptions removeObject:tappedOption];
		[tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
	}
	// Else, add it
	else
	{
		[_selectedTableViewOptions addObject:tappedOption];
		[tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
	}
}
@end


//============================================================================================================================================================





//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// StringPickerViewController
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// This class is the datasource and delegate for a pickerview
@implementation StringPickerViewController


// TODO TODO TODO
// Once OK is clicked, update the contents of _textField
// TODO TODO TODO


- (id) initForTextField:(UITextField*)textField withOptions:(NSArray*)options andROCViewController:(ReportOnConditionViewController*)rocViewController
{
	self = [super init];

	_textField = textField;
	_rocViewController = rocViewController;
	_spinnerOptions = [NSMutableArray arrayWithArray:options];
	
	return self;
}

// Executed by the UIAlertAction OK button
- (void) alertClickDone
{
	if(_selectedPickerString != nil)
	{
		[_textField setText: _selectedPickerString];
	}
}

// Executed by the UIAlertAction Cancel button
- (void) alertClickCancel
{
	// They clicked cancel, don't do anything (leave whatever was in the textField there)
}

// Executed when the user taps on the text field to show the picker dialog
- (void) showAlert
{
	// Creating the alertController for the picker dialog
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Title" message:nil preferredStyle:UIAlertControllerStyleAlert];
	
	
	// Adding OK button
	UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
											    handler:^(UIAlertAction * action) { [self alertClickDone];}];
	
	[alertController addAction:confirmAction];
	
	// Adding Cancel button
	UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
											   handler:^(UIAlertAction * action) { [self alertClickCancel];}];
	
	[alertController addAction:cancelAction];
	
	// Creating the pickerView
	UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
	
	[pickerView setDataSource: self];
	[pickerView setDelegate: self];
	
	
	// Adding as subview to the alert
	[alertController.view addSubview:pickerView];

	//-------------------------------------------------------------------------
	// Creating Constraints to resize the alertview
	//-------------------------------------------------------------------------
	
	// Making the alert be a certain height:
	NSLayoutConstraint *heightConstraint = [NSLayoutConstraint
									constraintWithItem:alertController.view
									attribute:NSLayoutAttributeHeight
									relatedBy:NSLayoutRelationEqual
									toItem:nil
									attribute:NSLayoutAttributeNotAnAttribute
									multiplier:1.0f
									constant:200];
	
	NSLayoutConstraint *widthConstraint = [NSLayoutConstraint
								    constraintWithItem:alertController.view
								    attribute:NSLayoutAttributeWidth
								    relatedBy:NSLayoutRelationEqual
								    toItem:nil
								    attribute:NSLayoutAttributeNotAnAttribute
								    multiplier:1.0f
								    constant:300];
	
	
	
	// Ignore the pickerView's frame when resolving constraints
	pickerView.translatesAutoresizingMaskIntoConstraints = false;
	
	
	// Creating constraints for each of the sides
	NSLayoutConstraint *pickerTopConstraint = [NSLayoutConstraint
									   constraintWithItem:pickerView
									   attribute:NSLayoutAttributeTop
									   relatedBy:NSLayoutRelationEqual
									   toItem:alertController.view
									   attribute:NSLayoutAttributeTop
									   multiplier:1.0f
									   constant:40];
	
	NSLayoutConstraint *pickerBottomConstraint = [NSLayoutConstraint
										 constraintWithItem:pickerView
										 attribute:NSLayoutAttributeBottom
										 relatedBy:NSLayoutRelationEqual
										 toItem:alertController.view
										 attribute:NSLayoutAttributeBottom
										 multiplier:1.0f
										 constant:-50];
	
	
	NSLayoutConstraint *pickerLeadingConstraint = [NSLayoutConstraint
										  constraintWithItem:pickerView
										  attribute:NSLayoutAttributeLeading
										  relatedBy:NSLayoutRelationEqual
										  toItem:alertController.view
										  attribute:NSLayoutAttributeLeading
										  multiplier:1.0f
										  constant:30];
	
	NSLayoutConstraint *pickerTrailingConstraint = [NSLayoutConstraint
										   constraintWithItem:pickerView
										   attribute:NSLayoutAttributeTrailing
										   relatedBy:NSLayoutRelationEqual
										   toItem:alertController.view
										   attribute:NSLayoutAttributeTrailing
										   multiplier:1.0f
										   constant:-30];
	
	// Adding the constraints
	[alertController.view addConstraint:heightConstraint];
	[alertController.view addConstraint:widthConstraint];
	// Adding constraints to the pickerview
	[alertController.view addConstraint:pickerTopConstraint];
	[alertController.view addConstraint:pickerBottomConstraint];
	[alertController.view addConstraint:pickerLeadingConstraint];
	[alertController.view addConstraint:pickerTrailingConstraint];
	
	//-------------------------------------------------------------------------
	
	[_rocViewController presentViewController:alertController animated:YES completion:nil];
}

//--------------------------------------------------------------------------------------------------------------------------
// UITextField Delegate Methods
//--------------------------------------------------------------------------------------------------------------------------
- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
	[self showAlert];
	return false;
}

//--------------------------------------------------------------------------------------------------------------------------
// UIPickerView DataSource Methods
//--------------------------------------------------------------------------------------------------------------------------
- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	return [_spinnerOptions objectAtIndex:row];
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return [_spinnerOptions count];
}
//--------------------------------------------------------------------------------------------------------------------------
// UIPickerView Delegate Methods
//--------------------------------------------------------------------------------------------------------------------------
- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	// Store the selected string
	// Don't do anything with it until the user clicks the "OK" button, though.
	_selectedPickerString = [_spinnerOptions objectAtIndex:row];
}

@end




































