/*|~^~|Copyright (c) 2008-2015, Massachusetts Institute of Technology (MIT)
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
//  DetailViewController.h
//  PHINICS
//
//

#import <UIKit/UIKit.h>
#import "FormView.h"
#import "FormEditText.h"
#import "DataManager.h"
#import "FieldReportPayload.h"
#import "Enums.h"

@interface FieldReportDetailViewController : UIViewController

@property (strong, nonatomic) FieldReportPayload *payload;
@property BOOL hideEditControls;

@property IBOutlet FormView *formView;
@property IBOutlet UIView *buttonView;

@property IBOutlet UIButton *saveAsDraftButton;
@property IBOutlet UIButton *submitButton;
@property IBOutlet UIButton *cancelButton;

@property IBOutlet NSLayoutConstraint *bottomConstraint;

@property DataManager *dataManager;

- (void)configureView;

- (IBAction)submitReportButtonPressed:(UIButton *)button;
- (void)submitTabletReportButtonPressed;

- (IBAction)saveDraftButtonPressed:(UIButton *)button;
- (void)saveTabletDraftButtonPressed;

- (IBAction)cancelButtonPressed:(UIButton *)button;
- (void)cancelTabletButtonPressed;

- (FieldReportPayload *)getPayload:(BOOL)isDraft;
@end
