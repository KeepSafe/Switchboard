//
//  SBPreferences.h
//  SwitchboardSample
//
//  Created by Chris Beauchamp on 7/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SBPreferences : NSObject

+ (void) setServerURL:(NSString *)serverURL andMainURL:(NSString *)mainURL;

+ (NSString *) getServerURL;
+ (NSString *) getMainURL;

+ (void) setConfigurationJSON:(NSDictionary *)json;
+ (NSDictionary *) getConfigurationJSON;

@end