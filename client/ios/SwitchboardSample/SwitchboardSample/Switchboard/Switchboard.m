//
//  Switchboard.m
//  SwitchboardSample
//
//  Created by Chris Beauchamp on 7/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Switchboard.h"

#import "SBPreferences.h"
#import "NSString+Switchboard.h"

#import "SBJson.h"
#import "OpenUDID.h"

@interface Switchboard()

// This is used throughout the class, but never from outside.
// Make a 'private' definition here.
+ (Switchboard*) sharedInstance;

@end



@implementation Switchboard

// the variable to hold our singleton instance
static Switchboard *sharedInstance = nil;


// A convenience method to store the local URL strings to 
// the persistent preferences file (if these prefs don't already exist)
- (void) storeDefaultURLsInPreferences {
    
    // get the defaults from the prefs file
    NSString *serverURL = [SBPreferences getServerURL];
    NSString *mainURL = [SBPreferences getMainURL];
    
    // if there's no server URL
    if(serverURL == nil) {
        
        // store the local var
        serverURL = _serverURL;
    }
    
    // if there's no main URL
    if(mainURL == nil) {
        
        // store the local var
        mainURL = _mainURL;
    }
    
    // save these prefs
    [SBPreferences setServerURL:serverURL andMainURL:mainURL];

}

+ (BOOL) isInExperiment:(NSString*)experimentName withDefault:(BOOL)defaultValue {
    
    // get the dictionary containing the current configuration
    NSDictionary *json = [SBPreferences getConfigurationJSON];
    
    // if the dictionary exists
    if(json != nil) {
        
        // print a log if we're debugging
        if([Switchboard isInDebugMode]) {
            SBLog(@"Experiment '%@' JSON Object: %@", experimentName, json);
        }
        
        // wrap in try/catch in case either of these keys don't exist or are typed incorrectly
        @try {
            
            // get the experiment dictionary
            NSDictionary *experiment = [json objectForKey:experimentName];
            
            // determine if this experiment is active
            defaultValue = [[experiment objectForKey:sbExperimentActiveKey] boolValue];
        }
        
        // one of the keys was invalid
        @catch (NSException *exception) {
            if([Switchboard isInDebugMode]) { SBLog(@"Unable to parse json for experiment: %@", experimentName); }
        }
        
    }
    
    // print the result if we're debugging
    if([Switchboard isInDebugMode]) { SBLog(@"In Experiment '%@': %d", experimentName, defaultValue?1:0); }
    
    // return the final value
    return defaultValue;
}

+ (BOOL) isInExperiment:(NSString*)experimentName {
    
    // pass thru to the 'full' method
    return [Switchboard isInExperiment:experimentName withDefault:FALSE];
}

+ (BOOL) hasExperimentValues:(NSString*)experimentName {
    
    // Convenience method for dev to quickly check if experiment values exist.
    // If not nil, values do exist.
    return [Switchboard getExperimentValueFromJSON:experimentName] != nil;
}

+ (NSDictionary*) getExperimentValueFromJSON:(NSString*)experimentName {
    
    // default to nil
    NSDictionary *returnValues = nil;
    
    // load the configuration
    NSDictionary *config = [SBPreferences getConfigurationJSON];
    
    // if we have a valid config
    if(config != nil) {

        // extract the experiment values
        NSDictionary *experiment = [config objectForKey:experimentName];
        
        // get the return values
        returnValues = [experiment objectForKey:sbExperimentValues];        
    }
    
    return returnValues;
}

- (BOOL) isInDebugMode {
    return _debug;
}

+ (BOOL) isInDebugMode {
    
    // the static call must access the value in our singleton
    return [[Switchboard sharedInstance] isInDebugMode];
}

#pragma mark server sync
- (void) updateServerURLs {
    
    // if we're debugging, this method won't do a server call.
    // it is assumed the developer has set proper URLs in the beginWithServerURL:... method
    if(_debug) {
        
        SBLog(@"Update server URLs");
        
        // set default value that is set in code
        [SBPreferences setServerURL:_serverURL andMainURL:_mainURL];
        return;
    }
    
    // get the current server url to access from prefs
    NSString *urlString = [SBPreferences getServerURL];
    
    // set to default when not set in preferences
    if(urlString == nil) {
        urlString = _serverURL;
    }
    
    // set up our request
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];

    // make an async connection on our request queue.
    [NSURLConnection sendAsynchronousRequest:urlRequest 
                                       queue:_requestQueue 
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               // got data
                               if ([data length] > 0 && error == nil) {
                                   
                                   // convert the NSData value into a readable string
                                   NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                   
                                   // print response if debugging
                                   if(_debug) { SBLog(@"Response: %@", responseString); }
                                   
                                   // generate a dict out of the response json
                                   NSDictionary *json = [responseString JSONValue];
                                   
                                   // make sure we were able to parse the json
                                   if(json != nil) {

                                       // read the new server values from the json
                                       NSString *updateServerURL = [json objectForKey:sbUpdateServerURLKey];
                                       NSString *configServerURL = [json objectForKey:sbConfigServerURLKey];
                                       
                                       // update the preferences
                                       [SBPreferences setServerURL:updateServerURL andMainURL:configServerURL];
                                       
                                       // print results if debugging
                                       if(_debug) {
                                           SBLog(@"Updated server url: %@", updateServerURL);
                                           SBLog(@"Updated config url: %@", configServerURL);
                                       }

                                   }
                                   
                                   // there was an error parsing the response
                                   else {
                                       
                                       // load the default values into preferences
                                       [self storeDefaultURLsInPreferences];
                                       
                                       if(_debug) {
                                           SBLog(@"Error updating server URLs: Could not parse response");
                                       }
                                   }
                                   
                               } 
                               
                               // something went wrong
                               else {
                                   
                                   // load the default values into preferences
                                   [self storeDefaultURLsInPreferences];
                                   
                                   if(_debug) {
                                       SBLog(@"Error updating server URLs: %@", error);
                                   }
                               }
                           
                           }];
    
}

+ (void) updateServerURLs {
    [[Switchboard sharedInstance] updateServerURLs];
}

- (void) downloadConfiguration:(NSString*)uuid {
    
    // debugging, print status
    if(_debug) { SBLog(@"Downloading app configuration"); }
    
    // if the developer hasn't provided a uuid, use our default uuid
    if(uuid == nil) {           
        uuid = [OpenUDID value];
    }

    // get the current user's locale
    NSLocale *l = [NSLocale currentLocale];
    
    // get some bundle information for the app
    NSDictionary *appInfo = [[NSBundle mainBundle] infoDictionary];
    
    // load params for sending to the server
    NSString *device = [UIDevice currentDevice].model;
    NSString *manufacturer = @"Apple";
    NSString *language = [l objectForKey:NSLocaleLanguageCode];
    NSString *country = [l objectForKey:NSLocaleCountryCode];
    NSString *packageName = [appInfo objectForKey:@"CFBundleIdentifier"]; // Ex: com.KeepSafe.KeepSafe
    NSString *versionName = [appInfo objectForKey:@"CFBundleShortVersionString"]; // Ex: 1.2.4

    // get the main url from preferences
    NSString *urlString = [SBPreferences getMainURL];

    // Setup the params for the url query string
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:uuid forKey:@"uuid"];
    [params setObject:device forKey:@"device"];
    [params setObject:language forKey:@"lang"];
    
    if (country != nil) {
        [params setObject:country forKey:@"country"];
    }
    
    [params setObject:manufacturer forKey:@"manufacturer"];
    [params setObject:packageName forKey:@"appId"];
    [params setObject:versionName forKey:@"version"];
    
    // print debug log
    if(_debug) { SBLog(@"Sending params for configuration: %@", params); }
    
    // build the query string
    NSString *queryString = @"?";
    
    // iterate through the keys in the parameters
    for(NSString *key in [params allKeys]) {
        
        // append the format to the query string
        queryString = [queryString stringByAppendingFormat:@"%@=%@&", key, [[params objectForKey:key] urlEncode]];
    }
    
    // append the query string to the url string
    urlString = [urlString stringByAppendingString:queryString];
    
    // print debug log
    if(_debug) { SBLog(@"Calling url: %@", urlString); }
    
    // construct our request
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    
    // send the request asynchronously
    [NSURLConnection sendAsynchronousRequest:urlRequest 
                                       queue:_requestQueue // use our request queue. this throttles so we minimize footprint
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               // got data
                               if ([data length] > 0 && error == nil) {
                                   
                                   // convert the NSData value into a readable string
                                   NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                   
                                   // print debug log
                                   if(_debug) { SBLog(@"Response: %@", responseString); }

                                   // parse the response string into a json dictionary
                                   NSDictionary *json = [responseString JSONValue];
                                   
                                   // store the config to persistent preferences
                                   if(json != nil) {
                                       [SBPreferences setConfigurationJSON:json];                                       

                                       // print debug
                                       if(_debug) { SBLog(@"Updated server config: %@", json); }

                                   }
                                   
                                   // there was an error parsing the response
                                   else {
                                       
                                       if(_debug) {
                                           SBLog(@"Error updating configuration: unable to parse response");
                                       }
                                       
                                   }
                                                                      
                                   
                               } 
                               
                               // error occurred
                               else {

                                   if(_debug) {
                                       SBLog(@"Error updating configuration: %@", error);
                                   }
                               }
                               
                           }];

}

+ (void) downloadConfigurationWithCustomUUID:(NSString*)uuid {
    [[Switchboard sharedInstance] downloadConfiguration:uuid];
}

+ (void) downloadConfiguration {
    [Switchboard downloadConfigurationWithCustomUUID:nil];
}

#pragma mark initialization
- (void) beginWithServerURL:(NSString*)serverURL 
          andServerURLStage:(NSString*)serverURLStage 
                 andMainURL:(NSString*)mainURL 
            andMainURLStage:(NSString*)mainURLStage 
                   andDebug:(BOOL)debug {
    
    // set up our operation queue
    _requestQueue = [[NSOperationQueue alloc] init];
    
    // limit to 1 request at a time. we don't want to use too much of the app's resources
    [_requestQueue setMaxConcurrentOperationCount:1];
    
    
    // keep the debug variable locally
    _debug = debug;

    // keep the urls around locally
    _serverURL = [serverURL retain];
    _mainURL = [mainURL retain];
    
    // if we were passed a staging server and we're in debug mode
    if(serverURLStage != nil && debug) {
        
        // use the stage as the default server
        _serverURL = [serverURLStage retain];
    }
    
    // if we were passed a staging server and we're in debug mode
    if(mainURLStage != nil && debug) {

        // use the stage as the default server
        _mainURL = [mainURLStage retain];
    }
    
    // store the strings in the persistent preference file
    [self storeDefaultURLsInPreferences];

}

+ (void) beginWithServerURL:(NSString*)serverURL 
          andServerURLStage:(NSString*)serverURLStage
                 andMainURL:(NSString*)mainURL 
            andMainURLStage:(NSString*)mainURLStage
                   andDebug:(BOOL)debug {
    
    // initialize the engine
    [[Switchboard sharedInstance] beginWithServerURL:serverURL 
                                   andServerURLStage:serverURLStage 
                                          andMainURL:mainURL 
                                     andMainURLStage:mainURLStage 
                                            andDebug:debug];
    
}

+ (void) beginWithServerURL:(NSString*)serverURL 
                 andMainURL:(NSString*)mainURL 
                   andDebug:(BOOL)debug {
    
    // initialize the engine
    [Switchboard beginWithServerURL:serverURL 
                  andServerURLStage:nil 
                         andMainURL:mainURL 
                    andMainURLStage:nil 
                           andDebug:debug];
}

#pragma mark - singleton management

// Get the singleton object. 
// As a static method this looks like [Switchboard sharedInstance]
+ (Switchboard*) sharedInstance {
    
    // if the singleton doesn't exist yet
    if (sharedInstance == nil) {
        
        // create it
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    
    // return the singleton
    return sharedInstance;
}

// We don't want to allocate a new instance, so return the current one.
+ (id)allocWithZone:(NSZone*)zone {
    return [[self sharedInstance] retain];
}

// Equally, we don't want to generate multiple copies of the singleton.
- (id)copyWithZone:(NSZone *)zone {
    return self;
}

// Once again - do nothing, as we don't have a retain counter for this object.
- (id)retain {
    return self;
}

// Replace the retain counter so we can never release this object.
- (NSUInteger)retainCount {
    return NSUIntegerMax;
}

//Do nothing, other than return the shared instance - as this is expected from autorelease.
- (id)autorelease {
    return self;
}

// It is important to leave this empty. This class should persist throughout the 
// lifetime of the app, so any call to dealloc should be ignored
- (void) dealloc { }


@end
