//
//  ViewController.m
//  SwitchboardSample
//
//  Created by Chris Beauchamp on 7/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "Switchboard.h"

#pragma mark -
#pragma mark ViewController
#pragma mark -

#pragma mark -> Class Extension
@interface ViewController ()

@end

#pragma mark -> Implementation
@implementation ViewController

#pragma mark -> Private methodes

- (void)refreshMessage {
	if ([Switchboard isInExperiment:@"homeScreenMessage"]) {
		NSLog(@"isInExperiment homeScreen");
    
		if ([Switchboard hasExperimentValues:@"homeScreenMessage"]) {
			NSLog(@"has values");
      
			NSDictionary *values = [Switchboard getExperimentValueFromJSON:@"homeScreenMessage"];
      
			self.messageText.text = [values objectForKey:@"message"];
			self.messageTitle.text = [values objectForKey:@"messageTitle"];
      
			NSLog(@"Got values:");
			NSLog(@"Message: %@", self.messageText.text);
			NSLog(@"MessageTitle: %@", self.messageTitle.text);
		}
	}
}

#pragma mark -> UIViewController methodes

- (void)viewDidAppear:(BOOL)animated {
	[self refreshMessage];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

@end
