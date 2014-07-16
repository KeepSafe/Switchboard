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
 * For usage <code>beginWithServerURL:andMainURL:andDebug:</code> for first time usage. Server URLs are automatically update from
 * a remote location. Values for scenario are automatically updated from a remote location or load from the disk.
 *
 * To run an experiment use <code>experiment:completionBlock:</code>.
 * that is set up on the server.
 *
 * All functions are design to be safe for programming mistakes and network connection issues.
 *
 * @author Chris Beauchamp
 * @updated Christophe Braud
 *
 */
@interface Switchboard : NSObject

/**
 * Basic initialization with one server.
 * @param pServerURL Url to: http://sub.domain/path_to/SwitchboardURLs.php
 * @param pMainURL Url to: http://sub.domain/path_to/SwitchboardDriver.php - the acutall config
 * @param pDebug Is the application running in debug mode. This will add log messages.
 */
+ (void)beginWithServerURL:(NSString *)pServerURL
                andMainURL:(NSString *)pMainURL
                  andDebug:(BOOL)pDebug;

/**
 * Advanced initialization that supports a production and staging environment without changing the server URLs manually.
 * SwitchBoard will connect to the staging environment in debug mode. Automatically this method update the URLs from
 * the server and load values of scenarios.
 * @param pServerURL Url to http://sub.domain/path_to/SwitchboardURLs.php in production environment
 * @param pServerURLStage Url to http://sub.domain/path_to/SwitchboardURLs.php in staging environment
 * @param pMainURL Url to: http://sub.domain/path_to/SwitchboardDriver.php in production - the acutal config
 * @param pMainURLStage Url to: http://sub.domain/path_to/SwitchboardDriver.php in production - the acutal config
 * @param pDebug Defines if the app runs in debug.
 */
+ (void)beginWithServerURL:(NSString *)pServerURL
         andServerURLStage:(NSString *)pServerURLStage
                andMainURL:(NSString *)pMainURL
           andMainURLStage:(NSString *)pMainURLStage
                  andDebug:(BOOL)pDebug;

/**
 * Execute the completion block if the experiment exist and if it's active. The block receive the values for the experimentation.
 * @param pExperimentName Name of the experiment to lookup
 * @param pCompletionBlock execute the block if the experiment exist and is active
 */
+ (void)experiment:(NSString *)pExperimentName completionBlock:(void (^)(NSDictionary *pValues))pCompletionBlock;

/**
 * When the URLs are updated and the values of scenarios are loaded the block is executed.
 * @param pCompletionBlock execute the block if the experiment exist and is active
 */
+ (void)whenReady:(void (^)(void))pCompletionBlock;

/**
 * Update the URLs from a remote location and update values of scenarios.
 */
+ (void)refreshScenario;

/** See if the application is run in debug mode.*/
+ (BOOL)debugMode;

@end