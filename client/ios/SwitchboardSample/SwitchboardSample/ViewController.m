//
//  ViewController.m
//  SwitchboardSample
//
//  Created by Chris Beauchamp on 7/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

#import "Switchboard.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize messageTitle;
@synthesize messageText;

- (void) refreshMessage {
    
    SBExperiment *e = [Switchboard getExperiment:@"homeScreenMessage"];
    
    if([e isInExperiment]) {
        
        NSLog(@"isInExperiment homeScreen");
        
        if([Switchboard hasExperimentValues:@"homeScreenMessage"]) {
            
            NSLog(@"has values");
            
            NSDictionary *values = [Switchboard getExperimentValueFromJSON:@"homeScreenMessage"];
            
            messageText.text = [values objectForKey:@"message"];
            messageTitle.text = [values objectForKey:@"messageTitle"];
            
            NSLog(@"Got values:");
            NSLog(@"Message: %@", messageText.text);
            NSLog(@"MessageTitle: %@", messageTitle.text);
            
        }
        
    }
    
}

- (void) viewDidAppear:(BOOL)animated {
    [self refreshMessage];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    [self refreshMessage];
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
