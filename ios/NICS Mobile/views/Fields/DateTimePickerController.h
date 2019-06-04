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
//  DateTimePicker.h
//  SCOUT Mobile
//
//  Created by Luis Gutierrez on 4/22/19.
//  Copyright © 2019 MIT Lincoln Labs. All rights reserved.
//

// This class sets up a textField to be a date or time picker
@interface DateTimePickerController : NSObject <UITextFieldDelegate>

// Sets up the object to provide dropdown support for textField
- (nullable id) initForTextField:(nonnull UITextField *)textField andView:(nonnull UIViewController*)viewController isTime:(bool)isTime;

// Whether or not the datepicker should only allow time values
@property bool isTimePicker;
// The textField to operate on
@property (nonnull, nonatomic) UITextField *textField;

// The view controller used to show the view
@property (nonnull) UIViewController *viewController;
// The controller responsible for
@property (nonnull) UIAlertController *alertController;
// The date picker itself
@property (nonnull) UIDatePicker *datePicker;
// Callback for pressing "Done" on the alert
- (void) alertDoneClick;
// Sets the field's date / time to a desired NSDate object
- (void) setFieldToCurrentDateTime:(nullable NSDate*)date;
// Callback for pressing "Cancel" on the alert
- (void) alertCancelClick;
// Delegate method to show the dialog on tap
- (BOOL) textFieldShouldBeginEditing:(nonnull UITextField *)textField;


@end
