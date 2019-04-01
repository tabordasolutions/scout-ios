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
//  StringPickerViewController.m
//  SCOUT Mobile
//
//  Created by Luis Gutierrez on 4/1/19.
//  Copyright © 2019 MIT Lincoln Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StringPickerViewController.h"

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


- (id) initForTextField:(UITextField*)textField withOptions:(NSArray*)options andViewController:(UIViewController*)viewController
{
	self = [super init];
	
	_textField = textField;
	_viewController = viewController;
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
	
	[_viewController presentViewController:alertController animated:YES completion:nil];
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


