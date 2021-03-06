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
//  ViewController.h
//  SidebarDemo
//
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FormView.h"
#import "DataManager.h"

@interface OverviewViewControllerTablet : UIViewController <UIActionSheetDelegate>

@property IBOutlet UIButton *selectIncidentButton;
@property IBOutlet UIButton *selectRoomButton;

@property (weak, nonatomic) IBOutlet UIButton *AddButton;


@property (weak, nonatomic) IBOutlet UIView *RoomCanvas;
@property (weak, nonatomic) IBOutlet UIView *IncidentCanvas;
@property (weak, nonatomic) IBOutlet UILabel *selectIncidentHelperLabel;
@property (weak, nonatomic) IBOutlet UIImageView *collabroomDownArrowImage;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *collabroomsLoadingIndicator;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatViewWidth;
@property DataManager *dataManager;
@property NSTimer *checkSessionIDValidityTimer;


@property UIActionSheet *incidentMenu;
@property UIActionSheet *collabroomMenu;

@property IncidentPayload *selectedIncident;
@property CollabroomPayload *selectedCollabroom;

- (void)showDuplicateLoginWarning:(BOOL)fromFR;
- (IBAction)selectIncidentButtonPressed:(UIButton *)button;
- (IBAction)selectRoomButtonPressed:(UIButton *)button;
- (IBAction)nicsHelpButtonPressed:(id)sender;
- (void)navigateBackToLoginScreen;

@end
