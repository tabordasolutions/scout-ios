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
//  DateTimePicker.m
//  SCOUT Mobile
//
//  Created by Luis Gutierrez on 4/22/19.
//  Copyright © 2019 MIT Lincoln Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DateTimePickerController.h"

@implementation DateTimePickerController


// Sets up the object to provide dropdown support for textField
- (nullable id) initForTextField:(nonnull UITextField *)textField andView:(UIViewController*)viewController isTime:(bool)isTime
{
	self = [super init];
	
	_viewController = viewController;
	_textField = textField;
	_isTimePicker = isTime;
	
	
	_alertController = [UIAlertController alertControllerWithTitle:@"Title" message:nil preferredStyle:UIAlertControllerStyleAlert];
	
	
	// Adding OK button
	UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
											    handler:^(UIAlertAction * action) { [self alertDoneClick];}];
	[_alertController addAction:confirmAction];

	// Adding Cancel button
	UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
											   handler:^(UIAlertAction * action) { [self alertCancelClick];}];
	
	[_alertController addAction:cancelAction];
	
	
	_datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
	if(_isTimePicker)
	{
		_datePicker.datePickerMode = UIDatePickerModeTime;
	}
	else
	{
		_datePicker.datePickerMode = UIDatePickerModeDate;
	}
	
	// Sets the date picker to use 24 hour time format by changing the locale
	NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"];
	[_datePicker setLocale:locale];
	
	
	[_alertController.view addSubview:_datePicker];
	
	//-------------------------------------------------------------------------
	// Creating Constraints to resize the alertview
	//-------------------------------------------------------------------------
	
	// Making the alert be a certain height:
	NSLayoutConstraint *heightConstraint = [NSLayoutConstraint
									constraintWithItem:_alertController.view
									attribute:NSLayoutAttributeHeight
									relatedBy:NSLayoutRelationEqual
									toItem:nil
									attribute:NSLayoutAttributeNotAnAttribute
									multiplier:1.0f
									constant:200];
	
	NSLayoutConstraint *widthConstraint = [NSLayoutConstraint
								    constraintWithItem:_alertController.view
								    attribute:NSLayoutAttributeWidth
								    relatedBy:NSLayoutRelationEqual
								    toItem:nil
								    attribute:NSLayoutAttributeNotAnAttribute
								    multiplier:1.0f
								    constant:300];
	
	
	
	_datePicker.translatesAutoresizingMaskIntoConstraints = false;
	//_testDateAlertController.view.translatesAutoresizingMaskIntoConstraints = true;
	
	
	// Creating constraints for each of the sides
	NSLayoutConstraint *pickerTopConstraint = [NSLayoutConstraint
									   constraintWithItem:_datePicker
									   attribute:NSLayoutAttributeTop
									   relatedBy:NSLayoutRelationEqual
									   toItem:_alertController.view
									   attribute:NSLayoutAttributeTop
									   multiplier:1.0f
									   constant:40];
	
	NSLayoutConstraint *pickerBottomConstraint = [NSLayoutConstraint
										 constraintWithItem:_datePicker
										 attribute:NSLayoutAttributeBottom
										 relatedBy:NSLayoutRelationEqual
										 toItem:_alertController.view
										 attribute:NSLayoutAttributeBottom
										 multiplier:1.0f
										 constant:-50];
	
	
	NSLayoutConstraint *pickerLeadingConstraint = [NSLayoutConstraint
										  constraintWithItem:_datePicker
										  attribute:NSLayoutAttributeLeading
										  relatedBy:NSLayoutRelationEqual
										  toItem:_alertController.view
										  attribute:NSLayoutAttributeLeading
										  multiplier:1.0f
										  constant:30];
	
	NSLayoutConstraint *pickerTrailingConstraint = [NSLayoutConstraint
										   constraintWithItem:_datePicker
										   attribute:NSLayoutAttributeTrailing
										   relatedBy:NSLayoutRelationEqual
										   toItem:_alertController.view
										   attribute:NSLayoutAttributeTrailing
										   multiplier:1.0f
										   constant:-30];
	
	// Adding the constraints
	[_alertController.view addConstraint:heightConstraint];
	[_alertController.view addConstraint:widthConstraint];
	// Adding constraints to the pickerview
	[_alertController.view addConstraint:pickerTopConstraint];
	[_alertController.view addConstraint:pickerBottomConstraint];
	[_alertController.view addConstraint:pickerLeadingConstraint];
	[_alertController.view addConstraint:pickerTrailingConstraint];
	//-------------------------------------------------------------------------
	
	
	return self;
}

- (void) alertDoneClick
{
	[self setFieldToCurrentDateTime:[_datePicker date]];
}



- (void) setFieldToCurrentDateTime:(nullable NSDate*)date
{
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	
	if(_isTimePicker)
	{
		formatter.dateFormat = @"HHmm";
	}
	else
	{
		formatter.dateFormat = @"MM/dd/yyyy";
	}
	
	NSString *dateString = [formatter stringFromDate:date];
	
	[_textField setText:dateString];
}




- (void) alertCancelClick
{
	// Do nothing if they clicked "Cancel"
}

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
	// Clearing the border color, if it's set (to clear the red error border)
	textField.layer.borderColor = UIColor.clearColor.CGColor;
	textField.layer.borderWidth = 0.0;
	
	[_viewController presentViewController:_alertController animated:YES completion:nil];
	return false;
}



@end
