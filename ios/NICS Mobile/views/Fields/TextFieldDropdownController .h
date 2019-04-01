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
//  TextFieldDropdownController .h
//  SCOUT Mobile
//
//  Created by Luis Gutierrez on 4/1/19.
//  Copyright © 2019 MIT Lincoln Labs. All rights reserved.
//

#ifndef TextFieldDropdownController__h
#define TextFieldDropdownController__h


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// TextFieldDropdownController
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// This class sets up a textField for autocomplete dropdowns
// use it via makeAutocompleteTextField: withOptions:
@interface TextFieldDropdownController : NSObject <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

// Sets up the object to provide dropdown support for textField
- (nullable id) initForTextField:(nonnull UITextField *)textField withOptions:(nonnull NSArray*)options;

@property (nonnull, nonatomic) UITextField *textField;
@property (nonnull, nonatomic) UITableView *dropdownMenuTableView;
// Contains all options
@property (nonnull) NSMutableArray *dropdownMenuOptions;
// Contains only the filtered options based on the textField's contents
@property (nonnull) NSMutableArray *activeDropdownMenuOptions;
@property (nonnull) NSLayoutConstraint *tableViewHeightConstraint;

// Filters the dropdownMenuOptions array and updates the activeDropdownMenuOptions
// Notifies the UITableView that the options have changed.
- (void) filterOptionsForText:(nullable NSString*)text;
// Hides the dropdownmenu table view (This is used when a form section is collapsed)
- (void) hideDropDownMenu;


//--------------------------------------------------------------------------------------------------------------------------
// UITextField Delegate Methods
//--------------------------------------------------------------------------------------------------------------------------
- (void)textFieldDidBeginEditing:(nonnull UITextField *)textField;
- (void) textFieldDidEndEditing:(nonnull UITextField *)textField;
- (BOOL) textFieldShouldClear:(nonnull UITextField *)textField;
- (void)textField:(nonnull UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(nonnull NSString *)string;
//--------------------------------------------------------------------------------------------------------------------------
// UITableView DataSource Methods
//--------------------------------------------------------------------------------------------------------------------------
- (NSInteger) numberOfSectionsInTableView:(nonnull UITableView *) tableView;
- (NSInteger) tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (nullable NSString *) tableView:(nonnull UITableView *)tableView titleForHeaderInSection:(NSInteger) section;
- (nonnull UITableViewCell *) tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath;
//- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath;
//--------------------------------------------------------------------------------------------------------------------------
// UITableView Delegate Methods
//--------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(nonnull UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath;
@end


#endif /* TextFieldDropdownController__h */
