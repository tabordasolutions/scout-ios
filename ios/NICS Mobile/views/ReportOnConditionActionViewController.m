//
//  ReportOnConditionActionViewController.m
//  SCOUT Mobile
//
//  Created by Luis Gutierrez on 2/8/19.
//  Copyright © 2019 MIT Lincoln Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ReportOnConditionActionViewController.h"


@implementation ReportOnConditionActionViewController


- (void)viewDidLoad
{
	[super viewDidLoad];
	
	_dataManager = [DataManager getInstance];
}


- (IBAction)createRocButtonPressed:(id)sender
{
	NSLog(@"Create ROC Button Pressed");
	
	
	// if ipad, we're going to call incidentcanvasview to replace the the view
	if(_dataManager.isIpad)
	{
		[IncidentCanvasUIViewController goToCreateReportOnCondition];
		return;
	}
	
	[ReportOnConditionViewController setViewControllerViewingMode:false];
	[self performSegueWithIdentifier:@"segue_roc_form" sender:self];
}

- (IBAction)viewRocButtonPressed:(id)sender
{
	NSLog(@"View ROC Button Pressed");
	
	// if ipad, we're going to call incidentcanvasview to replace the the view
	if(_dataManager.isIpad)
	{
		[IncidentCanvasUIViewController goToViewReportOnCondition];
		return;
	}
	
	[ReportOnConditionViewController setViewControllerViewingMode:true];
	[self performSegueWithIdentifier:@"segue_roc_form" sender:self];
}
@end
