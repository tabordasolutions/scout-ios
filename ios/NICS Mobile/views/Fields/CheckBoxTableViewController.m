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
//  CheckBoxTableViewController.m
//  SCOUT Mobile
//
//  Created by Luis Gutierrez on 4/1/19.
//  Copyright © 2019 MIT Lincoln Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CheckBoxTableViewController.h"

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
