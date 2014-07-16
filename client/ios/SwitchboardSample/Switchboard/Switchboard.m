//
//  Switchboard.m
//  SwitchboardSample
//
//  Created by Chris Beauchamp on 7/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Switchboard.h"

#import "SBPreferences.h"

// the variable to hold our singleton instance
static Switchboard *sharedInstance = nil;

@interface Switchboard () {
  // The local variables holding the server url strings.
  // These are passed in via the beginWithServerURL:... methods
  NSString *_serverURL;
  NSString *_mainURL;
  
  // Local variable with the current debug mode. TRUE = on.
  BOOL _debug;
  
  // An operation queue to handle our HTTP requests
  NSOperationQueue *_requestQueue;
}

// This is used throughout the class, but never from outside.
// Make a 'private' definition here.
+ (Switchboard *)sharedInstance;

@end

@implementation Switchboard

// A convenience method to store the local URL strings to
// the persistent preferences file (if these prefs don't already exist)
- (void) storeDefaultURLsInPreferences {
  // get the defaults from the prefs file
  NSString *serverURL = [SBPreferences getServerURL];
  NSString *mainURL = [SBPreferences getMainURL];
  
  // if there's no server URL
  if (serverURL == nil) {
    // store the local var
    serverURL = _serverURL;
  }
  
  // if there's no main URL
  if (mainURL == nil) {
    // store the local var
    mainURL = _mainURL;
  }
  
  // save these prefs
  [SBPreferences setServerURL:serverURL andMainURL:mainURL];
}

+ (BOOL) isInExperiment:(NSString *)pExperimentName withDefault:(BOOL)pDefaultValue {
  // get the dictionary containing the current configuration
  NSDictionary *lJson = [SBPreferences getConfigurationJSON];
  BOOL          lRet = pDefaultValue;
  
  // if the dictionary exists
  if (lJson != nil) {
    // print a log if we're debugging
    if ([Switchboard isInDebugMode]) {
      SBLog(@"Experiment '%@' JSON Object: %@", pExperimentName, lJson);
    }
    
    // wrap in try/catch in case either of these keys don't exist or are typed incorrectly
    @try {
      // get the experiment dictionary
      NSDictionary *experiment = [lJson objectForKey:pExperimentName];
      
      // determine if this experiment is active
      lRet = [[experiment objectForKey:sbExperimentActiveKey] boolValue];
    }
    
    // one of the keys was invalid
    @catch(NSException *lException) {
      if ([Switchboard isInDebugMode]) {
        SBLog(@"Unable to parse json for experiment: %@", pExperimentName);
      }
    }
  }
  
  // print the result if we're debugging
  if ([Switchboard isInDebugMode]) {
    SBLog(@"In Experiment '%@': %d", pExperimentName, lRet ? 1 : 0);
  }
  
  // return the final value
  return lRet;
}

+ (BOOL) isInExperiment:(NSString *)pExperimentName {
  // pass thru to the 'full' method
  return [Switchboard isInExperiment:pExperimentName withDefault:FALSE];
}

+ (BOOL) hasExperimentValues:(NSString *)pExperimentName {
  // Convenience method for dev to quickly check if experiment values exist.
  // If not nil, values do exist.
  return [Switchboard getExperimentValueFromJSON:pExperimentName] != nil;
}

+ (NSDictionary *) getExperimentValueFromJSON:(NSString *)pExperimentName {
  // default to nil
  NSDictionary *lRet = nil;
  
  // load the configuration
  NSDictionary *lConfig = [SBPreferences getConfigurationJSON];
  
  // if we have a valid config
  if (lConfig != nil) {
    // extract the experiment values
    NSDictionary *experiment = [lConfig objectForKey:pExperimentName];
    
    // get the return values
    lRet = [experiment objectForKey:sbExperimentValues];
  }
  
  return lRet;
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
  if (_debug) {
    SBLog(@"Update server URLs");
    
    // set default value that is set in code
    [SBPreferences setServerURL:_serverURL andMainURL:_mainURL];
    return;
  }
  
  // get the current server url to access from prefs
  NSString *lUrlString = [SBPreferences getServerURL];
  
  // set to default when not set in preferences
  if (lUrlString == nil) {
    lUrlString = _serverURL;
  }
  
  // set up our request
  NSURL        *lUrl = [NSURL URLWithString:lUrlString];
  NSURLRequest *lUrlRequest = [NSURLRequest requestWithURL:lUrl];
  
  // make an async connection on our request queue.
  [NSURLConnection sendAsynchronousRequest:lUrlRequest
                                     queue:_requestQueue
                         completionHandler:^(NSURLResponse *pResponse, NSData *pData, NSError *pError) {
                           // got data
                           if ([pData length] > 0 && pError == nil) {
                             
                             // print response if debugging
                             if (_debug) {
                               // convert the NSData value into a readable string
                               NSString *lResponseString = [[NSString alloc] initWithData:pData encoding:NSUTF8StringEncoding];
                               SBLog(@"Response: %@", lResponseString);
                             }
                             
                             // generate a dict out of the response json
                             NSError *lError = nil;
                             NSDictionary *lJson = [NSJSONSerialization JSONObjectWithData:pData options:kNilOptions error:&lError];
                             
                             // make sure we were able to parse the json
                             if (lJson != nil && !lError) {
                               // read the new server values from the json
                               NSString *updateServerURL = [lJson objectForKey:sbUpdateServerURLKey];
                               NSString *configServerURL = [lJson objectForKey:sbConfigServerURLKey];
                               
                               // update the preferences
                               [SBPreferences setServerURL:updateServerURL andMainURL:configServerURL];
                               
                               // print results if debugging
                               if (_debug) {
                                 SBLog(@"Updated server url: %@", updateServerURL);
                                 SBLog(@"Updated config url: %@", configServerURL);
                               }
                             }
                             // there was an error parsing the response
                             else {
                               // load the default values into preferences
                               [self storeDefaultURLsInPreferences];
                               
                               if (_debug) {
                                 SBLog(@"Error updating server URLs: Could not parse response");
                               }
                             }
                           }
                           // something went wrong
                           else {
                             // load the default values into preferences
                             [self storeDefaultURLsInPreferences];
                             
                             if (_debug) {
                               SBLog(@"Error updating server URLs: %@", pError);
                             }
                           }
                         }];
}

+ (void) updateServerURLs {
  [[Switchboard sharedInstance] updateServerURLs];
}

- (void) downloadConfiguration:(NSString *)pUUID {
  // debugging, print status
  if (_debug) {
    SBLog(@"Downloading app configuration");
  }
  
  // if the developer hasn't provided a uuid, use our default uuid
  if (pUUID == nil) {
    pUUID = [[NSUUID UUID] UUIDString];
  }
  
  // get the current user's locale
  NSLocale *lCurrentUserLocal = [NSLocale currentLocale];
  
  // get some bundle information for the app
  NSDictionary *lAppInfo = [[NSBundle mainBundle] infoDictionary];
  
  // load params for sending to the server
  NSString *lDevice = [UIDevice currentDevice].model;
  NSString *lManufacturer = @"Apple";
  NSString *lLanguage = [lCurrentUserLocal objectForKey:NSLocaleLanguageCode];
  NSString *lCountry = [lCurrentUserLocal objectForKey:NSLocaleCountryCode];
  NSString *lPackageName = [lAppInfo objectForKey:@"CFBundleIdentifier"];   // Ex: com.KeepSafe.KeepSafe
  NSString *lVersionName = [lAppInfo objectForKey:@"CFBundleShortVersionString"];   // Ex: 1.2.4
  
  // get the main url from preferences
  NSString *lUrlString = [SBPreferences getMainURL];
  
  // Setup the params for the url query string
  NSMutableDictionary *lParams = [NSMutableDictionary dictionary];
  [lParams setObject:pUUID forKey:@"uuid"];
  [lParams setObject:lDevice forKey:@"device"];
  [lParams setObject:lLanguage forKey:@"lang"];
  
  if (lCountry != nil) {
    [lParams setObject:lCountry forKey:@"country"];
  }
  
  [lParams setObject:lManufacturer forKey:@"manufacturer"];
  [lParams setObject:lPackageName forKey:@"appId"];
  [lParams setObject:lVersionName forKey:@"version"];
  
  // print debug log
  if (_debug) {
    SBLog(@"Sending params for configuration: %@", lParams);
  }
  
  // build the query string
  NSMutableString *lQueryString = [NSMutableString stringWithString:@"?"];
  
  // iterate through the keys in the parameters
  for (NSString *lKey in [lParams allKeys]) {
    // append the format to the query string
    NSString *lParam = [[lParams objectForKey:lKey] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    if (![lQueryString isEqualToString:@"?"])
      [lQueryString appendString:@"&"];
    
    [lQueryString appendFormat:@"%@=%@", lKey, lParam];
  }
  
  // append the query string to the url string
  lUrlString = [lUrlString stringByAppendingString:lQueryString];
  
  // print debug log
  if (_debug) {
    SBLog(@"Calling url: %@", lUrlString);
  }
  
  // construct our request
  NSURL        *lUrl = [NSURL URLWithString:lUrlString];
  NSURLRequest *lUrlRequest = [NSURLRequest requestWithURL:lUrl];
  
  // send the request asynchronously
  [NSURLConnection sendAsynchronousRequest:lUrlRequest
                                     queue:_requestQueue                                                                                                                                                                                                                                                                                                                                                                                                                           // use our request queue. this throttles so we minimize footprint
                         completionHandler:^(NSURLResponse *pResponse, NSData *pData, NSError *pError) {
                           // got data
                           if ([pData length] > 0 && pError == nil) {
                             // convert the NSData value into a readable string
                             NSString *lResponseString = [[NSString alloc] initWithData:pData encoding:NSUTF8StringEncoding];
                             
                             // print debug log
                             if (_debug) {
                               SBLog(@"Response: %@", lResponseString);
                             }
                             
                             // parse the response string into a json dictionary
                             NSError *lError = nil;
                             NSDictionary *lJson = [NSJSONSerialization JSONObjectWithData:pData options:kNilOptions error:&lError];
                             
                             // store the config to persistent preferences
                             if (lJson != nil && !lError) {
                               [SBPreferences setConfigurationJSON:lJson];
                               
                               // print debug
                               if (_debug) {
                                 SBLog(@"Updated server config: %@", lJson);
                               }
                             }
                             // there was an error parsing the response
                             else {
                               if (_debug) {
                                 SBLog(@"Error updating configuration: unable to parse response");
                               }
                             }
                           }
                           // error occurred
                           else {
                             if (_debug) {
                               SBLog(@"Error updating configuration: %@", pError);
                             }
                           }
                         }];
}

+ (void) downloadConfigurationWithCustomUUID:(NSString *)uuid {
  [[Switchboard sharedInstance] downloadConfiguration:uuid];
}

+ (void) downloadConfiguration {
  [Switchboard downloadConfigurationWithCustomUUID:nil];
}

#pragma mark initialization
- (void) beginWithServerURL:(NSString *)pServerURL
          andServerURLStage:(NSString *)pServerURLStage
                 andMainURL:(NSString *)pMainURL
            andMainURLStage:(NSString *)pMainURLStage
                   andDebug:(BOOL)pDebug {
  // set up our operation queue
  _requestQueue = [[NSOperationQueue alloc] init];
  
  // limit to 1 request at a time. we don't want to use too much of the app's resources
  [_requestQueue setMaxConcurrentOperationCount:1];
  
  // keep the debug variable locally
  _debug = pDebug;
  
  // keep the urls around locally
  _serverURL = [pServerURL retain];
  _mainURL = [pMainURL retain];
  
  // if we were passed a staging server and we're in debug mode
  if (pServerURLStage != nil && pDebug) {
    // use the stage as the default server
    _serverURL = [pServerURLStage retain];
  }
  
  // if we were passed a staging server and we're in debug mode
  if (pMainURLStage != nil && pDebug) {
    // use the stage as the default server
    _mainURL = [pMainURLStage retain];
  }
  
  // store the strings in the persistent preference file
  [self storeDefaultURLsInPreferences];
}

+ (void) beginWithServerURL:(NSString *)pServerURL
          andServerURLStage:(NSString *)pServerURLStage
                 andMainURL:(NSString *)pMainURL
            andMainURLStage:(NSString *)pMainURLStage
                   andDebug:(BOOL)pDebug {
  // initialize the engine
  [[Switchboard sharedInstance] beginWithServerURL:pServerURL
                                 andServerURLStage:pServerURLStage
                                        andMainURL:pMainURL
                                   andMainURLStage:pMainURLStage
                                          andDebug:pDebug];
}

+ (void) beginWithServerURL:(NSString *)pServerURL
                 andMainURL:(NSString *)pMainURL
                   andDebug:(BOOL)pDebug {
  // initialize the engine
  [Switchboard beginWithServerURL:pServerURL
                andServerURLStage:nil
                       andMainURL:pMainURL
                  andMainURLStage:nil
                         andDebug:pDebug];
}

#pragma mark - singleton management



// Get the singleton object.
// As a static method this looks like [Switchboard sharedInstance]
+ (Switchboard *) sharedInstance {
  // if the singleton doesn't exist yet
  if (sharedInstance == nil) {
    // create it
    sharedInstance = [[super allocWithZone:NULL] init];
  }
  
  // return the singleton
  return sharedInstance;
}

@end