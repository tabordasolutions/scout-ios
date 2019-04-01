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
//  ReportOnConditionViewController.h
//  SCOUT Mobile
//


//#import <UIKit/UIKit.h>
//#import "AssetsLibrary/AssetsLibrary.h"
#import "DataManager.h"
#import "Fields/TextFieldDropdownController .h"
#import "Fields/CheckBoxTableViewController.h"
#import "Fields/StringPickerViewController.h"

//#import "SimpleReportPayload.h"
//#import "FormSpinner.h"
//#import "Enums.h"
//#import "IncidentButtonBar.h"


@interface ReportOnConditionViewController : UIViewController <UISplitViewControllerDelegate, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

//=============================================================================
// Section Headers / Views
//=============================================================================
@property IBOutlet UIView *section1HeaderView;
@property IBOutlet UIImageView *section1HeaderArrowImage;
@property IBOutlet UIView *section1ContentView;
@property IBOutlet UIImageView *section1HeaderErrotableviwrImage;


@property IBOutlet UIView *section2HeaderView;
@property IBOutlet UIImageView *section2HeaderArrowImage;
@property IBOutlet UIView *section2ContentView;
@property IBOutlet UIImageView *section2HeaderErrorImage;
//=============================================================================


//=============================================================================
// Test Variables -  TODO - REMOVE THESE
//=============================================================================
//-----------------------------------------------------------------------------
// Test Dynamic Text Boxes Variables
//-----------------------------------------------------------------------------

@property IBOutlet UIButton *testButton;
@property IBOutlet UIStackView *testStackView;

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *testHeightConstraint;

//-----------------------------------------------------------------------------
// Test Dropdown Variables
//-----------------------------------------------------------------------------
@property IBOutlet UITextField *dropdownTextField;
// Keeping strong references to each delegate so they don't get garbage collected
@property NSMutableArray *delegatesArray;
- (void) makeAutocompleteTextField:(UITextField*)textField withOptions:(NSArray*)options;
//=============================================================================

//-----------------------------------------------------------------------------
// Test Checkbox Tableview variables
//-----------------------------------------------------------------------------
@property IBOutlet UITableView *checkboxTableView;

//-----------------------------------------------------------------------------
// Test Picker Field
//-----------------------------------------------------------------------------
@property UIAlertController *testDateAlertController;
@property UIDatePicker *testDatePicker;


@property UIAlertController *testAlertController;
@property UIPickerView *testPickerView;

- (void) makeStringPickerTextField:(UITextField *)textView withOptions:(NSArray*)options;


- (void) dateAlertControllerDoneClick;
- (void) dateAlertControllerCancelClick;
- (void) createDateAlertController;


- (void) alertControllerDoneClick;
- (void) alertControllerCancelClick;
//- (void) createAlertController;


@property IBOutlet UITextField *testCountiesField;


//-----------------------------------------------------------------------------
// Test Checkbox Fields
//-----------------------------------------------------------------------------
@property IBOutlet UIButton *testCheckbox;

@property BOOL checkboxSelected;
- (void) checkBoxTapped:(id) obj;

//=============================================================================
// Section Variables
//=============================================================================
//---------------------------------------------------------------------------
// ROC Form Info Fields
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
// Incident Info Fields
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
// ROC Incident Info Fields
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
// Vegetation Fire Incident Scope Fields
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
// Weather Information Fields
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
// Threats & Evacuations Fields
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
// Resource Commitment Fields
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
// Other Significant Info Fields
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
// Email Fields
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------


//=============================================================================


@property DataManager *dataManager;



@property IBOutlet UIButton *submitButton;
@property IBOutlet UIButton *cancelButton;


// View holding the submit and cancel buttons
@property IBOutlet UIView *buttonView;


// TODO - implement this:
- (IBAction)submitReportButtonPressed:(UIButton *)button;
- (void)submitTabletReportButtonPressed;

// TODO - implement this:
- (IBAction)cancelButtonPressed:(UIButton *)button;
- (void)cancelTabletButtonPressed;


// Builds a UITapGestureRecognizer for use on each section
- (UITapGestureRecognizer*) newTapRecognizer;
// Called each time a section header is clicked
// Is responsible for toggling the visibility of the appropriate section
// and collapsing all other sections
- (void) toggleCollapsibleSection:(UIGestureRecognizer*)sender;
// Collapses all report sections
- (void) collapseAllSections;


// TEST ACTION
- (IBAction)testButtonPush:(UIButton *)button;
- (IBAction)testButtonPush2:(UIButton *)button;


//@property IBOutlet UIScrollView *scrollView;


//@property (strong, nonatomic) SimpleReportPayload *payload;
//@property ALAssetsLibrary *assetsLibrary;
//@property NSString *imagePath;
//@property BOOL isImageSaved;
//@property UIView *focusedTextView;
//@property CGRect originalFrame;

//@property IBOutlet UIActivityIndicatorView *imageLoadingView;

/*@property IBOutlet UIView *locationButtonView;
 @property IBOutlet UIView *buttonView;
 @property (weak, nonatomic) IBOutlet UIView *contentView;
 
 @property IBOutlet UIButton *saveAsDraftButton;
 @property IBOutlet UIButton *submitButton;
 @property IBOutlet UIButton *cancelButton;
 @property IBOutlet UIImageView *imageView;
 @property IBOutlet UITextField *latitudeView;
 @property IBOutlet UITextField *longitudeView;
 @property IBOutlet FormSpinner *categoryView;
 @property IBOutlet UITextView *descriptionView;*/


/*@property IBOutlet UIButton createRocButton;
 @property IBOutlet UIButton viewRocButton;
 
 //@property IBOutlet UIView *imageSelectionView;
 //@property IBOutlet NSLayoutConstraint *paddingTopConstraint;
 
 - (IBAction)captureImagePressed:(UIButton *)button;
 - (IBAction)browseGalleryPressed:(UIButton *)button;
 
 - (IBAction)lrfButtonPressed:(UIButton *)button;
 - (IBAction)gpsButtonPressed:(UIButton *)button;
 
 - (IBAction)submitReportButtonPressed:(UIButton *)button;
 - (void)submitTabletReportButtonPressed;
 - (IBAction)saveDraftButtonPressed:(UIButton *)button;
 - (void)saveTabletDraftButtonPressed;
 - (IBAction)cancelButtonPressed:(UIButton *)button;
 - (void)cancelTabletButtonPressed;
 
 - (SimpleReportPayload *)getPayload:(BOOL)isDraft;
 - (void) configureView;
 
 @property BOOL hideEditControls;*/

@end

