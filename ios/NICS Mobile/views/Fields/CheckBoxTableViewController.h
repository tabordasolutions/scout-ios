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
//  CheckBoxTableViewController.h
//  SCOUT Mobile
//
//  Created by Luis Gutierrez on 4/1/19.
//  Copyright © 2019 MIT Lincoln Labs. All rights reserved.
//

#ifndef CheckBoxTableViewController_h
#define CheckBoxTableViewController_h



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// CheckBoxTableViewController
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


// This class is the datasource and delegate for a tableview that adds checkboxes
@interface CheckBoxTableViewController : NSObject <UITableViewDataSource, UITableViewDelegate>
// Sets up the object
- (id) initForTableView:(UITableView*)tableView withOptions:(NSArray*)options withSelector:(SEL)selector andTarget:(id)target;
// Contains the tableview
@property (nonnull) UITableView *tableView;
// Contains all options
@property (nonnull) NSMutableArray *tableViewOptions;
// Contains the options that are selected
@property (nonnull) NSMutableArray *selectedTableViewOptions;
// Whether or not the table view checkboxes can be checked
@property bool checkboxesEnabled;
// OnChange selector
@property SEL onChangeSelector;
@property id onChangeSelectorTarget;

- (void) deselectAllCheckboxes;
// Returns the list of selected strings
- (nonnull NSArray*) getSelectedOptions;
// Selects the checkboxes for desired strings, deselects all other checkboxes
- (void) setSelectedOptions:(nonnull NSArray*)options;
//--------------------------------------------------------------------------------------------------------------------------
// UITableView DataSource Methods
//--------------------------------------------------------------------------------------------------------------------------
- (NSInteger) numberOfSectionsInTableView:(nonnull UITableView *) tableView;
- (NSInteger) tableView:(nonnull  UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (nullable NSString *) tableView:(nullable UITableView *)tableView titleForHeaderInSection:(NSInteger) section;
- (nonnull UITableViewCell *) tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath;
//--------------------------------------------------------------------------------------------------------------------------
// UITableView Delegate Methods
//--------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(nonnull UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath*)indexPath;
@end


#endif /* CheckBoxTableViewController_h */
