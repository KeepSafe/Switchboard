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

#pragma mark -> UIViewController methodes

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [Switchboard whenReady:^{
    [Switchboard experiment:@"homeScreenMessage" completionBlock:^(NSDictionary *pValues) {
      self.messageText.text = [pValues objectForKey:@"message"];
      self.messageTitle.text = [pValues objectForKey:@"messageTitle"];
      
      NSLog(@"Got values:");
      NSLog(@"Message: %@", self.messageText.text);
      NSLog(@"MessageTitle: %@", self.messageTitle.text);
    }];
  }];
}

@end