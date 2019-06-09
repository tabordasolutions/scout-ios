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
//  TextFieldDropdownController.m
//  SCOUT Mobile
//
//  Created by Luis Gutierrez on 4/1/19.
//  Copyright © 2019 MIT Lincoln Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TextFieldDropdownController.h"


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
	// Clearing the border color, if it's set (to clear the red error border)
	_textField.layer.borderColor = UIColor.clearColor.CGColor;
	_textField.layer.borderWidth = 0.0;
	
	[_dropdownMenuTableView setHidden:true];
}

- (BOOL) textFieldShouldClear:(UITextField *)textField
{
	// Clearing the border color, if it's set (to clear the red error border)
	_textField.layer.borderColor = UIColor.clearColor.CGColor;
	_textField.layer.borderWidth = 0.0;
	
	[self filterOptionsForText:@""];
	[_dropdownMenuTableView setHidden:false];
	return true;
}

- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(nonnull NSString *)string
{
	// Buidling the final string that the textField will contain.
	NSString *finalString = [[textField text] stringByReplacingCharactersInRange:range withString:string];
	
	// Clearing the border color, if it's set (to clear the red error border)
	_textField.layer.borderColor = UIColor.clearColor.CGColor;
	_textField.layer.borderWidth = 0.0;
	
	// Filter the available options:
	[self filterOptionsForText:finalString];
	
	return true;
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
	[[cell textLabel] setAdjustsFontSizeToFitWidth:true];
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
	// Set the text view's text:
	[_textField setText: [_activeDropdownMenuOptions objectAtIndex:[indexPath row]]];
	[_textField sendActionsForControlEvents:UIControlEventValueChanged];
	[_textField sendActionsForControlEvents:UIControlEventEditingChanged];
	[_textField sendActionsForControlEvents:UIControlEventEditingDidEnd];
	
	// Clearing the border color, if it's set (to clear the red error border)
	_textField.layer.borderColor = UIColor.clearColor.CGColor;
	_textField.layer.borderWidth = 0.0;
	
	// Deselect the tableView cell
	[tableView deselectRowAtIndexPath:indexPath animated:true];
	// Hide the tableView
	[tableView setHidden:true];
}
//--------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------
@end
