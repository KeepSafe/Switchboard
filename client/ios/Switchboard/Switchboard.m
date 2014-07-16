//
//  Switchboard.m
//  SwitchboardSample
//
//  Created by Chris Beauchamp on 7/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Switchboard.h"

#define SwitchboardLog(fmt, ...) NSLog((@"Switchboard > %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ## __VA_ARGS__);

// define some server-specific dictionary keys
#define sbUserUUIDKey           @"userUUID"
#define sbUpdateServerURLKey    @"updateServerUrl"
#define sbConfigServerURLKey    @"mainServerUrl"

#define sbServerURL             @"switchboard-preference-server-url"
#define sbMainURL               @"switchboard-preference-launch-count"
#define sbConfigJSON            @"switchboard-preference-config-json"

#define sbExperimentActiveKey   @"isActive"
#define sbExperimentValues      @"values"

@interface Switchboard () {
  // The local variables holding the server url strings.
  // These are passed in via the beginWithServerURL:... methods
  NSString         *userUUID;
  NSString         *serverURL;
  NSString         *mainURL;
  NSDictionary     *values;
  BOOL              debug;
  NSOperationQueue *requestQueue;
  dispatch_group_t  ready;
}

@property (nonatomic, strong) NSString         *userUUID;
@property (nonatomic, strong) NSString         *serverURL;
@property (nonatomic, strong) NSString         *mainURL;
@property (nonatomic, strong) NSDictionary     *values;
@property (nonatomic, assign) BOOL              debug;
@property (nonatomic, strong) NSOperationQueue *requestQueue;

// This is used throughout the class, but never from outside.
// Make a 'private' definition here.
+ (Switchboard *)sharedInstance;

@end

@implementation Switchboard

@synthesize userUUID;
@synthesize serverURL;
@synthesize mainURL;
@synthesize values;
@synthesize debug;
@synthesize requestQueue;

#pragma mark -> Private methods

- (void)whenReady:(void (^)(void))pCompletionBlock {
  if (!ready) {
    if (pCompletionBlock)
      pCompletionBlock();
  } else   {
    dispatch_group_notify(ready, dispatch_get_main_queue(), ^{
      if (pCompletionBlock)
        pCompletionBlock();
    });
  }
}

- (void)loadValuesOfScenario {
  // debugging, print status
  if (self.debug) {
    SwitchboardLog(@"Downloading app configuration");
  }
  
  // if the developer hasn't provided a uuid, use our default uuid
  if (self.userUUID == nil) {
    self.userUUID = [[NSUserDefaults standardUserDefaults] objectForKey:sbUserUUIDKey];
    
    if (!self.userUUID) {
      self.userUUID = [[NSUUID UUID] UUIDString];
      [[NSUserDefaults standardUserDefaults] setObject:self.userUUID forKey:sbUserUUIDKey];
      [[NSUserDefaults standardUserDefaults] synchronize];
    }
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
  NSString *lPackageName = [lAppInfo objectForKey:@"CFBundleIdentifier"]; // Ex: com.KeepSafe.KeepSafe
  NSString *lVersionName = [lAppInfo objectForKey:@"CFBundleShortVersionString"]; // Ex: 1.2.4
  
  // get the main url from preferences
  self.mainURL = [[NSUserDefaults standardUserDefaults] stringForKey:sbMainURL];
  
  // Setup the params for the url query string
  NSMutableDictionary *lParams = [NSMutableDictionary dictionary];
  [lParams setObject:self.userUUID forKey:@"uuid"];
  [lParams setObject:lDevice forKey:@"device"];
  [lParams setObject:lLanguage forKey:@"lang"];
  
  if (lCountry != nil) {
    [lParams setObject:lCountry forKey:@"country"];
  }
  
  [lParams setObject:lManufacturer forKey:@"manufacturer"];
  [lParams setObject:lPackageName forKey:@"appId"];
  [lParams setObject:lVersionName forKey:@"version"];
  
  // print debug log
  if (self.debug) {
    SwitchboardLog(@"Sending params for configuration: %@", lParams);
  }
  
  // build the query string
  NSMutableString *lQueryString = [NSMutableString stringWithString:@"?"];
  
  // iterate through the keys in the parameters
  for (NSString *lKey in[lParams allKeys]) {
    // append the format to the query string
    NSString *lParam = [[lParams objectForKey:lKey] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    if (![lQueryString isEqualToString:@"?"])
      [lQueryString appendString:@"&"];
    
    [lQueryString appendFormat:@"%@=%@", lKey, lParam];
  }
  
  // append the query string to the url string
  NSString *lUrlString = [self.mainURL stringByAppendingString:lQueryString];
  
  // print debug log
  if (self.debug) {
    SwitchboardLog(@"Calling url: %@", lUrlString);
  }
  
  // construct our request
  NSURLRequest *lUrlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:lUrlString]];
  
  // send the request asynchronously
  [NSURLConnection sendAsynchronousRequest:lUrlRequest
                                     queue:self.requestQueue                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         // use our request queue. this throttles so we minimize footprint
                         completionHandler: ^(NSURLResponse *pResponse, NSData *pData, NSError *pError) {
                           // got data
                           if ([pData length] > 0 && pError == nil) {
                             // convert the NSData value into a readable string
                             
                             // print debug log
                             if (self.debug) {
                               NSString *lResponseString = [[NSString alloc] initWithData:pData encoding:NSUTF8StringEncoding];
                               SwitchboardLog(@"Response: %@", lResponseString);
                             }
                             
                             // parse the response string into a json dictionary
                             NSError *lError = nil;
                             NSDictionary *lValues = [NSJSONSerialization JSONObjectWithData:pData options:kNilOptions error:&lError];
                             
                             // store the config to persistent preferences
                             if (lValues != nil && !lError) {
                               NSString *lString = [[NSString alloc] initWithData:pData encoding:NSUTF8StringEncoding];
                               [[NSUserDefaults standardUserDefaults] setObject:lString forKey:sbConfigJSON];
                               [[NSUserDefaults standardUserDefaults] synchronize];
                               
                               self.values = lValues;
                               
                               // print debug
                               if (self.debug) {
                                 SwitchboardLog(@"Updated server config: %@", self.values);
                               }
                             }
                             // there was an error parsing the response
                             else {
                               if (self.debug) {
                                 SwitchboardLog(@"Error updating configuration: unable to parse response");
                               }
                             }
                           }
                           // error occurred
                           else {
                             if (self.debug) {
                               SwitchboardLog(@"Error updating configuration: %@", pError);
                             }
                           }
                           
                           dispatch_group_leave(ready);
                         }];
}

- (void)refreshScenario {
  // get the current server url to access from prefs
  NSString *lServerURL = [[NSUserDefaults standardUserDefaults] stringForKey:sbServerURL];
  
  // set to default when not set in preferences
  if (lServerURL == nil) {
    lServerURL = self.serverURL;
  }
  
  // set up our request
  NSURLRequest *lUrlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:lServerURL]];
  
  ready = dispatch_group_create();
  
  dispatch_group_enter(ready);
  // make an async connection on our request queue.
  [NSURLConnection sendAsynchronousRequest:lUrlRequest
                                     queue:self.requestQueue
                         completionHandler: ^(NSURLResponse *pResponse, NSData *pData, NSError *pError) {
                           // got data
                           if ([pData length] > 0 && pError == nil) {
                             // print response if debugging
                             if (self.debug) {
                               // convert the NSData value into a readable string
                               NSString *lResponseString = [[NSString alloc] initWithData:pData encoding:NSUTF8StringEncoding];
                               SwitchboardLog(@"Response: %@", lResponseString);
                             }
                             
                             // generate a dict out of the response json
                             NSError *lError = nil;
                             NSDictionary *lJson = [NSJSONSerialization JSONObjectWithData:pData options:kNilOptions error:&lError];
                             
                             // make sure we were able to parse the json
                             if (lJson != nil && !lError) {
                               NSString *lServerURL = [lJson objectForKey:sbUpdateServerURLKey];
                               NSString *lMainURL = [lJson objectForKey:sbConfigServerURLKey];
                               
                               // read the new server values from the json
                               if (lServerURL) {
                                 self.serverURL = lServerURL;
                                 [[NSUserDefaults standardUserDefaults] setObject:self.serverURL forKey:sbServerURL];
                                 [[NSUserDefaults standardUserDefaults] synchronize];
                               }
                               
                               if (lMainURL) {
                                 self.mainURL = [lJson objectForKey:sbConfigServerURLKey];
                                 [[NSUserDefaults standardUserDefaults] setObject:self.mainURL forKey:sbMainURL];
                                 [[NSUserDefaults standardUserDefaults] synchronize];
                               }
                               
                               // print results if debugging
                               if (self.debug) {
                                 SwitchboardLog(@"Updated server url: %@", self.serverURL);
                                 SwitchboardLog(@"Updated config url: %@", self.mainURL);
                               }
                             }
                             // there was an error parsing the response
                             else {
                               // load the default values from the disk
                               self.serverURL = [[NSUserDefaults standardUserDefaults] stringForKey:sbServerURL];
                               self.mainURL = [[NSUserDefaults standardUserDefaults] stringForKey:sbMainURL];
                               
                               if (self.debug) {
                                 SwitchboardLog(@"Error updating server URLs: Could not parse response");
                               }
                             }
                           }
                           // something went wrong
                           else {
                             // load the default values from the disk
                             self.serverURL = [[NSUserDefaults standardUserDefaults] stringForKey:sbServerURL];
                             self.mainURL = [[NSUserDefaults standardUserDefaults] stringForKey:sbMainURL];
                             
                             if (self.debug) {
                               SwitchboardLog(@"Error updating server URLs: %@", pError);
                             }
                           }
                           
                           // Download values of the scenario
                           [self loadValuesOfScenario];
                         }];
}

- (void)beginWithServerURL:(NSString *)pServerURL
         andServerURLStage:(NSString *)pServerURLStage
                andMainURL:(NSString *)pMainURL
           andMainURLStage:(NSString *)pMainURLStage
                  andDebug:(BOOL)pDebug {
  // set up our operation queue
  self.requestQueue = [[NSOperationQueue alloc] init];
  
  // limit to 1 request at a time. we don't want to use too much of the app's resources
  [self.requestQueue setMaxConcurrentOperationCount:1];
  
  // keep the debug variable locally
  self.debug = pDebug;
  
  // if we were passed a staging server and we're in debug mode
  if (pServerURLStage != nil && pDebug) {
    // use the stage as the default server
    self.serverURL = pServerURLStage;
  } else   {
    self.serverURL = pServerURL;
  }
  
  // if we were passed a staging server and we're in debug mode
  if (pMainURLStage != nil && pDebug) {
    // use the stage as the default server
    self.mainURL = pMainURLStage;
  } else   {
    // keep the urls around locally
    self.mainURL = pMainURL;
  }
  
  // By default load values from the disk of the last downloaded scenario
  NSError      *lError = nil;
  NSString     *lString = [[NSUserDefaults standardUserDefaults] objectForKey:sbConfigJSON];
  NSData       *lData = [lString dataUsingEncoding:NSUTF8StringEncoding];
  NSDictionary *lValues = [NSJSONSerialization JSONObjectWithData:lData options:kNilOptions error:&lError];
  
  if (lValues != nil && !lError) {
    self.values = lValues;
  }
  
  [self refreshScenario];
}

#pragma mark -> Class methods

// Get the singleton object.
// As a static method this looks like [Switchboard sharedInstance]
// This method is not public
+ (Switchboard *)sharedInstance {
  static Switchboard    *sSingleton = nil;
  static dispatch_once_t sOnceToken;
  
  dispatch_once(&sOnceToken, ^{
    // Create Switchboar shared instance
    sSingleton = [[Switchboard alloc] init];
  });
  
  return sSingleton;
}

+ (void)beginWithServerURL:(NSString *)pServerURL
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

+ (void)beginWithServerURL:(NSString *)pServerURL
                andMainURL:(NSString *)pMainURL
                  andDebug:(BOOL)pDebug {
  // initialize the engine
  [Switchboard beginWithServerURL:pServerURL
                andServerURLStage:nil
                       andMainURL:pMainURL
                  andMainURLStage:nil
                         andDebug:pDebug];
}

+ (BOOL)debugMode {
  // the static call must access the value in our singleton
  return [Switchboard sharedInstance].debug;
}

+ (void)experiment:(NSString *)pExperimentName completionBlock:(void (^)(NSDictionary *pValues))pCompletionBlock {
  // default to nil
  NSDictionary *lValues = [Switchboard sharedInstance].values;
  
  // if we have a valid config
  if (lValues != nil) {
    // extract the experiment values
    NSDictionary *lExperiment = [lValues objectForKey:pExperimentName];
    
    // Check if experiment is active
    if ([[lExperiment objectForKey:sbExperimentActiveKey] boolValue]) {
      // Get the values of the experiment
      NSDictionary *lExperimentValues = [lExperiment objectForKey:sbExperimentValues];
      
      if (lExperimentValues && pCompletionBlock) {
        pCompletionBlock(lExperimentValues);
      }
    }
  }
}

+ (void)whenReady:(void (^)(void))pCompletionBlock {
  [[Switchboard sharedInstance] whenReady:pCompletionBlock];
}

+ (void)refreshScenario {
  [[Switchboard sharedInstance] refreshScenario];
}

@end