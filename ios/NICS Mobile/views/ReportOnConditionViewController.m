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
	StringPickerViewController *viewController = [[StringPickerViewController alloc] initForTextField:textField withOptions:options andViewController:self];
	
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












































