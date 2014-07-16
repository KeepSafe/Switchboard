//
//  Switchboard.h
//  SwitchboardSample
//
//  Created by Chris Beauchamp on 7/15/12.
//  License pending
//

#import <Foundation/Foundation.h>

/**
 * SwitchBoard is the core class of the KeepSafe Switchboard mobile A/B testing framework.
 * This class provides several static methods that can be used in your app to run A/B tests.
 *
 * The SwitchBoard supports production and staging environment.
 *
 * For usage <code>initDefaultServerUrls</code> for first time usage. Server URLs can be updates from
 * a remote location with <code>initConfigServerUrl</code>.
 *
 * To run an experiment use <code>isInExperiment:</code>. The experiment name must match an experiment
 * that is set up on the server.
 *
 * All functions are design to be safe for programming mistakes and network connection issues. If the
 * experiment does not exists it will return false and pretend the user is not part of it.
 *
 * @author Chris Beauchamp
 *
 */
@interface Switchboard : NSObject 

/**
 * Basic initialization with one server.
 * @param serverURL Url to: http://sub.domain/path_to/SwitchboardURLs.php
 * @param mainURL Url to: http://sub.domain/path_to/SwitchboardDriver.php - the acutall config
 * @param debug Is the application running in debug mode. This will add log messages.
 */
+ (void) beginWithServerURL:(NSString *)serverURL
                 andMainURL:(NSString *)mainURL
                   andDebug:(BOOL)debug;

/**
 * Advanced initialization that supports a production and staging environment without changing the server URLs manually.
 * SwitchBoard will connect to the staging environment in debug mode. This makes it very simple to test new experiements
 * during development.
 * @param serverURL Url to http://sub.domain/path_to/SwitchboardURLs.php in production environment
 * @param serverURLStage Url to http://sub.domain/path_to/SwitchboardURLs.php in staging environment
 * @param mainURL Url to: http://sub.domain/path_to/SwitchboardDriver.php in production - the acutal config
 * @param mainURLStage Url to: http://sub.domain/path_to/SwitchboardDriver.php in production - the acutal config
 * @param debug Defines if the app runs in debug.
 */
+ (void) beginWithServerURL:(NSString *)serverURL
          andServerURLStage:(NSString *)serverURLStage
                 andMainURL:(NSString *)mainURL
            andMainURLStage:(NSString *)mainURLStage
                   andDebug:(BOOL)debug;

/** See if the application is run in debug mode. downloadConfiguration runs against staging server when in debug and production when not */
+ (BOOL) isInDebugMode;

/**
 * Updates the server URLs from remote and stores it locally in the app. This allows to move the server side
 * with users already using Switchboard.
 * When there is no internet connection it will continue to use the URLs from the last time or
 * default URLS that have been set with <code>beginWithServerURL:...</code>.
 *
 * This method is asynchronous, and will not block your main thread
 */
+ (void) updateServerURLs;

/**
 * Loads a new config file for the specific user from current config server. Uses internal unique user ID.
 * This method is asynchronous, and will not block your main thread
 */
+ (void) downloadConfiguration;

/**
 * Loads a new config for a user. This method allows you to pass your own unique user ID instead of using
 * the SwitchBoard internal user ID.
 * This method is asynchronous, and will not block your main thread
 * @param uuid Custom unique user ID
 */
+ (void) downloadConfigurationWithCustomUUID:(NSString *)uuid;

/**
 * Looks up in config if user is in certain experiment. Returns false as a default value when experiment
 * does not exist.
 * Experiment names are defined server side as Key in array for return values.
 * @param experimentName Name of the experiment to lookup
 * @return returns value for experiment or false if experiment does not exist.
 */
+ (BOOL) isInExperiment:(NSString *)experimentName;

/**
 * Looks up in config if user is in certain experiment.
 * Experiment names are defined server side as Key in array for return values.
 * @param experimentName Name of the experiment to lookup
 * @param defaultValue The return value that should be return when experiment does not exist
 * @return returns value for experiment or defaultReturnVal if experiment does not exist.
 */
+ (BOOL) isInExperiment:(NSString *)experimentName withDefault:(BOOL)defaultValue;

/**
 * Checks if a certain experiment exists.
 * @param experimentName Name of the experiment
 * @return TRUE when experiment exists
 */
+ (BOOL) hasExperimentValues:(NSString *)experimentName;

/**
 * Returns the experiment value as an NSDictionary. Depending on what experiment is has to be converted to the right type.
 * Typcasting is by convention. You have to know what is in there. Use <code>hasExperimentValues:</code>
 * before this to avoid a nil return value.
 * @param experimentName Name of the experiment to lookup
 * @return Experiment value as NSDictionary, null if experiment does not exist.
 */
+ (NSDictionary *) getExperimentValueFromJSON:(NSString *)experimentName;

@end