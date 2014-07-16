//
//  SBPreferences.m
//  SwitchboardSample
//
//  Created by Chris Beauchamp on 7/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SBPreferences.h"

#define sbServerURL     @"switchboard-preference-server-url"
#define sbMainURL       @"switchboard-preference-launch-count"
#define sbConfigJSON    @"switchboard-preference-config-json"

@implementation SBPreferences

+ (void)setServerURL:(NSString *)serverURL andMainURL:(NSString *)mainURL {
  [[NSUserDefaults standardUserDefaults] setObject:serverURL forKey:sbServerURL];
  [[NSUserDefaults standardUserDefaults] setObject:mainURL forKey:sbMainURL];
  
  [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)getServerURL {
  return [[NSUserDefaults standardUserDefaults] stringForKey:sbServerURL];
}

+ (NSString *)getMainURL {
  return [[NSUserDefaults standardUserDefaults] stringForKey:sbMainURL];
}

+ (void)setConfigurationJSON:(NSDictionary *)json {
  NSError *lError = nil;
  NSData  *lData = [NSJSONSerialization dataWithJSONObject:json options:kNilOptions error: &lError];
  
  [[NSUserDefaults standardUserDefaults] setObject:lData forKey : sbConfigJSON];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSDictionary *)getConfigurationJSON {
  NSError      *lError = nil;
  NSData       *lData = [[NSUserDefaults standardUserDefaults] dataForKey:sbConfigJSON];
  NSDictionary *lRet = nil;
  
  if (lData) {
    lRet = [NSJSONSerialization JSONObjectWithData:lData options:kNilOptions error: &lError];
  }
  
  return lRet;
}

@end