<?php
include('switchboard/switchBoardConfigManager.php');
/* Possible params
 * $lang - Device language
 * $manufacturer - Device manufacturer
 * $device - device model name
 * $uuid - client side generated unique user id
 * $country - device country
 * $version - app version
 */

//result experiment array
$resultArray = array();

//pin message
$resultArray['homeScreenMessage'] = sampleExperiment($uuid, $lang, $version);
$resultArray['nextActivityTest'] = turnOnBucket($uuid, 0, 50);


//return result array as JSON
renderResultJson($resultArray);


/** Sample experiment that gives 20% of the users a message. Those 20% are devided into two groups that
  * get to see a different message
  */
function sampleExperiment($uuid, $lang, $version) {
	if(empty($uuid))
		return inactiveExperimentReturnArray();
	
	//turn expiriment on for bucket 0-19. First 20% of the users
	if(isInBucket($uuid, 0, 20)) {
		//return values
		$values = array();
		
		//Filter for only users with english language settings
		if($lang == "eng") {
			//first 10% of the user see this message
			if(isInBucket($uuid, 0, 10)){
				//message that you want to display in the app
				$values['message'] = 'IMPORTANT! Get KeepSafe: <a href="market://details?id=com.kii.safe">click HERE.</a>'; 
				
				//message title that you give your analytics enging to track what version the user saw
				$values['messageTitle'] = 'get KeepSafe ver 1';

				return activeExperimentReturnArray($values);
			//the other 10% of the user see another message
			} else {
				$values['message'] = 'Please download KeepSafe: <a href="market://details?id=com.kii.safe">click HERE.</a>'; 
				$values['messageTitle'] = 'get KeepSafe ver 2';

				return activeExperimentReturnArray($values);
			}		
		}
	}
	
	//user is not in experiment as default
	return inactiveExperimentReturnArray();
}

?>